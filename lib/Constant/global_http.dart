import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_session.dart';

class Security {
  /// ต้องตรงกับฝั่ง PHP / Backend
  static const String secret =
      "8Tdsq2MO8PucYOmcdTG1mJYqvJ4yEJYG6hyQrbw2nzffLoZcRy74Zy82Idc72alz";

  /// php serialize (เลียนแบบ PHP serialize())
  static String phpSerialize(dynamic data) {
    if (data == null) return 'N;';

    if (data is bool) {
      return 'b:${data ? 1 : 0};';
    }

    if (data is int) {
      return 'i:$data;';
    }

    if (data is double) {
      return 'd:$data;';
    }

    if (data is String) {
      final length = utf8.encode(data).length;
      return 's:$length:"$data";';
    }

    if (data is List) {
      final buffer = StringBuffer();
      buffer.write('a:${data.length}:{');
      for (var i = 0; i < data.length; i++) {
        buffer.write('i:$i;'); // PHP array index
        buffer.write(phpSerialize(data[i]));
      }
      buffer.write('}');
      return buffer.toString();
    }

    if (data is Map<String, dynamic>) {
      final buffer = StringBuffer();
      buffer.write('a:${data.length}:{');
      data.forEach((key, value) {
        final keyLen = utf8.encode(key).length;
        buffer.write('s:$keyLen:"$key";');
        buffer.write(phpSerialize(value));
      });
      buffer.write('}');
      return buffer.toString();
    }

    throw UnsupportedError("Cannot serialize type ${data.runtimeType}");
  }

  /// ใช้สำหรับสร้าง header พวก timestamp + hmac จาก timestamp
  static Map<String, String> generateAuthHeaders() {
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    final hmac = Hmac(sha256, utf8.encode(secret));
    final clientHash = hmac.convert(utf8.encode(timestamp)).toString();

    return {
      'X-TIMESTAMP': timestamp,
      'X-TAPI': clientHash, // OK แล้ว ใช้ key นี้เป็น HMAC timestamp
    };
  }

  /// ใช้ sign ตัว payload (bodyData) ทั้งก้อน ด้วย HMAC-SHA256
  // static String buildHmacSignature({
  //   required String timestamp,
  //   required Map<String, dynamic> bodyData,
  //   required String uuid,
  // }) {
  //   final payload = timestamp + jsonEncode(bodyData) + uuid;
  //   final key = utf8.encode(secret);
  //   final bytes = utf8.encode(payload);
  //   final hmacSha256 = Hmac(sha256, key);
  //   return hmacSha256.convert(bytes).toString();
  // }
  static String buildHmacSignature({
    required String timestamp,
    required String ebody,
    required String uuid,
  }) {
    final content =
        timestamp + ebody + uuid; // ให้ตรงกับ PHP: $timestamp . $ebody . $nonce
    final key = utf8.encode(secret);
    final bytes = utf8.encode(content);
    final hmacSha256 = Hmac(sha256, key);
    return hmacSha256.convert(bytes).toString();
  }

  static String buildHmacdatafid({
    required dynamic Data,
  }) {
    final payload = jsonEncode(Data);
    final key = utf8.encode(secret);
    final bytes = utf8.encode(payload);
    final hmacSha256 = Hmac(sha256, key);
    return hmacSha256.convert(bytes).toString();
  }

  /// idempotency key : sha1(customerNo + serialize(keyData))
  static String idempotencyKey({
    required String customerNo,
    required Map<String, dynamic> keyData,
  }) {
    final serialized = phpSerialize(keyData); // ✅ เรียก static ได้แล้ว
    final raw = customerNo + serialized;
    final bytes = utf8.encode(raw);
    return sha1.convert(bytes).toString();
  }
}

/////------------------------------------------------>
class GlobalHttp extends http.BaseClient {
  final http.Client _inner = http.Client();

  static const String _secretKey = "YOUR_SECRET_KEY_HERE";

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    final hmacSha256 = Hmac(sha256, utf8.encode(_secretKey));
    final clientHash = hmacSha256.convert(utf8.encode(timestamp)).toString();

    request.headers['Content-Type'] =
        request.headers['Content-Type'] ?? 'application/json; charset=utf-8';
    request.headers['Accept'] = 'application/json';
    request.headers['X-TIMESTAMP'] = timestamp;
    request.headers['X-API-KEY'] = clientHash;

    if (ApiSession.bearerToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer ${ApiSession.bearerToken}';
    }
    if (ApiSession.nonceId.isNotEmpty) {
      request.headers['X-Nonce-Id'] = ApiSession.nonceId;
    }

    return _inner.send(request);
  }
}

final http.Client httpClient = GlobalHttp();

// const String passphrase = 'my106';

// encrypt.Key _deriveKey(String passphrase) {
//   final bytes = utf8.encode(passphrase);
//   final hash = sha256.convert(bytes).bytes; // 32 bytes
//   return encrypt.Key(Uint8List.fromList(hash));
// }

// encrypt.IV _randomIv() {
//   final rnd = Random.secure();
//   return encrypt.IV(
//     Uint8List.fromList(
//       List<int>.generate(16, (_) => rnd.nextInt(256)),
//     ),
//   );
// }

// /// เข้ารหัส -> base64(iv + cipher)
// String encryptText(String plainText) {
//   final key = _deriveKey(passphrase);
//   final iv = _randomIv();

//   final aes = encrypt.Encrypter(
//     encrypt.AES(
//       key,
//       mode: encrypt.AESMode.cbc,
//       padding: 'PKCS7',
//     ),
//   );

//   final encrypted = aes.encrypt(plainText, iv: iv);

//   final raw = <int>[]
//     ..addAll(iv.bytes)
//     ..addAll(encrypted.bytes);

//   return base64Encode(raw);
// }

// /// ถอดรหัส base64(iv + cipher) -> ข้อความ
// String decryptText(String base64Input) {
//   final key = _deriveKey(passphrase);
//   final raw = base64Decode(base64Input);

//   if (raw.length < 17) return '';

//   final ivBytes = raw.sublist(0, 16);
//   final ctBytes = raw.sublist(16);

//   final iv = encrypt.IV(Uint8List.fromList(ivBytes));
//   final ct = encrypt.Encrypted(Uint8List.fromList(ctBytes));

//   final aes = encrypt.Encrypter(
//     encrypt.AES(
//       key,
//       mode: encrypt.AESMode.cbc,
//       padding: 'PKCS7',
//     ),
//   );

//   return aes.decrypt(ct, iv: iv);
// }

// ENCRYPTION FUNCTIONS DISABLED - encrypt package was removed due to dependency conflicts

/////------------------------------------------------>
///
///
// class GlobalHttp extends http.BaseClient {
//   final http.Client _inner = http.Client();

//   // secret ต้องตรงกับ PHP: define("API_KEY", "YOUR_SECRET_KEY_HERE");
//   static const String _secretKey = "YOUR_SECRET_KEY_HERE";

//   @override
//   Future<http.StreamedResponse> send(http.BaseRequest request) async {
//     // 1) สร้าง timestamp ใหม่ทุกครั้ง (วินาที)
//     final timestamp =
//         (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

//     // 2) สร้าง HMAC SHA256 ด้วย secret เดียวกัน
//     final hmacSha256 = Hmac(sha256, utf8.encode(_secretKey));
//     final clientHash = hmacSha256.convert(utf8.encode(timestamp)).toString();

//     // 3) ใส่ headers ให้ตรงกับฝั่ง PHP
//     request.headers['Content-Type'] ??= 'application/json';
//     request.headers['TIMESTAMP'] = timestamp;
//     request.headers['API_KEY'] = clientHash;

//     // ถ้ามี header อื่นที่ user ใส่มาก่อน ก็ยังอยู่เหมือนเดิม
//     return _inner.send(request);
//   }
// }

  // String apiSecret = 'YOUR_SECRET_KEY_HERE'; // ต้องตรงกับ PHP API_KEY

  // Future<void> securePost() async {
  //   // 1) สร้าง timestamp (วินาที)
  //   final timestamp =
  //       (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

  //   // 2) สร้าง HMAC SHA256 ด้วย secret เดียวกัน
  //   final hmacSha256 = Hmac(sha256, utf8.encode(apiSecret));
  //   final clientHash = hmacSha256.convert(utf8.encode(timestamp)).toString();

  //   // 3) สร้าง headers ที่ถูกต้อง
  //   final headers = {
  //     "Content-Type": "application/json",
  //     "TIMESTAMP": timestamp,
  //     "API_KEY": clientHash,
  //   };

  //   print('headers = $headers');

  //   final url = Uri.parse(
  //     'http://192.168.1.227/chao_api/GC_user.php?isAdd=true&email=T_T@gmail.com',
  //   );

  //   // 4) ใช้ headers ตัวนี้จริง ๆ
  //   final response = await http.get(
  //     url,
  //     headers: headers,
  //   );

  //   print('statusCode = ${response.statusCode}');
  //   print('body = ${response.body}');
  // }
