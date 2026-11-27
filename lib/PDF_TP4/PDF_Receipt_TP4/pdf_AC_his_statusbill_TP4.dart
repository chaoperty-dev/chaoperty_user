import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty_user/File_s.dart';
import 'package:chaoperty_user/PDF/ThaiBaht.dart';
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

import '../../CRC_16_Prompay/generate_qrcode.dart';
import '../../Constant/Myconstant.dart';
import '../../Man_PDF/Man_Pay_Receipt_PDF.dart';
import '../../Man_PDF/Man_Temporary_Receipt_PDF.dart';
import '../../Man_PDF/Preview_PDF/PreviewPdfgen_Billsplay.dart';
import '../../Model/trans_re_bill_history_model.dart';

class Pdfgen_his_statusbill_TP4 {
//////////---------------------------------------------------->(ใบเสร็จรับเงิน/ใบกำกับภาษี)   ใช้  //

  static void exportPDF_statusbill_TP4(
      List<TransReBillHistoryModel> TransReBillHistory,
      Cust_no,
      cid_s,
      Zone_s,
      Ln_s,
      fname,
      foder,
      tableData00,
      tableData01,
      context,
      _TransReBillHistoryModels,
      Num_cid,
      Namenew,
      sum_pvat,
      sum_vat,
      sum_wht,
      Sum_SubTotal,
      sum_disp,
      sum_disamt,
      Total,
      renTal_name,
      sname,
      cname,
      addr,
      tax,
      bill_addr,
      bill_email,
      bill_tel,
      bill_tax,
      bill_name,
      newValuePDFimg,
      numinvoice,
      numdoctax,
      ref_invoice,
      finnancetransModels,
      date_Transaction,
      dayfinpay,
      type_bills,
      dis_sum_Matjum,
      TitleType_Default_Receipt_Name,
      dis_sum_Pakan,
      sum_fee,
      com_ment,
      fonts_pdf,
      Preview_ser,
      Con_remark,
      signature,
      fullname,
      billingFormat) async {
    ////
    //// ------------>(ใบเสร็จรับเงินชั่วคราว paySrsscreen_)
    // ------------------------------------------------------->
    // แสดง Dialog เลือกขนาดกระดาษก่อน Export
    final String? _selectedMode =
        await ManPay_Receipt_PDF.showPageFormatDialog(context as BuildContext);
    if (_selectedMode == null) return; // ผู้ใช้กด Cancel → หยุดทันที
    // ------------------------------------------------------->
    final pdf = pw.Document();
    final font = await rootBundle.load("${fonts_pdf}");
    var Colors_pd = PdfColors.black;
    const PdfColor PDF_Border_Color = PDFConstants.borderColor;
    // final font = await rootBundle.load("fonts/Sarabun-Medium.ttf");

    int pageCount = 1; // Initialize the page count
    final ttf = pw.Font.ttf(font);

    // ─────────────────────────────────────────────────────
    // โหมดกระดาษจาก Dialog
    // 'pos80' | 'pos58' | 'a3' | 'a4' | 'a5'
    final String pageMode = _selectedMode;
    final bool isPos = pageMode == 'pos80' || pageMode == 'pos58';

    // ── Responsive layout variables ─────────────────────
    // font_Size  : ขนาดตัวอักษรหลัก
    // logoSize   : ขนาด logo สี่เหลี่ยม
    // infoGapMm  : ช่องว่างระหว่าง logo กับ info text
    // ────────────────────────────────────────────────────
    // ── Responsive layout variables ─────────────────────
    final double font_Size = () {
      switch (pageMode) {
        case 'pos58':
          return 5.5;
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

    final int _logoPx = () {
      switch (pageMode) {
        case 'a3':
          return 300;
        case 'pos58':
          return 96;
        case 'pos80':
          return 120;
        case 'a5':
          return 150;
        case 'a4':
        default:
          return 180;
      }
    }();
    final double logoSize = isPos ? 32.0 : 60.0;
    final double infoGapMm = isPos ? 1.5 : 6.0;

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
            '${MyConstant().domain_chao_img}/files/$foder/payment/${finnancetransModels[i].img}'));
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
        'width': 25.0
      },
      {'label': 'กำหนดชำระ', 'flex': 1, 'align': pw.Alignment.centerLeft},
      {'label': 'รายการ', 'flex': 4, 'align': pw.Alignment.centerLeft},
      {'label': 'จำนวน', 'flex': 1, 'align': pw.Alignment.centerRight},
      {'label': 'หน่วย', 'flex': 1, 'align': pw.Alignment.centerRight},
      {'label': 'ก่อนVAT', 'flex': 1, 'align': pw.Alignment.centerRight},
      {'label': 'VAT', 'flex': 1, 'align': pw.Alignment.centerRight},
      {'label': 'WHT', 'flex': 1, 'align': pw.Alignment.centerRight},
      // {'label': 'VAT', 'flex': 1, 'align': pw.Alignment.centerRight},
      // {'label': 'WHT', 'flex': 1, 'align': pw.Alignment.centerRight},
      // {'label': 'ก่อนVAT', 'flex': 2, 'align': pw.Alignment.centerRight},

      {'label': 'ส่วนลด', 'flex': 1, 'align': pw.Alignment.centerRight},
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
          final sigUrl = '${MyConstant().domain_chao}/${signature}';
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
        _TransReBillHistoryModels, (e) => e.amt.toString() ?? '0'));
    final totalPvat = roundMoney(getTotalByField(
        _TransReBillHistoryModels, (e) => e.pvat.toString() ?? '0'));
    final totalVat = roundMoney(getTotalByField(
        _TransReBillHistoryModels, (e) => e.vat.toString() ?? '0'));
    final totalWht = roundMoney(getTotalByField(
        _TransReBillHistoryModels, (e) => e.wht.toString() ?? '0'));
    final totalLine = roundMoney(getTotalByField(
        _TransReBillHistoryModels, (e) => e.total.toString() ?? '0'));

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
    //  เพิ่ม safety buffer 40% เพื่อป้องกัน text wrap / image
    //  ทำให้เนื้อหาอยู่หน้าเดียว ไม่แตกหน้า 2
    final int _itemCount = _TransReBillHistoryModels.length;
    final double _rowH = font_Size * 5.5; // ต่อแถว (รวม wrap)
    final double _posH = isPos
        ? ((logoSize // header logo
                    +
                    90 // header info + doc title
                    +
                    15 // divider
                    +
                    100 // customer info block
                    +
                    28 // table header
                    +
                    (_itemCount * _rowH) // table rows (generous)
                    +
                    200 // summary / totals section
                    +
                    180 // footer (หมายเหตุ + ลงชื่อ)
                    +
                    60 // padding รวม
                ) *
                1.4 // safety buffer +40%
            )
            .clamp(500, 4500) // ต่ำสุด 500pt, สูงสุด 4500pt
        : 5000.0; // non-POS ไม่ใช้ค่านี้

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

    pdf.addPage(
      pw.MultiPage(
        pageFormat: buildFormat(),
        header: (context) {
          return pw.Column(children: [
            pw.Row(
              children: [
                pw.Container(
                  height: 60,
                  width: 60,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: resizedLogo != null
                      ? pw.Image(
                          pw.MemoryImage(resizedLogo),
                          height: 60,
                          width: 60,
                        )
                      : pw.Center(
                          child: pw.Text(
                            '$bill_name ',
                            maxLines: 1,
                            style: pw.TextStyle(
                              fontSize: 10,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                ),
                pw.SizedBox(width: 6 * PdfPageFormat.mm),
                pw.Container(
                  width: 200,
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '$bill_name',
                        //'$',
                        maxLines: 2,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          // fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                      pw.Text(
                        (bill_addr == null ||
                                bill_addr.toString() == 'null' ||
                                bill_addr.toString() == '')
                            ? 'ที่อยู่ : -'
                            : 'ที่อยู่ : $bill_addr',
                        maxLines: 3,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          color: Colors_pd,
                          font: ttf,
                        ),
                      ),
                      // pw.Text(
                      //   'โทรศัพท์ : $bill_tel',
                      //   textAlign: pw.TextAlign.right,
                      //   maxLines: 1,
                      //   style: pw.TextStyle(
                      //     fontSize: font_Size,
                      //     font: ttf,
                      //     color: Colors_pd,
                      //   ),
                      // ),
                      // pw.Text(
                      //   'อีเมล : $bill_email',
                      //   maxLines: 1,
                      //   textAlign: pw.TextAlign.right,
                      //   style: pw.TextStyle(
                      //     fontSize: font_Size,
                      //     font: ttf,
                      //     color: Colors_pd,
                      //   ),
                      // ),
                      pw.Text(
                        (bill_tax.toString() == '' || bill_tax == null)
                            ? 'เลขประจำตัวผู้เสียภาษี : 0'
                            : 'เลขประจำตัวผู้เสียภาษี : $bill_tax',
                        // textAlign: pw.TextAlign.justify,
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Container(
                  width: 180,
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      // if (TitleType_Default_Receipt_Name != null &&
                      //     TitleType_Default_Receipt_Name.toString().trim() !=
                      //         '' &&
                      //     TitleType_Default_Receipt_Name.toString() !=
                      //         'ไม่ระบุ')
                      //   pw.Text(
                      //     '[ $TitleType_Default_Receipt_Name ]',
                      //     maxLines: 1,
                      //     style: pw.TextStyle(
                      //       fontSize: font_Size + 2,
                      //       font: ttf,
                      //       color: PdfColors.grey400,
                      //     ),
                      //   ),
                      // pw.SizedBox(
                      //   height: 6,
                      // ),
                      // (hasNonCashTransaction1)
                      //     ? pw.Text(
                      //         (TitleType_Default_Receipt_Name != null &&
                      //                 TitleType_Default_Receipt_Name.toString()
                      //                         .trim() !=
                      //                     '' &&
                      //                 TitleType_Default_Receipt_Name
                      //                         .toString() !=
                      //                     'ไม่ระบุ')
                      //             ? (numdoctax.toString() == '')
                      //                 ? 'บิลเงินสด [ $TitleType_Default_Receipt_Name ]'
                      //                 : 'บิลเงินสด/ใบกำกับภาษี [ $TitleType_Default_Receipt_Name ]'
                      //             : (numdoctax.toString() == '')
                      //                 ? 'บิลเงินสด'
                      //                 : 'บิลเงินสด/ใบกำกับภาษี',
                      //         maxLines: 1,
                      //         textAlign: pw.TextAlign.right,
                      //         style: pw.TextStyle(
                      //           fontSize: font_Size,
                      //           fontWeight: pw.FontWeight.bold,
                      //           font: ttf,
                      //           color: Colors_pd,
                      //         ),
                      //       )
                      //     : pw.Text(
                      //         (TitleType_Default_Receipt_Name != null &&
                      //                 TitleType_Default_Receipt_Name.toString()
                      //                         .trim() !=
                      //                     '' &&
                      //                 TitleType_Default_Receipt_Name
                      //                         .toString() !=
                      //                     'ไม่ระบุ')
                      //             ? (numdoctax.toString() == '')
                      //                 ? 'ใบเสร็จรับเงิน [ $TitleType_Default_Receipt_Name ]'
                      //                 : 'ใบเสร็จรับเงิน/ใบกำกับภาษี [ $TitleType_Default_Receipt_Name ]'
                      //             : (numdoctax.toString() == '')
                      //                 ? 'ใบเสร็จรับเงิน'
                      //                 : 'ใบเสร็จรับเงิน/ใบกำกับภาษี',
                      //         maxLines: 1,
                      //         textAlign: pw.TextAlign.right,
                      //         style: pw.TextStyle(
                      //           fontSize: font_Size,
                      //           fontWeight: pw.FontWeight.bold,
                      //           font: ttf,
                      //           color: Colors_pd,
                      //         ),
                      //       ),
                      // pw.Text(
                      //   (numdoctax.toString() == '')
                      //       ? 'เลขที่ชำระ : $numinvoice'
                      //       : 'เลขที่ชำระ : $numdoctax',
                      //   maxLines: 2,
                      //   textAlign: pw.TextAlign.right,
                      //   style: pw.TextStyle(
                      //     fontSize: font_Size,
                      //     font: ttf,
                      //     color: Colors_pd,
                      //   ),
                      // ),
                      // pw.Text(
                      //   'วันที่ทำรายการ : $formattedDate ${newYear}',
                      //   textAlign: pw.TextAlign.right,
                      //   maxLines: 1,
                      //   style: pw.TextStyle(
                      //     fontSize: font_Size,
                      //     font: ttf,
                      //     color: Colors_pd,
                      //   ),
                      // ),
                      // pw.Text(
                      //   (ref_invoice.length == 0)
                      //       ? ''
                      //       : 'อ้างอิงเลขที่ : ${ref_invoice.toSet().map((model) => model).join(', ')}',
                      //   // (ref_invoice == null || ref_invoice.toString() == '')
                      //   //     ? ''
                      //   //     : 'อ้างอิงเลขที่ : ${ref_invoice}',
                      //   maxLines: 3,
                      //   textAlign: pw.TextAlign.right,
                      //   style: pw.TextStyle(
                      //     fontSize: font_Size,
                      //     font: ttf,
                      //     color: Colors_pd,
                      //   ),
                      // ),

                      if (TitleType_Default_Receipt_Name != null &&
                          TitleType_Default_Receipt_Name.toString().trim() !=
                              '' &&
                          TitleType_Default_Receipt_Name.toString() !=
                              'ไม่ระบุ')
                        pw.Text(
                          '[ $TitleType_Default_Receipt_Name ]',
                          maxLines: 1,
                          style: pw.TextStyle(
                            fontSize: font_Size + 2,
                            font: ttf,
                            color: PdfColors.grey400,
                          ),
                        ),
                      pw.SizedBox(
                        height: 6,
                      ),
                      pw.Text(
                        'หน้าที่ ${context.pageNumber} / ${context.pagesCount} ',
                        textAlign: pw.TextAlign.right,
                        maxLines: 1,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(width: 5 * PdfPageFormat.mm),
                      pw.Text(
                        'โทรศัพท์ : $bill_tel',
                        textAlign: pw.TextAlign.right,
                        maxLines: 1,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        (bill_email.toString() == '' ||
                                bill_email == null ||
                                bill_email.toString() == 'null')
                            ? 'อีเมล : '
                            : 'อีเมล : $bill_email',
                        maxLines: 1,
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Divider(),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
          ]);
        },
        build: (context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                (hasNonCashTransaction1)
                    ? pw.Text(
                        (TitleType_Default_Receipt_Name != null &&
                                TitleType_Default_Receipt_Name.toString()
                                        .trim() !=
                                    '' &&
                                TitleType_Default_Receipt_Name.toString() !=
                                    'ไม่ระบุ')
                            ? (numdoctax.toString() == '')
                                ? 'บิลเงินสด'
                                : 'บิลเงินสด/ใบกำกับภาษี'
                            : (numdoctax.toString() == '')
                                ? 'บิลเงินสด'
                                : 'บิลเงินสด/ใบกำกับภาษี',
                        maxLines: 1,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      )
                    : pw.Text(
                        (TitleType_Default_Receipt_Name != null &&
                                TitleType_Default_Receipt_Name.toString()
                                        .trim() !=
                                    '' &&
                                TitleType_Default_Receipt_Name.toString() !=
                                    'ไม่ระบุ')
                            ? (numdoctax.toString() == '')
                                ? 'ใบเสร็จรับเงิน'
                                : 'ใบเสร็จรับเงิน/ใบกำกับภาษี'
                            : (numdoctax.toString() == '')
                                ? 'ใบเสร็จรับเงิน'
                                : 'ใบเสร็จรับเงิน/ใบกำกับภาษี',
                        maxLines: 1,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // pw.Text(
                      //   'นามลูกค้า/Name',
                      //   style: pw.TextStyle(
                      //     fontSize: font_Size,
                      //     fontWeight: pw.FontWeight.bold,
                      //     font: ttf,
                      //     color: Colors_pd,
                      //   ),
                      // ),
                      pw.Text(
                        // (sname.toString() == null ||
                        //         sname.toString() == '' ||
                        //         sname.toString() == 'null')
                        //     ? ' -'
                        //     : '$sname',
                        (cname != null &&
                                cname.toString().trim().isNotEmpty &&
                                cname.toString() != 'null' &&
                                cname.toString() != '-')
                            ? 'นามลูกค้า/Name : $cname'
                            : (sname != null &&
                                    sname.toString().trim().isNotEmpty &&
                                    sname.toString() != 'null' &&
                                    sname.toString() != '-')
                                ? 'นามลูกค้า/Name : $sname'
                                : '-',
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        (addr.toString() == null ||
                                addr.toString() == '' ||
                                addr.toString() == 'null')
                            ? 'ที่อยู่/Address : -'
                            : 'ที่อยู่/Address : $addr',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        (tax == null ||
                                tax.toString() == '' ||
                                tax.toString() == 'null')
                            ? 'เลขประจำตัวผู้เสียภาษี/Tax : 0'
                            : 'เลขประจำตัวผู้เสียภาษี/Tax : $tax',
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        'โซน(Zone) : $Zone_s / ห้อง( Room) : $Ln_s',
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        'หมายเหตุ/Note : $com_ment',
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 10 * PdfPageFormat.mm),
                pw.Expanded(
                  flex: 4,
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'เลขที่ชำระ/Payment No.',
                        maxLines: 2,
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        (numdoctax.toString() == '')
                            ? '$numinvoice'
                            : '$numdoctax',
                        maxLines: 2,
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        'วันที่ทำรายการ/Date',
                        textAlign: pw.TextAlign.right,
                        maxLines: 1,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        '$formattedDate ${newYear}',
                        textAlign: pw.TextAlign.right,
                        maxLines: 1,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        (ref_invoice.length == 0)
                            ? ''
                            : 'อ้างอิงเลขที่/Ref No.',
                        // (ref_invoice == null || ref_invoice.toString() == '')
                        //     ? ''
                        //     : 'อ้างอิงเลขที่ : ${ref_invoice}',
                        maxLines: 3,
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        (ref_invoice.length == 0)
                            ? ''
                            : '${ref_invoice.toSet().map((model) => model).join(', ')}',
                        // (ref_invoice == null || ref_invoice.toString() == '')
                        //     ? ''
                        //     : 'อ้างอิงเลขที่ : ${ref_invoice}',
                        maxLines: 3,
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        (type_bills.toString().trim() == '' ||
                                type_bills == null)
                            ? ''
                            : 'ประเภท ( ล็อคเสียบ )',
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                          color: Colors_pd,
                        ),
                      ),
                    ],
                  ),
                ),
                // if (type_bills.toString().trim() != '' || type_bills != null)
                //   pw.SizedBox(width: 10 * PdfPageFormat.mm),
                // pw.Expanded(
                //   flex: 4,
                //   child: pw.Column(
                //     mainAxisSize: pw.MainAxisSize.min,
                //     crossAxisAlignment: pw.CrossAxisAlignment.start,
                //     children: [
                //       pw.Text(
                //         (type_bills.toString().trim() == '' ||
                //                 type_bills == null)
                //             ? ''
                //             : 'ประเภท ( ล็อคเสียบ )',
                //         textAlign: pw.TextAlign.justify,
                //         style: pw.TextStyle(
                //           fontSize: font_Size,
                //           font: ttf,
                //           fontWeight: pw.FontWeight.bold,
                //           color: Colors_pd,
                //         ),
                //       ),
                //       // pw.Row(children: [
                //       //   pw.Text(
                //       //     'พื้นที่ : ',
                //       //     textAlign: pw.TextAlign.justify,
                //       //     style: pw.TextStyle(
                //       //       fontSize: 8,
                //       //       font: ttf,
                //       //       fontWeight: pw.FontWeight.bold,
                //       //       color: Colors_pd,
                //       //     ),
                //       //   ),
                //       //   pw.Expanded(
                //       //     flex: 4,
                //       //     child: pw.Text(
                //       //       (area_ == null || area_.toString() == '')
                //       //           ? '-'
                //       //           : '${area_}',
                //       //       // textAlign: pw.TextAlign.justify,
                //       //       style: pw.TextStyle(
                //       //         fontSize: 8,
                //       //         font: ttf,
                //       //         color: Colors_pd,
                //       //       ),
                //       //     ),
                //       //   ),
                //       // ]),
                //     ],
                //   ),
                // ),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.Text(
                    'รูปแบบชำระ',
                    textAlign: pw.TextAlign.justify,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      color: Colors_pd,
                    ),
                  ),
                ),
                pw.SizedBox(width: 10 * PdfPageFormat.mm),
                pw.Expanded(
                  flex: 4,
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        (dayfinpay.toString() == '' ||
                                dayfinpay.toString() == 'null' ||
                                dayfinpay == null)
                            ? 'วันที่ชำระ/Payment Date : - '
                            : 'วันที่ชำระ/Payment Date : ${DateFormat('dd-MM').format(DateTime.parse('${dayfinpay}'))}-${DateTime.parse(dayfinpay).year + 543}',
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < finnancetransModels.length; i++)
                        if (finnancetransModels[i].dtype.toString() != 'FTA')
                          pw.Row(
                            children: [
                              (finnancetransModels[i].dtype.toString() == 'KP')
                                  ? pw.Expanded(
                                      flex: 1,
                                      child: pw.Container(
                                        // decoration: pw.BoxDecoration(
                                        //   color: PdfColors.green100,
                                        //   // border: pw.Border(
                                        //   //   bottom: pw.BorderSide(
                                        //   //       color: PdfColors.green900),
                                        //   // ),
                                        // ),
                                        child: pw.Text(
                                          (finnancetransModels[i]
                                                      .type
                                                      .toString() ==
                                                  'CASH')
                                              ? '${i + 1}.เงินสด : ${nFormat.format(double.parse(finnancetransModels[i].amt!.toString()))} บาท (~${convertToThaiBaht(double.parse(finnancetransModels[i].amt!.toString()))}~)'
                                              : '${i + 1}.เงินโอน : ${nFormat.format(double.parse(finnancetransModels[i].amt!.toString()))} บาท  (~${convertToThaiBaht(double.parse(finnancetransModels[i].amt!.toString()))}~)',
                                          textAlign: pw.TextAlign.justify,
                                          style: pw.TextStyle(
                                            fontSize: font_Size,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: Colors_pd,
                                          ),
                                        ),
                                      ))
                                  : pw.Expanded(
                                      flex: 1,
                                      child: pw.Container(
                                        // decoration: pw.BoxDecoration(
                                        //   color: PdfColors.green100,
                                        //   // border: pw.Border(
                                        //   //   bottom: pw.BorderSide(
                                        //   //       color: PdfColors.green900),
                                        //   // ),
                                        // ),
                                        child: pw.Text(
                                          '${i + 1}.${finnancetransModels[i].remark} : ${nFormat.format(double.parse(finnancetransModels[i].amt!.toString()))} บาท  (~${convertToThaiBaht(double.parse(finnancetransModels[i].amt!.toString()))}~)',
                                          textAlign: pw.TextAlign.justify,
                                          style: pw.TextStyle(
                                            fontSize: font_Size,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: Colors_pd,
                                          ),
                                        ),
                                      )),
                            ],
                          )
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),

            //////////////---------------------------------->
            pw.Container(
                decoration: const pw.BoxDecoration(
                  // color: PdfColors.green100,
                  border: pw.Border(
                    top: pw.BorderSide(color: PDF_Border_Color),
                    bottom: pw.BorderSide(color: PDF_Border_Color),
                  ),
                ),
                child: pw.Row(
                  children: headerColumns.map((col) {
                    final label = col['label'] as String;
                    final flex = col['flex'] as int;
                    final align = col['align'] as pw.Alignment;
                    final width = col['width'] as double?;

                    final container = pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          left: (label == 'ยอดสุทธิ')
                              ? pw.BorderSide.none
                              : const pw.BorderSide(color: PDF_Border_Color),
                          right: const pw.BorderSide(color: PDF_Border_Color),
                        ),
                      ),
                      height: 20,
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Align(
                        alignment: align,
                        child: pw.Text(
                          label,
                          maxLines: 1,
                          textAlign: (align == pw.Alignment.centerRight)
                              ? pw.TextAlign.right
                              : pw.TextAlign.left,
                          style: pw.TextStyle(
                            fontSize: font_Size,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                    );

                    if (width != null && flex == 0) {
                      return pw.Container(
                        width: width,
                        height: 20,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            left: pw.BorderSide(color: PDF_Border_Color),
                          ),
                        ),
                        padding: const pw.EdgeInsets.all(2.0),
                        child: container.child,
                      );
                    }

                    return pw.Expanded(flex: flex, child: container);
                  }).toList(),
                )),

            pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PDF_Border_Color),
                ),
              ),
            ),

            pw.Table(
              border: pw.TableBorder(
                left: pw.BorderSide(color: PDF_Border_Color),
                right: pw.BorderSide(color: PDF_Border_Color),
                verticalInside: pw.BorderSide(color: PDF_Border_Color),
                horizontalInside: pw.BorderSide(color: PDF_Border_Color),
              ),
              columnWidths: {
                0: pw.FixedColumnWidth(25),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(4),
                3: pw.FlexColumnWidth(1),
                4: pw.FlexColumnWidth(1),
                5: pw.FlexColumnWidth(1),
                6: pw.FlexColumnWidth(1),
                7: pw.FlexColumnWidth(1),
                8: pw.FlexColumnWidth(1),
                9: pw.FlexColumnWidth(2),
              },
              children: List.generate(TransReBillHistory.length, (index) {
                final TransReBill = TransReBillHistory[index];

                return pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Align(
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          '${index + 1}',
                          maxLines: 2,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: PdfColors.grey800),
                        ),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          (TransReBill.date == null ||
                                  TransReBill.date.toString() == '')
                              ? '-'
                              : '${DateFormat('dd-MM').format(DateTime.parse(TransReBill.date.toString()))}-${DateTime.parse(TransReBill.date.toString()).year + 543}',
                          maxLines: 2,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: PdfColors.grey800),
                        ),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          (TransReBill.unitser.toString() == '6')
                              ? '${TransReBill.expname} ${DateFormat('MMM', 'th').format(DateTime.parse(TransReBill.date!))} ${DateTime.parse('${TransReBill.date}').year + 543} [ หน่วยที่ใช้ไป ${TransReBill.ovalue}-${TransReBill.nvalue} ]'
                              : '${TransReBill.expname} ${DateFormat('MMM', 'th').format(DateTime.parse(TransReBill.date!))} ${DateTime.parse('${TransReBill.date}').year + 543}',
                          maxLines: 3,
                          textAlign: pw.TextAlign.left,
                          style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: PdfColors.grey800),
                        ),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          getFormattedText(TransReBill.qty),
                          maxLines: 2,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: PdfColors.grey800),
                        ),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          (TransReBill.ele_ty.toString() != '0' &&
                                  TransReBill.ele_ty != null)
                              ? 'อัตราพิเศษ'
                              : (TransReBill.dtype.toString() == 'KU')
                                  ? getFormattedText('${TransReBill.pri}')
                                  : '-',
                          maxLines: 2,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: PdfColors.grey800),
                        ),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          getFormattedText('${TransReBill.pvat}'),
                          maxLines: 2,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: PdfColors.grey800),
                        ),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          getFormattedText(TransReBill.vat),
                          maxLines: 2,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: PdfColors.grey800),
                        ),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          getFormattedText(TransReBill.wht),
                          maxLines: 2,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: PdfColors.grey800),
                        ),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          getFormattedText('${TransReBill.dis_list}'),
                          maxLines: 2,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: PdfColors.grey800),
                        ),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          getFormattedText('${TransReBill.total}'),
                          maxLines: 2,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: PdfColors.grey800),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),

            // pw.Divider(color: PdfColors.grey),
            pw.Container(
              decoration: const pw.BoxDecoration(
                // color: PdfColors.green100,
                border: pw.Border(
                  top: pw.BorderSide(color: PDF_Border_Color),
                ),
              ),
              padding: const pw.EdgeInsets.fromLTRB(0, 4, 0, 0),
              alignment: pw.Alignment.centerRight,
              child: pw.Row(
                children: [
                  if (Con_remark.toString() != '' && Con_remark != null)
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4.0),
                      child: pw.Text(
                        '# หมายเหตุ : $Con_remark',
                        style: pw.TextStyle(
                            fontSize: font_Size,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf,
                            color: PdfColors.grey800),
                      ),
                    ),
                  pw.Spacer(flex: 6),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // SubTotal, Vat, Deduct, Sum_SubTotal, DisC, Total
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'รวมราคาสินค้า/Sub Total',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                            pw.Text(
                              '${nFormat.format(totalPvat)}',
                              // '${nFormat.format(double.parse(sum_pvat.toString()))}',
                              // '${sum_pvat}',
                              // '$SubTotal',
                              style: pw.TextStyle(
                                  fontSize: font_Size,
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttf,
                                  color: PdfColors.grey800),
                            ),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'ภาษีมูลค่าเพิ่ม/Vat',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                            pw.Text(
                              '${nFormat.format(totalVat)}',
                              // '${nFormat.format(double.parse(sum_vat.toString()))}',
                              // '${sum_vat}',
                              // '$Vat',
                              style: pw.TextStyle(
                                  fontSize: font_Size,
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttf,
                                  color: PdfColors.grey800),
                            ),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'หัก ณ ที่จ่าย',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                            pw.Text(
                              '${nFormat.format(totalWht)}',
                              // '${nFormat.format(double.parse(sum_wht.toString()))}',
                              // '${sum_wht}',
                              // '$Deduct',
                              style: pw.TextStyle(
                                  fontSize: font_Size,
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttf,
                                  color: PdfColors.grey800),
                            ),
                          ],
                        ),
                        if (totalFee != 0.00)
                          pw.Row(
                            children: [
                              pw.Expanded(
                                child: pw.Text(
                                  'ค่าธรรมเนียม',
                                  style: pw.TextStyle(
                                      fontSize: font_Size,
                                      fontWeight: pw.FontWeight.bold,
                                      font: ttf,
                                      color: PdfColors.grey800),
                                ),
                              ),
                              pw.Text(
                                '${nFormat.format(totalFee)}',
                                // '${nFormat.format(double.parse(sum_fee.toString()))}',
                                // '$Sum_SubTotal',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ],
                          ),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'ยอดรวม',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                            pw.Text(
                              '${nFormat.format(roundMoney((totalPvat + totalVat) - totalWht) + totalFee)}',
                              // '${nFormat.format(double.parse(Sum_SubTotal.toString()) + double.parse(sum_fee.toString()))}',
                              // '$Sum_SubTotal',
                              style: pw.TextStyle(
                                  fontSize: font_Size,
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttf,
                                  color: PdfColors.grey800),
                            ),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'ส่วนลด/Discount',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                            pw.Text(
                              '${nFormat.format(totalDis)}',
                              // '${nFormat.format(double.parse(sum_disamt.toString()))}',
                              // '${sum_disamt}',
                              // '$DisC',
                              style: pw.TextStyle(
                                  fontSize: font_Size,
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttf,
                                  color: PdfColors.grey800),
                            ),
                          ],
                        ),
                        if (nFormat
                                .format(double.parse(dis_sum_Matjum.toString()))
                                .toString() !=
                            '0.00')
                          pw.Row(
                            children: [
                              pw.Expanded(
                                child: pw.Text(
                                  'เงินมัดจำ(ตัดมัดจำ)',
                                  //  'เงินมัดจำ(${nFormat.format(sum_matjum)})',
                                  style: pw.TextStyle(
                                      fontSize: font_Size,
                                      fontWeight: pw.FontWeight.bold,
                                      font: ttf,
                                      color: PdfColors.grey800),
                                ),
                              ),
                              pw.Text(
                                dis_sum_Matjum == 0.00
                                    ? '${nFormat.format(double.parse(dis_sum_Matjum.toString()))}'
                                    : '${nFormat.format(double.parse(dis_sum_Matjum.toString()))}',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ],
                          ),
                        if (nFormat
                                .format(double.parse(dis_sum_Pakan.toString()))
                                .toString() !=
                            '0.00')
                          pw.Row(
                            children: [
                              pw.Expanded(
                                child: pw.Text(
                                  'เงินประกัน(ตัดเงินประกัน)',
                                  //  'เงินมัดจำ(${nFormat.format(sum_matjum)})',
                                  style: pw.TextStyle(
                                      fontSize: font_Size,
                                      fontWeight: pw.FontWeight.bold,
                                      font: ttf,
                                      color: PdfColors.grey800),
                                ),
                              ),
                              pw.Text(
                                dis_sum_Pakan == 0.00
                                    ? '${nFormat.format(double.parse(dis_sum_Pakan.toString()))}'
                                    : '${nFormat.format(double.parse(dis_sum_Pakan.toString()))}',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ],
                          ),
                        pw.Divider(color: PDF_Border_Color),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'ยอดชำระ',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                            pw.Text(
                              '${nFormat.format(totalBill)}',
                              // '${nFormat.format((double.parse(Total.toString()) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}',
                              style: pw.TextStyle(
                                  fontSize: font_Size,
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttf,
                                  color: PdfColors.grey800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Container(
                height: 25,
                decoration: const pw.BoxDecoration(
                  // color: PdfColors.green100,
                  border: pw.Border(
                    top: pw.BorderSide(color: PDF_Border_Color),
                    bottom: pw.BorderSide(color: PDF_Border_Color),
                  ),
                ),
                alignment: pw.Alignment.centerRight,
                child: pw.Center(
                  child: pw.Row(
                    children: [
                      pw.SizedBox(width: 2 * PdfPageFormat.mm),
                      pw.Text(
                        'ตัวอักษร ',
                        style: pw.TextStyle(
                            fontSize: font_Size,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf,
                            fontStyle: pw.FontStyle.italic,
                            color: PdfColors.grey800),
                      ),
                      pw.Expanded(
                        flex: 4,
                        child: pw.Text(
                          //"${nFormat2.format(double.parse(Total.toString()))}";
                          '(~${convertToThaiBaht(totalBill)}~)',
                          style: pw.TextStyle(
                            fontSize: font_Size,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf,
                            fontStyle: pw.FontStyle.italic,
                            // decoration:
                            //     pw.TextDecoration.lineThrough,
                            color: PdfColors.grey800,
                          ),
                        ),
                      ),
                      // pw.Spacer(flex: 6),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              children: [
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Text(
                                    'ยอดรวมสุทธิ',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        font: ttf,
                                        fontSize: font_Size,
                                        color: PdfColors.grey800),
                                  ),
                                ),
                                pw.Text(
                                  '${nFormat.format(totalBill)}',
                                  // '${Total}',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      font: ttf,
                                      fontSize: font_Size,
                                      color: PdfColors.grey800),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            pw.SizedBox(height: 5 * PdfPageFormat.mm),
          ];
        },

        footer: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PDF_Border_Color, width: 1),
                  ),
                  padding: pw.EdgeInsets.fromLTRB(2, 4, 2, 4),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                          flex: 2,
                          child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'หมายเหตุ : ',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.Text(
                                  (hasNonCashTransaction)
                                      ? '( / ) 1. เงินโอน, QR Code, Mobile Banking '
                                      : '(   ) 1. เงินโอน, QR Code, Mobile Banking ',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.Text(
                                  (hasNonCashTransaction)
                                      ? '      บัญชี ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.bank).join(', ')} เลขที่ ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.bno).join(', ')} [ ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => (model.ptname.toString() == 'Online Payment' ? 'PromptPay QR' : model.ptname == 'เงินโอน' ? 'เลขบัญชี' : model.ptname == 'Beam Checkout' ? 'Beam Checkout' : 'Online Standard QR')).join(', ')} ]'
                                      : '      บัญชี...................................เลขที่...................................',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                                if (hasNonCashTransaction8)
                                  pw.Text(
                                    hasNonCashTransaction7
                                        ? '      ( Ref1. ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.inv.replaceAll('-', '')).join(', ')} Ref2. ${DateFormat('ddMM').format(DateTime.parse(dayfinpay!))}${DateTime.parse('${dayfinpay}').year + 543} )'
                                        : '      ( Ref1. ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.ref1).join(', ')} Ref2. ${DateFormat('ddMM').format(DateTime.parse(dayfinpay!))}${DateTime.parse('${dayfinpay}').year + 543} )',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                pw.Row(
                                  // mainAxisAlignment:
                                  //     pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Expanded(
                                      flex: 1,
                                      child: pw.Text(
                                        (hasNonCashTransaction1)
                                            ? '( / ) 2. เงินสด'
                                            : '(   ) 2. เงินสด',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ),
                                    pw.Expanded(
                                      flex: 3,
                                      child: pw.Text(
                                        (hasNonCashTransaction ||
                                                hasNonCashTransaction1)
                                            ? '(   ) 3. อื่นๆ.............................'
                                            : '( / ) 3. อื่นๆ ${finnancetransModels.where((model) => model.ptser != '6' || model.ptser != '5' || model.ptser != '2' || model.ptser != '1' && model.dtype == 'KP').map((model) => model.bank).join(', ')}',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ])),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text(
                              'ลงชื่อ : ผู้รับบริการ',
                              textAlign: pw.TextAlign.left,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                fontWeight: pw.FontWeight.bold,
                                color: Colors_pd,
                              ),
                            ),
                            pw.Container(
                              height: 35,
                              child: pw.Stack(
                                children: [
                                  pw.Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: pw.Text(
                                      '........................................................',
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                        fontSize: font_Size,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: Colors_pd,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Text(
                              '(......................................................)',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                fontWeight: pw.FontWeight.bold,
                                color: Colors_pd,
                              ),
                            ),
                            pw.Text(
                              'วันที่/Date...........................................',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                fontWeight: pw.FontWeight.bold,
                                color: Colors_pd,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text(
                              'ลงชื่อ : ผู้รับเงิน',
                              textAlign: pw.TextAlign.left,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                fontWeight: pw.FontWeight.bold,
                                color: Colors_pd,
                              ),
                            ),
                            pw.Container(
                              height: 35,
                              child: pw.Stack(
                                children: [
                                  pw.Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: pw.Text(
                                      '........................................................',
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                        fontSize: font_Size,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: Colors_pd,
                                      ),
                                    ),
                                  ),
                                  if (signatureBytes != null &&
                                      signatureBytes.isNotEmpty)
                                    pw.Positioned(
                                      bottom: 4,
                                      left: 0,
                                      right: 0,
                                      child: pw.Center(
                                        child: pw.Image(
                                          pw.MemoryImage(signatureBytes),
                                          width: 100,
                                          height: 40,
                                          fit: pw.BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            pw.Stack(
                              children: [
                                pw.Text(
                                  '(......................................................)',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                                if (fullname != null && signatureBytes != null)
                                  pw.Positioned(
                                    left: 0,
                                    right: 0,
                                    top: -4,
                                    bottom: 10,
                                    child: pw.Text(
                                      fullname,
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                        fontSize: font_Size + 2,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: Colors_pd,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            pw.Stack(
                              children: [
                                pw.Text(
                                  'วันที่/Date...............................................',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                                if (date_Transaction != null &&
                                    signatureBytes != null)
                                  pw.Positioned(
                                    left: 15,
                                    right: 0,
                                    top: -4,
                                    bottom: 10,
                                    child: pw.Text(
                                      '${DateFormat('dd/MM').format(DateTime.parse(date_Transaction!))}/${DateTime.parse('$date_Transaction').year + 543}',
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                        fontSize: font_Size + 2,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: Colors_pd,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // pw.Expanded(
                      //     flex: 1,
                      //     child: pw.Column(
                      //         mainAxisAlignment: pw.MainAxisAlignment.start,
                      //         // crossAxisAlignment: pw.CrossAxisAlignment.center,
                      //         children: [
                      //           if (hasNonCashTransaction2)
                      //             pw.Container(
                      //               child: pw.BarcodeWidget(
                      //                   data:
                      //                       '|${finnancetransModels.where((model) => model.ptser == '6' && model.dtype == 'KP').map((model) => model.bno).join(',')}\r${numinvoice.replaceAll('-', '')}\r${DateFormat('ddMM').format(DateTime.parse(dayfinpay))}${DateTime.parse('${dayfinpay}').year + 543}\r${newTotal_QR}',
                      //                   barcode: pw.Barcode.qrCode(),
                      //                   width: 55,
                      //                   height: 55),
                      //             ),
                      //           if (hasNonCashTransaction4)
                      //             pw.BarcodeWidget(
                      //                 data: generateQRCode(
                      //                     promptPayID:
                      //                         "${finnancetransModels.where((model) => model.ptser == '5' && model.dtype == 'KP').map((model) => model.bno).join(',')}",
                      //                     amount: double.parse((Total == null ||
                      //                             Total == '')
                      //                         ? '0'
                      //                         : '${finnancetransModels.where((model) => model.ptser == '5' && model.dtype == 'KP').map((model) => model.total).join(',')}')),
                      //                 barcode: pw.Barcode.qrCode(),
                      //                 width: 55,
                      //                 height: 55),
                      //           if (hasNonCashTransaction3)
                      //             for (var i = 0;
                      //                 i < finnancetransModels.length;
                      //                 i++)
                      //               if (finnancetransModels[i]
                      //                           .ptser
                      //                           .toString() ==
                      //                       '2' &&
                      //                   finnancetransModels[i]
                      //                           .dtype
                      //                           .toString() ==
                      //                       'KP')
                      //                 pw.Image(
                      //                   (netImage_QR[i]),
                      //                   height: 55,
                      //                   width: 55,
                      //                 ),
                      //         ])),
                    ],
                  )),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(0, 2, 0, 0),
                    child: pw.Align(
                      alignment: pw.Alignment.bottomLeft,
                      child: pw.Text(
                        'พิมพ์เมื่อ : $date',
                        // textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: 7.00,
                          font: ttf,
                          color: Colors_pd,
                          // fontWeight: pw.FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(0, 2, 0, 0),
                    child: pw.Align(
                      alignment: pw.Alignment.bottomRight,
                      child: pw.Text(
                        'หน้าที่ ${context.pageNumber} / ${context.pagesCount} ',
                        // textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: 7.00,
                          font: ttf,
                          color: Colors_pd,
                          // fontWeight: pw.FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        },
        // footer: (context) {
        //   return pw.Column(
        //     mainAxisSize: pw.MainAxisSize.min,
        //     children: [
        //       (hasNonCashTransaction)
        //           ? pw.Container(
        //               decoration: pw.BoxDecoration(
        //                 border: pw.Border.all(color: PdfColors.grey, width: 1),
        //               ),
        //               child: pw.Column(
        //                 mainAxisAlignment: pw.MainAxisAlignment.center,
        //                 crossAxisAlignment: pw.CrossAxisAlignment.start,
        //                 children: [
        //                   (hasNonCashTransaction2)
        //                       ? pw.Row(
        //                           mainAxisAlignment:
        //                               pw.MainAxisAlignment.center,
        //                           children: [
        //                               pw.Expanded(
        //                                 flex: 1,
        //                                 child: pw.Container(
        //                                   padding: const pw.EdgeInsets.all(4.0),
        //                                   child: pw.Column(
        //                                     children: [
        //                                       // pw.Container(
        //                                       //     // height: 60,
        //                                       //     // width: 200,
        //                                       //     child: pw.Image(
        //                                       //   pw.MemoryImage(uint8Listthaiqr),
        //                                       //   height: 72,
        //                                       //   width: 65,
        //                                       // )),
        //                                       pw.Container(
        //                                         child: pw.BarcodeWidget(
        //                                             data:
        //                                                 '|${finnancetransModels.where((model) => model.ptser == '6').map((model) => model.bno).join(', ')}\r$numinvoice\r${DateFormat('dd-MM-yyyy').format(DateTime.parse('${dayfinpay}'))}\r${newTotal_QR}\r',
        //                                             barcode:
        //                                                 pw.Barcode.qrCode(),
        //                                             width: 55,
        //                                             height: 55),

        //                                         //  pw.PrettyQr(
        //                                         //   // typeNumber: 3,
        //                                         //   image: const AssetImage(
        //                                         //     "images/Icon-chao.png",
        //                                         //   ),
        //                                         //   size: 110,
        //                                         //   data: '${teNantModels[index].cid}',
        //                                         //   errorCorrectLevel: QrErrorCorrectLevel.M,
        //                                         //   roundEdges: true,
        //                                         // ),
        //                                       ),
        //                                       pw.Text(
        //                                         'บัญชี : ${finnancetransModels.where((model) => model.ptser == '6').map((model) => model.bno).join(', ')}',
        //                                         style: pw.TextStyle(
        //                                           font: ttf,
        //                                           fontSize: font_Size,
        //                                           fontWeight:
        //                                               pw.FontWeight.bold,
        //                                         ),
        //                                       ),

        //                                       pw.Text(
        //                                         '(Ref1 : $numinvoice , Ref2 : ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${dayfinpay}'))})',
        //                                         style: pw.TextStyle(
        //                                           font: ttf,
        //                                           fontSize: font_Size,
        //                                           fontWeight:
        //                                               pw.FontWeight.bold,
        //                                         ),
        //                                       ),
        //                                       pw.Text(
        //                                         'สำหรับชำระด้วย Mobile Banking',
        //                                         style: pw.TextStyle(
        //                                           font: ttf,
        //                                           fontSize: font_Size,
        //                                           fontWeight:
        //                                               pw.FontWeight.bold,
        //                                         ),
        //                                       ),
        //                                     ],
        //                                   ),
        //                                 ),
        //                               ),
        //                               pw.Expanded(
        //                                 flex: 1,
        //                                 child: pw.Container(
        //                                   padding: const pw.EdgeInsets.all(4.0),
        //                                   child: pw.Column(
        //                                     children: [
        //                                       pw.Text(
        //                                         'คำเตือน',
        //                                         textAlign: pw.TextAlign.left,
        //                                         style: pw.TextStyle(
        //                                             fontSize: font_Size,
        //                                             font: ttf,
        //                                             color: PdfColors.red,
        //                                             fontWeight:
        //                                                 pw.FontWeight.bold),
        //                                       ),
        //                                       pw.SizedBox(
        //                                           height: 2 * PdfPageFormat.mm),
        //                                       pw.Text(
        //                                         'โปรดตรวจสอบความถูกต้องทุกครั้งก่อนทำการชำระเงิน',
        //                                         textAlign: pw.TextAlign.left,
        //                                         maxLines: 1,
        //                                         style: pw.TextStyle(
        //                                           fontSize: font_Size,
        //                                           font: ttf,
        //                                           color: PdfColors.red,
        //                                         ),
        //                                       ),
        //                                       pw.SizedBox(
        //                                           height: 2 * PdfPageFormat.mm),
        //                                       pw.Text(
        //                                         '( หากเกิดข้อผิดพลาดโปรดเก็บหลักฐานการชำระไว้ เพื่อติดต่อเจ้าหน้าที่ )',
        //                                         textAlign: pw.TextAlign.center,
        //                                         style: pw.TextStyle(
        //                                           fontSize: font_Size,
        //                                           font: ttf,
        //                                           color: PdfColors.red,
        //                                         ),
        //                                       ),
        //                                       pw.SizedBox(
        //                                           height: 2 * PdfPageFormat.mm),
        //                                     ],
        //                                   ),
        //                                 ),
        //                               ),
        //                             ])
        //                       : pw.Row(
        //                           mainAxisAlignment:
        //                               pw.MainAxisAlignment.center,
        //                           children: [
        // for (var i = 0;
        //     i < finnancetransModels.length;
        //     i++)
        //   if (finnancetransModels[i]
        //               .ptser
        //               .toString() !=
        //           '1' &&
        //       finnancetransModels[i]
        //               .dtype
        //               .toString() !=
        //           'FTA')
        //                                   pw.Expanded(
        //                                     flex: 1,
        //                                     child: pw.Container(
        //                                       padding:
        //                                           const pw.EdgeInsets.all(4.0),
        //                                       child: pw.Column(
        //                                         children: [
        //                                           // pw.Container(
        //                                           //     // height: 60,
        //                                           //     // width: 200,
        //                                           //     child: pw.Image(
        //                                           //   pw.MemoryImage(uint8Listthaiqr),
        //                                           //   height: 72,
        //                                           //   width: 65,
        //                                           // )),
        //                                           pw.Container(
        //                                             child: (finnancetransModels[i]
        //                                                             .ptser
        //                                                             .toString() ==
        //                                                         '' ||
        //                                                     finnancetransModels[i].ptser ==
        //                                                         null ||
        //                                                     finnancetransModels[i]
        //                                                             .img ==
        //                                                         null ||
        //                                                     finnancetransModels[i]
        //                                                             .img
        //                                                             .toString() ==
        //                                                         '')
        //                                                 ?
        // pw.BarcodeWidget(
        //                                                     data: generateQRCode(
        //                                                         promptPayID:
        //                                                             "${finnancetransModels[i].bno}",
        //                                                         amount: double.parse(
        //                                                                 (Total == null || Total == '')
        //                                                                     ? '0'
        //                                                                     : '${Total}') +
        //                                                             double.parse(
        //                                                                 (sum_fee == null || sum_fee == '') ? '0' : sum_fee.toString())),
        //                                                     barcode: pw.Barcode.qrCode(),
        //                                                     width: 55,
        //                                                     height: 55)
        //                                                 :
        // pw.Image(
        //                                                     (netImage_QR[i]),
        //                                                     height: 55,
        //                                                     width: 55,
        //                                                   ),
        //                                           ),
        //                                           pw.Text(
        //                                             'บัญชี : ${finnancetransModels[i].bno}',
        //                                             style: pw.TextStyle(
        //                                               font: ttf,
        //                                               fontSize: font_Size,
        //                                               fontWeight:
        //                                                   pw.FontWeight.bold,
        //                                             ),
        //                                           ),

        //                                           pw.Text(
        //                                             'สำหรับชำระด้วย Mobile Banking',
        //                                             style: pw.TextStyle(
        //                                               font: ttf,
        //                                               fontSize: font_Size,
        //                                               fontWeight:
        //                                                   pw.FontWeight.bold,
        //                                             ),
        //                                           ),
        //                                         ],
        //                                       ),
        //                                     ),
        //                                   ),
        //                               pw.Expanded(
        //                                 flex: 1,
        //                                 child: pw.Container(
        //                                   padding: const pw.EdgeInsets.all(4.0),
        //                                   child: pw.Column(
        //                                     children: [
        //                                       pw.Text(
        //                                         'คำเตือน',
        //                                         textAlign: pw.TextAlign.left,
        //                                         style: pw.TextStyle(
        //                                             fontSize: font_Size,
        //                                             font: ttf,
        //                                             color: PdfColors.red,
        //                                             fontWeight:
        //                                                 pw.FontWeight.bold),
        //                                       ),
        //                                       pw.SizedBox(
        //                                           height: 2 * PdfPageFormat.mm),
        //                                       pw.Text(
        //                                         'โปรดตรวจสอบความถูกต้องทุกครั้งก่อนทำการชำระเงิน',
        //                                         textAlign: pw.TextAlign.left,
        //                                         maxLines: 1,
        //                                         style: pw.TextStyle(
        //                                           fontSize: font_Size,
        //                                           font: ttf,
        //                                           color: PdfColors.red,
        //                                         ),
        //                                       ),
        //                                       pw.SizedBox(
        //                                           height: 2 * PdfPageFormat.mm),
        //                                       pw.Text(
        //                                         '( หากเกิดข้อผิดพลาดโปรดเก็บหลักฐานการชำระไว้ เพื่อติดต่อเจ้าหน้าที่ )',
        //                                         textAlign: pw.TextAlign.center,
        //                                         style: pw.TextStyle(
        //                                           fontSize: font_Size,
        //                                           font: ttf,
        //                                           color: PdfColors.red,
        //                                         ),
        //                                       ),
        //                                       pw.SizedBox(
        //                                           height: 2 * PdfPageFormat.mm),
        //                                     ],
        //                                   ),
        //                                 ),
        //                               ),
        //                             ]),
        //                 ],
        //               ))
        //           : pw.Container(
        //               decoration: pw.BoxDecoration(
        //                 border: pw.Border.all(color: PdfColors.grey, width: 1),
        //               ),
        //               child: pw.Column(
        //                 mainAxisAlignment: pw.MainAxisAlignment.center,
        //                 crossAxisAlignment: pw.CrossAxisAlignment.start,
        //                 children: [
        //                   pw.Row(
        //                       mainAxisAlignment: pw.MainAxisAlignment.center,
        //                       children: [
        //                         pw.Expanded(
        //                           flex: 1,
        //                           child: pw.Container(
        //                             padding: const pw.EdgeInsets.all(4.0),
        //                             child: pw.Column(
        //                               children: [
        //                                 pw.Text(
        //                                   'หมายเหตุ ',
        //                                   textAlign: pw.TextAlign.center,
        //                                   style: pw.TextStyle(
        //                                       fontSize: font_Size,
        //                                       font: ttf,
        //                                       color: Colors_pd,
        //                                       fontWeight: pw.FontWeight.bold),
        //                                 ),
        //                                 pw.SizedBox(
        //                                     height: 2 * PdfPageFormat.mm),
        //                                 pw.Text(
        //                                   ' .' * 160,
        //                                   textAlign: pw.TextAlign.center,
        //                                   maxLines: 2,
        //                                   style: pw.TextStyle(
        //                                     fontSize: font_Size,
        //                                     font: ttf,
        //                                     color: Colors_pd,
        //                                   ),
        //                                 ),
        //                                 pw.SizedBox(
        //                                     height: 2 * PdfPageFormat.mm),
        //                               ],
        //                             ),
        //                           ),
        //                         ),
        //                         pw.Expanded(
        //                           flex: 1,
        //                           child: pw.Container(
        //                             padding: const pw.EdgeInsets.all(4.0),
        //                             child: pw.Column(
        //                               children: [
        //                                 pw.Text(
        //                                   'ผู้รับเงิน',
        //                                   textAlign: pw.TextAlign.left,
        //                                   style: pw.TextStyle(
        //                                       fontSize: font_Size,
        //                                       font: ttf,
        //                                       color: Colors_pd,
        //                                       fontWeight: pw.FontWeight.bold),
        //                                 ),
        //                                 pw.SizedBox(
        //                                     height: 2 * PdfPageFormat.mm),
        //                                 pw.Text(
        //                                   ' (..............................................)',
        //                                   textAlign: pw.TextAlign.left,
        //                                   maxLines: 1,
        //                                   style: pw.TextStyle(
        //                                     fontSize: font_Size,
        //                                     font: ttf,
        //                                     color: Colors_pd,
        //                                   ),
        //                                 ),
        //                                 pw.SizedBox(
        //                                     height: 2 * PdfPageFormat.mm),
        //                                 pw.Text(
        //                                   'วันที่........../........../..........',
        //                                   textAlign: pw.TextAlign.center,
        //                                   style: pw.TextStyle(
        //                                     fontSize: font_Size,
        //                                     font: ttf,
        //                                     color: Colors_pd,
        //                                   ),
        //                                 ),
        //                                 pw.SizedBox(
        //                                     height: 2 * PdfPageFormat.mm),
        //                               ],
        //                             ),
        //                           ),
        //                         ),
        //                       ]),
        //                 ],
        //               )),
        //       pw.SizedBox(height: 3 * PdfPageFormat.mm),
        //       pw.Align(
        //         alignment: pw.Alignment.bottomRight,
        //         child: pw.Text(
        //           'หน้า ${context.pageNumber} / ${context.pagesCount} ',
        //           textAlign: pw.TextAlign.left,
        //           style: pw.TextStyle(
        //             fontSize: 10,
        //             font: ttf,
        //             color: Colors_pd,
        //             // fontWeight: pw.FontWeight.bold
        //           ),
        //         ),
        //       )
        //     ],
        //   );
        // },
      ),
    );
    // pageCount++;
    // pdf.addPage(pw.MultiPage(build: (context) {
    //   return [
    //     pw.Center(
    //       child: pw.Column(
    //         mainAxisAlignment: pw.MainAxisAlignment.center,
    //         children: [
    //           pw.Text(
    //             'Sheet $pageCount',
    //             style: pw.TextStyle(fontSize: 20),
    //           ),
    //           pw.Text(
    //             'Page $pageCount',
    //             style: pw.TextStyle(fontSize: 16),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ];
    // }, footer: (context) {
    //   return pw.Align(
    //     alignment: pw.Alignment.bottomRight,
    //     child: pw.Text(
    //       'หน้า ${context.pageNumber} / ${context.pagesCount} ',
    //       textAlign: pw.TextAlign.left,
    //       style: pw.TextStyle(
    //         fontSize: 10,
    //         font: ttf,
    //         color: Colors_pd,
    //         // fontWeight: pw.FontWeight.bold
    //       ),
    //     ),
    //   );
    // }));
    // final bytes = await pdf.save();

    // final dir = await getApplicationDocumentsDirectory();
    // final file = File('${dir.path}/name');
    // await file.writeAsBytes(bytes);
    // return file;
    ///-------------------------------------------------->
    // final List<int> bytes = await pdf.save();
    // final Uint8List data = Uint8List.fromList(bytes);
    // MimeType type = MimeType.PDF;
    // final dir = await FileSaver.instance.saveFile(
    //     "ใบเสร็จรับเงิน(ณ วันที่${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day})",
    //     data,
    //     "pdf",
    //     mimeType: type);

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
                selectedMode: _selectedMode,
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
}
