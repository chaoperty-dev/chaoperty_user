import 'package:flutter/cupertino.dart';

import 'crc16.dart';

String _tlv(String id, String value) {
  final len = value.length.toString().padLeft(2, '0');
  return '$id$len$value';
}

String generateEwalletQRCode({String promptPayID = "", double amount = 0}) {
  // Sanitize: เอาเฉพาะตัวเลข
  final cleanId = promptPayID.replaceAll(RegExp(r'[^0-9]'), '');
  print(
      '[EwalletQR] Called with promptPayID="$promptPayID" (clean=$cleanId, len=${cleanId.length}), amount=$amount');

  if (cleanId.length != 10 &&
      cleanId.length != 13 &&
      cleanId.length != 15 &&
      cleanId.length != 16) {
    print(
        '[EwalletQR] REJECTED: ID length ${cleanId.length} is not 10, 13, or 15, or 16');
    return "";
  }

  // 00: Payload Format Indicator (01)
  final start = _tlv('00', '01');

  // 01: Point of Initiation Method (11 = Dynamic)
  final poiMethod = _tlv('01', '11');

  // 29: Merchant Account Information (PromptPay)
  // AID A000000677010111 = PromptPay (รองรับทั้งธนาคารและ E-wallet ทุกตัวในไทย)
  final aid = _tlv('00', 'A000000677010111');
  final idField = (cleanId.length == 10)
      // 01: Mobile (ต้องเป็น 0066 + เบอร์ตัด 0 ตัวหน้า)
      ? _tlv('01', '006${'6'}${cleanId.substring(1)}')
      // 02: National ID (13 หลัก)
      : (cleanId.length == 13)
          ? _tlv('02', cleanId)
          // 03: E-Wallet ID (15 หลัก)
          : _tlv('03', cleanId);
  final mai = _tlv('29', aid + idField);

  // 53: Transaction Currency (764 = THB)
  final currencyISO = _tlv('53', '764');

  // 58: Country Code (TH)
  final country = _tlv('58', 'TH');

  // 54: Amount (optional)
  final dataAmount = amount > 0 ? _tlv('54', amount.toStringAsFixed(2)) : '';

  // 63: CRC placeholder
  const checkSumTag = '63';
  const checkSumLen = '04';

  // payload ก่อนคำนวณ CRC (ต้องลงท้ายด้วย 6304)
  final payloadNoCRC =
      '$start$poiMethod$mai$currencyISO$country$dataAmount$checkSumTag$checkSumLen';

  // คำนวณ CRC16 แล้วแพดให้ครบ 4 หลักเสมอ
  final crcHex =
      crc16(payloadNoCRC).toRadixString(16).toUpperCase().padLeft(4, '0');
  debugPrint('generateEwalletQRCode');
  debugPrint('$payloadNoCRC$crcHex');
  return '$payloadNoCRC$crcHex';
}
