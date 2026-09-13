import 'dart:typed_data';

import 'payment_subv4_web_actions_stub.dart'
    if (dart.library.html) 'payment_subv4_web_actions_html.dart' as platform;

Future<bool> savePaymentQrOnWeb(
  Uint8List bytes, {
  String fileName = 'payment_qr.png',
}) =>
    platform.savePaymentQrOnWeb(bytes, fileName: fileName);
