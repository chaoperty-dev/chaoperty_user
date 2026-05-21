// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' if (dart.library.io) 'package:chaoperty_user/fake_html.dart'
    as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import '../../Responsive/responsive.dart';
import '../../color.dart';
import '../../screen/Screen_new/fitness_app_theme.dart';
import '../Man_Pay_Receipt_PDF.dart'; // Added import for ManPay_Receipt_PDF
import 'WatermarkPainter.dart';

class PreviewPdfgen_Billsplay extends StatefulWidget {
  final pw.Document doc;
  final String? renTal_name;
  final String? title;
  final String? netImageUrl;
  static String?
      overrideTabPaid; // Kept for legacy/safety, but unused now preferably

  const PreviewPdfgen_Billsplay({
    Key? key,
    required this.doc,
    this.renTal_name,
    this.title,
    this.netImageUrl,
  }) : super(key: key);

  @override
  State<PreviewPdfgen_Billsplay> createState() =>
      _PreviewPdfgen_BillsplayState();
}

class _PreviewPdfgen_BillsplayState extends State<PreviewPdfgen_Billsplay> {
  bool _busy = false;
  bool _allowed = true;
  Uint8List? _cachedPdfBytes;
  String _tabpaid = 'false';
  @override
  void initState() {
    super.initState();
    // Synchronously check centralized override for immediate UI update
    if (ManPay_Receipt_PDF.overrideTabPaid != null) {
      _tabpaid = ManPay_Receipt_PDF.overrideTabPaid!;
      print(
          'DEBUG: Used ManPay_Receipt_PDF.overrideTabPaid in initState = $_tabpaid');
    } else if (PreviewPdfgen_Billsplay.overrideTabPaid != null) {
      // Fallback
      _tabpaid = PreviewPdfgen_Billsplay.overrideTabPaid!;
      print(
          'DEBUG: Used PreviewPdfgen_Billsplay.overrideTabPaid in initState = $_tabpaid');
    }
    _loadPermission();
  }

  Future<void> _loadPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final allowed = prefs.getBool('allowedBill');

    // Only load from Prefs if we didn't already get it from override
    if (ManPay_Receipt_PDF.overrideTabPaid != null) {
      ManPay_Receipt_PDF.overrideTabPaid = null;
    } else if (PreviewPdfgen_Billsplay.overrideTabPaid != null) {
      PreviewPdfgen_Billsplay.overrideTabPaid = null;
    } else {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      String tabpaid = preferences.getString('Tabpaid') ?? "false";
      print(
          'DEBUG: PreviewPdfgen_Billsplay read Tabpaid from Prefs = $tabpaid');

      if (mounted) {
        setState(() {
          _tabpaid = tabpaid;
        });
      }
    }

    if (mounted) {
      setState(() {
        _allowed = (allowed == null) ? true : allowed;
      });
    }
    Future.delayed(const Duration(seconds: 1), () {
      _showWarningialog();
    });
  }

  Future<void> _showWarningialog() async {
    await PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "คำเตือน",
      message: "หากพบข้อมูลผิดปกติ โปรดติดต่อผู้ดูแลระบบ",
      buttonText: "รับทราบ",
      onTapDismiss: () => Navigator.pop(context),
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false,
    );
  }

  String _safeFileName(String name, {String fallback = 'document'}) {
    final base = (name.isEmpty ? fallback : name).trim();
    final noPdf = base.toLowerCase().endsWith('.pdf')
        ? base.substring(0, base.length - 4)
        : base;
    final safe = noPdf.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return (safe.isEmpty ? fallback : safe) + '.pdf';
  }

  String _pdfName() => _safeFileName('${widget.title ?? 'เอกสาร'}');

  Future<Uint8List> _pdfBytes() async {
    if (_cachedPdfBytes != null) return _cachedPdfBytes!;
    _cachedPdfBytes = await widget.doc.save();
    return _cachedPdfBytes!;
  }

  Future<bool> _checkAllowed() async {
    if (!_allowed || !kIsWeb) {
      await _showBlockedDialog();
      return false;
    }
    return true;
  }

  Future<void> _showBlockedDialog() async {
    await PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "ขออภัย Apologize",
      message: "ไม่สามารถพิมพ์หรือดาวน์โหลดได้ (Unable to print or download)",
      buttonText: "รับทราบ",
      onTapDismiss: () => Navigator.pop(context),
      panaraDialogType: PanaraDialogType.error,
      barrierDismissible: false,
    );
  }

  Future<T?> _withBusy<T>(Future<T> Function() job) async {
    if (_busy) return null;
    setState(() => _busy = true);
    try {
      final result = await job();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เสร็จแล้ว')),
        );
      }
      return result;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
      rethrow;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _downloadPdf() async => _withBusy(() async {
        if (!await _checkAllowed()) return;
        final bytes = await _pdfBytes();
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final a = html.AnchorElement(href: url)
          ..download = _pdfName()
          ..style.display = 'none';
        html.document.body?.append(a);
        a.click();
        a.remove();
        html.Url.revokeObjectUrl(url);
      });

  Future<void> downloadPdfPageAsPng({int page = 1, double dpi = 144}) async =>
      _withBusy(() async {
        if (!await _checkAllowed()) return;
        final bytes = await _pdfBytes();
        final stream = Printing.raster(bytes, dpi: dpi);
        int i = 0;
        await for (final pageRaster in stream) {
          i++;
          if (i != page) continue;
          final png = await pageRaster.toPng();
          final blob = html.Blob([png], 'image/png');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final a = html.AnchorElement(href: url)
            ..download = '${_pdfName().replaceAll(".pdf", "_p$page.png")}'
            ..style.display = 'none';
          html.document.body?.append(a);
          a.click();
          a.remove();
          html.Url.revokeObjectUrl(url);
          break;
        }
      });

  Future<void> downloadPdfAllPagesAsPng({double dpi = 144}) async =>
      _withBusy(() async {
        if (!await _checkAllowed()) return;
        final bytes = await _pdfBytes();
        final stream = Printing.raster(bytes, dpi: dpi);
        int index = 0;
        await for (final pageRaster in stream) {
          index++;
          final png = await pageRaster.toPng();
          final blob = html.Blob([png], 'image/png');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final a = html.AnchorElement(href: url)
            ..download = '${_pdfName().replaceAll(".pdf", "_p$index.png")}'
            ..style.display = 'none';
          html.document.body?.append(a);
          a.click();
          a.remove();
          html.Url.revokeObjectUrl(url);
          await Future.delayed(const Duration(milliseconds: 30));
        }
      });

  @override
  Widget build(BuildContext context) {
    final appTitle = widget.title ?? 'เอกสาร';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppBarColors.hexColor,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          ),
          centerTitle: true,
          title: Text(appTitle, style: const TextStyle(color: Colors.white)),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PdfPreview(
                    build: (format) async => await _pdfBytes(),
                    allowSharing: false,
                    allowPrinting: false,
                    canDebug: false,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    maxPageWidth: (Responsive.isDesktop(context))
                        ? MediaQuery.of(context).size.width * 0.6
                        : MediaQuery.of(context).size.width * 0.95,
                    initialPageFormat: PdfPageFormat.a4,
                    pdfFileName: _pdfName(),
                  ),
                ),

                // ✅ แถบปุ่มล่างจะแสดงเฉพาะเมื่อมีสิทธิ์
                if (_allowed)
                  Material(
                    color: AppBarColors.hexColor.withOpacity(0.8),
                    child: (_tabpaid == 'true')
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'รายการรอตรวจสอบ ยังไม่สามารถดาวน์โหลดได้',
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      letterSpacing: 1.2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ])
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                tooltip: _busy
                                    ? 'กำลังทำงาน...'
                                    : 'ดาวน์โหลด PNG ทุกหน้า',
                                icon: const Icon(Icons.collections,
                                    color: Colors.white),
                                onPressed: _busy
                                    ? null
                                    : () => downloadPdfAllPagesAsPng(dpi: 144),
                              ),
                              IconButton(
                                tooltip: _busy
                                    ? 'กำลังทำงาน...'
                                    : 'ดาวน์โหลด PNG หน้าแรก',
                                icon: const Icon(Icons.image,
                                    color: Colors.white),
                                onPressed: _busy
                                    ? null
                                    : () =>
                                        downloadPdfPageAsPng(page: 1, dpi: 144),
                              ),
                              IconButton(
                                tooltip:
                                    _busy ? 'กำลังทำงาน...' : 'ดาวน์โหลด PDF',
                                icon: const Icon(Icons.download,
                                    color: Colors.white),
                                onPressed: _busy ? null : _downloadPdf,
                              ),
                            ],
                          ),
                  ),
              ],
            ),

            // ✅ ลายน้ำทับจอ
            const IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: WatermarkPainter('Chaoperty'),
              ),
            ),

            // ✅ overlay ขณะ busy
            if (_busy)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x33000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
