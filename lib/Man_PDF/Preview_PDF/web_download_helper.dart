// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:printing/printing.dart';

/// Web helper สำหรับ download blob ข้าม browser
///
/// - **Desktop / Chrome / Android browser**: anchor `<a download>` click → download ตรง
/// - **iOS Safari**: blob URL ในแท็บใหม่ (จะมี prompt "open external app" — user กด Allow → เปิดแท็บ PDF)
/// - **LINE browser** (block navigation ทุกรูปแบบ): embed ใน overlay ในหน้าเดิม (ไม่ trigger navigation)
class WebDownloadHelper {
  /// Download bytes เป็นไฟล์
  ///
  /// - [bytes]    : เนื้อหาไฟล์
  /// - [mimeType] : เช่น `'application/pdf'`, `'image/png'`
  /// - [fileName] : ชื่อไฟล์ (รวม extension)
  static Future<void> downloadOrOpen(
    Uint8List bytes,
    String mimeType,
    String fileName,
  ) async {
    final ua = html.window.navigator.userAgent.toLowerCase();

    if (_isLineBrowser(ua)) {
      // LINE browser: convert PDF → PNG แล้ว embed เป็น <img>
      // (iframe PDF viewer แสดงที่ natural size เล็ก/เบลอ — img scale ได้คมชัด)
      await _embedInPage(bytes, mimeType, fileName);
    } else if (_isIOSSafari(ua)) {
      // iOS Safari: blob URL trigger external app prompt → user กด Allow แล้วเปิดแท็บใหม่
      // (data URL ยาวเกินไป Safari แสดงหน้าดำ — ใช้ blob แทน)
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      // ปล่อย URL ไว้จนกว่า viewer โหลดเสร็จ
      Future.delayed(
        const Duration(minutes: 1),
        () => html.Url.revokeObjectUrl(url),
      );
    } else {
      // Desktop / Android browser / in-app browser อื่น: anchor <a download>
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final a = html.AnchorElement(href: url)
        ..download = fileName
        ..style.display = 'none';
      html.document.body?.append(a);
      a.click();
      a.remove();
      html.Url.revokeObjectUrl(url);
    }
  }

  /// LINE browser ตรวจแยก — block หนักกว่า iOS Safari ทั่วไป
  static bool _isLineBrowser(String ua) {
    return ua.contains('line/');
  }

  /// iOS Safari (Mobile Safari ทุกเวอร์ชัน)
  static bool _isIOSSafari(String ua) {
    return (ua.contains('iphone') || ua.contains('ipad')) &&
        ua.contains('safari') &&
        !ua.contains('crios') &&
        !ua.contains('fxios');
  }

  /// Fallback: embed ไฟล์ใน overlay ในหน้าเดิม
  ///
  /// ใช้เมื่อ browser (LINE, in-app) block `window.open`/navigation — ไม่ trigger
  /// external app prompt เพราะไม่มี navigation เกิดขึ้น
  ///
  /// PDF จะถูก render เป็น PNG (DPI 200) แล้วแสดงเป็น `<img>` — คมชัด ขนาดใหญ่
  /// รองรับ long-press → save/แชร์ตามปกติ
  ///
  /// หมายเหตุ: Flutter Web มี `<flt-glass-pane>` overlay ทับทุกอย่าง — inject
  /// overlay เข้า `<flt-host-node>` (Flutter root) เพื่อให้ z-index ทับ glass pane
  static Future<void> _embedInPage(
    Uint8List bytes,
    String mimeType,
    String fileName,
  ) async {
    // ลบ overlay เดิมถ้ามี (กันซ้อน)
    html.document.querySelector('#chaop-embed-overlay')?.remove();

    // PDF → PNG (เฉพาะหน้าแรก) เพื่อความคมชัด
    Uint8List displayBytes = bytes;
    String displayMime = mimeType;
    if (mimeType == 'application/pdf') {
      try {
        final stream = Printing.raster(bytes, dpi: 200);
        await for (final page in stream) {
          displayBytes = Uint8List.fromList(await page.toPng());
          break; // เอาแค่หน้าแรก
        }
        displayMime = 'image/png';
      } catch (_) {
        // fallback: ใช้ PDF byte เดิมผ่าน iframe
      }
    }

    final dataUrl = 'data:$displayMime;base64,${base64Encode(displayBytes)}';

    // container overlay เต็มจอ — ใช้ !important กัน Flutter override
    final overlay = html.DivElement()
      ..id = 'chaop-embed-overlay'
      ..setAttribute('style', '''
        position: fixed !important;
        top: 0 !important;
        left: 0 !important;
        right: 0 !important;
        bottom: 0 !important;
        width: 100vw !important;
        height: 100vh !important;
        margin: 0 !important;
        padding: 0 !important;
        background: #fff !important;
        z-index: 2147483647 !important;
        font-family: sans-serif;
      ''');

    // header bar (absolute top)
    final header = html.DivElement()
      ..setAttribute('style', '''
        position: absolute !important;
        top: 0 !important;
        left: 0 !important;
        right: 0 !important;
        height: 50px !important;
        padding: 0 16px !important;
        background: #1a1a1a !important;
        color: #fff !important;
        display: flex !important;
        align-items: center !important;
        justify-content: space-between !important;
        box-sizing: border-box !important;
        z-index: 2 !important;
      ''');

    final titleEl = html.SpanElement()
      ..text = fileName
      ..setAttribute('style', '''
        font-size: 14px !important;
        flex: 1 !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
        white-space: nowrap !important;
        margin-right: 12px !important;
      ''');

    final closeBtn = html.ButtonElement()
      ..text = '✕ ปิด'
      ..setAttribute('style', '''
        padding: 6px 14px !important;
        background: #dc3545 !important;
        color: #fff !important;
        border: none !important;
        border-radius: 4px !important;
        font-size: 14px !important;
        cursor: pointer !important;
        flex-shrink: 0 !important;
      ''');
    closeBtn.onClick.listen((_) => overlay.remove());

    header.append(titleEl);
    header.append(closeBtn);

    // iframe — absolute ระหว่าง header กับ footer
    // wrap ใน container ที่จำกัด width + center เพื่อให้ PDF viewer อยู่กลางจอ
    final iframeWrap = html.DivElement()
      ..setAttribute('style', '''
        position: absolute !important;
        top: 50px !important;
        left: 0 !important;
        right: 0 !important;
        bottom: 60px !important;
        display: flex !important;
        justify-content: center !important;
        align-items: flex-start !important;
        background: #525659 !important;
        overflow: auto !important;
      ''');

    final contentEl = displayMime == 'image/png'
        ? (html.ImageElement()
          ..src = dataUrl
          ..setAttribute('style', '''
            max-width: min(820px, 100%) !important;
            width: auto !important;
            height: auto !important;
            display: block !important;
            margin: 0 auto !important;
            background: #fff !important;
            box-shadow: 0 2px 12px rgba(0,0,0,0.3) !important;
            -webkit-user-select: none !important;
            user-select: none !important;
            -webkit-touch-callout: default !important;
          '''))
        : (html.IFrameElement()
          ..src = dataUrl
          ..setAttribute('style', '''
            width: min(820px, 100%) !important;
            max-width: 820px !important;
            height: 100% !important;
            border: none !important;
            background: #fff !important;
            margin: 0 auto !important;
            display: block !important;
          '''));

    iframeWrap.append(contentEl);

    // footer bar (absolute bottom) — คำแนะนำบันทึกไฟล์
    final footer = html.DivElement()
      ..setAttribute('style', '''
        position: absolute !important;
        bottom: 0 !important;
        left: 0 !important;
        right: 0 !important;
        height: 60px !important;
        padding: 0 16px !important;
        background: #1a1a1a !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        box-sizing: border-box !important;
        z-index: 2 !important;
      ''');

    // ข้อความแนะนำ: ให้ user กดค้างที่รูปแล้ว save
    final hint = html.SpanElement()
      ..text = 'กดค้างที่รูป แล้วเลือก "บันทึกรูปภาพ" หรือ "แชร์"'
      ..setAttribute('style', '''
        color: #fff !important;
        font-size: 14px !important;
        text-align: center !important;
        opacity: 0.9 !important;
      ''');
    footer.append(hint);

    overlay.append(header);
    overlay.append(iframeWrap);
    overlay.append(footer);

    // Inject เข้า Flutter root (flt-host-node) — ทับ canvas แน่นอน
    final hostNode = html.document.querySelector('flt-host-node') ??
        html.document.body;
    hostNode?.append(overlay);
  }
}