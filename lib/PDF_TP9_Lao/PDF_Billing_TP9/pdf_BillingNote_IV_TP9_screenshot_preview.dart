import 'package:chaoperty_user/loadAndCacheImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../../CRC_16_Prompay/generate_qrcode.dart';
import '../../Constant/Myconstant.dart';
import '../../Man_PDF/Preview_PDF/PreviewPdfgen_Bills_INV.dart';
import '../../Model/GetInvoice_history_Model.dart';

/// เวอร์ชัน "render ด้วย Flutter widget จริง แล้วแคปเป็นรูปฝังลง PDF",
/// ของ [Pdfgen_BillingNoteInvlice_TP9_Lao.exportPDF_BillingNoteInvlice_TP9_Lao]
/// ทำเป็นไฟล์แยกต่างหาก ไม่แก้ของเดิม เรียกใช้แทนที่ได้ในจุดที่ต้องการพรีวิว
/// ด้วยฟอนต์ที่ไม่มีทางเพี้ยน (widget เดียวกับที่ผู้ใช้เห็นบนจอ)
///
/// ผังเส้นขอบ (สี/ตำแหน่ง) ก๊อปมาจาก UI เดิมทุกจุดตาม
/// lib/PDF_TP9_Lao/PDF_Billing_TP9/pdf_BillingNote_IV_TP9.dart (ห้ามแก้ของเดิม)
/// แค่แปลงจาก pw.* (พีดีเอฟ) เป็น Flutter widget จริงเพื่อ capture เป็นรูป
class Pdfgen_BillingNoteInvlice_TP9_Lao_ScreenshotPreview {
  static void exportPDF_BillingNoteInvlice_TP9_Lao_ScreenshotPreview(
      List<InvoiceHistoryModel> invoiceHistoryModels,
      foder,
      Cust_no,
      cid_,
      Zone_s,
      Ln_s,
      fname,
      tableData003,
      context,
      Num_cid,
      Namenew,
      SubTotal,
      Vat,
      Deduct,
      Sum_SubTotal,
      DisC,
      Total,
      renTal_name,
      sname_,
      addr_,
      tel_,
      email_,
      tax_,
      cname_,
      bill_addr,
      bill_email,
      bill_tel,
      bill_tax,
      bill_name,
      newValuePDFimg,
      cFinn,
      date_Transaction,
      paymentName1,
      paymentName2,
      selectedValue_bank_bno,
      TitleType_Default_Receipt_Name,
      payment_Ptser1,
      bank1,
      ptser1,
      ptname1,
      img1,
      Preview_ser,
      End_Bill_Paydate,
      fonts_pdf,
      Con_remark,
      customer_name,
      remark) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BillingNoteInvoiceTP9LaoScreenshotPreviewPage(
          invoiceHistoryModels: invoiceHistoryModels,
          foder: foder,
          Cust_no: Cust_no,
          cid_: cid_,
          Zone_s: Zone_s,
          Ln_s: Ln_s,
          fname: fname,
          Total: Total,
          bill_addr: bill_addr,
          bill_email: bill_email,
          bill_tel: bill_tel,
          bill_tax: bill_tax,
          bill_name: bill_name,
          cFinn: cFinn,
          date_Transaction: date_Transaction,
          selectedValue_bank_bno: selectedValue_bank_bno,
          TitleType_Default_Receipt_Name: TitleType_Default_Receipt_Name,
          bank1: bank1,
          ptser1: ptser1,
          ptname1: ptname1,
          img1: img1,
          End_Bill_Paydate: End_Bill_Paydate,
          Con_remark: Con_remark,
          customer_name: customer_name,
          remark: remark,
        ),
      ),
    );
  }
}

class BillingNoteInvoiceTP9LaoScreenshotPreviewPage extends StatefulWidget {
  final List<InvoiceHistoryModel> invoiceHistoryModels;
  final dynamic foder;
  final dynamic Cust_no;
  final dynamic cid_;
  final dynamic Zone_s;
  final dynamic Ln_s;
  final dynamic fname;
  final dynamic Total;
  final dynamic bill_addr;
  final dynamic bill_email;
  final dynamic bill_tel;
  final dynamic bill_tax;
  final dynamic bill_name;
  final dynamic cFinn;
  final dynamic date_Transaction;
  final dynamic selectedValue_bank_bno;
  final dynamic TitleType_Default_Receipt_Name;
  final dynamic bank1;
  final dynamic ptser1;
  final dynamic ptname1;
  final dynamic img1;
  final dynamic End_Bill_Paydate;
  final dynamic Con_remark;
  final dynamic customer_name;
  final dynamic remark;
  const BillingNoteInvoiceTP9LaoScreenshotPreviewPage({
    Key? key,
    required this.invoiceHistoryModels,
    required this.foder,
    required this.Cust_no,
    required this.cid_,
    required this.Zone_s,
    required this.Ln_s,
    required this.fname,
    required this.Total,
    required this.bill_addr,
    required this.bill_email,
    required this.bill_tel,
    required this.bill_tax,
    required this.bill_name,
    required this.cFinn,
    required this.date_Transaction,
    required this.selectedValue_bank_bno,
    required this.TitleType_Default_Receipt_Name,
    required this.bank1,
    required this.ptser1,
    required this.ptname1,
    required this.img1,
    required this.End_Bill_Paydate,
    required this.Con_remark,
    required this.customer_name,
    required this.remark,
  }) : super(key: key);

  @override
  State<BillingNoteInvoiceTP9LaoScreenshotPreviewPage> createState() =>
      _BillingNoteInvoiceTP9LaoScreenshotPreviewPageState();
}

class _BillingNoteInvoiceTP9LaoScreenshotPreviewPageState
    extends State<BillingNoteInvoiceTP9LaoScreenshotPreviewPage> {
  // ── Measure phase ──────────────────────────────────────────────────────────
  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _footerKey = GlobalKey();
  List<GlobalKey> _blockKeys = [];
  List<Widget> _allBlocks = [];
  bool _measuring = false;

  // ── Screenshot phase ────────────────────────────────────────────────────────
  bool _screenshotReady = false;
  List<ScreenshotController> _pageControllers = [];
  List<List<Widget>> _pageBlocks = [];

  Uint8List? _logoBytes;
  Uint8List? _paymentQrImage;

  // ขนาดหน้าเท่าของเดิม A4 + margin 8pt (เท่ากับ pdf.dart เดิม)
  static const double _a4W = 595.28;
  static const double _a4H = 841.89;
  static const double _margin = 8.0;
  static const double _fs = 7.0;

  // สีเส้นขอบ ใช้ตรงตาม PdfColors ของไฟล์ต้นฉบับ
  static final Color _grey600 = Colors.grey.shade600;
  static final Color _grey800 = Colors.grey.shade600;
  static const Color _greyPlain = Colors.grey;

  static const String _laoFamily = 'NotoSansLaoTP9Billing';
  TextStyle get _ts => const TextStyle(
      fontFamily: _laoFamily, fontSize: _fs, color: Colors.black);
  // ตามคำขอ: ใช้ตัวธรรมดาแบบเดียวกันทั้งไฟล์ ไม่มีตัวหนา
  TextStyle get _tsBold => _ts;

  NumberFormat get _nFormat => NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final fontLoader = FontLoader(_laoFamily)
      ..addFont(rootBundle.load('fonts/NotoSansLao-Regular.ttf'));
    await fontLoader.load();

    _logoBytes = await getResizedLogo();

    if (widget.ptser1.toString() == '2' &&
        widget.img1 != null &&
        widget.img1.toString() != '') {
      try {
        final resp = await http.get(Uri.parse(
            '${MyConstant().domain_chao_img}/files/${widget.foder}/payment/${widget.img1}'));
        if (resp.statusCode == 200) _paymentQrImage = resp.bodyBytes;
      } catch (_) {}
    }

    if (!mounted) return;
    _allBlocks = _buildAllBlocks();
    _blockKeys = List.generate(_allBlocks.length, (_) => GlobalKey());
    setState(() => _measuring = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndPack());
    });
  }

  void _measureAndPack() {
    final headerRO =
        _headerKey.currentContext?.findRenderObject() as RenderBox?;
    final headerH = headerRO?.size.height ?? 90.0;
    final footerRO =
        _footerKey.currentContext?.findRenderObject() as RenderBox?;
    final footerH = footerRO?.size.height ?? 150.0;
    final usableH = _a4H - 2 * _margin - headerH - footerH - 8;

    final heights = _blockKeys.map((key) {
      final ro = key.currentContext?.findRenderObject() as RenderBox?;
      return ro?.size.height ?? 0.0;
    }).toList();

    _pageBlocks = [];
    var current = <Widget>[];
    var accumulated = 0.0;
    for (int i = 0; i < _allBlocks.length; i++) {
      final h = heights[i];
      if (current.isNotEmpty && accumulated + h > usableH) {
        _pageBlocks.add(List.from(current));
        current = [_allBlocks[i]];
        accumulated = h;
      } else {
        current.add(_allBlocks[i]);
        accumulated += h;
      }
    }
    if (current.isNotEmpty) _pageBlocks.add(List.from(current));

    _pageControllers =
        List.generate(_pageBlocks.length, (_) => ScreenshotController());

    setState(() {
      _measuring = false;
      _screenshotReady = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _capturePages());
    });
  }

  Future<void> _capturePages() async {
    final pdf = pw.Document();
    for (final ctrl in _pageControllers) {
      final img = await ctrl.capture(pixelRatio: 2.0);
      if (img == null) continue;
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => pw.Image(pw.MemoryImage(img), fit: pw.BoxFit.fill),
      ));
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewPdfgen_Bills(
          doc: pdf,
          nameBills: 'ໃບເກັບເງິນ${widget.cFinn}',
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  String _safe(dynamic v, {String fallback = '-'}) {
    final s = v?.toString() ?? '';
    return (s.isEmpty || s == 'null') ? fallback : s;
  }

  String _fmt(String? data) {
    final value = double.tryParse(data ?? '0.00') ?? 0.00;
    return _nFormat.format(value);
  }

  double _totalByField(String? Function(InvoiceHistoryModel item) getter) {
    return widget.invoiceHistoryModels.fold(0.0, (sum, item) {
      final value = double.tryParse(getter(item) ?? '0.00') ?? 0.00;
      return sum + value;
    });
  }

  double get _totalPvat => _totalByField((item) => item.pvat);
  double get _totalVat => _totalByField((item) => item.vat);
  double get _totalWht => _totalByField((item) => item.wht);
  double get _totalDis => widget.invoiceHistoryModels.isNotEmpty
      ? double.tryParse(
              widget.invoiceHistoryModels.first.disendbill ?? '0.00') ??
          0.00
      : 0.00;
  double get _totalPrice => _totalByField((item) => item.total);
  double get _totalBill => _totalPrice - _totalDis;
  String get _totalBillQr =>
      _totalBill.toString().replaceAll(RegExp(r'[^0-9]'), '');

  int get _yearQrThai {
    try {
      return (int.tryParse(DateFormat('yyyy')
                  .format(DateTime.parse(widget.End_Bill_Paydate))) ??
              0) +
          543;
    } catch (_) {
      return 0;
    }
  }

  // ── Header (พิมพ์ซ้ำทุกหน้า) ── ตรงกับ Header(context) ในไฟล์ต้นฉบับ ───────────
  Widget _buildHeader({int pageNo = 1, int pageCount = 1}) {
    return Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _logoBytes != null
              ? Image.memory(_logoBytes!, fit: BoxFit.contain)
              : Center(
                  child: Text('${_safe(widget.bill_name)} ',
                      style: _ts.copyWith(fontSize: 10), maxLines: 1)),
        ),
        const SizedBox(width: 2.83), // 1 * PdfPageFormat.mm
        SizedBox(
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_safe(widget.bill_name)}', style: _ts, maxLines: 2),
              Text(
                (widget.bill_addr == null ||
                        widget.bill_addr.toString() == '' ||
                        widget.bill_addr.toString() == 'null')
                    ? 'ທີ່ຢູ່ : -'
                    : 'ທີ່ຢູ່ : ${widget.bill_addr}',
                style: _ts,
                maxLines: 3,
              ),
              Text(
                (widget.bill_tax == null || widget.bill_tax.toString() == '')
                    ? 'ໝາຍເລກປະຈຳຕົວຜູ້ເສຍພາສີ : 0'
                    : 'ໝາຍເລກປະຈຳຕົວຜູ້ເສຍພາສີ : ${widget.bill_tax}',
                textAlign: TextAlign.right,
                style: _ts,
              ),
              Text('ໂທລະສັບ : ${widget.bill_tel}',
                  textAlign: TextAlign.right, maxLines: 1, style: _ts),
            ],
          ),
        ),
        const Spacer(),
        Align(
          alignment: Alignment.topRight,
          child: Text('ຫນ້າ No. $pageNo / $pageCount', style: _ts),
        ),
      ]),
      const SizedBox(height: 5.83), // 1 * PdfPageFormat.mm + 3
    ]);
  }

  // ── หัวตารางรายการสินค้า ── ตรงกับส่วน 'ເລກ No.' .. 'ມູນຄ່າເງິນ Amount' ───────
  Widget _headerCellIndex() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _grey600),
          left: BorderSide(color: _grey600),
          right: BorderSide(color: _grey600),
          bottom: BorderSide(color: _grey600),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('ເລກ', maxLines: 1, style: _ts),
          Text('No.', maxLines: 1, style: _ts),
        ],
      ),
    );
  }

  Widget _headerCell(String line1, String line2,
      {required int flex, required bool hasTop}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: _grey600),
            top: hasTop ? BorderSide(color: _grey600) : BorderSide.none,
            bottom: BorderSide(color: _grey600),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(line1, maxLines: 1, style: _ts),
            Text(line2, maxLines: 1, style: _ts),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(children: [
      _headerCellIndex(),
      _headerCell('ລະຫັດຜະລິດຕະພັນ', 'Product Code', flex: 2, hasTop: true),
      _headerCell('ລາຍລະອຽດ', 'Description', flex: 4, hasTop: true),
      _headerCell('ຈຳນວນ', 'Quantity', flex: 1, hasTop: true),
      _headerCell('ໜ່ວຍ', 'Unit', flex: 1, hasTop: true),
      _headerCell('ລາຄາ', 'Price', flex: 1, hasTop: true),
      _headerCell('ສ່ວນຫຼຸດ', 'Dis', flex: 1, hasTop: true),
      _headerCell('ມູນຄ່າເງິນ', 'Amount', flex: 2, hasTop: true),
    ]);
  }

  // ── แถวรายการสินค้า ── ตรงกับ pw.Table(TableBorder(left,right,verticalInside))
  // สีเส้นขอบ grey800 ไม่มีเส้นคั่นระหว่างแถว (ตามต้นฉบับ) ────────────────────────
  Widget _tableCell(String text,
      {int flex = 1,
      TextAlign align = TextAlign.right,
      bool showRightBorder = true}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          border: Border(
            right: showRightBorder
                ? BorderSide(color: _grey800, width: 1)
                : BorderSide.none,
          ),
        ),
        alignment: align == TextAlign.right
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Text(text, style: _ts, maxLines: 2, textAlign: align),
      ),
    );
  }

  Widget _buildTableRow(int index, InvoiceHistoryModel invoice) {
    final eleTySpecial =
        invoice.ele_ty.toString() != '0' && invoice.ele_ty != null;
    final priceText = eleTySpecial
        ? 'ອັດຕາພິເສດ'
        : (invoice.dtype.toString() == 'KU' ? _fmt(invoice.pri) : '-');
    final pvatOriginalNonZero =
        (double.tryParse(invoice.pvat_original.toString()) ?? 0) != 0;
    final amountText = pvatOriginalNonZero
        ? _fmt(invoice.pvat_original)
        : (invoice.dtype.toString() == 'KU'
            ? _fmt(invoice.amt)
            : _fmt(invoice.pri));
    final descText = invoice.unitser.toString() == '6'
        ? '${invoice.expname} [ ຫນ່ວຍງານທີ່ໃຊ້ ${invoice.ovalue}-${invoice.nvalue} ]'
        : '${invoice.expname}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 30,
            padding: const EdgeInsets.all(2.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: _grey800, width: 1),
                right: BorderSide(color: _grey800, width: 1),
              ),
            ),
            child:
                Text('${index + 1}', style: _ts, textAlign: TextAlign.center),
          ),
          _tableCell(_safe(invoice.refno), flex: 2, align: TextAlign.left),
          _tableCell(descText, flex: 4, align: TextAlign.left),
          _tableCell(_fmt(invoice.qty), flex: 1),
          _tableCell(priceText, flex: 1),
          _tableCell(amountText, flex: 1),
          _tableCell(_fmt(invoice.dis_list), flex: 1),
          _tableCell(_fmt(invoice.total), flex: 2, showRightBorder: true),
        ],
      ),
    );
  }

  // ── Totals summary row ── ตรงกับกล่อง Sub Total/Vat/Withholding/... ────────
  Widget _summaryRow(String label, String value, {bool isLast = false}) {
    final cellBorder = BorderSide(color: _grey600);
    final bottomBorder = isLast ? BorderSide.none : cellBorder;
    return Row(children: [
      Expanded(
        flex: 3,
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  left: cellBorder, right: cellBorder, bottom: bottomBorder)),
          padding: const EdgeInsets.all(2.0),
          child: Text(label, style: _tsBold),
        ),
      ),
      Expanded(
        flex: 2,
        child: Container(
          decoration: BoxDecoration(
              border: Border(right: cellBorder, bottom: bottomBorder)),
          padding: const EdgeInsets.all(2.0),
          child: Text(value, style: _tsBold, textAlign: TextAlign.right),
        ),
      ),
    ]);
  }

  // ── Footer (พิมพ์ซ้ำทุกหน้า) ── ตรงกับ footer: (context) ในไฟล์ต้นฉบับ ─────────
  Widget _buildFooter({int pageNo = 1, int pageCount = 1}) {
    final ptser1 = widget.ptser1.toString();
    final isTransfer = ['2', '5', '6', '7'].contains(ptser1);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        decoration: BoxDecoration(border: Border.all(color: _greyPlain)),
        padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ຫມາຍເຫດ : ', style: _tsBold),
                Text(
                  isTransfer
                      ? '( / ) 1. ໂອນເງິນ, QR Code, Mobile Banking '
                      : '(   ) 1. ໂອນເງິນ, QR Code, Mobile Banking ',
                  style: _tsBold,
                ),
                Text(
                  isTransfer
                      ? '      ບັນຊີ ${widget.bank1} ເລກບັນຊີ ${widget.selectedValue_bank_bno} [ ${(widget.ptname1 == 'Online Payment') ? 'PromptPay QR' : (widget.ptname1 == 'เงินโอน') ? 'ເລກບັນຊີ' : (widget.ptname1 == 'Beam Checkout') ? 'Beam Checkout' : 'Online Standard QR'} ]'
                      : '      ບັນຊີ...................................ເລກບັນຊີ...................................',
                  style: _tsBold,
                ),
                Row(children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      ptser1 == '1' ? '( / ) 2. ເງິນສົດ' : '(   ) 2. ເງິນສົດ',
                      style: _tsBold,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      (isTransfer || ptser1 == '1')
                          ? '(   ) 3. ອື່ນໆ.............................'
                          : '( / ) 3. ອື່ນໆ ${widget.ptname1.toString().trim()}',
                      style: _tsBold,
                    ),
                  ),
                ]),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ເຊັນ:ຜູ້ຈັດການ', style: _tsBold),
                Text('.......................................',
                    style: _tsBold, textAlign: TextAlign.center),
                Text('(.......................................)',
                    style: _tsBold, textAlign: TextAlign.center),
                Text('ວັນທີ/Date.......................................',
                    style: _tsBold, textAlign: TextAlign.center),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ເຊັນ:ຜູ້ຮັບເງິນ', style: _tsBold),
                Text('.......................................',
                    style: _tsBold, textAlign: TextAlign.center),
                Text('(.......................................)',
                    style: _tsBold, textAlign: TextAlign.center),
                Text('ວັນທີ/Date.......................................',
                    style: _tsBold, textAlign: TextAlign.center),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ptser1 == '6')
                  QrImageView(
                    data:
                        '|${widget.selectedValue_bank_bno}\r${widget.cFinn.toString().replaceAll('-', '')}\r${DateFormat('ddMM').format(DateTime.parse(widget.End_Bill_Paydate))}$_yearQrThai\r$_totalBillQr',
                    size: 55,
                    version: QrVersions.auto,
                  ),
                if (ptser1 == '5')
                  QrImageView(
                    data: generateQRCode(
                        promptPayID: '${widget.selectedValue_bank_bno}',
                        amount: _totalBill),
                    size: 55,
                    version: QrVersions.auto,
                  ),
                if (ptser1 == '2' && _paymentQrImage != null)
                  Image.memory(_paymentQrImage!, height: 55, width: 55),
                const SizedBox(height: 2),
                Text(
                  (widget.End_Bill_Paydate == null ||
                          widget.End_Bill_Paydate.toString() == '')
                      ? 'ການຈ່າຍເງິນບໍ່ຊ້າກວ່າວັນທີ ${widget.End_Bill_Paydate} '
                      : 'ການຈ່າຍເງິນບໍ່ຊ້າກວ່າວັນທີ ${DateFormat('dd/MM').format(DateTime.parse(widget.End_Bill_Paydate))}/${DateTime.parse('${widget.End_Bill_Paydate}').year}',
                  style: _ts.copyWith(fontSize: _fs - 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ]),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text('ພິມເມື່ອ : ${DateTime.now()}',
              style: _ts.copyWith(fontSize: 7)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text('ຫນ້າ No. $pageNo / $pageCount',
              style: _ts.copyWith(fontSize: 7)),
        ),
      ]),
    ]);
  }

  // ── All content blocks (แบ่งหน้าได้) ─────────────────────────────────────────
  List<Widget> _buildAllBlocks() {
    final titleName = widget.TitleType_Default_Receipt_Name;
    final hasTitle = titleName != null &&
        titleName.toString().trim() != '' &&
        titleName.toString() != 'ไม่ระบุ';
    final titleLao = !hasTitle
        ? 'ໃບເກັບເງິນ '
        : (titleName.toString() == 'ต้นฉบับ')
            ? 'ໃບເກັບເງິນ  [ ຕົ້ນສະບັບ ]'
            : (titleName.toString() == 'คู่ฉบับ')
                ? 'ໃບເກັບເງິນ  [ ຊໍ້າກັນ ]'
                : (titleName.toString() == 'สำเนาคู่ฉบับ')
                    ? 'ໃບເກັບເງິນ  [ ສຳເນົາຊໍ້າກັນ ]'
                    : 'ໃບເກັບເງິນ  [ ສຳເນົາ ]';
    final titleEn = !hasTitle
        ? 'Invoice'
        : (titleName.toString() == 'ต้นฉบับ')
            ? 'Invoice Original'
            : (titleName.toString() == 'คู่ฉบับ')
                ? 'Invoice Duplicate'
                : (titleName.toString() == 'สำเนาคู่ฉบับ')
                    ? 'Invoice Duplicate Copy'
                    : 'Invoice Copy';

    final blocks = <Widget>[];

    // ── Block: กล่องข้อมูลลูกค้า (flex3, height 85, border 4 ด้าน grey600) +
    //           กล่องหัวเรื่องใบเก็บเงิน/วันที่/เลขที่บิล (flex2) ──────────────
    blocks.add(SizedBox(
      height: 85,
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 85,
            decoration: BoxDecoration(border: Border.all(color: _grey600)),
            padding: const EdgeInsets.fromLTRB(2, 4, 2, 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ຊື່ລູກຄ້າ /Name : ${_safe(widget.customer_name)}',
                    style: _tsBold),
                Text('ທີ່ຢູ່ /Address : -', style: _tsBold),
                Text('ໝາຍເລກຜູ້ເສຍພາສີ /Tax : 0', style: _tsBold),
                Text('ໝາຍເລກສັນຍາ /No. : ${_safe(widget.cid_)} ',
                    style: _tsBold),
                Text(
                    'ເຂດ /Zone : ${_safe(widget.Zone_s)} (ພື້ນທີ່ /Area  : ${_safe(widget.Ln_s)})',
                    style: _tsBold),
                Text('ຫມາຍ​ເຫດ​ /Note : ${_safe(widget.remark)}',
                    style: _tsBold),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(children: [
            // title box: ไม่มี left border (พึ่ง right border ของกล่องซ้าย)
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: _grey600),
                    top: BorderSide(color: _grey600),
                    // bottom: BorderSide(color: _grey600),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(titleLao,
                              textAlign: TextAlign.center,
                              style: _tsBold.copyWith(fontSize: 8)),
                          Text(titleEn,
                              textAlign: TextAlign.center,
                              style: _tsBold.copyWith(fontSize: 8)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: Row(children: [
                // Date box: right+top+bottom grey600, ไม่มี left
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: _grey600),
                        top: BorderSide(color: _grey600),
                        bottom: BorderSide(color: _grey600),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('ວັນທີເຮັດທຸລະກໍາ',
                            textAlign: TextAlign.center, style: _tsBold),
                        Text('Date',
                            textAlign: TextAlign.center, style: _tsBold),
                        Text(
                          (widget.date_Transaction == null)
                              ? '-'
                              : '${DateFormat('dd/MM').format(DateTime.parse(widget.date_Transaction))}/${DateTime.parse('${widget.date_Transaction}').year}',
                          textAlign: TextAlign.center,
                          style: _tsBold,
                        ),
                      ],
                    ),
                  ),
                ),
                // Order no. box: right+top+bottom grey600, ไม่มี left
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: _grey600),
                        top: BorderSide(color: _grey600),
                        bottom: BorderSide(color: _grey600),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('ໝາຍເລກໃບເກັບເງິນ',
                            textAlign: TextAlign.center, style: _tsBold),
                        Text('Order no.',
                            textAlign: TextAlign.center, style: _tsBold),
                        Text(_safe(widget.cFinn),
                            textAlign: TextAlign.center, style: _tsBold),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    ));

    // ── Block: พนักงานขาย / รหัสลูกค้า / กำหนดชำระ (height 35) ──────────────
    blocks.add(SizedBox(
      height: 35,
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 35,
            // wrapper: left+bottom grey600 เท่านั้น (ให้กล่องซ้ายสุดใช้เส้นนี้)
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: _grey600),
                // bottom: BorderSide(color: _grey600),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sales man: bottom เท่านั้น สี grey800 (ตามต้นฉบับ)
                Expanded(
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                        // border: Border(
                        //   bottom: BorderSide(color: _grey800)),
                        ),
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('ພະນັກງານຂາຍ /Sales man No',
                            textAlign: TextAlign.center, style: _tsBold),
                        Text(_safe(widget.fname),
                            textAlign: TextAlign.center, style: _tsBold),
                      ],
                    ),
                  ),
                ),
                // ID ลูกค้า: right+left+bottom grey600
                Expanded(
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: _grey600),
                        left: BorderSide(color: _grey600),
                        // bottom: BorderSide(color: _grey600),
                      ),
                    ),
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('ID ລູກຄ້າ /Code',
                            textAlign: TextAlign.center, style: _tsBold),
                        Text(_safe(widget.Cust_no),
                            textAlign: TextAlign.center, style: _tsBold),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // กำหนดชำระ: right+bottom grey600 เท่านั้น (ไม่มี left)
        Expanded(
          flex: 1,
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: _grey600),
                // bottom: BorderSide(color: _grey600),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: 35,
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('ຮອດກຳນົດ /Due Date',
                            textAlign: TextAlign.center, style: _tsBold),
                        Text(
                          (widget.End_Bill_Paydate == null ||
                                  widget.End_Bill_Paydate.toString() == '')
                              ? '${widget.End_Bill_Paydate}'
                              : '${DateFormat('dd/MM').format(DateTime.parse(widget.End_Bill_Paydate))}/${DateTime.parse('${widget.End_Bill_Paydate}').year}',
                          textAlign: TextAlign.center,
                          style: _tsBold,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    ));

    // ── Block: หัวตาราง ──────────────────────────────────────────────────────
    blocks.add(_buildTableHeader());

    // ── Block: แต่ละแถวสินค้า (แยกเป็น block ต่อแถว เพื่อให้ตัดหน้าได้) ──────────
    for (int i = 0; i < widget.invoiceHistoryModels.length; i++) {
      blocks.add(_buildTableRow(i, widget.invoiceHistoryModels[i]));
    }

    // ── Block: สรุปยอด (หมายเหตุ + ตารางสรุป) ────────────────────────────────
    blocks.add(Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _grey600)),
      ),
      alignment: Alignment.centerRight,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.Con_remark.toString() != '' && widget.Con_remark != null)
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text('# ຫມາຍ​ເຫດ​ : ${widget.Con_remark}', style: _tsBold),
            ),
          )
        else
          const Spacer(flex: 6),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _summaryRow(
                  'ລາຄາທັງໝົດ / Sub Total', _nFormat.format(_totalPvat)),
              _summaryRow('ອາກອນມູນຄ່າເພີ່ມ / Vat', _nFormat.format(_totalVat)),
              _summaryRow(
                  'ຫັກຢູ່ບ່ອນຈ່າຍ / Withholding ', _nFormat.format(_totalWht)),
              _summaryRow('ທັງໝົດ / Total', _nFormat.format(_totalBill)),
              _summaryRow('ສ່ວນຫຼຸດ / Discount', _nFormat.format(_totalDis)),
              _summaryRow('ຈໍານວນການຈ່າຍເງິນ / Payment Amount',
                  _nFormat.format(_totalBill),
                  isLast: true),
            ],
          ),
        ),
      ]),
    ));

    // ── Block: ยอดสุทธิรวม ───────────────────────────────────────────────────
    blocks.add(Container(
      height: 25,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _grey600),
          bottom: BorderSide(color: _grey600),
        ),
      ),
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          const Spacer(flex: 6),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ລວມທັງໝົດສຸດທິ  ', style: _tsBold),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(_nFormat.format(_totalBill), style: _tsBold),
            ]),
          ),
        ],
      ),
    ));

    return blocks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('ກຳລັງສ້າງເອກະສານ...'),
          ]),
        ),

        // Phase 1: measure (นอกจอ)
        if (_measuring)
          Positioned(
            left: -9999,
            top: 0,
            width: _a4W,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(_margin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(key: _headerKey, child: _buildHeader()),
                  for (int i = 0; i < _allBlocks.length; i++)
                    Container(key: _blockKeys[i], child: _allBlocks[i]),
                  Container(key: _footerKey, child: _buildFooter()),
                ],
              ),
            ),
          ),

        // Phase 2: screenshot ทีละหน้า (นอกจอ)
        if (_screenshotReady)
          for (int p = 0; p < _pageBlocks.length; p++)
            Positioned(
              left: -9999,
              top: 0,
              width: _a4W,
              child: Screenshot(
                controller: _pageControllers[p],
                child: SizedBox(
                  width: _a4W,
                  height: _a4H,
                  child: ClipRect(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(_margin),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          _buildHeader(
                              pageNo: p + 1, pageCount: _pageBlocks.length),
                          ..._pageBlocks[p],
                          const Spacer(),
                          _buildFooter(
                              pageNo: p + 1, pageCount: _pageBlocks.length),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ]),
    );
  }
}
