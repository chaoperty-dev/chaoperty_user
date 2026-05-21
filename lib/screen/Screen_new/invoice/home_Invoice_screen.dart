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
import '../../../Model/GetCustomer_Model.dart';
import '../../../Model/GetRenTal_Model.dart';
import '../../../Model/GetInvoice_Model.dart';
import '../../../color.dart';
import '../../../main.dart';
import '../fitness_app_theme.dart';

class InvioceScreen extends StatefulWidget {
  const InvioceScreen({Key? key, this.animationController, this.cuslang})
      : super(key: key);
  final AnimationController? animationController;
  final String? cuslang;

  @override
  State<InvioceScreen> createState() => _InvioceScreenState();
}

enum InvoiceTab { unpaid, paid }

class _InvioceScreenState extends State<InvioceScreen>
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
    final offset = scrollController.offset.clamp(0, 24);
    final newOpacity = (offset / 24);
    if (newOpacity != topBarOpacity) {
      setState(() => topBarOpacity = newOpacity);
    }
  }

  Future<void> _bootstrap() async {
    try {
      await _loadPrefs();
      await Future.wait([_loadRental(), _loadCustomer()]);
      await _loadInvoices(paid: false, type: 'NOT');
    } finally {
      setState(() => isLoading = false);
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
    setState(() {
      customers = result.map((e) => CustomerModel.fromJson(e)).toList();
    });
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

  Future<void> _loadInvoices({required bool paid, required String type}) async {
    invoices.clear();
    final p = await SharedPreferences.getInstance();
    final ren = p.getString('renTalSer');
    final qutser = p.getString('qutser');
    final custno = p.getString('custno');

    ///GC_bill_invoice_custno

    final path =
        paid ? 'GC_bill_invoice_custno_pay.php' : 'GC_invoiceCustnoV2.php';
    final url =
        '${MyConstant().domain_chao}/$path?isAdd=true&ren=$ren&custno=$custno&qutser=$qutser&type=$type';
    // 'http://192.168.1.227/chao_api/$path?isAdd=true&ren=$ren&custno=$custno&qutser=$qutser&type=$type';
    // final url =
    //     '${MyConstant().domain_chao}/$path?isAdd=true&ren=$ren&custno=$custno&qutser=$qutser';
    print(url);
    final res = await http.get(Uri.parse(url));
    final result = json.decode(res.body);
    if (result.toString() == 'null') return;
    setState(() {
      final data = result is Map<String, dynamic> && result['data'] is List
          ? result['data'] as List
          : [];

      invoices = data.map((e) => InvoiceModel.fromJson(e)).toList();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // --- UI helpers ---
  Future<bool> _tick() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  int _crossAxisCount(BoxConstraints c) {
    if (!kIsWeb) return 1;
    final w = c.maxWidth;
    if (w >= 1600) return 4;
    if (w >= 1400) return 3;
    if (w >= 1000) return 3;
    if (w >= 800) return 2;
    return 1;
  }

  double _aspectRatio(BoxConstraints c) {
    if (!kIsWeb) return 5.0;
    final w = c.maxWidth;
    if (w >= 1400) return 3.85;
    if (w >= 1000) return 3.9;
    if (w >= 800) return 3.0;
    return 8.0;
    // หมายเหตุ: คงค่าใกล้เคียงของเดิมแต่ย่อ logic
  }

  // --- Build ---
  Widget getAppBarUI() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderBar(
        opacity: topBarOpacity,
        title: (cusLang == 'EN') ? 'Invioce' : 'ใบแจ้งหนี้/ใบวางบิล',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: isLoading
            ? Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 30,
                        backgroundImage:
                            AssetImage('assets/images/Icon-chao.png'),
                      ),
                    ),
                    LoadingAnimationWidget.inkDrop(
                        color: Colors.green, size: 70),
                  ],
                ),
              )
            : CustomScrollView(
                controller: scrollController,
                slivers: [
                  getAppBarUI(),
                  SliverToBoxAdapter(child: _tabSwitcher()),
                  SliverToBoxAdapter(child: _titleBar()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 100),
                    sliver: SliverToBoxAdapter(
                      child: LayoutBuilder(
                        builder: (context, c) {
                          double _tileHeight(BuildContext context, int cross) {
                            final scale =
                                MediaQuery.of(context).textScaleFactor;
                            final base = switch (cross) {
                              1 =>
                                145.0, // Increased significantly for multi-line wrap
                              2 => 155.0,
                              _ => 155.0,
                            };
                            return base * (1 + (scale - 1).clamp(0.0, 0.25));
                          }

                          final cross = _crossAxisCount(c);
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: invoices.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cross,
                              mainAxisSpacing: 1,
                              crossAxisSpacing: 1,
                              mainAxisExtent: _tileHeight(context, cross + 10),
                            ),
                            itemBuilder: (_, i) => InvoiceCard(
                              currentTab: currentTab,
                              model: invoices[i],
                              paid: currentTab == InvoiceTab.paid,
                              nFormat: nFormat,
                              cuslang: cusLang,
                              bankCodeMap: bankCodeMap,
                              onOpenPdf: (inv) async {
                                final SharedPreferences preferences =
                                    await SharedPreferences.getInstance();
                                List<String> newValuePDFimg = [];

                                if (rentals.isNotEmpty &&
                                    rentals[0].imglogo!.trim().isNotEmpty) {
                                  final urlimg =
                                      '${MyConstant().domain_chao}/files/$folder/logo/${rentals[0].imglogo!.trim()}';
                                  newValuePDFimg.add(urlimg);
                                  preferences.setString('renTal_logo', urlimg);
                                }

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.green),
                                  ),
                                );

                                try {
                                  Man_BillingNoteInvlice_PDF
                                      .ManBillingNoteInvlice_PDF(
                                    null,
                                    folder,
                                    '1',
                                    temPageSer,
                                    context,
                                    inv.cid ?? '',
                                    '', // ชื่อผู้เช่า
                                    billAddr,
                                    billEmail,
                                    billTel,
                                    billTax,
                                    billName,
                                    newValuePDFimg,
                                    inv.docno,
                                    '1',
                                  );
                                } catch (e) {
                                  debugPrint('PDF Error: $e');
                                } finally {
                                  if (context.mounted) Navigator.pop(context);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _mainListView() {
    return FutureBuilder<bool>(
      future: _tick(),
      builder: (_, s) {
        if (!s.hasData) return const SizedBox.shrink();
        return ListView(
          controller: scrollController,
          padding: EdgeInsets.only(
            top: AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top +
                24,
            bottom: 62 + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            _tabSwitcher(),
            _titleBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 8, 100),
              child: LayoutBuilder(
                builder: (context, c) {
                  double _tileHeight(BuildContext context, int cross) {
                    final scale = MediaQuery.of(context).textScaleFactor;
                    // Base heights by columns (more columns → taller tiles)
                    final base = switch (cross) {
                      1 => 145.0, // Increased significantly for multi-line wrap
                      2 => 155.0,
                      _ => 155.0,
                    };
                    // Expand ~15–25% when text scale grows
                    return base * (1 + (scale - 1).clamp(0.0, 0.25));
                  }

                  final cross = _crossAxisCount(c);
                  final ratio = _aspectRatio(c);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: invoices.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross, // your computed 1/2/3/4
                      mainAxisSpacing: 1,
                      crossAxisSpacing: 1,
                      // ✅ Fixed tile height (tune as you like)
                      mainAxisExtent: _tileHeight(context, cross + 10),
                    ),
                    itemBuilder: (_, i) => InvoiceCard(
                      currentTab: currentTab,
                      model: invoices[i],
                      paid: currentTab == InvoiceTab.paid,
                      nFormat: nFormat,
                      cuslang: cusLang,
                      bankCodeMap: bankCodeMap,
                      onOpenPdf: (inv) async {
                        final SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        List<String> newValuePDFimg = [];

                        if (rentals.isNotEmpty &&
                            rentals[0].imglogo!.trim().isNotEmpty) {
                          final urlimg =
                              '${MyConstant().domain_chao}/files/$folder/logo/${rentals[0].imglogo!.trim()}';
                          newValuePDFimg.add(urlimg);
                          preferences.setString('renTal_logo', urlimg);
                        }

                        // ✅ แสดงโหลดทันที (ไม่ต้อง delay)
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child:
                                CircularProgressIndicator(color: Colors.green),
                          ),
                        );

                        try {
                          // ✅ รอให้สร้าง PDF เสร็จจริง ๆ (ถ้าเป็น Future)
                          Man_BillingNoteInvlice_PDF.ManBillingNoteInvlice_PDF(
                            null,
                            folder,
                            '1',
                            temPageSer,
                            context,
                            inv.cid ?? '',
                            '', // ชื่อผู้เช่า
                            billAddr,
                            billEmail,
                            billTel,
                            billTax,
                            billName,
                            newValuePDFimg,
                            inv.docno,
                            '1',
                          );

                          // ✅ reload list หลังทำเสร็จ (ถ้ามี)
                        } catch (e) {
                          debugPrint('PDF Error: $e');
                        } finally {
                          // ✅ ปิด dialog ไม่ว่าจะ success หรือ fail
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
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
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _tabButton(
            text: (cusLang == 'EN') ? 'Invoice' : 'ใบแจ้งหนี้/ใบวางบิล',
            active: currentTab == InvoiceTab.unpaid,
            radius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            onTap: () async {
              if (currentTab == InvoiceTab.unpaid) return;
              setState(() => currentTab = InvoiceTab.unpaid);
              await _loadInvoices(paid: false, type: 'NOT');
            },
            activeColors: [HexColor('#FF9D3D'), HexColor('#FFBF61')],
            inactiveColors: [HexColor('#E4E0E1'), HexColor('#FFF1DB')],
          ),
          const SizedBox(width: 5),
          _tabButton(
            text: (cusLang == 'EN')
                ? 'Invoice, paid'
                : 'ใบแจ้งหนี้/ใบวางบิล ชำระแล้ว',
            active: currentTab == InvoiceTab.paid,
            radius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            onTap: () async {
              if (currentTab == InvoiceTab.paid) return;
              setState(() => currentTab = InvoiceTab.paid);
              await _loadInvoices(paid: false, type: '');
              // await _loadInvoices(paid: true, type: '');
            },
            activeColors: [HexColor('#FF9D3D'), HexColor('#FFBF61')],
            inactiveColors: [HexColor('#E4E0E1'), HexColor('#FFF1DB')],
          ),
        ],
      ),
    );
  }

  Widget _titleBar() {
    final countTxt = (cusLang == 'EN')
        ? 'Invioce ${invoices.length} bill'
        : 'ใบแจ้งหนี้/ใบวางบิล ${invoices.length} บิล';
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
                                    ? 'Invioce'
                                    : 'ใบแจ้งหนี้/ใบวางบิล',
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
  InvoiceCard({
    super.key,
    required this.currentTab,
    required this.model,
    required this.paid,
    required this.nFormat,
    required this.cuslang,
    required this.bankCodeMap,
    this.onOpenPdf, // ✅ ให้ parent จัดการกดปุ่ม
    this.badgeLeft = true, // ตัวเลือกโชว์ badge ซ้าย
  });
  InvoiceTab currentTab = InvoiceTab.unpaid;
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
          ? 'Payment due: Please contact staff.'
          : 'กำหนดชำระ: กรุณาติดต่อเจ้าหน้าที่';
    } else {
      DateTime? d;
      try {
        d = DateTime.parse('$rawDate 00:00:00');
      } catch (_) {}
      if (d == null) {
        dueStr = isEN
            ? 'Payment due: Please contact staff.'
            : 'กำหนดชำระ: กรุณาติดต่อเจ้าหน้าที่';
      } else {
        final f = DateFormat('dd-MM-yyyy');
        dueStr =
            isEN ? 'Payment due ${f.format(d)}' : 'กำหนดชำระ ${f.format(d)}';
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
                                height: 26,
                                cacheWidth:
                                    100, // ลด Memory Usage บน iOS Safari
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
                      spacing: 12, // More spacious horizontal spacing
                      runSpacing: 8, // More spacious vertical spacing
                      crossAxisAlignment:
                          WrapCrossAlignment.center, // Vertically center items
                      children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.badge_outlined,
                              size: 16, // Slightly larger icon
                              color: Colors.black54),
                          const SizedBox(width: 4), // Tighter spacing
                          Text(
                            model.cid ?? '-',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily:
                                  Font_.Fonts_T, // Ensure font family is used
                              fontWeight:
                                  FontWeight.w500, // Slightly bolder text
                              fontSize: 13, // Slightly larger text
                            ),
                          ),
                        ]),
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
                              (model.ptname.toString() == 'เงินสด')
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
                        if (currentTab == InvoiceTab.paid)
                          (model.pos.toString() == '1')
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
                        // ตัวอย่าง chip ขวา (จะโชว์อะไรก็เปลี่ยนได้)
                        // chip(model.status ?? '-', Colors.green.withOpacity(.08),
                        //     Colors.green),
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
