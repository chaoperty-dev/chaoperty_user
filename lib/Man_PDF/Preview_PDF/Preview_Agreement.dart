import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../color.dart';
import 'WatermarkPainter.dart';

class RentalInforman_Agreement extends StatefulWidget {
  final pw.Document doc;
  final context;
  final String? Get_Value_cid;
  final String? cid;
  final String? title;
  final String? filePrefix;

  const RentalInforman_Agreement({
    Key? key,
    required this.doc,
    this.context,
    this.cid,
    this.title,
    this.filePrefix,
    this.Get_Value_cid,
  }) : super(key: key);

  @override
  State<RentalInforman_Agreement> createState() =>
      _RentalInforman_AgreementState();
}

class _RentalInforman_AgreementState extends State<RentalInforman_Agreement> {
  Uint8List? _cachedPdfBytes;

  Future<Uint8List> _pdfBytes() async {
    if (_cachedPdfBytes != null) return _cachedPdfBytes!;
    _cachedPdfBytes = await widget.doc.save();
    return _cachedPdfBytes!;
  }

  String _safeFileName(String name, {String fallback = 'document'}) {
    final trimmed = (name.isEmpty ? fallback : name).trim();
    final safe = trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return safe.isEmpty ? '$fallback.pdf' : '$safe.pdf';
  }

  Future<void> _sharePdf(BuildContext context) async {
    final bytes = await _pdfBytes();
    await Printing.sharePdf(
      bytes: bytes,
      filename: _safeFileName(
          '${widget.filePrefix ?? 'เอกสารสัญญา'}${widget.cid ?? ''}'),
    );
  }

  Future<void> _printPdf(BuildContext context) async {
    final bytes = await _pdfBytes();
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: _safeFileName(
          '${widget.filePrefix ?? 'เอกสารสัญญา'}${widget.cid ?? ''}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTitle =
        widget.title ?? 'เอกสารเช่า (ต้นฉบับ / ยังไม่ลงลายมือชื่อดิจิทัล)';
    final fileName = _safeFileName(
        '${widget.filePrefix ?? 'เอกสารสัญญา'}${widget.cid ?? ''}');

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
          title: Text(
            appTitle,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: Font_.Fonts_T,
            ),
          ),
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
                    initialPageFormat: PdfPageFormat.a4,
                    maxPageWidth: MediaQuery.of(context).size.width * 0.6,
                    pdfFileName: fileName,
                  ),
                ),
                Material(
                  color: AppBarColors.hexColor.withOpacity(0.8),
                  child: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 24),
                        IconButton(
                          tooltip: 'พิมพ์ / เปิดในแท็บใหม่',
                          icon: const Icon(Icons.print, color: Colors.white),
                          onPressed: () => _printPdf(context),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          tooltip: 'ดาวน์โหลด PDF',
                          icon: const Icon(Icons.download, color: Colors.white),
                          onPressed: () => _sharePdf(context),
                        ),
                        const SizedBox(width: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: WatermarkPainter('Chaoperty'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
