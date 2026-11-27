import 'dart:convert';

import 'package:chaoperty_user/loadAndCacheImage.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import '../../../Man_PDF/Preview_PDF/Preview_Agreement.dart';

class Pdfgen_Agreementmeechoksub {
//////////---------------------------------------------------->( ****  แนบท้ายสัญญาเช่า   )

  static void exportPDF_Agreementmeechoksub(
    context,
    Get_Value_NameShop_index,
    Get_Value_cid,
    _verticalGroupValue,
    Form_nameshop,
    Form_typeshop,
    Form_bussshop,
    Form_bussscontact,
    Form_address,
    Form_tel,
    Form_email,
    Form_tax,
    Form_ln,
    Form_zn,
    Form_area,
    Form_qty,
    Form_sdate,
    Form_ldate,
    Form_period,
    Form_rtname,
    quotxSelectModels,
    charge_type_lp,
    _TransModels,
    renTal_name,
    bill_addr,
    bill_email,
    bill_tel,
    bill_tax,
    bill_name,
    newValuePDFimg,
    tableData00,
    TitleType_Default_Receipt_Name,
    Datex_text,
    teNantModels,
    contractPhotoModels,
    FormName1_choice,
    FormName2_choice,
    FormName3_choice,
    FormName4_choice,
    Title_text,
    Details_text,
  ) async {
    ////

    final pdf = pw.Document();
    // final fontData = await rootBundle.load("ThaiFonts/Sarabun-Medium.ttf");
    // var dataint = fontData.buffer
    //     .asUint8List(fontData.offsetInBytes, fontData.lengthInBytes);
    // final PdfFont font = PdfFont.of(pdf, data: dataint);
    final font = await rootBundle.load("fonts/THSarabunNew.ttf");
    var Colors_pd = PdfColors.black;

    final ttf = pw.Font.ttf(font);

    double font_Size = 15;
    DateTime date = DateTime.now();
    // var formatter = DateFormat('MMMMd', 'th');
    String thaiDate = DateFormat('d เดือน MMM', 'th').format(date);
    var nFormat = NumberFormat("#,##0.00", "en_US");
    var nFormat2 = NumberFormat("###0.00", "en_US");
    final iconImage =
        (await rootBundle.load('images/LOGO.png')).buffer.asUint8List();
    List netImage = [];
    Uint8List? resizedLogo = await getResizedLogo();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int pageCount = 1; // Initialize the page count
    String? base64Image_1 = preferences.getString('base64Image1');
    // String? base64Image_2 = preferences.getString('base64Image2');
    // String? base64Image_3 = preferences.getString('base64Image3');
    // String? base64Image_4 = preferences.getString('base64Image4');
    String base64Image_new1 = (base64Image_1 == null) ? '' : base64Image_1;
    // String base64Image_new2 = (base64Image_2 == null) ? '' : base64Image_2;
    // String base64Image_new3 = (base64Image_3 == null) ? '' : base64Image_3;
    // String base64Image_new4 = (base64Image_4 == null) ? '' : base64Image_4;
    // Uint8List data1 = base64Decode(base64Image_new1);
    // Uint8List data2 = base64Decode(base64Image_new2);
    // Uint8List data3 = base64Decode(base64Image_new3);
    // Uint8List data4 = base64Decode(base64Image_new4);

    // for (int i = 0; i < newValuePDFimg.length; i++) {
    //   netImage.add(await networkImage('${newValuePDFimg[i]}'));
    // }
    // final tableData = [
    //   for (int index = 0; index < quotxSelectModels.length; index++)
    //     [
    //       '${nFormat.format(int.parse(quotxSelectModels[index].term!) * double.parse(quotxSelectModels[index].total!))}',
    //     ],
    // ];
    // double Sumtotal = 0;
    // for (int index = 0; index < quotxSelectModels.length; index++)
    //   Sumtotal = Sumtotal +
    //       (int.parse(quotxSelectModels[index].term!) *
    //           double.parse(quotxSelectModels[index].total!));

    // final type = teNantModels.isNotEmpty ? teNantModels.first.ctype : null;
    // final typelist = teNantModels.where((item) => item.ctype != '').toList();
    // final type = typelist.isNotEmpty ? typelist.first.ctype : '-';
    // final remarkList = teNantModels.where((item) => item.remark != '').toList();
    // final remark = remarkList.isNotEmpty ? remarkList.first.remark : '-';

    // final filteredListchao = quotxSelectModels
    //     .where(
    //         (item) => (item.dtype ?? '').trim() == "KR" && item.expser == '1')
    //     .toList();
    // final totalchaoNumber = filteredListchao.fold<double>(
    //   0.00,
    //   (double sum, dynamic item) =>
    //       sum +
    //       (item.pvat != null
    //           ? double.parse(item.pvat!.replaceAll(',', ''))
    //           : 0.00),
    // ); // ค่าเช่า เดือนละ (ตัวเลข)
    // final totalchao =
    //     nFormat.format(totalchaoNumber); // ค่าเช่า เดือนละ (String)

    final remarkList = teNantModels.where((item) => item.remark != '').toList();
    final remark = remarkList.isNotEmpty ? remarkList.first.remark : '-';

    final filteredListchao = quotxSelectModels
        .where(
            (item) => (item.dtype ?? '').trim() == "KR" && item.expser == '1')
        .toList();
    final totalchaoNumber = filteredListchao.fold<double>(
      0.00,
      (double sum, dynamic item) =>
          sum +
          (item.pvat != null
              ? double.parse(item.pvat!.replaceAll(',', ''))
              : 0.00),
    ); // ค่าเช่า เดือนละ (ตัวเลข)
    final rt_chao =
        filteredListchao.where((item) => item.unit != null).toList();
    final totalchao =
        nFormat.format(totalchaoNumber); // ค่าเช่า เดือนละ (String)
    final charge_type = charge_type_lp?.toString() ?? '';

    final filteredListpakan = quotxSelectModels
        .where((item) => (item.dtype ?? '').trim() == "KD")
        .toList();
    final totalpakanNumber = filteredListpakan.fold<double>(
      0.00,
      (double sum, dynamic item) =>
          sum +
          (item.pvat != null
              ? double.parse(item.pvat!.replaceAll(',', ''))
              : 0.00),
    );
    final totalpakan = nFormat.format(totalpakanNumber);

    // additional info
    // ขนาด/เนื้อที่รวม: ใช้ teNantModels เป็นหลัก (มี area/area_rent/area_size)
    // ถ้าว่าง fallback ไป quotxSelectModels
    final _areaItem = (teNantModels.isNotEmpty)
        ? teNantModels.first
        : (quotxSelectModels.isNotEmpty ? quotxSelectModels.first : null);
    // ขนาด = area_width x area_length เช่น "3.00 x 3.00" (ถ้าไม่มีใช้ Form_area เดิม)
    final areaDimText = (_areaItem?.area_width != null &&
            '${_areaItem?.area_width}'.trim().isNotEmpty)
        ? '${_areaItem?.area_width} x ${_areaItem?.area_length ?? ''}'
        : ' - ';
    // เนื้อที่รวม = area เช่น "18"
    final areaTotalText =
        (_areaItem?.area != null && '${_areaItem?.area}'.trim().isNotEmpty)
            ? '${_areaItem?.area}'
            : ' - ';
    // ค่าเช่า ใช้ area_rent จาก quotxSelectModels (ถ้าไม่มีใช้ totalchao เดิม)
    final areaRentNumber =
        double.tryParse('${_areaItem?.area_rent ?? ''}'.replaceAll(',', '')) ??
            totalchaoNumber;
    final areaRentText = nFormat.format(areaRentNumber);

    pw.Widget Textx({
      // required String label,
      required String value,
      // int dotLength = 40,
      required pw.Font font,
      double? fontSize,
      textAlign = pw.TextAlign.left,
    }) {
      var Colors_pd = PdfColors.black;
      // final filled = value.padRight(dotLength, '.');
      return pw.Text(
        value,
        textAlign: textAlign,
        style: pw.TextStyle(
          font: font,
          fontSize: fontSize ?? font_Size,
          fontWeight: pw.FontWeight.bold,
        ),
      );
    }

    pw.Widget Textr({
      // required String label,
      required String value,
      // int dotLength = 40,
      required pw.Font font,
      double? fontSize,
    }) {
      var Colors_pd = PdfColors.black;
      // final filled = value.padRight(dotLength, '.');
      return pw.Text(
        value,
        textAlign: pw.TextAlign.right,
        style: pw.TextStyle(
          font: font,
          fontSize: fontSize ?? font_Size,
          // fontWeight: pw.FontWeight.bold,
        ),
      );
    }

    // เช็คค่าว่าง (null, '', ' ', 'null') ให้แสดงเป็น ' - ' แทน
    String dashIfEmpty(dynamic value, {String fallback = ' - '}) {
      if (value == null) return fallback;
      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') return fallback;
      return text;
    }

    pw.Widget labeledLine({
      required String? value,
      required pw.Font font,
      double? fontSize,
      required int flex,
    }) {
      var Colors_pd = PdfColors.black;
      final text = dashIfEmpty(value);
      // ค่าว่าง (' - ') ให้จัดกึ่งกลาง, ค่าปกติชิดซ้ายเหมือนเดิม
      final isEmptyValue = text == ' - ';

      return pw.Expanded(
          flex: flex,
          child: pw.Container(
            alignment:
                isEmptyValue ? pw.Alignment.center : pw.Alignment.centerLeft,
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColors.grey, // เส้นใต้สีเทาให้เท่ากับ labeledLine1
                  width: 0.05,
                ),
              ),
            ),
            padding: const pw.EdgeInsets.only(bottom: -5, top: -5),
            margin: const pw.EdgeInsets.only(bottom: 5, top: 5),
            //  padding: const pw.EdgeInsets.only(bottom: -3.5),
            child: pw.Text(
              // ' ' * 2 + text + ' ' * 2,
              text,
              textAlign: isEmptyValue ? pw.TextAlign.center : pw.TextAlign.left,
              style: pw.TextStyle(
                  font: font,
                  fontSize: fontSize ?? font_Size,
                  color: Colors_pd,
                  fontWeight: pw.FontWeight.bold),
            ),
          ));
    }

    pw.Widget labeledLine1({
      required String? value,
      required pw.Font font,
      double? fontSize,
      required int flex,
    }) {
      var Colors_pd = PdfColors.black;
      final text = dashIfEmpty(value);
      final isEmptyValue = text == ' - ';

      return pw.Expanded(
          flex: flex,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColors.grey,
                  width: 0.05, // ปรับให้บางลงกว่าเดิม
                ),
              ),
            ),
            padding: const pw.EdgeInsets.only(bottom: -5, top: -5),
            margin: const pw.EdgeInsets.only(bottom: 5, top: 5),
            //  padding: const pw.EdgeInsets.only(bottom: -3.5),
            child: pw.Text(
              ' ' * 2 + text + ' ' * 2,
              // text,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                  font: font,
                  fontSize: fontSize ?? font_Size,
                  color: Colors_pd,
                  fontWeight: pw.FontWeight.bold),
            ),
          ));
    }

    // บล็อกลงชื่อ 1 ช่อง (ใช้ซ้ำทั้ง ผู้เช่า / ผู้ให้เช่า / พยาน)
    pw.Widget signBlock({
      required String role,
      dynamic name,
      dynamic subName,
      int dots = 20,
    }) {
      final nameText = name?.toString().trim() ?? '';
      final subText = subName?.toString().trim() ?? '';

      return pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          Textx(
            value: 'ลงชื่อ${'...' * dots} $role',
            font: ttf,
            textAlign: pw.TextAlign.center,
          ),
          Textx(
            value:
                nameText.isNotEmpty ? '(  $nameText  )' : '(${'...' * dots})',
            font: ttf,
            textAlign: pw.TextAlign.center,
          ),
          if (subText.isNotEmpty)
            Textx(
              value: subText,
              font: ttf,
              textAlign: pw.TextAlign.center,
            ),
        ],
      );
    }

    const thaiMonths = [
      '',
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม',
    ];

    DateTime? parseThaiDateFlexible(String input) {
      try {
        // รองรับ yyyy-MM-dd, dd-MM-yyyy, dd/MM/yyyy
        if (input.contains('-')) {
          final parts = input.split('-');
          if (parts.length == 3) {
            // ถ้า year อยู่หน้าสุด
            if (parts[0].length == 4) {
              return DateTime(
                int.parse(parts[0]),
                int.parse(parts[1]),
                int.parse(parts[2]),
              );
            } else {
              // day-month-year
              return DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            }
          }
        } else if (input.contains('/')) {
          final parts = input.split('/');
          if (parts.length == 3) {
            return DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        }
        // fallback: parse แบบปกติ
        return DateTime.parse(input);
      } catch (e) {
        return null;
      }
    }

    // แยกตัวแปรวันที่แบบไทยออกมาใช้ได้
    Map<String, dynamic>? getThaiDateComponents(String input) {
      final dt = parseThaiDateFlexible(input);
      if (dt == null) return null;
      return {
        'day': dt.day,
        'monthName': thaiMonths[dt.month],
        'yearBE': dt.year + 543,
      };
    }

    // รูปแบบ: วันที่ 1 เดือน มกราคม พ.ศ. 2568
    String formatThaiDate(String input) {
      final components = getThaiDateComponents(input);
      if (components == null) return input;
      return 'วันที่ ${components['day']} เดือน ${components['monthName']} พ.ศ. ${components['yearBE']}';
    }

    // รูปแบบ: 1 มกราคม 2568
    String formatThaiDateS(String input) {
      final components = getThaiDateComponents(input);
      if (components == null) return input;
      return '${components['day']} ${components['monthName']} ${components['yearBE']}';
    }

    // ดึงข้อมูลวันที่แบบแยกส่วนเพื่อใช้ใน PDF
    final Datex = getThaiDateComponents(Datex_text.text); // สำหรับวันที่ทำสัญญา
    final DateStart =
        getThaiDateComponents(Form_sdate); // สำหรับวันที่เริ่มสัญญา
    final DateEnd =
        getThaiDateComponents(Form_ldate); // สำหรับวันที่สิ้นสุดสัญญา

///////////////////////------------------------------------------------->
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginBottom: 40.00,
          marginLeft: 40.00,
          marginRight: 40.00,
          marginTop: 40.00,
        ),

        build: (context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                Textx(
                    value: 'แนบท้ายสัญญาเช่า',
                    font: ttf,
                    fontSize: font_Size + 3),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                Textx(
                    value: 'ระเบียบปฏิบัติข้อบังคับตลาดนัด มีโชคพลาซ่า',
                    font: ttf,
                    fontSize: font_Size + 3),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),

            pw.Row(children: [
              Textx(
                value:
                    '${' ' * 6}1.  ผู้เช่าสัญญาว่าจะครอบครองใช้ประโยชน์ขายสินค้าของตนเองตามที่ระบุในสัญญาเท่านั้นจะไม่ยินยอมให้ผู้หนึ่งผู้ใดครอบครอง',
                font: ttf,
              ),
            ]),
            pw.Row(children: [
              Textx(
                value:
                    'ใช้ประโยชน์ในพื้นที่จำหน่ายสินค้าที่ได้รับมอบสิทธิ์จากผู้ให้เช่าพื้นที่จำหน่ายสินค้าที่ได้รับมอบสิทธิ์จากผู้ให้เช่า ถ้ามีการขายสินค้าที่ไม่',
                font: ttf,
              ),
            ]),
            Textx(
              value: 'ตรงกับที่แจ้งไว้ในวันนั้นจะถือว่าเป็นล็อควิ่ง',
              font: ttf,
            ),
            pw.Row(children: [
              Textx(
                value:
                    '${' ' * 6}2.  ผู้เช่าจะต้องจัดตั้งสินค้า กางเต้นท์หรือกระทำการสิ่งอื่นใดในขอบเขตของผู้เช่าเองเท่านั้น ห้ามล้ำเขตของผู้เช่ารายอื่นหรือทาง',
                font: ttf,
              ),
            ]),
            Textx(
              value:
                  'เดินและทางเท้าสาธารณะหากทำให้เกิดความเสียหายจะต้องรับผิดชอบในสิ่งที่เกิดขึ้น',
              font: ttf,
            ),
            pw.Row(children: [
              Textx(
                value:
                    '${' ' * 6}3.  สำหรับกรณีที่ผู้เช่าล็อคที่ติดกับร้านค้าของลูกค้าในโครงการมีโชคพลาซ่า  ห้ามตั้งวางสินค้าบนฟุตบาท,  นั่งบนฟุตบาท,  ห้าม',
                font: ttf,
              ),
            ]),
            Textx(
              value:
                  'ตั้งสินค้าสูงเกิน  1  เมตรเมื่อจำหน่ายสินค้าเสร็จแล้วให้เก็บสินค้าและอุปกรณ์กลับให้หมดสิ้น ',
              font: ttf,
            ),
            pw.Row(children: [
              Textx(
                value:
                    '${' ' * 6}4.  เมื่อลงสินค้าและอุปกรณ์เสร็จเรียบร้อยแล้ว  ผู้เช่าจะต้องนำรถยนต์ของผู้เช่าไปจอดยังอาคารจอดรถชั้น  4-6  หากรถหลังคา',
                font: ttf,
              ),
            ]),

            pw.Row(children: [
              Textx(
                value: 'สูงให้จอดที่ข้างอาคารพักขยะ',
                font: ttf,
              ),
              pw.Container(
                  child: labeledLine1(
                      value: '(ห้ามจอดรถยนต์แช่ไว้เพื่อจัดร้านให้เสร็จก่อน)',
                      font: ttf,
                      flex: 1)),
            ]),

            Textx(
              value:
                  '${' ' * 6}5.  ผู้เช่าที่จำหน่ายสินค้าประเภทอาหารทุกล็อค จะต้องมีผ้าใบปูพื้นล่าง เพื่อรักษาความสะอาดบริเวณพื้น ',
              font: ttf,
            ),
            Textx(
              value:
                  '${' ' * 6}6.  หากวันนัดใด  ผู้เช่าไม่สามารถมาจำหน่ายสินค้าได้  จะต้องแจ้งให้ทราบล่วงหน้าก่อน  เวลา 15.00 น.  ทางไลน์กลุ่มตลาดนัด หรือ โทรศัพท์ 086-6594498',
              font: ttf,
            ),
            pw.Row(children: [
              Textx(
                value:
                    '${' ' * 6}7.  ผู้เช่าใดที่จะมิได้มาจำหน่ายสินค้าหลายนัดติดต่อกัน  จะต้องแจ้งให้ผู้ให้เช่าทราบล่วงหน้า  หากประสงค์ให้ผู้อื่นมาขายในล็อค',
                font: ttf,
              ),
            ]),
            pw.Row(children: [
              Textx(
                value:
                    'ของตน จะต้องยื่นคำร้องและได้รับอนุญาต และชำระค่าเช่าล็อคเสียบให้ครบถ้วนก่อน หากมิได้มีการติดต่อแจ้งเหตุดังกล่าวจะถือว่าผู้',
                font: ttf,
              ),
            ]),
            Textx(
              value: 'เช่ารายนั้นๆ',
              font: ttf,
            ),
            pw.Row(children: [
              Textx(
                value:
                    '${' ' * 6}8.  ผู้เช่าต้องมาจัดวางสินค้าในบริเวณล็อคของท่านก่อนเวลา  16.00 น. (ประเภทอาหาร) และ 17.00 น. (สินค้าทั่วไป) หากเกิน',
                font: ttf,
              ),
            ]),
            pw.Row(children: [
              Textx(
                value:
                    'เวลาที่กำหนดนี้ ท่านยังมิได้มาจัดวางสินค้าและมิได้แจ้งเหตุขัดข้องให้ทราบล่วงหน้า ผู้ให้เช่ามีสิทธิ์ตัดล็อคของท่านเพื่อให้ผู้อื่นใช้พื้นที่',
                font: ttf,
              ),
            ]),
            Textx(
              value: 'ต่อไป ',
              font: ttf,
            ),

            Textx(
              value:
                  '${' ' * 6}9.  ในกรณีล็อคว่างเป็นสิทธิของผู้ให้เช่าที่จะพิจารณาจัดให้ผู้อื่นมาขายสินค้าใด ๆ ก็ได้ตามความเหมาะสม ',
              font: ttf,
            ),
            pw.Row(children: [
              Textx(
                value:
                    '${' ' * 6}10.  หากผู้เช่ารายใดทำการสิ่งใดทำให้เกิดความเสียหายกับสถานที่หรือทรัพย์สินอื่นๆ ของตลาดนัด ผู้เช่าจะต้องชดใช้ค่าเสียหาย',
                font: ttf,
              ),
            ]),
            Textx(
              value: 'ทุกประการ',
              font: ttf,
            ),

            pw.Row(children: [
              Textx(
                value:
                    '${' ' * 6}11.  ผู้เช่าจะต้องรักษาความสะอาดบริเวณจัดตั้งสินค้า โดยจัดเก็บขยะในล็อคของผู้เช่าเองในถุงพลาสติก  ปิดปากถุงให้เรียบร้อย',
                font: ttf,
              ),
            ]),
            Textx(
              value: 'ทิ้งใส่ภาชนะที่จัดเตรียมไว้ให้ ',
              font: ttf,
            ),

            pw.Row(children: [
              Textx(
                value:
                    '${' ' * 6}12.  ผู้เช่าทุกท่านจะต้องให้ความร่วมมือกับผู้ให้เช่าเมื่อได้รับการร้องขอในทันที  หากเกิดเหตุทะเลาะวิวาทกัน  หรือมีพฤติการรบ',
                font: ttf,
              ),
            ]),
            Textx(
              value: 'กวนผู้อื่น ผู้ให้เช่าจะยกเลิกสัญญาเช่าคู่กรณีทันที ',
              font: ttf,
            ),
            pw.Row(children: [
              Textx(
                value:
                    '${' ' * 6}13.  ผู้เช่าจะยินยอมปฏิบัติตามระเบียบต่างๆ ของตลาดนัดมีโชคพลาซ่าทุกประการ หากผิดระเบียบจะยินยอมให้ผู้ให้เช่ายกเลิก',
                font: ttf,
              ),
            ]),
            Textx(
              value:
                  'สิทธิการเช่าโดยจะไม่สามารถร้องเรียกสิทธิ์ใดๆ หรือค่าใช้จ่ายที่ชำระไปแล้วคืนจากผู้ให้เช่า ',
              font: ttf,
            ),
            pw.Row(children: [
              Textx(
                value:
                    '${' ' * 6}14.  ในกรณีที่มีการเปลี่ยนแปลงชื่อผู้เช่าต้องชำระค่าเปลี่ยนสัญญาล็อคละ 8,000 บาท หากเปลี่ยนประเภทสินค้า 4,000 บาท ',
                font: ttf,
              ),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            Textx(
              value:
                  '${' ' * 6}ผู้เช่าได้อ่านข้อความโดยละเอียดดีแล้วและเข้าใจดีแล้ว ยินดีปฏิบัติตามทุกประการ จึงลงลายมือชื่อรับทราบไว้เป็นหลักฐาน ',
              font: ttf,
            ),
            pw.SizedBox(height: 10 * PdfPageFormat.mm),
            // ช่องลงชื่อ 2 ฝั่ง ซ้าย-ขวา เรียงจากซ้าย: ผู้เช่า | ผู้ให้เช่า / พยาน | พยาน
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 1,
                  child: signBlock(
                    role: 'ผู้เช่า',
                    name: Form_bussscontact,
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: signBlock(
                    role: 'ผู้ให้เช่า',
                    name: FormName1_choice,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4 * PdfPageFormat.mm),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 1,
                  child: signBlock(
                    role: 'พยาน',
                    name: FormName3_choice,
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: signBlock(
                    role: 'พยาน',
                    name: FormName4_choice,
                  ),
                ),
              ],
            ),
          ];
        },
        // footer: (context) {
        //   return pw.Column(
        //     mainAxisSize: pw.MainAxisSize.min,
        //     children: [
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
    ); // final bytes = await pdf.save();
///////////////////////------------------------------------------------->

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RentalInforman_Agreement(
            doc: pdf,
            context: context, Get_Value_cid: Get_Value_cid,
            ////////////------------------->
            ///
            // Get_Value_NameShop_index: Get_Value_NameShop_index,
            // Get_Value_cid: Get_Value_cid,
            // verticalGroupValue: _verticalGroupValue,
            // Form_nameshop: Form_nameshop,
            // Form_typeshop: Form_typeshop,
            // Form_bussshop: Form_bussshop,
            // Form_bussscontact: Form_bussscontact,
            // Form_address: Form_address,
            // Form_tel: Form_tel,
            // Form_email: Form_email,
            // Form_tax: Form_tax,
            // Form_ln: Form_ln,
            // Form_zn: Form_zn,
            // Form_area: Form_area,
            // Form_qty: Form_qty,
            // Form_sdate: Form_sdate,
            // Form_ldate: Form_ldate,
            // Form_period: Form_period,
            // Form_rtname: Form_rtname,
            // quotxSelectModels: quotxSelectModels,
            // TransModels: _TransModels,
            // renTal_name: renTal_name,
            // bill_addr: bill_addr,
            // bill_email: bill_email,
            // bill_tel: bill_tel,
            // bill_tax: bill_tax,
            // bill_name: bill_name,
            // newValuePDFimg: newValuePDFimg,
          ),
        ));
  }
}
