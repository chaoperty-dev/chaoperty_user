// Web-only — returns localStorage keys
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<List<String>> debugGetLocalStorageKeys() async {
  final ls = html.window.localStorage;
  final keys = <String>[];
  try {
    // dart:html Storage ไม่มี method .key()/.length โดยตรง
    // ใช้ [] operator ดึง key จาก entries ทั้งหมด
    // วิธีที่ปลอดภัยกว่าคือใช้ dart:js_interop หรือ package:web
    // แต่เพื่อ debug เร็วๆ ใช้ entries ผ่าน _keys
    // ignore: implicit_dynamic_function
    for (final k in _localStorageKeys(ls)) {
      keys.add(k);
    }
  } catch (_) {}
  return keys;
}

Iterable<String> _localStorageKeys(html.Storage ls) sync* {
  // dart:html Storage ไม่มี key(i), ใช้ entries iteration via _keys
  // fallback: ใช้ known keys ที่ SharedPreferences 2.x ใช้
  for (final k in <String>[
    'flutter.custno',
    'flutter.pass_word',
    'flutter.UsernameUSer',
    'flutter.renTalSer',
    'flutter.renTalName',
    'flutter.api_bearer_token',
    'flutter.api_nonce_id',
  ]) {
    if (ls[k] != null) yield k;
  }
}
