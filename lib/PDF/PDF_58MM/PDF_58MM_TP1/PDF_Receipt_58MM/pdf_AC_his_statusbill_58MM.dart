import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty_user/File_s.dart';
import 'package:chaoperty_user/PDF/pdf_constants.dart';
import 'package:chaoperty_user/loadAndCacheImage.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;

import '../../../../CRC_16_Prompay/generate_qrcode.dart';
import '../../../../Constant/Myconstant.dart';
import '../../../../Man_PDF/Man_Pay_Receipt_PDF.dart';
import '../../../../Man_PDF/Man_Temporary_Receipt_PDF.dart';
import '../../../../Man_PDF/Preview_PDF/PreviewPdfgen_Billsplay.dart';
import '../../../../Model/trans_re_bill_history_model.dart';

class Pdfgen_his_statusbill_58MM {
//////////---------------------------------------------------->(ใบเสร็จรับเงิน/ใบกำกับภาษี)   ใช้  //

  static void exportPDF_statusbill_58MM({
    required List<TransReBillHistoryModel> TransReBillHistory,
    required Cust_no,
    required cid_s,
    required Zone_s,
    required Ln_s,
    required Ln_c,
    required fname,
    required foder,
    required tableData00,
    required tableData01,
    required context,
    required transReBillHistoryModels,
    required Num_cid,
    required Namenew,
    required sum_pvat,
    required sum_vat,
    required sum_wht,
    required Sum_SubTotal,
    required sum_disp,
    required sum_disamt,
    required Total,
    required renTal_name,
    required sname,
    required cname,
    required addr,
    required tax,
    required bill_addr,
    required bill_email,
    required bill_tel,
    required bill_tax,
    required bill_name,
    required newValuePDFimg,
    required numinvoice,
    required numdoctax,
    required ref_invoice,
    required finnancetransModels,
    required date_Transaction,
    required dayfinpay,
    required type_bills,
    required dis_sum_Matjum,
    required TitleType_Default_Receipt_Name,
    required dis_sum_Pakan,
    required sum_fee,
    required com_ment,
    required fonts_pdf,
    required Preview_ser,
    required Con_remark,
    required round_p,
    required paper,
    required paper_run,
    required amt_up,
    required vat_up,
    required lncode,
    required sum_addvat_choice,
    required sum_Nonvat_choice,
    required signature,
    required fullname,
    required billingFormat,
  }) async {
    ////
    //// ------------>(ใบเสร็จรับเงิน 58mm — hardcoded POS 58mm receipt)
    // 58mm variant always uses 'pos58' — no dialog needed.
    // User request 2026-07-27: hardcode pos58 instead of showing dialog.
    // ------------------------------------------------------->
    const String pageMode = 'pos58';
    final bool isPos = true; // pos58 is a POS paper roll

    final pdf = pw.Document();
    final font = await rootBundle.load("${fonts_pdf}");
    var Colors_pd = PdfColors.black;
    const PdfColor PDF_Border_Color = PDFConstants.borderColor;
    // final font = await rootBundle.load("fonts/Sarabun-Medium.ttf");

    int pageCount = 1; // Initialize the page count
    final ttf = pw.Font.ttf(font);

    // ── Responsive layout variables ─────────────────────
    // font_Size  : ขนาดตัวอักษรหลัก
    // logoSize   : ขนาด logo สี่เหลี่ยม
    // infoGapMm  : ช่องว่างระหว่าง logo กับ info text
    // ────────────────────────────────────────────────────
    // ── Responsive layout variables — 2026-07-28 tuned for 58mm ──
    // pos58 = 58 mm thermal (narrower than pos60, smaller font + logo).
    final double font_Size = () {
      switch (pageMode) {
        case 'pos58':
          return 5.5;
        case 'pos60':
          return 5.0; // 60 mm — slightly smaller than pos58 for fit
        case 'pos80':
          return 7.5;
        case 'a3':
          return 11.0;
        case 'a5':
          return 7.0;
        case 'a4':
        default:
          return 10.0;
      }
    }();

    // Extra-small variant for disclaimers / page numbers (2026-07-27).
    final double fontSize_xs = font_Size * 0.8;

    final int _logoPx = () {
      switch (pageMode) {
        case 'a3':
          return 300;
        case 'pos60':
          return 80; // 60 mm — small logo (vs pos80=120)
        case 'pos58':
          return 72; // 58 mm — smaller logo (vs pos60=80)
        case 'pos80':
          return 120;
        case 'a5':
          return 150;
        case 'a4':
        default:
          return 180;
      }
    }();
    final double logoSize = isPos
        ? (pageMode == 'pos60'
            ? 24.0
            : pageMode == 'pos58'
                ? 20.0
                : 32.0)
        : 60.0;
    final double infoGapMm = isPos
        ? (pageMode == 'pos60'
            ? 1.0
            : pageMode == 'pos58'
                ? 0.8
                : 1.5)
        : 6.0;

    //////--------------------------------------------->
    DateTime date = DateTime.now();
    // var formatter = new DateFormat.MMMMd('th_TH');
    // String thaiDate = formatter.format(date);
    final thaiDate = DateTime.parse(date_Transaction);
    final formatter = DateFormat('d MMMM', 'th_TH');
    final formattedDate = formatter.format(thaiDate);
    //////--------------->พ.ศ.
    DateTime dateTime = DateTime.parse(date_Transaction);
    int newYear = dateTime.year + 543;
    //////--------------------------------------------->
    var nFormat = NumberFormat("#,##0.00", "en_US");
    var nFormat2 = NumberFormat("###0.00", "en_US");
    final iconImage =
        (await rootBundle.load('images/LOGO.png')).buffer.asUint8List();
    List netImage = [];
    List netImage_QR = [];
    Uint8List? resizedLogo = await getResizedLogo();

    ///
    ///
////////////////------------------------------->
    double Total_CASH = double.parse(
      '${finnancetransModels.where((model) => model.ptser == '1' && model.dtype == 'KP').fold<double>(
            0.0,
            (double previousValue, element) =>
                previousValue +
                (element.total != null ? double.parse(element.total!) : 0),
          )}',
    );

    // '${finnancetransModels.where((model) => model.ptser == '1' && model.dtype == 'KP').map((model) => model.total).join(', ')}';
    String total_QR =
        '${nFormat.format(double.parse('${Total}') - Total_CASH)}';
    String newTotal_QR = total_QR.replaceAll(RegExp(r'[^0-9]'), '');
    // for (int i = 0; i < newValuePDFimg.length; i++) {
    //   netImage.add(await networkImage('${newValuePDFimg[i]}'));
    // }
    for (int i = 0; i < finnancetransModels.length; i++) {
      if (finnancetransModels[i].img == null ||
          finnancetransModels[i].img.toString() == '') {
        netImage_QR.add(iconImage);
      } else {
        netImage_QR.add(await networkImage(
            '${MyConstant().domain}/files/$foder/payment/${finnancetransModels[i].img}'));
      }
    }

//////////---------------------------->
    bool hasNonCashTransaction = finnancetransModels.any((transaction) {
      return transaction.type.toString() != 'CASH' &&
          transaction.type != null &&
          transaction.dtype.toString() != 'FTA';
    }); ///// เงินโอน , Online Standard QR , Online Payment
////////////////------------------------------->
    bool hasNonCashTransaction1 = finnancetransModels.any((transaction) {
      return transaction.type.toString() == 'CASH' &&
          transaction.dtype.toString() != 'FTA';
    }); ///// เงินสด
////////////////------------------------------->
    bool hasNonCashTransaction2 = finnancetransModels.any((transaction) {
      return transaction.ptser.toString() == '6' &&
          transaction.dtype.toString() != 'FTA';
    }); //Online Standard QR
////////////////------------------------------->
    bool hasNonCashTransaction3 = finnancetransModels.any((transaction) {
      return transaction.ptser.toString() == '2' &&
          transaction.dtype.toString() != 'FTA';
    }); ///// เงินโอน
////////////////------------------------------->
    bool hasNonCashTransaction4 = finnancetransModels.any((transaction) {
      return transaction.ptser.toString() == '5' &&
          transaction.dtype.toString() != 'FTA';
    }); ///// Online Payment
////////////////------------------------------->
    bool hasNonCashTransaction5 = finnancetransModels.any((transaction) {
      return transaction.dtype.toString() == 'MM';
    }); ///// Online Payment
//////////---------------------------------->
    bool hasNonCashTransaction6 = finnancetransModels.any((transaction) {
      return transaction.dtype.toString() == 'FTA';
    }); ///// Online Payment
//////////---------------------------------->
    bool hasNonCashTransaction7 = finnancetransModels.any((transaction) {
      return transaction.ref1.toString().trim() == '';
    });
    bool hasNonCashTransaction8 = finnancetransModels.any((transaction) {
      return transaction.ptser.toString().trim() == '6';
    });
///// Online Standard QR
//////////---------------------------------->

    /// ///---------------------> Table header columns (หัวคอลัมน์ของตาราง)
    final headerColumns = [
      {
        'label': 'ลำดับ',
        'flex': 0,
        'align': pw.Alignment.center,
        'width': 18.0
      },
      {'label': 'รายการ', 'flex': 3, 'align': pw.Alignment.centerLeft},
      {'label': 'ยอดสุทธิ', 'flex': 2, 'align': pw.Alignment.centerRight},
    ];
///////------------------------------->
    double getTotalByField(
      List<TransReBillHistoryModel> trans,
      String? Function(TransReBillHistoryModel item) getter,
    ) {
      return trans.fold(0.0, (sum, item) {
        final value = double.tryParse(getter(item) ?? '0.00') ?? 0.00;
        return sum + value;
      });
    }

    ///---------------------> โหลด signature image
    print('billingFormat: $billingFormat');
    Uint8List? signatureBytes;
    if (billingFormat == 'มี') {
      if (signature != null &&
          signature.toString().isNotEmpty &&
          signature.toString() != 'null') {
        try {
          final sigUrl = '${MyConstant().domain}/${signature}';
          print('signature URL: $sigUrl');
          final sigRes = await http.get(Uri.parse(sigUrl));
          if (sigRes.statusCode == 200) {
            signatureBytes = sigRes.bodyBytes;
          }
        } catch (_) {
          signatureBytes = null;
        }
      }
    }

///////------------------------------->
    // ฟังก์ชันปัดเศษทศนิยม 2 ตำแหน่ง
    double roundMoney(double value) {
      return (value * 100).round() / 100;
    }

    final totalAmt = roundMoney(getTotalByField(
        transReBillHistoryModels, (e) => e.amt.toString() ?? '0'));
    final totalPvat = roundMoney(getTotalByField(
        transReBillHistoryModels, (e) => e.pvat.toString() ?? '0'));
    final totalVat = roundMoney(getTotalByField(
        transReBillHistoryModels, (e) => e.vat.toString() ?? '0'));
    final totalWht = roundMoney(getTotalByField(
        transReBillHistoryModels, (e) => e.wht.toString() ?? '0'));
    final totalLine = roundMoney(getTotalByField(
        transReBillHistoryModels, (e) => e.total.toString() ?? '0'));

    final totalDis =
        roundMoney(double.tryParse(sum_disamt.toString() ?? '0.00') ?? 0.00);
    final totalFee =
        roundMoney(double.tryParse(sum_fee.toString() ?? '0.00') ?? 0.00);
    final totalMatjum = roundMoney(
        double.tryParse(dis_sum_Matjum.toString() ?? '0.00') ?? 0.00);
    final totalPakan =
        roundMoney(double.tryParse(dis_sum_Pakan.toString() ?? '0.00') ?? 0.00);

    final totalBill = roundMoney((totalLine + totalFee) - totalDis) -
        (totalMatjum + totalPakan);

    ///////------------------------------->

    String getFormattedText(String? data) {
      final value =
          (data == null) ? 0.00 : double.tryParse(data ?? '0.00') ?? 0.00;
      return nFormat.format(value);
    }

    bool isPositive(String? value) {
      return (double.tryParse(value ?? '0.00') ?? 0.00) > 0;
    }

    pw.Widget buildCell({
      required String text,
      int flex = 1,
      double padding = 2.0,
      pw.Alignment alignment = pw.Alignment.centerRight,
      pw.TextAlign textAlign = pw.TextAlign.right,
    }) {
      return pw.Expanded(
        flex: flex,
        child: pw.Container(
          decoration: const pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border(
              left: pw.BorderSide(color: PDF_Border_Color),
              right: pw.BorderSide(color: PDF_Border_Color),
              top: pw.BorderSide(color: PDF_Border_Color),
              bottom: pw.BorderSide(color: PDF_Border_Color),
            ),
          ),
          padding: pw.EdgeInsets.all(padding),
          child: pw.Align(
            alignment: alignment,
            child: pw.Text(
              text,
              maxLines: 2,
              textAlign: textAlign,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: PdfColors.grey800,
              ),
            ),
          ),
        ),
      );
    }

    // ── คำนวณความสูงกระดาษ POS จากเนื้อหาจริง ──────────────────
    //  Final tighten 2026-07-27: target content footprint ≈150–180 pt.
    //  Removed dead weights (1.4× safety + 120pt footer + 100pt payment
    //  blocks); kept only per-row scaling for table items.
    final int _itemCount = transReBillHistoryModels.length;
    // _rowH = ~3.5pt multiplier (real cell ~9-11pt with Padding(2) +
    // text 5pt \u2014 reduce from 5.5× overestimate).
    final double _rowH = font_Size * 2.8;
    final double _posH = isPos
        ? (logoSize // header logo (~24)
                +
                18 // shop name + brand divider
                +
                36 // customer info rows (~5 \u00d7 8pt + spacing)
                +
                20 // Receipt No + Date + Tax ID (3 rows)
                +
                6 // section divider before table
                +
                10 // table header row
                +
                (_itemCount *
                    _rowH) // table rows (\u00d73.5 instead of \u00d75.5)
                +
                32 // summary (3\u20135 sumRow + divider)
                +
                14 // payment (2 sumRow)
                +
                95 // footer (thank-you + disclaimer + signature columns)
                +
                12 // page margins (mTop + mBottom)
            )
            .clamp(140,
                4000) // \u0e15\u0e48\u0e33\u0e2a\u0e38\u0e14 160pt, \u0e2a\u0e39\u0e07\u0e2a\u0e38\u0e14 4000pt
        : 5000.0; // non-POS \u0e44\u0e21\u0e48\u0e43\u0e0a\u0e49\u0e04\u0e48\u0e32\u0e19\u0e35\u0e49

    // ────────────────────────────────────────────────────────────

    PdfPageFormat buildFormat() {
      // margin ซ้าย/ขวา/บน/ล่าง (หน่วย pt — 1 pt = 1/72 inch)
      const double mLeft = 10;
      const double mRight = 10;
      const double mTop = 12;
      const double mBottom = 12;

      switch (pageMode) {
        // ---- POS (กระดาษม้วน) — ความสูงคำนวณจากเนื้อหาจริง ----
        case 'pos80':
          return PdfPageFormat(80.0 * PdfPageFormat.mm, _posH).copyWith(
            marginLeft: mLeft,
            marginRight: mRight,
            marginTop: mTop,
            marginBottom: mBottom,
          );
        case 'pos58':
          return PdfPageFormat(58.0 * PdfPageFormat.mm, _posH).copyWith(
            marginLeft: mLeft,
            marginRight: mRight,
            marginTop: mTop,
            marginBottom: mBottom,
          );
        // ── 60 mm POS receipt (label / sticker printer) ──
        // Forked into PDF_60MM/ on 2026-07-27
        case 'pos60':
          return PdfPageFormat(60.0 * PdfPageFormat.mm, _posH).copyWith(
            marginLeft: mLeft,
            marginRight: mRight,
            marginTop: mTop,
            marginBottom: mBottom,
          );

        // ---- A3 (297 × 420 mm) ----
        case 'a3':
          return PdfPageFormat.a3.copyWith(
            marginLeft: mLeft,
            marginRight: mRight,
            marginTop: mTop,
            marginBottom: mBottom,
          );

        // ---- A5 (148 × 210 mm) ----
        case 'a5':
          return PdfPageFormat(14.8 * PdfPageFormat.cm, 21.0 * PdfPageFormat.cm)
              .copyWith(
            marginLeft: mLeft,
            marginRight: mRight,
            marginTop: mTop,
            marginBottom: mBottom,
          );

        // ---- A4 (210 × 297 mm) — default ----
        case 'a4':
        default:
          return PdfPageFormat.a4.copyWith(
            marginLeft: mLeft,
            marginRight: mRight,
            marginTop: mTop,
            marginBottom: mBottom,
          );
      }
    }

    // Phase 5.5 (2026-07-27): Derive payment summary + remark text
    // for header display. Local to this static method.
    final String paySummary =
        (finnancetransModels != null && finnancetransModels.isNotEmpty)
            ? (List<String>.from(
                finnancetransModels.map<String>((m) {
                  final amt = (m.amt ?? '').toString();
                  final amtFmt = amt.isEmpty
                      ? '0.00'
                      : double.tryParse(amt)?.toStringAsFixed(2) ?? amt;
                  final typeLabel =
                      (m.type ?? '').toString().toUpperCase() == 'CASH'
                          ? 'เงินสด'
                          : 'เงินโอน';
                  final ptName = (m.ptname ?? '').toString();
                  final ptSuffix = ptName.isEmpty ? '' : ' ($ptName)';
                  final line = '$typeLabel$ptSuffix : $amtFmt บาท';
                  return line;
                }).where((s) => (s as String).isNotEmpty),
              )).join('\n')
            : '';

    final String? remarkText = (Con_remark ?? '').toString().trim().isEmpty
        ? null
        : Con_remark.toString().trim();

    // Phase 2.5 (2026-07-27): Full information header
    // ── Logo + Shop Name + Tax ID + Receipt No. + Date ──
    // Plus customer details (name / address / tax), Zone / Room / Note,
    // Payment Date / payment form. Squeezed for 60 mm thermal.
    pdf.addPage(
      pw.MultiPage(
        pageFormat: buildFormat(),
        header: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Logo
              if (resizedLogo != null)
                pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(resizedLogo),
                    height: 28,
                    width: 28,
                  ),
                ),
              pw.SizedBox(height: 2),
              // Shop name
              pw.Center(
                child: pw.Text(
                  '$bill_name',
                  textAlign: pw.TextAlign.center,
                  maxLines: 1,
                  style: pw.TextStyle(
                    fontSize: 8,
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              // Shop name
              pw.Center(
                child: pw.Text(
                  '$bill_addr',
                  textAlign: pw.TextAlign.center,
                  maxLines: 1,
                  style: pw.TextStyle(
                    fontSize: 8,
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),
              pw.SizedBox(height: 3),
              // Divider after brand
              pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
                  ),
                ),
              ),
              pw.SizedBox(height: 3),

              // Customer: ชื่อ-ที่อยู่ (Name / Address / Tax)
              if ((fname ?? '').toString().isNotEmpty ||
                  (sname ?? '').toString().isNotEmpty ||
                  (cname ?? '').toString().isNotEmpty)
                _headerRow('ชื่อลูกค้า/Name : ',
                    '${fname ?? ''} ${sname ?? ''} ${cname ?? ''}'.trim(),
                    fontSize: font_Size, ttf: ttf),
              if ((addr ?? '').toString().isNotEmpty)
                _headerRow('ที่อยู่/Address : ', '$addr',
                    fontSize: font_Size, ttf: ttf),
              if ((tax ?? '').toString().isNotEmpty)
                _headerRow('เลขประจำตัวผู้เสียภาษี/Tax : ', '$tax',
                    fontSize: font_Size, ttf: ttf),

              pw.SizedBox(height: 1),

              // Receipt No. (right) [มี numdoctax ถ้าเป็น invoice อิเล็กทรอนิกส์]
              _headerRow(
                  'เลขที่/Receipt No. : ',
                  (numdoctax.toString() == ''
                      ? numinvoice.toString()
                      : numdoctax.toString()),
                  fontSize: font_Size,
                  ttf: ttf),
              if ((Zone_s ?? '').toString().isNotEmpty)
                _headerRow('โซน(Zone) : ', '$Zone_s',
                    fontSize: font_Size, ttf: ttf),

              pw.SizedBox(height: 1),

              // Date / Payment Date
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('วันที่ทำรายการ/Date',
                      style: pw.TextStyle(fontSize: fontSize_xs, font: ttf)),
                  pw.Text(
                    (date_Transaction == null)
                        ? '-'
                        : '${DateFormat('dd/MM/yyyy').format(DateTime.parse(date_Transaction))} ${DateFormat('HH:mm').format(DateTime.parse(date_Transaction))}',
                    style: pw.TextStyle(fontSize: fontSize_xs, font: ttf),
                  ),
                ],
              ),
              if ((dayfinpay ?? '').toString().isNotEmpty) ...[
                pw.SizedBox(height: 1),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('วันที่ชำระ/Payment Date',
                        style: pw.TextStyle(fontSize: fontSize_xs, font: ttf)),
                    pw.Text(
                      (dayfinpay == null)
                          ? '-'
                          : DateFormat('dd/MM/yyyy')
                              .format(DateTime.parse(dayfinpay.toString())),
                      style: pw.TextStyle(fontSize: fontSize_xs, font: ttf),
                    ),
                  ],
                ),
              ],

              // Payment Method (รูปแบบชำระ) — derived from finnancetransModels
              if (paySummary.isNotEmpty) ...[
                pw.SizedBox(height: 1),
                _headerRow('รูปแบบชำระ/Payment : ', paySummary,
                    fontSize: fontSize_xs, ttf: ttf),
              ],

              // หมายเหตุ (Remark) — optional, supports multi-line
              if (remarkText != null) ...[
                pw.SizedBox(height: 1),
                _headerRow('หมายเหตุ/Remark : ', remarkText,
                    fontSize: fontSize_xs, ttf: ttf),
              ],

              // Tax ID (กลุ่มบริษัท)
              if ((bill_tax ?? '').toString().isNotEmpty) ...[
                pw.SizedBox(height: 1),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Tax ID',
                        style: pw.TextStyle(fontSize: fontSize_xs, font: ttf)),
                    pw.Text('$bill_tax',
                        style: pw.TextStyle(fontSize: fontSize_xs, font: ttf)),
                  ],
                ),
              ],

              pw.SizedBox(height: 2),
              // Section divider before table
              pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
            ],
          );
        },
        build: (context) {
          // Phase 3 (2026-07-27): Items table + summary
          // Compact 5-column table (Tesco / FamilyMart style)
          return <pw.Widget>[
            // ── Items table ──
            pw.Table(
              border: pw.TableBorder(
                horizontalInside:
                    pw.BorderSide(color: PdfColors.grey400, width: 0.5),
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
              ),
              columnWidths: {
                0: pw.FixedColumnWidth(16), // #
                1: pw.FlexColumnWidth(3), // description
                // 2: pw.FixedColumnWidth(38), // qty
                // 3: pw.FixedColumnWidth(42), // price
                4: pw.FixedColumnWidth(50), // total
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
                    ),
                  ),
                  children: [
                    _th('#', fontSize: font_Size, ttf: ttf),
                    _th('รายการ',
                        align: pw.Alignment.centerLeft,
                        fontSize: font_Size,
                        ttf: ttf),
                    // _th('จำนวน', fontSize: font_Size, ttf: ttf),
                    // _th('ราคา', fontSize: font_Size, ttf: ttf),
                    _th('ยอด', fontSize: font_Size, ttf: ttf),
                  ],
                ),
                // Data rows
                ...List.generate(TransReBillHistory.length, (idx) {
                  final r = TransReBillHistory[idx];
                  return pw.TableRow(
                    children: [
                      _td('${idx + 1}',
                          align: pw.Alignment.center,
                          fontSize: font_Size,
                          ttf: ttf),
                      _td((r.expname ?? '-').toString(),
                          align: pw.Alignment.centerLeft,
                          maxLines: 2,
                          fontSize: font_Size,
                          ttf: ttf),
                      // _td(getFormattedText(r.qty),
                      //     fontSize: font_Size, ttf: ttf),
                      // _td(getFormattedText(r.pvat),
                      //     fontSize: font_Size, ttf: ttf),
                      _td(getFormattedText(r.total),
                          bold: true, fontSize: font_Size, ttf: ttf),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 2),

            // ── Summary (Sub Total / VAT / Discount / Total) ──
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  _sumRow('รวมทั้งสิ้น/Total', getFormattedText('$Total'),
                      fontSize: font_Size, ttf: ttf),
                  // if (_hasValue(sum_pvat))
                  //   _sumRow('ก่อน VAT', getFormattedText('$sum_pvat'),
                  //       fontSize: font_Size, ttf: ttf),
                  // if (_hasValue(sum_vat))
                  //   _sumRow(
                  //       'VAT ${type_bills ?? ''}', getFormattedText('$sum_vat'),
                  //       fontSize: font_Size, ttf: ttf),
                  // if (_hasValue(sum_wht))
                  //   _sumRow(
                  //       'หัก ณ ที่จ่าย ${sum_wht}%',
                  //       getFormattedText(
                  //           '${(double.tryParse('$sum_wht') ?? 0) * (double.tryParse('$Sum_SubTotal') ?? 0) / 100}'),
                  //       fontSize: font_Size,
                  //       ttf: ttf),
                  // if (_hasValue(sum_disamt))
                  //   _sumRow('ส่วนลด', '-${getFormattedText('$sum_disamt')}',
                  //       fontSize: font_Size, ttf: ttf),
                  // // ── ค่าธรรมเนียมการใช้ (Fees) — always shown (0 = 0.00) ──
                  // _sumRow('ค่าธรรมเนียมการใช้/ค่าบริการ',
                  //     getFormattedText('${double.tryParse('$sum_fee') ?? 0}'),
                  //     fontSize: font_Size, ttf: ttf),
                  // // ── เงินมัดจำ (Deposit) — always shown (0 = 0.00) ──
                  // _sumRow('เงินมัดจำ(ตัดมัดจำ)',
                  //     getFormattedText('$dis_sum_Matjum'),
                  //     fontSize: font_Size, ttf: ttf),
                  // // ── เงินประกัน (Insurance) — always shown (0 = 0.00) ──
                  // _sumRow('เงินประกัน(ตัดเงินประกัน)',
                  //     getFormattedText('$dis_sum_Pakan'),
                  //     fontSize: font_Size, ttf: ttf),
                  // pw.SizedBox(height: 2),
                  // _sumRow('รวมทั้งสิ้น/Total', getFormattedText('$Total'),
                  //     bold: true, divider: true, fontSize: font_Size, ttf: ttf),
                ],
              ),
            ),

            pw.SizedBox(height: 2),

            // ── Payment (Cash + Change) ──
            // pw.Align(
            //   alignment: pw.Alignment.centerRight,
            //   child: pw.Column(
            //     crossAxisAlignment: pw.CrossAxisAlignment.end,
            //     children: [
            //       _sumRow('รับเงิน/Cash', getFormattedText('$round_p'),
            //           fontSize: font_Size, ttf: ttf),
            //       _sumRow('เงินทอน/Change',
            //           '-${getFormattedText('${(double.tryParse('$round_p') ?? 0) - (double.tryParse('$Total') ?? 0)}')}',
            //           fontSize: font_Size, ttf: ttf),
            //     ],
            //   ),
            // ),

            pw.SizedBox(height: 2),
            pw.Container(
              width: double.infinity,
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.black, width: 0.5),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // ── Signature (ผู้รับเงิน + ผู้จ่ายเงิน) ──
                  //  • Receiver (left): shows signature when
                  //    billingFormat == 'มี', else blank box.
                  //  • Payer (right): always blank for customer hand-sign.
                  pw.SizedBox(height: 15),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // ── ผู้รับเงิน / Receiver (left) ──
                      pw.Column(
                        children: [
                          // Signature placeholder dots (no border box)
                          pw.Container(
                            width: 60,
                            alignment: pw.Alignment.center,
                            padding:
                                const pw.EdgeInsets.only(top: 8, bottom: 2),
                            child: pw.Text(
                              '',
                              style: pw.TextStyle(
                                fontSize: fontSize_xs + 1,
                                font: ttf,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ),
                          // Bottom divider line (signature underline)
                          pw.Container(
                            width: 60,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                top: pw.BorderSide(
                                    color: PdfColors.black, width: 0.5),
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 1),
                          pw.Text(
                            '($fullname)',
                            style: pw.TextStyle(
                              fontSize: fontSize_xs,
                              font: ttf,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'ผู้รับเงิน / Receiver',
                            style: pw.TextStyle(
                              fontSize: fontSize_xs,
                              font: ttf,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(
                        width: 20,
                      ),
                      // ── ผู้จ่ายเงิน / Payer (right) ──
                      pw.Column(
                        children: [
                          // Signature placeholder dots (no border box)
                          pw.Container(
                            width: 60,
                            alignment: pw.Alignment.center,
                            padding:
                                const pw.EdgeInsets.only(top: 8, bottom: 2),
                            child: pw.Text(
                              '',
                              style: pw.TextStyle(
                                fontSize: fontSize_xs + 1,
                                font: ttf,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ),
                          // Bottom divider line (signature underline)
                          pw.Container(
                            width: 60,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                top: pw.BorderSide(
                                    color: PdfColors.black, width: 0.5),
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 1),
                          pw.Text(
                            '( $cname )',
                            style: pw.TextStyle(
                              fontSize: fontSize_xs,
                              font: ttf,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'ผู้จ่ายเงิน / Payer',
                            style: pw.TextStyle(
                              fontSize: fontSize_xs,
                              font: ttf,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 2),

                  // ── Thank you message ──
                  pw.Text(
                    'ขอบคุณที่ใช้บริการ / Thank you',
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 1),

                  // ── Disclaimer: not a tax invoice ──
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      border:
                          pw.Border.all(color: PdfColors.grey400, width: 0.5),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      'เอกสารนี้ไม่ใช่ใบกำกับภาษีอิเล็กทรอนิกส์\nThis receipt is not a tax invoice',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: fontSize_xs,
                        font: ttf,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        // footer: (context) {
        //   // ───────── Phase 4: minimal POS footer ─────────
        //   // • คำขอบคุณ
        //   // • Disclaimer: เอกสารนี้ไม่ใช่ใบกำกับภาษีอิเล็กทรอนิกส์
        //   // • Signature (optional) + name of authorized person
        //   // • Page indicator for long receipts

        //   // Page indicator (e.g. page 1/3)
        //   final isLastPage = context.pageNumber == context.pagesCount;

        //   return pw.Container(
        //     width: double.infinity,
        //     padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        //     decoration: const pw.BoxDecoration(
        //       border: pw.Border(
        //         top: pw.BorderSide(color: PdfColors.black, width: 0.5),
        //       ),
        //     ),
        //     child: pw.Column(
        //       crossAxisAlignment: pw.CrossAxisAlignment.center,
        //       children: [
        //         // ── Page indicator (subtle) ──
        //         if (!isLastPage)
        //           pw.Text(
        //             'หน้า ${context.pageNumber}/${context.pagesCount}',
        //             style: pw.TextStyle(
        //               fontSize: fontSize_xs,
        //               font: ttf,
        //               color: PdfColors.grey600,
        //             ),
        //           ),

        //         pw.SizedBox(height: 2),

        //         // ── Thank you message ──
        //         pw.Text(
        //           'ขอบคุณที่ใช้บริการ / Thank you',
        //           style: pw.TextStyle(
        //             fontSize: font_Size,
        //             font: ttf,
        //             fontWeight: pw.FontWeight.bold,
        //           ),
        //         ),

        //         pw.SizedBox(height: 1),

        //         // ── Disclaimer: not a tax invoice ──
        //         pw.Container(
        //           padding:
        //               const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        //           decoration: pw.BoxDecoration(
        //             border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
        //             borderRadius:
        //                 const pw.BorderRadius.all(pw.Radius.circular(4)),
        //           ),
        //           child: pw.Text(
        //             'เอกสารนี้ไม่ใช่ใบกำกับภาษีอิเล็กทรอนิกส์\nThis receipt is not a tax invoice',
        //             textAlign: pw.TextAlign.center,
        //             style: pw.TextStyle(
        //               fontSize: fontSize_xs,
        //               font: ttf,
        //               color: PdfColors.grey800,
        //             ),
        //           ),
        //         ),

        //         // ── Signature (only for billingFormat='มี') ──
        //         if (billingFormat == 'มี' &&
        //             signatureBytes != null &&
        //             signatureBytes.isNotEmpty) ...[
        //           pw.SizedBox(height: 2),
        //           pw.Container(
        //             width: 60,
        //             height: 30,
        //             decoration: pw.BoxDecoration(
        //               border:
        //                   pw.Border.all(color: PdfColors.grey400, width: 0.5),
        //             ),
        //             child: pw.Image(
        //               pw.MemoryImage(signatureBytes),
        //               fit: pw.BoxFit.contain,
        //             ),
        //           ),
        //           pw.SizedBox(height: 1),
        //           pw.Container(
        //             width: 100,
        //             decoration: const pw.BoxDecoration(
        //               border: pw.Border(
        //                 top: pw.BorderSide(color: PdfColors.black, width: 0.5),
        //               ),
        //             ),
        //           ),
        //           pw.SizedBox(height: 1),
        //           pw.Text(
        //             '( $fullname )',
        //             style: pw.TextStyle(
        //               fontSize: fontSize_xs,
        //               font: ttf,
        //               fontWeight: pw.FontWeight.bold,
        //             ),
        //           ),
        //           pw.Text(
        //             'ผู้รับเงิน / Receiver',
        //             style: pw.TextStyle(
        //               fontSize: fontSize_xs,
        //               font: ttf,
        //               color: PdfColors.grey600,
        //             ),
        //           ),
        //         ],
        //       ],
        //     ),
        //   );
        // },
      ),
    );

    if (Preview_ser.toString() == 'Folder') {
      final List<int> bytes = await pdf.save(); // Save the PDF as bytes
      final Uint8List data = Uint8List.fromList(bytes); // Convert to Uint8List
      var name_1 = (numdoctax.toString() == '')
          ? 'ใบเสร็จรับเงิน $numinvoice'
          : 'ใบเสร็จรับเงิน/ใบกำกับภาษี $numdoctax';
      // Upload the file
      await uploadFile(data, name_1);
    } else if (Preview_ser.toString() == 'File') {
      // final List<int> bytes = await pdf.save();
      // final Uint8List data = Uint8List.fromList(bytes);
      // MimeType type = MimeType.PDF;
      // final dir = await FileSaver.instance.saveFile(
      //     (numdoctax.toString() == '')
      //         ? 'ใบเสร็จรับเงิน $numinvoice'
      //         : 'ใบเสร็จรับเงิน/ใบกำกับภาษี $numdoctax',
      //     data,
      //     "pdf",
      //     mimeType: type);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewPdfgen_Billsplay(
                selectedMode: pageMode,
                doc: pdf,
                title: (TitleType_Default_Receipt_Name == null)
                    ? (numdoctax.toString() == '')
                        ? 'ใบเสร็จรับเงิน $numinvoice'
                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี $numdoctax'
                    : (numdoctax.toString() == '')
                        ? 'ใบเสร็จรับเงิน [ $TitleType_Default_Receipt_Name ]$numinvoice'
                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี [ $TitleType_Default_Receipt_Name ]$numdoctax'),
          ));
    }
  }

  // ────────────────────────────────────────────────────────
  // Helper functions for the rewritten 60mm POS body (Phase 3)
  // ────────────────────────────────────────────────────────

  /// Check if a numeric/dynamic value is a non-zero number
  static bool _hasValue(dynamic v) {
    if (v == null) return false;
    final d = double.tryParse(v.toString());
    return d != null && d > 0;
  }

  /// Generic header row: 'Label : value' (left aligned) — for full-info header
  static pw.Widget _headerRow(
    String label,
    String value, {
    required double fontSize,
    required pw.Font ttf,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              font: ttf,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              maxLines: 2,
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: fontSize,
                font: ttf,
                fontWeight: pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Header cell — bold, centered
  static pw.Widget _th(String text,
      {pw.Alignment align = pw.Alignment.center,
      required double fontSize,
      required pw.Font ttf}) {
    return pw.Container(
      height: 18,
      padding: const pw.EdgeInsets.symmetric(horizontal: 2),
      alignment: align,
      child: pw.Text(
        text,
        textAlign: align == pw.Alignment.centerRight
            ? pw.TextAlign.right
            : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: fontSize,
          font: ttf,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
    );
  }

  /// Data cell
  static pw.Widget _td(String text,
      {pw.Alignment align = pw.Alignment.centerRight,
      int maxLines = 1,
      bool bold = false,
      required double fontSize,
      required pw.Font ttf}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2.0),
      child: pw.Align(
        alignment: align,
        child: pw.Text(
          text,
          maxLines: maxLines,
          textAlign: align == pw.Alignment.centerRight
              ? pw.TextAlign.right
              : pw.TextAlign.left,
          style: pw.TextStyle(
            fontSize: fontSize,
            font: ttf,
            color: PdfColors.grey800,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Summary row (label + value, right-aligned)
  static pw.Widget _sumRow(String label, String value,
      {bool bold = false,
      bool divider = false,
      required double fontSize,
      required pw.Font ttf}) {
    return pw.Container(
      decoration: divider
          ? const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.black, width: 0.5),
              ),
            )
          : null,
      padding: const pw.EdgeInsets.symmetric(vertical: 1, horizontal: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                fontSize: fontSize,
                font: ttf,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              )),
          pw.Text(value,
              style: pw.TextStyle(
                fontSize: fontSize,
                font: ttf,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              )),
        ],
      ),
    );
  }
}
