import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config-intents.dart';

Future<http.Response?> postPaymentIntentsBillReferenceAvailableBulkSlip({
  String? cusno,
  required String propertyno,
  required List billreference,
}) async {
  final ok = await MyHeadersIntents.checkauthpaymentintents();
  if (!ok) return null;

  final headers = await MyHeadersIntents.build();
  final url = Uri.parse(
    '${MyconfigIntents().domainIntents}/v1/payment/intents/bill-reference/slip/bulk',
  );

// {
//   "payloads": {
//     "bill_references": [
//       "INV69-06-001752",
//       "10008-05-2026-R4/3"
//     ]
//   }
// }
  final body = jsonEncode({
    // 'e': true, // debug
    'payloads': {
      'bill_references': billreference,
    },
  });

  // debug
  print('POST postPaymentIntentsBillReferenceAvailableBulkSlip : $url');
  print('Body: $body');

  try {
    final response = await http.post(
      url,
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print(
        'response : ${response.body}',
      );
      return response;
    } else {
      try {
        final respJson = jsonDecode(response.body);
        print(
          '❌ postPaymentIntentsBillReferenceAvailableBulkSlip Failed [${response.statusCode}]: $respJson',
        );
      } catch (_) {
        print(
          '❌ postPaymentIntentsBillReferenceAvailableBulkSlipSlip Failed [${response.statusCode}]: ${response.body}',
        );
      }
      return response;
    }
  } catch (e, stack) {
    print(
        '❌ Exception in POST postPaymentIntentsBillReferenceAvailableBulkSlip: $e');
    print('🧭 StackTrace:\n$stack');
    return null;
  }

/////////======>
// EX.Response {
//   "success": true,
//   "data": {
//     "INV69-06-001752": true,
//     "10008-05-2026-R4/3": true
//   }
// }
/////////======>
}
