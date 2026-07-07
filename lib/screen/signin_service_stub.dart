// Stub for non-web platforms — returns null (no localStorage)
Future<List<String>> debugGetLocalStorageKeys() async {
  return <String>[];
}
