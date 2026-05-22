import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../Constant/Myconstant.dart';
import '../../Constant/api_session.dart';
import '../../Constant/global_http.dart';

class MyHeadersIntents {
  MyHeadersIntents._(); // private constructor

  /// Build headers for Payment API v1
  /// Always refreshes token before making API calls
  static Future<Map<String, String>> build() async {
    final uuid = const Uuid().v4();

    // Always refresh token to ensure it's valid
    debugPrint('🔑 Refreshing token before API call...');
    final token = await _refreshCustomerToken() ?? ApiSession.bearerToken;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-Nonce-Id': uuid,
      'Authorization': 'Bearer $token',
    };
  }

  /// Refresh customer token from API
  static Future<String?> _refreshCustomerToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payEncoded64 = prefs.getString('pay_encoded64') ?? '';
      final custno = prefs.getString('custno') ?? '';
      final ren = prefs.getString('renTalSer') ?? '';

      if (payEncoded64.isEmpty || custno.isEmpty || ren.isEmpty) {
        debugPrint('❌ Cannot refresh token: missing credentials');
        return null;
      }

      // Keep raw custno as-is (preserve leading zeros)
      final customerNo16 = custno.trim();

      final url = Uri.parse(
        '${MyconfigIntents().domainIntents}/v1/payment/customer-token',
      );

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Nonce-Id': const Uuid().v4(),
          'Authorization': 'Basic $payEncoded64',
        },
        body: jsonEncode({'customer_no': customerNo16}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['token'] != null) {
          final token = data['token'] as String;
          await ApiSession.setBearerToken(token);
          debugPrint('✅ Token refreshed successfully');
          return token;
        }
      }

      debugPrint('❌ Failed to refresh token: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('❌ Exception refreshing token: $e');
      return null;
    }
  }
}

// class MyHeadersIntents {
//   static Future<Map<String, String>> build() async {
//     // final token = await MyToken.accessToken;

//     // gen uuid v4 ใหม่ทุกครั้งที่เรียก build()
//     final uuid = const Uuid().v4();

//     return {
//       'X-Tenant': 'rser-0',
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//       'uuid': uuid,
//       ...Security.generateAuthHeaders(),
//       // 'Authorization': 'Bearer $token',
//     };
//   }
// }

class MyconfigIntents {
  var domainIntents = 'http://192.168.1.89:3004/api';
}
