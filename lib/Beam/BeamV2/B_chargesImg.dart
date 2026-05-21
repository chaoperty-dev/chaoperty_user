import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../Api_V2/MyHeaders.dart';

Future<http.Response?> postBeamChargesImg({
  required int bankMerchantId,
  required String ref1,
  required String ref2,
  required double aMount,
  required String expiryTime,
}) async {
  final url = Uri.parse('https://api.beamcheckout.com/api/v1/charges');

  // 🔐 Authorization ตาม curl (แนะนำเก็บไว้ใน .env หรือ config)
  final headers = {
    'Authorization':
        'basic dGhla2FubmFzOnM2bGtaQ2dMRUpIekt2ckcyeFk2TDdOVGJDOGRxZGZWRU1lL2ZiNmhHNWc9',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // 🧾 JSON body (อิงตามตัวอย่าง cURL)
  final body = jsonEncode({
    "amount": aMount,
    "currency": "THB",
    "paymentMethod": {
      "qrPromptPay": {
        "expiryTime":
            expiryTime, // ✅ ใช้ค่าที่ส่งมา เช่น "2025-11-12T02:31:59.000000Z"
        // "expiryTime": DateTime.now()
        //     .add(const Duration(minutes: 15))
        //     .toUtc()
        //     .toIso8601String(), // ✅ หมดอายุอีก 15 นาที
      },
      "paymentMethodType": "QR_PROMPT_PAY"
    },
    "referenceId": ref1, // ✅ unique
    "merchantReference": "เลขที่สัญญา ",
    "merchantReferenceId": "cFinn",
    "returnUrl": "https://www.beamcheckout.com",
    "skip3dsFlow": false,
  });

  print('🚀 POST $url');
  print('Headers: $headers');
  print('Body: $body');

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ POST BeamCharges Success: ${response.body}');
      return response;
    } else {
      print('❌ BeamCharges Failed [${response.statusCode}]: ${response.body}');
      return response;
    }
  } catch (e, stack) {
    print('💥 Exception in postBeamChargesImg: $e');
    print(stack);
    return null;
  }
}
