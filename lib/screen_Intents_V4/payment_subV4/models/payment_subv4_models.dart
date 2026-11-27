import 'package:flutter/foundation.dart';
import 'package:chaoperty_user/Model/GetTeNant_Model.dart';
import 'package:chaoperty_user/Model/GetPayMent_Model.dart';
import 'package:chaoperty_user/Model/GetRenTal_Model.dart';
import 'package:chaoperty_user/Model/GetInvoice_Model.dart';
import 'package:chaoperty_user/Model/GetInvoice_pay_Model.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/screen_Intents/bankCodeMap.dart';
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

/// รูปแบบช่องทางที่ View ต้องแสดง
/// แยกออกจาก QrStatus เพราะ intent ของ Bank Transfer ก็ active ได้โดยไม่มี QR
enum PaymentChannelMode { qr, bankTransfer, unsupported }

/// ปุ่ม action บนการ์ด intent ในแท็บ 2/3
///
/// ชื่อและลำดับอ้างกติกาต้นฉบับ `_IntentBox`:
/// - `paymentProof` = ปุ่ม "หลักฐานการชำระ" (มีสลิปอยู่แล้ว และยังไม่อยู่ระหว่างตรวจ)
/// - `attachProof` = "กดเพื่อแนบหลักฐาน" (รอแนบหลักฐาน)
/// - `viewProof` = "กดเพื่อดูหลักฐาน" (รอระบบตรวจสอบ แต่ยังไม่มีข้อมูลสลิป)
/// - `pressToPay` = "กดเพื่อยืนยัน" (สถานะอื่น)
/// - `none` = ต้นฉบับไม่แสดงปุ่ม (แนบสลิปแล้วและอยู่ระหว่างตรวจ)
enum IntentCardAction { none, paymentProof, attachProof, viewProof, pressToPay }

/// สถานะของ "การแนบสลิป" ที่การ์ดต้องรู้ เพื่อเลือกปุ่มให้ตรงต้นฉบับ
enum IntentSlipPresence { none, uploaded, awaitingCheck }

/// ข้อมูลหลักฐานการชำระที่โหลดกลับมาจาก `GET /v1/payment/intent/{uuid}`
/// โครงเดียวกับ `attaches` ของ server
class PaymentSlipInfo {
  const PaymentSlipInfo({
    this.slipNo,
    this.originalFilename,
    this.amount,
    this.currency,
    this.transferDate,
    this.transferRefNo,
    this.status,
  });

  final String? slipNo;
  final String? originalFilename;
  final String? amount;
  final String? currency;
  final String? transferDate;
  final String? transferRefNo;
  final String? status;

  bool get isValid => (slipNo ?? '').trim().isNotEmpty;

  /// ข้อความสถานะภาษาไทย ตาม `_getStatusText` ของต้นฉบับ
  String get statusLabel {
    switch ((status ?? '').toUpperCase()) {
      case 'PENDING':
        return 'รอตรวจสอบ';
      case 'APPROVED':
        return 'อนุมัติแล้ว';
      case 'REJECTED':
        return 'ไม่อนุมัติ';
      default:
        final raw = (status ?? '').trim();
        return raw.isEmpty ? '-' : raw;
    }
  }

  String get amountWithCurrency {
    final value = (amount ?? '').trim();
    final cur = (currency ?? '').trim();
    if (value.isEmpty) return '-';
    return cur.isEmpty ? value : '$value $cur';
  }

  static PaymentSlipInfo? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final info = PaymentSlipInfo(
      slipNo: _slipString(map['slip_no']),
      originalFilename: _slipString(map['original_filename']),
      amount: _slipString(map['amount']),
      currency: _slipString(map['currency']),
      transferDate: _slipString(map['transfer_date']),
      transferRefNo: _slipString(map['transfer_ref_no']),
      status: _slipString(map['status']),
    );
    return info;
  }
}

String? _slipString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

extension PayMentModelDisplay on PayMentModel {
  PaymentChannelMode get channelMode {
    final type = (ptser ?? '').trim();
    if (type == '2') return PaymentChannelMode.bankTransfer;
    if (const {'5', '6', '7', '11'}.contains(type)) {
      return PaymentChannelMode.qr;
    }
    return PaymentChannelMode.unsupported;
  }

  bool get isQrChannel => channelMode == PaymentChannelMode.qr;
  bool get isBankTransfer => channelMode == PaymentChannelMode.bankTransfer;

  String bankDisplayName({required bool isEn}) {
    final raw = (bank ?? '').trim();
    final info = bankCodeMap[raw];
    if (isEn) return (info?['en'] ?? raw).trim();
    return raw;
  }

  String get bankShortCode => bankCodeMap[(bank ?? '').trim()]?['code'] ?? '';

  String? get bankLogoAsset {
    final file = bankCodeMap[(bank ?? '').trim()]?['logo'];
    return file == null || file.isEmpty ? null : 'assets/images/LogoBank/$file';
  }

  String get safeAccountNumber {
    final value = (bno ?? '').trim();
    return value == 'null' ? '' : value;
  }

  /// ชื่อบัญชีผู้รับเงินที่แสดงบนหน้าจอ — ใช้ `bname` เท่านั้น
  ///
  /// ต้นฉบับเก็บ `payment_bname = _PayMentModels[i].bname` แล้วใช้แสดงทุกจุด
  /// (payment_subV4_InvAll.dart:852, 2855, 3407, 5279) และไม่สลับเป็น `bnameEn`
  /// ตามภาษา — `bnameEn` ใช้ส่ง API เท่านั้น (`PayBname_en`, :1139)
  ///
  /// [isEn] เก็บไว้ให้ผู้เรียกเดิมไม่ต้องแก้ แต่ไม่มีผลต่อค่าที่คืน
  String accountOwner({bool isEn = false}) {
    final value = (bname ?? '').trim();
    return value == 'null' ? '' : value;
  }

  String get safeRemark {
    final value = (remark ?? '').trim();
    return value == 'null' ? '' : value;
  }
}

/// ยอดที่ต้อง **แสดงผล** ของใบแจ้งหนี้
///
/// ใช้ `total_bill` เป็นหลัก เพราะเป็นค่าที่ทุกหน้าจอของต้นฉบับใช้แสดง:
/// - `payment_subV4_InvAll.dart:5210` → `_safeDouble(model.total_bill)`
/// - `payment_subV3_InvAll.dart:5038` → `_safeDouble(model.total_bill)`
/// - `paymentMainV3InvAll` `_billRow` → `bill.totalBill`
///
/// `amtall` เป็นยอดที่ใช้ **ส่ง API** (`buildInvoiceEntry` → `'total'`) ไม่ใช่ยอดที่แสดง
/// สองค่าไม่เท่ากันในบางโครงการ (ต่างกันด้วย VAT) จึงห้ามสลับกันใช้
extension InvoiceModelDisplay on InvoiceModel {
  Money get displayAmount {
    final bill = Money.parse(total_bill);
    if (bill.isPositive) return bill;
    return Money.parse(amtall);
  }

  /// ส่วนลดที่แสดง — ใช้ `disendbill` ตามต้นฉบับ
  Money get displayDiscount => Money.parse(disendbill);
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
    this.amount,
    this.softExpireAt,
    this.billExpireAt,
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

  /// ยอดที่ใช้สร้าง QR — ต้องเป็นยอดที่ server ถือ (`requested_amount` ของ intent)
  /// ไม่ใช่ยอดที่ฝั่งแอปรวมเอง เพราะสองค่าไม่เท่ากันเมื่อมีส่วนลด
  final double? amount;

  /// หมดอายุของ QR session (ใช้เดิน countdown)
  final String? softExpireAt;

  /// deadline ของบิล (ต่างจาก session) — ใช้ตัดสินว่า renew ได้หรือไม่
  final String? billExpireAt;

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
    double? amount,
    String? softExpireAt,
    String? billExpireAt,
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
      amount: amount ?? this.amount,
      softExpireAt: softExpireAt ?? this.softExpireAt,
      billExpireAt: billExpireAt ?? this.billExpireAt,
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
    this.seq = 0,
  });

  /// ชนิดของ event (ใช้ระบุชนิด ไม่ใช่ระบุ instance)
  final String id;
  final String message;
  final bool isError;

  /// เลขลำดับไม่ซ้ำต่อการ emit หนึ่งครั้ง
  /// จำเป็นเพราะ event ชนิดเดิม (id เดิม) เกิดซ้ำได้ เช่น อัปโหลดล้มเหลวหลายครั้ง
  /// ถ้าใช้ id เปรียบเทียบเฉย ๆ ครั้งที่สองจะไม่ถูกแสดง
  final int seq;
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
    this.targetIntent,
    this.attachedSlip,
    this.slipPreviewBytes,
    this.isSlipPreviewLoading = false,
    this.slipPreviewError,
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

  /// Intent ที่ผู้ใช้กดจากการ์ดแท็บ 2/3 (ใช้แสดงข้อมูลหลักฐานของใบนั้น)
  final PaymentIntent? targetIntent;

  /// ข้อมูลหลักฐานที่โหลดจาก intent detail (`attaches`)
  final PaymentSlipInfo? attachedSlip;

  /// ไบต์รูปหลักฐานที่โหลดผ่าน preview endpoint
  final Uint8List? slipPreviewBytes;
  final bool isSlipPreviewLoading;
  final String? slipPreviewError;

  /// error ของแต่ละ section ที่โหลดไม่สำเร็จ (ไม่ล้างข้อมูล section อื่นที่สำเร็จ)
  final List<String> sectionErrors;

  /// รายละเอียดบิลย่อยต่อ invoice/docno (โหลดเมื่อผู้ใช้กางรายการ)
  final Map<String, List<IntentsInvoiceHistoryModel>> invoiceHistoryByDocno;

  /// ค่าปรับราย invoice จาก GC_selectFine_inv
  final Map<String, Map<String, dynamic>> invoiceFineByDocno;

  /// docno ที่กำลังโหลดรายละเอียด (แสดง loading เฉพาะแถวนั้น)
  final String? detailLoadingDocno;

  // Tab Count Getters
  //
  // ใช้กติกาข้อความ status แบบเดียวกับต้นฉบับ (`_countAwaitingSlip` /
  // `_countAwaitingVerify`) ไม่ใช่ [classifyIntentStatus] เพราะต้นฉบับนับจาก
  // ข้อความ status เท่านั้น — intent ที่ system_status เป็น slip_uploaded
  // แต่ status ยังเป็น "รอชำระเงิน" จะยังอยู่แท็บรอแนบหลักฐานเหมือนต้นฉบับ
  int get countAwaitingSlip =>
      paymentIntents.where((p) => legacyIsAwaitingSlipStatus(p.status)).length;

  int get countAwaitingVerify => paymentIntents
      .where((p) => legacyIsAwaitingVerifyStatus(p.status))
      .length;

  /// Intent ที่ต้องแสดงในแท็บ 2 (รอแนบหลักฐาน)
  List<PaymentIntent> get awaitingSlipIntents => paymentIntents
      .where((p) => legacyIsAwaitingSlipStatus(p.status))
      .toList();

  /// Intent ที่ต้องแสดงในแท็บ 3 (รอระบบตรวจสอบ)
  List<PaymentIntent> get awaitingVerifyIntents => paymentIntents
      .where((p) => legacyIsAwaitingVerifyStatus(p.status))
      .toList();

  PaymentSubV4State copyWith({
    PageStatus? pageStatus,
    PaymentOperation? operation,
    String? errorMessage,
    bool clearError = false,
    PaymentUiEvent? uiEvent,
    bool clearUiEvent = false,
    int? selectedTab,
    bool? hasAutoSwitched,
    List<InvoiceModel>? invoices,
    List<InvoiceModel>? invoicesInIntent,
    List<PaymentIntent>? paymentIntents,
    List<PayMentModel>? paymentModels,
    PayMentModel? selectedPaymentModel,
    bool clearSelectedPayment = false,
    RenTalModel? rentalModel,
    bool clearRental = false,
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
    PaymentIntent? targetIntent,
    bool clearTargetIntent = false,
    PaymentSlipInfo? attachedSlip,
    bool clearAttachedSlip = false,
    Uint8List? slipPreviewBytes,
    bool clearSlipPreview = false,
    bool? isSlipPreviewLoading,
    String? slipPreviewError,
    List<String>? sectionErrors,
    bool clearSectionErrors = false,
    Map<String, List<IntentsInvoiceHistoryModel>>? invoiceHistoryByDocno,
    Map<String, Map<String, dynamic>>? invoiceFineByDocno,
    String? detailLoadingDocno,
    bool clearDetailLoading = false,
  }) {
    return PaymentSubV4State(
      pageStatus: pageStatus ?? this.pageStatus,
      operation: operation ?? this.operation,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      // คง event เดิมไว้จนกว่าจะสั่ง clear หรือส่ง event ใหม่
      uiEvent: clearUiEvent ? null : (uiEvent ?? this.uiEvent),
      selectedTab: selectedTab ?? this.selectedTab,
      hasAutoSwitched: hasAutoSwitched ?? this.hasAutoSwitched,
      invoices: invoices ?? this.invoices,
      invoicesInIntent: invoicesInIntent ?? this.invoicesInIntent,
      paymentIntents: paymentIntents ?? this.paymentIntents,
      paymentModels: paymentModels ?? this.paymentModels,
      selectedPaymentModel: clearSelectedPayment
          ? null
          : (selectedPaymentModel ?? this.selectedPaymentModel),
      rentalModel: clearRental ? null : (rentalModel ?? this.rentalModel),
      tenantModels: tenantModels ?? this.tenantModels,
      contractxFineModels: contractxFineModels ?? this.contractxFineModels,
      invoicePayModels: invoicePayModels ?? this.invoicePayModels,
      invoiceHistoryModels: invoiceHistoryModels ?? this.invoiceHistoryModels,
      summary: summary ?? this.summary,
      qrState: qrState ?? this.qrState,
      slipState: slipState ?? this.slipState,
      authValid: authValid ?? this.authValid,
      uploadTargetUuid: clearUploadTarget
          ? null
          : (uploadTargetUuid ?? this.uploadTargetUuid),
      uploadTargetAmount: clearUploadTarget
          ? null
          : (uploadTargetAmount ?? this.uploadTargetAmount),
      targetIntent:
          clearTargetIntent ? null : (targetIntent ?? this.targetIntent),
      attachedSlip:
          clearAttachedSlip ? null : (attachedSlip ?? this.attachedSlip),
      slipPreviewBytes:
          clearSlipPreview ? null : (slipPreviewBytes ?? this.slipPreviewBytes),
      isSlipPreviewLoading: isSlipPreviewLoading ?? this.isSlipPreviewLoading,
      slipPreviewError:
          clearSlipPreview ? null : (slipPreviewError ?? this.slipPreviewError),
      sectionErrors:
          clearSectionErrors ? const [] : (sectionErrors ?? this.sectionErrors),
      invoiceHistoryByDocno:
          invoiceHistoryByDocno ?? this.invoiceHistoryByDocno,
      invoiceFineByDocno: invoiceFineByDocno ?? this.invoiceFineByDocno,
      detailLoadingDocno: clearDetailLoading
          ? null
          : (detailLoadingDocno ?? this.detailLoadingDocno),
    );
  }

  /// มีหลักฐานถูกอัปโหลดแล้วหรือไม่ (ตามต้นฉบับ `showSlipAction`)
  static bool hasUploadedSlip(PaymentIntent intent) {
    final systemStatus = (intent.systemStatus ?? '').toLowerCase();
    return intent.latestSlip != null || systemStatus == 'slip_uploaded';
  }

  /// สถานะ "รอตรวจสอบ" แบบตรงตัวตามต้นฉบับ (`isWaitingCheck`)
  ///
  /// ต้นฉบับเทียบเท่ากับ `'รอตรวจสอบ'` หรือ `'รอการตรวจสอบ'` เท่านั้น
  /// ไม่ใช่ contains — จึงแยกจาก [legacyIsAwaitingVerifyStatus]
  static bool legacyIsWaitingCheckStatus(String? status) {
    final s = (status ?? '').trim();
    return s == 'รอตรวจสอบ' || s == 'รอการตรวจสอบ';
  }

  /// สถานะที่ต้นฉบับถือว่า "อยู่ระหว่างตรวจ" (ใช้เลือกสี/label)
  ///
  /// ต่างจาก [classifyIntentStatus] ที่นับ `slip_uploaded` และ `latestSlip`
  /// เป็น awaitingVerification ด้วย — กติกาปุ่มของต้นฉบับใช้เฉพาะข้อความ status
  static bool legacyIsAwaitingVerifyStatus(String? status) {
    final s = (status ?? '').toLowerCase();
    return s.contains('ตรวจ') ||
        s.contains('review') ||
        s.contains('pending') ||
        s.contains('รอการ');
  }

  /// สถานะ "รอแนบหลักฐาน" ตามต้นฉบับ (รอชำระ/awaiting/pay แต่ไม่ใช่รอตรวจ)
  static bool legacyIsAwaitingSlipStatus(String? status) {
    final s = (status ?? '').toLowerCase();
    final isPaidIntent =
        s.contains('รอชำระเงิน') || s.contains('awaiting') || s.contains('pay');
    final hasReview =
        s.contains('ตรวจ') || s.contains('review') || s.contains('pending');
    return isPaidIntent && !hasReview;
  }

  /// สถานะการมีหลักฐานของการ์ด — ใช้เลือกปุ่มให้ตรงต้นฉบับ
  ///
  /// ใช้ [legacyIsWaitingCheckStatus] (ตรงตัว) ไม่ใช่ contains
  /// เพราะต้นฉบับเทียบ status แบบตรงตัวใน `isWaitingCheck`
  static IntentSlipPresence intentSlipPresence(PaymentIntent intent) {
    if (hasUploadedSlip(intent)) return IntentSlipPresence.uploaded;
    if (legacyIsWaitingCheckStatus(intent.status)) {
      return IntentSlipPresence.awaitingCheck;
    }
    return IntentSlipPresence.none;
  }

  /// ปุ่มที่การ์ดต้องแสดง
  ///
  /// กติกาต้นฉบับ `_IntentBox` (payment_subV4_InvAll.dart):
  /// - `showSlipAction = latestSlip != null || systemStatus == 'slip_uploaded'
  ///   || status == 'รอตรวจสอบ' || status == 'รอการตรวจสอบ'`
  /// - ถ้า `showSlipAction` และ status เป็นรอตรวจ → ไม่แสดงปุ่มเลย
  /// - ถ้า `showSlipAction` และไม่ใช่รอตรวจ → แสดงปุ่ม "หลักฐานการชำระ"
  /// - ถ้าไม่ `showSlipAction` → ปุ่มตามประเภทสถานะ
  static IntentCardAction intentCardAction(PaymentIntent intent) {
    final presence = intentSlipPresence(intent);
    if (presence != IntentSlipPresence.none) {
      return legacyIsAwaitingVerifyStatus(intent.status)
          ? IntentCardAction.none
          : IntentCardAction.paymentProof;
    }

    if (legacyIsAwaitingVerifyStatus(intent.status)) {
      return IntentCardAction.viewProof;
    }
    if (legacyIsAwaitingSlipStatus(intent.status)) {
      return IntentCardAction.attachProof;
    }
    return IntentCardAction.pressToPay;
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
