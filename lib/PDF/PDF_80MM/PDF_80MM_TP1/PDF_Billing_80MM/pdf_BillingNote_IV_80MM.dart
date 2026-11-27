import 'package:chaoperty_user/Constant/Myconstant.dart';
import 'package:chaoperty_user/File_s.dart';
import 'package:chaoperty_user/Man_PDF/Preview_PDF/PreviewPdfgen_Bills_INV.dart';
import 'package:chaoperty_user/Model/GetInvoice_history_Model.dart';
import 'package:chaoperty_user/PDF/pdf_constants.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Pdfgen_BillingNoteInvlice_80MM {
  //////////---------------------------------------------------->(บิลเงินสด กระดาษ 80 mm)
  // เทมเพลตแบบใบเสร็จ POS 80 mm : แสดงเฉพาะ 2 คอลัมน์ => รายการ / รวม
  static void exportPDF_BillingNoteInvlice_80MM({
    required List<InvoiceHistoryModel> invoiceHistoryModels,
    required foder,
    required Cust_no,
    required cid_,
    required Zone_s,
    required Ln_s,
    required lncode,
    required fname,
    required tableData003,
    required context,
    required Num_cid,
    required Namenew,
    required SubTotal,
    required Vat,
    required Deduct,
    required Sum_SubTotal,
    required DisC,
    required Total,
    required renTal_name,
    required sname_,
    required addr_,
    required tel_,
    required email_,
    required tax_,
    required cname_,
    required bill_addr,
    required bill_email,
    required bill_tel,
    required bill_tax,
    required bill_name,
    required newValuePDFimg,
    required cFinn,
    required date_Transaction,
    required paymentName1,
    required paymentName2,
    required selectedValue_bank_bno,
    required TitleType_Default_Receipt_Name,
    required payment_Ptser1,
    required bank1,
    required ptser1,
    required ptname1,
    required img1,
    required Preview_ser,
    required End_Bill_Paydate,
    required fonts_pdf,
    required Con_remark,
    required paper,
    required paper_run,
    required sum_net_amount_pvat,
    required sum_net_non_pvat,
    required customer_name,
    required signature,
    required billingFormat,
    required remark,
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
    final DateTime printDate = DateTime.now();

    // ── ขนาดตัวอักษรสำหรับกระดาษ 80 mm ─────────────────────
    // THSarabunNew ตัวเล็กกว่า Sarabun ที่ pt เท่ากัน จึงกลับมาใช้ 13.0 ตามเดิม
    const double font_Size = 13.0;
    const double font_Title = 13.0;

    ///---------------------> โหลด signature image (ถ้ามี)
    Uint8List? signatureBytes;
    if (billingFormat == 'มี' &&
        signature != null &&
        signature.toString().isNotEmpty &&
        signature.toString() != 'null') {
      try {
        final sigRes = await http
            .get(Uri.parse('${MyConstant().domain_chao}/${signature}'));
        if (sigRes.statusCode == 200) {
          signatureBytes = sigRes.bodyBytes;
        }
      } catch (_) {
        signatureBytes = null;
      }
    }

    ///////------------------------------->
    double roundMoney(double value) {
      return (value * 100).round() / 100;
    }

    double getTotalByField(
      List<InvoiceHistoryModel> invoices,
      String? Function(InvoiceHistoryModel item) getter,
    ) {
      return invoices.fold(0.0, (sum, item) {
        return sum + (double.tryParse(getter(item) ?? '0.00') ?? 0.00);
      });
    }

    String getFormattedText(String? data) {
      return nFormat
          .format((data == null) ? 0.00 : double.tryParse(data) ?? 0.00);
    }

    // ── ยอดรวมทั้งบิล (ราคารวม - ส่วนลดท้ายบิล) ─────────────
    final double totalPrice =
        roundMoney(getTotalByField(invoiceHistoryModels, (item) => item.total));
    final double totalDis = invoiceHistoryModels.isNotEmpty
        ? roundMoney(
            double.tryParse(invoiceHistoryModels.first.disendbill ?? '0.00') ??
                0.00)
        : 0.00;
    final double totalBill = roundMoney(totalPrice - totalDis);

    // ── ชื่อรายการ (แสดงในคอลัมน์ "รายการ") ─────────────────
    String itemName(InvoiceHistoryModel inv) {
      final String name = (inv.expname != null &&
              inv.expname.toString().trim().isNotEmpty &&
              inv.expname.toString() != 'null')
          ? inv.expname.toString()
          : (inv.descr ?? '').toString();
      try {
        if (inv.unitser.toString() == '6' && inv.dtype.toString() != 'KU') {
          return '$name [ หน่วยที่ใช้ไป ${inv.ovalue}-${inv.nvalue} ]';
        }
        if (inv.date != null && inv.date.toString().trim().isNotEmpty) {
          final d = DateTime.parse(inv.date!);
          return '$name ${DateFormat('MMM', 'th').format(d)} ${d.year + 543}';
        }
      } catch (_) {}
      return name;
    }

    // ── ชื่อลูกค้า ──────────────────────────────────────────
    String custName() {
      final candidates = [customer_name, cname_, sname_, Namenew];
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

    // ── หัวเอกสาร (ชื่อร้าน / ประเภทเอกสาร / เลขที่ / วันที่) ──
    final String docTitle = (TitleType_Default_Receipt_Name != null &&
            TitleType_Default_Receipt_Name.toString().trim() != '' &&
            TitleType_Default_Receipt_Name.toString() != 'ไม่ระบุ')
        ? 'ใบวางบิล/ใบแจ้งหนี้ [ $TitleType_Default_Receipt_Name ]'
        : 'ใบวางบิล/ใบแจ้งหนี้';

    final String docDate = (date_Transaction == null ||
            date_Transaction.toString().trim() == '' ||
            date_Transaction.toString() == 'null')
        ? '-'
        : '${DateFormat('dd-MM').format(DateTime.parse(date_Transaction))}-${DateTime.parse('${date_Transaction}').year + 543}';

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
                'เลขที่ : ${(cFinn == null || cFinn.toString() == 'null') ? '-' : cFinn}'),
            tLeft('วันที่ : $docDate'),
            tLeft('นามลูกค้า : ${custName()}'),
            tLeft(
                'โซน : ${(Zone_s == null || Zone_s.toString() == 'null') ? '-' : Zone_s}   รหัสพื้นที่ : ${(Ln_s == null || Ln_s.toString() == 'null') ? '-' : Ln_s}'),
            if (fname != null &&
                fname.toString().trim().isNotEmpty &&
                fname.toString() != 'null')
              tLeft('พนักงาน : $fname'),
            if (remark != null &&
                remark.toString().trim().isNotEmpty &&
                remark.toString() != 'null')
              tLeft('หมายเหตุ/Note : $remark'),
            pw.SizedBox(height: 6),
            divider(),
            // ───── หัวตาราง : รายการ | รวม ─────
            itemRow1('รายการ', 'รวม', bold: true),
            divider(),
            // ───── รายการสินค้า/บริการ ─────
            ...List.generate(
              invoiceHistoryModels.length,
              (index) {
                final inv = invoiceHistoryModels[index];
                return itemRow(itemName(inv), getFormattedText(inv.total));
              },
            ),

            divider(),
            // ───── ยอดรวมทั้งสิ้น ─────
            itemRow1('รวมเป็นเงินทั้งสิ้น', nFormat.format(totalBill),
                bold: true),
            divider(),
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
    double _hi = 240.0 + invoiceHistoryModels.length * (font_Size * 1.9);
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
      var name_1 = 'ใบวางบิล/ใบแจ้งหนี้${cFinn}';
      // Upload the file
      await uploadFile(data, name_1);
    } else if (Preview_ser.toString() == 'File') {
      // final List<int> bytes = await pdf.save();
      // final Uint8List data = Uint8List.fromList(bytes);
      // MimeType type = MimeType.PDF;
      // final dir = await FileSaver.instance
      //     .saveFile('ใบวางบิล/ใบแจ้งหนี้${cFinn}', data, "pdf", mimeType: type);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewPdfgen_Bills(
                doc: pdf, nameBills: 'ใบวางบิล/ใบแจ้งหนี้${cFinn}'),
          ));
    }
  }
}
