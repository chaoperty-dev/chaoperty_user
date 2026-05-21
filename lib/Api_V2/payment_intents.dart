import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../Constant/Myconstant.dart';
import 'MyHeaders.dart';

Future<http.Response?> getPaymentIntents({
  required String cusno,
  required String bankMerchantId,
}) async {
  final headers = await MyHeaders.build();
  final base = '${MyConstantV2().domainV1}/payment-intents';
  final url = Uri.parse(base).replace(queryParameters: {
    'customer_no': cusno, // ✅ ส่งเป็น query string
    'bank_merchant_id': bankMerchantId, // ✅ ส่งเป็น query string
  });

  // debug
  print('GET getPaymentIntents : $url');
  // print('Headers: $headers');

  try {
    final response = await http.get(url, headers: headers);

    // 200–299 ถือว่าสำเร็จ
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // print('✅ PaymentIntents Success: ${response.body}');
      return response;
    } else {
      // พยายาม decode ถ้าเป็น JSON
      try {
        final respJson = jsonDecode(response.body);
        print('❌ PaymentIntents Failed [${response.statusCode}]: $respJson');
      } catch (_) {
        print(
            '❌ PaymentIntents Failed [${response.statusCode}]: ${response.body}');
      }
      return response;
    }
  } catch (e, stack) {
    print('❌ Exception in GET PaymentIntents: $e');
    print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> getPaymentIntentsCanceled({
  required String cusno,
  // required String bankMerchantId,
}) async {
  final headers = await MyHeaders.build();
  final base = '${MyConstantV2().domainV1}/payment-intents/canceled';
  final url = Uri.parse(base).replace(queryParameters: {
    'customer_no': cusno, // ✅ ส่งเป็น query string
    // 'bank_merchant_id': bankMerchantId, // ✅ ส่งเป็น query string
  });

  // debug
  print('GET getPaymentIntents Canceled: $url');
  // print('Headers: $headers');

  try {
    final response = await http.get(url, headers: headers);

    // 200–299 ถือว่าสำเร็จ
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ PaymentIntents Canceled Success: ${response.body}');
      return response;
    } else {
      // พยายาม decode ถ้าเป็น JSON
      try {
        final respJson = jsonDecode(response.body);
        print(
            '❌ PaymentIntents Canceled Failed [${response.statusCode}]: $respJson');
      } catch (_) {
        print(
            '❌ PaymentIntents Canceled Failed [${response.statusCode}]: ${response.body}');
      }
      return response;
    }
  } catch (e, stack) {
    print('❌ Exception in GET PaymentIntents Canceled: $e');
    print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> PatchPaymentIntents_UuidCanceled({
  // required String cusno,
  required String intentsUuid,
}) async {
  final headers = await MyHeaders.build();
  final base = '${MyConstantV2().domainV1}/payment-intents/$intentsUuid/cancel';
  final url = Uri.parse(base);

  // debug
  print('Patch getPaymentIntents Uuid Canceled: $url');
  // print('Headers: $headers');

  try {
    final response = await http.patch(url, headers: headers);

    // 200–299 ถือว่าสำเร็จ
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ PaymentIntents Uuid Canceled Success: ${response.body}');
      return response;
    } else {
      // พยายาม decode ถ้าเป็น JSON
      try {
        final respJson = jsonDecode(response.body);
        print(
            '❌ PaymentIntents Uuid Canceled Failed [${response.statusCode}]: $respJson');
      } catch (_) {
        print(
            '❌ PaymentIntents Uuid Canceled Failed [${response.statusCode}]: ${response.body}');
      }
      return response;
    }
  } catch (e, stack) {
    print('❌ Exception in Patch PaymentIntents Uuid Canceled: $e');
    print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> getPaymentIntentsUuid({
  required String cusno, // ถ้าไม่ใช้จะลบทิ้งก็ได้
  required String intentsUuid,
}) async {
  if (intentsUuid.isEmpty) {
    debugPrint('❌ intentsUuid ว่าง');
    return null;
  }

  try {
    final headers = await MyHeaders.build();
    final base = '${MyConstantV2().domainV1}/payment-intents/$intentsUuid';
    final url = Uri.parse(base);

    debugPrint('GET getPaymentIntents Uuid: $url');

    final response = await http.get(url, headers: headers);

    // 200–299 = success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    // error log
    try {
      debugPrint(
          '❌ PaymentIntents Failed [${response.statusCode}]: ${jsonDecode(response.body)}');
    } catch (_) {
      debugPrint(
          '❌ PaymentIntents Failed [${response.statusCode}]: ${response.body}');
    }
    return response;
  } catch (e, st) {
    debugPrint('❌ Exception in GET PaymentIntents Uuid: $e');
    debugPrint('🧭 StackTrace:\n$st');
    return null;
  }
}

Future<http.Response?> postPaymentIntents({
  required String cusNo,
  required int bankMerchantId,
  required int bankMerchantType,
  required String chanNel,
  required double requestedAmount,
  required String createdById,
  required List<Map<String, dynamic>> inVoices,
}) async {
  final headers = await MyHeaders.build();
  final url = Uri.parse('${MyConstantV2().domainV1}/payment-intents');

  print('POST $url');
  print('Headers: $headers');
  print('📦 Body: ${jsonEncode({
        "customer_no": cusNo,
        "bank_merchant_id": bankMerchantId,
        "bank_merchant_type": bankMerchantType,
        "created_by_id": createdById,
        "channel": chanNel,
        "requested_amount": requestedAmount,
        "invoices": inVoices,
      })}');

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        "customer_no": cusNo,
        "bank_merchant_id": bankMerchantId,
        "created_by_id": createdById,
        "channel": chanNel,
        "requested_amount": requestedAmount,
        "invoices": inVoices,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ POST PaymentIntents Success: ${response.body}');
      return response;
    } else {
      try {
        final respJson = jsonDecode(response.body);
        print(
            '❌ POST PaymentIntents Failed [${response.statusCode}]: $respJson');
      } catch (_) {
        print(
            '❌ POST PaymentIntents Failed [${response.statusCode}]: ${response.body}');
      }
      return response;
    }
  } catch (e, stack) {
    print('❌ Exception in POST PaymentIntents: $e');
    print('🧭 StackTrace:\n$stack');
    return null;
  }
}
