class MyHeaders {
  static Future<Map<String, String>> build() async {
    // final token = await MyToken.accessToken;
    return {
      'X-Tenant': 'rser-0',
      'Accept': 'application/json',
      'Content-Type': 'application/json'
      // 'Authorization': 'Bearer $token',
    };
  }
}

class MyConstantV2 {
  var domainV1 = 'http://192.168.1.89:3000/api/v1';
}
