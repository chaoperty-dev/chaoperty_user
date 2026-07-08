import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../Constant/Myconstant.dart';
import '../../../Model/GetC_Quot_Select_Model.dart';
import '../../../Model/GetContractx_Model.dart';
import '../../../Model/GetRenTal_Model.dart';
import '../../../Model/GetTeNant_Model.dart';
import '../../../Model/GetTeNant_rental_Model.dart';
import '../../../Model/GetTrans_Model.dart';
import '../../../PDF/PDF_Agreement/pdf_RentalInforma.dart';
import '../../../color.dart';
import '../../../main.dart';
import '../fitness_app_theme.dart';
import '../ui_view/title_view.dart';

class MitterScreen extends StatefulWidget {
  const MitterScreen({Key? key, this.animationController}) : super(key: key);
  final AnimationController? animationController;

  @override
  State<MitterScreen> createState() => _MitterScreenState();
}

class _MitterScreenState extends State<MitterScreen>
    with TickerProviderStateMixin {
  // ===== Core =====
  final nFormat = NumberFormat("#,##0.00", "en_US");
  final ScrollController _scroll = ScrollController();

  // ===== Data =====
  final List<RenTalModel> _rentalSettings = [];
  final List<TeNantModel> _tenants = [];
  final List<TeNantRentalModel> _tenantDetails = [];
  final List<QuotxSelectModel> _quoteItems = [];
  final List<TransModel> _TransModels = [];
  final List<ContractxModel> contractx = [];

  // ===== UI State =====
  String? _cusLang; // 'EN' or 'TH'
  String? _selectedCid; // current tenant (cid)
  double _topBarOpacity = 0.0;
  int _serviceOpen = -1; // -1 closed, >=0 open at index

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

  @override
  void initState() {
    super.initState();
    _init();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
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
    setState(() {});
  }

  Future<void> _loadPrefs() async {
    final sp = await SharedPreferences.getInstance();
    _cusLang = sp.getString('lang');
    // ไม่โหลด customer ที่ไม่ใช้แล้ว
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

  Future<void> _loadExp(String cid) async {
    contractx.clear();
    final sp = await SharedPreferences.getInstance();
    final ren = sp.getString('renTalSer');
    final qutser = sp.getString('qutser');

    final url =
        '${MyConstant().domain_chao}/GC_exp_wherser.php?isAdd=true&ren=$ren&ciddoc=$cid&qutser=$qutser';
    try {
      final res = await http.get(Uri.parse(url));
      final list = json.decode(res.body);
      for (final m in list) {
        final contract = ContractxModel.fromJson(m);
        contractx.add(contract);
      }
    } catch (_) {}
  }

  Future<void> _loadTrans(
      {required String cid, required String exp, required String note}) async {
    _TransModels.clear();
    final sp = await SharedPreferences.getInstance();
    final ren = sp.getString('renTalSer');
    final qutser = sp.getString('qutser');

    final url =
        '${MyConstant().domain_chao}/GC_quotx_consx.php?isAdd=true&ren=$ren&ciddoc=$cid&qutser=$exp&_cser=$note';
    print(url);
    try {
      final res = await http.get(Uri.parse(url));
      final list = json.decode(res.body);
      for (final m in list) {
        final t = TransModel.fromJson(m);
        _TransModels.add(t);
      }
    } catch (_) {}
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
    final isEN = _cusLang == 'EN';
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderBar(
        opacity: _topBarOpacity,
        title: isEN ? 'Electric meters and water meters' : 'มิเตอร์ไฟฟ้า-น้ำ',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEN = _cusLang == 'EN';

    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scroll,
              slivers: [
                getAppBarUI(),

                // ===== Tenants Chips =====
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 16, bottom: 8),
                        child: Text(
                          isEN ? 'Tenants' : 'ผู้เช่า',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
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
                  SliverToBoxAdapter(
                    child: _Section(
                      title: isEN
                          ? 'Electric meter and water meter information'
                          : 'ข้อมูล มิเตอร์ไฟฟ้า และ มิเตอร์น้ำ',
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

                          // ปุ่มสวิทช์จาก contractx (หลายปุ่ม)
                          SizedBox(
                            height: 48, // ความสูงปุ่ม
                            child: ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              scrollDirection: Axis.horizontal,
                              itemCount: contractx.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final opened = _serviceOpen == index;
                                final titleTh = opened
                                    ? (_cusLang == 'EN')
                                        ? 'Hide service details'
                                        : 'ซ่อนรายละเอียด'
                                    : (contractx[index].expname ??
                                        '${(_cusLang == 'EN') ? 'View service details' : 'ดูรายละเอียด'}');

                                return ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      minWidth:
                                          180), // กำหนดกว้างขั้นต่ำให้กดง่าย/ไม่บี้
                                  child: _GhostButton(
                                    colors: Colors.white,
                                    icon: opened
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    text: titleTh,
                                    onTap: () async {
                                      await _loadTrans(
                                          cid: contractx[index].cid ?? "",
                                          exp: contractx[index].expser ?? "",
                                          note: contractx[index].ser ?? "");
                                      setState(() {
                                        _serviceOpen = opened
                                            ? -1
                                            : index; // toggle รายปุ่ม
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),

                          // ส่วนขยาย/ยุบ (อิง index ที่เปิดอยู่)
                          AnimatedCrossFade(
                            crossFadeState: _serviceOpen >= 0
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 250),
                            firstChild: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _ServiceFeeList(
                                items: _TransModels,
                                isEN: isEN,
                                nFormat: nFormat,
                                folder: _folderDb!,
                              ),
                            ),
                            secondChild: const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 200)),
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
                          color: Colors.indigo, size: 64),
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
      const [], // ไม่ใช้ _TransModels ใน PDF นี้
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
      _serviceOpen = -1;
    });
    await _loadTenantDetailAndQuote(cid);
    await _loadExp(cid);
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
    return Material(
      child: Container(
        decoration: BoxDecoration(
          color: FitnessAppTheme.white.withOpacity(opacity),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32.0),
          ),
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
                backgroundColor: Colors.transparent, // Image icon
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
        child: Card(
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
              padding: const EdgeInsets.only(
                  top: 16, bottom: 16, left: 16, right: 16),
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
        ));
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
  const _ServiceFeeList({
    required this.items,
    required this.isEN,
    required this.nFormat,
    required this.folder,
  });

  final List<TransModel> items;
  final bool isEN;
  final NumberFormat nFormat;
  final String folder;

  // helper: แปลงค่าอะไรก็ได้ให้เป็น num (ถ้าไม่ได้ให้ 0)
  num _asNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    final s = v.toString().trim();
    if (s.isEmpty) return 0;
    return num.tryParse(s) ?? 0;
  }

  // helper: แปลงวันที่จากสตริงให้ปลอดภัย
  DateTime? _parseDate(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    try {
      return DateTime.parse('$s 00:00:00');
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = items.where((e) => e.dtype != '!Z').toList();
    if (filtered.isEmpty) {
      return _EmptyHint(
        icon: Icons.receipt_long_outlined,
        text: isEN ? 'No items' : 'ไม่มีรายการ',
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
                _head(isEN ? 'Period' : 'เดือน'),
                _head(isEN ? 'Meter (prev.)' : 'เลขมิเตอร์ก่อน'),
                _head(isEN ? 'Meter (new)' : 'เลขมิเตอร์หลัง'),
                _head(isEN ? 'Used' : 'หน่วยที่ใช้ไป', end: true),
                _head(isEN ? 'Evidence' : 'หลักฐาน', end: true),
              ],
            ),
          ),
          ...filtered.map((t) {
            // ===== วันที่ปลอดภัย
            final d = _parseDate(t.date);
            final monthTh = (d != null)
                ? isEN
                    ? '${DateFormat.MMMM('en').format(d)} ${d.year + 0}'
                    : '${DateFormat.MMMM('th_TH').format(d)} ${d.year + 543}'
                : '-';
            // final lateNote = (t.docno_in == null || t.docno_in!.isEmpty) &&
            //         (d != null && d.isBefore(DateTime.now()))
            //     ? isEN
            //         ? ' \nOverdue/No invoice issued.'
            //         : ' \n(เลยกำหนด/ไม่มีการวางบิล)'
            //     : '';
            final periodText = '$monthTh';

            // ===== ค่าที่ใช้ไป (ต้องเป็น num เท่านั้น)
            final usedUnits = _asNum(t.nvalue.toString() == '0' ? '0' : t.qty5);

            return Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  _cell(Text(periodText, style: const TextStyle(fontSize: 14))),
                  _cell(Text('${t.ovalue ?? '-'}',
                      style: const TextStyle(fontSize: 14))),
                  _cell(Text('${t.nvalue ?? '-'}',
                      style: const TextStyle(fontSize: 14))),
                  _cell(
                    Text(nFormat.format(usedUnits), textAlign: TextAlign.end),
                    end: true,
                  ),
                  _cell(
                    InkWell(
                      onTap: (t.img == null || t.img == '')
                          ? null
                          : () async {
                              // print(folder);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  backgroundColor:
                                      AppbackgroundColor.Sub_Abg_Colors,
                                  titlePadding: const EdgeInsets.all(0.0),
                                  contentPadding: const EdgeInsets.all(10.0),
                                  actionsPadding: const EdgeInsets.all(6.0),
                                  title: Center(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Icon(Icons.highlight_off,
                                                    size: 30,
                                                    color: Colors.red[700]),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  content: Image.network(
                                    '${MyConstant().domain_chao_img}/files/$folder/meters/${t.img}',
                                    fit: BoxFit.contain,
                                    cacheWidth: 500,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(
                                            color: Colors.white),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                      child: Icon(Icons.broken_image,
                                          color: Colors.white, size: 50),
                                    ),
                                  ),
                                ),
                              );
                            },
                      child: Icon(
                        Icons.open_in_new,
                        size: 18,
                        color: (t.img == null || t.img == '')
                            ? Colors.grey
                            : Colors.blue.shade600,
                      ),
                    ),
                    end: true,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _head(String t, {bool end = false}) => Expanded(
        child: Text(
          t,
          textAlign: end ? TextAlign.end : TextAlign.start,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
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
  const _GhostButton(
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
