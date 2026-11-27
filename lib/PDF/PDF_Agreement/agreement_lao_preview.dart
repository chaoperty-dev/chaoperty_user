import 'package:chaoperty_user/LaoBaht.dart';
import 'package:chaoperty_user/loadAndCacheImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import '../../Man_PDF/Preview_PDF/Preview_Agreement.dart';
import '../../Model/GetC_Quot_Select_Model.dart';

class AgreementLaoPreviewPage extends StatefulWidget {
  final dynamic context0;
  final dynamic Get_Value_cid;
  final dynamic Get_Value_NameShop_index;
  final dynamic verticalGroupValue;
  final dynamic Form_nameshop;
  final dynamic Form_typeshop;
  final dynamic Form_bussshop;
  final dynamic Form_bussscontact;
  final dynamic Form_address;
  final dynamic Form_areaaddrx;
  final dynamic Form_tel;
  final dynamic Form_email;
  final dynamic Form_tax;
  final dynamic Form_ln;
  final dynamic Form_zn;
  final dynamic Form_area;
  final dynamic Form_qty;
  final dynamic Form_sdate;
  final dynamic Form_ldate;
  final dynamic Form_period;
  final dynamic Form_rtname;
  final List<QuotxSelectModel> quotxSelectModels;
  final dynamic TransModels;
  final dynamic renTal_name;
  final dynamic bill_addr;
  final dynamic bill_email;
  final dynamic bill_tel;
  final dynamic bill_tax;
  final dynamic bill_name;
  final dynamic newValuePDFimg;
  final dynamic tableData00;
  final dynamic TitleType_Default_Receipt_Name;
  final dynamic Datex_text;
  final dynamic FormName1_choice;
  final dynamic FormName2_choice;
  final dynamic FormName3_choice;
  final dynamic FormName4_choice;

  const AgreementLaoPreviewPage({
    Key? key,
    required this.context0,
    required this.Get_Value_cid,
    required this.Get_Value_NameShop_index,
    required this.verticalGroupValue,
    required this.Form_nameshop,
    required this.Form_typeshop,
    required this.Form_bussshop,
    required this.Form_bussscontact,
    required this.Form_address,
    required this.Form_areaaddrx,
    required this.Form_tel,
    required this.Form_email,
    required this.Form_tax,
    required this.Form_ln,
    required this.Form_zn,
    required this.Form_area,
    required this.Form_qty,
    required this.Form_sdate,
    required this.Form_ldate,
    required this.Form_period,
    required this.Form_rtname,
    required this.quotxSelectModels,
    required this.TransModels,
    required this.renTal_name,
    required this.bill_addr,
    required this.bill_email,
    required this.bill_tel,
    required this.bill_tax,
    required this.bill_name,
    required this.newValuePDFimg,
    required this.tableData00,
    required this.TitleType_Default_Receipt_Name,
    required this.Datex_text,
    required this.FormName1_choice,
    required this.FormName2_choice,
    required this.FormName3_choice,
    required this.FormName4_choice,
  }) : super(key: key);

  @override
  State<AgreementLaoPreviewPage> createState() =>
      _AgreementLaoPreviewPageState();
}

class _AgreementLaoPreviewPageState extends State<AgreementLaoPreviewPage> {
  // ── Measure phase ──────────────────────────────────────────────────────────
  final GlobalKey _headerKey = GlobalKey();
  List<GlobalKey> _blockKeys = [];
  List<Widget> _allBlocks = [];
  bool _measuring = false;
  // indices that must always start a new page
  final Set<int> _forceBreakBefore = {};

  // ── Screenshot phase ────────────────────────────────────────────────────────
  bool _screenshotReady = false;
  List<ScreenshotController> _pageControllers = [];
  List<List<Widget>> _pageBlocks = [];

  static Uint8List? _logoMemCache;

  Uint8List? _logoBytes;

  static const double _a4W = 595.0;
  static const double _a4H = 842.0;
  static const double _margin = 18.0;
  static const double _fs = 8.0;
  static const double _fsBold = 8.0;

  static const String _laoFamily = 'NotoSansLao';
  TextStyle get _ts =>
      TextStyle(fontFamily: _laoFamily, fontSize: _fs, color: Colors.black);
  TextStyle get _tsBold =>
      TextStyle(fontFamily: _laoFamily, fontSize: _fsBold, color: Colors.black);
  TextStyle get _tsTitle =>
      TextStyle(fontFamily: _laoFamily, fontSize: 10, color: Colors.black);

  @override
  void initState() {
    super.initState();
    _loadLogoThenBuild();
  }

  Future<void> _loadLogoThenBuild() async {
    final fontLoader = FontLoader(_laoFamily)
      ..addFont(rootBundle.load('fonts/NotoSansLao.ttf'));
    await fontLoader.load();
    _logoMemCache ??= await getResizedLogo();
    _logoBytes = _logoMemCache;
    if (!mounted) return;
    widget.quotxSelectModels.sort((QuotxSelectModel a, QuotxSelectModel b) {
      final exptserA = int.tryParse(a.exptser ?? '0') ?? 0;
      final exptserB = int.tryParse(b.exptser ?? '0') ?? 0;
      if (exptserA != exptserB) return exptserA.compareTo(exptserB);
      final nameA = (a.expname ?? '').replaceAll(RegExp(r'[^ก-๙a-zA-Z]'), '');
      final nameB = (b.expname ?? '').replaceAll(RegExp(r'[^ก-๙a-zA-Z]'), '');
      return nameA.compareTo(nameB);
    });
    _allBlocks = _buildAllBlocks();
    // signatures block is always last — force it onto a new page
    _forceBreakBefore.add(_allBlocks.length - 1);
    _blockKeys = List.generate(_allBlocks.length, (_) => GlobalKey());
    setState(() => _measuring = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndPack());
    });
  }

  void _measureAndPack() {
    final headerRO =
        _headerKey.currentContext?.findRenderObject() as RenderBox?;
    final headerH = headerRO?.size.height ?? 80.0;
    final usableH = _a4H - 2 * _margin - headerH;

    final heights = _blockKeys.map((key) {
      final ro = key.currentContext?.findRenderObject() as RenderBox?;
      return ro?.size.height ?? 0.0;
    }).toList();

    // Greedy pack blocks into A4 pages
    _pageBlocks = [];
    var current = <Widget>[];
    var accumulated = 0.0;
    for (int i = 0; i < _allBlocks.length; i++) {
      final h = heights[i];
      final forcedBreak = _forceBreakBefore.contains(i);
      if (current.isNotEmpty && (forcedBreak || accumulated + h > usableH)) {
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
        builder: (_) => RentalInforman_Agreement(
          doc: pdf,
          Get_Value_cid: widget.Get_Value_cid?.toString(),
          title: 'ສັນຍາເຊົ່າພື້ນທີ່',
          filePrefix: 'ສັນຍາເຊົ່າ',
        ),
      ),
    );
  }

  String _safe(dynamic v, {String fallback = '-'}) {
    final s = v?.toString() ?? '';
    return s.isEmpty ? fallback : s;
  }

  String _toUnitLao(dynamic v) {
    final s = v?.toString() ?? '';
    if (s == 'รายวัน') return 'ລາຍວັນ';
    if (s == 'รายเดือน') return 'ລາຍເດືອນ';
    if (s == 'รายปี') return 'ລາຍປີ';
    return s;
  }

  String _rtname() => _toUnitLao(widget.Form_rtname);

  String _expname(String? n) => (n ?? '').replaceAll('ค่าปรับ', 'ຄ່າປັບໄໝ');

  NumberFormat get _nf => NumberFormat('#,##0.00', 'en_US');

  double get _total_ {
    double t = 0;
    for (final m in widget.quotxSelectModels) {
      if (m.amt_ty != null && m.amt_ty!.isNotEmpty) {
        t += double.tryParse(m.totals?.toString() ?? '0') ?? 0;
      } else {
        t += (int.tryParse(m.term ?? '0') ?? 0) *
            (double.tryParse(m.total ?? '0') ?? 0);
      }
    }
    return t;
  }

  double get _total1 {
    double t = 0;
    for (final m in widget.quotxSelectModels) {
      if (m.amt_ty != null && m.amt_ty!.isNotEmpty) {
        final vals =
            m.amt_ty!.split(',').map((v) => double.tryParse(v) ?? 0).toSet();
        for (final v in vals) t += v;
      } else {
        t += double.tryParse(m.total?.toString() ?? '0') ?? 0;
      }
    }
    return t;
  }

  // ─── Header widget ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      child: Text(_safe(widget.bill_name),
                          style: _ts.copyWith(fontSize: 7),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_safe(widget.bill_name),
                      style: _tsBold,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text(_safe(widget.bill_addr), style: _ts, maxLines: 2),
                  Text('ເລກປະຈຳຕົວຜູ້ເສຍພາສີ : ${_safe(widget.bill_tax)}',
                      style: _ts, maxLines: 1),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.TitleType_Default_Receipt_Name != null &&
                      widget.TitleType_Default_Receipt_Name.toString().trim() !=
                          '')
                    Text('[ ${widget.TitleType_Default_Receipt_Name} ]',
                        style: TextStyle(
                            fontFamily: _laoFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        textAlign: TextAlign.right),
                  Text('ໂທລະສັບ : ${_safe(widget.bill_tel)}',
                      style: _ts, textAlign: TextAlign.right, maxLines: 1),
                  Text('ອີເມວ : ${_safe(widget.bill_email)}',
                      style: _ts, textAlign: TextAlign.right, maxLines: 1),
                  Text('ວັນທີ່ເຮັດສັນຍາ :${widget.Datex_text?.text ?? ''}',
                      style: _ts, textAlign: TextAlign.right, maxLines: 2),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Divider(height: 1, color: Colors.black),
        const SizedBox(height: 6),
      ],
    );
  }

  // ─── Underline row ──────────────────────────────────────────────────────────
  Widget _uRow(String label, String value, {int flex = 1}) {
    return Row(
      children: [
        Text(label, style: _ts),
        Expanded(
          flex: flex,
          child: Container(
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.black, width: 0.5))),
            child: Text(value,
                style: _tsBold, textAlign: TextAlign.center, maxLines: 2),
          ),
        ),
      ],
    );
  }

  // ─── Table cell ───────────────────────────────────────────────────────────0──
  Widget _tc(String text,
      {int flex = 1, Color? bg, TextAlign align = TextAlign.center}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 22,
        decoration: BoxDecoration(
          color: bg,
          border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 0.5)),
        ),
        alignment:
            align == TextAlign.right ? Alignment.centerRight : Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(text,
            style: _ts,
            textAlign: align,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _tcFixed(String text, {double width = 28, Color? bg}) {
    return Container(
      width: width,
      height: 22,
      decoration: BoxDecoration(
        color: bg,
        border:
            Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      alignment: Alignment.center,
      child: Text(text, style: _ts, textAlign: TextAlign.center),
    );
  }

  // ─── Table rows ─────────────────────────────────────────────────────────────
  List<Widget> _buildTableRows() {
    final rows = <Widget>[];
    int rowNo = 1;

    for (final model in widget.quotxSelectModels) {
      final bool hasAmtTy = model.amt_ty != null && model.amt_ty!.isNotEmpty;

      if (!hasAmtTy) {
        final dateStr = (model.sdate == null || model.ldate == null)
            ? '00-00-0000'
            : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${model.sdate} 00:00:00'))}'
                ' - ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${model.ldate} 00:00:00'))}';
        rows.add(Row(children: [
          _tcFixed('${rowNo++}'),
          _tc(_expname(model.expname), flex: 2, bg: Colors.grey[100]),
          _tc(dateStr, flex: 2),
          _tc('${_toUnitLao(model.unit)} / ${_safe(model.term)} (ງວດ)',
              flex: 2, bg: Colors.grey[100]),
          _tc(model.qty == null
              ? '0.00'
              : _nf.format(double.tryParse(model.qty ?? '0') ?? 0)),
          _tc(
              model.total == null
                  ? '0.00'
                  : _nf.format(double.tryParse(model.total ?? '0') ?? 0),
              bg: Colors.grey[100]),
          _tc(
            model.total == null || model.term == null
                ? '0.00'
                : _nf.format((int.tryParse(model.term ?? '0') ?? 0) *
                    (double.tryParse(model.total ?? '0') ?? 0)),
            align: TextAlign.right,
          ),
        ]));
      } else {
        final rawList = model.amt_ty!.split(',');
        final List<double> groupedAmt = [];
        final List<int> groupedCount = [];
        double? current;
        int count = 0;
        double sum = 0;
        for (final v in rawList) {
          final val = double.tryParse(v) ?? 0;
          if (current == null) {
            current = val;
            sum = val;
            count = 1;
          } else if (val == current) {
            sum += val;
            count++;
          } else {
            groupedAmt.add(sum);
            groupedCount.add(count);
            current = val;
            sum = val;
            count = 1;
          }
        }
        if (current != null) {
          groupedAmt.add(sum);
          groupedCount.add(count);
        }

        int termStart = 1;
        DateTime currentStartDate = DateTime.parse('${model.sdate} 00:00:00');
        final unitserValue = int.tryParse(model.unitser ?? '0') ?? 0;

        for (int i = 0; i < groupedAmt.length; i++) {
          final double amt = groupedAmt[i];
          final int cnt = groupedCount[i];
          final int termEnd = termStart + cnt - 1;
          final String termText =
              termStart == termEnd ? '$termStart' : '$termStart-$termEnd';
          termStart = termEnd + 1;

          final DateTime dateStart = currentStartDate;
          DateTime dateEnd;
          final bool isLast = (i == groupedAmt.length - 1);
          if (isLast) {
            dateEnd = DateTime.parse('${model.ldate} 00:00:00');
          } else if (unitserValue == 1) {
            dateEnd =
                DateTime(dateStart.year + cnt, dateStart.month, dateStart.day)
                    .subtract(const Duration(days: 1));
          } else if (unitserValue == 2) {
            int nm = dateStart.month + cnt;
            int ny = dateStart.year;
            while (nm > 12) {
              nm -= 12;
              ny++;
            }
            dateEnd = DateTime(ny, nm, dateStart.day)
                .subtract(const Duration(days: 1));
          } else if (unitserValue == 3) {
            dateEnd = dateStart.add(Duration(days: 7 * cnt - 1));
          } else {
            dateEnd = dateStart.add(Duration(days: cnt - 1));
          }
          currentStartDate = dateEnd.add(const Duration(days: 1));

          final dateStr =
              '${DateFormat('dd-MM-yyyy').format(dateStart)} - ${DateFormat('dd-MM-yyyy').format(dateEnd)}';

          rows.add(Row(children: [
            _tcFixed('${rowNo++}'),
            _tc(_expname(model.expname), flex: 2, bg: Colors.grey[100]),
            _tc(dateStr, flex: 2),
            _tc('${_toUnitLao(model.unit)} / $termText (ງວດ)',
                flex: 2, bg: Colors.grey[100]),
            _tc(_nf.format(double.tryParse(model.qty ?? '0') ?? 0)),
            _tc(_nf.format(amt / cnt), bg: Colors.grey[100]),
            _tc(_nf.format(amt), align: TextAlign.right),
          ]));
        }
      }
    }
    return rows;
  }

  // ─── All content blocks (no header) ────────────────────────────────────────
  List<Widget> _buildAllBlocks() {
    final t1 = _total1;
    final t_ = _total_;
    final b = const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 0.5)));
    Widget ub(String label, String value) => _uRow(label, value);

    String sigName(dynamic v) => (v == null || v.toString().isEmpty)
        ? '(___________________________)'
        : '( $v )';

    return [
      // Title + contract number
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Text('ສັນຍາເຊົ່າພື້ນທີ່', style: _tsTitle)),
        const SizedBox(height: 2),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 200,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                  'ເລກທີ່ສັນຍາ.........${_safe(widget.Get_Value_cid)}................',
                  style: _ts,
                  textAlign: TextAlign.right),
              Text('ເຮັດທີ່ ${_safe(widget.bill_name)}',
                  style: _ts, textAlign: TextAlign.right),
            ]),
          ),
        ),
        const SizedBox(height: 8),
      ]),

      // Lessor
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('ສັນຍາສະບັບນີ້ເຮັດຂຶ້ນລະຫວ່າງ', style: _ts),
          Expanded(
              child: Container(
                  decoration: b,
                  child: Text(_safe(widget.bill_name),
                      style: _tsBold, textAlign: TextAlign.center))),
        ]),
        const SizedBox(height: 3),
        ub('ທີ່ຢູ່ ', _safe(widget.bill_addr)),
        const SizedBox(height: 3),
      ]),

      // Lessee
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('ເຊິ່ງຕໍ່ໄປໃນສັນຍານີ້ເອີ້ນວ່າ "ຜູ້ໃຫ້ເຊົ່າ" ຝ່າຍໜຶ່ງກັບ',
              style: _ts),
          Expanded(
              child: Container(
                  decoration: b,
                  child: Text(_safe(widget.Form_bussshop),
                      style: _tsBold, textAlign: TextAlign.center))),
        ]),
        const SizedBox(height: 3),
        Row(children: [
          Text('ທີ່ຢູ່ ', style: _ts),
          Expanded(
              flex: 3,
              child: Container(
                  decoration: b,
                  child: Text(_safe(widget.Form_address),
                      style: _tsBold, textAlign: TextAlign.center))),
          Text(' ເລກປະຈຳຕົວຜູ້ເສຍພາສີ ', style: _ts),
          Expanded(
              child: Container(
                  decoration: b,
                  child: Text(_safe(widget.Form_tax),
                      style: _tsBold, textAlign: TextAlign.center))),
        ]),
        const SizedBox(height: 3),
        Row(children: [
          Text('ເບີໂທລະສັບ ', style: _ts),
          Expanded(
              child: Container(
                  decoration: b,
                  child: Text(_safe(widget.Form_tel),
                      style: _tsBold, textAlign: TextAlign.center))),
          Text(' Email ', style: _ts),
          Expanded(
              child: Container(
                  decoration: b,
                  child: Text(_safe(widget.Form_email),
                      style: _tsBold, textAlign: TextAlign.center))),
        ]),
        const SizedBox(height: 5),
        Text(
            '        ເຊິ່ງຕໍ່ໄປນີ້ໃນສັນຍານີ້ເອີ້ນວ່າ "ຜູ້ເຊົ່າ" ອີກຝ່າຍໜຶ່ງ  ທັງສອງຝ່າຍຕົກລົງເຮັດສັນຍາດັ່ງທີ່ມີຂໍ້ຄວາມຕໍ່ໄປນີ້',
            style: _ts),
        const SizedBox(height: 4),
      ]),

      // Art 1
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(
              'ຂໍ້ 1. ຜູ້ໃຫ້ເຊົ່າ ຕົກລົງໃຫ້ເຊົ່າ ແລະ ຜູ້ເຊົ່າຕົກລົງເຊົ່າ ພື້ນທີ່ບາງສ່ວນ ບໍລິເວນພື້ນທີ່ໂຊນ ',
              style: _ts),
          Expanded(
              child: Container(
                  decoration: b,
                  child: Text(_safe(widget.Form_zn),
                      style: _tsBold, textAlign: TextAlign.center))),
        ]),
        const SizedBox(height: 3),
        Row(children: [
          Text('ລະຫັດພື້ນທີ່ ', style: _ts),
          Expanded(
              flex: 4,
              child: Container(
                  decoration: b,
                  child: Text(_safe(widget.Form_ln),
                      style: _tsBold, textAlign: TextAlign.center))),
          Text(' ລ໋ອກ/ຫ້ອງ  ມີເນື້ອທີ່ປະມານ ', style: _ts),
          Expanded(
              child: Container(
                  decoration: b,
                  child: Text(_safe(widget.Form_area),
                      style: _tsBold, textAlign: TextAlign.center))),
          Text(' ຕາລາງແມັດ ຈຳນວນພື້ນທີ່ ', style: _ts),
          Expanded(
              child: Container(
                  decoration: b,
                  child: Text(_safe(widget.Form_qty),
                      style: _tsBold, textAlign: TextAlign.center))),
          Text(' ລ໋ອກ/ຫ້ອງ', style: _ts),
        ]),
        const SizedBox(height: 3),
        ub('ຕັ້ງຢູ່ ', _safe(widget.Form_areaaddrx)),
        const SizedBox(height: 5),
        Text('        ເຊິ່ງຕໍ່ໄປນີ້ໃນສັນຍານີ້ເອີ້ນວ່າ "ພື້ນທີ່ເຊົ່າ"',
            style: _ts),
        const SizedBox(height: 4),
      ]),

      // Art 2
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(
              'ຂໍ້ 2. ຜູ້ໃຫ້ເຊົ່າຕົກລົງໃຫ້ຜູ້ເຊົ່າ ເຊົ່າພື້ນທີ່ເຊົ່າ ມີກຳນົດອາຍຸ ',
              style: _ts),
          Expanded(
              child: Container(
                  decoration: b,
                  child: Text(_safe(widget.Form_period),
                      style: _tsBold, textAlign: TextAlign.center))),
          Text(' ${_rtname()} ', style: _ts),
          Text('ເລີ່ມຕັ້ງແຕ່ ', style: _ts),
          Expanded(
              child: Container(
                  decoration: b,
                  child: Text(_safe(widget.Form_sdate),
                      style: _tsBold, textAlign: TextAlign.center))),
          Text(' ສິ້ນສຸດ ', style: _ts),
          Expanded(
              child: Container(
                  decoration: b,
                  child: Text(_safe(widget.Form_ldate),
                      style: _tsBold, textAlign: TextAlign.center))),
        ]),
        const SizedBox(height: 3),
        Row(children: [
          Text('ໂດຍມີຈຸດປະສົງ ', style: _ts),
          Expanded(
              child: Container(
                  decoration: b,
                  child: Text(_safe(widget.Form_typeshop),
                      style: _tsBold, textAlign: TextAlign.center))),
          Text(' ໃຊ້ຊື່ທຸລະກິດ ', style: _ts),
          Expanded(
              child: Container(
                  decoration: b,
                  child: Text(
                    (widget.Form_nameshop == null ||
                            widget.Form_nameshop.toString() == 'null')
                        ? _safe(widget.Form_bussshop)
                        : _safe(widget.Form_nameshop),
                    style: _tsBold,
                    textAlign: TextAlign.center,
                  ))),
        ]),
        const SizedBox(height: 4),
      ]),

      // Art 3 heading + table header
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ຂໍ້ 3.  ຜູ້ເຊົ່າຈະຊຳລະຄ່າບໍລິການໃຫ້ຜູ້ໃຫ້ເຊົ່າ ດັ່ງນີ້',
            style: _tsBold),
        const SizedBox(height: 4),
        Container(
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black))),
          child: Row(children: [
            Container(
                width: 28, child: Center(child: Text('ລຳດັບ', style: _tsBold))),
            Expanded(
                flex: 2, child: Center(child: Text('ລາຍການ', style: _tsBold))),
            Expanded(
                flex: 2, child: Center(child: Text('ວັນທີ່', style: _tsBold))),
            Expanded(
                flex: 2,
                child:
                    Center(child: Text('ຄວາມຖີ່ / ຈຳນວນງວດ', style: _tsBold))),
            Expanded(child: Center(child: Text('ໜ່ວຍລະ', style: _tsBold))),
            Expanded(child: Center(child: Text('ຍອດ/ງວດ', style: _tsBold))),
            Expanded(child: Center(child: Text('ຍອດລວມ', style: _tsBold))),
          ]),
        ),
      ]),

      // Table rows (each row is its own block)
      ..._buildTableRows(),

      // Total + Art3 conclusion
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black))),
            height: 1),
        SizedBox(
          height: 26,
          child: Row(children: [
            Expanded(
                flex: 4,
                child: Text('ຕົວໜັງສື (~${convertToLaoBaht(t1)}~)',
                    style: _tsBold.copyWith(fontStyle: FontStyle.italic))),
            const SizedBox(width: 28),
            Expanded(
                flex: 2,
                child: Text('ຍອດລວມສຸດທິ',
                    style: _tsBold.copyWith(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center)),
            Expanded(
                flex: 3,
                child: Row(children: [
                  const Expanded(child: SizedBox()),
                  Expanded(
                      child: Text(_nf.format(t1),
                          style: _tsBold, textAlign: TextAlign.center)),
                  Expanded(
                      child: Text(_nf.format(t_),
                          style: _tsBold, textAlign: TextAlign.center)),
                ])),
          ]),
        ),
        const SizedBox(height: 5),
        Text(
            '        ໂດຍຜູ້ໃຫ້ເຊົ່າຕ້ອງໃຫ້ການບໍລິການໃນສ່ວນທີ່ເກັບຄ່າບໍລິການຢ່າງຊື່ສັດ ແລະ ໂປ່ງໃສຕາມໜ້າທີ່ຂອງຜູ້ໃຫ້ເຊົ່າ',
            style: _ts),
      ]),

      // Art 4
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        Text('ຂໍ້ 4.  ຜູ້ເຊົ່າຕົກລົງວາງເງິນປະກັນການເຊົ່າ ດັ່ງນີ້', style: _ts),
        const SizedBox(height: 3),
        Text(' ( ຫາກມີລະບຸໄວ້ໃນຂໍ້ 3 )', style: _ts),
        const SizedBox(height: 3),
        Text(
            '        ໃຫ້ແກ່ຜູ້ໃຫ້ເຊົ່າເພື່ອເປັນການປະກັນການປະຕິບັດຕາມສັນຍາເຊົ່າ ແລະ ເປັນປະກັນຄວາມເສຍຫາຍໃດໆທີ່ອາດເກີດຂຶ້ນແກ່ພື້ນທີ່ເຊົ່າ ແລະ/ຫຼືແກ່ຜູ້ໃຫ້ເຊົ່າ ເງິນປະກັນການເຊົ່ານີ້ຜູ້ໃຫ້ເຊົ່າຈະຄືນໃຫ້ແກ່ຜູ້ເຊົ່າໃນ',
            style: _tsBold),
        Text(
            'ທັນທີທີ່ສັນຍາເຊົ່າສິ້ນສຸດລົງ ໂດຍຜູ້ໃຫ້ເຊົ່າມີສິດທີ່ຈະຫັກຄ່າເຊົ່າທີ່ຄ້າງຊຳລະຢູ່ ແລະ ຫາກເງິນປະກັນການເຊົ່ານີ້ມີຈຳນວນບໍ່ພຽງພໍ ຜູ້ເຊົ່າສັນຍາວ່າຈະຊຳລະເງິນສ່ວນທີ່ຂາດ ໃຫ້ແກ່ຜູ້ໃຫ້ເຊົ່າໃນທັນທີທີ່ໄດ້ຮັບການທວງຖາມ',
            style: _tsBold),
      ]),

      // Art 5
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        Text(
            'ຂໍ້ 5.  ເມື່ອສັນຍາເຊົ່າສະບັບນີ້ສິ້ນສຸດລົງຕາມໄລຍະເວລາດັ່ງກ່າວໃນ ຂໍ້ 2. ໂດຍ ຜູ້ເຊົ່າບໍ່ໄດ້ເຄີຍມີການຜິດນັດຜິດສັນຍາໃນຂໍ້ໃດຂໍ້ໜຶ່ງມາກ່ອນ ຫາກຜູ້ເຊົ່າປະສົງຈະຂໍເຊົ່າພື້ນທີ່ເຊົ່ານີ້ຕໍ່ໄປອີກຕ້ອງດຳເນີນການແຈ້ງ ຄວາມປະສົງດັ່ງກ່າວລ່ວງໜ້າເປັນໜັງສືກ່ອນສິ້ນສຸດໄລຍະເວລາທີ່ໄດ້ລະບຸໄວ້ໃນສັນຍານີ້ ບໍ່ໜ້ອຍກວ່າ 3 ເດືອນ ເມື່ອຜູ້ໃຫ້ເຊົ່າໄດ້ຮັບໜັງສືຕາມທີ່ໄດ້',
            style: _ts),
        Text(
            'ກ່າວໄວ້ໃນວັກທຳອິດແລ້ວ ຈະດຳເນີນການຕົກລົງລາຍລະອຽດອີກຄັ້ງ ເພື່ອຈັດທຳສັນຍາເຊົ່າສະບັບໃໝ່ ໂດຍຜູ້ໃຫ້ເຊົ່າຈະຕ້ອງສະເໜີລາຄາຂອງການເຊົ່າຄັ້ງໃໝ່ໃຫ້ຜູ້ເຊົ່າກ່ອນທຸກຄັ້ງ',
            style: _ts),
      ]),

      // Art 6
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        Text(
            'ຂໍ້ 6.  ຄ່າພາສີໂຮງຮຽນ ແລະ ທີ່ດິນ ຜູ້ໃຫ້ເຊົ່າຈະເປັນຜູ້ຊຳລະເອງທັງໝົດ',
            style: _ts),
      ]),

      // Art 7
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        Text(
            'ຂໍ້ 7.  ຜູ້ໃຫ້ເຊົ່າມີໜ້າທີ່ໃນການຈັດຫາ ຫຼື ແນະນຳສະຖານທີ່ຈອດລົດ ແລະ ແນວທາງການອຳນວຍການຈາລາຈອນ ເຊິ່ງສາມາດລວມໄປຍັງລະບົບຮັກສາຄວາມປອດໄພພາຍໃນ ແລະ ພາຍນອກອາຄານ ຕະຫຼອດ 24 ຊົ່ວໂມງ',
            style: _ts),
      ]),

      // Art 8
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        Text(
            'ຂໍ້ 8.  ຜູ້ເຊົ່າມີໜ້າທີ່ໃນການດູແລຮັກສາ ແລະ ສ້ອມແປງພື້ນທີ່ເຊົ່າ ຄືກັບທີ່ຜູ້ມີສະຕິຈະພຶງສະຫງວນຮັກສາຊັບສິນຂອງຕົນເອງ ໂດຍທຶນຊັບຂອງຜູ້ເຊົ່າເອງ ເວັ້ນແຕ່ການຊຳລຸດທຸລໂທລົມທີ່ເກີດ ຂຶ້ນຕາມສະພາບ ຂອງພື້ນທີ່ເຊົ່າຈົນເຖິງຂະໜາດຕ້ອງສ້ອມແປງໃຫຍ່ ຜູ້ໃຫ້ເຊົ່າຈຶ່ງຈະເປັນຜູ້ຮັບຜິດຊອບໃນຄ່າໃຊ້ຈ່າຍສຳລັບການສ້ອມແປງນັ້ນ ຫາກຜູ້ເຊົ່າບໍ່ປະຕິບັດໜ້າທີ່ໃນການດູແລຮັກສາແລະສ້ອມແປງພື້ນທີ່ເຊົ່າຕາມວັກທຳ',
            style: _ts),
        Text(
            'ອິດແລະ ຜູ້ໃຫ້ເຊົ່າໄດ້ບອກກ່າວແລ້ວ ຜູ້ໃຫ້ເຊົ່າ ມີສິດຈັດການສ້ອມແປງເອງ ໂດຍ ຜູ້ເຊົ່າ ຕ້ອງເປັນຜູ້ອອກຄ່າໃຊ້ຈ່າຍໃນການນັ້ນທັງໝົດ',
            style: _ts),
      ]),

      // Art 9
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        Text(
            'ຂໍ້ 9.  ຜູ້ເຊົ່າ ຈະບໍ່ດຳເນີນການດັດແປງ ຕໍ່ເຕີມ ຮື້ຖອນ ຫຼື ປ່ຽນແປງ ພື້ນທີ່ເຊົ່າ ບໍ່ວ່າຈະທັງໝົດ ຫຼື ພຽງບາງສ່ວນ ເວັ້ນແຕ່ ຈະໄດ້ຮັບຄວາມຍິນຍອມເປັນໜັງສືຈາກ ຜູ້ໃຫ້ເຊົ່າກ່ອນ ຫາກຜູ້ເຊົ່າ ໄດ້ດຳເນີນການໄປ ໂດຍບໍ່ໄດ້ຮັບຄວາມຍິນຍອມ ຜູ້ໃຫ້ເຊົ່າຈະຮຽກ ໃຫ້ຜູ້ເຊົ່າເຮັດພື້ນທີ່ເຊົ່າໃຫ້ກັບສູ່ສະພາບເດີມ ລວມທັງຮຽກໃຫ້ຊົດໃຊ້ຄ່າເສຍຫາຍອັນເກີດຈາກການດັດແປງ ຕໍ່ເຕີມ ຮື້ຖອນ ຫຼື ປ່ຽນແປງນັ້ນກໍ່ໄດ້',
            style: _ts),
        Text(
            '        ບັນດາຊັບສິນ ອຸປະກອນ ຫຼື ເຄື່ອງຕົກແຕ່ງທີ່ມີລັກສະນະຕິດແໜ້ນກັບພື້ນທີ່ເຊົ່າ ທີ່ຜູ້ເຊົ່າ ຫຼື ບໍລິວານນຳມາຕິດຕັ້ງ ບໍ່ວ່າຈະໂດຍໄດ້ຮັບຄວາມຍິນຍອມຈາກ ຜູ້ໃຫ້ເຊົ່າ ຫຼືບໍ່ ໃຫ້ຕົກເປັນກຳມະສິດຂອງຜູ້ໃຫ້ເຊົ່າໃນທັນທີ ໂດຍຜູ້ໃຫ້ເຊົ່າ ບໍ່ຕ້ອງຊົດໃຊ້ລາຄາ ຫຼື ຄ່າຕອບແທນໃດໆທັງໝົດ',
            style: _ts),
      ]),

      // Art 10
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        Text(
            'ຂໍ້ 10.  ຜູ້ເຊົ່າ ຍິນຍອມໃຫ້ ຜູ້ໃຫ້ເຊົ່າ ຫຼື ຕົວແທນຂອງຜູ້ໃຫ້ເຊົ່າ ເຂົ້າກວດຕ່ວງ ພື້ນທີ່ເຊົ່າ ໄດ້ເປັນຄັ້ງຄາວ ແລະ ໃນໄລຍະເວລາທີ່ເໝາະສົມ',
            style: _ts),
      ]),

      // Art 11
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        Text(
            'ຂໍ້ 11.  ຜູ້ເຊົ່າ ຈະບໍ່ນຳພື້ນທີ່ເຊົ່າ ໄປໃຫ້ຜູ້ອື່ນເຊົ່າຊ່ວງ ຫຼື ຍິນຍອມໃຫ້ຜູ້ອື່ນໃຊ້ ພື້ນທີ່ເຊົ່າ ບໍ່ວ່າຈະໂດຍຊັດແຈ້ງ ຫຼື ໂດຍປະລິຍາຍ ເວັ້ນແຕ່ຈະໄດ້ຮັບຄວາມຍິນຍອມເປັນໜັງສືຈາກຜູ້ໃຫ້ເຊົ່າກ່ອນ',
            style: _ts),
      ]),

      // Art 12
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        Text(
            'ຂໍ້ 12.  ຜູ້ເຊົ່າ ສັນຍາວ່າຈະບໍ່ດຳເນີນການໃດໆ ທີ່ເປັນການຂັດຕໍ່ກົດໝາຍ ຫຼື ສີລະທຳອັນດີຂອງປະຊາຊົນ ຫຼື ເປັນການກໍ່ໃຫ້ເກີດຄວາມເດືອດຮ້ອນລຳຄານແກ່ບຸກຄົນອື່ນ',
            style: _ts),
      ]),

      // Art 13
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        Text(
            'ຂໍ້ 13.  ຖ້າຜູ້ເຊົ່າ ເລີກສັນຍາເຊົ່າກ່ອນຄົບກຳນົດໄລຍະເວລາຕາມສັນຍານີ້ ຫຼື ຜູ້ເຊົ່າ ຜິດນັດຜິດສັນຍາຂໍ້ໃດຂໍ້ໜຶ່ງກໍ່ຕາມ ຜູ້ໃຫ້ເຊົ່າ ມີສິດບອກເລີກສັນຍາເຊົ່າ ແລະ ດຳເນີນການຮິບເງິນປະກັນການ ເຊົ່າໄວ້ທັງໝົດ ໄດ້ທັນທີ',
            style: _ts),
      ]),

      // Art 14
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        Text(
            'ຂໍ້ 14.  ເມື່ອສັນຍາເຊົ່າໄດ້ສິ້ນສຸດລົງບໍ່ວ່າຈະໂດຍສາເຫດໃດກໍ່ຕາມ ຜູ້ເຊົ່າ ຕ້ອງຂົນຍ້າຍຊັບສິນ ແລະ ບໍລິວານອອກໄປຈາກພື້ນທີ່ເຊົ່າ ແລະ ສົ່ງມອບພື້ນທີ່ເຊົ່າຄືນໃຫ້ແກ່ຜູ້ໃຫ້ເຊົ່າໃນສະພາບທີ່ຮຽບຮ້ອຍ ພາຍໃນ ກຳນົດເວລາ 15 ວັນ ນັບແຕ່ວັນທີ່ສັນຍາສິ້ນສຸດລົງ ໂດຍ ຜູ້ເຊົ່າຈະຮຽກຮ້ອງຄ່າຂົນຍ້າຍ ຫຼື ຄ່າໃຊ້ຈ່າຍປະການໃດໆ ຈາກຜູ້ໃຫ້ເຊົ່າ ອີກບໍ່ໄດ້ ຫາກຜູ້ເຊົ່າ ບໍ່ດຳເນີນການພາຍໃນກຳນົດ ຜູ້ເຊົ່າຍິນຍອມໃຫ້ຜູ້ໃຫ້ເຊົ່າ ປັບຕາມເລດອັດຕາຄ່າເຊົ່າລາຍວັນຄູນ 2 ເທົ່າ ຈົນກວ່າຈະດຳເນີນການໄດ້ຖືກຕ້ອງຕາມສັນຍາ',
            style: _ts),
      ]),

      // Art 15
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        Text(
            'ຂໍ້ 15.  ໃນກໍລະນີທີ່ພື້ນທີ່ເຊົ່າຖືກເວນຄືນຕາມກົດໝາຍຂອງທາງລາຊະການກ່ອນຄົບກຳນົດຕາມສັນຍາເຊົ່າ ຫຼື ເກີດໄຟໄໝ້ ຫຼື ໄພພິບັດໃດໆຂຶ້ນກັບພື້ນທີ່ເຊົ່າ ຈົນເປັນເຫດໃຫ້ບໍ່ສາມາດ ໃຊ້ງານພື້ນທີ່ເຊົ່າໄດ້ ໂດຍມິໃຊ່ສາເຫດທີ່ເກີດຈາກຜູ້ເຊົ່າ ແລ້ວຄູ່ສັນຍາທັງສອງຝ່າຍຕົກລົງກັນໃຫ້ຖືວ່າສັນຍາເຊົ່າສະບັບນີ້ເປັນອັນລະງັບສິ້ນສຸດລົງ ແລະ ຕ່າງຝ່າຍຕ່າງບໍ່ຕິດໃຈຮຽກຮ້ອງຄ່າເສຍຫາຍ ປະການໃດໆຕໍ່ກັນອີກ',
            style: _ts),
      ]),

      // Art 16
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        Text(
            'ຂໍ້ 16.  ຫາກຄູ່ສັນຍາຝ່າຍໃດຝ່າຍໜຶ່ງ ຜິດນັດຜິດສັນຍາຂໍ້ໃດຂໍ້ໜຶ່ງ ຄູ່ສັນຍາອີກຝ່າຍໜຶ່ງມີສິດບອກເລີກສັນຍາໄດ້ທັນທີ ແລະ ຄູ່ສັນຍາຝ່າຍທີ່ຜິດຍິນຍອມຊົດໃຊ້ຄ່າເສຍຫາຍຕາມທີ່ເກີດ ຂຶ້ນຈິງ ນັບແຕ່ ວັນບອກເລີກສັນຍາເປັນຕົ້ນໄປ',
            style: _ts),
      ]),

      // Signatures (always forced to new page)
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Text(
          '        ສັນຍານີ້ເຮັດຂຶ້ນ 2 ສະບັບ ມີຂໍ້ຄວາມຕົງກັນ ຄູ່ສັນຍາທັງສອງຝ່າຍໄດ້ອ່ານ ແລະ ເຂົ້າໃຈຂໍ້ຄວາມໃນສັນຍາສະບັບນີ້ໂດຍຕະຫຼອດແລ້ວ ເຫັນວ່າຖືກຕ້ອງ ແລະ ຕົງຕາມຄວາມປະສົງແລ້ວ ຈຶ່ງໄດ້ລົງລາຍເຊັນໄວ້ເປັນຫຼັກຖານຕໍ່ໜ້າພະຍານ ແລະ ເກັບສັນຍາໄວ້ຝ່າຍລະສະບັບ',
          style: _ts,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 60),
        Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Text('ລົງຊື່___________________________ຜູ້ໃຫ້ເຊົ່າ    ',
                    style: _tsBold),
                const SizedBox(height: 8),
                Text(sigName(widget.FormName1_choice), style: _tsBold),
                const SizedBox(height: 8),
                Text('ວັນທີ່____/________/____', style: _tsBold),
              ])),
          const SizedBox(width: 20),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Text('ລົງຊື່___________________________ຜູ້ເຊົ່າ    ',
                    style: _tsBold),
                const SizedBox(height: 8),
                Text(sigName(widget.FormName2_choice), style: _tsBold),
                const SizedBox(height: 8),
                Text('ວັນທີ່____/________/____', style: _tsBold),
              ])),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Text('ລົງຊື່___________________________ພະຍານ    ',
                    style: _tsBold),
                const SizedBox(height: 8),
                Text(sigName(widget.FormName3_choice), style: _tsBold),
                const SizedBox(height: 8),
                Text('ວັນທີ່____/________/____', style: _tsBold),
              ])),
          const SizedBox(width: 20),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Text('ລົງຊື່___________________________ພະຍານ    ',
                    style: _tsBold),
                const SizedBox(height: 8),
                Text(sigName(widget.FormName4_choice), style: _tsBold),
                const SizedBox(height: 8),
                Text('ວັນທີ່____/________/____', style: _tsBold),
              ])),
        ]),
      ]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('ກຳລັງສ້າງເອກະສານ...', style: _ts),
        ])),

        // Phase 1: render all blocks off-screen for measurement
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
                ],
              ),
            ),
          ),

        // Phase 2: screenshot each packed page (each exactly A4 height)
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          ..._pageBlocks[p],
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
