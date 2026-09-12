import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:chaoperty_user/CRC_16_Prompay/generate_qrcode.dart';
import 'package:chaoperty_user/CRC_16_Prompay/generate_Ewallet_qrcode.dart';
import 'package:chaoperty_user/Model/GetInvoice_Model.dart';
import 'package:chaoperty_user/Model/GetInvoice_pay_Model.dart';
import 'package:chaoperty_user/Model/GetPayMent_Model.dart';
import 'package:chaoperty_user/Model/GetTeNant_Model.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/screen_Intents/Model/IntentsContractx_Fine_Model.dart';
import 'package:chaoperty_user/screen_Intents/Model/IntentsInv_history_Model.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_intent_payload.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/services/payment_subv4_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// cids ที่ใช้ยิง API — จาก tenantModels ถ้ามี ไม่งั้นใช้ usercid
  List<String> _cidsFromState(String fallbackUsercid) {
    final fromTenants = _state.tenantModels
        .map((t) => t.cid ?? '')
        .where((c) => c.isNotEmpty)
        .toList();
    return fromTenants.isNotEmpty ? fromTenants : [fallbackUsercid];
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
          final hasVerify = targetIntents.any((p) =>
              PaymentSubV4State.classifyIntentStatus(p) ==
              NormalizedIntentStatus.awaitingVerification);
          final hasSlip = targetIntents.any((p) =>
              PaymentSubV4State.classifyIntentStatus(p) ==
              NormalizedIntentStatus.awaitingSlip);

          if (hasVerify) {
            targetTab = 3;
          } else if (hasSlip) {
            targetTab = 2;
          } else {
            targetTab = 1;
          }
        } else if (payableInvoices.isEmpty) {
          final countSlip = intents
              .where((p) =>
                  PaymentSubV4State.classifyIntentStatus(p) ==
                  NormalizedIntentStatus.awaitingSlip)
              .length;
          final countVerify = intents
              .where((p) =>
                  PaymentSubV4State.classifyIntentStatus(p) ==
                  NormalizedIntentStatus.awaitingVerification)
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
        uploadTargetUuid: preTarget?.intentUuid,
        uploadTargetAmount: preTarget == null
            ? null
            : Money.fromDouble(preTarget.amount ?? preTarget.requestedAmount),
      ));
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

    for (final inv in invoices) {
      subTotalSatang += Money.parse(inv.amtall).satang;
      discountSatang += Money.parse(inv.disendbill).satang;
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

      // 2) คิดยอดตามสูตรต้นแบบ ซึ่งอิง transaction-level ไม่ใช่ invoice-level
      //    ยอดจาก GC_tran_select (sum_pvat/sum_amt) + GC_tran_select_fin (sum_tran_fine)
      //    บวกยอดที่คิดจาก invoice history (sum_amt_in/sum_tran_fine_in)
      var sumPvat = 0.0;
      var sumTranFine = 0.0;
      var sumAmtIn = 0.0;
      var sumTranFineIn = 0.0;

      final cids = _cidsFromState(usercid);

      try {
        final txs = await _service.loadTransactions(
          ren: ren,
          cids: cids,
          user: user,
        );
        for (final t in txs) {
          sumPvat += _d(t.pvat);
        }
      } catch (e) {
        debugPrint('⚠️ loadTransactions failed, using invoice totals: $e');
      }

      try {
        final fines = await _service.loadTransFines(
          ren: ren,
          cids: cids,
          user: user,
        );
        for (final f in fines) {
          sumTranFine += _d(f.total);
        }
      } catch (e) {
        debugPrint('⚠️ loadTransFines failed: $e');
      }

      // ยอดจาก invoice history ของบิลที่เลือก
      for (final h in allTrans) {
        sumAmtIn += _d(h.total_t);
      }
      sumTranFineIn = sumInvoiceFine;

      // sumDisIn / disSumPakan เป็น 0 ในต้นแบบตลอด (ดูหมายเหตุใน payment_intent_payload)
      // sumDiscount ใช้ค่าตามความหมายเดิมของต้นแบบ คือ disendbill ของ history แถวสุดท้าย
      final requestedTotal = PaymentIntentPayload.requestedTotal(
        sumPvat: sumPvat,
        sumTranFine: sumTranFine,
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
        final uuid = (res['uuid'] ?? res['intent_uuid'] ?? '').toString();
        final ref1 = (res['ref1'] ?? '').toString();
        final ref2 = (res['ref2'] ?? '').toString();
        final ref3 = (res['ref3'] ?? '').toString();
        final softExpireAt = (res['soft_expire_at'] ?? '').toString();

        // คำนวณ Payload QR Code
        final ptser = payModel.ptser ?? '';
        final bno = payModel.bno ?? '';
        final amtVal = _state.summary.grandTotal.toDouble();
        final amtRaw = amtVal.toStringAsFixed(2);

        String qrPayload = '';
        if (ptser == '7') {
          qrPayload = (res['payload'] ?? '').toString();
        } else if (ptser == '6') {
          qrPayload = '|$bno\r$ref1\r$ref2\r${amtRaw.replaceAll('.', '')}';
        } else if (ptser == '5') {
          qrPayload = generateQRCode(promptPayID: bno, amount: amtVal);
        } else if (ptser == '11') {
          qrPayload = generateEwalletQRCode(promptPayID: bno, amount: amtVal);
        } else if (ptser == '2') {
          qrPayload = payModel.img ?? '';
        }

        startQrCountdown(softExpireAt);

        _updateState(_state.copyWith(
          operation: PaymentOperation.none,
          qrState: PaymentQrState(
            status: QrStatus.active,
            intentUuid: uuid,
            ref1: ref1,
            ref2: ref2,
            ref3: ref3,
            qrPayload: qrPayload,
            softExpireAt: softExpireAt,
          ),
          uiEvent: _event('create_intent_success', 'สร้าง QR Code สำเร็จ'),
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

  /// เลือก Intent ที่ต้องการดำเนินการ (ใช้กับแท็บ 2 ที่กดแนบสลิปจาก intent card)
  void openIntent(PaymentIntent intent) {
    final uuid = intent.intentUuid;
    if (uuid == null || uuid.isEmpty) return;

    final amt = Money.fromDouble(intent.amount ?? intent.requestedAmount);

    _updateState(_state.copyWith(
      uploadTargetUuid: uuid,
      uploadTargetAmount: amt,
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

    final success = await _service.uploadSlip(
      intentUuid: uuid,
      slipBytes: slip.slipBytes!,
      fileName: slip.fileName!,
      amount: amount.toFixed2(),
      ref3: _state.qrState.ref3,
    );

    if (success) {
      _updateState(_state.copyWith(
        operation: PaymentOperation.none,
        clearUploadTarget: true,
        slipState: slip.copyWith(
          isUploading: false,
          uploadSuccess: true,
        ),
        uiEvent: _event('slip_upload_success', 'อัปโหลดสลิปสำเร็จ'),
      ));
      // Reload intents เพื่อปรับปรุงสถานะแท็บ
      await initialize();
      return true;
    } else {
      _updateState(_state.copyWith(
        operation: PaymentOperation.none,
        slipState: slip.copyWith(isUploading: false),
        uiEvent: _event(
          'slip_upload_fail',
          'อัปโหลดสลิปล้มเหลว กรุณาลองใหม่',
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
