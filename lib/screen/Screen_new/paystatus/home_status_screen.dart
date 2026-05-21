import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../Constant/Myconstant.dart';
import '../../../Man_PDF/Man_BillingNoteInvlice_PDF.dart';
import '../../../Man_PDF/Man_Pay_Receipt_PDF.dart';

import '../../../Model/GetCustomer_Model.dart';
import '../../../Model/GetRenTal_Model.dart';
import '../../../Model/GetInvoice_Model.dart';
import '../../../color.dart';
import '../../../main.dart';
import '../fitness_app_theme.dart';

class ReceiptPayScreen extends StatefulWidget {
  const ReceiptPayScreen({Key? key, this.animationController, this.cuslang})
      : super(key: key);
  final AnimationController? animationController;
  final String? cuslang;

  @override
  State<ReceiptPayScreen> createState() => _ReceiptPayScreenState();
}

enum InvoiceTab { unpaid, paid }

class _ReceiptPayScreenState extends State<ReceiptPayScreen>
    with TickerProviderStateMixin {
  // --- State ---
  final scrollController = ScrollController();
  final nFormat = NumberFormat("#,##0.00", "en_US");

  Animation<double>? topBarAnimation;
  double topBarOpacity = 0.0;

  bool isLoading = true;
  InvoiceTab currentTab = InvoiceTab.unpaid;

  // Profile / rental
  String? serRe, renTalName, custNo, cusLang, folder, temPageSer;
  String? billName,
      billAddr,
      billTax,
      billTel,
      billEmail,
      billDefault,
      billsName;
  String reportTitle = "ไม่ระบุ";
  String? cusPhoto, cusFoder, cusImgLogo;

  List<CustomerModel> customers = [];
  List<RenTalModel> rentals = [];
  List<InvoiceModel> invoices = [];
  final Map<String, Map<String, String>> bankCodeMap = {
    'ธนาคารกรุงเทพ': {
      'code': 'BBL',
      'en': 'Bangkok Bank',
      'logo': 'BBL.png',
    },
    'ธนาคารกสิกรไทย': {
      'code': 'KBANK',
      'en': 'Kasikornbank',
      'logo': 'KBANK.png',
    },
    'ธนาคารกรุงไทย': {
      'code': 'KTB',
      'en': 'Krung Thai Bank',
      'logo': 'KTB.png',
    },
    'ธนาคารทหารไทยธนชาต': {
      'code': 'TTB',
      'en': 'TMBThanachart Bank',
      'logo': 'TTB.png',
    },
    'ธนาคารไทยพาณิชย์': {
      'code': 'SCB',
      'en': 'Siam Commercial Bank',
      'logo': 'SCB.png',
    },
    'ธนาคารกรุงศรีอยุธยา': {
      'code': 'BAY',
      'en': 'Bank of Ayudhya',
      'logo': 'BAY.png',
    },
    'ธนาคารเกียรตินาคินภัทร': {
      'code': 'KKP',
      'en': 'Kiatnakin Phatra Bank',
      'logo': 'KKP.png',
    },
    'ธนาคารซีไอเอ็มบีไทย': {
      'code': 'CIMBT',
      'en': 'CIMB Thai Bank',
      'logo': 'CIMBT.png',
    },
    'ธนาคารทิสโก้': {
      'code': 'TISCO',
      'en': 'TISCO Bank',
      'logo': 'TISCO.png',
    },
    'ธนาคารยูโอบี': {
      'code': 'UOBT',
      'en': 'United Overseas Bank (Thai)',
      'logo': 'UOBT.png',
    },
    'ธนาคารไทยเครดิตเพื่อรายย่อย': {
      'code': 'TCD',
      'en': 'Thai Credit Retail Bank',
      'logo': 'TCD.png',
    },
    'ธนาคารแลนด์ แอนด์ เฮ้าส์': {
      'code': 'LHFG',
      'en': 'Land and Houses Bank',
      'logo': 'LHFG.png',
    },
    'ธนาคารไอซีบีซี (ไทย)': {
      'code': 'ICBCT',
      'en': 'ICBC (Thai)',
      'logo': 'ICBCT.png',
    },
    'ธนาคารพัฒนาวิสาหกิจขนาดกลางและขนาดย่อมแห่งประเทศไทย': {
      'code': 'SME',
      'en': 'SME Development Bank',
      'logo': 'SME.png',
    },
    'ธนาคารเพื่อการเกษตรและสหกรณ์การเกษตร': {
      'code': 'BAAC',
      'en': 'Bank for Agriculture and Agricultural Cooperatives',
      'logo': 'BAAC.png',
    },
    'ธนาคารออมสิน': {
      'code': 'GSB',
      'en': 'Government Savings Bank',
      'logo': 'GSB.png',
    },
    'ธนาคารอาคารสงเคราะห์': {
      'code': 'GHB',
      'en': 'Government Housing Bank',
      'logo': 'GHB.png',
    },
    'ธนาคารอิสลามแห่งประเทศไทย': {
      'code': 'ISBT',
      'en': 'Islamic Bank of Thailand',
      'logo': 'ISBT.png',
    },
    'ธนาคารอิสลามแห่งประเทศไทย2': {
      'code': 'ISBT2',
      'en': 'Islamic Bank of Thailand 2',
      'logo': 'ISBT2.png',
    },
    'BeamCheckOut': {
      'code': 'BEAM',
      'en': 'Beam Checkout',
      'logo': 'BEAM.png',
    },
    'ທະນາຄານການຄ້າຕ່າງປະເທດລາວ': {
      'code': 'BCEL',
      'en': 'Banque Pour Le Commerce Exterieur Lao',
      'logo': 'BCEL.png',
    },
    'Lao Development Bank': {
      'code': 'LDB',
      'en': 'Lao Development Bank',
      'logo': 'LDB.png',
    },
  };
  @override
  void initState() {
    super.initState();
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController!,
        curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn),
      ),
    );
    scrollController.addListener(_onScroll);
    _bootstrap();
  }

  void _onScroll() {
    final offset = scrollController.offset.clamp(0.0, 24.0);
    final newOpacity = (offset / 24.0);
    if (newOpacity != topBarOpacity) {
      setState(() => topBarOpacity = newOpacity);
    }
  }

  Future<void> _bootstrap() async {
    try {
      await _loadPrefs();
      await Future.wait([_loadRental(), _loadCustomer()]);
      await _loadInvoices(paid: false, type: 'PAY');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    serRe = p.getString('renTalSer');
    renTalName = p.getString('renTalName');
    custNo = p.getString('custno');
    cusLang = p.getString('lang');
    cusPhoto = p.getString('photo');
    cusFoder = p.getString('foder');

    if (cusPhoto != null &&
        cusPhoto!.isNotEmpty &&
        cusPhoto!.toLowerCase() != 'null' &&
        cusFoder != null &&
        cusFoder!.isNotEmpty) {
      final newUrl = MyConstant().domain_chao;
      cusImgLogo = '$newUrl/files/$cusFoder/contract/$cusPhoto';
    }
  }

  Future<void> _loadCustomer() async {
    if (serRe == null || custNo == null) return;
    final url =
        '${MyConstant().domain}/Gc_customer_user.php?isAdd=true&ren=$serRe&cusno=$custNo';
    final res = await http.get(Uri.parse(url));
    final List<dynamic> result = json.decode(res.body);
    if (mounted) {
      setState(() {
        customers = result.map((e) => CustomerModel.fromJson(e)).toList();
      });
    }
  }

  Future<void> _loadRental() async {
    final p = await SharedPreferences.getInstance();
    final ren = p.getString('renTalSer');
    renTalName = p.getString('renTalName');

    final url =
        '${MyConstant().domain_chao}/GC_rental_setring.php?isAdd=true&ren=$ren';
    final res = await http.get(Uri.parse(url));
    final List<dynamic>? result = json.decode(res.body);

    if (result == null) return;

    final list = result.map((e) => RenTalModel.fromJson(e)).toList();
    final r = list.first;

    if (mounted) {
      setState(() {
        rentals = list;
        folder = r.dbn;
        temPageSer = r.tem_page?.trim();
        billName = r.bill_name?.trim();
        billAddr = r.bill_addr?.trim();
        billTax = r.bill_tax?.trim();
        billTel = r.bill_tel?.trim();
        billEmail = r.bill_email?.trim();
        billDefault = r.bill_default;
        billsName = billDefault == 'P' ? 'บิลธรรมดา' : 'ใบกำกับภาษี';
        reportTitle = (r.receipt_title == '0')
            ? 'ไม่ระบุ'
            : (r.receipt_title == '1')
                ? 'ต้นฉบับ'
                : 'สำเนา';
      });
    }
  }
//     ORDER BY
//     c_financetrans.ser DESC;

  Future<void> _handleOpenPdf(InvoiceModel inv) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> newValuePDFimg = [];

    if (rentals.isNotEmpty && rentals[0].imglogo!.trim().isNotEmpty) {
      final urlimg =
          '${MyConstant().domain_chao}/files/$folder/logo/${rentals[0].imglogo!.trim()}';
      newValuePDFimg.add(urlimg);
      preferences.setString('renTal_logo', urlimg);
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    try {
      ManPay_Receipt_PDF.overrideTabPaid =
          (currentTab == InvoiceTab.paid) ? 'true' : 'false';

      if (currentTab == InvoiceTab.paid) {
        await preferences.setString('Tabpaid', 'true');
      } else {
        await preferences.setString('Tabpaid', 'false');
      }

      if (!mounted) return;
      ManPay_Receipt_PDF.ManPayReceipt_PDF(
        inv.docno,
        context,
        folder,
        renTalName,
        billAddr,
        billEmail,
        billTel,
        billTax,
        billName,
        newValuePDFimg,
        null,
        temPageSer,
        billsName,
        '1',
      );
    } catch (e) {
      debugPrint('PDF Error: $e');
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _loadInvoices({required bool paid, required String type}) async {
    final p = await SharedPreferences.getInstance();
    final ren = p.getString('renTalSer');
    final qutser = p.getString('qutser');
    final custno = p.getString('custno');

    final url =
        '${MyConstant().domain_chao}/GC_ReceiptUserV2.php?isAdd=true&ren=$ren&custno=$custno&qutser=$qutser&type=$type';

    final res = await http.get(Uri.parse(url));
    final result = json.decode(res.body);

    if (mounted) {
      setState(() {
        if (result == null || result['data'] == null) {
          invoices = [];
        } else {
          final data = result['data'] as List;
          invoices = data.map((e) => InvoiceModel.fromJson(e)).toList();
        }
      });
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  int _crossAxisCountWidth(double width) {
    if (!kIsWeb) return 1;
    if (width >= 1600) return 4;
    if (width >= 1400) return 3;
    if (width >= 1000) return 3;
    if (width >= 800) return 2;
    return 1;
  }

  Widget getAppBarUI() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderBar(
        opacity: topBarOpacity,
        title: (cusLang == 'EN') ? 'Payment receipt' : 'ใบเสร็จรับชำระ',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cross = _crossAxisCountWidth(width);
    final scale = MediaQuery.of(context).textScaleFactor;

    // Filter list based on current tab
    final filtered = invoices.where((inv) {
      if (currentTab == InvoiceTab.paid) {
        // "Waiting list" (รายการรอตรวจสอบ) -> Only Pending items
        return inv.status == '1';
      } else {
        // "Payment items" (รายการรับชำระ) -> Unpaid/Everything else
        // In the original app, unpaid items are usually those not yet confirmed
        return inv.status != '1';
      }
    }).toList();

    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: isLoading
            ? Center(
                child: LoadingAnimationWidget.inkDrop(
                    color: Colors.green, size: 70),
              )
            : ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: CustomScrollView(
                  key: ValueKey(
                      currentTab), // Force rebuild sliver state on tab switch
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Ensure reactive scrolling
                  controller: scrollController,
                  slivers: [
                    getAppBarUI(),
                    SliverToBoxAdapter(child: _tabSwitcher()),
                    SliverToBoxAdapter(child: _titleBar(filtered.length)),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 100),
                      sliver: cross == 1
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, i) => InvoiceCard(
                                  key: ValueKey(filtered[i].docno ?? i),
                                  model: filtered[i],
                                  paid: currentTab == InvoiceTab.paid,
                                  nFormat: nFormat,
                                  cuslang: cusLang,
                                  bankCodeMap: bankCodeMap,
                                  onOpenPdf: _handleOpenPdf,
                                ),
                                childCount: filtered.length,
                              ),
                            )
                          : SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cross,
                                mainAxisSpacing: 1,
                                crossAxisSpacing: 1,
                                mainAxisExtent:
                                    145.0 * (1 + (scale - 1).clamp(0.0, 0.25)),
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, i) => InvoiceCard(
                                  key: ValueKey(filtered[i].docno ?? i),
                                  model: filtered[i],
                                  paid: currentTab == InvoiceTab.paid,
                                  nFormat: nFormat,
                                  cuslang: cusLang,
                                  bankCodeMap: bankCodeMap,
                                  onOpenPdf: _handleOpenPdf,
                                ),
                                childCount: filtered.length,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _tabButton({
    required String text,
    required bool active,
    required BorderRadius radius,
    required VoidCallback onTap,
    required List<Color> activeColors,
    required List<Color> inactiveColors,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: HexColor('#FBF3D5').withOpacity(0.6),
                offset: const Offset(1.1, 4.0),
                blurRadius: 8.0,
              ),
            ],
            gradient: LinearGradient(
              colors: active ? activeColors : inactiveColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: radius,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : Colors.black,
                fontFamily: Font_.Fonts_T,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabSwitcher() {
    final _greenActive = [HexColor('#2E7D32'), HexColor('#66BB6A')];
    final _greenInactive = [HexColor('#E8F5E9'), HexColor('#C8E6C9')];
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _tabButton(
            text: (cusLang == 'EN') ? 'Payment items' : 'รายการรับชำระ',
            active: currentTab == InvoiceTab.unpaid,
            radius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            onTap: () async {
              if (currentTab == InvoiceTab.unpaid) return;
              setState(() {
                currentTab = InvoiceTab.unpaid;
                isLoading = true; // Show loader while switching
                invoices.clear();
              });
              try {
                await _loadInvoices(paid: false, type: 'PAY');
              } finally {
                if (mounted) setState(() => isLoading = false);
              }
            },
            activeColors: _greenActive,
            inactiveColors: _greenInactive,
          ),
          const SizedBox(width: 5),
          _tabButton(
            text: (cusLang == 'EN') ? 'Waiting list' : 'รายการรอตรวจสอบ',
            active: currentTab == InvoiceTab.paid,
            radius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            onTap: () async {
              if (currentTab == InvoiceTab.paid) return;
              setState(() {
                currentTab = InvoiceTab.paid;
                isLoading = true; // Show loader while switching
                invoices.clear();
              });
              try {
                await _loadInvoices(paid: false, type: '');
              } finally {
                if (mounted) setState(() => isLoading = false);
              }
            },
            activeColors: _greenActive,
            inactiveColors: _greenInactive,
          ),
        ],
      ),
    );
  }

  Widget _titleBar(int count) {
    final countTxt =
        (cusLang == 'EN') ? 'List $count bill' : 'รายการ $count บิล';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: _SectionTitle(
        title: countTxt,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
        controller: widget.animationController!,
      ),
    );
  }

  Widget _appBar() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (_, __) => FadeTransition(
            opacity: topBarAnimation!,
            child: Transform(
              transform: Matrix4.translationValues(
                  0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
              child: Container(
                decoration: BoxDecoration(
                  color: FitnessAppTheme.white.withOpacity(topBarOpacity),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          FitnessAppTheme.grey.withOpacity(0.4 * topBarOpacity),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16 - 8.0 * topBarOpacity,
                        bottom: 12 - 8.0 * topBarOpacity,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                (cusLang == 'EN')
                                    ? 'Payment receipt'
                                    : 'ใบเสร็จรับชำระ',
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22 + 6 - 6 * topBarOpacity,
                                  letterSpacing: 1.2,
                                  color: FitnessAppTheme.darkerText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ------- Widgets ย่อย -------
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.animation,
    required this.controller,
  });

  final String title;
  final Animation<double> animation;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    controller.forward();
    return FadeTransition(
      opacity: animation,
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: FitnessAppTheme.fontName,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.model,
    required this.paid,
    required this.nFormat,
    required this.cuslang,
    required this.bankCodeMap,
    this.onOpenPdf, // ✅ ให้ parent จัดการกดปุ่ม
    this.badgeLeft = true, // ตัวเลือกโชว์ badge ซ้าย
  });

  final InvoiceModel model;
  final bool paid;
  final NumberFormat nFormat;
  final String? cuslang;
  final bankCodeMap;

  /// ให้ parent ส่งฟังก์ชันมาจัดการเปิด PDF หรือทำอย่างอื่น
  final void Function(InvoiceModel model)? onOpenPdf;

  /// เผื่ออยากซ่อน badge ซ้ายในบาง layout
  final bool badgeLeft;

  @override
  Widget build(BuildContext context) {
    // สี badge ตามสถานะชำระ
    final badgeColors = paid
        ? [HexColor('#4F6F52'), HexColor('#3A4D39')]
        : [HexColor('#FF8080'), HexColor('#EF4B4B')];

    // รวมยอด
    final total = nFormat.format(double.tryParse(model.total_bill ?? '0') ?? 0);
    final bank = model.bank ?? '';
    final bankInfo = bankCodeMap[bank];
    final logoFile = bankInfo?['logo'];
    // ภาษา (โปรเจ็กต์คุณใช้ 'EN'/'TH')
    final isEN = (cuslang?.toUpperCase() == 'EN');

    // วันที่กำหนดชำระ (กัน null/parse error)
    String dueStr;
    final rawDate = (model.date ?? '').trim();
    if (rawDate.isEmpty) {
      dueStr = isEN
          ? 'Payment date: Please contact staff.'
          : 'วันที่ชำระ: กรุณาติดต่อเจ้าหน้าที่';
    } else {
      DateTime? d;
      try {
        d = DateTime.parse('$rawDate 00:00:00');
      } catch (_) {}
      if (d == null) {
        dueStr = isEN
            ? 'Payment date: Please contact staff.'
            : 'วันที่ชำระ: กรุณาติดต่อเจ้าหน้าที่';
      } else {
        final f = DateFormat('dd-MM-yyyy');
        dueStr =
            isEN ? 'Payment date ${f.format(d)}' : 'วันที่ชำระ ${f.format(d)}';
      }
    }

    Widget chip(String text, Color bg, Color fg) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: fg.withOpacity(.25), width: .7),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: Font_.Fonts_T,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
              color: fg,
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12, width: .4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // เนื้อหา
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      // โลโก้
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: logoFile != null
                            ? Image.asset(
                                'assets/images/LogoBank/$logoFile',
                                cacheWidth: 100, // ลด Memory Leak
                                height: 26,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.account_balance,
                                    size: 20,
                                    color: Colors.grey),
                              )
                            : const Icon(Icons.account_balance,
                                size: 20, color: Colors.grey),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          model.docno ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: Colors.black,
                            fontFamily: Font_.Fonts_T,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        total,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: Colors.black,
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Row(mainAxisSize: MainAxisSize.min, children: [
                        //   const Icon(Icons.badge_outlined,
                        //       size: 14, color: Colors.black54),
                        //   const SizedBox(width: 6),
                        //   Text(
                        //     model.cid ?? '-',
                        //     maxLines: 1,
                        //     overflow: TextOverflow.ellipsis,
                        //     style: const TextStyle(
                        //       fontFamily: Font_.Fonts_T,
                        //       fontSize: 12.5,
                        //     ),
                        //   ),
                        // ]),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            dueStr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: Font_.Fonts_T,
                              fontSize: 12.5,
                            ),
                          ),
                        ]),
                        if (model.bno != '' && model.bno != null)
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.account_balance,
                                size: 14, color: Colors.black54),
                            const SizedBox(width: 6),
                            Text(
                              (model.ptname.toString() == 'เงินสด' ||
                                      model.bno.toString() == 'เงินสด')
                                  ? isEN
                                      ? 'cash'
                                      : model.bno ?? '-'
                                  : model.bno ?? '-',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: Font_.Fonts_T,
                                fontSize: 12.5,
                              ),
                            ),
                          ]),
                        // ตัวอย่าง chip ขวา (จะโชว์อะไรก็เปลี่ยนได้)ฃ
                        (model.status.toString() == '1')
                            ? chip(
                                isEN
                                    ? 'Pending'
                                    : 'รอตรวจสอบ' ?? '-', // Translated text
                                Colors.orange.withOpacity(.08),
                                Colors.orange)
                            : chip(
                                isEN
                                    ? 'Success'
                                    : 'ชำระสำเร็จ' ?? '-', // Translated text
                                Colors.green.withOpacity(.08),
                                Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ปุ่ม action (ให้ parent จัดการ)
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onOpenPdf == null ? null : () => onOpenPdf!(model),
              tooltip: isEN ? 'Open details' : 'ดูรายละเอียด',
            ),
          ],
        ),
      ),
    );
  }
}

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
