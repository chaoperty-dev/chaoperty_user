// // web-only helper: วาด QR ลง <canvas> แล้วดาวน์โหลดเป็น PNG
// import 'dart:html' as html;
// import 'package:qr/qr.dart';

// Future<void> saveQrPayloadAsPng(
//   String data, {
//   String fileName = 'QRPAY.png',
//   int size = 640, // ขนาดรูปสุดท้าย (px)
//   int padding = 24, // ขอบ
// }) async {
//   // ใช้ API ใหม่ของ package:qr
//   final qr = QrCode.fromData(
//     data: data,
//     errorCorrectLevel: QrErrorCorrectLevel.M,
//   );

//   final modules = qr.modules; // 2D array ของค่ามอดูล (อาจเป็น int?/bool?)
//   final count = qr.moduleCount;
//   if (modules == null || count == 0) {
//     throw StateError('QR modules not generated');
//   }

//   // ขนาดพิกเซลต่อโมดูล
//   final px = ((size - 2 * padding) / count).floor().clamp(1, 40);
//   final canvasSize = count * px + 2 * padding;

//   final canvas = html.CanvasElement(width: canvasSize, height: canvasSize);
//   final ctx = canvas.context2D;

//   // พื้นหลังขาว
//   ctx
//     ..fillStyle = '#FFFFFF'
//     ..fillRect(0, 0, canvasSize.toDouble(), canvasSize.toDouble());

//   // ฟังก์ชันเช็กโมดูล "สีดำ"
//   bool isDarkAt(int r, int c) {
//     final v = modules[r][c];
//     if (v is bool) return v; // บางเวอร์ชันเก็บเป็น bool
//     if (v is int) return v == 1; // บางเวอร์ชันเก็บเป็น 0/1
//     return v == true; // เผื่อกรณีอื่น ๆ
//   }

//   // วาดโมดูลสีดำ
//   ctx.fillStyle = '#000000';
//   for (int r = 0; r < count; r++) {
//     for (int c = 0; c < count; c++) {
//       if (isDarkAt(r, c)) {
//         ctx.fillRect(
//           (padding + c * px).toDouble(),
//           (padding + r * px).toDouble(),
//           px.toDouble(),
//           px.toDouble(),
//         );
//       }
//     }
//   }

//   // ดาวน์โหลดเป็น PNG
//   final dataUrl = canvas.toDataUrl('image/png');
//   final a = html.AnchorElement(href: dataUrl)
//     ..download = fileName
//     ..style.display = 'none';
//   html.document.body!.append(a);
//   a.click();
//   a.remove();
// }
