import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:chaoperty_user/Model/GetInvoice_Model.dart';
import 'package:chaoperty_user/Model/GetPayMent_Model.dart';
import 'package:chaoperty_user/Model/GetRenTal_Model.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/services/payment_subv4_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentSubV4ViewModel extends ChangeNotifier {
  PaymentSubV4ViewModel({
    required this.params,
    PaymentSubV4Service? service,
  }) : _service = service ?? PaymentSubV4Service();

  final PaymentSubV4Params params;
  final PaymentSubV4Service _service;

  PaymentSubV4State _state = const PaymentSubV4State();
  PaymentSubV4State get state => _state;

  StreamSubscription<int>? _timerSub;
  bool _isDisposed = false;

  void _updateState(PaymentSubV4State newState) {
    if (_isDisposed) return;
    _state = newState;
    notifyListeners();
  }

  /// Initial Load
  Future<void> initialize() async {
    _updateState(_state.copyWith(
      pageStatus: PageStatus.loading,
      operation: PaymentOperation.none,
      errorMessage: null,
    ));

    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = (prefs.getString('renTalSer') ?? '').trim();
      final custno = (prefs.getString('custno') ?? '').trim();
      final usercid = (prefs.getString('usercid') ?? '').trim();
      final qutser = (prefs.getString('qutser') ?? '1').trim();

      // 1. Auth Gate
      final isAuthOk = await _service.checkAuth();

      // 2. โหลด Payment Methods & Rental
      final paymentMethodsFuture = _service.loadPaymentMethods(ren: ren);
      final rentalFuture = _service.loadRentalData(ren: ren);
      final results = await Future.wait([paymentMethodsFuture, rentalFuture]);

      final paymentMethods = results[0] as List<PayMentModel>;
      final rental = results[1] as RenTalModel?;

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
        tenants = await _service.loadTenantData(
          ren: ren,
          cidDoc: usercid,
          qutser: qutser,
        );
      }

      final List<String> cids = tenants.isNotEmpty
          ? tenants.map((t) => t.cid ?? '').where((c) => c.isNotEmpty).toList()
          : [usercid];

      // 4. โหลด Payment Intents
      final intents = isAuthOk
          ? await _service.loadPaymentIntents(
              cusno: custno,
              propertyno: ren,
              serPayment: params.paymentSerial,
            )
          : <PaymentIntent>[];

      // 5. โหลด Invoices & Contract Fines
      final invoices = await _service.loadInvoices(
        ren: ren,
        cids: cids,
        qutser: qutser,
      );

      final contractFines = await _service.loadContractFines(
        ren: ren,
        cids: cids,
      );

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

      // 8. Auto-Switch แท็บ
      int targetTab = _state.selectedTab;
      if (!_state.hasAutoSwitched) {
        if (params.fromIntent) {
          final awaitingVerify = intents.any((p) =>
              PaymentSubV4State.classifyIntentStatus(p) ==
              NormalizedIntentStatus.awaitingVerification);
          final awaitingSlip = intents.any((p) =>
              PaymentSubV4State.classifyIntentStatus(p) ==
              NormalizedIntentStatus.awaitingSlip);

          if (awaitingVerify) {
            targetTab = 3;
          } else if (awaitingSlip) {
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

      _updateState(_state.copyWith(
        pageStatus: PageStatus.ready,
        authValid: isAuthOk,
        rentalModel: rental,
        paymentModels: paymentMethods,
        selectedPaymentModel: selectedPay,
        tenantModels: tenants,
        contractxFineModels: contractFines,
        paymentIntents: intents,
        invoices: payableInvoices,
        invoicesInIntent: inIntentInvoices,
        summary: summary,
        selectedTab: targetTab,
        hasAutoSwitched: true,
      ));
    } catch (e) {
      debugPrint('❌ initialize error: $e');
      _updateState(_state.copyWith(
        pageStatus: PageStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// คำนวณสรุปยอดเงินทั้งหมด (Canonical Numeric)
  PaymentSummary _calculateSummary(
    List<InvoiceModel> invoices,
    PayMentModel? payModel,
  ) {
    var subTotalSatang = 0;
    var discountSatang = 0;

    for (final inv in invoices) {
      final amt = Money.parse(inv.amtall);
      final dis = Money.parse(inv.disendbill);
      subTotalSatang += amt.satang;
      discountSatang += dis.satang;
    }

    var fineSatang = 0;
    if (payModel != null && payModel.fine == '1') {
      if (payModel.fine_c == '0.00' || payModel.fine_c == null) {
        fineSatang = Money.parse(payModel.fine_a).satang;
      } else {
        final rate = double.tryParse(payModel.fine_c ?? '0') ?? 0.0;
        final base = subTotalSatang - discountSatang;
        fineSatang = ((base * rate) / 100).round();
      }
    }

    final grandTotalSatang = subTotalSatang - discountSatang + fineSatang;

    return PaymentSummary(
      subTotal: Money(subTotalSatang),
      discountTotal: Money(discountSatang),
      fineTotal: Money(fineSatang),
      grandTotal: Money(grandTotalSatang > 0 ? grandTotalSatang : 0),
    );
  }

  /// สลับแท็บ
  void selectTab(int tab) {
    if (_state.selectedTab == tab) return;
    _updateState(_state.copyWith(selectedTab: tab));
  }

  /// ปรับปรุงเวลา Countdown QR Code
  void startQrCountdown(String? expireIso) {
    _timerSub?.cancel();
    if (expireIso == null || expireIso.isEmpty) return;

    final expiry = DateTime.tryParse(expireIso);
    if (expiry == null) return;

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
    final uuid = _state.qrState.intentUuid;

    if (slip.slipBytes == null ||
        slip.fileName == null ||
        uuid == null ||
        uuid.isEmpty) {
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
      amount: _state.summary.grandTotal.toFixed2(),
      ref3: _state.qrState.ref3,
    );

    if (success) {
      _updateState(_state.copyWith(
        operation: PaymentOperation.none,
        slipState: slip.copyWith(
          isUploading: false,
          uploadSuccess: true,
        ),
        uiEvent: const PaymentUiEvent(
          id: 'slip_upload_success',
          message: 'อัปโหลดสลิปสำเร็จ',
        ),
      ));
      // Reload intents เพื่อปรับปรุงแท็บ
      await initialize();
      return true;
    } else {
      _updateState(_state.copyWith(
        operation: PaymentOperation.none,
        slipState: slip.copyWith(isUploading: false),
        uiEvent: const PaymentUiEvent(
          id: 'slip_upload_fail',
          message: 'อัปโหลดสลิปล้มเหลว กรุณาลองใหม่',
          isError: true,
        ),
      ));
      return false;
    }
  }

  /// ยกเลิกการชำระเงิน Intent
  Future<bool> cancelPayment() async {
    final uuid = _state.qrState.intentUuid;
    if (uuid == null || uuid.isEmpty) return false;

    _updateState(_state.copyWith(operation: PaymentOperation.cancelling));

    final prefs = await SharedPreferences.getInstance();
    final ren = (prefs.getString('renTalSer') ?? '').trim();
    final custno = (prefs.getString('custno') ?? '').trim();
    final bankId =
        int.tryParse(_state.selectedPaymentModel?.ser ?? '') ?? 0;

    final success = await _service.cancelPaymentIntent(
      cusNo: custno,
      propertyNo: ren,
      intentsUuid: uuid,
      bankMerchantId: bankId,
    );

    _updateState(_state.copyWith(
      operation: PaymentOperation.none,
      uiEvent: PaymentUiEvent(
        id: 'cancel_intent',
        message: success ? 'ยกเลิกรายการสำเร็จ' : 'ยกเลิกรายการไม่สำเร็จ',
        isError: !success,
      ),
    ));

    if (success) {
      await initialize();
    }
    return success;
  }

  /// เคลียร์ UI Event เมื่อแสดงผลแล้ว
  void consumeEvent(String id) {
    if (_state.uiEvent?.id == id) {
      _updateState(_state.copyWith(uiEvent: null));
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timerSub?.cancel();
    super.dispose();
  }
}
