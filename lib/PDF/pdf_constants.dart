// PDF Constants - extracted from lib/color.dart on 2026-07-08 to keep
// package:pdf out of the app bundle's eager dependency graph.
// Only imported by PDF generators under lib/PDF/ and lib/Man_PDF/.
import 'package:pdf/pdf.dart';

class PDFConstants {
  // ==================== สีสำหรับ Border ====================
  /// สีดำสำหรับ border ทั้งหมดในเอกสาร PDF
  static const PdfColor borderColor = PdfColors.black;
  static const PdfColor borderColorGrey = PdfColors.grey600;

  // ==================== สีสำหรับข้อความ ====================
  /// สีดำสำหรับข้อความทั่วไป
  static const PdfColor textColorBlack = PdfColors.black;
  static const PdfColor textColorGrey = PdfColors.grey800;

  // ==================== ขนาดฟอนต์ ====================
  /// ขนาดฟอนต์มาตรฐาน
  static const double fontSizeNormal = 10.0;

  /// ขนาดฟอนต์เล็ก
  static const double fontSizeSmall = 8.0;

  /// ขนาดฟอนต์ใหญ่
  static const double fontSizeLarge = 14.0;
}