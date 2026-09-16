import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:chaoperty_user/Model/GetInvoice_Model.dart';
import 'package:chaoperty_user/Model/GetInvoice_pay_Model.dart';
import 'package:chaoperty_user/Model/GetPayMent_Model.dart';
import 'package:chaoperty_user/Model/GetTeNant_Model.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/screen_Intents/Model/IntentsContractx_Fine_Model.dart';
import 'package:chaoperty_user/screen_Intents/Model/IntentsInv_history_Model.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_intent_payload.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_qr_payload.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/services/payment_subv4_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
/// ผลลัพธ์ของ `_loadOrCreateSession`
///
/// [session] คือ `active_qr_session` (ว่างได้ถ้า server ไม่ให้)
/// [source] คือ payload ระดับบนของ response ที่ session นี้มาจาก — ใช้ fallback
/// ค่า `soft_expire_at` ของบิล ซึ่งอยู่นอก session
typedef QrSessionResult = ({
  Map<String, dynamic> session,
  Map<String, dynamic> source,
});

class PaymentSubV4ViewModel extends ChangeNotifier {
  PaymentSubV4ViewModel({
    required this.params,
    PaymentSubV4Service? service,
  })  : _service = service ?? PaymentSubV4Service(),
        _state = const PaymentSubV4State();

  /// สำหรับ test — seed state เริ่มต้นได้โดยไม่ต้องยิง network
  @visibleForTesting
  PaymentSubV4ViewModel.withState({
    required this.params,
    required PaymentSubV4State initialState,
    PaymentSubV4Service? service,
  })  : _service = service ?? PaymentSubV4Service(),
        _state = initialState;

  final PaymentSubV4Params params;
  final PaymentSubV4Service _service;

  PaymentSubV4State _state;
  PaymentSubV4State get state => _state;

  StreamSubscription<int>? _timerSub;
  bool _isDisposed = false;

  /// อายุเต็มของ session (วินาที) ใช้คำนวณ progress bar
  int _sessionTotalSecs = 0;
  int get sessionTotalSecs => _sessionTotalSecs;

  /// เลขลำดับ event เพิ่มขึ้นทุกครั้งที่ emit
  int _eventSeq = 0;

  /// สร้าง UI event ที่มี seq ไม่ซ้ำ เพื่อให้ชนิดเดิมเกิดซ้ำได้
  PaymentUiEvent _event(String id, String message, {bool isError = false}) =>
      PaymentUiEvent(
        id: id,
        message: message,
        isError: isError,
        seq: ++_eventSeq,
      );

  /// parse ตัวเลขแบบปลอดภัย (null/empty/comma → 0)
  double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    final s = v.toString().replaceAll(',', '').trim();
    if (s.isEmpty) return 0;
    return double.tryParse(s) ?? 0;
  }

  void _updateState(PaymentSubV4State newState) {
    if (_isDisposed) return;
    _state = newState;
    notifyListeners();
  }

  /// resolve intent ที่ caller ต้องการเปิด
  /// ลำดับ: intentUuid → paymentIntentNo → selectedDocNos เทียบ billReference
  /// คืน list ว่าง = ไม่ได้มาจาก intent card
  List<PaymentIntent> _resolveTargetIntents(List<PaymentIntent> intents) {
    final wantUuid = (params.targetIntentUuid ?? '').trim();
    if (wantUuid.isNotEmpty) {
      final hit = intents
          .where((p) => (p.intentUuid ?? '').trim() == wantUuid)
          .toList();
      if (hit.isNotEmpty) return hit;
    }

    final wantNo = (params.targetPaymentIntentNo ?? '').trim();
    if (wantNo.isNotEmpty) {
      final hit = intents
          .where((p) => (p.paymentIntentNo ?? '').trim() == wantNo)
          .toList();
      if (hit.isNotEmpty) return hit;
    }

    final docNos = params.selectedDocNos;
    if (docNos != null && docNos.isNotEmpty) {
      return intents.where((p) {
        return p.invoices.any((inv) {
          final ref = (inv.billReference ?? '').trim();
          return ref.isNotEmpty && docNos.contains(ref);
        });
      }).toList();
    }

    return const [];
  }

  /// Initial Load
  Future<void> initialize() async {
    _updateState(_state.copyWith(
      pageStatus: PageStatus.loading,
      operation: PaymentOperation.none,
      clearError: true,
    ));

    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = (prefs.getString('renTalSer') ?? '').trim();
      final custno = (prefs.getString('custno') ?? '').trim();
      final usercid = (prefs.getString('usercid') ?? '').trim();
      final qutser = (prefs.getString('qutser') ?? '1').trim();

      // 1. Auth Gate
      final isAuthOk = await _service.checkAuth();

      // 2. โหลด Payment Methods & Rental (ไม่พึ่งกัน → ขนานกันได้)
      final paymentRes = await _service.loadPaymentMethods(ren: ren);
      final rentalRes = await _service.loadRentalData(ren: ren);

      final paymentMethods =
          paymentRes.isSuccess ? paymentRes.valueOr : <PayMentModel>[];
      final rental = rentalRes.isSuccess ? rentalRes.valueOr : null;
      // โหลด rental ไม่สำเร็จ = ไม่มีข้อมูลโครงการ ไม่ใช่คงค่าเก่าที่อาจผิด
      final clearRental = !rentalRes.isSuccess;

      // Resolve selected payment model
      PayMentModel? selectedPay;
      if (params.paymentSerial != null && params.paymentSerial!.isNotEmpty) {
        try {
          selectedPay = paymentMethods.firstWhere(
            (m) => m.ser.toString() == params.paymentSerial,
          );
        } catch (_) {}
      }
      selectedPay ??= paymentMethods.isNotEmpty ? paymentMethods.first : null;

      // 3. โหลด Tenant Models
      var tenants = params.tenants;
      if (tenants == null || tenants.isEmpty) {
        final tenantRes = await _service.loadTenantData(
          ren: ren,
          cidDoc: usercid,
          qutser: qutser,
        );
        tenants = tenantRes.isSuccess ? tenantRes.valueOr : <TeNantModel>[];
      }

      final List<String> cids = tenants.isNotEmpty
          ? tenants.map((t) => t.cid ?? '').where((c) => c.isNotEmpty).toList()
          : [usercid];

      // 4. โหลด Payment Intents (ต้องมี auth เท่านั้น)
      final intents = isAuthOk
          ? await _service.loadPaymentIntents(
              cusno: custno,
              propertyno: ren,
              serPayment: params.paymentSerial,
            )
          : <PaymentIntent>[];

      // 5. โหลด Invoices & Contract Fines
      final invoiceRes = await _service.loadInvoices(
        ren: ren,
        cids: cids,
        qutser: qutser,
      );
      final fineRes = await _service.loadContractFines(
        ren: ren,
        cids: cids,
      );

      final invoices =
          invoiceRes.isSuccess ? invoiceRes.valueOr : <InvoiceModel>[];
      final contractFines =
          fineRes.isSuccess ? fineRes.valueOr : <IntentsContractxFineModel>[];

      // เก็บ error ของแต่ละ section ไว้แสดง แทนการกลืนหาย
      final sectionErrors = <String>{
        if (!paymentRes.isSuccess) paymentRes.error!,
        if (!rentalRes.isSuccess) rentalRes.error!,
        if (!invoiceRes.isSuccess) invoiceRes.error!,
        if (!fineRes.isSuccess) fineRes.error!,
      };

      // 6. Filter Invoices ตามสถานะ Intent
      final List<InvoiceModel> payableInvoices = [];
      final List<InvoiceModel> inIntentInvoices = [];

      for (final inv in invoices) {
        final docno = (inv.docno ?? '').trim();
        final inIntent = intents.any((intent) =>
            intent.invoices.any((i) => (i.billReference ?? '').trim() == docno));

        // Filter ตาม payser หรือ selectedDocNos
        final isPayerMatched =
            inv.payser.toString() == (params.paymentSerial ?? '');
        final isFromIntent = params.fromIntent;
        final isInSelected = params.selectedDocNos != null &&
            params.selectedDocNos!.contains(docno);

        if (!isPayerMatched && !isFromIntent) continue;
        if (params.selectedDocNos != null &&
            params.selectedDocNos!.isNotEmpty &&
            !isInSelected) {
          continue;
        }

        if (inIntent) {
          inIntentInvoices.add(inv);
        } else {
          payableInvoices.add(inv);
        }
      }

      // 7. คำนวณยอดเงินรวม
      final summary = _calculateSummary(payableInvoices, selectedPay);

      // 8. Auto-Switch แท็บ (ใช้เฉพาะ intent ที่ caller ระบุ เมื่อมี)
      final targetIntents = _resolveTargetIntents(intents);
      final cameFromIntent = targetIntents.isNotEmpty;

      int targetTab = _state.selectedTab;
      if (!_state.hasAutoSwitched) {
        if (cameFromIntent) {
          // ลำดับความสำคัญ: สถานะ intent มาก่อน เพราะผู้ใช้กดมาจาก intent card
          // ใช้กติกาข้อความ status แบบเดียวกับต้นฉบับ (ไม่ใช่ classifier ที่นับ slip_uploaded)
          final hasVerify = targetIntents
              .any((p) => PaymentSubV4State.legacyIsAwaitingVerifyStatus(p.status));
          final hasSlip = targetIntents
              .any((p) => PaymentSubV4State.legacyIsAwaitingSlipStatus(p.status));

          if (hasVerify) {
            targetTab = 3;
          } else if (hasSlip) {
            targetTab = 2;
          } else {
            targetTab = 1;
          }
        } else if (payableInvoices.isEmpty) {
          final countSlip = intents
              .where((p) => PaymentSubV4State.legacyIsAwaitingSlipStatus(p.status))
              .length;
          final countVerify = intents
              .where(
                  (p) => PaymentSubV4State.legacyIsAwaitingVerifyStatus(p.status))
              .length;

          if (countSlip > 0) {
            targetTab = 2;
          } else if (countVerify > 0) {
            targetTab = 3;
          }
        }
      }

      // ผูก intent เป้าหมายไว้ล่วงหน้า เพื่อให้แนบสลิปถูกใบ
      // ต้อง clear เมื่อไม่มีเป้าหมาย ไม่งั้น copyWith จะคงค่าเก่าไว้ (?? this.x)
      final preTarget = targetIntents.length == 1 ? targetIntents.first : null;

      _updateState(_state.copyWith(
        pageStatus: PageStatus.ready,
        authValid: isAuthOk,
        rentalModel: rental,
        clearRental: clearRental,
        paymentModels: paymentMethods,
        selectedPaymentModel: selectedPay,
        clearSelectedPayment: selectedPay == null,
        tenantModels: tenants,
        contractxFineModels: contractFines,
        paymentIntents: intents,
        invoices: payableInvoices,
        invoicesInIntent: inIntentInvoices,
        summary: summary,
        selectedTab: targetTab,
        hasAutoSwitched: true,
        sectionErrors: sectionErrors.toList(),
        clearSectionErrors: sectionErrors.isEmpty,
        clearUploadTarget: preTarget == null,
        clearTargetIntent: preTarget == null,
        clearAttachedSlip: preTarget == null,
        clearSlipPreview: true,
        uploadTargetUuid: preTarget?.intentUuid,
        uploadTargetAmount: preTarget == null
            ? null
            : Money.fromDouble(preTarget.amount ?? preTarget.requestedAmount),
      ));

      // เปิดจาก intent card หรือกลับเข้าหน้าใหม่ → เติม ref/expiry จาก server
      //
      // ต้องเป็น [openIntentDetail] ไม่ใช่ [openIntent] เพราะ ref3 อยู่ใน
      // `active_qr_session` ของ details response เท่านั้น — list response
      // ไม่ได้ส่งมา ทำให้ช่อง Ref ขึ้น `-`
      // ต้นฉบับก็เรียก `_DetailsPaymentIntentsReload()` ใน QrGenRef ก่อนวาด QR เสมอ
      if (preTarget != null) {
        await openIntentDetail(preTarget);
      } else if (targetTab != 1 && intents.isNotEmpty) {
        // ไม่ได้ระบุ intent แต่ถูกพาไปแท็บ 2/3 → ผูกใบแรกที่ตรงแท็บนั้น
        // ใช้กติกาข้อความ status แบบเดียวกับที่แท็บใช้ (ไม่ใช่ classifier)
        final fallback = targetTab == 3
            ? intents
                .where((p) => PaymentSubV4State.legacyIsAwaitingVerifyStatus(p.status))
                .firstOrNull
            : intents
                .where((p) => PaymentSubV4State.legacyIsAwaitingSlipStatus(p.status))
                .firstOrNull;

        await openIntentDetail(fallback ?? intents.first);
      }
    } catch (e) {
      debugPrint('❌ initialize error: $e');
      _updateState(_state.copyWith(
        pageStatus: PageStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// คำนวณค่าปรับตามกติกาเดิมของต้นแบบ
  /// - fine != '1' → ไม่มีค่าปรับ
  /// - fine_c เป็น '0.00'/null → ใช้ยอดคงที่จาก fine_a
  /// - ไม่เช่นนั้น → คิดเป็นเปอร์เซ็นต์ของ (ยอดรวม - ส่วนลด)
  static Money calculateFine({
    required Money subTotal,
    required Money discount,
    required PayMentModel? payModel,
  }) {
    if (payModel == null || payModel.fine != '1') {
      return const Money(0);
    }

    final rateRaw = payModel.fine_c;
    if (rateRaw == null || rateRaw.isEmpty || rateRaw == '0.00') {
      return Money.parse(payModel.fine_a);
    }

    final rate = double.tryParse(rateRaw) ?? 0.0;
    if (rate <= 0) {
      return Money.parse(payModel.fine_a);
    }

    final base = subTotal.satang - discount.satang;
    if (base <= 0) return const Money(0);
    return Money(((base * rate) / 100).round());
  }

  /// คำนวณสรุปยอดเงินทั้งหมด (Canonical Numeric)
  static PaymentSummary calculateSummary(
    List<InvoiceModel> invoices,
    PayMentModel? payModel,
  ) {
    var subTotalSatang = 0;
    var discountSatang = 0;

    // ใช้ยอดที่แสดงผล (total_bill) ให้ตรงกับทุกหน้าจอของต้นฉบับ
    // ส่วนยอดที่ส่ง API ยังใช้ amtall แยกกันใน [PaymentIntentPayload.buildInvoiceEntry]
    for (final inv in invoices) {
      subTotalSatang += inv.displayAmount.satang;
      discountSatang += inv.displayDiscount.satang;
    }

    final subTotal = Money(subTotalSatang);
    final discount = Money(discountSatang);
    final fine = calculateFine(
      subTotal: subTotal,
      discount: discount,
      payModel: payModel,
    );

    final grandTotalSatang = subTotalSatang - discountSatang + fine.satang;

    return PaymentSummary(
      subTotal: subTotal,
      discountTotal: discount,
      fineTotal: fine,
      grandTotal: Money(grandTotalSatang > 0 ? grandTotalSatang : 0),
    );
  }

  /// wrapper ให้ ViewModel เรียกใช้และเทสต์ static ได้
  PaymentSummary _calculateSummary(
    List<InvoiceModel> invoices,
    PayMentModel? payModel,
  ) =>
      calculateSummary(invoices, payModel);

  /// สร้าง Payment Intent และเริ่ม QR Code
  Future<bool> createPaymentIntent() async {
    if (_state.summary.grandTotal.isZero || _state.summary.grandTotal.isNegative) {
      _updateState(_state.copyWith(
        uiEvent: _event('invalid_amount', 'ยอดเงินไม่ถูกต้อง', isError: true),
      ));
      return false;
    }

    final payModel = _state.selectedPaymentModel;
    if (payModel == null) {
      _updateState(_state.copyWith(
        uiEvent: _event(
          'no_payment_method',
          'กรุณาเลือกช่องทางการชำระเงิน',
          isError: true,
        ),
      ));
      return false;
    }

    _updateState(_state.copyWith(operation: PaymentOperation.creatingIntent));

    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = (prefs.getString('renTalSer') ?? '').trim();
      final custno = (prefs.getString('custno') ?? '').trim();
      final user = (prefs.getString('ser') ?? '').trim();
      final usercid = (prefs.getString('usercid') ?? '').trim();
      final payser = int.tryParse(payModel.ser ?? '') ?? 0;
      final typepayser = int.tryParse(payModel.ptser ?? '') ?? 0;

      // 1) โหลด invoice history + fine ราย invoice + ค่าปรับจาก payment method
      //    ต้องได้ครบก่อน ไม่งั้น metadata/trans/customer_data/list_fee จะว่าง
      final allTrans = <IntentsInvoiceHistoryModel>[];
      final invoicePayloads = <Map<String, dynamic>>[];
      final payModels = <InvoicePayModel>[];
      var sumInvoiceFine = 0.0;

      for (final inv in _state.invoices) {
        final docno = (inv.docno ?? '').trim();

        // เทียบทุก field ที่เป็นไปได้กับยอดที่ควรได้ เพื่อหา VAT 7% ที่หายไป
        debugPrint('🔎 invoice $docno: amt=${inv.amt} vat=${inv.vat} '
            'wht=${inv.wht} pvat=${inv.pvat} amtall=${inv.amtall} '
            'total_bill=${inv.total_bill} vatall=${inv.vatall} '
            'pvatall=${inv.pvatall} dis=${inv.dis} '
            'disendbill=${inv.disendbill}');

        final historyRes = await _service.loadInvoiceHistory(
          ren: ren,
          user: user,
          cidDoc: usercid,
          docno: docno,
        );
        final history = historyRes.isSuccess
            ? historyRes.valueOr
            : <IntentsInvoiceHistoryModel>[];
        allTrans.addAll(history);

        final fineMap = await _service.loadInvoiceFine(ren: ren, docno: docno);

        // ค่าปรับราย invoice มาจาก In_tran_select_fine_inv (string "ชื่อ,ยอด")
        final invoiceFine = await _service.loadInvoiceFineAmount(
          ren: ren,
          cidDoc: usercid,
          tser: inv.ser ?? '',
          tdocno: docno,
          user: user,
        );
        sumInvoiceFine += invoiceFine;

        // เก็บลง invoicePayModels เพื่อให้ fineForDocno ใช้ค่าจริง
        payModels.add(
          InvoicePayModel.fromJson({
            'ser': inv.ser,
            'docno': docno,
            'amtall': inv.amtall,
            'fine': invoiceFine.toString(),
            'discount': inv.disendbill?.toString() ?? '0',
            'fine_book': invoiceFine.toString(),
            'discount_book': inv.disendbill?.toString() ?? '0',
          }),
        );

        invoicePayloads.add(
          PaymentIntentPayload.buildInvoiceEntry(
            inv: inv,
            history: history,
            fine: fineMap,
            invoiceFine: invoiceFine,
            payser: payser,
          ),
        );
      }

      // เก็บค่าปรับที่คำนวณได้ เพื่อให้ create ครั้งถัดไปใช้ค่าเดียวกัน
      _updateState(_state.copyWith(invoicePayModels: payModels));

      final customerData =
          PaymentIntentPayload.buildCustomerData(trans: allTrans);

      // 2) คิดยอดตามสูตรต้นแบบ
      //
      //    สูตร: sum_pvat + sum_tran_fine - dis_sum_Pakan
      //          - (sum_disamt + sum_disamt_in) + (sum_amt_in + sum_tran_fine_in) + fine_total
      //
      //    ค่าที่เป็น 0 ในเส้นทางใช้งานจริงของต้นแบบ (ตรวจ call site แล้ว):
      //    - sum_pvat / sum_tran_fine: มาจาก red_Trans_select2 ซึ่งเรียกผ่าน
      //      in_Trans_select แต่ไม่มี call site ที่ актив (ถูก comment ทั้งหมด)
      //    - sum_disamt_in: ไม่เคยถูกกำหนดค่า
      //    - dis_sum_Pakan: ประกาศเป็น 0.00 และไม่เคยถูกกำหนดค่า
      //
      //    จึงเหลือเฉพาะก้อนที่มาจาก invoice history + ค่าปรับ
      var sumAmtIn = 0.0;
      for (final h in allTrans) {
        sumAmtIn += _d(h.total_t);
      }
      final sumTranFineIn = sumInvoiceFine;

      final requestedTotal = PaymentIntentPayload.requestedTotal(
        sumPvat: 0,
        sumTranFine: 0,
        sumAmtIn: sumAmtIn,
        sumTranFineIn: sumTranFineIn,
        sumDiscount: PaymentIntentPayload.legacyLastDiscount(allTrans),
        sumDisIn: PaymentIntentPayload.legacySumDisIn,
        fineTotal: _state.summary.fineTotal.toDouble(),
        disSumPakan: 0,
      );

      if (requestedTotal <= 0) {
        _updateState(_state.copyWith(
          operation: PaymentOperation.none,
          uiEvent: _event(
            'invalid_total',
            'ยอดชำระทั้งหมดต้องมากกว่า 0',
            isError: true,
          ),
        ));
        return false;
      }

      final res = await _service.createPaymentIntent(
        cusNo: custno,
        propertyNo: ren,
        payser: payser,
        typepayser: typepayser,
        requestedTotal: requestedTotal,
        lateFee: sumInvoiceFine,
        discountAmount: _state.summary.discountTotal.toDouble(),
        inVoices: invoicePayloads,
        transSelect: allTrans.map((e) => e.toJson()).toList(),
        payBno: payModel.bno ?? '',
        payBname: payModel.bname ?? '',
        payBnameEn: payModel.bnameEn ?? '',
        payBankNcode: payModel.bankNcode ?? '',
        payPaytypeNcode: payModel.paytypeNcode ?? '',
        customerData: customerData,
      );

      if (res != null) {
        debugPrint('🔎 create intent response keys: ${res.keys.toList()}');
        debugPrint('🔎 create intent refs: ref1="${res['ref1']}" '
            'ref2="${res['ref2']}" ref3="${res['ref3']}" '
            'payload="${(res['payload'] ?? '').toString().length} chars"');

        final uuid = (res['uuid'] ?? res['intent_uuid'] ?? '').toString();

        // ยอดที่ใช้สร้าง QR ต้องเป็นยอดที่ server ถือ (requested_amount)
        // ไม่ใช่ summary.grandTotal ที่ฝั่งแอปรวมเอง — สองค่าไม่เท่ากันเมื่อมี
        // ส่วนลด เพราะ server ใช้ discount ของ history แถวสุดท้าย (legacyLastDiscount)
        //
        // ถ้า response ไม่ส่งยอดกลับมา ใช้ requestedTotal ที่เพิ่งส่งไป (ยอดที่
        // server ได้รับแน่นอน) ก่อน แล้วจึงค่อย fallback เป็นยอดในเครื่อง
        final serverAmount = _d(res['requested_amount'] ?? res['amount']);
        debugPrint('🔎 amount check: sent=$requestedTotal '
            'server_requested_amount=${res['requested_amount']} '
            'server_amount=${res['amount']} server_total=${res['total']} '
            'summary=${_state.summary.grandTotal.toDouble()} '
            '→ using=${serverAmount > 0 ? serverAmount : requestedTotal}');

        final amtVal = PaymentQrPayload.resolveAmount(
          intentRequestedAmount: serverAmount > 0 ? serverAmount : requestedTotal,
          fallback: _state.summary.grandTotal.toDouble(),
        );

        _applyQrSession(
          intentUuid: uuid,
          payModel: payModel,
          amount: amtVal,
          ref1: (res['ref1'] ?? '').toString(),
          ref2: (res['ref2'] ?? '').toString(),
          ref3: (res['ref3'] ?? '').toString(),
          serverPayload: (res['payload'] ?? '').toString(),
          softExpireAt: (res['soft_expire_at'] ?? '').toString(),
          // intent ที่เพิ่งสร้างยังไม่มีในลิสต์ — ส่งข้อมูลที่รู้แล้วเพื่อให้
          // ref1/ref2 fallback ได้เหมือน `currentIntent` ของต้นฉบับ
          paymentIntentNo: (res['payment_intent_no'] ?? '').toString(),
          invoices: const <Invoice>[],
          customerNo: custno,
        );

        // ref3 มาจาก `active_qr_session` ซึ่ง **ยังไม่มีตอนเพิ่งสร้าง intent**
        // ต้อง POST /generate เพื่อสร้าง session ก่อน ไม่งั้นช่อง Ref ขึ้น `-`
        //
        // ต้นฉบับทำแบบเดียวกัน: หลัง create → reload intents → QrGenRef() เจอว่า
        // ไม่มี active_qr_session จึงเรียก _renewQrAndReload() → POST /generate
        // (payment_subV4_InvAll.dart:1264-1269, 1414-1441)
        if (uuid.isNotEmpty) {
          await _hydrateNewIntentSession(
            intentUuid: uuid,
            payModel: payModel,
            amount: amtVal,
            cusNo: custno,
            propertyNo: ren,
            createResponse: res,
          );
        }

        _updateState(_state.copyWith(
          operation: PaymentOperation.none,
          uiEvent: _event(
            'create_intent_success',
            payModel.isBankTransfer
                ? 'สร้างรายการชำระเงินสำเร็จ'
                : 'สร้าง QR Code สำเร็จ',
          ),
        ));
        return true;
      }
    } catch (e) {
      debugPrint('❌ createPaymentIntent error: $e');
    }

    _updateState(_state.copyWith(
      operation: PaymentOperation.none,
      uiEvent: _event(
        'create_intent_fail',
        'สร้าง QR Code ล้มเหลว กรุณาลองใหม่อีกครั้ง',
        isError: true,
      ),
    ));
    return false;
  }

  /// โหลดรายละเอียดบิลย่อย + ค่าปรับ ของ invoice ที่ผู้ใช้กาง
  /// cache เฉพาะเมื่อสำเร็จ — ถ้าล้มเหลวให้กางใหม่เพื่อลองอีกครั้ง
  Future<void> loadInvoiceDetail(String docno) async {
    if (docno.isEmpty) return;
    if (_state.invoiceHistoryByDocno.containsKey(docno)) return;
    if (_state.detailLoadingDocno == docno) return;

    _updateState(_state.copyWith(detailLoadingDocno: docno));

    final prefs = await SharedPreferences.getInstance();
    final ren = (prefs.getString('renTalSer') ?? '').trim();
    final user = (prefs.getString('ser') ?? '').trim();
    final usercid = (prefs.getString('usercid') ?? '').trim();

    final historyRes = await _service.loadInvoiceHistory(
      ren: ren,
      user: user,
      cidDoc: usercid,
      docno: docno,
    );
    final fineMap = await _service.loadInvoiceFine(ren: ren, docno: docno);

    if (_isDisposed) return;

    final fineByDoc = Map<String, Map<String, dynamic>>.from(
      _state.invoiceFineByDocno,
    );
    fineByDoc[docno] = fineMap;

    if (!historyRes.isSuccess) {
      // ไม่ cache — ปล่อยให้กางใหม่เพื่อ retry ได้
      _updateState(_state.copyWith(
        invoiceFineByDocno: fineByDoc,
        clearDetailLoading: true,
        clearSectionErrors: true,
        sectionErrors: [historyRes.error!],
      ));
      return;
    }

    final historyMap = Map<String, List<IntentsInvoiceHistoryModel>>.from(
      _state.invoiceHistoryByDocno,
    );
    historyMap[docno] = historyRes.valueOr;

    _updateState(_state.copyWith(
      invoiceHistoryByDocno: historyMap,
      invoiceFineByDocno: fineByDoc,
      clearDetailLoading: true,
      clearSectionErrors: true,
      sectionErrors: _state.sectionErrors
          .where((e) => !_isDetailError(e))
          .toList(),
    ));
  }

  /// error ที่เกิดจาก loadInvoiceDetail (แยกจาก error ของ section หลัก)
  bool _isDetailError(String message) =>
      message.contains('ประวัติรายการ');

  /// สลับแท็บ
  void selectTab(int tab) {
    if (_state.selectedTab == tab) return;
    _updateState(_state.copyWith(selectedTab: tab));
  }

  /// ปรับปรุงเวลา Countdown QR Code
  void startQrCountdown(String? expireIso) {
    _timerSub?.cancel();
    _sessionTotalSecs = 0;
    if (expireIso == null || expireIso.isEmpty) return;

    final expiry = DateTime.tryParse(expireIso);
    if (expiry == null) return;

    final initial = expiry.difference(DateTime.now()).inSeconds;
    _sessionTotalSecs = initial > 0 ? initial : 0;

    if (_sessionTotalSecs == 0) {
      _updateState(_state.copyWith(
        qrState: _state.qrState.copyWith(
          secondsRemaining: 0,
          isSessionExpired: true,
        ),
      ));
      return;
    }

    _updateState(_state.copyWith(
      qrState: _state.qrState.copyWith(
        secondsRemaining: _sessionTotalSecs,
        isSessionExpired: false,
      ),
    ));

    _timerSub = Stream.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final diff = expiry.difference(now).inSeconds;
      return diff < 0 ? 0 : diff;
    }).listen((secs) {
      if (_isDisposed) return;
      _updateState(_state.copyWith(
        qrState: _state.qrState.copyWith(
          secondsRemaining: secs,
          isSessionExpired: secs <= 0,
        ),
      ));
    });
  }

  /// สร้าง payload QR แล้วเขียนลง state พร้อมเริ่ม countdown
  ///
  /// ใช้ร่วมกันทั้งตอนสร้าง intent ใหม่ (แท็บ 1) และตอน hydrate intent เดิม
  /// (แท็บ 2/3) เพื่อให้การวาด QR มาจากทางเดียวเสมอ
  ///
  /// ลำดับค่าตามต้นฉบับ `QrGenRef()` (payment_subV4_InvAll.dart:1551-1609):
  /// - `qrBno` = bno ของช่องทาง → bno ของ intent → `'-'`
  /// - `ref1`  = session → `metadata.first.cid` → `customerNo` → `'-'`
  /// - `ref2`  = session → `paymentIntentNo` → `'-'`
  /// - `ref3`  = session เท่านั้น → `'-'`
  /// - `amount` = ยอดที่ server ถือ ([amount] ที่ผู้เรียกส่งมา)
  void _applyQrSession({
    required String intentUuid,
    required PayMentModel payModel,
    required double amount,
    String? ref1,
    String? ref2,
    String? ref3,
    String serverPayload = '',
    String? softExpireAt,
    String? billExpireAt,
    String? paymentIntentNo,
    List<Invoice> invoices = const [],
    String? customerNo,
    String? intentBno,
  }) {
    final ptser = (payModel.ptser ?? '').trim();
    final isBankTransfer = payModel.isBankTransfer;

    final qrBno = PaymentQrPayload.resolveBno(
      selectedBno: payModel.bno,
      intentBno: intentBno,
    );

    final resolvedRef1 = PaymentQrPayload.resolveRef1(
      fromSession: ref1 ?? '',
      invoices: invoices,
      customerNo: customerNo,
    );
    // ต้นฉบับอ่าน ref2 จาก paymentIntentNo ของ intent ไม่ใช่ค่าที่ผู้เรียกส่งมา
    final resolvedRef2 = PaymentQrPayload.resolveRef2(
      fromSession: ref2 ?? '',
      paymentIntentNo: paymentIntentNo ?? _state.qrState.paymentIntentNo,
    );
    final resolvedRef3 = PaymentQrPayload.resolveRef3(fromSession: ref3 ?? '');

    // ต้นฉบับใช้ payload จาก server **เฉพาะ ptser 7** เท่านั้น
    // ส่วน 5/6/11 สร้างเองเสมอ แม้ server จะส่ง payload มาก็ตาม
    final payload = PaymentQrPayload.build(
      ptser: ptser,
      bno: qrBno,
      amount: amount,
      ref1: resolvedRef1,
      ref2: resolvedRef2,
      serverPayload: serverPayload.trim(),
    );

    // ptser 2: payload คือชื่อไฟล์รูป ไม่ใช่ QR ที่สแกนได้ จึงไม่นับเป็น QR active
    final qrStatus = isBankTransfer
        ? QrStatus.unavailable
        : payload.isEmpty
            ? QrStatus.unavailable
            : QrStatus.active;

    startQrCountdown(softExpireAt);

    _updateState(_state.copyWith(
      qrState: PaymentQrState(
        status: qrStatus,
        intentUuid: intentUuid,
        paymentIntentNo: paymentIntentNo ?? _state.qrState.paymentIntentNo,
        ref1: resolvedRef1,
        ref2: resolvedRef2,
        ref3: resolvedRef3,
        qrPayload: isBankTransfer ? null : payload,
        amount: amount,
        softExpireAt: softExpireAt,
        billExpireAt: billExpireAt,
        secondsRemaining: _sessionTotalSecs,
        isSessionExpired: _sessionTotalSecs <= 0,
      ),
    ));
  }

  /// เลือก Intent ที่ต้องการดำเนินการ (ใช้กับแท็บ 2/3 ที่กดจาก intent card)
  ///
  /// ต้อง hydrate ref/expiry จาก intent ที่โหลดมาจาก server ให้ครบ
  /// เพราะผู้ใช้ออกจากแอปแล้วกลับเข้ามาใหม่ ซึ่ง state ในหน่วยความจำหายหมด
  /// ต้นฉบับแก้ด้วยวิธีเดียวกัน คือเรียก QrGenRef ด้วย ref1/ref2/ref3/softExpireAt
  /// ของ intent ที่ได้จาก server
  ///
  /// และต้อง**สร้าง payload QR ใหม่**ด้วย เพราะ list endpoint ส่ง `ref1/ref2/ref3`
  /// มาแล้วแต่ไม่ได้ส่ง `payload` — ถ้าปล่อยว่างจะเห็นแค่ placeholder
  /// (ต้นฉบับก็เซ็ต `qrDataNoIntens` ใหม่ทุกครั้งใน QrGenRef)
  void openIntent(PaymentIntent intent) {
    final uuid = intent.intentUuid;
    if (uuid == null || uuid.isEmpty) return;

    final amount = Money.fromDouble(
      PaymentQrPayload.resolveAmount(
        intentRequestedAmount: intent.requestedAmount ?? intent.amount,
        fallback: _state.summary.grandTotal.toDouble(),
      ),
    );

    // ต้นฉบับเลือกธนาคารจาก `intent.bankmerchantid` ไม่ใช่ช่องทางที่ผู้ใช้เลือก
    // เพราะ intent ที่เปิดจากแท็บ 2/3 อาจเป็นของธนาคารอื่น
    final payModel = _payModelFor(intent.bankmerchantid) ??
        _state.selectedPaymentModel;
    final expireIso = intent.softExpireAt?.toIso8601String();

    // ต้นฉบับเซ็ต _intentsSlipData จาก `attaches` ของ details response
    // ถ้า list ส่ง latest_slip มาแล้ว ใช้ค่านั้นได้เลย ไม่ต้องยิง detail ซ้ำ
    final listSlip = PaymentSlipInfo.fromJson(intent.latestSlip);

    _updateState(_state.copyWith(
      uploadTargetUuid: uuid,
      uploadTargetAmount: amount,
      targetIntent: intent,
      attachedSlip: listSlip,
      clearAttachedSlip: listSlip == null,
      clearSlipPreview: true,
      summary: PaymentSummary(
        subTotal: _state.summary.subTotal,
        fineTotal: _state.summary.fineTotal,
        discountTotal: _state.summary.discountTotal,
        vatTotal: _state.summary.vatTotal,
        whtTotal: _state.summary.whtTotal,
        grandTotal: amount.isPositive ? amount : _state.summary.grandTotal,
      ),
    ));

    if (payModel != null) {
      _applyQrSession(
        intentUuid: uuid,
        payModel: payModel,
        amount: amount.toDouble(),
        ref1: intent.ref1,
        ref2: intent.ref2,
        ref3: intent.ref3,
        paymentIntentNo: intent.paymentIntentNo,
        // ref1/ref2 ของต้นฉบับ fallback มาที่ข้อมูลใน intent ไม่ใช่ปล่อยว่าง
        invoices: intent.invoices,
        customerNo: intent.customerNo,
        softExpireAt: expireIso,
        billExpireAt: expireIso,
      );
    } else {
      // ไม่รู้จักช่องทางของ intent นี้ — ยังต้องมี UUID/expiry ให้ upload ทำงานได้
      startQrCountdown(expireIso);
      _updateState(_state.copyWith(
        qrState: PaymentQrState(
          intentUuid: uuid,
          paymentIntentNo: intent.paymentIntentNo,
          ref1: intent.ref1,
          ref2: intent.ref2,
          ref3: intent.ref3,
          amount: amount.toDouble(),
          softExpireAt: expireIso,
          billExpireAt: expireIso,
        ),
      ));
    }
  }

  /// อ่าน `active_qr_session` ของ intent และ **สร้างให้ถ้ายังไม่มี**
  ///
  /// ตรงกับ `QrGenRef()` ของต้นฉบับ: ถ้าไม่มี `active_qr_session` ให้เรียก
  /// `_renewQrAndReload()` → POST `/generate` แล้วอ่านค่ากลับอีกครั้ง
  /// (payment_subV4_InvAll.dart:1394-1441)
  ///
  /// ref1/ref2/ref3 มีเฉพาะใน session — ถ้าไม่สร้าง ช่อง Ref จะว่าง
  Future<QrSessionResult> _loadOrCreateSession({
    required String intentUuid,
    required PayMentModel payModel,
    required String cusNo,
    required String propertyNo,
    Map<String, dynamic>? knownDetail,
  }) async {
    Map<String, dynamic> sessionOf(Map<String, dynamic>? source) {
      final raw = source?['active_qr_session'];
      return raw is Map ? Map<String, dynamic>.from(raw) : const {};
    }

    var source = knownDetail ?? const <String, dynamic>{};
    var session = sessionOf(source);

    // ยังไม่มี session → POST /generate (เหมือน _renewQrAndReload ของต้นฉบับ)
    if (session.isEmpty) {
      debugPrint('🔎 no active_qr_session → POST /generate uuid=$intentUuid');
      final generated = await _service.generateOrRenewQr(
        cusNo: cusNo,
        propertyNo: propertyNo,
        intentsUuid: intentUuid,
        bankMerchantId: int.tryParse(payModel.ser ?? '') ?? 0,
      );
      if (_isDisposed) {
        return (
          session: const <String, dynamic>{},
          source: const <String, dynamic>{},
        );
      }

      source = generated ?? const <String, dynamic>{};
      session = sessionOf(source);
      debugPrint('🔎 /generate keys=${source.keys.toList()} '
          'sessionKeys=${session.keys.toList()} '
          'ref3=${session['ref3']}');
    }

    // generate อาจไม่ส่ง session กลับมา → ถาม detail อีกครั้ง
    if (session.isEmpty) {
      final detail = await _service.loadIntentDetail(
        cusNo: cusNo,
        propertyNo: propertyNo,
        intentsUuid: intentUuid,
      );
      if (_isDisposed) return (session: const <String, dynamic>{}, source: const <String, dynamic>{});

      if (detail != null) {
        source = detail;
        session = sessionOf(detail);
      }
    }

    return (session: session, source: source);
  }

  /// เติม ref/payload/expiry ให้ intent ที่เพิ่งสร้าง
  ///
  /// ล้มเหลวเงียบ ๆ ไม่ล้มทั้ง flow — intent สร้างสำเร็จแล้ว ผู้ใช้ยังแนบสลิปได้
  /// เพียงแต่ช่อง Ref อาจว่าง
  Future<void> _hydrateNewIntentSession({
    required String intentUuid,
    required PayMentModel payModel,
    required double amount,
    required String cusNo,
    required String propertyNo,
    required Map<String, dynamic> createResponse,
  }) async {
    final result = await _loadOrCreateSession(
      intentUuid: intentUuid,
      payModel: payModel,
      cusNo: cusNo,
      propertyNo: propertyNo,
    );
    if (_isDisposed) return;

    debugPrint('🔎 ref hydrate: uuid=$intentUuid '
        'sessionKeys=${result.session.keys.toList()} '
        'createRef3=${createResponse['ref3']} '
        'sessionRef3=${result.session['ref3']}');

    // ผู้ใช้อาจกดยกเลิก/เริ่มใหม่ไประหว่างรอ network
    if ((_state.qrState.intentUuid ?? '') != intentUuid) return;

    String? readStr(dynamic v) {
      final s = (v ?? '').toString().trim();
      return s.isEmpty ? null : s;
    }

    _applyQrSession(
      intentUuid: intentUuid,
      payModel: payModel,
      amount: amount,
      ref1: readStr(result.session['ref1']) ?? readStr(createResponse['ref1']),
      ref2: readStr(result.session['ref2']) ?? readStr(createResponse['ref2']),
      ref3: readStr(result.session['ref3']) ?? readStr(createResponse['ref3']),
      serverPayload: readStr(result.session['payload']) ??
          readStr(createResponse['payload']) ??
          '',
      paymentIntentNo: readStr(createResponse['payment_intent_no']),
      invoices: const <Invoice>[],
      customerNo: cusNo,
      softExpireAt: readStr(result.session['soft_expire_at']) ??
          readStr(result.source['soft_expire_at']) ??
          readStr(createResponse['soft_expire_at']),
      billExpireAt: readStr(result.source['soft_expire_at']) ??
          readStr(result.session['soft_expire_at']),
    );
  }

  /// invoice ของ intent ที่กำลังดำเนินการ — ใช้เป็น fallback ของ ref1
  ///
  /// คืน list ว่างเมื่อไม่มี target intent เพื่อให้ [PaymentQrPayload.resolveRef1]
  /// ตกไปใช้ `customerNo` ต่อ
  List<Invoice> _targetIntentInvoices() =>
      _state.targetIntent?.invoices ?? const <Invoice>[];

  /// หา payment method ที่ตรงกับ bank merchant ของ intent
  PayMentModel? _payModelFor(int? bankMerchantId) {
    if (bankMerchantId == null) return null;
    for (final m in _state.paymentModels) {
      if (m.ser.toString() == '$bankMerchantId') return m;
    }
    return null;
  }

  /// เปิด intent พร้อมโหลดข้อมูลหลักฐานและ QR session จาก server (แท็บ 2/3)
  ///
  /// ต่างจาก [openIntent] ตรงที่คุยกับ server เพิ่ม เพื่อให้ได้ `attaches`
  /// และ `active_qr_session` เหมือนที่ต้นฉบับเรียก `QrGenRef()` — ซึ่งโหลด detail
  /// และ **สร้าง session ให้ถ้ายังไม่มี** (`_renewQrAndReload()`)
  ///
  /// ถ้าไม่มี session อยู่เลย ช่อง Ref จะว่าง เพราะ ref1/ref2/ref3 อยู่ในนั้น
  Future<void> openIntentDetail(PaymentIntent intent) async {
    openIntent(intent);

    final uuid = (intent.intentUuid ?? '').trim();
    if (uuid.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final ren = (prefs.getString('renTalSer') ?? '').trim();
    final custno = (prefs.getString('custno') ?? '').trim();

    final detail = await _service.loadIntentDetail(
      cusNo: custno,
      propertyNo: ren,
      intentsUuid: uuid,
    );
    if (_isDisposed) return;
    // ผู้ใช้อาจกดการ์ดใบอื่นไปแล้วระหว่างรอ network
    if ((_state.uploadTargetUuid ?? '') != uuid) return;

    // แสดงข้อมูลหลักฐานก่อน เพื่อไม่ให้ผู้ใช้รอ generate QR
    final slip = PaymentSlipInfo.fromJson(detail?['attaches']);
    _updateState(_state.copyWith(
      attachedSlip: slip,
      clearAttachedSlip: slip == null,
      clearSlipPreview: true,
    ));

    final payModel =
        _payModelFor(intent.bankmerchantid) ?? _state.selectedPaymentModel;
    if (payModel == null) return;

    // ไม่มี active_qr_session → สร้างให้ (ต้นฉบับ: _renewQrAndReload)
    final result = await _loadOrCreateSession(
      intentUuid: uuid,
      payModel: payModel,
      cusNo: custno,
      propertyNo: ren,
      knownDetail: detail,
    );
    if (_isDisposed) return;
    if ((_state.uploadTargetUuid ?? '') != uuid) return;

    final sessionMap = result.session;
    final sessionExpire = (sessionMap['soft_expire_at'] as String?) ??
        (result.source['soft_expire_at'] as String?);
    final amount = PaymentQrPayload.resolveAmount(
      intentRequestedAmount: intent.requestedAmount ?? intent.amount,
      fallback: _state.summary.grandTotal.toDouble(),
    );

    _applyQrSession(
      intentUuid: uuid,
      payModel: payModel,
      amount: amount,
      ref1: (sessionMap['ref1'] as String?) ?? intent.ref1,
      ref2: (sessionMap['ref2'] as String?) ?? intent.ref2,
      ref3: (sessionMap['ref3'] as String?) ?? intent.ref3,
      serverPayload: (sessionMap['payload'] as String?) ?? '',
      paymentIntentNo: intent.paymentIntentNo,
      invoices: intent.invoices,
      customerNo: intent.customerNo,
      softExpireAt: sessionExpire,
      billExpireAt: (result.source['soft_expire_at'] as String?) ??
          sessionExpire,
    );

    _updateState(_state.copyWith(
      qrState: _state.qrState.copyWith(
        isBillDead: sessionMap.isNotEmpty &&
            _isBillDead(_state.qrState.billExpireAt, _state.qrState.softExpireAt),
      ),
    ));
  }

  /// บิลหมดอายุจริงหรือไม่
  ///
  /// ต้นฉบับถือว่า "bill หมด" เมื่อ bill deadline อยู่หลัง session expiry
  /// และเลย deadline นั้นมาแล้ว (payment_subV4_InvAll.dart:1479-1485)
  /// ถ้า server ส่งค่าเดียวกันทั้งสองฟิลด์ แปลว่ายัง renew ได้เสมอ
  static bool _isBillDead(String? billExpireIso, String? sessionExpireIso) {
    final bill = DateTime.tryParse((billExpireIso ?? '').trim());
    if (bill == null) return false;

    final session = DateTime.tryParse((sessionExpireIso ?? '').trim());
    if (session != null && !bill.isAfter(session)) return false;

    return DateTime.now().isAfter(bill);
  }

  /// ขอ QR ใหม่ให้ **intent เดิม** (ไม่สร้าง intent ใหม่)
  ///
  /// ต้นฉบับเรียก `_renewQrAndReload()` ซึ่ง POST `/generate` ด้วย UUID เดิม
  /// ถ้า session ยังไม่หมดจะโหลด session เดิมกลับมาแทนการยิง generate (กัน 409)
  Future<bool> renewQr() async {
    final uuid = (_state.uploadTargetUuid ?? _state.qrState.intentUuid ?? '')
        .trim();
    final payModel = _state.selectedPaymentModel;
    if (uuid.isEmpty || payModel == null) return false;

    _updateState(_state.copyWith(operation: PaymentOperation.renewingQr));

    final prefs = await SharedPreferences.getInstance();
    final ren = (prefs.getString('renTalSer') ?? '').trim();
    final custno = (prefs.getString('custno') ?? '').trim();

    // session ยังไม่หมด → โหลดของเดิม ไม่ต้องยิง /generate
    if (!_state.qrState.isSessionExpired) {
      final detail = await _service.loadIntentDetail(
        cusNo: custno,
        propertyNo: ren,
        intentsUuid: uuid,
      );
      if (_isDisposed) return false;

      final session = detail?['active_qr_session'];
      if (session is Map) {
        final map = Map<String, dynamic>.from(session);
        final expire = map['soft_expire_at'] as String?;
        _applyQrSession(
          intentUuid: uuid,
          payModel: payModel,
          amount: _state.qrState.amount ??
              _state.summary.grandTotal.toDouble(),
          ref1: map['ref1'] as String?,
          ref2: map['ref2'] as String?,
          ref3: map['ref3'] as String?,
          serverPayload: (map['payload'] as String?) ?? '',
          paymentIntentNo: _state.qrState.paymentIntentNo,
          invoices: _targetIntentInvoices(),
          customerNo: _state.targetIntent?.customerNo,
          softExpireAt: expire,
          billExpireAt: (detail?['soft_expire_at'] as String?) ?? expire,
        );
        _updateState(_state.copyWith(operation: PaymentOperation.none));
        return true;
      }
    }

    // bill หมดอายุแล้ว → ต่อ QR ไม่ได้ ต้องแจ้งผู้ใช้
    if (_state.qrState.isBillDead) {
      _updateState(_state.copyWith(
        operation: PaymentOperation.none,
        uiEvent: _event(
          'renew_bill_dead',
          'รายการนี้หมดอายุแล้ว กรุณายกเลิกและเริ่มการชำระใหม่',
          isError: true,
        ),
      ));
      return false;
    }

    final result = await _loadOrCreateSession(
      intentUuid: uuid,
      payModel: payModel,
      cusNo: custno,
      propertyNo: ren,
    );
    if (_isDisposed) return false;

    final map = result.session;
    if (map.isEmpty) {
      _updateState(_state.copyWith(
        operation: PaymentOperation.none,
        uiEvent: _event(
          'renew_qr_fail',
          'ต่ออายุ QR ไม่สำเร็จ กรุณาลองใหม่',
          isError: true,
        ),
      ));
      return false;
    }

    final expire = (map['soft_expire_at'] as String?) ??
        (result.source['soft_expire_at'] as String?);

    _applyQrSession(
      intentUuid: uuid,
      payModel: payModel,
      amount: _state.qrState.amount ?? _state.summary.grandTotal.toDouble(),
      ref1: map['ref1'] as String?,
      ref2: map['ref2'] as String?,
      ref3: map['ref3'] as String?,
      serverPayload: (map['payload'] as String?) ?? '',
      paymentIntentNo: _state.qrState.paymentIntentNo,
      invoices: _targetIntentInvoices(),
      customerNo: _state.targetIntent?.customerNo,
      softExpireAt: expire,
      billExpireAt: (result.source['soft_expire_at'] as String?) ?? expire,
    );

    _updateState(_state.copyWith(
      operation: PaymentOperation.none,
      uiEvent: _event('renew_qr_success', 'สร้าง QR ใหม่สำเร็จ'),
    ));
    return true;
  }

  /// เปิด flow แนบหลักฐานของ intent ที่กดจากการ์ดแท็บ 2
  ///
  /// ตั้ง upload target ให้ตรงใบก่อนเสมอ ไม่งั้นสลิปจะไปเกาะใบที่สร้างในแท็บ 1
  Future<void> beginAttachSlip(PaymentIntent intent) async {
    await openIntentDetail(intent);
  }

  /// เปิดดูหลักฐานของ intent ที่กดจากการ์ด (แท็บ 3)
  ///
  /// โหลดเฉพาะข้อมูลหลักฐาน (`attaches`) ไม่โหลดรูป
  /// รูปจะโหลดเมื่อผู้ใช้กด "ดูหลักฐาน" เท่านั้น — เลี่ยง request ซ้ำซ้อน
  Future<void> openAttachedSlip(PaymentIntent intent) async {
    await openIntentDetail(intent);
  }

  /// ล้างข้อมูล intent ที่กำลังดูอยู่ (ปิด dialog แล้ว)
  void clearIntentTarget() {
    _updateState(_state.copyWith(
      clearTargetIntent: true,
      clearAttachedSlip: true,
      clearSlipPreview: true,
    ));
  }

  /// โหลดรูปหลักฐานจาก preview endpoint
  Future<bool> loadSlipPreview() async {
    final slipNo = (_state.attachedSlip?.slipNo ?? '').trim();
    if (slipNo.isEmpty) {
      _updateState(_state.copyWith(
        isSlipPreviewLoading: false,
        slipPreviewError: 'ไม่พบรหัสหลักฐานการชำระ',
      ));
      return false;
    }

    _updateState(_state.copyWith(
      isSlipPreviewLoading: true,
      clearSlipPreview: true,
    ));

    final result = await _service.loadSlipPreview(slipUuid: slipNo);
    if (_isDisposed) return false;

    if (result.isSuccess) {
      _updateState(_state.copyWith(
        slipPreviewBytes: result.valueOr,
        isSlipPreviewLoading: false,
      ));
      return true;
    }

    _updateState(_state.copyWith(
      isSlipPreviewLoading: false,
      slipPreviewError: result.error ?? 'โหลดรูปหลักฐานไม่สำเร็จ',
    ));
    return false;
  }

  /// ล้างข้อมูลชั่วคราวของสลิปในเครื่อง (preview/error) — ไม่แตะข้อมูลที่โหลดมาจาก server
  void clearSlipPreviewState() {
    _updateState(_state.copyWith(
      clearSlipPreview: true,
      isSlipPreviewLoading: false,
    ));
  }

  /// ตั้งค่ารูปสลิปจาก View
  void setSlip({
    required Uint8List bytes,
    required String fileName,
    String mimeType = 'image/jpeg',
  }) {
    _updateState(_state.copyWith(
      slipState: _state.slipState.copyWith(
        slipBytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
      ),
    ));
  }

  /// ล้างข้อมูลสลิป
  void clearSlip() {
    _updateState(_state.copyWith(
      slipState: const PaymentSlipState(),
    ));
  }

  /// อัปโหลดสลิป
  Future<bool> uploadSlip() async {
    final slip = _state.slipState;

    // ใช้ intent จากแท็บ 2 ถ้ามี ไม่งั้นใช้ intent ที่สร้างในแท็บ 1
    final uuid = _state.uploadTargetUuid ?? _state.qrState.intentUuid;
    final amount = _state.uploadTargetAmount ?? _state.summary.grandTotal;

    if (slip.slipBytes == null ||
        slip.fileName == null ||
        uuid == null ||
        uuid.isEmpty) {
      _updateState(_state.copyWith(
        uiEvent: _event(
          'upload_no_target',
          'ไม่พบรายการชำระเงินสำหรับแนบสลิป',
          isError: true,
        ),
      ));
      return false;
    }

    _updateState(_state.copyWith(
      operation: PaymentOperation.uploadingSlip,
      slipState: slip.copyWith(isUploading: true),
    ));

    final result = await _service.uploadSlip(
      intentUuid: uuid,
      slipBytes: slip.slipBytes!,
      fileName: slip.fileName!,
      amount: amount.toFixed2(),
      ref3: _state.qrState.ref3,
    );

    if (result.success) {
      _updateState(_state.copyWith(
        operation: PaymentOperation.none,
        clearUploadTarget: true,
        clearSlipPreview: true,
        slipState: slip.copyWith(
          isUploading: false,
          uploadSuccess: true,
          slipNo: result.slipNo,
        ),
        uiEvent: _event('slip_upload_success', 'อัปโหลดสลิปสำเร็จ'),
      ));
      // Reload intents เพื่อปรับปรุงสถานะแท็บ (แท็บ 2 → แท็บ 3)
      await initialize();
      return true;
    } else {
      _updateState(_state.copyWith(
        operation: PaymentOperation.none,
        slipState: slip.copyWith(isUploading: false),
        uiEvent: _event(
          'slip_upload_fail',
          result.error ?? 'อัปโหลดสลิปล้มเหลว กรุณาลองใหม่',
          isError: true,
        ),
      ));
      return false;
    }
  }

  /// ยกเลิกการชำระเงิน Intent
  Future<bool> cancelPayment() async {
    final uuid = _state.uploadTargetUuid ?? _state.qrState.intentUuid;
    if (uuid == null || uuid.isEmpty) {
      _updateState(_state.copyWith(
        uiEvent: _event(
          'cancel_no_target',
          'ไม่พบรายการชำระเงินที่ต้องการยกเลิก',
          isError: true,
        ),
      ));
      return false;
    }

    _updateState(_state.copyWith(operation: PaymentOperation.cancelling));

    final prefs = await SharedPreferences.getInstance();
    final ren = (prefs.getString('renTalSer') ?? '').trim();
    final custno = (prefs.getString('custno') ?? '').trim();

    // ใช้ bank id จาก intent ที่กำลังยกเลิก ถ้าหาไม่ได้จึง fallback เป็นบัญชีที่เลือก
    var bankId = int.tryParse(_state.selectedPaymentModel?.ser ?? '') ?? 0;
    try {
      final target = _state.paymentIntents.firstWhere(
        (p) => (p.intentUuid ?? '') == uuid,
      );
      bankId = target.bankmerchantid ?? bankId;
    } catch (_) {}

    final success = await _service.cancelPaymentIntent(
      cusNo: custno,
      propertyNo: ren,
      intentsUuid: uuid,
      bankMerchantId: bankId,
    );

    if (success) {
      _updateState(_state.copyWith(
        operation: PaymentOperation.none,
        clearUploadTarget: true,
        clearTargetIntent: true,
        clearAttachedSlip: true,
        clearSlipPreview: true,
        qrState: const PaymentQrState(),
        slipState: const PaymentSlipState(),
        uiEvent: _event(
          'cancel_intent_success',
          'ยกเลิกรายการชำระเงินสำเร็จ',
        ),
      ));
      await initialize();
      return true;
    }

    _updateState(_state.copyWith(
      operation: PaymentOperation.none,
      uiEvent: _event(
        'cancel_intent_fail',
        'ยกเลิกรายการไม่สำเร็จ กรุณาลองใหม่',
        isError: true,
      ),
    ));
    return false;
  }

  /// เคลียร์ UI Event เมื่อแสดงผลแล้ว
  /// เทียบทั้ง id และ seq เพื่อไม่ให้ event ชนิดเดียวกันครั้งถัดไปถูกกลืน
  void consumeEvent(String id, {int? seq}) {
    final current = _state.uiEvent;
    if (current == null) return;
    if (current.id != id) return;
    if (seq != null && current.seq != seq) return;
    _updateState(_state.copyWith(clearUiEvent: true));
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timerSub?.cancel();
    super.dispose();
  }
}
