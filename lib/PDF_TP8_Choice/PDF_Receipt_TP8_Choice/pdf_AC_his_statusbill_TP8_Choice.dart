import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty_user/File_s.dart';
import 'package:chaoperty_user/PDF/ThaiBaht.dart';
import 'package:chaoperty_user/PDF/pdf_constants.dart';
import 'package:chaoperty_user/loadAndCacheImage.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../CRC_16_Prompay/generate_qrcode.dart';
import '../../Constant/Myconstant.dart';
import '../../Man_PDF/Man_Pay_Receipt_PDF.dart';
import '../../Man_PDF/Preview_PDF/PreviewPdfgen_Billsplay.dart';
import '../../Model/GetBillPayUsedDeposit_Model.dart';
import '../../Model/trans_re_bill_history_model.dart';

import 'package:http/http.dart' as http;
import 'dart:html' as html;

class Pdfgen_his_statusbill_TP8_Choice {
//////////---------------------------------------------------->(ใบเสร็จรับเงิน/ใบกำกับภาษี)   ใช้  //

  static void exportPDF_statusbill_TP8_Choice(
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
      round_p,
      paper,
      paper_run,
      amt_up,
      vat_up,
      sum_addvat,
      sum_Nonvat,
      signature,
      [List<BillPayUsedDepositModel> billPayUsedDepositModels =
          const []]) async {
    ////
    //// ------------>(ใบเสร็จรับเงิน)
    // ------------------------------------------------------->
    // แสดง Dialog เลือกขนาดกระดาษก่อน Export
    final String? _selectedMode =
        await ManPay_Receipt_PDF.showPageFormatDialog(context as BuildContext);
    if (_selectedMode == null) return; // ผู้ใช้กด Cancel → หยุดทันที
    // ------------------------------------------------------->
    final pdf = pw.Document();
    final font = await rootBundle.load("${fonts_pdf}");
    var Colors_pd = PdfColors.black;
    // final font = await rootBundle.load("fonts/Sarabun-Medium.ttf");
    const PdfColor PDF_Border_Color = PDFConstants.borderColor;
    int pageCount = 1; // Initialize the page count
    final ttf = pw.Font.ttf(font);
    double widths = await MediaQuery.of(context).size.width;
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

    //////--------------------------------------------->
    DateTime date = DateTime.now();
    // // var formatter = new DateFormat.MMMMd('th_TH');
    // // String thaiDate = formatter.format(date);
    // final thaiDate = DateTime.parse(date_Transaction);
    // final formatter = DateFormat('d MMMM', 'th_TH');
    // final formattedDate = formatter.format(thaiDate);
    // //////--------------->พ.ศ.
    // DateTime dateTime = DateTime.parse(date_Transaction);
    // int newYear = dateTime.year + 543;
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

////////////////------------------------------->
    final ByteData image = await rootBundle.load('images/image7-11.png');
    final ByteData BG_PDF = await rootBundle.load('images/Choice_BG_PDF.png');
    final ByteData LG_PDF = await rootBundle.load('images/choice_logo2.png');
    // final ByteData Logo_PDF = await rootBundle.load('images/choice_logo.png');
    // Uint8List? resizedLogo = await getResizedLogo();
    Uint8List imageData = (image).buffer.asUint8List();
    Uint8List imageBG = (BG_PDF).buffer.asUint8List();
    Uint8List imageLG = (LG_PDF).buffer.asUint8List();
    var docid = (numdoctax.toString() == '') ? '$numinvoice ' : '$numdoctax ';
    var licence_name1 = 'สิริกร พรหมปัญญา';
    var licence_name2 = 'สิริกร พรหมปัญญา';
    var refid = 'LLJZX20241';

    final imageBytes_manager = await loadAndCacheImage(
        '${MyConstant().domain_choice}/gen_licence_img.php?isAdd=true&ren=106&ref_id=$refid&name_id=$licence_name1&doc_id=$docid&extension=.png');
    // final imageBytes_Payee = await loadAndCacheImage(
    //     '${MyConstant().domain}/gen_licence_img.php?isAdd=true&ren=50&ref_id=$refid&name_id=$licence_name2&doc_id=$docid&extension=.png');

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
            '${MyConstant().domain_choice}/files/$foder/payment/${finnancetransModels[i].img}'));
      }
    }

    ///---------------------> โหลด signature image
    Uint8List? signatureBytes;
    if (signature != null &&
        signature.toString().isNotEmpty &&
        signature.toString() != 'null') {
      try {
        final sigUrl = '${MyConstant().domain_choice}/${signature}';
        print('signature URL: $sigUrl');
        final sigRes = await http.get(Uri.parse(sigUrl));
        if (sigRes.statusCode == 200) {
          signatureBytes = sigRes.bodyBytes;
        }
      } catch (_) {
        signatureBytes = null;
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

    final net_amount_pvat = roundMoney(getTotalByField(
        _TransReBillHistoryModels, (e) => e.net_amount_pvat.toString() ?? '0'));
    final net_non_pvat = roundMoney(getTotalByField(
        _TransReBillHistoryModels, (e) => e.net_non_pvat.toString() ?? '0'));

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

    // คำนวณจำนวนเงินหลังหักส่วนลด
    String afterDiscount = '';
    if (totalMatjum > 0) {
      afterDiscount = nFormat.format(totalMatjum - totalDis);
    } else if (totalPakan > 0) {
      afterDiscount = nFormat.format(totalPakan - totalDis);
    } else if (totalFee > 0) {
      afterDiscount = nFormat.format(totalFee - totalDis);
    } else {
      afterDiscount = '0.00';
    }

    ///==========================================>ท้ายบิล

    /// แปลงค่าที่รับมา (อาจเป็น null / ตัวเลข / ข้อความมีลูกน้ำ) ให้เป็น double
    double toNum(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) {
        final cleaned = v.replaceAll(',', '').trim();
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    /// จัดรูปแบบเป็นข้อความใส่ในบิล เช่น 69,500.00
    String fmt(dynamic v) => nFormat.format(toNum(v));

    ///──────────────────────────────────────────────────────────────
    /// 1) ตัวเลขที่ได้จากบิล
    ///──────────────────────────────────────────────────────────────
    final double netNonPvat = toNum(net_non_pvat); // รายการที่ไม่มี/ยกเว้น VAT
    final double totalPvatNum = toNum(totalPvat); // ยอดรวมก่อน VAT
    final double totalVatNum = toNum(totalVat); // ยอด VAT
    final double totalDisNum = toNum(totalDis); // ส่วนลดทั้งบิล
    final double totalWhtNum = toNum(totalWht); // หัก ณ ที่จ่าย
    final double totalFeeNum = toNum(totalFee); // ค่าธรรมเนียม
    final double totalBillNum = toNum(totalBill); // ยอดชำระสุทธิ
    final double netAmountPvatNum =
        toNum(net_amount_pvat); // ฐาน VAT ที่ API คำนวณมาให้

    final bool hasDiscount = totalDisNum > 0.00;

    ///──────────────────────────────────────────────────────────────
    /// 2) ยอดหลังหักส่วนลด — ใช้เฉพาะบิลที่มีส่วนลด
    ///    เพราะยอดที่ API ส่งมายังไม่ได้หักส่วนลดให้ ต้องคำนวณฐาน VAT เอง
    ///    (ถอด VAT ออกจากยอดรวมด้วยการหาร 1.07 หลังตัดรายการที่ไม่มี VAT ทิ้ง)
    ///──────────────────────────────────────────────────────────────
    const double vatRate = 0.07;
    const double vatMultiplier = 1.07;

    final double totalAfterDiscount =
        (totalPvatNum + totalVatNum) - totalDisNum;
    final double vatBaseAfterDiscount =
        (totalAfterDiscount - netNonPvat) / vatMultiplier;
    final double vatAmountAfterDiscount = vatBaseAfterDiscount * vatRate;

    ///──────────────────────────────────────────────────────────────
    /// 3) เงินมัดจำที่ถูกตัดไปชำระบิลนี้แล้ว (จาก GC_billpay_used_deposit.php)
    ///──────────────────────────────────────────────────────────────
    final double depositTotal = roundMoney(billPayUsedDepositModels.fold(
        0.00, (sum, m) => sum + (m.total ?? 0.00)));
    final double depositPvat = roundMoney(billPayUsedDepositModels.fold(
        0.00, (sum, m) => sum + (m.pvat ?? 0.00)));
    final double depositVat = roundMoney(
        billPayUsedDepositModels.fold(0.00, (sum, m) => sum + (m.vat ?? 0.00)));

    /// มียอดมัดจำจริงถึงจะโชว์แถว 'หัก เงินมัดจำ'
    final bool showDepositRow = depositTotal.abs() > 0.000001;

    /// เงินมัดจำก้อนนี้มี VAT หรือไม่ — ดูจากช่อง vat ที่ API ส่งมา
    /// ตัวอย่าง 'ตัดมัดจำชำระ' pvat 46,000 / vat 0 = ถือว่าไม่มี VAT
    ///
    /// มี VAT    -> เอายอดมัดจำไปลบที่แถว 'รวมราคาสินค้าคำนวณภาษีมูลค่าเพิ่ม'
    ///              และแถว 'ภาษีมูลค่าเพิ่ม 7%'
    /// ไม่มี VAT -> ไม่ลบแถวไหนเลย ปล่อยให้ 2 แถวนั้นรวมเฉพาะรายการที่มี VAT จริง
    ///
    /// ส่วนแถว 'จำนวนเงินรวมทั้งสิ้น' ไม่หักมัดจำทุกกรณี โชว์ยอดรวมของบิลเฉย ๆ
    final bool cutDepositFromVatRows =
        showDepositRow && depositVat.abs() > 0.000001;

    ///──────────────────────────────────────────────────────────────
    /// 4) ยอดที่เอาไปแสดงจริงในแต่ละแถวท้ายบิล
    ///──────────────────────────────────────────────────────────────
    /// id '2' จำนวนเงินรวมทั้งสิ้น
    final double grandTotalRow = hasDiscount
        ? totalAfterDiscount
        : roundMoney(totalPvatNum + totalVatNum);

    /// id '4' รวมราคาสินค้าคำนวณภาษีมูลค่าเพิ่ม
    final double vatBaseFull =
        hasDiscount ? vatBaseAfterDiscount : netAmountPvatNum;
    final double vatBaseRow =
        cutDepositFromVatRows ? vatBaseFull - depositPvat : vatBaseFull;

    /// id '5' ภาษีมูลค่าเพิ่ม 7%
    final double vatAmountFull =
        hasDiscount ? vatAmountAfterDiscount : totalVatNum;
    final double vatAmountRow =
        cutDepositFromVatRows ? vatAmountFull - depositVat : vatAmountFull;

    List<Map<String, String>> BillsList = [
      {
        'id': '1',
        'st': '1',
        'pn': 'รวมสินค้าไม่มี/ยกเว้นภาษี',
        'total': fmt(netNonPvat),
      },
      {
        'id': '2',
        'st': '1',
        'pn': 'จำนวนเงินรวมทั้งสิ้น',
        'total': fmt(grandTotalRow),
      },
      {
        'id': '3',
        'st': showDepositRow ? '1' : '0',
        'pn': 'หัก เงินมัดจำ',
        'total': fmt(depositTotal),
      },
      {
        'id': '4',
        'st': '1',
        'pn': 'รวมราคาสินค้าคำนวณภาษีมูลค่าเพิ่ม',
        'total': fmt(vatBaseRow),
      },
      {
        'id': '5',
        'st': '1',
        'pn': 'ภาษีมูลค่าเพิ่ม 7%/',
        'total': fmt(vatAmountRow),
      },
      {
        'id': '6',
        'st': '1',
        'pn': 'หัก ณ ที่จ่าย / Withholding',
        'total': fmt(totalWhtNum),
      },
      {
        'id': '7',
        'st': '1',
        'pn': 'ค่าธรรมเนียม',
        'total': fmt(totalFeeNum),
      },
      {
        'id': '8',
        'st': '1',
        'pn': 'ยอดชำระ / Payment Amount',
        'total': fmt(totalBillNum),
      },
    ];

    ///==========================================>

    String getFormattedText(String? data) {
      final value =
          (data == null) ? 0.00 : double.tryParse(data ?? '0.00') ?? 0.00;
      return nFormat.format(value);
    }

    bool isPositive(String? value) {
      return (double.tryParse(value ?? '0.00') ?? 0.00) > 0;
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
      const double mLeft = 0;
      const double mRight = 0;
      const double mTop = 0;
      const double mBottom = 5;

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
            // color: PdfColors.white,
            border: pw.Border(
              left: pw.BorderSide(color: PDF_Border_Color),
              right: pw.BorderSide(color: PDF_Border_Color),
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

    final pageTheme = pw.PageTheme(
      pageFormat: buildFormat(),
      // pageFormat: PdfPageFormat.a4.copyWith(
      //   marginBottom: 5.00,
      //   marginLeft: 0.00,
      //   marginRight: 0.00,
      //   marginTop: 0.00,
      // ),
      buildBackground: (ctx) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Image(pw.MemoryImage(imageBG), fit: pw.BoxFit.cover),
      ),
    );
    pw.Widget Header(context) {
      return pw
          .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Container(
          width: buildFormat().width + 100,

          //  PdfPageFormat.a4.width + 100,
          color: PdfColors.green900,
          height: 13,
        ),
        pw.SizedBox(height: 1 * PdfPageFormat.mm),

        pw.Container(
            padding: pw.EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: pw.Column(
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    imageLG != null
                        ? pw.Container(
                            child: pw.Center(
                            child: pw.Image(pw.MemoryImage(imageLG),
                                height: 55, width: 60, fit: pw.BoxFit.fill),
                          ))
                        : pw.Container(
                            height: 55,
                            width: 60,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              border: pw.Border.all(color: PdfColors.grey300),
                            ),
                            child: pw.Center(
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
                    // (netImage.isEmpty)
                    //     ? pw.Container(
                    //         height: 60,
                    //         width: 60,
                    //         decoration: const pw.BoxDecoration(
                    //           color: PdfColors.grey200,
                    //           border: pw.Border(
                    //             right: pw.BorderSide(color: PdfColors.grey300),
                    //             left: pw.BorderSide(color: PdfColors.grey300),
                    //             top: pw.BorderSide(color: PdfColors.grey300),
                    //             bottom: pw.BorderSide(color: PdfColors.grey300),
                    //           ),
                    //         ),
                    //         child: pw.Center(
                    //           child: pw.Text(
                    //             '$bill_name ',
                    //             maxLines: 1,
                    //             style: pw.TextStyle(
                    //               fontSize: 10,
                    //               font: ttf,
                    //               color: Colors_pd,
                    //             ),
                    //           ),
                    //         ))

                    //     // pw.Image(
                    //     //     pw.MemoryImage(iconImage),
                    //     //     height: 72,
                    //     //     width: 70,
                    //     //   )
                    //     : pw.Container(
                    //         height: 60,
                    //         width: 60,
                    //         decoration: const pw.BoxDecoration(
                    //           color: PdfColors.grey200,
                    //           border: pw.Border(
                    //             right: pw.BorderSide(color: PdfColors.grey300),
                    //             left: pw.BorderSide(color: PdfColors.grey300),
                    //             top: pw.BorderSide(color: PdfColors.grey300),
                    //             bottom: pw.BorderSide(color: PdfColors.grey300),
                    //           ),
                    //         ),
                    //         child: pw.Image(
                    //           (netImage[0]),
                    //           // fit: pw.BoxFit.fill,
                    //           height: 60,
                    //           width: 60,
                    //         )),
                    pw.SizedBox(width: 1 * PdfPageFormat.mm),
                    pw.Container(
                      // color: PdfColors.grey200,
                      width: 400,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
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
                          pw.Text(
                            (bill_tax.toString() == '' || bill_tax == null)
                                ? 'หมายเลขประจำตัวผู้เสียภาษี : 0'
                                : 'หมายเลขประจำตัวผู้เสียภาษี : $bill_tax',
                            // textAlign: pw.TextAlign.justify,
                            textAlign: pw.TextAlign.right,
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
                        ],
                      ),
                    ),
                    pw.Spacer(),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: pw.Align(
                            alignment: pw.Alignment.topRight,
                            child: pw.Text(
                              'หน้าที่ ${context.pageNumber} / ${context.pagesCount} ',
                              // textAlign: pw.TextAlign.left,
                              style: pw.TextStyle(
                                fontSize: 10,
                                font: ttf,
                                color: Colors_pd,
                                // fontWeight: pw.FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                        if (TitleType_Default_Receipt_Name != null &&
                            TitleType_Default_Receipt_Name.toString().trim() !=
                                '' &&
                            TitleType_Default_Receipt_Name.toString().trim() !=
                                'ไม่ระบุ')
                          pw.Padding(
                            padding: const pw.EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: pw.Container(
                              width: 80,
                              decoration: pw.BoxDecoration(
                                // color: PdfColors.grey400,
                                borderRadius: pw.BorderRadius.only(
                                    topLeft: pw.Radius.circular(10),
                                    topRight: pw.Radius.circular(10),
                                    bottomLeft: pw.Radius.circular(10),
                                    bottomRight: pw.Radius.circular(10)),
                                border: pw.Border.all(
                                    color: PdfColors.black, width: 1),
                              ),
                              padding: pw.EdgeInsets.all(4),
                              child: pw.Center(
                                child: pw.Text(
                                  '$TitleType_Default_Receipt_Name',
                                  maxLines: 1,
                                  style: pw.TextStyle(
                                    fontSize: 20,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
                pw.SizedBox(height: 1 * PdfPageFormat.mm + 3),
              ],
            )),

        // pw.SizedBox(height: 1 * PdfPageFormat.mm),
        // pw.Divider(),
        // pw.SizedBox(height: 1 * PdfPageFormat.mm),
      ]);
    }

    pw.Widget headerBlock(double fontSize, pw.Font ttf, PdfColor color) {
      return pw.Container(
          // decoration: pw.BoxDecoration(
          //   image: pw.DecorationImage(
          //     image: pw.MemoryImage(
          //       imageBG,
          //     ),
          //     fit: pw.BoxFit.fill,
          //   ),
          // ),
          // padding: pw.EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: pw.Column(children: [
        pw.Container(
          height: (ref_invoice.length > 5)
              ? 112
              : (ref_invoice.length > 1)
                  ? 100
                  : 85,
          child: pw.Row(
            children: [
              pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    height: (ref_invoice.length > 30)
                        ? 260
                        : (ref_invoice.length > 25)
                            ? 230
                            : (ref_invoice.length > 20)
                                ? 200
                                : (ref_invoice.length > 10)
                                    ? 130
                                    : (ref_invoice.length > 5)
                                        ? 112
                                        : (ref_invoice.length > 1)
                                            ? 115
                                            : 85,
                    decoration: const pw.BoxDecoration(
                      // color: PdfColors.green100,
                      border: pw.Border(
                        top: pw.BorderSide(color: PDF_Border_Color),
                        right: pw.BorderSide(color: PDF_Border_Color),
                        left: pw.BorderSide(color: PDF_Border_Color),
                        bottom: pw.BorderSide(color: PDF_Border_Color),
                      ),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.fromLTRB(2, 4, 2, 2),
                              child: pw.Column(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    // (cname.toString() == '' ||
                                    //         cname.toString() == '-' ||
                                    //         cname == null ||
                                    //         cname.toString() ==
                                    //             'null')
                                    //     ? 'นามลูกค้า /Name : ${(sname.toString() == '' || sname == null || sname.toString() == 'null') ? '-' : sname}'
                                    //     :
                                    // 'นามลูกค้า /Name : ${cname}',
                                    (cname != null &&
                                            cname
                                                .toString()
                                                .trim()
                                                .isNotEmpty &&
                                            cname.toString() != 'null' &&
                                            cname.toString() != '-')
                                        ? 'นามลูกค้า /Name : $cname'
                                        : (sname != null &&
                                                sname
                                                    .toString()
                                                    .trim()
                                                    .isNotEmpty &&
                                                sname.toString() != 'null' &&
                                                sname.toString() != '-')
                                            ? 'นามลูกค้า /Name : $sname'
                                            : 'นามลูกค้า /Name : -',
                                    // (sname.toString() == null ||
                                    //         sname.toString() == '' ||
                                    //         sname.toString() == 'null')
                                    //     ? 'นามลูกค้า /Name : -'
                                    //     : 'นามลูกค้า /Name : $sname',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Text(
                                    (addr.toString() == null ||
                                            addr.toString() == '' ||
                                            addr.toString() == 'null')
                                        ? 'ที่อยู่ /Address : -'
                                        : 'ที่อยู่ /Address  : $addr',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Text(
                                    (tax == null ||
                                            tax.toString() == '' ||
                                            tax.toString() == 'null')
                                        ? 'เลขที่ผู้เสียภาษี /Tax : 0'
                                        : 'เลขที่ผู้เสียภาษี /Tax : $tax',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  // pw.Text(
                                  //   'เลขสัญญา /No. : $cid_s ',
                                  //   textAlign: pw.TextAlign.left,
                                  //   style: pw.TextStyle(
                                  //     fontSize: font_Size,
                                  //     font: ttf,
                                  //     fontWeight: pw.FontWeight.bold,
                                  //     color: Colors_pd,
                                  //   ),
                                  // ),
                                  // pw.Text(
                                  //   'โซน /Zone : $Zone_s (รหัสพื้นที่ /Area  : $Ln_s)',
                                  //   textAlign: pw.TextAlign.left,
                                  //   style: pw.TextStyle(
                                  //     fontSize: font_Size,
                                  //     font: ttf,
                                  //     fontWeight: pw.FontWeight.bold,
                                  //     color: Colors_pd,
                                  //   ),
                                  // ),
                                  pw.Text(
                                    'หมายเหตุ /Note : $com_ment ',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  (ref_invoice.length > 1)
                                      ? pw.Text(
                                          'อ้างอิงเลขที่/Refer no. : ${ref_invoice.toSet().map((model) => model).join(', ')}',
                                          textAlign: pw.TextAlign.left,
                                          maxLines: 5,
                                          style: pw.TextStyle(
                                            fontSize: (ref_invoice.length > 20)
                                                ? font_Size - 2
                                                : font_Size,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: Colors_pd,
                                          ),
                                        )
                                      : pw.SizedBox(),
                                ],
                              ),
                            )),
                      ],
                    ),
                  )),
              pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    children: [
                      pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            height: (ref_invoice.length > 5)
                                ? 40
                                : (ref_invoice.length > 1)
                                    ? 20
                                    : 10,
                            decoration: const pw.BoxDecoration(
                              // color: PdfColors.green100,
                              border: pw.Border(
                                right: pw.BorderSide(color: PDF_Border_Color),
                                top: pw.BorderSide(color: PDF_Border_Color),
                                bottom: pw.BorderSide(color: PDF_Border_Color),
                              ),
                            ),
                            child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Expanded(
                                  flex: 1,
                                  child: pw.Column(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.center,
                                      children: [
                                        (hasNonCashTransaction1)
                                            ? pw.Text(
                                                (TitleType_Default_Receipt_Name !=
                                                            null &&
                                                        TitleType_Default_Receipt_Name
                                                                    .toString()
                                                                .trim() !=
                                                            '' &&
                                                        TitleType_Default_Receipt_Name
                                                                .toString() !=
                                                            'ไม่ระบุ')
                                                    ? (numdoctax.toString() ==
                                                            '')
                                                        ? 'บิลเงินสด [ $TitleType_Default_Receipt_Name ]'
                                                        : 'บิลเงินสด/ใบกำกับภาษี [ $TitleType_Default_Receipt_Name ]'
                                                    : (numdoctax.toString() ==
                                                            '')
                                                        ? 'บิลเงินสด'
                                                        : 'บิลเงินสด/ใบกำกับภาษี',
                                                textAlign: pw.TextAlign.center,
                                                style: pw.TextStyle(
                                                  fontSize: 14,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: Colors_pd,
                                                ),
                                              )
                                            : pw.Text(
                                                (TitleType_Default_Receipt_Name !=
                                                            null &&
                                                        TitleType_Default_Receipt_Name
                                                                    .toString()
                                                                .trim() !=
                                                            '' &&
                                                        TitleType_Default_Receipt_Name
                                                                .toString() !=
                                                            'ไม่ระบุ')
                                                    ? (numdoctax.toString() ==
                                                            '')
                                                        ? 'ใบเสร็จรับเงิน'
                                                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี '
                                                    : (numdoctax.toString() ==
                                                            '')
                                                        ? 'ใบเสร็จรับเงิน'
                                                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี',
                                                textAlign: pw.TextAlign.center,
                                                style: pw.TextStyle(
                                                  fontSize: 14,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: Colors_pd,
                                                ),
                                              ),
                                        (hasNonCashTransaction1)
                                            ? pw.Text(
                                                (TitleType_Default_Receipt_Name !=
                                                            null &&
                                                        TitleType_Default_Receipt_Name.toString()
                                                                .trim() !=
                                                            '' &&
                                                        TitleType_Default_Receipt_Name
                                                                .toString() !=
                                                            'ไม่ระบุ')
                                                    ? (numdoctax.toString() ==
                                                            '')
                                                        ? (TitleType_Default_Receipt_Name
                                                                    .toString() ==
                                                                'ต้นฉบับ')
                                                            ? 'Cash Sell Original'
                                                            : (TitleType_Default_Receipt_Name
                                                                        .toString() ==
                                                                    'คู่ฉบับ')
                                                                ? 'Cash Sell Duplicate'
                                                                : (TitleType_Default_Receipt_Name
                                                                            .toString() ==
                                                                        'สำเนาคู่ฉบับ')
                                                                    ? 'Cash Sell Duplicate Copy'
                                                                    : (TitleType_Default_Receipt_Name.toString() ==
                                                                            'สำเนา')
                                                                        ? 'Cash Sell Copy'
                                                                        : 'Cash Sell'
                                                        : (TitleType_Default_Receipt_Name
                                                                    .toString() ==
                                                                'ต้นฉบับ')
                                                            ? 'Cash Sell/Tax Invoice Original'
                                                            : (TitleType_Default_Receipt_Name
                                                                        .toString() ==
                                                                    'คู่ฉบับ')
                                                                ? 'Cash Sell/Tax Invoice Duplicate'
                                                                : (TitleType_Default_Receipt_Name
                                                                            .toString() ==
                                                                        'สำเนาคู่ฉบับ')
                                                                    ? 'Cash Sell/Tax Invoice Duplicate Copy'
                                                                    : (TitleType_Default_Receipt_Name.toString() ==
                                                                            'สำเนา')
                                                                        ? 'Cash Sell/Tax Invoice Copy'
                                                                        : 'Cash Sell/Tax Invoice'
                                                    : (numdoctax.toString() ==
                                                            '')
                                                        ? 'Cash Sell'
                                                        : 'Cash Sell/Tax Invoice',
                                                textAlign: pw.TextAlign.center,
                                                style: pw.TextStyle(
                                                  fontSize: 14,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: Colors_pd,
                                                ),
                                              )
                                            : pw.Text(
                                                (TitleType_Default_Receipt_Name !=
                                                        null)
                                                    ? (numdoctax.toString() ==
                                                            '')
                                                        ? (TitleType_Default_Receipt_Name
                                                                    .toString() ==
                                                                'ต้นฉบับ')
                                                            ? 'Receipt Original'
                                                            : (TitleType_Default_Receipt_Name
                                                                        .toString() ==
                                                                    'คู่ฉบับ')
                                                                ? 'Receipt Duplicate'
                                                                : (TitleType_Default_Receipt_Name
                                                                            .toString() ==
                                                                        'สำเนาคู่ฉบับ')
                                                                    ? 'Receipt Duplicate Copy'
                                                                    : (TitleType_Default_Receipt_Name.toString() ==
                                                                            'สำเนา')
                                                                        ? 'Receipt Copy'
                                                                        : 'Receipt'
                                                        : (TitleType_Default_Receipt_Name
                                                                    .toString() ==
                                                                'ต้นฉบับ')
                                                            ? 'Receipt/Tax Receipt Original'
                                                            : (TitleType_Default_Receipt_Name
                                                                        .toString() ==
                                                                    'คู่ฉบับ')
                                                                ? 'Receipt/Tax Receipt Duplicate'
                                                                : (TitleType_Default_Receipt_Name
                                                                            .toString() ==
                                                                        'สำเนาคู่ฉบับ')
                                                                    ? 'Receipt/Tax Receipt Duplicate Copy'
                                                                    : (TitleType_Default_Receipt_Name.toString() ==
                                                                            'สำเนา')
                                                                        ? 'Receipt/Tax Receipt Copy'
                                                                        : 'Receipt/Tax Invoice'
                                                    : (numdoctax.toString() ==
                                                            '')
                                                        ? 'Receipt'
                                                        : 'Receipt/Tax Invoice',
                                                textAlign: pw.TextAlign.center,
                                                style: pw.TextStyle(
                                                  fontSize: 14,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: Colors_pd,
                                                ),
                                              ),
                                      ]),
                                ),
                              ],
                            ),
                          )),
                      pw.Row(
                        children: [
                          pw.Expanded(
                              flex: 1,
                              child: pw.Container(
                                height: (ref_invoice.length > 5)
                                    ? 70
                                    : (ref_invoice.length > 1)
                                        ? 50
                                        : 40,
                                decoration: const pw.BoxDecoration(
                                  // color: PdfColors.green100,
                                  border: pw.Border(
                                    right:
                                        pw.BorderSide(color: PDF_Border_Color),
                                    top: pw.BorderSide(color: PDF_Border_Color),
                                    bottom:
                                        pw.BorderSide(color: PDF_Border_Color),
                                  ),
                                ),
                                child: pw.Row(
                                  // crossAxisAlignment:
                                  //     pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Expanded(
                                      flex: 1,
                                      child: pw.Column(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.center,
                                          children: [
                                            pw.Text(
                                              'วันที่ทำรายการ',
                                              textAlign: pw.TextAlign.center,
                                              style: pw.TextStyle(
                                                fontSize: font_Size,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: Colors_pd,
                                              ),
                                            ),
                                            pw.Text(
                                              'Date',
                                              textAlign: pw.TextAlign.center,
                                              style: pw.TextStyle(
                                                fontSize: font_Size,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: Colors_pd,
                                              ),
                                            ),
                                            pw.Text(
                                              '${DateFormat('dd/MM').format(DateTime.parse(date_Transaction!))}/${DateTime.parse('${date_Transaction}').year + 543}',
                                              //'$date_Transaction',
                                              textAlign: pw.TextAlign.center,
                                              style: pw.TextStyle(
                                                fontSize: font_Size,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: Colors_pd,
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ],
                                ),
                              )),
                          pw.Expanded(
                              flex: 1,
                              child: pw.Container(
                                height: (ref_invoice.length > 5)
                                    ? 70
                                    : (ref_invoice.length > 1)
                                        ? 50
                                        : 40,
                                decoration: const pw.BoxDecoration(
                                  // color: PdfColors.green100,
                                  border: pw.Border(
                                    right:
                                        pw.BorderSide(color: PDF_Border_Color),
                                    top: pw.BorderSide(color: PDF_Border_Color),
                                    bottom:
                                        pw.BorderSide(color: PDF_Border_Color),
                                  ),
                                ),
                                child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Expanded(
                                      flex: 1,
                                      child: pw.Column(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.center,
                                          children: [
                                            pw.Text(
                                              'เลขที่ใบกำกับ',
                                              textAlign: pw.TextAlign.center,
                                              style: pw.TextStyle(
                                                fontSize: font_Size,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: Colors_pd,
                                              ),
                                            ),
                                            pw.Text(
                                              'Order no.',
                                              textAlign: pw.TextAlign.center,
                                              style: pw.TextStyle(
                                                fontSize: font_Size,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: Colors_pd,
                                              ),
                                            ),
                                            pw.Text(
                                              (numdoctax.toString() == '')
                                                  ? '$numinvoice '
                                                  : '$numdoctax ',
                                              textAlign: pw.TextAlign.center,
                                              style: pw.TextStyle(
                                                fontSize: font_Size,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: Colors_pd,
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ],
                                ),
                              )),
                          (ref_invoice.length == 0 || ref_invoice.length > 1)
                              ? pw.SizedBox()
                              : pw.Expanded(
                                  flex: 1,
                                  child: pw.Container(
                                    height: 40,
                                    decoration: const pw.BoxDecoration(
                                      // color: PdfColors.green100,
                                      border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PDF_Border_Color),
                                        top: pw.BorderSide(
                                            color: PDF_Border_Color),
                                        bottom: pw.BorderSide(
                                            color: PDF_Border_Color),
                                      ),
                                    ),
                                    child: pw.Row(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Expanded(
                                          flex: 1,
                                          child: pw.Column(
                                              mainAxisAlignment:
                                                  pw.MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.center,
                                              children: [
                                                pw.Text(
                                                  'อ้างอิงเลขที่',
                                                  textAlign:
                                                      pw.TextAlign.center,
                                                  style: pw.TextStyle(
                                                    fontSize: font_Size,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: Colors_pd,
                                                  ),
                                                ),
                                                pw.Text(
                                                  'Refer no.',
                                                  textAlign:
                                                      pw.TextAlign.center,
                                                  style: pw.TextStyle(
                                                    fontSize: font_Size,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: Colors_pd,
                                                  ),
                                                ),
                                                pw.Text(
                                                  (ref_invoice[0].toString() ==
                                                          '')
                                                      ? '-'
                                                      : '${ref_invoice[0]}',
                                                  // (ref_invoice == null ||
                                                  //         ref_invoice
                                                  //                 .toString() ==
                                                  //             '')
                                                  //     ? ''
                                                  //     : '${ref_invoice}',
                                                  textAlign:
                                                      pw.TextAlign.center,
                                                  style: pw.TextStyle(
                                                    fontSize: font_Size,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: Colors_pd,
                                                  ),
                                                ),
                                              ]),
                                        ),
                                      ],
                                    ),
                                  )),
                        ],
                      )
                    ],
                  )),
            ],
          ),
        ),
        pw.Container(
          height: 35,
          child: pw.Row(
            children: [
              pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    height: 35,
                    decoration: const pw.BoxDecoration(
                      // color: PdfColors.green100,
                      border: pw.Border(
                        // right: pw.BorderSide(color: PdfColors.grey600),
                        left: pw.BorderSide(color: PDF_Border_Color),
                        bottom: pw.BorderSide(color: PDF_Border_Color),
                      ),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                              height: 35,
                              decoration: const pw.BoxDecoration(
                                // color: PdfColors.green100,
                                border: pw.Border(
                                  right: pw.BorderSide(color: PDF_Border_Color),
                                  bottom:
                                      pw.BorderSide(color: PDF_Border_Color),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    'พนักงานผู้ทำสัญญา /Contractor man No.',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Text(
                                    (fname == '' || fname == null)
                                        ? '-'
                                        : '$fname',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                              height: 35,
                              decoration: const pw.BoxDecoration(
                                // color: PdfColors.green100,
                                border: pw.Border(
                                  bottom:
                                      pw.BorderSide(color: PDF_Border_Color),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    'ประเภท /Type.',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Text(
                                    (type_bills.toString().trim() == '' ||
                                            type_bills == null)
                                        ? 'สัญญา'
                                        : 'ล็อคเสียบ',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                              height: 35,
                              decoration: const pw.BoxDecoration(
                                // color: PdfColors.green100,
                                border: pw.Border(
                                  right: pw.BorderSide(color: PDF_Border_Color),
                                  left: pw.BorderSide(color: PDF_Border_Color),
                                  bottom:
                                      pw.BorderSide(color: PDF_Border_Color),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    'รหัสลูกค้า /Code',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Text(
                                    (Cust_no.toString() == '' ||
                                            Cust_no == null)
                                        ? '-'
                                        : '$Cust_no',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  )),
              pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    height: 35,
                    decoration: const pw.BoxDecoration(
                      // color: PdfColors.green100,
                      border: pw.Border(
                        right: pw.BorderSide(color: PDF_Border_Color),
                        // left: pw.BorderSide(color: PdfColors.grey800),
                        bottom: pw.BorderSide(color: PDF_Border_Color),
                      ),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                              height: 35,
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    'วันที่รับชำระ /Payment Date',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Text(
                                    (dayfinpay.toString() == '' ||
                                            dayfinpay.toString() == 'null' ||
                                            dayfinpay == null)
                                        ? '-'
                                        : '${DateFormat('dd/MM').format(DateTime.parse(dayfinpay!))}/${DateTime.parse('${dayfinpay}').year + 543}',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        )
      ]));
    }

    // ═══════════════════════════════════════════════════════════════════════
    // [showVatWht] ปิดไว้ก่อน — เงื่อนไขซ่อนคอลัมน์ 7 ภาษี(Vat) + 8 หัก ณ ที่จ่าย(WHT)
    // กติกา: ถ้า "วันที่รับชำระ" (dayfinpay) ก่อน 25/06/2026 → ไม่แสดง 2 คอลัมน์นี้
    //
    // วิธีเปิดใช้ = เอาคอมเมนต์ออกทั้ง 4 จุดที่ทำเครื่องหมาย [showVatWht]
    //   จุดที่ 1 บล็อกนี้ + ผังคอลัมน์ด้านล่าง (ต้องสลับไปใช้เวอร์ชัน _cols)
    //   จุดที่ 2 tableHeader   จุดที่ 3 itemRow   จุดที่ 4 tablefool
    //
    // final DateTime _vatWhtStart = DateTime(2026, 6, 25);
    // final DateTime? _payDate = (dayfinpay == null ||
    //         dayfinpay.toString().trim() == '' ||
    //         dayfinpay.toString().trim() == 'null')
    //     ? null
    //     : DateTime.tryParse(dayfinpay.toString());
    // // ไม่มีวันที่รับชำระ = แสดงตามปกติ
    // final bool showVatWht =
    //     (_payDate == null) ? true : !_payDate.isBefore(_vatWhtStart);
    // ═══════════════════════════════════════════════════════════════════════

    // ── ผังคอลัมน์กลางของตารางรายการ ──
    // ใช้ร่วมกันทั้ง หัวตาราง (tableHeader) / แถวรายการ (itemRow) / แถวสรุป (tablefool)
    // แก้ความกว้างที่นี่ที่เดียว ทุกส่วนจะตรงกันเสมอ
    // 0 ลำดับ | 1 รหัสสินค้า | 2 รายละเอียด | 3 จำนวน | 4 หน่วยละ | 5 ราคา
    // 6 ส่วนลด | 7 ภาษี | 8 หัก ณ ที่จ่าย | 9 จำนวนเงิน
    const Map<int, pw.TableColumnWidth> tableColumnWidths = {
      0: pw.FixedColumnWidth(25),
      1: pw.FixedColumnWidth(95),
      2: pw.FlexColumnWidth(3),
      3: pw.FixedColumnWidth(35),
      4: pw.FixedColumnWidth(35),
      5: pw.FlexColumnWidth(1),
      6: pw.FlexColumnWidth(1),
      7: pw.FlexColumnWidth(1),
      8: pw.FlexColumnWidth(1),
      9: pw.FlexColumnWidth(1),
    };

    // [showVatWht] จุดที่ 1 — เปิดเงื่อนไขให้ "คอมเมนต์ผังคอลัมน์ const ด้านบนทิ้ง"
    // แล้วใช้เวอร์ชันนี้แทน (ไล่เลข index ใหม่ให้อัตโนมัติเมื่อตัด 2 คอลัมน์ออก)
    // final List<pw.TableColumnWidth> _cols = [
    //   const pw.FixedColumnWidth(25), // 0 ลำดับ
    //   const pw.FixedColumnWidth(95), // 1 รหัสสินค้า
    //   const pw.FlexColumnWidth(3), // 2 รายละเอียด
    //   const pw.FixedColumnWidth(35), // 3 จำนวน
    //   const pw.FixedColumnWidth(35), // 4 หน่วยละ
    //   const pw.FlexColumnWidth(1), // 5 ราคา
    //   const pw.FlexColumnWidth(1), // 6 ส่วนลด
    //   if (showVatWht) const pw.FlexColumnWidth(1), // 7 ภาษี
    //   if (showVatWht) const pw.FlexColumnWidth(1), // 8 หัก ณ ที่จ่าย
    //   const pw.FlexColumnWidth(1), // 9 จำนวนเงิน
    // ];
    // final Map<int, pw.TableColumnWidth> tableColumnWidths = {
    //   for (int i = 0; i < _cols.length; i++) i: _cols[i]
    // };

    pw.Widget tableHeader(double fontSize, pw.Font ttf) {
      // — หัวคอลัมน์ ไทย/อังกฤษ ทุกช่องสูงเท่ากัน —
      pw.Widget headCell(String th, String en) => pw.Container(
            height: 30,
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(horizontal: 2.0),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  th,
                  maxLines: 1,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                      fontSize: font_Size, font: ttf, color: PdfColors.black),
                ),
                pw.Text(
                  en,
                  maxLines: 1,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                      fontSize: font_Size, font: ttf, color: PdfColors.black),
                ),
              ],
            ),
          );

      return pw.Table(
        columnWidths: tableColumnWidths,
        border: pw.TableBorder.all(color: PDF_Border_Color, width: 1),
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          pw.TableRow(
            children: [
              headCell('ลำดับ', 'No.'),
              headCell('รหัสสินค้า', 'Product Code'),
              headCell('รายละเอียด', 'Description'),
              headCell('จำนวน', 'Quantity'),
              headCell('หน่วยละ', 'Unit'),
              headCell('ราคา', 'Price'),
              headCell('ส่วนลด', 'Dis'),
              // [showVatWht] จุดที่ 2 — เปิดเงื่อนไข: ใช้ 2 บรรทัดคอมเมนต์นี้
              // แทน 2 บรรทัดที่ใช้อยู่ (แล้วคอมเมนต์ 2 บรรทัดที่ใช้อยู่ทิ้ง)
              // if (showVatWht) headCell('ภาษี', 'Vat'),
              // if (showVatWht) headCell('หัก ณ ที่จ่าย', 'WHT'),
              headCell('ภาษี', 'Vat'),
              headCell('หัก ณ ที่จ่าย', 'WHT'),
              headCell('จำนวนเงิน', 'Amount'),
            ],
          ),
        ],
      );
    }

    pw.Widget itemRow(
        TransReBillHistory, int index, double fontSize, pw.Font ttf) {
      final TransReBill = TransReBillHistory[index];

      pw.Widget cell(
        String text, {
        pw.Alignment alignment = pw.Alignment.centerRight,
        pw.TextAlign textAlign = pw.TextAlign.right,
      }) =>
          pw.Container(
            padding: const pw.EdgeInsets.all(2.0),
            alignment: alignment,
            child: pw.Text(
              text,
              maxLines: 2,
              textAlign: textAlign,
              style: pw.TextStyle(
                  fontSize: font_Size, font: ttf, color: PdfColors.grey800),
            ),
          );

      return pw.Table(
        columnWidths: tableColumnWidths,
        // เส้นแนวตั้งอย่างเดียว (ไม่มีเส้นคั่นระหว่างแถว) ให้เหมือนของเดิม
        // ถ้าอยากได้ตารางเต็มกริด เปลี่ยนเป็น:
        // border: pw.TableBorder.all(color: PDF_Border_Color, width: 1),
        border: const pw.TableBorder(
          left: pw.BorderSide(color: PDF_Border_Color),
          right: pw.BorderSide(color: PDF_Border_Color),
          verticalInside: pw.BorderSide(color: PDF_Border_Color),
        ),
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          pw.TableRow(
            children: [
              // ลำดับ
              cell(
                '${index + 1}',
                alignment: pw.Alignment.center,
                textAlign: pw.TextAlign.center,
              ),
              // รหัสสินค้า
              cell(
                (TransReBill.zn != null)
                    ? (TransReBill.zn!.split('_')[0].length <= 4)
                        ? '${TransReBill.refno}/0${TransReBill.zn!.split('_')[0]}'
                        : '${TransReBill.refno}/${TransReBill.zn!.split('_')[0]}'
                    : (TransReBill.fine.toString() == '1.00' &&
                            TransReBill.refno.toString().trim() == 'null')
                        ? (TransReBill.zn!.split('_')[0].length <= 4)
                            ? '-/0${TransReBill.zn!.split('_')[0]}'
                            : '-/${TransReBill.zn!.split('_')[0]}'
                        : '${TransReBill.refno}',
                alignment: pw.Alignment.centerLeft,
                textAlign: pw.TextAlign.left,
              ),
              // รายละเอียด
              cell(
                (TransReBill.unitser.toString() == '6')
                    ? '${TransReBill.expname} [ หน่วยที่ใช้ไป ${TransReBill.ovalue}-${TransReBill.nvalue} ]' //descr
                    : '${TransReBill.expname}',
                alignment: pw.Alignment.centerLeft,
                textAlign: pw.TextAlign.left,
              ),
              // จำนวน
              cell(getFormattedText(TransReBill.qty)),
              // หน่วยละ
              cell((TransReBill.ele_ty.toString() != '0' &&
                      TransReBill.ele_ty != null)
                  ? 'อัตราพิเศษ'
                  : (TransReBill.exp_dtype.toString() == 'KU')
                      ? getFormattedText('${TransReBill.pri}')
                      : '-'),
              // ราคา
              cell((double.tryParse(TransReBill.pvat_original.toString()) != 0)
                  ? getFormattedText('${TransReBill.pvat_original}')
                  : (TransReBill.exp_dtype.toString() == 'KU')
                      ? getFormattedText('${TransReBill.pvat}')
                      : getFormattedText('${TransReBill.pvat}')),
              // ส่วนลด
              cell(getFormattedText('${TransReBill.dis_list}')),
              // [showVatWht] จุดที่ 3 — เปิดเงื่อนไข: ใช้ 2 บล็อกคอมเมนต์นี้
              // แทน 2 บล็อกที่ใช้อยู่ (แล้วคอมเมนต์ 2 บล็อกที่ใช้อยู่ทิ้ง)
              // // ภาษี
              // if (showVatWht)
              //   cell(nFormat.format(
              //       (double.tryParse(TransReBill.vat ?? '0') ?? 0) +
              //           20000000.00)),
              // // หัก ณ ที่จ่าย
              // if (showVatWht) cell(getFormattedText('${TransReBill.wht}')),
              // ภาษี
              cell(nFormat
                  .format((double.tryParse(TransReBill.vat ?? '0') ?? 0))),
              // หัก ณ ที่จ่าย
              cell(getFormattedText('${TransReBill.wht}')),
              // จำนวนเงิน
              cell(nFormat.format(
                  (double.tryParse(TransReBill.pvat ?? '0') ?? 0) +
                      (double.tryParse(TransReBill.vat ?? '0') ?? 0))),
            ],
          ),
        ],
      );
    }

    pw.Widget tablefool(double fontSize, pw.Font ttf) {
      // ── แถวสรุป: ทุกช่องสูงเท่ากัน เส้นกรอบถึงต่อกันสนิท ──
      // คอลัมน์ตาราง: 25 | 95 | 3 | 1 | 1 | 1 | 1 | 1 | 1 | 1  (ดู tableColumnWidths)
      final double _foolH = font_Size * 1.7;

      pw.Widget _foolCell({
        String? text,
        bool alignRight = false,
        bool left = false,
        bool bottom = false,
        bool right = false,
      }) =>
          pw.Container(
            height: _foolH,
            padding: const pw.EdgeInsets.symmetric(horizontal: 2.0),
            alignment:
                alignRight ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border(
                top: const pw.BorderSide(color: PDF_Border_Color),
                left: left
                    ? const pw.BorderSide(color: PDF_Border_Color)
                    : pw.BorderSide.none,
                bottom: bottom
                    ? const pw.BorderSide(color: PDF_Border_Color)
                    : pw.BorderSide.none,
                right: right
                    ? const pw.BorderSide(color: PDF_Border_Color)
                    : pw.BorderSide.none,
              ),
            ),
            child: (text == null)
                ? null
                : pw.Text(
                    text,
                    maxLines: 1,
                    textAlign:
                        alignRight ? pw.TextAlign.right : pw.TextAlign.left,
                    style: pw.TextStyle(
                        fontSize: font_Size,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: PdfColors.grey800),
                  ),
          );

      return pw.Column(
        children: [
          pw.Table(
            columnWidths: tableColumnWidths,
            children: [
              pw.TableRow(
                children: [
                  _foolCell(), // ลำดับ
                  _foolCell(), // รหัสสินค้า
                  // รายละเอียด  <-- ช่อง 'ส่วนลด' ตรงคอลัมน์นี้พอดี
                  _foolCell(text: 'ส่วนลด', left: true, bottom: true),
                  _foolCell(bottom: true), // จำนวน
                  _foolCell(bottom: true), // หน่วยละ
                  _foolCell(bottom: true), // ราคา
                  _foolCell(bottom: true), // ส่วนลด
                  // [showVatWht] จุดที่ 4 — เปิดเงื่อนไข: ใช้ 2 บรรทัดคอมเมนต์นี้
                  // แทน 2 บรรทัดที่ใช้อยู่ (แล้วคอมเมนต์ 2 บรรทัดที่ใช้อยู่ทิ้ง)
                  // if (showVatWht) _foolCell(bottom: true), // ภาษี
                  // if (showVatWht) _foolCell(bottom: true), // หัก ณ ที่จ่าย
                  _foolCell(bottom: true), // ภาษี
                  _foolCell(bottom: true), // หัก ณ ที่จ่าย
                  // จำนวนเงิน
                  _foolCell(
                    text: nFormat.format(totalDis),
                    alignRight: true,
                    bottom: true,
                    right: true,
                  ),
                ],
              ),
            ],
          ),

          pw.Container(
            decoration: const pw.BoxDecoration(
              // color: PdfColors.white,
              border: const pw.Border(
                  // top: pw.BorderSide(color: PdfColors.grey600),
                  // left: pw.BorderSide(color: PdfColors.grey600),
                  ),
            ),
            // padding: const pw.EdgeInsets.fromLTRB(0, 4, 0, 0),
            alignment: pw.Alignment.centerRight,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
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
                pw.Container(width: 30),
                pw.Spacer(flex: 7),
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      for (int index = 0; index < BillsList.length; index++)
                        pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 3,
                              child: pw.Container(
                                decoration: const pw.BoxDecoration(
                                  color: PdfColors.white,
                                  border: const pw.Border(
                                    top: pw.BorderSide(color: PDF_Border_Color),
                                    left:
                                        pw.BorderSide(color: PDF_Border_Color),
                                    bottom:
                                        pw.BorderSide(color: PDF_Border_Color),
                                    right:
                                        pw.BorderSide(color: PDF_Border_Color),
                                  ),
                                ),
                                padding: const pw.EdgeInsets.all(2.0),
                                child: pw.Text(
                                  '${BillsList[index]['pn'] ?? ''}',
                                  style: pw.TextStyle(
                                      fontSize: font_Size,
                                      fontWeight: pw.FontWeight.bold,
                                      font: ttf,
                                      color: PdfColors.grey800),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Container(
                                decoration: const pw.BoxDecoration(
                                  color: PdfColors.white,
                                  border: const pw.Border(
                                    left:
                                        pw.BorderSide(color: PDF_Border_Color),
                                    top: pw.BorderSide(color: PDF_Border_Color),
                                    right:
                                        pw.BorderSide(color: PDF_Border_Color),
                                    bottom:
                                        pw.BorderSide(color: PDF_Border_Color),
                                  ),
                                ),
                                padding: const pw.EdgeInsets.all(2.0),
                                child: pw.Text(
                                  '${BillsList[index]['total'] ?? ''}',
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                      fontSize: font_Size,
                                      fontWeight: pw.FontWeight.bold,
                                      font: ttf,
                                      color: PdfColors.grey800),
                                ),
                              ),
                            ),
                          ],
                        ),
                      // pw.Row(
                      //   children: [
                      //     pw.Expanded(
                      //       flex: 3,
                      //       child: pw.Container(
                      //         decoration: const pw.BoxDecoration(
                      //           color: PdfColors.white,
                      //           border: const pw.Border(
                      //             top: pw.BorderSide(color: PDF_Border_Color),
                      //             left: pw.BorderSide(color: PDF_Border_Color),
                      //             bottom:
                      //                 pw.BorderSide(color: PDF_Border_Color),
                      //             right: pw.BorderSide(color: PDF_Border_Color),
                      //           ),
                      //         ),
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text(
                      //           'รวมราคาสินค้า ไม่มี/ยกเว้นภาษี',
                      //           style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               fontWeight: pw.FontWeight.bold,
                      //               font: ttf,
                      //               color: PdfColors.grey800),
                      //         ),
                      //       ),
                      //     ),
                      //     pw.Expanded(
                      //       flex: 2,
                      //       child: pw.Container(
                      //         decoration: const pw.BoxDecoration(
                      //           color: PdfColors.white,
                      //           border: const pw.Border(
                      //             left: pw.BorderSide(color: PDF_Border_Color),
                      //             top: pw.BorderSide(color: PDF_Border_Color),
                      //             right: pw.BorderSide(color: PDF_Border_Color),
                      //             bottom:
                      //                 pw.BorderSide(color: PDF_Border_Color),
                      //           ),
                      //         ),
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text(
                      //           // '${nFormat.format(sum_Nonvat == null ? 0.00 : double.parse(sum_Nonvat.toString()))}',
                      //           // '${roundToTwoDecimals('${double.parse(sum_pvat.toString())}')}',
                      //           // (round_p.toString() == '1')
                      //           //     ? (amt_up == null)
                      //           //         ? '0.00'
                      //           //         : '${nFormat.format(double.parse(amt_up.toString()))}'
                      //           //     : '${nFormat.format(double.parse(sum_pvat.toString()))}',
                      //           '${nFormat.format(net_non_pvat)}',
                      //           textAlign: pw.TextAlign.right,
                      //           style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               fontWeight: pw.FontWeight.bold,
                      //               font: ttf,
                      //               color: PdfColors.grey800),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // pw.Row(
                      //   children: [
                      //     pw.Expanded(
                      //       flex: 3,
                      //       child: pw.Container(
                      //         decoration: const pw.BoxDecoration(
                      //           color: PdfColors.white,
                      //           border: const pw.Border(
                      //             top: pw.BorderSide(color: PDF_Border_Color),
                      //             left: pw.BorderSide(color: PDF_Border_Color),
                      //             bottom:
                      //                 pw.BorderSide(color: PDF_Border_Color),
                      //             right: pw.BorderSide(color: PDF_Border_Color),
                      //           ),
                      //         ),
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text(
                      //           'จำนวนเงินรวมทั้งสิ้น',
                      //           style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               fontWeight: pw.FontWeight.bold,
                      //               font: ttf,
                      //               color: PdfColors.grey800),
                      //         ),
                      //       ),
                      //     ),
                      //     pw.Expanded(
                      //       flex: 2,
                      //       child: pw.Container(
                      //         decoration: const pw.BoxDecoration(
                      //           color: PdfColors.white,
                      //           border: const pw.Border(
                      //             left: pw.BorderSide(color: PDF_Border_Color),
                      //             top: pw.BorderSide(color: PDF_Border_Color),
                      //             bottom:
                      //                 pw.BorderSide(color: PDF_Border_Color),
                      //             right: pw.BorderSide(color: PDF_Border_Color),
                      //           ),
                      //         ),
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text(
                      //           // '${nFormat.format(Total == null ? 0.00 : double.parse(Total.toString()))}',
                      //           // '${nFormat.format(((totalPvat + totalVat) - totalWht) + totalFee)}',
                      //           // '${nFormat.format(((totalPvat + totalVat) - totalWht) + totalFee)}',
                      //           '${nFormat.format(roundMoney(totalPvat + totalVat))}',
                      //           // ('${TransReBill.total}'),

                      //           // '${nFormat.format((double.parse(Total.toString()) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}',
                      //           // (nFormat.format(double.parse(
                      //           //             dis_sum_Matjum
                      //           //                 .toString())) !=
                      //           //         '0.00')
                      //           //     ? '${nFormat.format(double.parse(dis_sum_Matjum.toString()) - double.parse(sum_addvat_choice.toString()) * 1.07)}' //dis_sum_Matjum
                      //           //     : (nFormat.format(double.parse(
                      //           //                 dis_sum_Pakan
                      //           //                     .toString())) !=
                      //           //             '0.00')
                      //           //         ? '${nFormat.format(double.parse(dis_sum_Pakan.toString()) - double.parse(sum_addvat_choice.toString()) * 1.07)}'
                      //           //         : '${nFormat.format((double.parse(sum_addvat_choice.toString()) - double.parse(sum_disamt.toString())) * 1.07)}',
                      //           textAlign: pw.TextAlign.right,
                      //           style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               fontWeight: pw.FontWeight.bold,
                      //               font: ttf,
                      //               color: PdfColors.grey800),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // pw.Row(
                      //   children: [
                      //     pw.Expanded(
                      //       flex: 3,
                      //       child: pw.Container(
                      //         decoration: const pw.BoxDecoration(
                      //           color: PdfColors.white,
                      //           border: const pw.Border(
                      //             top: pw.BorderSide(color: PDF_Border_Color),
                      //             left: pw.BorderSide(color: PDF_Border_Color),
                      //             bottom:
                      //                 pw.BorderSide(color: PDF_Border_Color),
                      //             right: pw.BorderSide(color: PDF_Border_Color),
                      //           ),
                      //         ),
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text(
                      //           'รวมราคาสินค้าคำนวณภาษีมูลค่าเพิ่ม',
                      //           style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               fontWeight: pw.FontWeight.bold,
                      //               font: ttf,
                      //               color: PdfColors.grey800),
                      //         ),
                      //       ),
                      //     ),
                      //     pw.Expanded(
                      //       flex: 2,
                      //       child: pw.Container(
                      //         decoration: const pw.BoxDecoration(
                      //           color: PdfColors.white,
                      //           border: const pw.Border(
                      //             left: pw.BorderSide(color: PDF_Border_Color),
                      //             top: pw.BorderSide(color: PDF_Border_Color),
                      //             right: pw.BorderSide(color: PDF_Border_Color),
                      //             bottom:
                      //                 pw.BorderSide(color: PDF_Border_Color),
                      //           ),
                      //         ),
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text(
                      //           // '${nFormat.format(((double.parse(Total.toString()) * 100 / 107) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}',

                      //           // '${nFormat.format(double.parse(Sum_SubTotal.toString()))}',
                      //           // '${nFormat.format(double.parse(sum_addvat.toString()))}',
                      //           // (nFormat.format(double.parse(
                      //           //             sum_addvat.toString())) !=
                      //           //         '0.00')
                      //           //     ? '${nFormat.format(((double.parse(Total.toString()) * 100 / 107) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}'
                      //           //     : '${nFormat.format(double.parse(sum_addvat.toString()))}',

                      //           // '${nFormat.format(net_amount_pvat)}',
                      //           '${nFormat.format(net_amount_pvat)}',

                      //           ///
                      //           textAlign: pw.TextAlign.right,
                      //           style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               fontWeight: pw.FontWeight.bold,
                      //               font: ttf,
                      //               color: PdfColors.grey800),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // pw.Row(
                      //   children: [
                      //     pw.Expanded(
                      //       flex: 3,
                      //       child: pw.Container(
                      //         decoration: const pw.BoxDecoration(
                      //           color: PdfColors.white,
                      //           border: const pw.Border(
                      //             top: pw.BorderSide(color: PDF_Border_Color),
                      //             left: pw.BorderSide(color: PDF_Border_Color),
                      //             bottom:
                      //                 pw.BorderSide(color: PDF_Border_Color),
                      //             right: pw.BorderSide(color: PDF_Border_Color),
                      //           ),
                      //         ),
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text(
                      //           'ภาษีมูลค่าเพิ่ม 7%/ Vat',
                      //           style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               fontWeight: pw.FontWeight.bold,
                      //               font: ttf,
                      //               color: PdfColors.grey800),
                      //         ),
                      //       ),
                      //     ),
                      //     pw.Expanded(
                      //       flex: 2,
                      //       child: pw.Container(
                      //         decoration: const pw.BoxDecoration(
                      //           color: PdfColors.white,
                      //           border: const pw.Border(
                      //             left: pw.BorderSide(color: PDF_Border_Color),
                      //             top: pw.BorderSide(color: PDF_Border_Color),
                      //             right: pw.BorderSide(color: PDF_Border_Color),
                      //             bottom:
                      //                 pw.BorderSide(color: PDF_Border_Color),
                      //           ),
                      //         ),
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text(
                      //           // (round_p.toString() == '1')
                      //           //     ? (vat_up == null
                      //           //         ? '0.00'
                      //           //         : '${nFormat.format(double.parse(vat_up.toString()))}')
                      //           // : '${nFormat.format(double.parse(sum_vat.toString()))}',

                      //           ///
                      //           //  : '${nFormat.format(double.parse(Total.toString()) * 7 / 100)}',
                      //           // : '${nFormat.format((((double.parse(Total.toString()) * 100 / 107) * 7 / 100) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}',

                      //           // : '${nFormat.format((double.parse(roundToTwoDecimals('${double.parse(sum_pvat.toString())}')) * 7) / 100)}', //pvat

                      //           // // : '${nFormat.format((double.parse(sum_addvat_choice.toString()) * 7) / 100)}',
                      //           // (nFormat.format(double.parse(
                      //           //             sum_addvat.toString())) !=
                      //           //         '0.00')
                      //           //     ? '${nFormat.format((((double.parse(Total.toString()) * 100 / 107) * 7 / 100) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}'
                      //           //     : '${nFormat.format(double.parse(sum_addvat.toString()))}',
                      //           '${nFormat.format(totalVat)}',
                      //           textAlign: pw.TextAlign.right,
                      //           style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               fontWeight: pw.FontWeight.bold,
                      //               font: ttf,
                      //               color: PdfColors.grey800),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // pw.Row(
                      //   children: [
                      //     pw.Expanded(
                      //       flex: 3,
                      //       child: pw.Container(
                      //         decoration: const pw.BoxDecoration(
                      //           color: PdfColors.white,
                      //           border: const pw.Border(
                      //             top: pw.BorderSide(color: PDF_Border_Color),
                      //             left: pw.BorderSide(color: PDF_Border_Color),
                      //             bottom:
                      //                 pw.BorderSide(color: PDF_Border_Color),
                      //             right: pw.BorderSide(color: PDF_Border_Color),
                      //           ),
                      //         ),
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text(
                      //           'หัก ณ ที่จ่าย / Withholding ',
                      //           style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               fontWeight: pw.FontWeight.bold,
                      //               font: ttf,
                      //               color: PdfColors.grey800),
                      //         ),
                      //       ),
                      //     ),
                      //     pw.Expanded(
                      //       flex: 2,
                      //       child: pw.Container(
                      //         decoration: const pw.BoxDecoration(
                      //           color: PdfColors.white,
                      //           border: const pw.Border(
                      //             left: pw.BorderSide(color: PDF_Border_Color),
                      //             top: pw.BorderSide(color: PDF_Border_Color),
                      //             bottom:
                      //                 pw.BorderSide(color: PDF_Border_Color),
                      //             right: pw.BorderSide(color: PDF_Border_Color),
                      //           ),
                      //         ),
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text(
                      //           // '${nFormat.format(double.parse(sum_wht.toString()))}',
                      //           '${nFormat.format(totalWht)}',
                      //           textAlign: pw.TextAlign.right,
                      //           style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               fontWeight: pw.FontWeight.bold,
                      //               font: ttf,
                      //               color: PdfColors.grey800),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // pw.Row(
                      //   children: [
                      //     pw.Expanded(
                      //       flex: 3,
                      //       child: pw.Container(
                      //         decoration: const pw.BoxDecoration(
                      //           color: PdfColors.white,
                      //           border: const pw.Border(
                      //             top: pw.BorderSide(color: PDF_Border_Color),
                      //             left: pw.BorderSide(color: PDF_Border_Color),
                      //             bottom:
                      //                 pw.BorderSide(color: PDF_Border_Color),
                      //             right: pw.BorderSide(color: PDF_Border_Color),
                      //           ),
                      //         ),
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text(
                      //           'ค่าธรรมเนียม / Fees',
                      //           style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               fontWeight: pw.FontWeight.bold,
                      //               font: ttf,
                      //               color: PdfColors.grey800),
                      //         ),
                      //       ),
                      //     ),
                      //     pw.Expanded(
                      //       flex: 2,
                      //       child: pw.Container(
                      //         decoration: const pw.BoxDecoration(
                      //           color: PdfColors.white,
                      //           border: const pw.Border(
                      //             left: pw.BorderSide(color: PDF_Border_Color),
                      //             top: pw.BorderSide(color: PDF_Border_Color),
                      //             bottom:
                      //                 pw.BorderSide(color: PDF_Border_Color),
                      //             right: pw.BorderSide(color: PDF_Border_Color),
                      //           ),
                      //         ),
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text(
                      //           // '${nFormat.format(double.parse(sum_fee.toString()))}',
                      //           '${nFormat.format(totalFee)}',
                      //           textAlign: pw.TextAlign.right,
                      //           style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               fontWeight: pw.FontWeight.bold,
                      //               font: ttf,
                      //               color: PdfColors.grey800),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // if (afterDiscount != '0.00')
                      //   pw.Row(
                      //     children: [
                      //       pw.Expanded(
                      //         flex: 3,
                      //         child: pw.Container(
                      //           decoration: const pw.BoxDecoration(
                      //             color: PdfColors.white,
                      //             border: const pw.Border(
                      //               top: pw.BorderSide(color: PDF_Border_Color),
                      //               left:
                      //                   pw.BorderSide(color: PDF_Border_Color),
                      //               bottom:
                      //                   pw.BorderSide(color: PDF_Border_Color),
                      //               right:
                      //                   pw.BorderSide(color: PDF_Border_Color),
                      //             ),
                      //           ),
                      //           padding: const pw.EdgeInsets.all(2.0),
                      //           child: pw.Text(
                      //             'หักเงินมัดจำ',
                      //             style: pw.TextStyle(
                      //                 fontSize: font_Size,
                      //                 fontWeight: pw.FontWeight.bold,
                      //                 font: ttf,
                      //                 color: PdfColors.grey800),
                      //           ),
                      //         ),
                      //       ),
                      //       pw.Expanded(
                      //         flex: 2,
                      //         child: pw.Container(
                      //           decoration: const pw.BoxDecoration(
                      //             color: PdfColors.white,
                      //             border: const pw.Border(
                      //               left:
                      //                   pw.BorderSide(color: PDF_Border_Color),
                      //               top: pw.BorderSide(color: PDF_Border_Color),
                      //               bottom:
                      //                   pw.BorderSide(color: PDF_Border_Color),
                      //               right:
                      //                   pw.BorderSide(color: PDF_Border_Color),
                      //             ),
                      //           ),
                      //           padding: const pw.EdgeInsets.all(2.0),
                      //           child: pw.Text(
                      //             // (nFormat.format(double.parse(
                      //             //             dis_sum_Matjum.toString())) !=
                      //             //         '0.00')
                      //             //     ? '${nFormat.format(double.parse(dis_sum_Matjum.toString()) - double.parse(sum_disamt.toString()))}' //dis_sum_Matjum
                      //             //     : (nFormat.format(double.parse(
                      //             //                 dis_sum_Pakan.toString())) !=
                      //             //             '0.00')
                      //             //         ? '${nFormat.format(double.parse(dis_sum_Pakan.toString()) - double.parse(sum_disamt.toString()))}'
                      //             //         : '${nFormat.format(double.parse(net_amount_pvat.toString()) - double.parse(sum_disamt.toString()))}',
                      //             afterDiscount,
                      //             textAlign: pw.TextAlign.right,
                      //             style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               fontWeight: pw.FontWeight.bold,
                      //               font: ttf,
                      //               color: PdfColors.grey800,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // pw.Row(
                      //   children: [
                      //     pw.Expanded(
                      //       flex: 3,
                      //       child: pw.Container(
                      //         decoration: const pw.BoxDecoration(
                      //           color: PdfColors.white,
                      //           border: const pw.Border(
                      //             top: pw.BorderSide(color: PDF_Border_Color),
                      //             left: pw.BorderSide(color: PDF_Border_Color),
                      //             bottom:
                      //                 pw.BorderSide(color: PDF_Border_Color),
                      //             right: pw.BorderSide(color: PDF_Border_Color),
                      //           ),
                      //         ),
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text(
                      //           'ยอดชำระ / Payment Amount',
                      //           style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               fontWeight: pw.FontWeight.bold,
                      //               font: ttf,
                      //               color: PdfColors.grey800),
                      //         ),
                      //       ),
                      //     ),
                      //     pw.Expanded(
                      //       flex: 2,
                      //       child: pw.Container(
                      //         decoration: const pw.BoxDecoration(
                      //           color: PdfColors.white,
                      //           border: const pw.Border(
                      //             left: pw.BorderSide(color: PDF_Border_Color),
                      //             top: pw.BorderSide(color: PDF_Border_Color),
                      //             bottom:
                      //                 pw.BorderSide(color: PDF_Border_Color),
                      //             right: pw.BorderSide(color: PDF_Border_Color),
                      //           ),
                      //         ),
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text(
                      //           '${nFormat.format(totalBill)}',
                      //           // '${nFormat.format((double.parse(Total.toString()) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}',
                      //           // '${nFormat.format(double.parse(Total.toString()) - double.parse(dis_sum_Matjum.toString()) - double.parse(dis_sum_Pakan.toString()))}',
                      //           // (nFormat.format(double.parse(
                      //           //             dis_sum_Matjum
                      //           //                 .toString())) !=
                      //           //         '0.00')
                      //           //     ? '${nFormat.format(double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Matjum.toString()) * 1.07)}'
                      //           //     : (nFormat.format(double.parse(
                      //           //                 dis_sum_Pakan
                      //           //                     .toString())) !=
                      //           //             '0.00')
                      //           //         ? '${nFormat.format(double.parse(dis_sum_Pakan.toString()) + double.parse(dis_sum_Pakan.toString()) * 1.07)}'
                      //           //         : '${nFormat.format((double.parse(sum_Nonvat_choice.toString()) + double.parse(sum_addvat_choice.toString()) - double.parse(sum_disamt.toString())) * 1.07)}',
                      //           textAlign: pw.TextAlign.right,
                      //           style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               fontWeight: pw.FontWeight.bold,
                      //               font: ttf,
                      //               color: PdfColors.grey800),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // pw.SizedBox(height: 2 * PdfPageFormat.mm),
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
                        '(~${convertToThaiBaht(totalBill)}~)',

                        /// "${nFormat2.format(double.parse(Total.toString()))}",
                        ///
                        ///       '(~${convertToThaiBaht(double.parse(Total.toString()) - double.parse(dis_sum_Matjum.toString()))}~)',
                        // '(~${convertToThaiBaht(double.parse(Total.toString()) + double.parse(sum_fee.toString()))}~)',
                        // (nFormat.format(double.parse(
                        //             dis_sum_Matjum.toString())) !=
                        //         '0.00')
                        //     ? '(~${convertToThaiBaht(double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Matjum.toString()) * 1.07)}~)'
                        //     : (nFormat.format(double.parse(
                        //                 dis_sum_Pakan.toString())) !=
                        //             '0.00')
                        //         ? '(~${convertToThaiBaht(double.parse(dis_sum_Pakan.toString()) + double.parse(dis_sum_Pakan.toString()) * 1.07)}~)'
                        //         : '(~${convertToThaiBaht((double.parse(sum_Nonvat_choice.toString()) + double.parse(sum_addvat_choice.toString()) - double.parse(sum_disamt.toString())) * 1.07)}~)',
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
                                // '${nFormat.format(double.parse(Total.toString()) + double.parse(sum_fee.toString()))}',
                                '${nFormat.format(totalBill)}',
                                // (nFormat.format(double.parse(
                                //             dis_sum_Matjum
                                //                 .toString())) !=
                                //         '0.00')
                                //     ? '${nFormat.format(double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Matjum.toString()) * 1.07)}'
                                //     : (nFormat.format(double.parse(
                                //                 dis_sum_Pakan
                                //                     .toString())) !=
                                //             '0.00')
                                //         ? '${nFormat.format(double.parse(dis_sum_Pakan.toString()) + double.parse(dis_sum_Pakan.toString()) * 1.07)}'
                                //         : '${nFormat.format((double.parse(sum_Nonvat_choice.toString()) + double.parse(sum_addvat_choice.toString()) - double.parse(sum_disamt.toString())) * 1.07)}',
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
        ],
      );
    }

    // for (int page = 0;
    //     page < (TransReBillHistory.length / 100).ceil();
    //     page++) { TA68-07-004620
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme, // ✅ BG อยู่ที่นี่
        maxPages: 50,
        // header: (ctx) => Header(ctx),
        header: (ctx) {
          return pw.Column(
            children: [
              Header(ctx),
              // ✅ ส่วนหัว: ถ้าต้องให้อยู่หน้าเดียว และ “ขนาดไม่เกินหน้า”
              // pw.KeepTogether(headerBlock(font_Size, ttf, Colors_pd)),
              pw.Padding(
                padding: pw.EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: headerBlock(font_Size, ttf, Colors_pd),
              ),

              // // ✅ หัวตาราง
              pw.Padding(
                padding: pw.EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: tableHeader(font_Size, ttf),
              ),
              // ✅ รายการแตกหน้าได้เอง
            ],
          );
        },
        build: (ctx) => [
          pw.Padding(
            padding: pw.EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: pw.ListView.builder(
              itemCount: TransReBillHistory.length,
              itemBuilder: (c, i) => itemRow(
                TransReBillHistory,
                i,
                font_Size,
                ttf,
              ),
            ),
          ),

          // ✅ บล็อคสรุปด้านล่าง แนะนำ KeepTogether (แต่ต้องไม่ใหญ่เกินหน้า)
          pw.Padding(
            padding: pw.EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: tablefool(font_Size, ttf),
          ),
          // pw.KeepTogether(
          //   totalsBlock(
          //       /* ใช้กลุ่ม pw.Row/pw.Container ของคุณด้านล่างนี้ได้เลย แต่เลิก fix height */),
          // ),

          // ช่องว่างเล็ก ๆ ปิดท้ายถ้าจำเป็น
          pw.SizedBox(height: 5 * PdfPageFormat.mm),
        ],
        footer: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: pw.Stack(children: [
                  pw.Positioned(
                      top: 4,
                      left: 0,
                      child: pw.Container(
                        width: 300,
                        height: 300,
                        decoration: pw.BoxDecoration(
                          image: pw.DecorationImage(
                            image: pw.MemoryImage(
                              imageBG,
                            ),
                            fit: pw.BoxFit.cover,
                          ),
                          // border:
                          //     pw.Border.all(color: PdfColors.grey, width: 1),
                        ),
                      )),
                  pw.Positioned(
                      bottom: 4,
                      right: 0,
                      child: pw.Container(
                        width: 200,
                        height: 30,
                        decoration: pw.BoxDecoration(
                          image: pw.DecorationImage(
                            image: pw.MemoryImage(
                              imageBG,
                            ),
                            fit: pw.BoxFit.cover,
                          ),
                          // border:
                          //     pw.Border.all(color: PdfColors.grey, width: 1),
                        ),
                      )),
                  pw.Container(
                      decoration: pw.BoxDecoration(
                        border:
                            pw.Border.all(color: PDF_Border_Color, width: 1),
                      ),
                      padding: pw.EdgeInsets.fromLTRB(2, 4, 2, 4),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                              flex: 2,
                              child: pw.Column(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
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
                                          ? '      บัญชี ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.bank).join(', ')} เลขที่ ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.bno).join(', ')} [ ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => (model.ptname.toString() == 'Online Payment' ? 'PromptPay QR' : model.ptname == 'เงินโอน' ? 'เลขบัญชี' : model.ptname == 'Beam Checkout' ? 'Beam Checkout' : model.ptname == 'Online Standard QR' ? 'Online Standard QR' : '${model.ptname}')).join(', ')} ]'
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
                                  // crossAxisAlignment: pw.CrossAxisAlignment.center,
                                  children: [
                                    pw.Container(
                                      width: 200,
                                      // decoration: const pw.BoxDecoration(
                                      //   // color: PdfColors.green100,
                                      //   border: pw.Border(
                                      //     bottom: pw.BorderSide(
                                      //         width: 0.5, color: PdfColors.grey600),
                                      //   ),
                                      // ),
                                      padding: const pw.EdgeInsets.fromLTRB(
                                          4, 0, 4, 0),
                                      child: pw.Row(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.end,
                                        // mainAxisAlignment:
                                        //     pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Expanded(
                                            flex: 1,
                                            child: pw.Text(
                                              'ลงชื่อ : ',
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
                                            flex: 2,
                                            child: (imageBytes_manager.isEmpty)
                                                ? pw.Container(
                                                    // width: 120,
                                                    decoration:
                                                        const pw.BoxDecoration(
                                                      // color: PdfColors.green100,
                                                      border: pw.Border(
                                                        bottom: pw.BorderSide(
                                                            width: 0.5,
                                                            color: PdfColors
                                                                .grey600),
                                                      ),
                                                    ),
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            8.0),
                                                    height: 30,
                                                  )
                                                : pw.Container(
                                                    // width: 120,
                                                    decoration:
                                                        const pw.BoxDecoration(
                                                      // color: PdfColors.green100,
                                                      border: pw.Border(
                                                        bottom: pw.BorderSide(
                                                            width: 0.5,
                                                            color: PdfColors
                                                                .grey600),
                                                      ),
                                                    ),
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            8.0),
                                                    child: pw.Center(
                                                      child: pw.Image(
                                                        pw.MemoryImage(
                                                            imageBytes_manager),
                                                        height: 20,
                                                        width: 100,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          pw.Expanded(
                                            flex: 2,
                                            child: pw.Text(
                                              ' เจ้าหน้าที่/พนักงาน',
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
                                      ),
                                    ),
                                    pw.SizedBox(
                                      height: 3,
                                    ),
                                    pw.Container(
                                      width: 200,
                                      // decoration: const pw.BoxDecoration(
                                      //   // color: PdfColors.green100,
                                      //   border: pw.Border(
                                      //     bottom: pw.BorderSide(
                                      //         width: 0.5, color: PdfColors.grey600),
                                      //   ),
                                      // ),
                                      padding: const pw.EdgeInsets.fromLTRB(
                                          4, 0, 4, 0),
                                      child: pw.Row(
                                        // mainAxisAlignment:
                                        //     pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Expanded(
                                            flex: 1,
                                            child: pw.Text(
                                              'คุณ : ',
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
                                            flex: 2,
                                            child: pw.Align(
                                              alignment: pw.Alignment.center,
                                              child: pw.Text(
                                                '(${licence_name1})',
                                                textAlign: pw.TextAlign.left,
                                                style: pw.TextStyle(
                                                  fontSize: font_Size,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: Colors_pd,
                                                ),
                                              ),
                                            ),
                                          ),
                                          pw.Expanded(
                                            flex: 2,
                                            child: pw.Text(
                                              '',
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
                                      ),
                                    ),
                                  ])),
                        ],
                      )),
                ]),
              ),
              pw.Stack(
                children: [
                  pw.Container(
                      width: PdfPageFormat.a4.width,
                      height: 55,
                      child: pw.Center(
                        child: pw.Container(
                            width: widths,
                            height: 25,
                            child: pw.Column(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Row(children: [
                                    pw.Expanded(
                                        child: pw.Container(
                                      color: PdfColors.red,
                                      height: 5,
                                    ))
                                  ]),
                                  pw.Row(children: [
                                    pw.Expanded(
                                        child: pw.Container(
                                      color: PdfColors.green900,
                                      height: 8,
                                    ))
                                  ]),
                                  pw.Row(children: [
                                    pw.Expanded(
                                        child: pw.Container(
                                      color: PdfColors.red,
                                      height: 5,
                                    ))
                                  ]),
                                ])),
                      )),
                  pw.Positioned(
                      top: 4,
                      right: 50,
                      child: pw.Container(
                          width: 50.0,
                          height: 50.0,
                          child: pw.Image(pw.MemoryImage(imageData)))),
                  pw.Positioned(
                    top: 4,
                    left: 40,
                    child: pw.Text(
                      "CHOICE MINI STORE CO., LTD. 7/11 VILLAGE NO.5, THA SALA SUB-DISTRICT, MUEANG CHIANG MAI DISTRICT, CHIANG MAI PROVINANCE 50000",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        color: Colors_pd, fontSize: 8.00,
                        // fontSize: font_Size - 4,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                      ),
                    ),
                  ),
                  pw.Positioned(
                    bottom: 4,
                    right: 120,
                    child: pw.Text(
                      "Sub Area Licencee: Chiang Mai, Lamphun, Mae-Hong-Son",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: Colors_pd,
                        fontSize: 8.00,
                        // fontSize: font_Size - 4,
                        font: ttf,
                      ),
                    ),
                  ),
                  pw.Positioned(
                    bottom: 4,
                    left: 40,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.fromLTRB(0, 2, 0, 0),
                          child: pw.Align(
                            alignment: pw.Alignment.bottomLeft,
                            child: pw.Text(
                              'ครั้งที่ : ${paper_run} พิมพ์เมื่อ : $date ',
                              // textAlign: pw.TextAlign.left,
                              style: pw.TextStyle(
                                fontSize: 8.00,
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
                              ' ( หน้าที่ ${context.pageNumber} / ${context.pagesCount} ) ',
                              // textAlign: pw.TextAlign.left,
                              style: pw.TextStyle(
                                fontSize: 8.00,
                                font: ttf,
                                color: Colors_pd,
                                // fontWeight: pw.FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewPdfgen_Billsplay(
                doc: pdf,
                title: (TitleType_Default_Receipt_Name == null)
                    ? (numdoctax.toString() == '')
                        ? 'ใบเสร็จรับเงิน_$numinvoice'
                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี_$numdoctax'
                    : (numdoctax.toString() == '')
                        ? 'ใบเสร็จรับเงิน_[$TitleType_Default_Receipt_Name]$numinvoice'
                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี_[$TitleType_Default_Receipt_Name]$numdoctax'),
          ));
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
                doc: pdf,
                title: (TitleType_Default_Receipt_Name == null)
                    ? (numdoctax.toString() == '')
                        ? 'ใบเสร็จรับเงิน_$numinvoice'
                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี_$numdoctax'
                    : (numdoctax.toString() == '')
                        ? 'ใบเสร็จรับเงิน_[$TitleType_Default_Receipt_Name]$numinvoice'
                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี_[$TitleType_Default_Receipt_Name]$numdoctax'),
          ));
    }
  }
}
