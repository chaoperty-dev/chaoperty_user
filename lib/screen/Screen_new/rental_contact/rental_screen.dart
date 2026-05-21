import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../Constant/Myconstant.dart';
import '../../../Model/GetC_Quot_Select_Model.dart';
import '../../../Model/GetContractf_Model.dart';
import '../../../Model/GetCustomer_Model.dart';
import '../../../Model/GetInvoice_Model.dart';
import '../../../Model/GetRenTal_Model.dart';
import '../../../Model/GetTeNant_Model.dart';
import '../../../Model/GetTeNant_rental_Model.dart';
import '../../../PDF/PDF_Agreement/pdf_RentalInforma.dart';

import '../../../main.dart';
import '../../model/electricity_history_model.dart';
import '../fitness_app_home_screen.dart';
import '../fitness_app_theme.dart';

class RentalScreen extends StatefulWidget {
  const RentalScreen({Key? key, this.animationController}) : super(key: key);
  final AnimationController? animationController;

  @override
  State<RentalScreen> createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen>
    with TickerProviderStateMixin {
  // ===== Core =====
  final nFormat = NumberFormat("#,##0.00", "en_US");
  final DateTime _today = DateTime.now();
  final ScrollController _scroll = ScrollController();

  // ===== Data =====
  final List<RenTalModel> _rentalSettings = [];
  final List<CustomerModel> _customers = [];
  final List<TeNantModel> _tenants = [];
  final List<TeNantRentalModel> _tenantDetails = [];
  final List<InvoiceModel> _invoices = [];
  final List<QuotxSelectModel> _quoteItems = [];
  final List<ElectricityHistoryModel> _electricity = [];
  List<ContractfModel> Other_file = [];
  // ===== UI State =====
  String? _cusLang; // 'EN' or 'TH'
  String? _selectedCid; // current tenant (cid)
  double _topBarOpacity = 0.0;
  int _serviceOpen = 0; // 0 closed, 1 open

  // ===== TextControllers (เฉพาะที่ใช้จริง) =====
  final tNameshop = TextEditingController();
  final tTypeshop = TextEditingController();
  final tBuss = TextEditingController();
  final tContact = TextEditingController();
  final tAddr = TextEditingController();
  final tTel = TextEditingController();
  final tEmail = TextEditingController();
  final tTax = TextEditingController();
  final tWnote = TextEditingController();
  final tArea = TextEditingController();
  final tAreaCode = TextEditingController(); // ln
  final tZone = TextEditingController();
  final tQty = TextEditingController();
  final tStart = TextEditingController();
  final tEnd = TextEditingController();
  final tPeriod = TextEditingController();
  final tRtname = TextEditingController();
  final tCdate = TextEditingController();
  String? tType; // _verticalGroupValue

  // ===== Misc =====
  String? _folderDb;
  String? _receiptTitleText = 'ไม่ระบุ';

  // ===== Totals =====
  double _totalToday = 0.0;

  // ===== Anim =====
  late final AnimationController _anim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void initState() {
    super.initState();
    _init();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _anim.dispose();
    _scroll.dispose();
    // dispose text controllers
    for (final c in [
      tNameshop,
      tTypeshop,
      tBuss,
      tContact,
      tAddr,
      tTel,
      tEmail,
      tTax,
      tWnote,
      tArea,
      tAreaCode,
      tZone,
      tQty,
      tStart,
      tEnd,
      tPeriod,
      tRtname,
      tCdate,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ================== LOAD ==================
  Future<void> _init() async {
    await _loadPrefs();
    await _loadRentalSettings();
    await _loadTenants();
    await _loadInvoices();
    if (mounted) setState(() {});
    _anim.forward(from: 0);
  }

  Future<void> _loadPrefs() async {
    final sp = await SharedPreferences.getInstance();
    _cusLang = sp.getString('lang');
    final renTalSer = sp.getString('renTalSer');
    final custno = sp.getString('custno');

    // Load customer info (ชื่อผู้ใช้ ฯลฯ)
    final url =
        '${MyConstant().domain}/Gc_customer_user.php?isAdd=true&ren=$renTalSer&cusno=$custno';
    final res = await http.get(Uri.parse(url));
    final jsonList = json.decode(res.body);
    for (final m in jsonList) {
      _customers.add(CustomerModel.fromJson(m));
    }
  }

  Future<void> _loadRentalSettings() async {
    final sp = await SharedPreferences.getInstance();
    final ren = sp.getString('renTalSer');
    final url =
        '${MyConstant().domain_chao}/GC_rental_setring.php?isAdd=true&ren=$ren';
    try {
      final res = await http.get(Uri.parse(url));
      final list = json.decode(res.body);
      for (final m in list) {
        final r = RenTalModel.fromJson(m);
        _rentalSettings.add(r);
        _folderDb = r.dbn;
        _receiptTitleText = (r.receipt_title == '0')
            ? 'ไม่ระบุ'
            : (r.receipt_title == '1')
                ? 'ต้นฉบับ'
                : 'สำเนา';
      }
    } catch (_) {}
  }

  Future<void> _loadTenants() async {
    _tenants.clear();
    final sp = await SharedPreferences.getInstance();
    final ren = sp.getString('renTalSer');
    final custno = sp.getString('custno');
    final url =
        '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&custno=$custno';
    try {
      final res = await http.get(Uri.parse(url));
      final list = json.decode(res.body);
      for (final m in list) {
        final tn = TeNantModel.fromJson(m);
        final cid = tn.cid?.trim() ?? '';
        if (cid.isNotEmpty && cid.toLowerCase() != 'null') _tenants.add(tn);
      }
    } catch (_) {}
  }

  Future<void> _loadContractf(String cid) async {
    Other_file.clear();
    final sp = await SharedPreferences.getInstance();
    final ren = sp.getString('renTalSer');
    // final custno = sp.getString('custno');
    final qutser = sp.getString('qutser');

    final url =
        '${MyConstant().domain}/GC_contractf.php?isAdd=true&ren=$ren&ser_user=$qutser&namecid=$cid';
    try {
      final res = await http.get(Uri.parse(url));
      final list = json.decode(res.body);
      for (final m in list) {
        ContractfModel contractfModelss = ContractfModel.fromJson(m);
        Other_file.add(contractfModelss);
      }
    } catch (_) {}
  }

  Future<void> _loadInvoices() async {
    _invoices.clear();
    _totalToday = 0.0;

    final sp = await SharedPreferences.getInstance();
    final ren = sp.getString('renTalSer');
    final qutser = sp.getString('qutser');

    for (final tn in _tenants) {
      final url =
          '${MyConstant().domain_chao}/GC_bill_invoice.php?isAdd=true&ren=$ren&ciddoc=${tn.cid}&qutser=$qutser';
      try {
        final res = await http.get(Uri.parse(url));
        final list = json.decode(res.body);
        if (list.toString() == 'null') continue;
        for (final m in list) {
          final inv = InvoiceModel.fromJson(m);
          final amt = double.tryParse(inv.amtall ?? '0') ?? 0;
          if (inv.billdate == DateFormat('yyyy-MM-dd').format(_today)) {
            _totalToday += amt;
          }
          _invoices.add(inv);
        }
      } catch (_) {}
    }
  }

  Future<void> _loadTenantDetailAndQuote(String cid) async {
    _tenantDetails.clear();
    _quoteItems.clear();

    final sp = await SharedPreferences.getInstance();
    final ren = sp.getString('renTalSer');

    // detail
    final urlD =
        '${MyConstant().domain_chao}/GC_tenantlookAS.php?isAdd=true&ren=$ren&ciddoc=$cid&qutser=1';
    try {
      final res = await http.get(Uri.parse(urlD));
      final list = json.decode(res.body);
      for (final m in list) {
        final d = TeNantRentalModel.fromJson(m);
        _tenantDetails.add(d);
        // map -> controllers
        tNameshop.text = d.sname ?? '';
        tTypeshop.text = d.stype ?? '';
        tBuss.text = d.cname ?? '';
        tContact.text = d.attn ?? '';
        tAddr.text = d.addr ?? '';
        tTel.text = d.tel ?? '';
        tEmail.text = d.email ?? '';
        tTax.text = (d.tax == null || d.tax!.isEmpty) ? '-' : d.tax!;
        tArea.text = d.area ?? '';
        tAreaCode.text = d.area_c ?? '';
        tWnote.text = d.wnote ?? '';
        tZone.text = d.zn ?? '';
        tQty.text = d.qty ?? '';
        tRtname.text = d.rtname ?? '';
        tCdate.text = d.cdate ?? '';
        tType = d.ctype;

        if ((d.sdate ?? '').isNotEmpty) {
          tStart.text = DateFormat('dd-MM-yyyy')
              .format(DateTime.parse('${d.sdate} 00:00:00'));
        }
        if ((d.ldate ?? '').isNotEmpty) {
          tEnd.text = DateFormat('dd-MM-yyyy')
              .format(DateTime.parse('${d.ldate} 00:00:00'));
        }
        tPeriod.text = d.period ?? '';
      }
    } catch (_) {}

    // quote list
    final urlQ =
        '${MyConstant().domain_chao}/GC_quot_conx.php?isAdd=true&ren=$ren&ciddoc=$cid&qutser=1';
    try {
      final res = await http.get(Uri.parse(urlQ));
      final list = json.decode(res.body);
      if (list.toString() != 'null') {
        for (final m in list) {
          _quoteItems.add(QuotxSelectModel.fromJson(m));
        }
      }
    } catch (_) {}
  }

  // ================== UI HELPERS ==================
  void _onScroll() {
    final o = _scroll.offset;
    if (o >= 24) {
      if (_topBarOpacity != 1.0) setState(() => _topBarOpacity = 1.0);
    } else if (o <= 24 && o >= 0) {
      final v = o / 24;
      if (_topBarOpacity != v) setState(() => _topBarOpacity = v);
    } else if (o <= 0) {
      if (_topBarOpacity != 0.0) setState(() => _topBarOpacity = 0.0);
    }
  }

  bool get _hasSelectedDue => _selectedCid == null
      ? false
      : _invoices.where((e) => e.cid == _selectedCid).fold<double>(
              0, (s, e) => s + (double.tryParse(e.amtall ?? '0') ?? 0)) >
          0;

  double get _sumSelectedDue => _selectedCid == null
      ? 0
      : _invoices.where((e) => e.cid == _selectedCid).fold<double>(
          0, (s, e) => s + (double.tryParse(e.amtall ?? '0') ?? 0));

  // ===== Color logic for tenant chips =====
  _ChipColors _chipColors(TeNantModel t) {
    final active = t.quantity == '1';
    final expired = active &&
        (t.ldate?.isNotEmpty ?? false) &&
        DateTime.now().isAfter(DateTime.parse('${t.ldate} 00:00:00.000'));
    if (!active) {
      return _ChipColors(
        bg: FitnessAppTheme.notWhite,
        fg: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.8),
        bd: FitnessAppTheme.notWhite,
      );
    }
    if (expired) {
      return _ChipColors(
        bg: HexColor('#FFE5E5'),
        fg: HexColor('#B42318'),
        bd: HexColor('#FFB4B4'),
      );
    }
    return _ChipColors(
      bg: FitnessAppTheme.white,
      fg: FitnessAppTheme.nearlyDarkBlue,
      bd: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.5),
    );
  }

  // ================== BUILD ==================
  Widget getAppBarUI() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderBar(
        opacity: _topBarOpacity,
        title: (_cusLang == 'EN') ? 'Rental contracts' : 'สัญญาเช่า',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEN = _cusLang == 'EN';
    // สร้างรายการปุ่มที่ต้องการ
    final pdfItems = [
      for (int index = 0; index < Other_file.length; index++)
        {
          'en': '${Other_file[index].filename}',
          'th': '${Other_file[index].filename}',
          'onTap': _exportPdf,
        },
    ];
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scroll,
              slivers: [
                getAppBarUI(),

                // ===== Summary Today =====
                // SliverToBoxAdapter(
                //   child: _SummaryCard(
                //     title: isEN ? 'Today’s receipts' : 'ยอดรับวันนี้',
                //     amount: _totalToday,
                //     nFormat: nFormat,
                //   ),
                // ),

                // ===== Tenants Chips =====
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.only(
                      //       left: 16, right: 16, top: 16, bottom: 8),
                      //   child: Text(
                      //     isEN ? 'Tenants' : 'ผู้เช่า',
                      //     style: const TextStyle(
                      //         fontWeight: FontWeight.w800, fontSize: 16),
                      //   ),
                      // ),
                      Container(
                        height: 120,
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                            left: 12, right: 12, top: 0, bottom: 8),
                        decoration: BoxDecoration(
                          color: FitnessAppTheme.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: FitnessAppTheme.grey.withOpacity(0.2),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 10.0),
                          ],
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: _tenants.length,
                          itemBuilder: (context, index) {
                            return _buildTenantCard(index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== Empty state when not selected =====
                if (_selectedCid == null)
                  SliverToBoxAdapter(
                    child: _EmptyHint(
                      icon: Icons.assignment_outlined,
                      text: isEN
                          ? 'Select a contract to view details'
                          : 'เลือกรายการสัญญาเพื่อดูรายละเอียด',
                    ),
                  ),

                // ===== Details =====
                if (_selectedCid != null) ...[
                  // Due card
                  // if (_hasSelectedDue)
                  //   SliverToBoxAdapter(
                  //     child: _DueCard(
                  //       title: isEN ? 'Payment due' : 'เกินกำหนดชำระ',
                  //       amount: _sumSelectedDue,
                  //       nFormat: nFormat,
                  //       button: isEN ? 'Pay now' : 'ชำระเลย',
                  //       onPressed: () async {
                  //         final sp = await SharedPreferences.getInstance();
                  //         await sp.setString('usercid', _selectedCid!);
                  //         await sp.setString('payby', 'PAYCONTACT');
                  //         if (!mounted) return;
                  //         Navigator.pushAndRemoveUntil(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (_) => const FitnessAppHomeScreen(
                  //                   pageroot: 'PAYCONTACT')),
                  //           (r) => false,
                  //         );
                  //       },
                  //     ),
                  //   ),

                  // Space info
                  SliverToBoxAdapter(
                    child: _Section(
                      title: isEN ? 'Rental space' : 'พื้นที่เช่า',
                      child: _InfoTable(rows: [
                        _kv(isEN ? 'Area code' : 'รหัสพื้นที่', tAreaCode.text),
                        _kv(isEN ? 'Zone' : 'โซน', tZone.text),
                        _kv(isEN ? 'Total area (sq.m.)' : 'รวมพื้นที่ (ตร.ม.)',
                            tArea.text),
                        _kv(isEN ? 'Quantity' : 'จำนวนพื้นที่', tQty.text),
                      ]),
                    ),
                  ),

                  // Tenant info
                  SliverToBoxAdapter(
                    child: _Section(
                      title: isEN ? 'Tenant information' : 'ข้อมูลผู้เช่า',
                      child: _InfoTable(rows: [
                        _kv(
                          isEN ? 'Type' : 'ประเภท',
                          isEN
                              ? (tType == 'ส่วนตัว/บุคคลธรรมดา')
                                  ? 'Personal/Individual'
                                  : (tType == 'องค์กร/นิติบุคคล')
                                      ? 'Corporate/Legal Entity'
                                      : (tType == 'หน่วยงานราชการ')
                                          ? 'Government Agency'
                                          : tType ?? '-'
                              : tType ?? '-',
                        ),
                        _kv(isEN ? 'Store name' : 'ชื่อร้านค้า',
                            tNameshop.text),
                        _kv(isEN ? 'Store type' : 'ประเภทร้าน', tTypeshop.text),
                        _kv(isEN ? 'Company' : 'บริษัท/ผู้เช่า', tBuss.text),
                        _kv(isEN ? 'Contact person' : 'ผู้ติดต่อ',
                            tContact.text),
                        _kv(isEN ? 'Address' : 'ที่อยู่', tAddr.text,
                            multi: true),
                        _kv(isEN ? 'Phone' : 'โทร', tTel.text),
                        _kv(isEN ? 'Email' : 'อีเมล', tEmail.text),
                        _kv('ID / TAX ID', tTax.text),
                        _kv(isEN ? 'Reference no.' : 'เลขอ้างอิง',
                            tWnote.text.isEmpty ? '-' : tWnote.text),
                      ]),
                    ),
                  ),

                  // Contract info
                  SliverToBoxAdapter(
                    child: _Section(
                      title: isEN
                          ? 'Contract / Quotation'
                          : 'ข้อมูลสัญญา/เสนอราคา',
                      child: Column(
                        children: [
                          _InfoTable(rows: [
                            _kv(isEN ? 'Start' : 'เริ่ม', tStart.text),
                            _kv(isEN ? 'End' : 'สิ้นสุด', tEnd.text),
                            _kv(
                                isEN ? 'Contract period' : 'อายุสัญญา',
                                isEN
                                    ? '${tPeriod.text} lock/room'
                                    : '${tPeriod.text} ล็อก/ห้อง'),
                          ]),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _GhostButton(
                                  colors: Colors.blueGrey.shade200,
                                  icon: _serviceOpen == 1
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  text: isEN
                                      ? (_serviceOpen == 1
                                          ? 'Hide contract'
                                          : 'View all contracts')
                                      : (_serviceOpen == 1
                                          ? 'ซ่อนสัญญา'
                                          : 'ดูสัญญาทั้งหมด(${Other_file.length})'),
                                  onTap: () => setState(() =>
                                      _serviceOpen = _serviceOpen == 1 ? 0 : 1),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _GhostButton(
                                  colors: Colors.white,
                                  icon: _serviceOpen == 2
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  text: isEN
                                      ? (_serviceOpen == 2
                                          ? 'Hide service details'
                                          : 'View service details')
                                      : (_serviceOpen == 2
                                          ? 'ซ่อนรายละเอียดบริการ'
                                          : 'ดูรายละเอียดบริการ'),
                                  onTap: () => setState(() =>
                                      _serviceOpen = _serviceOpen == 2 ? 0 : 2),
                                ),
                              ),
                            ],
                          ),
                          AnimatedCrossFade(
                            crossFadeState: _serviceOpen == 1
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 250),
                            firstChild: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                children: [
                                  for (final it in pdfItems) ...[
                                    _PrimaryButton(
                                      icon: Icons.picture_as_pdf_outlined,
                                      text: isEN
                                          ? (it['en'] as String)
                                          : (it['th'] as String),
                                      onTap: it['onTap'] as VoidCallback,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ],
                              ),
                            ),
                            secondChild: const SizedBox.shrink(),
                          ),
                          AnimatedCrossFade(
                            crossFadeState: _serviceOpen == 2
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 250),
                            firstChild: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _ServiceFeeList(
                                  items: _quoteItems,
                                  isEN: isEN,
                                  nFormat: nFormat),
                            ),
                            secondChild: const SizedBox(height: 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // const SliverToBoxAdapter(child: SizedBox(height: 24)),
                const SliverToBoxAdapter(
                    child: SizedBox(
                  height: 200,
                ))
              ],
            ),

            // ===== Floating Loader when empty =====
            if (_tenants.isEmpty && _selectedCid == null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingAnimationWidget.inkDrop(
                          color: Colors.green, size: 64),
                      const SizedBox(height: 12),
                      Text(isEN ? 'Loading...' : 'กำลังโหลด...',
                          style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================== ACTIONS ==================
  Future<void> _exportPdf() async {
    if (_tenantDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            _cusLang == 'EN' ? 'Data not ready yet.' : 'ข้อมูลยังไม่พร้อม'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final imgs = <String>[];
    if (_rentalSettings.isNotEmpty &&
        (_rentalSettings.first.imglogo?.trim().isNotEmpty ?? false)) {
      imgs.add(
          '${MyConstant().domain_chao}/files/${_folderDb}/logo/${_rentalSettings.first.imglogo!.trim()}');
    }

    final sp = await SharedPreferences.getInstance();
    final renTalName = sp.getString('renTalName');
    final ciddoc = _selectedCid;
    final qutser = sp.getString('qutser');

    Pdfgen_RentalInforma.exportPDF_RentalInforma(
      context,
      qutser,
      ciddoc,
      tType,
      tNameshop.text,
      tTypeshop.text,
      tBuss.text,
      tContact.text,
      tAddr.text,
      tTel.text,
      tEmail.text,
      tTax.text,
      tAreaCode.text,
      tZone.text,
      tArea.text,
      tQty.text,
      tStart.text,
      tEnd.text,
      tPeriod.text,
      tRtname.text,
      tCdate.text,
      _quoteItems,
      const [], // เดิมส่ง _TransModels ที่ไม่ได้ใช้ ลบออก
      '$renTalName',
      ' ${_rentalSettings.isNotEmpty ? _rentalSettings.first.bill_addr : ''}',
      ' ${_rentalSettings.isNotEmpty ? _rentalSettings.first.bill_email : ''}',
      ' ${_rentalSettings.isNotEmpty ? _rentalSettings.first.bill_tel : ''}',
      ' ${_rentalSettings.isNotEmpty ? _rentalSettings.first.bill_tax : ''}',
      ' ${_rentalSettings.isNotEmpty ? _rentalSettings.first.bill_name : ''}',
      imgs,
    );
  }

  Future<void> _onTenantSelected(String cid) async {
    setState(() {
      _selectedCid = cid;
      _serviceOpen = 0;
    });
    await _loadTenantDetailAndQuote(cid);
    await _loadContractf(cid);
    if (mounted) setState(() {});
  }

  Widget _buildTenantCard(int index) {
    bool isSelected = _selectedCid == _tenants[index].cid;
    return GestureDetector(
      onTap: () async {
        _onTenantSelected(_tenants[index].cid.toString());
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? FitnessAppTheme.nearlyDarkBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
          border: isSelected
              ? null
              : Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work_rounded,
                color:
                    isSelected ? Colors.white : FitnessAppTheme.nearlyDarkBlue,
                size: 32),
            const SizedBox(height: 8),
            Text(
              '${_tenants[index].cid}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87),
            ),
            Text(
              (_cusLang == 'EN')
                  ? (_tenants[index].rtname == 'รายวัน')
                      ? 'Daily'
                      : (_tenants[index].rtname == 'รายสัปดาห์')
                          ? 'Weekly'
                          : (_tenants[index].rtname == 'รายเดือน')
                              ? 'Monthly'
                              : (_tenants[index].rtname == 'รายปี')
                                  ? 'Yearly'
                                  : '${_tenants[index].rtname ?? ""}'
                  : '${_tenants[index].rtname ?? ""}',
              style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white70 : Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ================== WIDGETS ==================

class _HeaderBar extends SliverPersistentHeaderDelegate {
  _HeaderBar({required this.opacity, required this.title});
  final double opacity;
  final String title;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: FitnessAppTheme.white.withOpacity(opacity),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: FitnessAppTheme.grey.withOpacity(0.4 * opacity),
              offset: const Offset(1.1, 1.1),
              blurRadius: 10.0),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).padding.top,
      ),
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/Icon-chao.png'),
              radius: 16,
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: FitnessAppTheme.darkerText,
                letterSpacing: 0.4,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent =>
      kToolbarHeight +
      16 +
      MediaQueryData.fromView(
              WidgetsBinding.instance.platformDispatcher.views.first)
          .padding
          .top;
  @override
  double get minExtent =>
      kToolbarHeight +
      16 +
      MediaQueryData.fromView(
              WidgetsBinding.instance.platformDispatcher.views.first)
          .padding
          .top;
  @override
  bool shouldRebuild(covariant _HeaderBar oldDelegate) =>
      oldDelegate.opacity != opacity || oldDelegate.title != title;
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: FitnessAppTheme.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
              topRight: Radius.circular(8.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: FitnessAppTheme.grey.withOpacity(0.2),
                offset: const Offset(1.1, 1.1),
                blurRadius: 10.0),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(
      {required this.title, required this.amount, required this.nFormat});
  final String title;
  final double amount;
  final NumberFormat nFormat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [HexColor('#F1F8E9'), HexColor('#E8F5E9')],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: HexColor('#CDE6C4')),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Icon(Icons.receipt_long, color: HexColor('#2E7D32')),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      color: HexColor('#2E7D32'), fontWeight: FontWeight.w700)),
            ),
            Text(nFormat.format(amount),
                style: TextStyle(
                  color: HexColor('#2E7D32'),
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                )),
            const SizedBox(width: 6),
            Text('฿', style: TextStyle(color: HexColor('#2E7D32'))),
          ],
        ),
      ),
    );
  }
}

class _DueCard extends StatelessWidget {
  const _DueCard({
    required this.title,
    required this.amount,
    required this.nFormat,
    required this.button,
    required this.onPressed,
  });
  final String title;
  final double amount;
  final NumberFormat nFormat;
  final String button;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        color: HexColor('#FFF1F1'),
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: HexColor('#FFCCCC')),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: HexColor('#B42318')),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: HexColor('#B42318'),
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('${nFormat.format(amount)} ฿',
                        style: TextStyle(
                          color: HexColor('#B42318'),
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        )),
                  ],
                ),
              ),
              _PrimaryButton(
                text: button,
                icon: Icons.play_arrow,
                dense: true,
                onTap: onPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTable extends StatelessWidget {
  const _InfoTable({required this.rows});
  final List<_KV> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rows
          .map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: e.multi
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      child: Text(e.k,
                          style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.v.isEmpty ? '-' : e.v,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _ServiceFeeList extends StatelessWidget {
  const _ServiceFeeList(
      {required this.items, required this.isEN, required this.nFormat});
  final List<QuotxSelectModel> items;
  final bool isEN;
  final NumberFormat nFormat;

  @override
  Widget build(BuildContext context) {
    final filtered = items.where((e) => e.etype != 'F').toList();
    if (filtered.isEmpty) {
      return _EmptyHint(
        icon: Icons.receipt_long_outlined,
        text: isEN ? 'No data found' : 'ไม่พบข้อมูล',
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            color: HexColor('#F7F7F7'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _head(isEN ? 'Period' : 'งวด'),
                _head(isEN ? 'Item' : 'รายการ'),
                _head(isEN ? 'Total/period' : 'ยอด/งวด', end: true),
                _head(isEN ? 'Sum' : 'ยอด', end: true),
              ],
            ),
          ),
          if (filtered.isEmpty) ...[
            _EmptyHint(
              icon: Icons.receipt_long_outlined,
              text: isEN ? 'No data found' : 'ไม่พบข้อมูล',
            )
          ] else
            ...filtered.map((q) {
              final total = double.tryParse(q.total ?? '0') ?? 0;
              final term = int.tryParse(q.term ?? '0') ?? 0;
              return Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    _cell(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            isEN
                                ? (q.unit == 'รายปี')
                                    ? 'Yearly'
                                    : (q.unit == 'รายเดือน')
                                        ? 'Monthly'
                                        : (q.unit == 'รายสัปดาห์')
                                            ? 'Weekly'
                                            : (q.unit == 'รายวัน')
                                                ? 'Daily'
                                                : (q.unit == 'ครั้งเดียว')
                                                    ? 'One-time'
                                                    : (q.unit == 'มิเตอร์')
                                                        ? 'Meter'
                                                        : (q.unit == 'ไม่มี')
                                                            ? 'None'
                                                            : (q.unit ==
                                                                    'เหมาจ่าย')
                                                                ? 'Lump sum'
                                                                : '${q.unit}'
                                : '${q.unit}',
                            style: const TextStyle(fontSize: 14)),
                        Text(isEN ? '${q.term} (period)' : '${q.term} (งวด)',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                      ],
                    )),
                    _cell(Text('${q.expname}',
                        style: const TextStyle(fontSize: 14))),
                    _cell(Text(nFormat.format(total), textAlign: TextAlign.end),
                        end: true),
                    _cell(
                        Text(nFormat.format(term * total),
                            textAlign: TextAlign.end),
                        end: true),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _head(String t, {bool end = false}) => Expanded(
        child: Text(t,
            textAlign: end ? TextAlign.end : TextAlign.start,
            style: const TextStyle(fontWeight: FontWeight.w800)),
      );
  Widget _cell(Widget child, {bool end = false}) => Expanded(
        child: Align(
          alignment: end ? Alignment.centerRight : Alignment.centerLeft,
          child: child,
        ),
      );
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        decoration: BoxDecoration(
          color: HexColor('#F8FAFC'),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HexColor('#E2E8F0')),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Row(
          children: [
            Icon(icon, color: HexColor('#64748B')),
            const SizedBox(width: 12),
            Expanded(
                child: Text(text,
                    style: TextStyle(
                        color: HexColor('#475569'),
                        fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton(
      {required this.text, this.icon, this.onTap, this.dense = false});
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HexColor('#C4BC85'),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 12, vertical: dense ? 8 : 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.black87, size: dense ? 18 : 20),
                const SizedBox(width: 6),
              ],
              Text(text,
                  style: const TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  _GhostButton(
      {required this.text, this.icon, this.onTap, required this.colors});
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color colors;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: HexColor('#DADADA')),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.black87, size: 20),
                const SizedBox(width: 6),
              ],
              Text(text,
                  style: const TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== MODELS FOR UI HELPERS ==================
class _ChipColors {
  final Color bg, fg, bd;
  _ChipColors({required this.bg, required this.fg, required this.bd});
}

class _KV {
  final String k;
  final String v;
  final bool multi;
  _KV(this.k, this.v, {this.multi = false});
}

_KV _kv(String k, String v, {bool multi = false}) => _KV(k, v, multi: multi);
