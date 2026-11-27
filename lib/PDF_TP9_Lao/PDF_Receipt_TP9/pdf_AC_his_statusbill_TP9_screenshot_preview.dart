import 'package:chaoperty_user/loadAndCacheImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';

import '../../Man_PDF/Man_Pay_Receipt_PDF.dart';
import '../../Man_PDF/Preview_PDF/PreviewPdfgen_Billsplay.dart';
import '../../Model/trans_re_bill_history_model.dart';

/// เวอร์ชัน "render ด้วย Flutter widget จริง แล้วแคปเป็นรูปฝังลง PDF",
/// ของ [Pdfgen_his_statusbill_TP9_Lao.exportPDF_statusbill_TP9_Lao]
/// ทำเป็นไฟล์แยกต่างหาก ไม่แก้ของเดิม เรียกใช้แทนที่ได้ในจุดที่ต้องการพรีวิว
/// ด้วยฟอนต์ที่ไม่มีทางเพี้ยน (widget เดียวกับที่ผู้ใช้เห็นบนจอ)
///
/// ผังเส้นขอบ (สี/ตำแหน่ง) ก๊อปมาจาก UI เดิมทุกจุดตาม
/// lib/PDF_TP9_Lao/PDF_Receipt_TP9/pdf_AC_his_statusbill_TP9.dart (ห้ามแก้ของเดิม)
/// แค่แปลงจาก pw.* (พีดีเอฟ) เป็น Flutter widget จริงเพื่อ capture เป็นรูป
class Pdfgen_his_statusbill_TP9_Lao_ScreenshotPreview {
  static Future<void> exportPDF_statusbill_TP9_Lao_ScreenshotPreview(
      List<TransReBillHistoryModel> transReBillHistory,
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
      Con_remark) async {
    final String? selectedMode =
        await ManPay_Receipt_PDF.showPageFormatDialog(context as BuildContext);
    if (selectedMode == null) return; // ผู้ใช้กด Cancel → หยุดทันที

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptTP9LaoScreenshotPreviewPage(
          transReBillHistory: transReBillHistory,
          selectedMode: selectedMode,
          Cust_no: Cust_no,
          cid_s: cid_s,
          Zone_s: Zone_s,
          Ln_s: Ln_s,
          fname: fname,
          sname: sname,
          cname: cname,
          addr: addr,
          tax: tax,
          bill_addr: bill_addr,
          bill_email: bill_email,
          bill_tel: bill_tel,
          bill_tax: bill_tax,
          bill_name: bill_name,
          numinvoice: numinvoice,
          numdoctax: numdoctax,
          ref_invoice: ref_invoice,
          finnancetransModels: finnancetransModels,
          date_Transaction: date_Transaction,
          dayfinpay: dayfinpay,
          type_bills: type_bills,
          TitleType_Default_Receipt_Name: TitleType_Default_Receipt_Name,
          sum_disamt: sum_disamt,
          sum_fee: sum_fee,
          dis_sum_Matjum: dis_sum_Matjum,
          dis_sum_Pakan: dis_sum_Pakan,
          com_ment: com_ment,
          Con_remark: Con_remark,
        ),
      ),
    );
  }
}

class ReceiptTP9LaoScreenshotPreviewPage extends StatefulWidget {
  final List<TransReBillHistoryModel> transReBillHistory;
  final String selectedMode;
  final dynamic Cust_no;
  final dynamic cid_s;
  final dynamic Zone_s;
  final dynamic Ln_s;
  final dynamic fname;
  final dynamic sname;
  final dynamic cname;
  final dynamic addr;
  final dynamic tax;
  final dynamic bill_addr;
  final dynamic bill_email;
  final dynamic bill_tel;
  final dynamic bill_tax;
  final dynamic bill_name;
  final dynamic numinvoice;
  final dynamic numdoctax;
  final List ref_invoice;
  final List finnancetransModels;
  final dynamic date_Transaction;
  final dynamic dayfinpay;
  final dynamic type_bills;
  final dynamic TitleType_Default_Receipt_Name;
  final dynamic sum_disamt;
  final dynamic sum_fee;
  final dynamic dis_sum_Matjum;
  final dynamic dis_sum_Pakan;
  final dynamic com_ment;
  final dynamic Con_remark;

  const ReceiptTP9LaoScreenshotPreviewPage({
    Key? key,
    required this.transReBillHistory,
    required this.selectedMode,
    required this.Cust_no,
    required this.cid_s,
    required this.Zone_s,
    required this.Ln_s,
    required this.fname,
    required this.sname,
    required this.cname,
    required this.addr,
    required this.tax,
    required this.bill_addr,
    required this.bill_email,
    required this.bill_tel,
    required this.bill_tax,
    required this.bill_name,
    required this.numinvoice,
    required this.numdoctax,
    required this.ref_invoice,
    required this.finnancetransModels,
    required this.date_Transaction,
    required this.dayfinpay,
    required this.type_bills,
    required this.TitleType_Default_Receipt_Name,
    required this.sum_disamt,
    required this.sum_fee,
    required this.dis_sum_Matjum,
    required this.dis_sum_Pakan,
    required this.com_ment,
    required this.Con_remark,
  }) : super(key: key);

  @override
  State<ReceiptTP9LaoScreenshotPreviewPage> createState() =>
      _ReceiptTP9LaoScreenshotPreviewPageState();
}

class _ReceiptTP9LaoScreenshotPreviewPageState
    extends State<ReceiptTP9LaoScreenshotPreviewPage> {
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

  // ── Error / empty-data phase ────────────────────────────────────────────────
  String? _errorMessage;

  Uint8List? _logoBytes;

  // ขนาดหน้าเท่าของเดิม A4 + margin 8pt (เท่ากับ pdf_BillingNote_IV_TP9_screenshot_preview.dart)
  static const double _a4W = 595.28;
  static const double _a4H = 841.89;
  static const double _margin = 8.0;
  static const double _fs = 7.0;

  // สีเส้นขอบ ตรงตาม PdfColors ของไฟล์ต้นฉบับ pdf_AC_his_statusbill_TP9.dart:
  // grey600 ใช้เป็นสีหลักของกรอบ, grey800 ใช้เฉพาะเส้นล่างกล่อง "ผู้ขาย/ประเภท"
  // (เป็นสีคนละเฉดกับ grey600 จริงๆ ในต้นฉบับ — ห้ามรวมเป็นเฉดเดียวกัน)
  static final Color _grey600 = Colors.grey.shade600;
  static final Color _grey800 = Colors.grey.shade600;
  static const Color _greyPlain = Colors.grey;

  static const String _laoFamily = 'NotoSansLaoTP9Receipt';
  TextStyle get _ts =>
      TextStyle(fontFamily: _laoFamily, fontSize: _fs, color: Colors.black);
  // ตามแพทเทิร์นเดียวกับไฟล์ billing note: ใช้ตัวธรรมดาแบบเดียวกันทั้งไฟล์ ไม่มีตัวหนา
  TextStyle get _tsBold => _ts;

  NumberFormat get _nFormat => NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.transReBillHistory.isEmpty) {
      setState(() => _errorMessage = 'ไม่พบข้อมูลรายการสำหรับสร้างเอกสาร');
      return;
    }
    try {
      final fontLoader = FontLoader(_laoFamily)
        ..addFont(rootBundle.load('fonts/NotoSansLao-Regular.ttf'));
      await fontLoader.load();

      _logoBytes = await getResizedLogo();

      if (!mounted) return;
      _allBlocks = _buildAllBlocks();
      _blockKeys = List.generate(_allBlocks.length, (_) => GlobalKey());
      setState(() => _measuring = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndPack());
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'เกิดข้อผิดพลาดขณะโหลดข้อมูล: $e');
    }
  }

  void _measureAndPack() {
    try {
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

      if (_pageBlocks.isEmpty) {
        throw Exception('ไม่สามารถจัดหน้าเอกสารได้');
      }

      _pageControllers =
          List.generate(_pageBlocks.length, (_) => ScreenshotController());

      setState(() {
        _measuring = false;
        _screenshotReady = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _capturePages());
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _measuring = false;
        _errorMessage = 'เกิดข้อผิดพลาดขณะจัดหน้าเอกสาร: $e';
      });
    }
  }

  Future<void> _capturePages() async {
    try {
      final pdf = pw.Document();
      var capturedAny = false;
      for (final ctrl in _pageControllers) {
        final img = await ctrl.capture(pixelRatio: 2.0);
        if (img == null) continue;
        capturedAny = true;
        pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (ctx) => pw.Image(pw.MemoryImage(img), fit: pw.BoxFit.fill),
        ));
      }
      if (!capturedAny) {
        throw Exception('ไม่สามารถสร้างภาพเอกสารได้');
      }
      if (!mounted) return;
      final title = (widget.numdoctax.toString() == '')
          ? 'ໃບຮັບເງິນ ${widget.numinvoice}'
          : 'ໃບຮັບເງິນ/ໃບເກັບພາສີ ${widget.numdoctax}';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PreviewPdfgen_Billsplay(
            selectedMode: widget.selectedMode,
            doc: pdf,
            title: title,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _screenshotReady = false;
        _errorMessage = 'เกิดข้อผิดพลาดขณะสร้างเอกสาร: $e';
      });
    }
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

  double _totalByField(String? Function(TransReBillHistoryModel item) getter) {
    return widget.transReBillHistory.fold(0.0, (sum, item) {
      final value = double.tryParse(getter(item) ?? '0.00') ?? 0.00;
      return sum + value;
    });
  }

  double get _totalPvat => _totalByField((e) => e.pvat);
  double get _totalVat => _totalByField((e) => e.vat);
  double get _totalWht => _totalByField((e) => e.wht);
  double get _totalLine => _totalByField((e) => e.total);
  double get _totalDis => double.tryParse(widget.sum_disamt.toString()) ?? 0.00;
  double get _totalFee => double.tryParse(widget.sum_fee.toString()) ?? 0.00;
  double get _totalMatjum =>
      double.tryParse(widget.dis_sum_Matjum.toString()) ?? 0.00;
  double get _totalPakan =>
      double.tryParse(widget.dis_sum_Pakan.toString()) ?? 0.00;

  double get _totalBill =>
      ((_totalLine + _totalFee) - _totalDis) - (_totalMatjum + _totalPakan);

  bool get _hasNonCash => widget.finnancetransModels.any((t) =>
      t.type.toString() != 'CASH' &&
      t.type != null &&
      t.dtype.toString() != 'FTA');
  bool get _hasCash => widget.finnancetransModels
      .any((t) => t.type.toString() == 'CASH' && t.dtype.toString() != 'FTA');
  bool get _refBlank =>
      widget.finnancetransModels.any((t) => t.ref1.toString().trim() == '');
  bool get _hasQrTransferPtser6 =>
      widget.finnancetransModels.any((t) => t.ptser.toString().trim() == '6');

  // ── Header (พิมพ์ซ้ำทุกหน้า / ต่อเนื่องกับเนื้อหาถ้าเป็น POS) ────────────────────
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
        const SizedBox(width: 2.83),
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
      const SizedBox(height: 5.83),
    ]);
  }

  // ── หัวตารางรายการสินค้า ─────────────────────────────────────────────────────
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

  Widget _buildTableRow(int index, TransReBillHistoryModel item) {
    final eleTySpecial = item.ele_ty.toString() != '0' && item.ele_ty != null;
    final priceText = eleTySpecial
        ? 'ອັດຕາພິເສດ'
        : (item.dtype.toString() == 'KU' ? _fmt(item.pri) : '-');
    final pvatOriginalNonZero =
        (double.tryParse(item.pvat_original.toString()) ?? 0) != 0;
    final amountText = pvatOriginalNonZero
        ? _fmt(item.pvat_original)
        : (item.dtype.toString() == 'KU' ? _fmt(item.amt) : _fmt(item.pri));
    final descText = item.unitser.toString() == '6'
        ? '${item.expname} [ ຫນ່ວຍງານທີ່ໃຊ້ ${item.ovalue}-${item.nvalue} ]'
        : '${item.expname}';

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
          _tableCell(_safe(item.refno), flex: 2, align: TextAlign.left),
          _tableCell(descText, flex: 4, align: TextAlign.left),
          _tableCell(_fmt(item.qty), flex: 1),
          _tableCell(priceText, flex: 1),
          _tableCell(amountText, flex: 1),
          _tableCell(_fmt(item.dis_list), flex: 1),
          _tableCell(_fmt(item.total), flex: 2, showRightBorder: true),
        ],
      ),
    );
  }

  // ── Totals summary row ─────────────────────────────────────────────────────
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

  // ── Footer (พิมพ์ซ้ำทุกหน้า) ── หมายเหตุ + ลงชื่อผู้จัดการ/ผู้รับเงิน ─────────
  Widget _buildFooter({int pageNo = 1, int pageCount = 1}) {
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
                  _hasNonCash
                      ? '( / ) 1. ໂອນເງິນ, QR Code, Mobile Banking '
                      : '(   ) 1. ໂອນເງິນ, QR Code, Mobile Banking ',
                  style: _tsBold,
                ),
                Text(
                  _hasNonCash
                      ? '      ບັນຊີ ${widget.finnancetransModels.where((m) => m.dtype == 'KP' && m.ptser != null && m.ptser != '1').map((m) => m.bank).join(', ')} ເລກບັນຊີ ${widget.finnancetransModels.where((m) => m.dtype == 'KP' && m.ptser != null && m.ptser != '1').map((m) => m.bno).join(', ')} [ ${widget.finnancetransModels.where((m) => m.dtype == 'KP' && m.ptser != null && m.ptser != '1').map((m) => (m.ptname.toString() == 'Online Payment' ? 'PromptPay QR' : m.ptname == 'เงินโอน' ? 'ເລກບັນຊີ' : m.ptname == 'Beam Checkout' ? 'Beam Checkout' : 'Online Standard QR')).join(', ')} ]'
                      : '      ບັນຊີ...................................ເລກບັນຊີ...................................',
                  style: _tsBold,
                ),
                if (_hasQrTransferPtser6)
                  Text(
                    _refBlank
                        ? '      ( Ref1. ${widget.finnancetransModels.where((m) => m.dtype == 'KP' && m.ptser != null && m.ptser != '1').map((m) => m.inv.toString().replaceAll('-', '')).join(', ')} Ref2. ${(widget.dayfinpay == null || widget.dayfinpay.toString() == '') ? '' : '${DateFormat('ddMM').format(DateTime.parse(widget.dayfinpay))}${DateTime.parse('${widget.dayfinpay}').year + 543}'} )'
                        : '      ( Ref1. ${widget.finnancetransModels.where((m) => m.dtype == 'KP' && m.ptser != null && m.ptser != '1').map((m) => m.ref1).join(', ')} Ref2. ${(widget.dayfinpay == null || widget.dayfinpay.toString() == '') ? '' : '${DateFormat('ddMM').format(DateTime.parse(widget.dayfinpay))}${DateTime.parse('${widget.dayfinpay}').year + 543}'} )',
                    style: _tsBold,
                  ),
                Row(children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      _hasCash ? '( / ) 2. ເງິນສົດ' : '(   ) 2. ເງິນສົດ',
                      style: _tsBold,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      (_hasNonCash || _hasCash)
                          ? '(   ) 3. ອື່ນໆ.............................'
                          : '( / ) 3. ອື່ນໆ ${widget.finnancetransModels.where((m) => m.ptser != '6' || m.ptser != '5' || m.ptser != '2' || m.ptser != '1' && m.dtype == 'KP').map((m) => m.bank).join(', ')}',
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

  // ── All content blocks (แบ่งหน้าได้เมื่อไม่ใช่ POS) ─────────────────────────
  List<Widget> _buildAllBlocks() {
    final titleName = widget.TitleType_Default_Receipt_Name;
    final hasTitle = titleName != null &&
        titleName.toString().trim() != '' &&
        titleName.toString() != 'ไม่ระบุ';
    final noDocTax = widget.numdoctax.toString() == '';
    final titleLao = !hasTitle
        ? (noDocTax ? 'ໃບຮັບເງິນ' : 'ໃບຮັບເງິນ/ໃບເກັບພາສີ')
        : noDocTax
            ? (titleName.toString() == 'ต้นฉบับ'
                ? 'ໃບຮັບເງິນ [ ຕົ້ນສະບັບ ]'
                : titleName.toString() == 'คู่ฉบับ'
                    ? 'ໃບຮັບເງິນ [ ຊໍ້າກັນ ]'
                    : titleName.toString() == 'สำเนาคู่ฉบับ'
                        ? 'ໃບຮັບເງິນ [ ສຳເນົາຊໍ້າກັນ ]'
                        : 'ໃບຮັບເງິນ [ ສຳເນົາ ]')
            : (titleName.toString() == 'ต้นฉบับ'
                ? 'ໃບຮັບເງິນ/ໃບເກັບພາສີ [ ຕົ້ນສະບັບ ]'
                : titleName.toString() == 'คู่ฉบับ'
                    ? 'ໃບຮັບເງິນ/ໃບເກັບພາສີ [ ຊໍ້າກັນ ]'
                    : titleName.toString() == 'สำเนาคู่ฉบับ'
                        ? 'ໃບຮັບເງິນ/ໃບເກັບພາສີ [ ສຳເນົາຊໍ້າກັນ ]'
                        : 'ໃບຮັບເງິນ/ໃບເກັບພາສີ [ ສຳເນົາ ]');
    final titleEn = !hasTitle
        ? (noDocTax ? 'Receipt' : 'Receipt/Tax Invoice')
        : noDocTax
            ? (titleName.toString() == 'ต้นฉบับ'
                ? 'Receipt Original'
                : titleName.toString() == 'คู่ฉบับ'
                    ? 'Receipt Duplicate'
                    : titleName.toString() == 'สำเนาคู่ฉบับ'
                        ? 'Receipt Duplicate Copy'
                        : 'Receipt Copy')
            : (titleName.toString() == 'ต้นฉบับ'
                ? 'Receipt/Tax Receipt Original'
                : titleName.toString() == 'คู่ฉบับ'
                    ? 'Receipt/Tax Receipt Duplicate'
                    : titleName.toString() == 'สำเนาคู่ฉบับ'
                        ? 'Receipt/Tax Receipt Duplicate Copy'
                        : 'Receipt/Tax Invoice Copy');

    final refLen = widget.ref_invoice.length;
    // ต้นฉบับ: outer Container กับ inner (กล่องข้อมูลลูกค้า) ใช้สูตรความสูงไม่เท่ากัน
    // (100 vs 115 ตอน ref_invoice.length อยู่ระหว่าง 2-5) — คงไว้ตามต้นฉบับ
    final outerTopBoxH = refLen > 5 ? 112.0 : (refLen > 1 ? 100.0 : 85.0);
    final innerCustomerBoxH = refLen > 5 ? 112.0 : (refLen > 1 ? 115.0 : 85.0);
    final dateOrderBoxH = refLen > 5 ? 70.0 : (refLen > 1 ? 50.0 : 40.0);

    final blocks = <Widget>[];

    // ── Block: ข้อมูลลูกค้า + หัวเรื่องใบเสร็จ/วันที่/เลขที่ ───────────────────
    blocks.add(SizedBox(
      height: outerTopBoxH,
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
          flex: 3,
          child: Container(
            height: innerCustomerBoxH,
            decoration: BoxDecoration(border: Border.all(color: _grey600)),
            padding: const EdgeInsets.fromLTRB(2, 4, 2, 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (widget.cname != null &&
                          widget.cname.toString().trim().isNotEmpty &&
                          widget.cname.toString() != 'null' &&
                          widget.cname.toString() != '-')
                      ? 'ຊື່ລູກຄ້າ /Name : ${widget.cname}'
                      : (widget.sname != null &&
                              widget.sname.toString().trim().isNotEmpty &&
                              widget.sname.toString() != 'null' &&
                              widget.sname.toString() != '-')
                          ? 'ຊື່ລູກຄ້າ /Name : ${widget.sname}'
                          : 'ຊື່ລູກຄ້າ /Name : -',
                  style: _tsBold,
                ),
                Text(
                  (widget.addr == null ||
                          widget.addr.toString() == '' ||
                          widget.addr.toString() == 'null')
                      ? 'ທີ່ຢູ່  /Address : -'
                      : 'ທີ່ຢູ່  /Address  : ${widget.addr}',
                  style: _tsBold,
                ),
                Text(
                  (widget.tax == null ||
                          widget.tax.toString() == '' ||
                          widget.tax.toString() == 'null')
                      ? 'ໝາຍເລກຜູ້ເສຍພາສີ /Tax : 0'
                      : 'ໝາຍເລກຜູ້ເສຍພາສີ /Tax : ${widget.tax}',
                  style: _tsBold,
                ),
                Text('ໝາຍເລກສັນຍາ /No. : ${widget.cid_s} ', style: _tsBold),
                Text(
                    'ເຂດ /Zone : ${widget.Zone_s} (ພື້ນທີ່ /Area  : ${widget.Ln_s})',
                    style: _tsBold),
                Text('ຫມາຍເຫດ /Note : ${widget.com_ment} ', style: _tsBold),
                if (refLen > 1)
                  Text(
                      'ອ້າງອີງ No./Refer no. : ${widget.ref_invoice.toSet().map((m) => m).join(', ')}',
                      style: _tsBold),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ต้นฉบับห่อกล่องนี้ด้วย pw.Expanded(flex:1) ให้ยืดเต็มพื้นที่ที่เหลือ
            // ของ Column (มากกว่าความสูงตายตัว 40/20/10 ที่ประกาศไว้เฉยๆ)
            Expanded(
              child: Container(
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
                    Text(titleLao,
                        textAlign: TextAlign.center,
                        style: _tsBold.copyWith(fontSize: 8)),
                    Text(titleEn,
                        textAlign: TextAlign.center,
                        style: _tsBold.copyWith(fontSize: 8)),
                  ],
                ),
              ),
            ),
            Row(children: [
              Expanded(
                child: Container(
                  height: dateOrderBoxH,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: _grey600),
                      // top: BorderSide(color: _grey600),
                      bottom: BorderSide(color: _grey600),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('ວັນທີ',
                          textAlign: TextAlign.center, style: _tsBold),
                      Text('Date', textAlign: TextAlign.center, style: _tsBold),
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
              Expanded(
                child: Container(
                  height: dateOrderBoxH,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: _grey600),
                      // top: BorderSide(color: _grey600),
                      bottom: BorderSide(color: _grey600),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('ຄໍາສັ່ງເລກທີ',
                          textAlign: TextAlign.center, style: _tsBold),
                      Text('Order no.',
                          textAlign: TextAlign.center, style: _tsBold),
                      Text(
                        noDocTax
                            ? '${widget.numinvoice} '
                            : '${widget.numdoctax} ',
                        textAlign: TextAlign.center,
                        style: _tsBold,
                      ),
                    ],
                  ),
                ),
              ),
              if (refLen == 1 &&
                  widget.ref_invoice[0].toString().trim().isNotEmpty)
                Expanded(
                  child: Container(
                    height: dateOrderBoxH,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: _grey600),
                        // top: BorderSide(color: _grey600),
                        bottom: BorderSide(color: _grey600),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('ອ້າງອີງ No.',
                            textAlign: TextAlign.center, style: _tsBold),
                        Text('Refer no.',
                            textAlign: TextAlign.center, style: _tsBold),
                        Text(' ${widget.ref_invoice[0]}',
                            textAlign: TextAlign.center, style: _tsBold),
                      ],
                    ),
                  ),
                ),
            ]),
          ]),
        ),
      ]),
    ));

    // ── Block: ผู้ขาย / ประเภท / รหัส + วันที่จ่ายเงิน ───────────────────────
    blocks.add(SizedBox(
      height: 35,
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: _grey600),
                // bottom: BorderSide(color: _grey600),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: _grey600),
                        // bottom: BorderSide(color: _grey800),
                      ),
                    ),
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('ຜູ້ຂາຍ No. /Sales man No.',
                            textAlign: TextAlign.center, style: _tsBold),
                        Text(_safe(widget.fname),
                            textAlign: TextAlign.center, style: _tsBold),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                        // border: Border(bottom: BorderSide(color: _grey800)),
                        ),
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('ປະເພດ /Type.',
                            textAlign: TextAlign.center, style: _tsBold),
                        Text(
                          (widget.type_bills.toString().trim() == '' ||
                                  widget.type_bills == null)
                              ? 'ສັນຍາ'
                              : 'ປລັກສຽບ',
                          textAlign: TextAlign.center,
                          style: _tsBold,
                        ),
                      ],
                    ),
                  ),
                ),
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
                        Text('ລະຫັດ /Code',
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('ວັນທີຈ່າຍເງິນ /Payment Date',
                    textAlign: TextAlign.center, style: _tsBold),
                Text(
                  (widget.dayfinpay == null ||
                          widget.dayfinpay.toString() == '' ||
                          widget.dayfinpay.toString() == 'null')
                      ? '-'
                      : '${DateFormat('dd/MM').format(DateTime.parse(widget.dayfinpay))}/${DateTime.parse('${widget.dayfinpay}').year}',
                  textAlign: TextAlign.center,
                  style: _tsBold,
                ),
              ],
            ),
          ),
        ),
      ]),
    ));

    // ── Block: หัวตาราง ──────────────────────────────────────────────────────
    blocks.add(_buildTableHeader());

    // ── Block: แต่ละแถวสินค้า ────────────────────────────────────────────────
    for (int i = 0; i < widget.transReBillHistory.length; i++) {
      blocks.add(_buildTableRow(i, widget.transReBillHistory[i]));
    }

    // ── Block: สรุปยอด ───────────────────────────────────────────────────────
    blocks.add(Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _grey600)),
      ),
      alignment: Alignment.centerRight,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.Con_remark.toString() != '' && widget.Con_remark != null)
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text('# ຫມາຍເຫດ : ${widget.Con_remark}', style: _tsBold),
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
              _summaryRow('ລວມ / Sub Total', _nFormat.format(_totalPvat)),
              _summaryRow('ອາກອນມູນຄ່າ / Vat', _nFormat.format(_totalVat)),
              _summaryRow(
                  'ຫັກຢູ່ບ່ອນຈ່າຍ / Withholding ', _nFormat.format(_totalWht)),
              _summaryRow('ຄ່າທຳນຽມ / Fees', _nFormat.format(_totalFee)),
              _summaryRow(
                  'ທັງໝົດ / Total',
                  _nFormat.format(
                      ((_totalPvat + _totalVat) - _totalWht) + _totalFee)),
              _summaryRow('ສ່ວນຫຼຸດ  / Discount', _nFormat.format(_totalDis)),
              _summaryRow('ຈໍານວນການຈ່າຍເງິນ  / Payment Amount',
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
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('ย้อนกลับ'),
                ),
              ],
            ),
          ),
        ),
      );
    }
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
