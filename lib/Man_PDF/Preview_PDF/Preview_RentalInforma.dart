import 'dart:async';

// import 'dart:html'; // Removed duplicate/unused import
import 'dart:typed_data';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../color.dart';
import 'package:path/path.dart' as path;

import 'package:http/http.dart' as http;

class PreviewScreenRentalInforma extends StatefulWidget {
  final pw.Document doc;
  final netImage_;

  const PreviewScreenRentalInforma(
      {Key? key, required this.doc, this.netImage_})
      : super(key: key);

  @override
  State<PreviewScreenRentalInforma> createState() =>
      _PreviewScreenRentalInformaState();
}

class _PreviewScreenRentalInformaState
    extends State<PreviewScreenRentalInforma> {
  Uint8List? _cachedPdfBytes;

  Future<Uint8List> _pdfBytes() async {
    if (_cachedPdfBytes != null) return _cachedPdfBytes!;
    _cachedPdfBytes = await widget.doc.save();
    return _cachedPdfBytes!;
  }

  static const customSwatch = MaterialColor(
    0xFF8DB95A,
    <int, Color>{
      50: Color(0xFFC2FD7F),
      100: Color(0xFFB6EE77),
      200: Color(0xFFB2E875),
      300: Color(0xFFACDF71),
      400: Color(0xFFA7DA6E),
      500: Color(0xFFA1D16A),
      600: Color(0xFF94BF62),
      700: Color(0xFF90B961),
      800: Color(0xFF85AB5A),
      900: Color(0xFF7A9B54),
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppBarColors.hexColor,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_outlined,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          title: const Text(
            "ข้อมูลผู้เช่า",
            style: TextStyle(
              color: Colors.white,
              fontFamily: Font_.Fonts_T,
            ),
          ),
        ),
        body: PdfPreview(
          build: (format) async => await _pdfBytes(),
          allowSharing: true,
          allowPrinting: true,
          canDebug: false,
          canChangeOrientation: false,
          canChangePageFormat: false,
          maxPageWidth: MediaQuery.of(context).size.width * 0.6,
          initialPageFormat: PdfPageFormat.a4,
          pdfFileName: "ข้อมูลผู้เช่า.pdf",
        ),
      ),
    );
  }
}
