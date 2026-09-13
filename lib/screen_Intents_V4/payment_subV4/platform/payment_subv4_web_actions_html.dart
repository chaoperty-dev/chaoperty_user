import 'dart:convert';
import 'dart:typed_data';

import 'package:universal_html/html.dart' as html;

Future<bool> savePaymentQrOnWeb(
  Uint8List bytes, {
  String fileName = 'payment_qr.png',
}) async {
  if (bytes.isEmpty) return false;

  final userAgent = html.window.navigator.userAgent.toLowerCase();
  final isIos = userAgent.contains('iphone') ||
      userAgent.contains('ipad') ||
      userAgent.contains('ipod');
  final isMobile = isIos ||
      userAgent.contains('android') ||
      userAgent.contains('mobile');

  if (isIos) {
    _showLongPressOverlay(bytes);
    return true;
  }

  final blob = html.Blob([bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);

  if (isMobile) {
    html.window.open(url, '_blank');
    Future<void>.delayed(
      const Duration(minutes: 1),
      () => html.Url.revokeObjectUrl(url),
    );
    return true;
  }

  final anchor = html.AnchorElement(href: url)
    ..download = fileName
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
  return true;
}

void _showLongPressOverlay(Uint8List bytes) {
  const id = 'payment_subv4_qr_save_overlay';
  html.document.getElementById(id)?.remove();

  final imageUrl = 'data:image/png;base64,${base64Encode(bytes)}';
  final overlay = html.DivElement()
    ..id = id
    ..style.position = 'fixed'
    ..style.left = '0'
    ..style.top = '0'
    ..style.right = '0'
    ..style.bottom = '0'
    ..style.backgroundColor = 'rgba(15,23,42,.94)'
    ..style.display = 'flex'
    ..style.flexDirection = 'column'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center'
    ..style.zIndex = '2147483647'
    ..style.padding = '20px';

  final image = html.ImageElement(src: imageUrl)
    ..style.maxWidth = '88vw'
    ..style.maxHeight = '68vh'
    ..style.padding = '14px'
    ..style.backgroundColor = '#FFFFFF'
    ..style.borderRadius = '16px'
    ..style.setProperty('-webkit-touch-callout', 'default');

  final hint = html.DivElement()
    ..text = 'กดค้างที่รูปเพื่อบันทึก / Long-press to save'
    ..style.color = '#FFFFFF'
    ..style.fontSize = '15px'
    ..style.marginTop = '16px'
    ..style.textAlign = 'center';

  final close = html.ButtonElement()
    ..text = 'ปิด / Close'
    ..style.marginTop = '14px'
    ..style.padding = '10px 18px'
    ..style.border = '0'
    ..style.borderRadius = '10px'
    ..style.backgroundColor = '#FFFFFF'
    ..style.color = '#0F172A';

  close.onClick.listen((_) => overlay.remove());
  image.onClick.listen((event) => event.stopPropagation());
  overlay.children.addAll([image, hint, close]);
  html.document.body?.append(overlay);
}
