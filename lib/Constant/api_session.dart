import 'package:shared_preferences/shared_preferences.dart';

class ApiSession {
  static String _bearerToken = '';
  static String _nonceId = '';
  static bool _isInitialized = false;

  static String get bearerToken => _bearerToken;
  static String get nonceId => _nonceId;

  /// Initialize and load saved tokens from SharedPreferences
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _bearerToken = prefs.getString('api_bearer_token') ?? '';
    _nonceId = prefs.getString('api_nonce_id') ?? '';
    _isInitialized = true;
  }

  /// Set bearer token and save to SharedPreferences automatically
  static Future<void> setBearerToken(String token) async {
    _bearerToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_bearer_token', token);
  }

  /// Set nonce ID and save to SharedPreferences automatically
  static Future<void> setNonceId(String nonce) async {
    _nonceId = nonce;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_nonce_id', nonce);
  }

  /// Clear tokens from memory and SharedPreferences
  static Future<void> clear() async {
    _bearerToken = '';
    _nonceId = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_bearer_token');
    await prefs.remove('api_nonce_id');
  }

  /// Reset static fields without touching SharedPreferences
  /// (ใช้ตอน logout เพื่อเคลียร์ memory cache ทันที)
  static void reset() {
    _bearerToken = '';
    _nonceId = '';
    _isInitialized = false;
  }

  /// Check if token exists
  static bool get hasToken => _bearerToken.isNotEmpty;
}
