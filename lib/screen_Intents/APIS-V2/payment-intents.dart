import 'dart:convert';
import 'package:chaoperty_user/Constant/api_session.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart'; // ใช้ gen uuid v4

import '../../Api_V2/MyHeaders.dart';
import 'config-intents.dart';

// Future<http.Response?> getPaymentIntents({
//   required String cusno,
//   // required String bankMerchantId,
// }) async {
//   final headers = await MyHeadersIntents.build();
//   final base = '${MyconfigIntents().domainIntents}/v1/payment/intents';
//   final url = Uri.parse(base).replace(queryParameters: {
//     'customer_no': cusno, // ✅ ส่งเป็น query string
//     // 'bank_merchant_id': bankMerchantId, // ✅ ส่งเป็น query string
//   });

//   // debug
//   print('GET getPaymentIntents : $url');
//   // print('Headers: $headers');

//   try {
//     final response = await http.get(url, headers: headers);

//     // 200–299 ถือว่าสำเร็จ
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       // print('✅ PaymentIntents Success: ${response.body}');
//       return response;
//     } else {
//       // พยายาม decode ถ้าเป็น JSON
//       try {
//         final respJson = jsonDecode(response.body);
//         print('❌ PaymentIntents Failed [${response.statusCode}]: $respJson');
//       } catch (_) {
//         print(
//             '❌ PaymentIntents Failed [${response.statusCode}]: ${response.body}');
//       }
//       return response;
//     }
//   } catch (e, stack) {
//     print('❌ Exception in GET PaymentIntents: $e');
//     print('🧭 StackTrace:\n$stack');
//     return null;
//   }
// }

Future<http.Response?> postPaymentIntentsState({
  required String cusno,
  required String propertyno,
}) async {
  final headers = await MyHeadersIntents.build();

  final url = Uri.parse(
    '${MyconfigIntents().domainIntents}/v1/payment/intents/state',
  );

  final body = jsonEncode({
    // 'e': true, // debug
    'payloads': {
      'customer_no': cusno,
      'property_no': propertyno,
    },
  });

  // debug
  print('POST postPaymentIntentsState : $url');
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
      return response;
    } else {
      try {
        final respJson = jsonDecode(response.body);
        print(
          '❌ postPaymentIntentsState Failed [${response.statusCode}]: $respJson',
        );
      } catch (_) {
        print(
          '❌ postPaymentIntentsState Failed [${response.statusCode}]: ${response.body}',
        );
      }
      return response;
    }
  } catch (e, stack) {
    print('❌ Exception in POST postPaymentIntentsState: $e');
    print('🧭 StackTrace:\n$stack');
    return null;
  }
}

// Future<http.Response?> getPaymentIntentsCanceled({
//   required String cusno,
//   // required String bankMerchantId,
// }) async {
//   final headers = await MyHeaders.build();
//   final base = '${MyconfigIntents().domainIntents}/payment-intents/canceled';
//   final url = Uri.parse(base).replace(queryParameters: {
//     'customer_no': cusno, // ✅ ส่งเป็น query string
//     // 'bank_merchant_id': bankMerchantId, // ✅ ส่งเป็น query string
//   });

//   // debug
//   print('GET getPaymentIntents Canceled: $url');
//   // print('Headers: $headers');

//   try {
//     final response = await http.get(url, headers: headers);

//     // 200–299 ถือว่าสำเร็จ
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       print('✅ PaymentIntents Canceled Success: ${response.body}');
//       return response;
//     } else {
//       // พยายาม decode ถ้าเป็น JSON
//       try {
//         final respJson = jsonDecode(response.body);
//         print(
//             '❌ PaymentIntents Canceled Failed [${response.statusCode}]: $respJson');
//       } catch (_) {
//         print(
//             '❌ PaymentIntents Canceled Failed [${response.statusCode}]: ${response.body}');
//       }
//       return response;
//     }
//   } catch (e, stack) {
//     print('❌ Exception in GET PaymentIntents Canceled: $e');
//     print('🧭 StackTrace:\n$stack');
//     return null;
//   }
// }

Future<http.Response?> DeletePaymentIntents_UuidCanceled({
  required String cusNo,
  required String propertyNo,
  required String intentsUuid,
  required int bankMerchantId,
}) async {
  if (intentsUuid.trim().isEmpty) {
    print('❌ intentsUuid ว่าง');
    return null;
  }

  try {
    // Use MyHeadersIntents for payment API v1 (with auto token refresh)
    final headers = await MyHeadersIntents.build();

    final url = Uri.parse(
      '${MyconfigIntents().domainIntents}/v1/payment/intent/$intentsUuid?force=1',
    );

    print('DELETE PaymentIntents Uuid Canceled: $url');

    final body = {
      "payloads": {
        "bank_merchant_id": 0,
        "ref2": "",
        "customer_no": cusNo, // 16-bit แล้วจาก caller
        "property_no": propertyNo, // 16-bit แล้วจาก caller
      }
    };

    print('DELETE PaymentIntents body Canceled: $body');
    final response = await http.delete(
      url,
      headers: {
        ...headers,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body), // ✅ ต้อง encode
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ PaymentIntents Uuid Canceled Success: ${response.body}');
      return response;
    }

    try {
      print(
        '❌ PaymentIntents Uuid Canceled Failed '
        '[${response.statusCode}]: ${jsonDecode(response.body)}',
      );
    } catch (_) {
      print(
        '❌ PaymentIntents Uuid Canceled Failed '
        '[${response.statusCode}]: ${response.body}',
      );
    }

    return response;
  } catch (e, stack) {
    print('❌ Exception in DeletePaymentIntents_UuidCanceled: $e');
    print('🧭 StackTrace:\n$stack');
    return null;
  }
}

// Future<http.Response?> getPaymentIntentsUuid({
//   required String cusno, // ถ้าไม่ใช้จะลบทิ้งก็ได้
//   required String intentsUuid,
// }) async {
//   if (intentsUuid.isEmpty) {
//     debugPrint('❌ intentsUuid ว่าง');
//     return null;
//   }

//   try {
//     final headers = await MyHeaders.build();
//     final base =
//         '${MyconfigIntents().domainIntents}/payment-intents/$intentsUuid';
//     final url = Uri.parse(base);

//     debugPrint('GET getPaymentIntents Uuid: $url');

//     final response = await http.get(url, headers: headers);

//     // 200–299 = success
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       return response;
//     }

//     // error log
//     try {
//       debugPrint(
//           '❌ PaymentIntents Failed [${response.statusCode}]: ${jsonDecode(response.body)}');
//     } catch (_) {
//       debugPrint(
//           '❌ PaymentIntents Failed [${response.statusCode}]: ${response.body}');
//     }
//     return response;
//   } catch (e, st) {
//     debugPrint('❌ Exception in GET PaymentIntents Uuid: $e');
//     debugPrint('🧭 StackTrace:\n$st');
//     return null;
//   }
// }

// ----------------------
// Helpers (ไม่แยกไฟล์)
// ----------------------
String _toU16Str(dynamic v) => '$v'.trim();
Future<http.Response?> postPaymentIntents(
    {required String cusNo,
    required String propertyNo,
    required String payedType,
    required String chanNel,
    required double requestedAmount,
    required double lateFee,
    required double discountAmount,
    required double depositAmount,
    required double insuranceAmount,
    required double withholdingAmount,
    required double requestedTotal,
    // required String createdById,
    required bool isAdminCreated,
    required int bankMerchantId,
    required int bankMerchantType,
    required String descripTion,
    required List<Map<String, dynamic>> inVoices, // จะถูกส่งเป็น "invoices"
    required String accountType,
    required String accountNumber,
    required String accountNameTh,
    required String accountNameEn,
    required List<Map<String, dynamic>> transSelect}) async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? ren = preferences.getString('renTalSer');
    String? createdById = preferences.getString('ser');
    final headers = await MyHeadersIntents.build();
    final url =
        Uri.parse('${MyconfigIntents().domainIntents}/v1/payment/intent');

    // ✅ ถ้าต้องการจำกัด 16-bit (unsigned) ให้ใช้แบบนี้:
    // final customerNo16 = ((int.tryParse(cusNo) ?? 0) & 0xFFFF).toString();
    // final propertyNo16 = ((int.tryParse(propertyNo) ?? 0) & 0xFFFF).toString();

    // ✅ ถ้ายังไม่จำกัด (ใช้ค่าเดิมก่อน)
    final customerNo16 = cusNo;
    final propertyNo16 = propertyNo;

    final body = {
      "payloads": {
        "customer_no": customerNo16,
        "property_no": propertyNo16,
        "payed_type": payedType,
        "channel": chanNel,
        "amount": requestedAmount,
        "receiving_account": {
          "account_type": accountType,
          "account_number": accountNumber,
          "account_name_th": accountNameTh,
          "account_name_en": accountNameEn
        },

        "late_fee": lateFee,
        "discount_amount": discountAmount,
        "deposit_amount": depositAmount,
        "insurance_amount": insuranceAmount,
        "withholding_amount": withholdingAmount,
        "total": requestedTotal,
        "bank_merchant_id": bankMerchantId,
        // "currency": "",
        "description": descripTion ?? "",
        "created_by": createdById,
        "is_admin_created": isAdminCreated,
        "bank_merchant_type": bankMerchantType,
        "invoices": inVoices, // ✅ key ให้ตรง API
        "trans": transSelect,
      }
    };

    debugPrint('POST payment intent: $url');
    debugPrint('Payload: ${jsonEncode(body)}');

    final response = await http.post(
      url,
      headers: {
        ...headers,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    try {
      debugPrint(
        '❌ postPaymentIntents Failed [${response.statusCode}]: ${jsonDecode(response.body)}',
      );
    } catch (_) {
      debugPrint(
        '❌ postPaymentIntents Failed [${response.statusCode}]: ${response.body}',
      );
    }

    return response;
  } catch (e, st) {
    debugPrint('❌ Exception in postPaymentIntents: $e');
    debugPrint('🧭 StackTrace:\n$st');
    // ✅ rethrow เพื่อให้ caller (PostPaymentIntent) เห็น exception จริง
    // และแสดง popup พร้อม endpoint URL + status + error detail
    rethrow;
  }
}

///=====>
Future<http.Response?> postGeneratePaymentIntents({
  required String cusNo,
  required String propertyNo,
  required String intentsUuid,
  required int bankMerchantId,
  bool force = false,
}) async {
  try {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // String? ren = preferences.getString('renTalSer');
    // String? createdById = preferences.getString('ser');
    final headers = await MyHeadersIntents.build();
    final url = Uri.parse(
        '${MyconfigIntents().domainIntents}/v1/payment/intent/${intentsUuid}/generate');

    // ✅ ถ้าต้องการจำกัด 16-bit (unsigned) ให้ใช้แบบนี้:
    // final customerNo16 = ((int.tryParse(cusNo) ?? 0) & 0xFFFF).toString();
    // final propertyNo16 = ((int.tryParse(propertyNo) ?? 0) & 0xFFFF).toString();

    // ✅ ถ้ายังไม่จำกัด (ใช้ค่าเดิมก่อน)
    final customerNo16 = cusNo;
    final propertyNo16 = propertyNo;

    final body = {
      "payloads": {
        "bank_merchant_id": bankMerchantId,
        "ref2": "",
        "customer_no": customerNo16,
        "property_no": propertyNo16,
        // if (force) "force": true,
      }
    };

    debugPrint('POST generate payment intent: $url');
    debugPrint('Payload: ${jsonEncode(body)}');

    final response = await http.post(
      url,
      headers: {
        ...headers,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    try {
      debugPrint(
        '❌ post Generate PaymentIntents Failed [${response.statusCode}]: ${jsonDecode(response.body)}',
      );
    } catch (_) {
      debugPrint(
        '❌ post Generate PaymentIntents Failed [${response.statusCode}]: ${response.body}',
      );
    }

    return response;
  } catch (e, st) {
    debugPrint('❌ Exception in post Generate PaymentIntents: $e');
    debugPrint('🧭 StackTrace:\n$st');
    // ✅ rethrow เพื่อให้ caller (_renewQrAndReload) เห็น exception จริง
    // และแสดง popup พร้อม endpoint URL + status + error detail
    rethrow;
  }
}

Future<http.Response?> getDetailsPaymentIntents({
  required String cusNo,
  required String propertyNo,
  required String intentsUuid,
}) async {
  try {
    final headers = await MyHeadersIntents.build();
    final url = Uri.parse(
        '${MyconfigIntents().domainIntents}/v1/payment/intent/${intentsUuid}');

    final response = await http.get(
      url,
      headers: {
        ...headers,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    try {
      debugPrint(
        '❌ get Details PaymentIntents Failed [${response.statusCode}]: ${jsonDecode(response.body)}',
      );
    } catch (_) {
      debugPrint(
        '❌ get Details PaymentIntents Failed [${response.statusCode}]: ${response.body}',
      );
    }

    return response;
  } catch (e, st) {
    debugPrint('❌ Exception in get Details PaymentIntents: $e');
    debugPrint('🧭 StackTrace:\n$st');
    return null;
  }
}

Future<http.Response?> getSlipPreviewPaymentIntents({
  // required String cusNo,
  // required String propertyNo,
  required String slipUuid,
}) async {
  try {
    final headers = await MyHeadersIntents.build();
    final url = Uri.parse(
        '${MyconfigIntents().domainIntents}/v1/payment/intent/upload/${slipUuid}/preview');
    print(url);
    final response = await http.get(
      url,
      headers: {
        ...headers,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    try {
      debugPrint(
        '❌ get SlipPreview PaymentIntents Failed [${response.statusCode}]: ${jsonDecode(response.body)}',
      );
    } catch (_) {
      debugPrint(
        '❌ get SlipPreview PaymentIntents Failed [${response.statusCode}]: ${response.body}',
      );
    }

    return response;
  } catch (e, st) {
    debugPrint('❌ Exception in get SlipPreview PaymentIntents: $e');
    debugPrint('🧭 StackTrace:\n$st');
    return null;
  }
}

/// Get customer JWT token from payment API
/// Call this after login with customer_no (16-bit format)
Future<String?> getCustomerToken({
  required String customerNo,
  required String propertyNo,
}) async {
  // ✅ ห้ามยิง API เส้นนี้ถ้า _hasIntentsAuth ไม่เท่ากับ true
  // เพื่อป้องกัน browser เด้ง popup Basic Auth (Sign in)
  if (MyHeadersIntents.hasIntentsAuth != true) {
    debugPrint(
        '🚫 getCustomerToken: _hasIntentsAuth != true → skip API to pay-api.chaoperties.com');
    return null;
  }

  try {
    final url = Uri.parse(
      '${MyconfigIntents().domainIntents}/v1/payment/customer-token',
    );

    // Use pay_encoded64 as Basic Auth (from ApiSession or SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('pay_encoded64') ?? '';
    // Treat literal "null" string as empty (from legacy null.toString() saves)
    final payEncoded64 = (raw == 'null') ? '' : raw;

    if (payEncoded64.isEmpty) {
      debugPrint(
          '❌ pay_encoded64 not found / null in SharedPreferences — user may not have payment credentials set in DB');
      MyHeadersIntents.hasIntentsAuth = false;
      return null;
    }

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-Nonce-Id': const Uuid().v4(),
      'Authorization': 'Basic $payEncoded64',
    };

    final body = jsonEncode({
      'customer_no': customerNo,
    });

    debugPrint('POST getCustomerToken: $url');
    debugPrint('Body: $body');

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['token'] != null) {
        final token = data['token'] as String;
        // Store token in ApiSession for subsequent API calls
        await ApiSession.setBearerToken(token);
        debugPrint('✅ Customer token obtained and saved');
        return token;
      } else {
        debugPrint(
            '❌ getCustomerToken API returned success=false: ${data['message']}');
        return null;
      }
    } else {
      debugPrint(
        '❌ getCustomerToken Failed [${response.statusCode}]: ${response.body}',
      );
      return null;
    }
  } catch (e, st) {
    debugPrint('❌ Exception in getCustomerToken: $e');
    debugPrint('🧭 StackTrace:\n$st');
    return null;
  }
}
