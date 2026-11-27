import 'package:chaoperty_user/File_s.dart';
import 'package:chaoperty_user/Model/trans_re_bill_history_model.dart';
import 'package:chaoperty_user/PDF/pdf_constants.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/services.dart';

import '../../../../Man_PDF/Preview_PDF/PreviewPdfgen_Billsplay.dart';

class Pdfgen_his_statusbill_80MM {
  //////////---------------------------------------------------->(บิลเงินสด/ใบเสร็จรับเงิน กระดาษ 80 mm)
  // เทมเพลตแบบใบเสร็จ POS 80 mm : แสดงเฉพาะ 2 คอลัมน์ => รายการ / รวม
  static void exportPDF_statusbill_80MM({
    required List<TransReBillHistoryModel> TransReBillHistory,
    required Cust_no,
    required cid_s,
    required Zone_s,
    required Ln_s,
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
    required signature,
    required fullname,
    required billingFormat,
  }) async {
    const String pageMode = 'pos80';
    final pdf = pw.Document();
    // ── ฟอนต์สำหรับกระดาษความร้อน 80mm ──────────────────────
    // !! ห้ามใช้ Sarabun*.ttf (Cadson Demak) กับ package:pdf เด็ดขาด !!
    // package:pdf 3.10.1 ไม่ทำ OpenType shaping (ไม่อ่าน GSUB/GPOS เลย)
    // Sarabun ออกแบบให้ "ยกวรรณยุกต์" ด้วย GPOS mark-to-mark ตอน render
    // พอไม่มี GPOS วรรณยุกต์เลยไปทับสระบน เช่น ที่ / ผู้ / เพื่อ
    //   วัดจากไฟล์ฟอนต์ (หน่วย em) :
    //     THSarabunNew : สระอี 0.455-0.647 | ไม้เอก 0.680-0.791  -> ห่าง ไม่ทับ
    //     SarabunBold  : สระอี 0.652-0.954 | ไม้เอก 0.684-0.903  -> ซ้อนกันเต็ม
    // THSarabunNew วางความสูงมาร์คมาให้ถูกตั้งแต่ในฟอนต์ จึงใช้ได้โดยไม่ต้อง GPOS
    //
    // ตัวหนาจึงใช้ THSarabunNewBold.ttf (ฟอนต์แห่งชาติชุดเดียวกัน จาก SIPA)
    // วัดแล้วเช่นกัน : สระอี 0.450-0.648 | ไม้เอก 0.677-0.791 -> ไม่ทับ
    // และ advance กว้างกว่า Regular แค่ ~2% เลย์เอาต์จึงไม่เพี้ยน
    //
    // ลาว (fonts_pdf เป็นฟอนต์ลาว) ยังไม่มีน้ำหนัก Bold ใน fonts/
    // จึงใช้ไฟล์ที่ส่งเข้ามาเป็นตัวหนาไปก่อน (ไม่งั้นไทยกับลาวจะปนกัน)
    final bool _isLao = fonts_pdf.toString().contains('Lao');
    final ttf = pw.Font.ttf(await rootBundle.load(fonts_pdf.toString()));
    final ttfBold = _isLao
        ? ttf
        : pw.Font.ttf(await rootBundle.load('fonts/THSarabunNewBold.ttf'));
    final Colors_pd = PdfColors.black;
    final nFormat = NumberFormat("#,##0.00", "en_US");
    const PdfColor PDF_Border_Color = PDFConstants.borderColor;

    // ── ขนาดตัวอักษรสำหรับกระดาษ 80 mm ─────────────────────
    // THSarabunNew ตัวเล็กกว่า Sarabun ที่ pt เท่ากัน จึงกลับมาใช้ 13.0 ตามเดิม
    const double font_Size = 13.0;

    ///////------------------------------->
    double roundMoney(double value) {
      return (value * 100).round() / 100;
    }

    double getTotalByField(
      List<TransReBillHistoryModel> trans,
      String? Function(TransReBillHistoryModel item) getter,
    ) {
      return trans.fold(0.0, (sum, item) {
        return sum + (double.tryParse(getter(item) ?? '0.00') ?? 0.00);
      });
    }

    String getFormattedText(String? data) {
      return nFormat
          .format((data == null) ? 0.00 : double.tryParse(data) ?? 0.00);
    }

    // ── ยอดรวมต่างๆ (คิดแบบเดียวกับ TP4) ─────────────────────
    final double totalPvat = roundMoney(
        getTotalByField(transReBillHistoryModels, (e) => e.pvat.toString()));
    final double totalVat = roundMoney(
        getTotalByField(transReBillHistoryModels, (e) => e.vat.toString()));
    final double totalWht = roundMoney(
        getTotalByField(transReBillHistoryModels, (e) => e.wht.toString()));
    final double totalLine = roundMoney(
        getTotalByField(transReBillHistoryModels, (e) => e.total.toString()));

    final double totalDis =
        roundMoney(double.tryParse(sum_disamt.toString()) ?? 0.00);
    final double totalFee =
        roundMoney(double.tryParse(sum_fee.toString()) ?? 0.00);
    final double totalMatjum =
        roundMoney(double.tryParse(dis_sum_Matjum.toString()) ?? 0.00);
    final double totalPakan =
        roundMoney(double.tryParse(dis_sum_Pakan.toString()) ?? 0.00);

    final double totalBill = roundMoney((totalLine + totalFee) - totalDis) -
        (totalMatjum + totalPakan);

    // ── ชำระด้วยเงินสดหรือไม่ (ใช้เลือกชื่อเอกสาร) ──────────────
    final bool hasCashTransaction = finnancetransModels.any((transaction) {
      return transaction.type.toString() == 'CASH' &&
          transaction.dtype.toString() != 'FTA';
    });

    // ── ชื่อรายการ (แสดงในคอลัมน์ "รายการ") ─────────────────
    String itemName(TransReBillHistoryModel bill) {
      final String name = (bill.expname != null &&
              bill.expname.toString().trim().isNotEmpty &&
              bill.expname.toString() != 'null')
          ? bill.expname.toString()
          : (bill.name ?? '').toString();
      try {
        if (bill.unitser.toString() == '6' && bill.dtype.toString() != 'KU') {
          return '$name [ หน่วยที่ใช้ไป ${bill.ovalue}-${bill.nvalue} ]';
        }
        if (bill.date != null && bill.date.toString().trim().isNotEmpty) {
          final d = DateTime.parse(bill.date!);
          return '$name ${DateFormat('MMM', 'th').format(d)} ${d.year + 543}';
        }
      } catch (_) {}
      return name;
    }

    // ── ชื่อลูกค้า ──────────────────────────────────────────
    String custName() {
      final candidates = [cname, sname, Namenew];
      for (final c in candidates) {
        if (c != null &&
            c.toString().trim().isNotEmpty &&
            c.toString() != 'null' &&
            c.toString() != '-') {
          return c.toString();
        }
      }
      return '-';
    }

    // ── หัวเอกสาร (ประเภทเอกสาร / เลขที่ / วันที่) ──────────────
    final String docName = (hasCashTransaction)
        ? ((numdoctax.toString() == '') ? 'บิลเงินสด' : 'บิลเงินสด/ใบกำกับภาษี')
        : ((numdoctax.toString() == '')
            ? 'ใบเสร็จรับเงิน'
            : 'ใบเสร็จรับเงิน/ใบกำกับภาษี');

    final String docTitle = (TitleType_Default_Receipt_Name != null &&
            TitleType_Default_Receipt_Name.toString().trim() != '' &&
            TitleType_Default_Receipt_Name.toString() != 'ไม่ระบุ')
        ? '$docName [ $TitleType_Default_Receipt_Name ]'
        : docName;

    final String docNo =
        (numdoctax.toString() == '') ? '$numinvoice' : '$numdoctax';

    final String docDate = (date_Transaction == null ||
            date_Transaction.toString().trim() == '' ||
            date_Transaction.toString() == 'null')
        ? '-'
        : '${DateFormat('dd-MM').format(DateTime.parse(date_Transaction))}-${DateTime.parse('${date_Transaction}').year + 543}';

    final String payDate = (dayfinpay == null ||
            dayfinpay.toString().trim() == '' ||
            dayfinpay.toString() == 'null')
        ? '-'
        : '${DateFormat('dd-MM').format(DateTime.parse('${dayfinpay}'))}-${DateTime.parse('${dayfinpay}').year + 543}';

    pw.Widget divider() => pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            children: List.generate(
              46,
              (_) => pw.Expanded(
                child: pw.Container(
                  height: 0.7,
                  color: PDF_Border_Color,
                  margin: const pw.EdgeInsets.symmetric(horizontal: 0.6),
                ),
              ),
            ),
          ),
        );

    pw.Text tCenter(String s, {double size = font_Size, bool bold = true}) =>
        pw.Text(
          s,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: size,
            font: ttf,
            fontBold: ttfBold,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: Colors_pd,
          ),
        );

    pw.Text tLeft(String s, {bool bold = true}) => pw.Text(
          s,
          textAlign: pw.TextAlign.left,
          style: pw.TextStyle(
            fontSize: font_Size,
            font: ttf,
            fontBold: ttfBold,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: Colors_pd,
          ),
        );

    // ── แถวรายการ : รายการ (ซ้าย flex 2) | รวม (ขวา flex 1) ───────────────
    //    ชื่อยาวปล่อยให้ wrap เองตามช่องว่างในข้อความ, จำกัด 3 บรรทัด เกินตัดทิ้ง
    pw.Widget itemRow(String name, String amount, {bool bold = true}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                name,
                maxLines: 3, // ยาวเกิน 3 บรรทัดตัดทิ้ง (pdf ไม่มี ellipsis)
                overflow: pw.TextOverflow.clip,
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: font_Size,
                  font: ttf,
                  fontBold: ttfBold,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: Colors_pd,
                ),
              ),
            ),
            pw.SizedBox(width: 4),
            pw.Expanded(
              flex: 1,
              child: pw.Text(
                amount,
                maxLines: 1,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontSize: font_Size,
                  font: ttf,
                  fontBold: ttfBold,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: Colors_pd,
                ),
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget itemRow1(String name, String amount, {bool bold = true}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                name,
                maxLines: 3,
                overflow: pw.TextOverflow.clip,
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: font_Size + 3,
                  font: ttf,
                  fontBold: ttfBold,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: Colors_pd,
                ),
              ),
            ),
            pw.SizedBox(width: 4),
            pw.Expanded(
              flex: 1,
              child: pw.Text(
                amount,
                maxLines: 1,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontSize: font_Size + 3,
                  font: ttf,
                  fontBold: ttfBold,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: Colors_pd,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── เนื้อหาบิล ────────────────────────────────────────────────
    //    แยกเป็นฟังก์ชันเพื่อใช้ทั้ง "ตอนลองวัดจำนวนหน้า" และ "ตอนออกจริง"
    //    (widget ของ pdf ใช้ซ้ำข้ามเอกสารไม่ได้ จึงต้องสร้างใหม่ทุกครั้ง)
    List<pw.Widget> buildContent() {
      return [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Center(
                child: tCenter(docTitle, size: font_Size + 3, bold: true)),
            pw.SizedBox(height: 6),
            // ───── ข้อมูลเอกสาร ─────
            tLeft(
                'เลขที่ : ${(docNo.trim() == '' || docNo == 'null') ? '-' : docNo}'),
            tLeft('วันที่ : $docDate'),
            tLeft('วันที่ชำระ : $payDate'),
            tLeft('นามลูกค้า : ${custName()}'),
            tLeft(
                'โซน : ${(Zone_s == null || Zone_s.toString() == 'null') ? '-' : Zone_s}   รหัสพื้นที่ : ${(Ln_s == null || Ln_s.toString() == 'null') ? '-' : Ln_s}'),
            if (fname != null &&
                fname.toString().trim().isNotEmpty &&
                fname.toString() != 'null')
              tLeft('พนักงาน : $fname'),
            if (ref_invoice != null && ref_invoice.length != 0)
              tLeft(
                  'อ้างอิงเลขที่ : ${ref_invoice.toSet().map((model) => model).join(', ')}'),

            // if (com_ment != null &&
            //     com_ment.toString().trim() != '' &&
            //     com_ment.toString() != 'null')
            //   tLeft('หมายเหตุ/Note : $com_ment'),
            pw.SizedBox(height: 6),
            divider(),
            // ───── หัวตาราง : รายการ | รวม ─────
            itemRow1('รายการ', 'รวม', bold: true),
            divider(),
            // ───── รายการสินค้า/บริการ ─────
            ...List.generate(
              TransReBillHistory.length,
              (index) {
                final bill = TransReBillHistory[index];
                return itemRow(
                    itemName(bill), getFormattedText('${bill.total}'));
              },
            ),
            divider(),
            // ───── สรุปยอด ─────
            // itemRow('รวมราคาสินค้า/Sub Total', nFormat.format(totalPvat)),
            // if (totalVat != 0.00)
            //   itemRow('ภาษีมูลค่าเพิ่ม/Vat', nFormat.format(totalVat)),
            // if (totalWht != 0.00)
            //   itemRow('หัก ณ ที่จ่าย', nFormat.format(totalWht)),
            // if (totalFee != 0.00)
            //   itemRow('ค่าธรรมเนียม', nFormat.format(totalFee)),
            // if (totalDis != 0.00)
            //   itemRow('ส่วนลด/Discount', nFormat.format(totalDis)),
            // if (totalMatjum != 0.00)
            //   itemRow('เงินมัดจำ(ตัดมัดจำ)', nFormat.format(totalMatjum)),
            // if (totalPakan != 0.00)
            //   itemRow(
            //       'เงินประกัน(ตัดเงินประกัน)', nFormat.format(totalPakan)),
            // ───── รวมเป็นเงินทั้งสิ้น ─────
            itemRow1('รวมเป็นเงินทั้งสิ้น', nFormat.format(totalBill),
                bold: true),
            // divider(),
            // pw.Center(
            //     child: tCenter('(~${convertToThaiBaht(totalBill)}~)',
            //         bold: true)),
            divider(),
            // ───── รูปแบบการชำระ ─────
            // tLeft('รูปแบบชำระ', bold: true),
            // for (var i = 0; i < finnancetransModels.length; i++)
            //   if (finnancetransModels[i].dtype.toString() != 'FTA')
            //     tLeft(
            //       (finnancetransModels[i].dtype.toString() == 'KP')
            //           ? (finnancetransModels[i].type.toString() == 'CASH')
            //               ? '${i + 1}.เงินสด : ${nFormat.format(double.parse(finnancetransModels[i].amt!.toString()))} บาท'
            //               : '${i + 1}.เงินโอน : ${nFormat.format(double.parse(finnancetransModels[i].amt!.toString()))} บาท'
            //           : '${i + 1}.${finnancetransModels[i].remark} : ${nFormat.format(double.parse(finnancetransModels[i].amt!.toString()))} บาท',
            //     ),
            // if (Con_remark != null && Con_remark.toString().trim() != '')
            //   tLeft('# หมายเหตุ : $Con_remark'),

            // ───── ท้ายเอกสาร ─────
            pw.SizedBox(height: 6),
            pw.Center(
                child: tCenter('Thank you', bold: true, size: font_Size + 3)),
            pw.SizedBox(height: 6),
          ],
        ),
      ];
    }

    // ── รูปแบบหน้า : กว้าง 80mm คงที่ / สูง = h ──
    PdfPageFormat _fmt(double h) =>
        PdfPageFormat(80.0 * PdfPageFormat.mm, h).copyWith(
          marginLeft: 16,
          marginRight: 16,
          marginTop: 16,
          marginBottom: 16,
        );

    // ── นับจำนวนหน้าจริงเมื่อกำหนดความสูง = h (render ลองแล้วนับ) ──
    Future<int> countPages(double h) async {
      final probe = pw.Document();
      probe.addPage(pw.MultiPage(
        pageFormat: _fmt(h),
        maxPages: 100000, // กัน exception ระหว่างลองความสูงน้อยๆ
        build: (context) => buildContent(),
      ));
      await probe.save();
      return probe.document.pdfPageList.pages.length;
    }

    // ── หา "ความสูงพอดีเป๊ะ" = ความสูงต่ำสุดที่เนื้อหายังจบใน 1 หน้า ──
    //    (ความยาว = เท่าข้อมูลจริง ไม่เผื่อ ไม่แบ่งหน้า)
    double _lo = 60.0; // ต่ำกว่าความสูงเนื้อหาจริงแน่ๆ
    double _hi = 300.0 +
        (TransReBillHistory.length + finnancetransModels.length) *
            (font_Size * 1.9);
    int _guard = 0;
    while (await countPages(_hi) > 1 && _guard < 16) {
      _lo = _hi;
      _hi *= 1.5;
      _guard++;
    }
    // binary search: หาความสูงต่ำสุดที่ยังจบใน 1 หน้า
    for (int i = 0; i < 12; i++) {
      final double _mid = (_lo + _hi) / 2;
      if (await countPages(_mid) <= 1) {
        _hi = _mid;
      } else {
        _lo = _mid;
      }
    }
    final double _posH = _hi + 1.5; // เผื่อ sub-pixel กันหลุดไปหน้า 2

    pdf.addPage(
      pw.MultiPage(
        pageFormat: _fmt(_posH),
        maxPages: 100000,
        build: (context) => buildContent(),
      ),
    );

    ///////----------------------------------------->
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
}
