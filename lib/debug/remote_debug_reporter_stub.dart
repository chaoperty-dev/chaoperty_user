Future<void> reportRemoteDebugError({
  required String endpoint,
  required String source,
  required String error,
  required String stackTrace,
}) async {}

String currentDebugPageUrl() => Uri.base.toString();
