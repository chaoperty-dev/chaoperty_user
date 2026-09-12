import 'package:flutter/foundation.dart';
import 'package:chaoperty_user/Model/GetTeNant_Model.dart';
import 'package:chaoperty_user/Model/GetPayMent_Model.dart';
import 'package:chaoperty_user/Model/GetRenTal_Model.dart';
import 'package:chaoperty_user/Model/GetInvoice_Model.dart';
import 'package:chaoperty_user/Model/GetInvoice_pay_Model.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/screen_Intents/Model/IntentsContractx_Fine_Model.dart';
import 'package:chaoperty_user/screen_Intents/Model/IntentsInv_history_Model.dart';

/// Parameter ส่งเข้า PaymentSubV4
class PaymentSubV4Params {
  const PaymentSubV4Params({
    this.tenants,
    this.customerLanguage,
    this.paymentSerial,
    this.paymentTypeSerial,
    this.selectedDocNos,
    this.fromIntent = false,
    this.targetIntentUuid,
    this.targetPaymentIntentNo,
  });

  final List<TeNantModel>? tenants;
  final String? customerLanguage;
  final String? paymentSerial;
  final String? paymentTypeSerial;
  final List<String>? selectedDocNos;
  final bool fromIntent;
  final String? targetIntentUuid;
  final String? targetPaymentIntentNo;
}

/// Canonical Money (สตางค์) เพื่อความแม่นยำทางตัวเลข
class Money {
  const Money(this.satang);

  final int satang;

  double toDouble() => satang / 100.0;
  String toFixed2() => toDouble().toStringAsFixed(2);

  factory Money.fromDouble(num? val) {
    if (val == null || val.isNaN) return const Money(0);
    return Money((val * 100).round());
  }

  factory Money.parse(dynamic val) {
    if (val == null) return const Money(0);
    if (val is num) return Money.fromDouble(val);
    final str = val.toString().replaceAll(',', '').trim();
    final parsed = double.tryParse(str) ?? 0.0;
    return Money.fromDouble(parsed);
  }

  Money operator +(Money other) => Money(satang + other.satang);
  Money operator -(Money other) => Money(satang - other.satang);
  Money operator *(num factor) => Money((satang * factor).round());

  bool get isZero => satang == 0;
  bool get isNegative => satang < 0;
  bool get isPositive => satang > 0;
}

/// สถานะหน้าจอหลัก
enum PageStatus { idle, loading, ready, error }

/// สถานะ Async Operation ย่อย
enum PaymentOperation {
  none,
  creatingIntent,
  loadingIntent,
  renewingQr,
  uploadingSlip,
  cancelling,
}

/// สถานะ QR Code
enum QrStatus { none, loading, active, expired, unavailable }

/// Normalized Intent Status
enum NormalizedIntentStatus {
  payable,
  awaitingSlip,
  awaitingVerification,
  completed,
  expired,
  cancelled,
  failed,
  unknown,
}

/// สรุปยอดเงินรวม
class PaymentSummary {
  const PaymentSummary({
    this.subTotal = const Money(0),
    this.fineTotal = const Money(0),
    this.discountTotal = const Money(0),
    this.vatTotal = const Money(0),
    this.whtTotal = const Money(0),
    this.grandTotal = const Money(0),
  });

  final Money subTotal;
  final Money fineTotal;
  final Money discountTotal;
  final Money vatTotal;
  final Money whtTotal;
  final Money grandTotal;
}

/// State ข้อมูล QR / Session
class PaymentQrState {
  const PaymentQrState({
    this.status = QrStatus.none,
    this.intentUuid,
    this.paymentIntentNo,
    this.ref1,
    this.ref2,
    this.ref3,
    this.qrPayload,
    this.softExpireAt,
    this.secondsRemaining = 0,
    this.isSessionExpired = false,
    this.isBillDead = false,
  });

  final QrStatus status;
  final String? intentUuid;
  final String? paymentIntentNo;
  final String? ref1;
  final String? ref2;
  final String? ref3;
  final String? qrPayload;
  final String? softExpireAt;
  final int secondsRemaining;
  final bool isSessionExpired;
  final bool isBillDead;

  PaymentQrState copyWith({
    QrStatus? status,
    String? intentUuid,
    String? paymentIntentNo,
    String? ref1,
    String? ref2,
    String? ref3,
    String? qrPayload,
    String? softExpireAt,
    int? secondsRemaining,
    bool? isSessionExpired,
    bool? isBillDead,
  }) {
    return PaymentQrState(
      status: status ?? this.status,
      intentUuid: intentUuid ?? this.intentUuid,
      paymentIntentNo: paymentIntentNo ?? this.paymentIntentNo,
      ref1: ref1 ?? this.ref1,
      ref2: ref2 ?? this.ref2,
      ref3: ref3 ?? this.ref3,
      qrPayload: qrPayload ?? this.qrPayload,
      softExpireAt: softExpireAt ?? this.softExpireAt,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isSessionExpired: isSessionExpired ?? this.isSessionExpired,
      isBillDead: isBillDead ?? this.isBillDead,
    );
  }
}

/// State ข้อมูลสลิป
class PaymentSlipState {
  const PaymentSlipState({
    this.slipBytes,
    this.fileName,
    this.mimeType = 'image/jpeg',
    this.isUploading = false,
    this.uploadSuccess = false,
    this.slipNo,
  });

  final Uint8List? slipBytes;
  final String? fileName;
  final String mimeType;
  final bool isUploading;
  final bool uploadSuccess;
  final String? slipNo;

  PaymentSlipState copyWith({
    Uint8List? slipBytes,
    String? fileName,
    String? mimeType,
    bool? isUploading,
    bool? uploadSuccess,
    String? slipNo,
  }) {
    return PaymentSlipState(
      slipBytes: slipBytes ?? this.slipBytes,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      isUploading: isUploading ?? this.isUploading,
      uploadSuccess: uploadSuccess ?? this.uploadSuccess,
      slipNo: slipNo ?? this.slipNo,
    );
  }
}

/// UI Event เพื่อแสดงผลครั้งเดียว (One-time event) ไม่แสดงซ้ำตอน rebuild
class PaymentUiEvent {
  const PaymentUiEvent({
    required this.id,
    required this.message,
    this.isError = false,
  });

  final String id;
  final String message;
  final bool isError;
}

/// State กลางของหน้าจอ PaymentSubV4
class PaymentSubV4State {
  const PaymentSubV4State({
    this.pageStatus = PageStatus.idle,
    this.operation = PaymentOperation.none,
    this.errorMessage,
    this.uiEvent,
    this.selectedTab = 1,
    this.hasAutoSwitched = false,
    this.invoices = const [],
    this.invoicesInIntent = const [],
    this.paymentIntents = const [],
    this.paymentModels = const [],
    this.selectedPaymentModel,
    this.rentalModel,
    this.tenantModels = const [],
    this.contractxFineModels = const [],
    this.invoicePayModels = const [],
    this.invoiceHistoryModels = const [],
    this.summary = const PaymentSummary(),
    this.qrState = const PaymentQrState(),
    this.slipState = const PaymentSlipState(),
    this.authValid = true,
    this.uploadTargetUuid,
    this.uploadTargetAmount,
    this.sectionErrors = const <String>[],
    this.invoiceHistoryByDocno = const {},
    this.invoiceFineByDocno = const {},
    this.detailLoadingDocno,
  });

  final PageStatus pageStatus;
  final PaymentOperation operation;
  final String? errorMessage;
  final PaymentUiEvent? uiEvent;
  final int selectedTab;
  final bool hasAutoSwitched;

  // Data Collections
  final List<InvoiceModel> invoices;
  final List<InvoiceModel> invoicesInIntent;
  final List<PaymentIntent> paymentIntents;
  final List<PayMentModel> paymentModels;
  final PayMentModel? selectedPaymentModel;
  final RenTalModel? rentalModel;
  final List<TeNantModel> tenantModels;
  final List<IntentsContractxFineModel> contractxFineModels;
  final List<InvoicePayModel> invoicePayModels;
  final List<IntentsInvoiceHistoryModel> invoiceHistoryModels;

  // Summaries & Sub-states
  final PaymentSummary summary;
  final PaymentQrState qrState;
  final PaymentSlipState slipState;
  final bool authValid;

  /// Intent เป้าหมายของ upload ที่กดมาจาก intent card (แท็บ 2)
  /// null = ใช้ intent ที่สร้างในแท็บ 1
  final String? uploadTargetUuid;
  final Money? uploadTargetAmount;

  /// error ของแต่ละ section ที่โหลดไม่สำเร็จ (ไม่ล้างข้อมูล section อื่นที่สำเร็จ)
  final List<String> sectionErrors;

  /// รายละเอียดบิลย่อยต่อ invoice/docno (โหลดเมื่อผู้ใช้กางรายการ)
  final Map<String, List<IntentsInvoiceHistoryModel>> invoiceHistoryByDocno;

  /// ค่าปรับราย invoice จาก GC_selectFine_inv
  final Map<String, Map<String, dynamic>> invoiceFineByDocno;

  /// docno ที่กำลังโหลดรายละเอียด (แสดง loading เฉพาะแถวนั้น)
  final String? detailLoadingDocno;

  // Tab Count Getters
  int get countAwaitingSlip => paymentIntents
      .where((p) => classifyIntentStatus(p) == NormalizedIntentStatus.awaitingSlip)
      .length;

  int get countAwaitingVerify => paymentIntents
      .where((p) =>
          classifyIntentStatus(p) == NormalizedIntentStatus.awaitingVerification)
      .length;

  PaymentSubV4State copyWith({
    PageStatus? pageStatus,
    PaymentOperation? operation,
    String? errorMessage,
    PaymentUiEvent? uiEvent,
    bool clearUiEvent = false,
    int? selectedTab,
    bool? hasAutoSwitched,
    List<InvoiceModel>? invoices,
    List<InvoiceModel>? invoicesInIntent,
    List<PaymentIntent>? paymentIntents,
    List<PayMentModel>? paymentModels,
    PayMentModel? selectedPaymentModel,
    RenTalModel? rentalModel,
    List<TeNantModel>? tenantModels,
    List<IntentsContractxFineModel>? contractxFineModels,
    List<InvoicePayModel>? invoicePayModels,
    List<IntentsInvoiceHistoryModel>? invoiceHistoryModels,
    PaymentSummary? summary,
    PaymentQrState? qrState,
    PaymentSlipState? slipState,
    bool? authValid,
    String? uploadTargetUuid,
    Money? uploadTargetAmount,
    bool clearUploadTarget = false,
    List<String>? sectionErrors,
    Map<String, List<IntentsInvoiceHistoryModel>>? invoiceHistoryByDocno,
    Map<String, Map<String, dynamic>>? invoiceFineByDocno,
    String? detailLoadingDocno,
    bool clearDetailLoading = false,
  }) {
    return PaymentSubV4State(
      pageStatus: pageStatus ?? this.pageStatus,
      operation: operation ?? this.operation,
      errorMessage: errorMessage ?? this.errorMessage,
      // คง event เดิมไว้จนกว่าจะสั่ง clear หรือส่ง event ใหม่
      uiEvent: clearUiEvent ? null : (uiEvent ?? this.uiEvent),
      selectedTab: selectedTab ?? this.selectedTab,
      hasAutoSwitched: hasAutoSwitched ?? this.hasAutoSwitched,
      invoices: invoices ?? this.invoices,
      invoicesInIntent: invoicesInIntent ?? this.invoicesInIntent,
      paymentIntents: paymentIntents ?? this.paymentIntents,
      paymentModels: paymentModels ?? this.paymentModels,
      selectedPaymentModel: selectedPaymentModel ?? this.selectedPaymentModel,
      rentalModel: rentalModel ?? this.rentalModel,
      tenantModels: tenantModels ?? this.tenantModels,
      contractxFineModels: contractxFineModels ?? this.contractxFineModels,
      invoicePayModels: invoicePayModels ?? this.invoicePayModels,
      invoiceHistoryModels: invoiceHistoryModels ?? this.invoiceHistoryModels,
      summary: summary ?? this.summary,
      qrState: qrState ?? this.qrState,
      slipState: slipState ?? this.slipState,
      authValid: authValid ?? this.authValid,
      uploadTargetUuid:
          clearUploadTarget ? null : (uploadTargetUuid ?? this.uploadTargetUuid),
      uploadTargetAmount: clearUploadTarget
          ? null
          : (uploadTargetAmount ?? this.uploadTargetAmount),
      sectionErrors: sectionErrors ?? this.sectionErrors,
      invoiceHistoryByDocno:
          invoiceHistoryByDocno ?? this.invoiceHistoryByDocno,
      invoiceFineByDocno: invoiceFineByDocno ?? this.invoiceFineByDocno,
      detailLoadingDocno:
          clearDetailLoading ? null : (detailLoadingDocno ?? this.detailLoadingDocno),
    );
  }

  /// Status classifier สำหรับ Intent
  static NormalizedIntentStatus classifyIntentStatus(PaymentIntent intent) {
    final statusStr = (intent.status ?? '').toLowerCase();
    final systemStatus = (intent.systemStatus ?? '').toLowerCase();

    final isVerify = statusStr.contains('ตรวจ') ||
        statusStr.contains('review') ||
        statusStr.contains('pending') ||
        statusStr.contains('รอการ') ||
        systemStatus == 'slip_uploaded' ||
        intent.latestSlip != null;

    if (isVerify) {
      return NormalizedIntentStatus.awaitingVerification;
    }

    final isAwaitingSlip = statusStr.contains('รอชำระ') ||
        statusStr.contains('awaiting') ||
        statusStr.contains('pay');

    if (isAwaitingSlip) {
      return NormalizedIntentStatus.awaitingSlip;
    }

    if (statusStr.contains('success') || statusStr.contains('สำเร็จ')) {
      return NormalizedIntentStatus.completed;
    }
    if (statusStr.contains('expire') || statusStr.contains('หมดอายุ')) {
      return NormalizedIntentStatus.expired;
    }
    if (statusStr.contains('cancel') || statusStr.contains('ยกเลิก')) {
      return NormalizedIntentStatus.cancelled;
    }

    return NormalizedIntentStatus.payable;
  }
}
