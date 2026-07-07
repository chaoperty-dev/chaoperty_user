import 'package:flutter/foundation.dart'
    show kIsWeb, debugPrint, ChangeNotifier;
// Conditional import for web-only localStorage clearing
import 'session_service_stub.dart'
    if (dart.library.html) 'session_service_web.dart' as platform;

import 'package:shared_preferences/shared_preferences.dart';

import '../Constant/api_session.dart';
import '../Constant/app_markets.dart';

/// Service สำหรับ clear session ทั้งหมดเมื่อ logout
/// - Clear SharedPreferences ทั้งหมด
/// - Clear ApiSession tokens
/// - Clear AppMarkets cache
/// - Clear web localStorage (ถ้าเป็น web) - ลบเฉพาะ key ที่ขึ้นต้นด้วย "flutter."
/// - Clear sessionStorage
class SessionService {
  /// List ของ key ที่ต้องลบเพิ่มเติม (ที่ SharedPreferences.clear() อาจไม่ลบ)
  /// เพื่อให้แน่ใจว่าแม้ SharedPreferences มี bug ก็ยังลบข้อมูลครบ
  static const List<String> _allKnownKeys = <String>[
    'custno',
    'lang',
    'renTalSer',
    'renTalName',
    'renTal_logo',
    'lintid',
    'ser',
    'cname',
    'sname',
    'email',
    'photo',
    'address',
    'contact',
    'stype',
    'tel',
    'tax',
    'foder',
    'pass_word',
    'UsernameUSer',
    'pay_token',
    'pay_encoded64',
    'fid',
    'api_bearer_token',
    'api_nonce_id',
    'Date_Login',
    'usercid',
    'qutser',
    'Tabpaid',
    'payby',
    // bot settings cache
    'imageData',
    'imageBG',
    'imageLG',
  ];

  /// Clear ทุกอย่างที่เกี่ยวกับ user session
  static Future<void> clearAll({List<ChangeNotifier>? providers}) async {
    debugPrint('🧹 [SessionService] Clearing all session data...');

    try {
      // 1) Clear SharedPreferences (ทุก key)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 2) ลบ keys ที่อาจตกค้างด้วย remove() ทีละตัว (defensive)
      for (final k in _allKnownKeys) {
        try {
          await prefs.remove(k);
        } catch (_) {}
      }

      // 3) Clear ApiSession tokens
      try {
        await ApiSession.clear();
        ApiSession.reset(); // reset static fields
      } catch (e) {
        debugPrint('⚠️ ApiSession clear error: $e');
      }

      // 4) Clear AppMarkets cache (memory)
      try {
        AppMarkets.markets.clear();
      } catch (_) {}

      // 5) Reset Provider state (ถ้าส่งมา)
      if (providers != null) {
        for (final p in providers) {
          try {
            // dynamic call: provider.reset()
            (p as dynamic).reset();
          } catch (e) {
            debugPrint('⚠️ Provider reset error ($p): $e');
          }
        }
      }

      // 6) Web-only: clear localStorage + sessionStorage
      try {
        await platform.clearWebStorage();
      } catch (e) {
        debugPrint('⚠️ Web storage clear error: $e');
      }

      // 7) Verify by reading back
      final afterClear = await SharedPreferences.getInstance();
      final remaining = <String>[];
      for (final k in afterClear.getKeys()) {
        remaining.add(k);
      }
      debugPrint(
          '🧹 [SessionService] Done. Remaining keys (${remaining.length}): $remaining');
    } catch (e, st) {
      debugPrint('❌ [SessionService] clearAll error: $e');
      debugPrint('$st');
    }
  }
}
