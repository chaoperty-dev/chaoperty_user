import 'package:chaoperty_user/CRC_16_Prompay/generate_Ewallet_qrcode.dart';
import 'package:chaoperty_user/CRC_16_Prompay/generate_qrcode.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';

/// ชนิดช่องทางที่เกี่ยวกับ QR — ค่าตรงกับ `ptser` ของ `PayMentModel`
///
/// แยกจาก [PaymentChannelMode] เพราะ `ptser == '2'` (bank transfer) ใช้รูป QR
/// ของธนาคาร ไม่ได้ generate payload เอง
abstract final class QrPayloadKind {
  static const String promptPay = '5';
  static const String billPayment = '6';
  static const String serverPayload = '7';
  static const String bankTransfer = '2';
  static const String ewallet = '11';

  /// ชนิดที่ generate payload เองได้ (ไม่ต้องพึ่ง server)
  static const Set<String> generated = {promptPay, billPayment, ewallet};

  /// ชนิดที่ใช้ payload จาก server (`active_qr_session.payload` / response)
  static const String fromServer = serverPayload;
}

/// ตัวสร้าง payload QR — pure function เพื่อ unit test ได้โดยไม่ต้องมี network
///
/// ยึดสูตรเดียวกับต้นฉบับ `QrGenRef()` (payment_subV4_InvAll.dart:1594-1609):
/// ```
/// qrBno = selectedValue ?? paybno ?? '-'
/// ptser 7  → qr_payload (จาก active_qr_session)
/// ptser 6  → '|$qrBno\r$ref1\r$ref2\r$amt'   (amt ตัดจุดทศนิยมออก)
/// ptser 5  → generateQRCode(promptPayID: qrBno, amount: amtVal)
/// ptser 11 → generateEwalletQRCode(promptPayID: qrBno, amount: amtVal)
/// ptser 2  → '$payimg'  (ชื่อไฟล์รูป QR ของธนาคาร ไม่ใช่ payload ที่สแกนได้)
/// อื่น ๆ   → ''
/// ```
abstract final class PaymentQrPayload {
  /// ค่าที่ต้นฉบับใช้แทนค่าว่าง — `'-'`
  static const String placeholder = '-';

  /// จำนวนเงินที่ต้องเป็นค่าตั้งต้นเมื่อผู้เรียกไม่มี `requestedAmount`
  ///
  /// ต้นฉบับอ่านจาก `currentIntent.requestedAmount` เท่านั้น ไม่ใช่ยอดที่คำนวณใหม่
  /// เพราะยอดที่ server ถืออาจไม่เท่ากับยอดที่ฝั่งแอปรวมเอง (ดู [resolveAmount])
  static double resolveAmount({
    double? intentRequestedAmount,
    required double fallback,
  }) {
    final fromIntent = intentRequestedAmount ?? 0;
    if (fromIntent > 0) return fromIntent;
    return fallback > 0 ? fallback : 0;
  }

  /// เลือก ref1 ตามลำดับของต้นฉบับ (payment_subV4_InvAll.dart:1443-1460)
  ///
  /// 1. ref จาก active_qr_session / response
  /// 2. `metadata.first.cid` ของ invoice แรกใน intent
  /// 3. `customerNo` ของ intent
  /// 4. `'-'` (ต้นฉบับใส่ `?? '-'` ตอนประกอบ payload)
  static String resolveRef1({
    required String fromSession,
    required List<Invoice> invoices,
    String? customerNo,
  }) {
    if (fromSession.trim().isNotEmpty) return fromSession.trim();

    if (invoices.isNotEmpty && invoices.first.metadata.isNotEmpty) {
      final cid = (invoices.first.metadata.first.cid ?? '').trim();
      if (cid.isNotEmpty) return cid;
    }

    final cust = (customerNo ?? '').trim();
    if (cust.isNotEmpty) return cust;

    return placeholder;
  }

  /// เลือก ref2 ตามลำดับของต้นฉบับ (payment_subV4_InvAll.dart:1461-1466)
  ///
  /// 1. ref จาก active_qr_session / response
  /// 2. `paymentIntentNo`
  /// 3. `'-'`
  static String resolveRef2({
    required String fromSession,
    String? paymentIntentNo,
  }) {
    if (fromSession.trim().isNotEmpty) return fromSession.trim();

    final no = (paymentIntentNo ?? '').trim();
    if (no.isNotEmpty) return no;

    return placeholder;
  }

  /// ref3 ของต้นฉบับมาจาก session/argument เท่านั้น ไม่มี fallback จาก intent
  /// จึงใส่ `'-'` เมื่อว่าง (payment_subV4_InvAll.dart:1554)
  static String resolveRef3({required String fromSession}) {
    final value = fromSession.trim();
    return value.isEmpty ? placeholder : value;
  }

  /// bno ที่ใช้สร้าง QR — `selectedValue ?? paybno ?? '-'`
  ///
  /// ต้นฉบับใช้ bno ของช่องทางที่เลือก (PromptPay ID) ไม่ใช่ ref ที่ server ส่งมา
  static String resolveBno({
    String? selectedBno,
    String? intentBno,
  }) {
    final selected = (selectedBno ?? '').trim();
    if (selected.isNotEmpty) return selected;

    final fromIntent = (intentBno ?? '').trim();
    if (fromIntent.isNotEmpty) return fromIntent;

    return placeholder;
  }

  /// สร้าง payload สำหรับ [ptser] ที่ระบุ
  ///
  /// [serverPayload] ใช้เฉพาะ `ptser == '7'`
  ///
  /// `ptser == '2'` คืนค่าว่างเสมอ — ต้นฉบับมีนิพจน์ `payimg` อยู่ใน chain
  /// (`payment_subV4_InvAll.dart:1607`) แต่ branch ที่วาดรูปนั้นไม่เคยถูกเรียก
  /// เพราะ `if (payment_tser == '2')` ด้านนอก (`:2774`) ชนะและแสดงการ์ด
  /// เลขบัญชีแทน — ไม่ทำพฤติกรรมที่ไม่มีผลจริง
  static String build({
    required String ptser,
    required String bno,
    required double amount,
    String? ref1,
    String? ref2,
    String serverPayload = '',
  }) {
    switch (ptser.trim()) {
      case QrPayloadKind.serverPayload:
        return serverPayload;
      case QrPayloadKind.billPayment:
        final amtRaw = amount.toStringAsFixed(2).replaceAll('.', '');
        return '|$bno\r${ref1 ?? ''}\r${ref2 ?? ''}\r$amtRaw';
      case QrPayloadKind.promptPay:
        return generateQRCode(promptPayID: bno, amount: amount);
      case QrPayloadKind.ewallet:
        return generateEwalletQRCode(promptPayID: bno, amount: amount);
      default:
        return '';
    }
  }

  /// ชนิดนี้ต้องมี payload ก่อนจึงจะวาด QR ได้
  static bool needsPayload(String ptser) =>
      QrPayloadKind.generated.contains(ptser.trim()) ||
      ptser.trim() == QrPayloadKind.fromServer;
}
