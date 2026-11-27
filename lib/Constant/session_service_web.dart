// Web-only — clears all localStorage + sessionStorage keys
// that start with "flutter." or "line_" (ที่ใช้ในโปรเจกต์นี้)
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show debugPrint;

/// List ของ key ที่ SharedPreferences ของ Flutter web ใช้
/// ใช้ลบทีละตัวเพราะ dart:html Storage ไม่มี method key(i)
const List<String> _knownSharedPreferencesKeys = <String>[
  // SharedPreferences 2.x จะเก็บเป็น "flutter." + key
  'flutter.custno',
  'flutter.lang',
  'flutter.renTalSer',
  'flutter.renTalName',
  'flutter.renTal_logo',
  'flutter.lintid',
  'flutter.ser',
  'flutter.cname',
  'flutter.sname',
  'flutter.email',
  'flutter.photo',
  'flutter.address',
  'flutter.contact',
  'flutter.stype',
  'flutter.tel',
  'flutter.tax',
  'flutter.foder',
  'flutter.pass_word',
  'flutter.UsernameUSer',
  'flutter.pay_token',
  'flutter.pay_encoded64',
  'flutter.fid',
  'flutter.api_bearer_token',
  'flutter.api_nonce_id',
  'flutter.Date_Login',
  'flutter.usercid',
  'flutter.qutser',
  'flutter.Tabpaid',
  'flutter.payby',
  'flutter.imageData',
  'flutter.imageBG',
  'flutter.imageLG',
  // LINE OAuth scratch
  'line_processing_code',
  'line_code_verifier',
];

Future<void> clearWebStorage() async {
  try {
    // 1) Clear localStorage
    final ls = html.window.localStorage;
    int removed = 0;
    for (final k in _knownSharedPreferencesKeys) {
      try {
        if (ls.containsKey(k)) {
          ls.remove(k);
          removed++;
        }
      } catch (_) {}
    }

    // 2) Clear sessionStorage (ลบทั้งหมดเพราะไม่มีข้อมูลสำคัญ)
    try {
      final ss = html.window.sessionStorage;
      ss.clear();
      debugPrint('🧹 [Web] Cleared sessionStorage (all keys)');
    } catch (_) {}

    debugPrint('🧹 [Web] Cleared localStorage ($removed keys)');
  } catch (e) {
    debugPrint('⚠️ [Web] clearWebStorage error: $e');
  }
}
