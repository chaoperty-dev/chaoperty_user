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
import '../../Man_PDF/Preview_PDF/PreviewPdfgen_Billsplay.dart';
import '../../Model/trans_re_bill_history_model.dart';

import '../../Man_PDF/Man_Temporary_Receipt_PDF.dart';

class Pdfgen_his_statusbill_TP3 {
//////////---------------------------------------------------->(ใบเสร็จรับเงิน/ใบกำกับภาษี)   ใช้  //

  static void exportPDF_statusbill_TP3(
      List<TransReBillHistoryModel> TransReBillHistory,
      Cust_no,
      cid_,
      Zone_s,
      Ln_s,
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
    ///////

    // ------------------------------------------------------->
    // แสดง Dialog เลือกขนาดกระดาษก่อน Export
    final String? _selectedMode =
        await ManPay_Receipt_PDF.showPageFormatDialog(context as BuildContext);
    if (_selectedMode == null) return; // ผู้ใช้กด Cancel → หยุดทันที
    // ------------------------------------------------------->

    final pdf = pw.Document();
    final font = await rootBundle.load("${fonts_pdf}");
    var Colors_pd = PdfColors.black;

    int pageCount = 1;
    final ttf = pw.Font.ttf(font);
    const PdfColor PDF_Border_Color = PDFConstants.borderColor;

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
          return 10.0; // A4 — ค่าเดิม ไม่เปลี่ยน
      }
    }();

    final double logoSize = isPos ? 32.0 : 60.0;
    final double infoGapMm = isPos ? 1.5 : 6.0;
    // ─────────────────────────────────────────────────────
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
    //////--------------------------------------------->
    // targetPx ปรับตามขนาดหน้า: A3 ใหญ่สุด → px สูง → คมชัด
    // PNG (lossless) ไม่เบลอเหมือน JPEG
    final int _logoPx = () {
      switch (_selectedMode) {
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
    Uint8List? resizedLogo = await getResizedLogoForSize(targetPx: _logoPx);

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

    ///---------------------> Table header columns (หัวคอลัมน์ของตาราง)
    // ── header columns — 4 คอลัมน์ (POS) หรือ 10 คอลัมน์ (A4/A3/A5) ────
    final headerColumns = [
      {
        'label': 'ลำดับ',
        'flex': 0,
        'align': pw.Alignment.center,
        'width': isPos ? 18.0 : 30.0
      },
      {'label': 'รหัสสินค้า', 'flex': 2, 'align': pw.Alignment.centerLeft},
      {'label': 'รายการ', 'flex': 4, 'align': pw.Alignment.centerLeft},
      if (!isPos) ...[
        {'label': 'จำนวน', 'flex': 1, 'align': pw.Alignment.centerRight},
        {'label': 'หน่วย', 'flex': 1, 'align': pw.Alignment.centerRight},
        {'label': 'ก่อนVAT', 'flex': 1, 'align': pw.Alignment.centerRight},
        {'label': 'VAT', 'flex': 1, 'align': pw.Alignment.centerRight},
        {'label': 'WHT', 'flex': 1, 'align': pw.Alignment.centerRight},
        {'label': 'ส่วนลด', 'flex': 1, 'align': pw.Alignment.centerRight},
      ],
      {'label': 'ยอดสุทธิ', 'flex': 1, 'align': pw.Alignment.centerRight},
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

    ///////------------------------------->

    // ── local footer builder (capture scope, POS ใช้ใน build list) ──
    pw.Widget buildFooterContent() {
      // helpers ──────────────────────────────────────────────────────────
      final _boldStyle = pw.TextStyle(
          fontSize: font_Size,
          font: ttf,
          fontWeight: pw.FontWeight.bold,
          color: Colors_pd);

      pw.Widget _ft(String text, {pw.TextAlign? align}) =>
          pw.Text(text, textAlign: align, style: _boldStyle);

      pw.Widget _signCol1(String title) => pw.Expanded(
            flex: 1,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                _ft(title),
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
          );

      pw.Widget _signCol2(String title) => pw.Expanded(
            flex: 1,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                _ft(title),
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
                      if (signatureBytes != null && signatureBytes.isNotEmpty)
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
                    if (date_Transaction != null && signatureBytes != null)
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
                )
              ],
            ),
          );

      // payment method text ───────────────────────────────────────────────
      final _nonCashFilter = finnancetransModels
          .where((m) => m.dtype == 'KP' && m.ptser != null && m.ptser != '1');
      final _bankList = _nonCashFilter.map((m) => m.bank).join(', ');
      final _bnoList = _nonCashFilter.map((m) => m.bno).join(', ');
      final _ptypeList = _nonCashFilter.map((m) {
        if (m.ptname.toString() == 'Online Payment') return 'PromptPay QR';
        if (m.ptname == 'เงินโอน') return 'เลขบัญชี';
        if (m.ptname == 'Beam Checkout') return 'Beam Checkout';
        return 'Online Standard QR';
      }).join(', ');
      final _ref1List = _nonCashFilter.map((m) => m.ref1).join(', ');
      final _invList =
          _nonCashFilter.map((m) => m.inv.replaceAll('-', '')).join(', ');
      final _ref2Date = dayfinpay != null
          ? '${DateFormat('ddMM').format(DateTime.parse(dayfinpay!))}${DateTime.parse('${dayfinpay}').year + 543}'
          : '';

      return pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Container(
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1)),
            padding: pw.EdgeInsets.fromLTRB(2, 4, 2, 4),
            child: pw.Row(children: [
              // ── หมายเหตุ / วิธีชำระ ─────────────────────────────────
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _ft('หมายเหตุ : '),
                    _ft(hasNonCashTransaction
                        ? '( / ) 1. เงินโอน, QR Code, Mobile Banking '
                        : '(   ) 1. เงินโอน, QR Code, Mobile Banking '),
                    _ft(hasNonCashTransaction
                        ? '      บัญชี $_bankList เลขที่ $_bnoList [ $_ptypeList ]'
                        : '      บัญชี...................................เลขที่...................................'),
                    if (hasNonCashTransaction8)
                      _ft(hasNonCashTransaction7
                          ? '      ( Ref1. $_invList Ref2. $_ref2Date )'
                          : '      ( Ref1. $_ref1List Ref2. $_ref2Date )'),
                    pw.Row(children: [
                      pw.Expanded(
                        flex: 1,
                        child: _ft(hasNonCashTransaction1
                            ? '( / ) 2. เงินสด'
                            : '(   ) 2. เงินสด'),
                      ),
                      pw.Expanded(
                        flex: 3,
                        child: _ft((hasNonCashTransaction ||
                                hasNonCashTransaction1)
                            ? '(   ) 3. อื่นๆ.............................'
                            : '( / ) 3. อื่นๆ ${finnancetransModels.where((m) => m.ptser != '6' || m.ptser != '5' || m.ptser != '2' || m.ptser != '1' && m.dtype == 'KP').map((m) => m.bank).join(', ')}'),
                      ),
                    ]),
                  ],
                ),
              ),
              // ── ลายเซ็น ─────────────────────────────────────────────
              _signCol1('ลงชื่อ : ผู้รับบริการ'),
              _signCol2('ลงชื่อ : ผู้รับเงิน'),
            ]),
          ),

          // pw.Row(
          //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //   children: [
          //     pw.Text('พิมพ์เมื่อ : $date',
          //         style:
          //             pw.TextStyle(fontSize: 7.0, font: ttf, color: Colors_pd)),
          //     pw.Text('Print: $date',
          //         style:
          //             pw.TextStyle(fontSize: 7.0, font: ttf, color: Colors_pd)),
          //   ],
          // ),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: buildFormat(),
        header: (context) {
          // ══════════════════════════════════════════════
          // POS compact header — เฉพาะข้อมูลสำคัญ
          // ══════════════════════════════════════════════
          if (isPos) {
            final String _docNo =
                (numdoctax.toString() == '') ? '$numinvoice' : '$numdoctax';
            final String _custName = (cname != null &&
                    cname.toString().trim().isNotEmpty &&
                    cname.toString() != 'null')
                ? '$cname'
                : (sname != null &&
                        sname.toString().trim().isNotEmpty &&
                        sname.toString() != 'null')
                    ? '$sname'
                    : '-';
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // ── โลโก้ + ชื่อบริษัท (กลาง) ────────────
                if (resizedLogo != null)
                  pw.Image(pw.MemoryImage(resizedLogo),
                      width: logoSize, height: logoSize),
                pw.SizedBox(height: 2),
                pw.Text(
                  '$bill_name',
                  maxLines: 2,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                      fontSize: font_Size + 1,
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      color: Colors_pd),
                ),
                if (bill_tel != null && bill_tel.toString().isNotEmpty)
                  pw.Text(
                    'โทร: $bill_tel',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                        fontSize: font_Size, font: ttf, color: Colors_pd),
                  ),
                pw.Divider(thickness: 0.5),
                // ── เลขเอกสาร + วันที่ ────────────────────
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('เลขที่: $_docNo',
                        style: pw.TextStyle(
                            fontSize: font_Size,
                            font: ttf,
                            fontWeight: pw.FontWeight.bold,
                            color: Colors_pd)),
                    pw.Text('$formattedDate $newYear',
                        style: pw.TextStyle(
                            fontSize: font_Size, font: ttf, color: Colors_pd)),
                  ],
                ),
                // ── ชื่อลูกค้า ────────────────────────────
                pw.Row(
                  children: [
                    pw.Text('ลูกค้า: $_custName',
                        maxLines: 2,
                        style: pw.TextStyle(
                            fontSize: font_Size, font: ttf, color: Colors_pd)),
                  ],
                ),
                pw.Text(
                  'ห้อง: $Zone_s / $Ln_s',
                  style: pw.TextStyle(
                      fontSize: font_Size, font: ttf, color: Colors_pd),
                ),
                pw.Divider(thickness: 0.5),
              ],
            );
          }

          // ══════════════════════════════════════════════
          // A4 / A3 / A5 — full header (ตามเดิม)
          // ══════════════════════════════════════════════
          return pw.Column(children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ── Logo ─────────────────────────────────────────
                pw.Container(
                  height: logoSize,
                  width: logoSize,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: resizedLogo != null
                      ? pw.Image(
                          pw.MemoryImage(resizedLogo),
                          height: logoSize,
                          width: logoSize,
                        )
                      : pw.Center(
                          child: pw.Text(
                            '$bill_name ',
                            maxLines: 1,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                ),
                pw.SizedBox(width: infoGapMm * PdfPageFormat.mm),
                // ── ข้อมูลบริษัท (ซ้าย) ────────────────────────
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '$bill_name',
                        maxLines: 2,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
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
                      pw.Text(
                        (bill_tax.toString() == '' || bill_tax == null)
                            ? 'เลขประจำตัวผู้เสียภาษี : 0'
                            : 'เลขประจำตัวผู้เสียภาษี : $bill_tax',
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── ข้อมูลเอกสาร (ขวา) ─────────────────────────
                pw.Expanded(
                  flex: 4,
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
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
                      pw.SizedBox(height: 6),
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
                      pw.Text(
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
                pw.SizedBox(
                    width:
                        isPos ? 2 * PdfPageFormat.mm : 10 * PdfPageFormat.mm),
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
            pw.Container(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.green100,
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.green900),
                  ),
                ),
                child: pw.Row(
                  children: headerColumns.map((col) {
                    final label = col['label'] as String;
                    final flex = col['flex'] as int;
                    final align = col['align'] as pw.Alignment;
                    final width = col['width'] as double?;

                    final container = pw.Container(
                      // decoration: pw.BoxDecoration(
                      //   border: pw.Border(
                      //     left: (label == 'ยอดสุทธิ')
                      //         ? pw.BorderSide.none
                      //         : const pw.BorderSide(color: PdfColors.grey600),
                      //     right: const pw.BorderSide(color: PdfColors.grey600),
                      //   ),
                      // ),
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
                            color: PdfColors.green900,
                          ),
                        ),
                      ),
                    );

                    if (width != null && flex == 0) {
                      return pw.Container(
                        width: width,
                        height: 20,
                        // decoration: const pw.BoxDecoration(
                        //   border: pw.Border(
                        //     left: pw.BorderSide(color: PdfColors.grey600),
                        //   ),
                        // ),
                        padding: const pw.EdgeInsets.all(2.0),
                        child: container.child,
                      );
                    }

                    return pw.Expanded(flex: flex, child: container);
                  }).toList(),
                )),
            // ── Table (data rows) ────────────────────────────────────────
            // ── Table (data rows) ────────────────────────────────────────
            pw.Table(
              columnWidths: {
                0: pw.FixedColumnWidth(isPos ? 18 : 30),
                1: pw.FlexColumnWidth(2),
                2: pw.FlexColumnWidth(4),
                if (!isPos) ...{
                  3: pw.FlexColumnWidth(1), // จำนวน
                  4: pw.FlexColumnWidth(1), // หน่วย
                  5: pw.FlexColumnWidth(1), // ก่อนVAT
                  6: pw.FlexColumnWidth(1), // VAT
                  7: pw.FlexColumnWidth(1), // WHT
                  8: pw.FlexColumnWidth(1), // ส่วนลด
                  9: pw.FlexColumnWidth(1), // ยอดสุทธิ
                } else ...{
                  3: pw.FlexColumnWidth(1), // ยอดสุทธิ (POS)
                },
              },
              children: List.generate(TransReBillHistory.length, (index) {
                final TransReBill = TransReBillHistory[index];

                // ── helper: สร้าง cell ───────────────────────────────────
                pw.Widget _cell(String text,
                    {pw.Alignment align = pw.Alignment.centerLeft,
                    int maxLines = 2}) {
                  return pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Align(
                      alignment: align,
                      child: pw.Text(text,
                          maxLines: maxLines,
                          textAlign: align == pw.Alignment.centerRight
                              ? pw.TextAlign.right
                              : pw.TextAlign.left,
                          style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: PdfColors.grey800)),
                    ),
                  );
                }

                // ── helper: ชื่อรายการ ───────────────────────────────────
                final _month = DateFormat('MMM', 'th')
                    .format(DateTime.parse(TransReBill.date!));
                final _year = DateTime.parse('${TransReBill.date}').year + 543;
                final _expText = (TransReBill.unitser.toString() == '6')
                    ? '${TransReBill.expname} $_month $_year'
                        '[ หน่วยที่ใช้ไป ${TransReBill.ovalue}-${TransReBill.nvalue} ]'
                    : '${TransReBill.expname} $_month $_year';

                // ── helper: format nullable number ───────────────────────
                String _fmt(String? v) =>
                    (v == null) ? '0.00' : nFormat.format(double.parse(v));

                return pw.TableRow(
                  children: [
                    // col 0: ลำดับ
                    _cell('${index + 1}', align: pw.Alignment.center),
                    // col 1: รหัสสินค้า
                    _cell('${TransReBill.refno}'),
                    // col 2: รายการ
                    _cell(_expText, maxLines: 3),
                    // col 3-8: แสดงเฉพาะ non-POS
                    if (!isPos) ...[
                      _cell(getFormattedText(TransReBill.qty),
                          align: pw.Alignment.centerRight),
                      _cell(
                          (TransReBill.ele_ty.toString() != '0' &&
                                  TransReBill.ele_ty != null)
                              ? 'อัตราพิเศษ'
                              : (TransReBill.dtype.toString() == 'KU')
                                  ? getFormattedText('${TransReBill.pri}')
                                  : '-',
                          align: pw.Alignment.centerRight),
                      _cell(_fmt(TransReBill.pvat),
                          align: pw.Alignment.centerRight),
                      _cell(_fmt(TransReBill.vat),
                          align: pw.Alignment.centerRight),
                      _cell(_fmt(TransReBill.wht),
                          align: pw.Alignment.centerRight),
                      _cell(_fmt(TransReBill.dis_list),
                          align: pw.Alignment.centerRight),
                    ],
                    // col 9: ยอดสุทธิ (ทุก mode)
                    _cell(_fmt(TransReBill.total),
                        align: pw.Alignment.centerRight),
                  ],
                );
              }),
            ),
            // ── Data rows (paginate ได้) ───────────────────────────────────
            // pw.ListView.builder(
            //   itemCount: TransReBillHistory.length,
            //   itemBuilder: (context, index) {
            //     final TransReBill = TransReBillHistory[index];

            //     // helper: format nullable number
            //     String _fmt(String? v) =>
            //         (v == null) ? '0.00' : nFormat.format(double.parse(v));

            //     // helper: ชื่อรายการ
            //     final _month = DateFormat('MMM', 'th')
            //         .format(DateTime.parse(TransReBill.date!));
            //     final _year = DateTime.parse('${TransReBill.date}').year + 543;

            //     final _expText = (TransReBill.unitser.toString() == '6')
            //         ? '${TransReBill.expname} $_month $_year'
            //             '[ หน่วยที่ใช้ไป ${TransReBill.ovalue}-${TransReBill.nvalue} ]'
            //         : '${TransReBill.expname} $_month $_year';

            //     pw.Widget cell(
            //       String text, {
            //       double? w,
            //       int flex = 0,
            //       pw.Alignment align = pw.Alignment.centerLeft,
            //       int maxLines = 2,
            //       bool borderBottom = true,
            //     }) {
            //       final child = pw.Container(
            //         padding: const pw.EdgeInsets.all(2),
            //         decoration: borderBottom
            //             ? const pw.BoxDecoration(
            //                 border: pw.Border(
            //                   bottom: pw.BorderSide(
            //                       width: 0.3, color: PdfColors.grey300),
            //                 ),
            //               )
            //             : null,
            //         child: pw.Align(
            //           alignment: align,
            //           child: pw.Text(
            //             text,
            //             maxLines: maxLines,
            //             textAlign: align == pw.Alignment.centerRight
            //                 ? pw.TextAlign.right
            //                 : (align == pw.Alignment.center
            //                     ? pw.TextAlign.center
            //                     : pw.TextAlign.left),
            //             style: pw.TextStyle(
            //               fontSize: font_Size,
            //               font: ttf,
            //               color: PdfColors.grey800,
            //             ),
            //           ),
            //         ),
            //       );

            //       if (w != null) return pw.SizedBox(width: w, child: child);
            //       if (flex > 0) return pw.Expanded(flex: flex, child: child);
            //       return child;
            //     }

            //     // column widths (เหมือนเดิม)
            //     final w0 = isPos ? 18.0 : 30.0;

            //     return pw.Row(
            //       crossAxisAlignment: pw.CrossAxisAlignment.start,
            //       children: [
            //         // col 0: ลำดับ (Fixed)
            //         cell('${index + 1}', w: w0, align: pw.Alignment.center),

            //         // col 1: รหัสสินค้า (Flex 2)
            //         cell('${TransReBill.refno}', flex: 2),

            //         // col 2: รายการ (Flex 4)
            //         cell(_expText, flex: 4, maxLines: 3),

            //         if (!isPos) ...[
            //           // col 3: จำนวน (Flex 1)
            //           cell(getFormattedText(TransReBill.qty),
            //               flex: 1, align: pw.Alignment.centerRight),

            //           // col 4: หน่วย/อัตรา (Flex 1)
            //           cell(
            //               (TransReBill.ele_ty.toString() != '0' &&
            //                       TransReBill.ele_ty != null)
            //                   ? 'อัตราพิเศษ'
            //                   : (TransReBill.dtype.toString() == 'KU')
            //                       ? getFormattedText('${TransReBill.pri}')
            //                       : '-',
            //               flex: 1,
            //               align: pw.Alignment.centerRight),

            //           // col 5: ก่อนVAT (Flex 1)
            //           cell(_fmt(TransReBill.pvat),
            //               flex: 1, align: pw.Alignment.centerRight),

            //           // col 6: VAT (Flex 1)
            //           cell(_fmt(TransReBill.vat),
            //               flex: 1, align: pw.Alignment.centerRight),

            //           // col 7: WHT (Flex 1)
            //           cell(_fmt(TransReBill.wht),
            //               flex: 1, align: pw.Alignment.centerRight),

            //           // col 8: ส่วนลด (Flex 1)
            //           cell(_fmt(TransReBill.dis_list),
            //               flex: 1, align: pw.Alignment.centerRight),
            //         ],

            //         // col สุดท้าย: ยอดสุทธิ (Flex 1)
            //         cell(_fmt(TransReBill.total),
            //             flex: 1, align: pw.Alignment.centerRight),
            //       ],
            //     );
            //   },
            // ),

            pw.Divider(color: PdfColors.grey),
            pw.Container(
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
                        // ── helper: สร้าง summary row ────────────────────
                        ...(() {
                          pw.Widget _sumRow(
                            String label,
                            String value, {
                            PdfColor color = PdfColors.green900,
                          }) =>
                              pw.Row(children: [
                                pw.Expanded(
                                  child: pw.Text(label,
                                      style: pw.TextStyle(
                                          fontSize: font_Size,
                                          fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                          color: color)),
                                ),
                                pw.Text(value,
                                    style: pw.TextStyle(
                                        fontSize: font_Size,
                                        fontWeight: pw.FontWeight.bold,
                                        font: ttf,
                                        color: color)),
                              ]);

                          final _fmtD = (dynamic v) =>
                              nFormat.format(double.parse(v.toString()));

                          return [
                            _sumRow('รวมราคาสินค้า/Sub Total',
                                nFormat.format(totalPvat)),
                            _sumRow('ภาษีมูลค่าเพิ่ม/Vat',
                                nFormat.format(totalVat)),
                            _sumRow('หัก ณ ที่จ่าย', nFormat.format(totalWht)),
                            if (totalFee != 0)
                              _sumRow('ค่าธรรมเนียม', nFormat.format(totalFee)),
                            _sumRow(
                                'ยอดรวม',
                                nFormat.format(roundMoney(
                                        (totalPvat + totalVat) - totalWht) +
                                    totalFee)),
                            _sumRow(
                                'ส่วนลด/Discount', nFormat.format(totalDis)),
                            if (totalMatjum != 0)
                              _sumRow(
                                  'เงินมัดจำ(ตัดมัดจำ)', _fmtD(dis_sum_Matjum),
                                  color: PdfColors.grey800),
                            if (totalPakan != 0)
                              _sumRow('เงินประกัน(ตัดเงินประกัน)',
                                  _fmtD(dis_sum_Pakan),
                                  color: PdfColors.grey800),
                            pw.Divider(color: PdfColors.grey),
                            _sumRow('ยอดชำระ', nFormat.format(totalBill)),
                          ];
                        }()),
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
                  color: PdfColors.green100,
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.green900),
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
                            color: PdfColors.green900),
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
                            color: PdfColors.green900,
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
                                    'ยอดรวมสุทธิ ',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        font: ttf,
                                        fontSize: font_Size,
                                        color: PdfColors.green900),
                                  ),
                                ),
                                pw.Text(
                                  '${nFormat.format(totalBill)}',
                                  // '${Total}',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      font: ttf,
                                      fontSize: font_Size,
                                      color: PdfColors.green900),
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
            // POS: footer ติดท้ายเนื้อหา (ไม่ใช่ footer parameter
            // เพราะ MultiPage pin footer ที่ความสูง 5000pt ทำให้ห่างมาก)
            if (isPos) buildFooterContent(),
          ];
        },
        footer: (context) {
          // POS: footer ไม่ใช้ parameter นี้ (ถูกใส่ใน build แล้ว)
          if (isPos) return pw.SizedBox.shrink();
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              buildFooterContent(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('พิมพ์เมื่อ : $date',
                      style: pw.TextStyle(
                          fontSize: 7.0, font: ttf, color: Colors_pd)),
                  pw.Text(
                      'หน้าที่ ${context.pageNumber} / ${context.pagesCount} ',
                      style: pw.TextStyle(
                          fontSize: 7.0, font: ttf, color: Colors_pd)),
                ],
              ),
            ],
          );
        },
      ),
    );

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
                pageFormat: buildFormat(),
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
