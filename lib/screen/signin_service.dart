// lib/screen/signin_service.dart
// Conditional imports: ใช้ dart:html บน web, ใช้ stub บน mobile
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Constant/Myconstant.dart';
import '../Constant/app_markets.dart';
import '../Model/GetC_regis_Model.dart';
import 'Screen_new/fitness_app_home_screen.dart';
import 'market_select_screen.dart';
import 'market_service.dart';
import 'signin_service_stub.dart'
    if (dart.library.html) 'signin_service_web.dart' as platform;

/// ตรวจสอบว่า string เป็น MD5 hash (32 hex chars) หรือไม่
bool _looksLikeMd5(String s) {
  final t = s.trim();
  if (t.length != 32) return false;
  return RegExp(r'^[0-9a-fA-F]{32}$').hasMatch(t);
}

/// Hash password เป็น MD5 (UTF-8)
String _toMd5(String plain) => md5.convert(utf8.encode(plain)).toString();

/// ผลลัพธ์จากการตรวจสอบ session ที่บันทึกไว้
/// - [destination] = Widget ปลายทางที่จะเปิด (Home) หรือ null ถ้า validate ไม่ผ่าน
/// - [requiresMarketSelection] = true ถ้าผู้ใช้มีหลายตลาด ต้องเปิด MarketSelectScreen
/// - [validMarkets] = รายชื่อตลาดที่ valid (กรณี requiresMarketSelection = true)
/// - [errorMessage] = ข้อความ error (กรณี validate ไม่ผ่าน)
class SignInResult {
  final Widget? destination;
  final bool requiresMarketSelection;
  final List<c_regis_Model> validMarkets;
  final String? errorMessage;

  const SignInResult._({
    this.destination,
    this.requiresMarketSelection = false,
    this.validMarkets = const <c_regis_Model>[],
    this.errorMessage,
  });

  /// กรณีที่ต้องไปหน้าใดหน้าหนึ่งโดยตรง (home)
  factory SignInResult.goTo(Widget page) => SignInResult._(destination: page);

  /// กรณีที่ผู้ใช้มีหลายตลาด ต้องเปิดหน้าเลือกตลาด
  factory SignInResult.marketSelection(List<c_regis_Model> markets) =>
      SignInResult._(
        requiresMarketSelection: true,
        validMarkets: markets,
      );

  /// กรณี login ไม่ผ่าน (session หมดอายุ / credentials เปลี่ยน)
  /// destination = null หมายถึงให้ผู้เรียกเปิด LoginScreen
  factory SignInResult.failure(String message) =>
      SignInResult._(errorMessage: message);
}

/// Service สำหรับตรวจสอบ session ของผู้ใช้
/// - ใช้ได้ทั้งตอน login ปกติ และตอนที่ผู้ใช้รีเฟรชหน้าเว็บ (browser refresh)
/// - เลียนแบบ signInThread() ใน loginscreen.dart
class SignInService {
  /// ตรวจสอบ username/password ที่บันทึกไว้ใน SharedPreferences
  /// แล้วคืนค่า SignInResult เพื่อบอกว่าควรไปหน้าไหน
  ///
  /// ลำดับการตัดสินใจ:
  ///   1. ไม่มี credentials ที่บันทึกไว้ -> failure (ไป LoginScreen)
  ///   2. Backend ตอบกลับมา 1 ตลาด  -> FitnessAppHomeScreen(custno)
  ///   3. Backend ตอบกลับมา > 1 ตลาด -> ให้ผู้เรียกเปิด MarketSelectScreen
  ///   4. Backend ตอบกลับมา 0 ตลาด / error -> failure (ไป LoginScreen)
  static Future<SignInResult> validateSavedSession() async {
    // ✅ Debug: แสดง localStorage keys ทั้งหมดเพื่อตรวจสอบว่า
    //    SharedPreferences เก็บข้อมูลลงที่ไหน (localStorage/IndexedDB)
    try {
      final keys = await platform.debugGetLocalStorageKeys();
      debugPrint('🔍 [AuthGate] localStorage keys (${keys.length}): $keys');
    } catch (e) {
      debugPrint('🔍 [AuthGate] localStorage debug error: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('UsernameUSer')?.trim() ?? '';
    final password = prefs.getString('pass_word')?.trim() ?? '';
    final savedCustno = prefs.getString('custno')?.trim() ?? '';

    // ไม่มี credentials ที่บันทึกไว้ -> ไปหน้า login
    if (username.isEmpty || password.isEmpty || savedCustno.isEmpty) {
      return SignInResult.failure('ไม่พบข้อมูลล็อกอินที่บันทึกไว้');
    }

    // เรียก backend ด้วย credentials ที่บันทึกไว้
    // (เลียนแบบ signInThread() แต่ไม่ต้องการ isLineOAuth/ser_Web)
    // ✅ ลองทั้ง 2 รูปแบบ: ค่าใน SharedPreferences เป็น MD5 hash หรือ plaintext
    final url = '${MyConstant().domain}/GC_user_loginV2.php';

    // ถ้า password เป็น plaintext (ไม่ใช่ MD5) → hash ก่อนส่ง
    // ถ้า password เป็น MD5 hash อยู่แล้ว → ส่งตรงๆ
    final passwordToSend =
        _looksLikeMd5(password) ? password : _toMd5(password);
    debugPrint(
        '🔑 [AuthGate] Trying password ${_looksLikeMd5(password) ? "(already MD5)" : "(plaintext → MD5)"}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({
          'isAdd': 'true',
          'username': username,
          'password': passwordToSend,
          'idtoken': '',
          'line_rser': '',
          'is_line_oauth': '0',
        }),
      );

      if (response.statusCode != 200) {
        return SignInResult.failure('Backend error: ${response.statusCode}');
      }

      final decoded = json.decode(response.body);
      final result = (decoded is List)
          ? decoded
          : (decoded is Map && decoded['status'] == true
              ? decoded['data']
              : null);

      if (result == null || result is! List || result.isEmpty) {
        debugPrint(
            '❌ [AuthGate] Empty result. statusCode=${response.statusCode}, body=${response.body.substring(0, response.body.length.clamp(0, 200))}');
        return SignInResult.failure('ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่');
      }

      // Parse models
      final allModels = result
          .map<c_regis_Model>((map) => c_regis_Model.fromJson(map))
          .toList();

      // เช็ค password (เลียนแบบ signInThread() สำหรับ normal login)
      final firstPasswd =
          allModels.isNotEmpty ? allModels.first.passwd ?? '' : '';
      // เทียบ password ที่ส่งจริง (MD5) กับที่ backend ส่งกลับ
      if (passwordToSend.trim() != firstPasswd.trim()) {
        return SignInResult.failure('Username & password ผิดพลาด');
      }

      // ✅ ตาม requirement: ถ้ามีหลายตลาด ต้องกลับไปหน้า MarketSelectScreen เสมอ
      // (ทั้งตอน login ใหม่ และตอนรีเฟรช)
      if (allModels.length > 1) {
        AppMarkets.markets = allModels;
        debugPrint(
            '🔀 [AuthGate] Multiple markets (${allModels.length}) — showing selection');
        return SignInResult.marketSelection(allModels);
      }

      // 1 ตลาด -> ไป FitnessAppHomeScreen ตรงๆ
      final m = allModels.first;
      return SignInResult.goTo(
        FitnessAppHomeScreen(custno_s: m.custno),
      );
    } catch (e) {
      return SignInResult.failure('เกิดข้อผิดพลาด: $e');
    }
  }

  /// สร้าง MarketSelectScreen พร้อม callback สำหรับ navigate หลังเลือกตลาด
  /// ใช้ในกรณี requiresMarketSelection = true
  ///
  /// [context] จำเป็นต้องใช้สำหรับให้ MarketService.applyMarket
  /// ทำ Navigator.pushAndRemoveUntil ไป FitnessAppHomeScreen ได้
  static Widget buildMarketSelectScreen(
      BuildContext context, List<c_regis_Model> markets) {
    return MarketSelectScreen(
      markets: markets,
      onSelect: (selected) => MarketService.applyMarket(context, selected),
    );
  }
}
