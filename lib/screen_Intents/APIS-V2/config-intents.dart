import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

import '../../Constant/Myconstant.dart';
import '../../Constant/api_session.dart';
import '../../Constant/global_http.dart';

///
/// ✅ Global gate for pay-api.chaoperties.com API calls.
/// When `_hasIntentsAuth != true`, the API must NOT be called —
/// otherwise the server returns 401 and the browser pops up the
/// "Sign in" Basic Auth dialog (see screenshot).
///
/// Set by [MyHeadersIntents.checkauthpaymentintents].
/// Read by [MyHeadersIntents.build] and [getCustomerToken].
/// Exposed via [MyHeadersIntents.hasIntentsAuth] getter/setter for external use.
///
bool? _hasIntentsAuth;

class MyHeadersIntents {
  MyHeadersIntents._(); // private constructor

  /// ✅ Public getter/setter so external files (e.g. payment-intents.dart)
  /// can read AND write the private top-level [_hasIntentsAuth] flag.
  static bool? get hasIntentsAuth => _hasIntentsAuth;
  static set hasIntentsAuth(bool? value) => _hasIntentsAuth = value;

  /// Build headers for Payment API v1
  /// Always refreshes token before making API calls
  ///
  static Future<bool> checkauthpaymentintents() async {
    final prefs = await SharedPreferences.getInstance();
    final ren = prefs.getString('renTalSer') ?? '';
    final payEncoded64 = prefs.getString('pay_encoded64') ?? '';
    final custno = prefs.getString('custno') ?? '';

    // ✅ ห้ามยิง API ไปที่ pay-api.chaoperties.com ถ้าเงื่อนไขไม่ครบ
    // เพราะถ้ายิงแล้ว server จะตอบ 401 → browser เด้ง popup Basic Auth
    if (ren.toString() != '146' && ren.toString() != '148') {
      _hasIntentsAuth = false;
      debugPrint(
          '🚫 checkauthpaymentintents: ren=$ren is not 146/148 → skip API');
      return false;
    }
    if (payEncoded64.isEmpty || payEncoded64 == 'null' || custno.isEmpty) {
      _hasIntentsAuth = false;
      debugPrint(
          '🚫 checkauthpaymentintents: missing pay_encoded64/custno → skip API');
      return false;
    }

    // ✅ เงื่อนไขครบ ค่อยเรียก API จริง
    final token = await _refreshCustomerToken() ?? ApiSession.bearerToken;
    _hasIntentsAuth = token.isNotEmpty;
    debugPrint('🔐 checkauthpaymentintents: _hasIntentsAuth=$_hasIntentsAuth');
    return _hasIntentsAuth == true;
  }

  static Future<Map<String, String>> build() async {
    // ✅ ห้ามยิง API ถ้า _hasIntentsAuth ไม่เท่ากับ true
    // เพื่อป้องกัน browser เด้ง popup Basic Auth (Sign in)
    if (_hasIntentsAuth != true) {
      debugPrint(
          '🚫 MyHeadersIntents.build: _hasIntentsAuth != true → return empty headers');
      return <String, String>{};
    }

    final uuid = const Uuid().v4();

    // Always refresh token to ensure it's valid
    debugPrint('🔑 Refreshing token before API call...');
    final token = await _refreshCustomerToken() ?? ApiSession.bearerToken;
    debugPrint('🔑 MyHeadersIntents.build() - Token length: ${token.length}');
    debugPrint(
        '🔑 Token starts with: ${token.isNotEmpty ? token.substring(0, min(50, token.length)) : "EMPTY"}...');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-Nonce-Id': uuid,
      'Authorization': 'Bearer $token',
    };

    debugPrint('📤 Headers: $headers');
    return headers;
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
        _hasIntentsAuth = false;
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
      _hasIntentsAuth = false;
      return null;
    } catch (e) {
      debugPrint('❌ Exception refreshing token: $e');
      _hasIntentsAuth = false;
      return null;
    }
  }
}

int min(int a, int b) => a < b ? a : b;

class MyHeadersIntents2 {
  MyHeadersIntents2._(); // private constructor

  static Future<Map<String, String>> build() async {
    return {
      'X-Tenant': 'rser-0',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-NONCE-ID': ApiSession.nonceId,
      ...Security.generateAuthHeaders(),
      'Authorization': 'Bearer ${ApiSession.bearerToken}',
    };
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
//  ;
// }

class MyconfigIntents {
  var domainIntents = 'https://pay-api.chaoperties.com/api';

  // 'https://pay-stg-api.chaoperties.com/api';
  // var domainIntents = 'http://192.168.1.89:3004/api';
}
