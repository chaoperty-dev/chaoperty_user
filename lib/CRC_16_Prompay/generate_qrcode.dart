import 'crc16.dart';

String _tlv(String id, String value) {
  final len = value.length.toString().padLeft(2, '0');
  return '$id$len$value';
}

String generateQRCode({String promptPayID = "", double amount = 0}) {
  // รองรับเลข 10 หลัก (เบอร์โทร), 13 หลัก (เลขบัตรประชาชน), และ 15 หลัก (เลขบัญชีธนาคาร)
  if (promptPayID.length != 10 &&
      promptPayID.length != 13 &&
      promptPayID.length != 15) return "";

  // 00: Payload Format Indicator (01)
  final start = _tlv('00', '01');

  // 01: Point of Initiation Method (11 = Dynamic)
  final poiMethod = _tlv('01', '11');

  // 29: Merchant Account Information (PromptPay)
  final aid = _tlv('00', 'A000000677010111');
  final idField;
  if (promptPayID.length == 10) {
    // 01: Mobile (ต้องเป็น 0066 + เบอร์ตัด 0 ตัวหน้า)
    idField = _tlv('01', '006${'6'}${promptPayID.substring(1)}');
  } else if (promptPayID.length == 13) {
    // 02: National ID
    idField = _tlv('02', promptPayID);
  } else {
    // 04: Bank Account (เลขบัญชี 15 หลัก)
    idField = _tlv('04', promptPayID);
  }
  final mai = _tlv('29', aid + idField);

  // 53: Transaction Currency (764 = THB)
  final currencyISO = _tlv('53', '764');

  // 58: Country Code (TH)
  final country = _tlv('58', 'TH');

  // 54: Amount (optional)
  final dataAmount = amount > 0 ? _tlv('54', amount.toStringAsFixed(2)) : '';

  // (optionally) 52/59/60 ฯลฯ สามารถใส่เพิ่มได้ตามมาตรฐาน
  // final mcc = _tlv('52','0000');
  // final name = _tlv('59','MERCHANT');
  // final city = _tlv('60','BANGKOK');

  // 63: CRC placeholder
  const checkSumTag = '63';
  const checkSumLen = '04';

  // payload ก่อนคำนวณ CRC (ต้องลงท้ายด้วย 6304)
  final payloadNoCRC =
      '$start$poiMethod$mai$currencyISO$country$dataAmount$checkSumTag$checkSumLen';

  // คำนวณ CRC16 แล้วแพดให้ครบ 4 หลักเสมอ
  final crcHex =
      crc16(payloadNoCRC).toRadixString(16).toUpperCase().padLeft(4, '0');

  return '$payloadNoCRC$crcHex';
}

// String generateQRCode({String promptPayID = "", double amount = 0}) {
//   if (promptPayID.length == 10 || promptPayID.length == 13) {
//     /// Start
//     String start = "000201";

//     /// Accept recycle
//     String acceptRecycle = "010211";

//     /// Merchant account information
//     /// application ID
//     String merchantInfo = "0016A000000677010111";

//     /// PromptPay ID
//     /// length 10 = phone
//     /// length 13 = ID Card
//     String merchantInfoType = promptPayID.length == 10
//         ? "2937${merchantInfo}01130066${promptPayID.substring(1)}"
//         : "2937${merchantInfo}0213$promptPayID";

//     /// Field 58 length 28 data TH is Thai baht
//     String currency = "5802TH";

//     /// Amount
//     String dataAmount = "";
//     if (amount > 0) {
//       String amountText = amount.toStringAsFixed(2);
//       String amountLength = amountText.length < 10
//           ? "0${amountText.length}"
//           : "${amountText.length}";
//       dataAmount = "54$amountLength$amountText";
//     }

//     /// Field 53 length 03 data 764 is thai baht in ISO4217
//     String currencyISO = "5303764";

//     /// checksum Field 63 length 04
//     String checkSum = "6304";

//     /// Prompt-pay generate before checksum use to [crc16] for check sum.
//     String promptPayQR =
//         "$start$acceptRecycle$merchantInfoType$currency$dataAmount$currencyISO$checkSum";

//     /// check sum by [crc16]
//     String checkSumData = crc16(promptPayQR).toRadixString(16).toUpperCase();

//     return "$promptPayQR$checkSumData";
//   }
//   return "";
// }
