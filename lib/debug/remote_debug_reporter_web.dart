import 'dart:convert';
import 'dart:html' as html;

Future<void> reportRemoteDebugError({
  required String endpoint,
  required String source,
  required String error,
  required String stackTrace,
}) async {
  try {
    await html.HttpRequest.request(
      endpoint,
      method: 'POST',
      sendData: jsonEncode({
        'time': DateTime.now().toIso8601String(),
        'source': source,
        'error': error,
        'stack': stackTrace,
        'url': currentDebugPageUrl(),
        'userAgent': html.window.navigator.userAgent,
      }),
    );
  } catch (_) {}
}

String currentDebugPageUrl() {
  try {
    return Uri.decodeFull(html.window.location.href);
  } catch (_) {
    return Uri.base.toString();
  }
}
