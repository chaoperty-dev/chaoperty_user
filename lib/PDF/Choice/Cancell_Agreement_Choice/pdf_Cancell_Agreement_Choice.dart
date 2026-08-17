
import 'package:chaoperty_user/PDF/ThaiBaht.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../Man_PDF/Preview_PDF/PreviewPdfgen_Billsplay.dart';

class Pdfgen_Cancell_Agreement_Choice {
  static void exportPDF_Cancell_Agreement_Choice(
      context,
      foder,
      rentalName,
      billAddr,
      billEmail,
      billTel,
      billTax,
      billName,
      tenantNameshop,
      tenantTypeshop,
      tenantBussshop,
      tenantBussscontact,
      tenantAddress,
      tenantTel,
      tenantEmail,
      tenantRentalCount,
      tenantArea,
      tenantLn,
      tenantSdate,
      tenantLdate,
      tenantPeriod,
      tenantRtname,
      tenantDocno,
      tenantZn,
      tenantAser,
      tenantQty,
      tenantCdate,
      tenantTax,
      tenantCtype,
      tenantCustno,
      tenantCiddoc,
      tenantQutser,
      tenantVerticalgroupvalue,
      tenantSname,
      tenantRoomNumber,
      newValuePDFimg,
      formbecauseCancel,
      quotxSelectModels,
      transKonModels,
      titletypeDefaultReceiptName,
      cc_date,
      w1_date,
      formExpserpakan,
      formPakanallPvat,
      fontsPdf,
      ucancel,
      datex_cc_date,
      cc_date_remark,
      [Map<String, dynamic>? refundPayload]) async {
    final pdf = pw.Document();
    final font = await rootBundle.load('fonts/THSarabunNew.ttf');
    final fontBold = await rootBundle.load('fonts/SarabunBold.ttf');
    var colorsPd = PdfColors.black;
    final ttf = pw.Font.ttf(font);
    final ttfBold = pw.Font.ttf(fontBold);
    double fontSize = 13.0;

    // final bool isServiceDeposit = (Form_expserPakan?.toString() == '25');
    // final numberFormat = NumberFormat('#,##0.00');
    // final double pakanAmountValue = double.tryParse((Form_PakanAll_pvat ?? '0')
    //         .toString()
    //         .trim()
    //         .replaceAll(',', '')) ??
    //     0.00;
    // final bool hasDepositAmount = pakanAmountValue > 0;
    // final String pakanAmount =
    //     hasDepositAmount ? numberFormat.format(pakanAmountValue) : '';

    // final String depositRentAmountText =
    //     checkDepositRent ? pakanAmount : '0.00';
    // final String depositServiceAmountText =
    //     checkDepositService ? pakanAmount : '0.00';
    // final String depositTotalAmountText =
    //     hasDepositAmount ? pakanAmount : '0.00';
    // final String depositThaiBahtText =
    //     hasDepositAmount ? convertToThaiBaht(pakanAmountValue) : '';

    final numberFormat = NumberFormat('#,##0.00');

    double _parseAmount(dynamic raw) {
      if (raw == null) return 0.0;
      final cleaned = raw.toString().trim().replaceAll(',', '');
      return double.tryParse(cleaned) ?? 0.0;
    }

    bool _parseBool01(dynamic raw) {
      if (raw == null) return false;
      final s = raw.toString().trim();
      return s == '1' || s.toLowerCase() == 'true';
    }

// 1. ประกาศตัวแปรรับยอดเงิน (ต้องอยู่ก่อน Loop)
    double depositRentAmountValue = 0.0;
    double depositServiceAmountValue = 0.0;

// 2. ลูปหาค่าจาก quotxSelectModels (แบบ Object)
    if (quotxSelectModels != null && quotxSelectModels.isNotEmpty) {
      for (var item in quotxSelectModels) {
        final String expser = item.expser?.toString() ?? '';

        final String pvatString =
            item.pvat?.toString().trim().replaceAll(',', '') ?? '0';
        final double pvatValue = double.tryParse(pvatString) ?? 0.0;

        if (expser == '2') {
          depositRentAmountValue += pvatValue;
        } else if (expser == '25') {
          depositServiceAmountValue += pvatValue;
        }
      }
    }

    // Override from dialog payload (if provided)
    bool checkDepositRentOverride = false;
    bool checkDepositServiceOverride = false;
    String? depositThaiBahtTextOverride;
    if (refundPayload != null) {
      checkDepositRentOverride = _parseBool01(refundPayload['is_dep_rental']);
      checkDepositServiceOverride =
          _parseBool01(refundPayload['is_dep_service']);

      final depRentalAmt = _parseAmount(refundPayload['dep_rental_amt']);
      final depServiceAmt = _parseAmount(refundPayload['dep_service_amt']);

      depositRentAmountValue = checkDepositRentOverride ? depRentalAmt : 0.0;
      depositServiceAmountValue =
          checkDepositServiceOverride ? depServiceAmt : 0.0;
      final totalAmt = _parseAmount(refundPayload['total_dep_amt']);
      final totalText = refundPayload['total_dep_text']?.toString() ?? '';
      depositThaiBahtTextOverride =
          totalText.trim().isNotEmpty ? totalText.trim() : null;

      // if dialog didn't send total, compute from components
      if (totalAmt > 0) {
        depositThaiBahtTextOverride ??= convertToThaiBaht(totalAmt);
      }
    }

// 3. คำนวณยอดรวมและสถานะ Checkbox
    final double totalDepositAmountValue =
        depositRentAmountValue + depositServiceAmountValue;
    final bool hasDepositAmount = totalDepositAmountValue > 0;

    final bool checkDepositRent = refundPayload != null
        ? checkDepositRentOverride
        : depositRentAmountValue > 0;
    final bool checkDepositService = refundPayload != null
        ? checkDepositServiceOverride
        : depositServiceAmountValue > 0;

// 4. จัด Format สำหรับแสดงใน PDF
    final String depositRentAmountText =
        numberFormat.format(depositRentAmountValue);
    final String depositServiceAmountText =
        numberFormat.format(depositServiceAmountValue);
    final String depositTotalAmountText =
        numberFormat.format(totalDepositAmountValue);
    final String depositThaiBahtText = hasDepositAmount
        ? (refundPayload != null && depositThaiBahtTextOverride != null
            ? depositThaiBahtTextOverride
            : convertToThaiBaht(totalDepositAmountValue))
        : '';

    final logoImage = await rootBundle.load('images/choice_logo2.png');
    final logoData = logoImage.buffer.asUint8List();
    final resizedLogo = logoData; // Defined resizedLogo
    var colorsPd3 = PdfColors.black; // Defined Colors_pd3
    final iconImage =
        (await rootBundle.load('images/LOGO.png')).buffer.asUint8List();
    final ByteData image = await rootBundle.load('images/image7-11.png');
    final ByteData bgPdf = await rootBundle.load('images/Choice_BG_PDF.png');
    final ByteData lgPdf = await rootBundle.load('images/choice_logo2.png');
    Uint8List imageData = (image).buffer.asUint8List();
    Uint8List imageBG = (bgPdf).buffer.asUint8List();
    Uint8List imageLG = (lgPdf).buffer.asUint8List();
    int cbCount = 0;
    DateTime now = DateTime.now();
    String dateNowStr =
        '${now.day} ${DateFormat('MMMM', 'th').format(now)} ${now.year + 543}';

    String strCcDate = '-';
    String strCcxdate = '-';

    DateTime? parseDateRobust(String? dateStr) {
      if (dateStr == null ||
          dateStr.trim() == '0000-00-00' ||
          dateStr.trim() == '-' ||
          dateStr.trim().isEmpty) return null;
      dateStr = dateStr.trim();
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        try {
          return DateFormat('dd-MM-yyyy').parse(dateStr);
        } catch (e2) {
          try {
            return DateFormat('dd/MM/yyyy').parse(dateStr);
          } catch (e3) {
            return null;
          }
        }
      }
    }

    final parsedCcDate = parseDateRobust(cc_date?.toString());
    if (parsedCcDate != null) {
      strCcDate =
          '${parsedCcDate.day} ${DateFormat('MMMM', 'th').format(parsedCcDate)} ${parsedCcDate.year + 543}';
    }

    final parsedCcxdate = parseDateRobust(datex_cc_date?.toString());
    if (parsedCcxdate != null) {
      strCcxdate =
          '${parsedCcxdate.day} ${DateFormat('MMMM', 'th').format(parsedCcxdate)} ${parsedCcxdate.year + 543}';
    }
    double widths = PdfPageFormat.a4.width;

    // Calculate total Term from quotxSelectModels

    // double totalDep = 0;
    // double serviceDep = 0;

    // for(var m in transKonModels){
    //    // Logic to separate rental and service deposit if possible
    //    // Assuming structure based on image
    // }
    pw.Widget Textx({
      required String value,
      required pw.Font font,
      double fontSize = 12.5,
      pw.TextAlign align = pw.TextAlign.left,
      pw.FontWeight fontWeight = pw.FontWeight.bold,
      PdfColor? color,
      pw.TextDecoration? decoration,
    }) {
      return pw.Text(
        value,
        textAlign: align,
        style: pw.TextStyle(
          font: font,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color ?? PdfColors.black,
          decoration: decoration,
        ),
      );
    }

    pw.Widget labeledLine({
      required String value,
      required pw.Font font,
      double fontSize = 12.5,
      required int flex,
      PdfColor? color,
    }) {
      var colorsPd = PdfColors.black;

      return pw.Expanded(
          flex: flex,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: colorsPd,
                  width: 0.3,
                ),
              ),
            ),
            // padding: const pw.EdgeInsets.only(bottom: -5, top: -5),
            // margin: const pw.EdgeInsets.only(bottom: 5, top: 5),
            //  padding: const pw.EdgeInsets.only(bottom: -3.5),
            child: Textx(
              value: ' ' * 2 + value + ' ' * 2,
              align: pw.TextAlign.center,
              font: font,
              fontSize: fontSize,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ));
    }

    pw.Widget boxX(bool checked) {
      return pw.Container(
        width: 12,
        height: 12,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(
            color: PdfColors.black,
            width: 1,
          ),
        ),
        child: checked
            ? pw.Center(
                child: pw.Text(
                  '/',
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 10,
                  ),
                ),
              )
            : null,
      );
    }

    //   pw.Widget boxX(bool checked) {
    //   return pw.Checkbox(
    //     name: 'cb_${++cbCount}',
    //     value: checked,
    //     width: 12,
    //     height: 12,
    //     checkColor: PdfColors.black,
    //     activeColor: PdfColors.white,
    //   );
    // }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 4.00,
            marginLeft: 8.00,
            marginRight: 8.00,
            marginTop: 8.00,
          ),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Opacity(
              opacity: 0.5,
              child: pw.Image(
                pw.MemoryImage(imageBG),
                fit: pw.BoxFit.cover,
              ),
            ),
          ),
        ),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // pw.Container(
              //   decoration: pw.BoxDecoration(
              //     border: pw.Border.all(
              //       color: PdfColors.black,
              //       width: 0.5,
              //     ),
              //   ),
              //   padding: pw.EdgeInsets.all(5),
              //   child: pw.Column(
              //     children: [

              //     ]
              //   )
              // ),
              pw.Container(
                width: PdfPageFormat.a4.width + 100,
                color: PdfColors.green900,
                height: 13,
              ),
              pw.SizedBox(height: 1 * PdfPageFormat.mm),
              pw.Row(
                children: [
                  pw.Container(
                    width: 30,
                    height: 10,
                  ),
                  pw.Container(
                    height: 60,
                    width: 70,
                    child: pw.Image(
                      pw.MemoryImage(resizedLogo),
                      height: 60,
                      width: 70,
                    ),
                  ),
                  pw.SizedBox(width: 1 * PdfPageFormat.mm),
                  pw.Container(
                    width: 350,
                    child: pw.Column(
                      mainAxisSize: pw.MainAxisSize.min,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        Textx(
                          value: billName.toString().trim(),
                          font: ttf,
                        ), //   maxLines: 2,
                        Textx(
                            value: billAddr.toString().trim(),
                            font: ttf), //   maxLines: 3,
                        Textx(
                            value: 'เลขประจำตัวผู้เสียภาษี : $billTax',
                            font: ttf), //   maxLines: 2,
                      ],
                    ),
                  ),
                  pw.Spacer(),
                  if (titletypeDefaultReceiptName != null &&
                      titletypeDefaultReceiptName.toString().trim() != '' &&
                      titletypeDefaultReceiptName.toString().trim() !=
                          'ไม่ระบุ')
                    pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: pw.Container(
                        width: 80,
                        decoration: pw.BoxDecoration(
                          // color: PdfColors.grey400,
                          borderRadius: const pw.BorderRadius.only(
                              topLeft: pw.Radius.circular(10),
                              topRight: pw.Radius.circular(10),
                              bottomLeft: pw.Radius.circular(10),
                              bottomRight: pw.Radius.circular(10)),
                          border: pw.Border.all(color: colorsPd3, width: 1),
                        ),
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Center(
                          child: Textx(
                            value: '$titletypeDefaultReceiptName',
                            // maxLines: 1, // Textx doesn't support maxLines yet, but existing code had it
                            fontSize: 20,
                            font: ttf,
                            color: colorsPd3,
                          ),
                        ),
                      ),
                    ),
                  if (titletypeDefaultReceiptName != null &&
                      titletypeDefaultReceiptName.toString().trim() != '' &&
                      titletypeDefaultReceiptName.toString().trim() !=
                          'ไม่ระบุ')
                    pw.Spacer(),
                ],
              ),
              pw.Center(
                child: Textx(
                    value: 'แบบฟอร์มยกเลิกสัญญา',
                    font: ttf, //  ttf, // ttfBold,,
                    fontSize: fontSize),
              ),
              pw.SizedBox(height: 10),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                Textx(value: 'วันที่แจ้ง ', font: ttf, fontSize: fontSize),
                pw.Container(
                  width: 100,
                  child: labeledLine(
                      value: strCcxdate,
                      font: ttf,
                      flex: 1), // cc_date ตอนที่กดบันทึก
                ),
                pw.Container(width: 50)
              ]),
              pw.SizedBox(height: 5),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                Textx(
                    value: 'เรื่อง     ยกเลิกสัญญา   วันที่ยกเลิกสัญญา',
                    font: ttf, // ttfBold,,
                    fontSize: fontSize),
                pw.SizedBox(width: 14),
                pw.Container(
                  width: 100,
                  child: labeledLine(
                      value: strCcDate,
                      font: ttf,
                      flex: 1), // cc_datex กำหนดล่วงหน้า
                ),
              ]),
              // pw.SizedBox(height: 5),
              // pw.Divider(thickness: 2),
            ],
          );
        },
        build: (pw.Context context) => [
          // --- Body ---
          pw.SizedBox(height: 15),
          pw.Row(children: [
            Textx(value: 'ชื่อผู้เช่า    ', font: ttf, fontSize: fontSize),
            labeledLine(
              flex: 1,
              value: '${tenantBussscontact ?? "-"}',
              font: ttf, // ttfBold,,
              fontSize: fontSize,
            ),
            Textx(
                value: 'จำหน่ายสินค้า/ธุรกิจ  ', font: ttf, fontSize: fontSize),
            labeledLine(
              flex: 1,
              value: '${tenantTypeshop ?? "-"}',
              font: ttf, // ttfBold,,
              fontSize: fontSize,
            ),
            Textx(value: '   เลขที่สัญญา   ', font: ttf, fontSize: fontSize),
            labeledLine(
              flex: 1,
              value: '${tenantCiddoc ?? "-"}',
              font: ttf, // ttfBold,,
              fontSize: fontSize,
            ),
          ]),
          pw.SizedBox(height: 5),
          pw.Row(children: [
            Textx(value: 'ประเภทการเช่า    ', font: ttf, fontSize: fontSize),
            boxX(refundPayload != null
                ? _parseBool01(refundPayload['is_type_storefront'])
                : tenantTypeshop == 'พื้นที่หน้าร้าน'),
            Textx(value: ' พื้นที่หน้าร้าน    ', font: ttf, fontSize: fontSize),
            boxX(refundPayload != null
                ? _parseBool01(refundPayload['is_type_outside_eaves'])
                : tenantTypeshop == 'พื้นที่นอกชายคา'),
            Textx(value: ' พื้นที่นอกชายคา    ', font: ttf, fontSize: fontSize),
            boxX(refundPayload != null
                ? _parseBool01(refundPayload['is_type_room'])
                : tenantTypeshop == 'ห้องเช่า'),
            Textx(value: ' ห้องเช่า    ', font: ttf, fontSize: fontSize),
            boxX(refundPayload != null
                ? _parseBool01(refundPayload['is_type_vending'])
                : tenantTypeshop == 'เครื่องไข่หยอดเหรียญ'),
            Textx(
                value: ' เครื่องไข่หยอดเหรียญ    ',
                font: ttf,
                fontSize: fontSize),
            boxX(refundPayload != null
                ? _parseBool01(refundPayload['is_type_scale'])
                : tenantTypeshop == 'เครื่องชั่งน้ำหนัก'),
            Textx(
                value: ' เครื่องชั่งน้ำหนัก    ',
                font: ttf,
                fontSize: fontSize),
            boxX(refundPayload != null
                ? (refundPayload['type_other_detail']
                        ?.toString()
                        .trim()
                        .isNotEmpty ??
                    false)
                : false),
            Textx(value: ' อื่นๆ', font: ttf, fontSize: fontSize),
            labeledLine(
              value: refundPayload != null
                  ? (refundPayload['type_other_detail']
                              ?.toString()
                              .trim()
                              .isNotEmpty ??
                          false)
                      ? refundPayload['type_other_detail'].toString().trim()
                      : '-'
                  : '-',
              font: ttf,
              flex: 1,
              color: refundPayload != null
                  ? (refundPayload['type_other_detail']
                              ?.toString()
                              .trim()
                              .isNotEmpty ??
                          false)
                      ? PdfColors.black // ✅ มีข้อมูล = สีดำ
                      : PdfColors.white // ✅ ไม่มีข้อมูล = สีขาว
                  : PdfColors.white, // ✅ null = ไม่มีข้อมูล
            ),
          ]),
          pw.SizedBox(height: 5),
          pw.Row(children: [
            Textx(
                value: 'สถานที่เช่าร้านเซเว่น-อีเลฟเว่น สาขา   ',
                font: ttf,
                fontSize: fontSize),
            labeledLine(
              flex: 1,
              value: '${tenantZn ?? "-"}',
              font: ttf, // ttfBold,,
              fontSize: fontSize,
            ),
          ]),
          pw.SizedBox(height: 5),
          pw.Row(children: [
            pw.SizedBox(width: 50),
            Textx(value: 'ล็อคที่   ', font: ttf, fontSize: fontSize),
            pw.Container(
              width: 100,
              child: labeledLine(
                flex: 1,
                value: '${tenantLn ?? "-"}',
                font: ttf, // ttfBold,,
                fontSize: fontSize,
              ),
            ),
            Textx(value: '   เนื้อที่   ', font: ttf, fontSize: fontSize),
            pw.Container(
              width: 100,
              child: labeledLine(
                flex: 1,
                value: '${tenantArea ?? "-"}',
                font: ttf, // ttfBold,,
                fontSize: fontSize,
              ),
            ),
            Textx(value: '   ตร.ม.', font: ttf, fontSize: fontSize),
          ]),
          pw.SizedBox(height: 5),
          pw.Row(children: [
            pw.SizedBox(width: 50),
            Textx(value: 'อาคารเลขที่   ', font: ttf, fontSize: fontSize),
            labeledLine(
              flex: 1,
              value: '${tenantRoomNumber ?? "-"}',
              font: ttf, // ttfBold,,
              fontSize: fontSize,
            ),
          ]),
          pw.SizedBox(height: 10),
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            Textx(
                value: 'สาเหตุการยกเลิก    ',
                font: ttf, // ttfBold,,
                fontSize: fontSize),
            labeledLine(
              flex: 1,
              value:
                  '${(cc_date_remark ?? "-").replaceAll(RegExp(r'\[.*?\]'), '')}',
              font: ttf, // ttfBold,,
              fontSize: fontSize,
            ),
          ]),

          // --- Deposit Details ---
          pw.SizedBox(height: 15),
          pw.Center(
              child: Textx(
                  value: 'รายละเอียดเงินประกัน',
                  font: ttf, // ttfBold,,
                  fontSize: fontSize,
                  decoration: pw.TextDecoration.underline)),
          pw.SizedBox(height: 5),

          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Expanded(child: pw.SizedBox()),
            pw.Container(
              width: 320,
              child: pw.Table(
                  border: pw.TableBorder.all(
                      color: PdfColors.black,
                      width: 1,
                      style: pw.BorderStyle.solid),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Center(
                            child: Textx(
                                value: 'รายการ',
                                font: ttf,
                                fontSize: fontSize)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Center(
                            child: Textx(
                                value: 'จำนวนเงิน (ไม่รวมภาษี)',
                                font: ttf,
                                fontSize: fontSize)),
                      ),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(
                              left: 5, top: 4, bottom: 4),
                          child: pw.Row(children: [
                            // pw.Checkbox(
                            //     height: 12,
                            //     checkColor: PdfColors.grey,
                            //     activeColor: PdfColors.white,
                            //     name: 'd1',
                            //     value: checkDepositRent),
                            boxX(checkDepositRent),
                            Textx(
                                value: ' เงินประกันการเช่า',
                                font: ttf,
                                fontSize: fontSize)
                          ])),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 4, bottom: 4),
                          child: pw.Center(
                              child: Textx(
                                  value: depositRentAmountText,
                                  align: pw.TextAlign.center,
                                  font: ttf,
                                  fontSize: fontSize)))
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(
                              left: 5, top: 4, bottom: 4),
                          child: pw.Row(children: [
                            // pw.Checkbox(
                            //     height: 12,
                            //     checkColor: PdfColors.grey,
                            //     activeColor: PdfColors.white,
                            //     name: 'd2',
                            //     value: checkDepositService),
                            boxX(checkDepositService),
                            Textx(
                                value: ' เงินประกันการบริการ',
                                font: ttf,
                                fontSize: fontSize)
                          ])),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 4, bottom: 4),
                          child: pw.Center(
                              child: Textx(
                                  value: depositServiceAmountText,
                                  align: pw.TextAlign.center,
                                  font: ttf,
                                  fontSize: fontSize)))
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Center(
                            child: Textx(
                                value: 'รวมเงินประกันทั้งสิ้น',
                                font: ttf,
                                fontSize: fontSize)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Center(
                            child: Textx(
                                value: depositTotalAmountText,
                                align: pw.TextAlign.center,
                                font: ttf,
                                fontSize: fontSize)),
                      ),
                    ]),
                  ]),
            ),
            // thaibaht
            pw.Expanded(
                child: pw.Padding(
              padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
              child: pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: Textx(
                  value: depositThaiBahtText,
                  font: ttf,
                  fontSize: fontSize,
                ),
              ),
            )),
          ]),

          // --- Refund Options ---
          pw.SizedBox(height: 15),
          Textx(
              value: 'ขอให้ทางบริษัทฯ คืนเงินประกันการเช่า โดย',
              font: ttf, // ttfBold,,
              fontSize: fontSize),
          pw.SizedBox(height: 5),
          pw.Row(children: [
            // pw.Checkbox(
            //     height: 12,
            //     checkColor: PdfColors.grey,
            //     activeColor: PdfColors.white,
            //     name: 'r1',
            //     value: true),
            boxX(refundPayload != null
                ? _parseBool01(refundPayload['refund_cond_full'])
                : true),
            pw.Expanded(
                child: Textx(
                    value:
                        ' คืนเงินประกันการเช่า (กรณีผู้เช่าไม่มีค่าใช้จ่ายค้างชำระ และทำการแจ้งยกเลิกกล่าวหน้า 60 วัน)',
                    font: ttf,
                    fontSize: fontSize)),
          ]),
          pw.Row(children: [
            // pw.Checkbox(
            //     height: 12,
            //     checkColor: PdfColors.grey,
            //     activeColor: PdfColors.white,
            //     name: 'r2',
            //     value: false),
            boxX(refundPayload != null
                ? _parseBool01(refundPayload['refund_cond_deduct'])
                : false),
            pw.Expanded(
                child: Textx(
                    value:
                        " เงินประกันหักค่าใช้จ่ายคงค้างชำระต่างๆ ทั้งหมด (ส่วนที่เหลือคืนให้กับผู้เช่า / ผู้เช่าชำระเงินส่วนเพิ่ม กรณีเงินประกัน)",
                    font: ttf,
                    fontSize: fontSize)),
          ]),
          pw.Row(children: [
            // pw.Checkbox(
            //     height: 12,
            //     checkColor: PdfColors.grey,
            //     activeColor: PdfColors.white,
            //     name: 'r3',
            //     value: false),
            boxX(refundPayload != null
                ? _parseBool01(refundPayload['refund_cond_none'])
                : false),
            Textx(
                value: ' ไม่คืนเงินประกัน (กรณีผิดสัญญาเช่า)',
                font: ttf,
                fontSize: fontSize),
          ]),
          pw.Padding(
              padding: const pw.EdgeInsets.only(left: 30),
              child: pw.Row(children: [
                // pw.Checkbox(
                //     height: 12,
                //     checkColor: PdfColors.grey,
                //     activeColor: PdfColors.white,
                //     name: 'r3_1',
                //     value: false),
                boxX(refundPayload != null
                    ? _parseBool01(refundPayload['reason_short_notice'])
                    : false),
                pw.Expanded(
                    child: Textx(
                        value:
                            ' เนื่องจาก ผู้เช่าไม่ได้ทำการแจ้งยกเลิกสัญญาล่วงหน้า 60 วัน (ตามเงื่อนไขสัญญา)',
                        font: ttf,
                        fontSize: fontSize)),
              ])),
          pw.Padding(
              padding: const pw.EdgeInsets.only(left: 30),
              child: pw.Row(children: [
                // pw.Checkbox(
                //     checkColor: PdfColors.grey,
                //     activeColor: PdfColors.white,
                //     height: 12,
                //     name: 'r3_2',
                //     value: false),
                boxX(refundPayload != null
                    ? _parseBool01(refundPayload['reason_late_payment'])
                    : false),
                pw.Expanded(
                    child: Textx(
                        value:
                            ' เนื่องจาก ผู้เช่าชำระค่าเช่าเกินกำหนด (ตามเงื่อนไขสัญญา)',
                        font: ttf,
                        fontSize: fontSize)),
              ])),
          // pw.Row(children: [
          //   // pw.Checkbox(
          //   //     activeColor: PdfColors.grey, // Color when checked
          //   //     checkColor: PdfColors.white, // Color of the check icon
          //   //     height: 12,
          //   //     name: 'r3_3',
          //   //     value: false),
          //   boxX(false),
          //   Textx(value: ' อื่นๆ ', font: ttf, fontSize: font_Size),
          //   pw.Container(
          //     width: 350,
          //     child: labeledLine(
          //       flex: 1,
          //       value: '${Formbecause_cancel ?? "-"}',
          //       font: ttf, // ttfBold,,
          //       fontSize: font_Size,
          //     ),
          //   )
          // ]),

          pw.SizedBox(height: 10),
          Textx(
              value:
                  'หมายเหตุ   1  บริษัทฯ จะทำการคืนเงินประกันการเช่าให้แก่ผู้เช่าภายในระยะเวลา 45 วัน (นับตั้งแต่วันที่ผู้เช่าส่งมอบพื้นที่คืนให้กับบริษัทฯ เป็นที่เรียบร้อยแล้ว)',
              font: ttf,
              fontSize: 12),
          Textx(
              value:
                  '               2  บริษัทฯ จะทำการคืนเงินประกันโดยการโอนเงินผ่านบัญชีธนาคาร โดยมีค่าธรรมเนียมในการโอน (บัญชีธนาคารกรุงเทพ 5 บาท , ธนาคารอื่น 10 บาท )',
              font: ttf,
              fontSize: 12),

          // --- Signature Section ---
          pw.SizedBox(height: 20),
          pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
              },
              border: pw.TableBorder.all(
                  color: PdfColors.black,
                  width: 0.5,
                  style: pw.BorderStyle.solid),
              children: [
                pw.TableRow(children: [
                  // -- 1. ผู้เช่า --
                  pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: pw.Column(children: [
                        Textx(
                            value: 'ผู้เช่า',
                            font: ttf,
                            fontSize: fontSize,
                            decoration: pw.TextDecoration.underline),
                        pw.SizedBox(height: 30),
                        // pw.Divider(thickness: 0.5, color: PdfColors.black),
                        pw.Row(children: [
                          Textx(
                            value: 'ลงชื่อ ',
                            font: ttf,
                            fontSize: fontSize,
                          ),
                          pw.Expanded(
                            child: labeledLine(
                              value: '-',
                              font: ttf,
                              flex: 1,
                              color: PdfColors.white,
                            ),
                          ),
                        ]),
                        pw.SizedBox(height: 5),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              Textx(
                                  value: '( ${tenantBussscontact ?? "-"} )',
                                  font: ttf,
                                  fontSize: fontSize),
                            ]),
                        Textx(value: 'ผู้เช่า', font: ttf, fontSize: fontSize),
                        Textx(
                            value: '........../........../..........',
                            font: ttf,
                            fontSize: fontSize),
                      ])),

                  // -- 2. เสนอโดย --
                  pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: pw.Column(children: [
                        Textx(
                            value: 'เสนอโดย',
                            font: ttf,
                            fontSize: fontSize,
                            decoration: pw.TextDecoration.underline),
                        pw.SizedBox(height: 30),
                        pw.Row(children: [
                          Textx(
                            value: 'ลงชื่อ ',
                            font: ttf,
                            fontSize: fontSize,
                          ),
                          pw.Expanded(
                            child: labeledLine(
                              value: '-',
                              font: ttf,
                              flex: 1,
                              color: PdfColors.white,
                            ),
                          ),
                        ]),
                        pw.SizedBox(height: 5),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              Textx(
                                  value: '( ${ucancel ?? "-"} )',
                                  font: ttf,
                                  fontSize: fontSize),
                            ]),
                        Textx(
                            value: 'แผนกบริหารพื้นที่เช่า',
                            font: ttf,
                            fontSize: fontSize,
                            fontWeight: pw.FontWeight.normal),
                        Textx(
                            value: '........../........../..........',
                            font: ttf,
                            fontSize: fontSize,
                            fontWeight: pw.FontWeight.normal),
                      ])),

                  // -- 3. อนุมัติโดย --
                  pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: pw.Column(children: [
                        Textx(
                            value: 'อนุมัติโดย',
                            font: ttf,
                            fontSize: fontSize,
                            decoration: pw.TextDecoration.underline),
                        pw.SizedBox(height: 30),
                        pw.Row(children: [
                          Textx(
                            value: 'ลงชื่อ ',
                            font: ttf,
                            fontSize: fontSize,
                          ),
                          pw.Expanded(
                            child: labeledLine(
                              value: '-',
                              font: ttf,
                              flex: 1,
                              color: PdfColors.white,
                            ),
                          ),
                        ]),
                        pw.SizedBox(height: 5),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              Textx(
                                  value: '( เกศแก้ว สุภา )',
                                  font: ttf,
                                  fontSize: fontSize),
                              // pw.Spacer(),
                            ]),
                        Textx(
                            value: 'ผู้จัดการทั่วไป สายงานพัฒนาธุรกิจ',
                            font: ttf,
                            fontSize: fontSize),
                        Textx(
                            value: '........../........../..........',
                            font: ttf,
                            fontSize: fontSize),
                      ])),
                ]),
              ]),
          // pw.SizedBox(height: 20),
        ],
        footer: (context) {
          // // -------------------------------------------------------------
          // final int firstSection = 2; // ชุดแรกมี 2 หน้า
          // final int secondSection =
          //     (context.pagesCount - firstSection).clamp(0, 1 << 30);

          // final String pageLabel = (context.pageNumber <= firstSection)
          //     ? "${context.pageNumber}/$firstSection"
          //     : "${context.pageNumber - firstSection}/$secondSection";

          // // ✅ รวมเลขหน้ากับข้อความด้านขวา
          // String rightText = '';
          // if (context.pageNumber == 1) {
          //   rightText = '$pageLabel... ข้อ 7. ค่าเช่าสาธารณูปโภค...';
          // } else if (context.pageNumber == 2) {
          //   rightText = '';
          // } else if (context.pageNumber == 3) {
          //   rightText = '$pageLabel... 2.12 การชำระเงินประกัน...';
          // } else if (context.pageNumber == 4) {
          //   rightText = '$pageLabel... 3.8 หากผู้ให้เช่าช่วงมีความ...';
          // } else if (context.pageNumber == 5) {
          //   rightText = '$pageLabel... สัญญานี้ทำขึ้นเป็น 2 ฉบับ...';
          // } else {
          //   rightText = '';
          // }

          // -------------------------------------------------------------
          return pw.Column(
            children: [
              // ====== บรรทัดตัวเลขและข้อความ ======
              // pw.Container(
              //   width: PdfPageFormat.a4.width,
              //   padding: const pw.EdgeInsets.fromLTRB(40, 0, 40, 0),
              //   child: pw.Stack(
              //     alignment: pw.Alignment.center,
              //     children: [
              //       // 🔹 ตัวเลขอยู่กลาง
              //       pw.Align(
              //         alignment: pw.Alignment.center,
              //         child: pw.Text(
              //           pageLabel,
              //           textAlign: pw.TextAlign.center,
              //           style: pw.TextStyle(
              //             fontWeight: pw.FontWeight.bold,
              //             color: Colors_pd,
              //             fontSize: font_Size,
              //             font: ttf,
              //           ),
              //         ),
              //       ),

              //       // 🔹 ข้อความอยู่ขวา + กล่องเปล่าด้านหลัง
              //       pw.Align(
              //         alignment: pw.Alignment.centerRight,
              //         child: pw.Row(
              //           mainAxisSize:
              //               pw.MainAxisSize.min, // ให้ Row กว้างเท่าที่จำเป็น
              //           children: [
              //             pw.Text(
              //               rightText,
              //               textAlign: pw.TextAlign.right,
              //               style: pw.TextStyle(
              //                 fontWeight: pw.FontWeight.bold,
              //                 color: Colors_pd,
              //                 fontSize: font_Size,
              //                 font: ttf,
              //               ),
              //             ),
              //             pw.SizedBox(width: 7),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // ====== แถบสีและโลโก้ด้านล่าง ======
              pw.Stack(
                children: [
                  // 🔸 แถบสี 3 ชั้น
                  pw.Container(
                    width: PdfPageFormat.a4.width,
                    height: 55,
                    child: pw.Center(
                      child: pw.Container(
                        width: widths,
                        height: 25,
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Row(children: [
                              pw.Expanded(
                                child: pw.Container(
                                  color: PdfColors.red,
                                  height: 5,
                                ),
                              )
                            ]),
                            pw.Row(children: [
                              pw.Expanded(
                                child: pw.Container(
                                  color: PdfColors.green900,
                                  height: 8,
                                ),
                              )
                            ]),
                            pw.Row(children: [
                              pw.Expanded(
                                child: pw.Container(
                                  color: PdfColors.red,
                                  height: 5,
                                ),
                              )
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 🔸 โลโก้มุมขวา
                  pw.Positioned(
                    top: 4,
                    right: 50,
                    child: pw.Container(
                      width: 50.0,
                      height: 50.0,
                      child: pw.Image(pw.MemoryImage(imageData)),
                    ),
                  ),

                  // 🔸 ข้อความบริษัท (ซ้ายบน)
                  pw.Positioned(
                    top: 4,
                    left: 40,
                    child: pw.Container(
                      width: PdfPageFormat.a4.width - 150,
                      child: pw.Text(
                        "CHOICE MINI STORE CO., LTD. 7/11 VILLAGE NO.5, THA SALA SUB-DISTRICT, MUEANG CHIANG MAI DISTRICT, CHIANG MAI PROVINCE 50000",
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          color: colorsPd,
                          fontSize: fontSize - 4,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                    ),
                  ),

                  // 🔸 ข้อความลิขสิทธิ์ (ขวาล่าง)
                  pw.Positioned(
                    bottom: 4,
                    right: 120,
                    child: pw.Text(
                      "Sub Area Licencee: Chiang Mai, Lamphun, Mae-Hong-Son",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: colorsPd,
                        fontSize: fontSize - 4,
                        font: ttf,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPdfgen_Billsplay(
              doc: pdf, title: 'ใบยกเลิกสัญญาเช่า($tenantCiddoc)'),
        ));
    // Printing.layoutPdf(
    //   onLayout: (PdfPageFormat format) async => pdf.save(),
    // );
  }
}
