import 'dart:async';
import 'dart:convert';
import 'package:chaoperty_user/video_player_helper.dart';
import 'package:chaoperty_user/screen_Intents/bankCodeMap.dart';
import 'package:chaoperty_user/screen_Intents/payment_subV2_InvAll.dart';
import 'package:chaoperty_user/screen_Intents_V3/payment_subV3_InvAll.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4_InvAll.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Constant/Myconstant.dart';
import '../Model/GetCustomer_Model.dart';
import '../Model/GetInvoice_Model.dart';
import '../Model/GetInvoice_pay_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../color.dart';
import '../screen/Screen_new/fitness_app_home_screen.dart';
import '../screen/Screen_new/fitness_app_theme.dart';
import '../screen/Screen_new/ui_view/running_view_pay.dart';
import '../screen/model/contractInvoice.dart';
import '../screen/pay_bill_screen.dart';

class paymentMainV3InvAll extends StatefulWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<TeNantModel>? teNantModel;
  final List<CustomerModel>? customerModel;
  final String? cuslang;
  final bool isMainScreen; // [NEW] Control scroll behavior
  const paymentMainV3InvAll(
      {super.key,
      this.mainScreenAnimationController,
      this.mainScreenAnimation,
      this.teNantModel,
      this.customerModel,
      this.cuslang,
      this.isMainScreen = true}); // [NEW] Default to true

  @override
  State<paymentMainV3InvAll> createState() => _paymentMainV3InvAllState();
}

class _paymentMainV3InvAllState extends State<paymentMainV3InvAll> {
  // ✅ Static formatters to avoid recreation
  static final _nFormat = NumberFormat("#,##0.00", "en_US");
  static final _nFormatInt = NumberFormat("#,##0", "en_US");
  static final _dateFormat = DateFormat('dd-MM-yyyy');

  String fmtMoney(num? n) =>
      _nFormat.format(double.parse((n ?? 0).toStringAsFixed(2)));
  String fmtInt(num? n) =>
      _nFormatInt.format(double.parse((n ?? 0).toInt().toString()));
  String fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return _dateFormat.format(d);
  }

  DateTime datex = DateTime.now();
  int tap_pay = 0;
  int? _serPayment, _serptPayment;
  ////--------------------->
  List<InvoicePayModel> invoicePayModels = [];
  List<InvoiceModel> _InvoiceModels = [];
  List<InvoiceModel> invoicePayModels2 = [];
  List<dynamic> InvoicePay = [];
  ////--------------------->

  int ref_new = 0;
  String? return_qr_img, invoiceAll, return_qr_refapi, return_img;
  bool _isLoading = true;
  bool _showGuideCard = false;
  Timer? _timer;
  String countdownText = '';
  Offset _fabPos = Offset.zero;
  Offset _cardPos = Offset.zero;

  static const String _guideCardLastShownKey = 'guideCardLastShownV3';
  static const Duration _guideCardCooldown = Duration(minutes: 5);

  // ✅ Cached totals (computed once per data load)
  double _cachedTotalAll = 0;
  double _cachedTotalDiscount = 0;
  String? renTal_user, renTal_name, Value_cid, custno_, cus_ser;
  ////--------------------->
  ////----------- แท็บสีตามสถานะสัญญา (ถ้าต้องการ)
  Color tagColor(String? st) {
    switch (st) {
      case 'สัญญาปัจจุบัน':
        return Colors.teal.shade700;
      case 'ยกเลิกสัญญา':
        return Colors.red.shade800;
      default:
        return Colors.blueGrey.shade700;
    }
  }

  ////--------------------->
  @override
  void initState() {
    red_Invoice();
    // red_Invoice().then((value) => Check_genref_pay());
    Check_time();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      setState(() {
        _fabPos = Offset(size.width - 64, size.height - 220);
        _cardPos = Offset(size.width - 268, size.height - 680);
      });
      // ✅ ตรวจสอบว่าเคยแสดง Guide Card ภายใน 5 นาทีที่ผ่านมาหรือยัง
      final prefs = await SharedPreferences.getInstance();
      final lastShown = prefs.getInt(_guideCardLastShownKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final canShow = (now - lastShown) >= _guideCardCooldown.inMilliseconds;
      if (canShow) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          setState(() => _showGuideCard = true);
          prefs.setInt(_guideCardLastShownKey, now);
        });
      }
    });
  }

  ////--------------------->
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  ////--------------------->
  Future<Null> Check_time() async {
    final now = DateTime.now();
    print('เช็คว่าเวลาปัจจุบัน ${now.hour}:${now.minute}');

    // เช็คว่าเวลาปัจจุบันอยู่ในช่วง 23:00 - 01:00
    if (now.hour == 23 || now.hour == 0) {
      Future.delayed(const Duration(milliseconds: 200), () {
        PanaraInfoDialog.showAnimatedGrow(
          context,
          title: "Oops",
          message: widget.cuslang == 'EN'
              ? 'Transactions cannot be made between 11:00 PM and 1:00 AM.'
              : "ไม่สามารถทำรายการได้ในช่วงเวลา 23.00 ถึง 01.00",
          buttonText: widget.cuslang == 'EN' ? 'OK' : "รับทราบ",
          onTapDismiss: () async {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            var custno = preferences.getString('custno');
            Navigator.of(
              context,
              rootNavigator: true,
            ).pop();
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
              return FitnessAppHomeScreen(custno_s: custno);
            }), (route) => false);
          },
          panaraDialogType: PanaraDialogType.error,
          barrierDismissible: false,
        );
      });
    }
  }

  List<ContractInvoice> coninv = [];

  Future<void> red_Invoice() async {
    // 🔴 หยุดทำงานทันที
    if (widget.teNantModel == null || widget.teNantModel!.isEmpty) {
      debugPrint('teNantModel is null or empty → stop ${widget.teNantModel}');
      return;
    }
    if (!mounted) return;

    setState(() {
      coninv.clear();
      _isLoading = true;
    });

    // helper: filter ตามเงื่อนไข 2 กรณี
    List<ContractInvoice> filterInvoiceByCid(
      List<ContractInvoice> invoices,
      String? userCid,
    ) {
      // กรณีเอาทุกบิล
      if (userCid == null || userCid.isEmpty) return invoices;

      return invoices
          .map((inv) {
            final newData = inv.data
                ?.map((d) {
                  final filteredBills =
                      d.bill?.where((b) => (b.cid ?? '') == userCid).toList();

                  if (filteredBills == null || filteredBills.isEmpty)
                    return null;

                  return Data(
                    payser: d.payser,
                    ptser: d.ptser,
                    bank: d.bank,
                    bno: d.bno,
                    bname: d.bname,
                    ptname: d.ptname,
                    img: d.img,
                    serPayweb: d.serPayweb,
                    pvatBill: d.pvatBill,
                    vatBill: d.vatBill,
                    whtBill: d.whtBill,
                    totalBill: d.totalBill,
                    totalDisendbill: d.totalDisendbill,
                    bill: filteredBills,
                  );
                })
                .whereType<Data>()
                .toList();

            if (newData == null || newData.isEmpty) return null;

            return ContractInvoice(
              billAll: inv.billAll,
              pvatAll: inv.pvatAll,
              vatAll: inv.vatAll,
              whtAll: inv.whtAll,
              totalDisendbill: inv.totalDisendbill,
              totalAll: inv.totalAll,
              data: newData,
            );
          })
          .whereType<ContractInvoice>()
          .toList();
    }

    final preferences = await SharedPreferences.getInstance();
    final custNo = preferences.getString('custno');
    final ren = preferences.getString('renTalSer');
    // ✅ 2 กรณี:
    // - ถ้ามีผู้เช่ามากกว่า 1 -> userCid = null (เอาทุกบิล)
    // - ถ้ามีผู้เช่าเดียว -> userCid = cid (เอาเฉพาะบิล cid ตรง)
    final String? userCid = (widget.teNantModel == null ||
            widget.teNantModel!.isEmpty ||
            widget.teNantModel!.length > 1)
        ? null
        : null;
    //widget.teNantModel!.first.cid;

    if (custNo == null || custNo.isEmpty) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    final url =
        '${MyConstant().domain}/GC_billGropInv_UserPaytypeV2.php?isAdd=true&ren=$ren&custno_inv=$custNo';

    debugPrint('url userCid=$userCid : $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        debugPrint('HTTP error: ${response.statusCode}');
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      final decoded = json.decode(response.body);
      debugPrint('raw: ${response.body}');

      List<ContractInvoice> parsed = [];

      if (decoded is Map<String, dynamic>) {
        parsed = [ContractInvoice.fromJson(decoded)];
      } else if (decoded is List) {
        parsed = decoded
            .whereType<Map<String, dynamic>>()
            .map((e) => ContractInvoice.fromJson(e))
            .toList();
      } else {
        debugPrint('Unexpected JSON shape');
      }

      // ✅ ใช้ filter ตามเงื่อนไข 2 กรณี
      parsed = filterInvoiceByCid(parsed, userCid);

      if (!mounted) return;
      setState(() {
        coninv = parsed;
        _isLoading = false;

        // ✅ Compute totals ONCE and cache them
        // _cachedTotalAll = (parsed.firstOrNull?.data ?? []).fold<double>(
        //   0.0,
        //   (sum, d) => sum + ((d.totalBill ?? 0).toDouble()),
        // );
        // _cachedTotalDiscount = (parsed.firstOrNull?.data ?? []).fold<double>(
        //   0.0,
        //   (sum, d) => sum + ((d.totalDisendbill ?? 0).toDouble()),
        // );
        // รวมยอดจริงจากรายการบิลด้านใน (bill.total_bill)
        _cachedTotalAll = (parsed.firstOrNull?.data ?? const [])
            .expand((d) => d.bill ?? const [])
            .fold<double>(
                0.0, (sum, b) => sum + ((b.totalBill ?? 0).toDouble()));

// รวมส่วนลดจาก bill.total_disendbill (ถ้าต้องการ)
        _cachedTotalDiscount = (parsed.firstOrNull?.data ?? const [])
            .expand((d) => d.bill ?? const [])
            .fold<double>(
                0.0, (sum, b) => sum + ((b.totalDisendbill ?? 0).toDouble()));
      });
      print('coninv =========================>');

      for (final inv in coninv) {
        print(jsonEncode(inv.toJson()));
      }

      print('coninv =========================>');
    } catch (e) {
      debugPrint('red_Invoice error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Widget getAppBarUI() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderBar(
        opacity:
            1.0, // Sticky header constant opacity or bind to scroll if needed
        title: widget.cuslang == 'EN' ? 'Payment' : 'ชำระเงิน',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading();
    if (coninv.isEmpty) return _buildEmptyState();

    final inv = coninv.first;
    final groups = inv.data ?? const <Data>[];
    if (groups.isEmpty) return _buildEmptyState();

    return Stack(
      children: [
        AnimatedBuilder(
          animation: widget.mainScreenAnimationController!,
          builder: (_, __) => FadeTransition(
            opacity: widget.mainScreenAnimation!,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - widget.mainScreenAnimation!.value)),
              child: RefreshIndicator(
                onRefresh: red_Invoice,
                child: CustomScrollView(
                  shrinkWrap: !widget.isMainScreen,
                  physics: widget.isMainScreen
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  slivers: [
                    if (widget.isMainScreen) getAppBarUI(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.teNantModel!.length > 1) ...[
                              RunningViewPay(
                                animation: Tween<double>(begin: 0.0, end: 1.0)
                                    .animate(CurvedAnimation(
                                        parent: widget
                                            .mainScreenAnimationController!,
                                        curve: Interval((1 / 5) * 3, 1.0,
                                            curve: Curves.fastOutSlowIn))),
                                animationController:
                                    widget.mainScreenAnimationController!,
                                cuslang: widget.cuslang,
                                customerModel: widget.customerModel,
                              ),
                            ],
                            _summaryCard(inv),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.list_sharp,
                                        color: Colors.orange.shade700,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Text(
                                          widget.cuslang == 'EN'
                                              ? 'Outstanding/Pending Payments'
                                              : 'รายการค้าง/รอชำระ',
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade700,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return _groupTile(
                                (inv.data ?? const <Data>[])[index]);
                          },
                          childCount: (inv.data ?? const <Data>[]).length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: _fabPos.dy,
          left: _fabPos.dx,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (d) {
              final size = MediaQuery.of(context).size;
              setState(() {
                _fabPos = Offset(
                  (_fabPos.dx + d.delta.dx).clamp(0, size.width - 64),
                  (_fabPos.dy + d.delta.dy).clamp(0, size.height - 120),
                );
              });
            },
            child: _buildGuideFABWithLabel(),
          ),
        ),
        Positioned(
          top: _cardPos.dy,
          left: _cardPos.dx,
          width: 260,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (d) {
              final size = MediaQuery.of(context).size;
              setState(() {
                _cardPos = Offset(
                  (_cardPos.dx + d.delta.dx).clamp(0, size.width - 260),
                  (_cardPos.dy + d.delta.dy).clamp(0, size.height - 200),
                );
              });
            },
            child: IgnorePointer(
              ignoring: !_showGuideCard,
              child: AnimatedOpacity(
                opacity: _showGuideCard ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 220),
                child: AnimatedScale(
                  scale: _showGuideCard ? 1.0 : 0.88,
                  duration: const Duration(milliseconds: 220),
                  alignment: Alignment.bottomRight,
                  child: _buildGuideCard(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideFAB() {
    return GestureDetector(
      onTap: () async {
        setState(() => _showGuideCard = !_showGuideCard);
        if (_showGuideCard) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setInt(
              _guideCardLastShownKey, DateTime.now().millisecondsSinceEpoch);
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo.withValues(alpha: 0.7),
              const Color(0xFF283593).withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.live_help_rounded,
            color: Colors.white70, size: 20),
      ),
    );
  }

  // label ใต้ FAB
  Widget _buildGuideFABWithLabel() {
    final isEN = widget.cuslang == 'EN';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGuideFAB(),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.indigo.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isEN ? 'Guide' : 'คู่มือ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideCard() {
    final isEN = widget.cuslang == 'EN';
    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 6, 6),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 16,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        isEN ? 'Payment Guide' : 'วิธีการชำระเงิน',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showGuideCard = false),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded,
                            size: 15, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          barrierColor: Colors.black87,
                          builder: (_) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(12),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                InteractiveViewer(
                                  minScale: 0.8,
                                  maxScale: 5.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      'https://chaoperties.com/user/guide_user/img/img_payment.jpg',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      Navigator.of(context, rootNavigator: true)
                                          .pop(),
                                  child: Container(
                                    margin: const EdgeInsets.all(8),
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close_rounded,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  'https://chaoperties.com/user/guide_user/img/img_payment.jpg',
                                  fit: BoxFit.contain,
                                  loadingBuilder: (_, child, progress) =>
                                      progress == null
                                          ? child
                                          : Container(
                                              height: 140,
                                              alignment: Alignment.center,
                                              child:
                                                  const CircularProgressIndicator(
                                                      color: Colors.indigo),
                                            ),
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 140,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                        child: Icon(Icons.broken_image,
                                            color: Colors.grey, size: 40)),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.zoom_in_rounded,
                                        color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text('ขยาย',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.indigo, Color(0xFF283593)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => showInlineVideoDialog(
                                context,
                                'https://chaoperties.com/user/guide_user/vdo/vdo_payment.mp4',
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.play_circle_rounded,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    isEN
                                        ? 'Watch Tutorial Video'
                                        : 'ดูวิดีโอสอนการชำระเงิน',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// --------- Helpers (ใส่ในคลาสเดียวกัน) ---------
  Widget _buildLoading() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.85,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 30,
                backgroundImage: AssetImage('assets/images/Icon-chao.png'),
              ),
            ),
            LoadingAnimationWidget.inkDrop(color: Colors.indigo, size: 70),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 60,
            backgroundImage: AssetImage('assets/fitness_app/area2x.png'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.cuslang == 'EN'
                  ? 'No information or no items to be paid'
                  : 'ไม่มีข้อมูลหรือไม่มีรายการที่ต้องชำระ',
              style: const TextStyle(
                  fontSize: 16, color: Colors.black, fontFamily: Font_.Fonts_T),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.cuslang == 'EN'
                  ? '( Attach proof of past transfer. Please go to the payment history menu. )'
                  : '( แนบหลักฐานการโอนย้อนหลัง กรุณาไปที่เมนูประวัติชำระ. )',
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontFamily: Font_.Fonts_T),
            ),
          ),
        ],
      ),
    );
  }

  Widget _softTag(
      {required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.25), width: .7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: Font_.Fonts_T,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: color.withOpacity(.95),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: Font_.Fonts_T,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: color.withOpacity(.95),
            ),
          ),
        ],
      ),
    );
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
          style: TextStyle(
            fontFamily: Font_.Fonts_T,
            fontWeight: FontWeight.w700,
            fontSize: 11.5,
            color: fg,
          ),
        ),
      );
  Widget _metricTile({
    required double width,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    double progress = 0,
    bool emphasize = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12, width: .5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(.25), width: .7),
              ),
              child: Icon(icon, size: 16, color: color.withOpacity(.95)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  color: Colors.black.withOpacity(.85),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          // ค่า Value (animate เปลี่ยนค่า)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: Text(
              value,
              key: ValueKey(value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: Font_.Fonts_T,
                fontWeight: emphasize ? FontWeight.w900 : FontWeight.w800,
                fontSize: emphasize ? 16 : 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(ContractInvoice inv) {
    // ✅ Use cached totals instead of recomputing
    final totalAll = _cachedTotalAll;
    final totalDisendbill = _cachedTotalDiscount;

    // สัดส่วนเทียบยอดสุทธิรวม (กันหารศูนย์)
    double ratio(num n) => totalAll == 0 ? 0 : (n.toDouble() / totalAll);

    final isEN = widget.cuslang == 'EN';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.white.withOpacity(.92)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.black12, width: .5),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // หัวข้อ + badge รวมทั้งสิ้น
            Row(
              children: [
                Icon(Icons.insights, color: Colors.indigo.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  isEN ? 'Summary' : 'สรุปภาพรวม',
                  style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                _softTag(
                  label: isEN ? 'Bills' : 'บิลทั้งหมด',
                  value: fmtInt(inv.billAll),
                  color: Colors.indigo,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.warning, color: Colors.red.shade600, size: 14),
                const SizedBox(width: 8),
                Text(
                  isEN
                      ? 'Note: The amount shown does not include any penalties/overdue payments that may occur.'
                      : 'หมายเหตุ:ยอดที่แสดงยังไม่รวมค่าปรับ/ชำระเกินกำหนดที่อาจเกิดขึ้น',
                  style: const TextStyle(
                    color: Colors.red,
                    fontFamily: Font_.Fonts_T,
                    // fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // กริด 2–4 คอลัมน์ตามความกว้าง
            LayoutBuilder(builder: (_, c) {
              final w = c.maxWidth;
              final cols = w >= 1100 ? 5 : (w >= 740 ? 3 : 2);
              final itemW = (w - ((cols - 1) * 10)) / cols;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  // _metricTile(
                  //   width: itemW,
                  //   icon: Icons.receipt_long,
                  //   label: isEN ? 'PVAT' : 'ก่อนภาษีมูลค่าเพิ่ม',
                  //   value: fmtMoney(inv.pvatAll),
                  //   color: Colors.teal,
                  //   // สัดส่วน PVAT/Total
                  //   progress: ratio(inv.pvatAll ?? 0),
                  // ),
                  // _metricTile(
                  //   width: itemW,
                  //   icon: Icons.percent,
                  //   label: isEN ? 'VAT' : 'ภาษีมูลค่าเพิ่ม',
                  //   value: fmtMoney(inv.vatAll ?? 0),
                  //   color: Colors.orange,
                  //   progress: ratio(inv.vatAll ?? 0),
                  // ),
                  // _metricTile(
                  //   width: itemW,
                  //   icon: Icons.money_off_csred_outlined,
                  //   label: isEN ? 'WHT' : 'ภาษีหัก ณ ที่จ่าย',
                  //   value: fmtMoney(inv.whtAll),
                  //   color: Colors.pink,
                  //   progress: ratio(inv.whtAll ?? 0),
                  // ),
                  _metricTile(
                    width: itemW,
                    icon: Icons.money_off_csred_outlined,
                    label: isEN ? 'DISCOUNT' : 'ส่วนลดรวม',
                    value: fmtMoney(totalDisendbill),
                    color: Colors.pink,
                    progress: ratio(totalDisendbill),
                  ),
                  _metricTile(
                    width: itemW,
                    icon: Icons.payments,
                    label: isEN ? 'TOTAL' : 'ยอดสุทธิรวม',
                    value: fmtMoney(totalAll ?? 0),
                    // fmtMoney(inv.totalAll ?? 0),
                    color: Colors.blue,
                    // TOTAL = 100%
                    progress: totalAll == 0 ? 0 : 1,
                    emphasize: true,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _billRow(Bill b) {
    final amount = fmtMoney(b.totalBill ?? 0);
    final stTxt = b.st ?? '';
    final stCol = tagColor(stTxt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12, width: .4),
      ),
      child: Row(
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(b.docno ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5)),
                ),
                const SizedBox(width: 8),
                Text(amount,
                    style: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5)),
              ]),
              const SizedBox(height: 6),
              Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.badge_outlined,
                          size: 14, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(b.cid ?? '-',
                          style: const TextStyle(
                              fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                    ]),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(fmtDate(b.date),
                          style: const TextStyle(
                              fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                    ]),
                    chip(
                        stTxt.isEmpty
                            ? (widget.cuslang == 'EN' ? 'Unknown' : 'ไม่ทราบ')
                            : stTxt,
                        stCol.withOpacity(.08),
                        stCol),
                  ]),
            ]),
          ),
          // ปุ่มไปจ่าย/รายละเอียด (ต่อยอดจากของเดิมได้)
          // IconButton(icon: const Icon(Icons.chevron_right), onPressed: () { ... })
        ],
      ),
    );
  }

  Widget _groupTile(Data g) {
    const int count = 5;
    final payser = g.payser ?? null;
    final serPayweb = g.serPayweb ?? null;
    final payptser = g.ptser ?? null;
    final bank = g.bank ?? '';
    final bno = g.bno ?? '';
    final bname = g.bname ?? ''; // Added definition
    final title =
        g.bank ?? (widget.cuslang == 'EN' ? 'Payment method' : 'ช่องทางชำระ');
    // หารหัสไฟล์โลโก้

    final bankInfo = bankCodeMap[bank];
    final logoFile = bankInfo?['logo'];
    final bankCode = bankInfo?['code'];
    final bankEn = bankInfo?['en'];

    return Card(
      color: Colors.white,
      elevation: 0.4,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            childrenPadding:
                const EdgeInsets.only(left: 6, right: 6, bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: logoFile != null
                      ? Image.asset(
                          'assets/images/LogoBank/$logoFile',
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
                      widget.cuslang == 'EN'
                          ? bankEn! + ' ($bankCode)'
                          : bank! + ' ($bankCode)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5)),
                ),
                const SizedBox(width: 4),
                chip(widget.cuslang == 'EN' ? 'Bills' : 'ใบแจ้งหนี้',
                    Colors.indigo.shade50, Colors.indigo.shade700),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 12,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (bno.isNotEmpty)
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.account_balance,
                          size: 15, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(bno,
                          style: const TextStyle(
                              fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                    ]),
                  // if (bno.isNotEmpty)
                  //   Row(mainAxisSize: MainAxisSize.min, children: [
                  //     const Icon(Icons.confirmation_number_outlined,
                  //         size: 15, color: Colors.black54),
                  //     const SizedBox(width: 6),
                  //     Text(bno,
                  //         style: const TextStyle(
                  //             fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                  //   ]),
                  // Row(mainAxisSize: MainAxisSize.min, children: [
                  //   const Icon(Icons.receipt_long,
                  //       size: 15, color: Colors.black54),
                  //   const SizedBox(width: 6),
                  //   Text(
                  //       '${widget.cuslang == "EN" ? "PVAT" : "ก่อน VAT"}: ${fmtInt(g.pvatBill)}',
                  //       style: const TextStyle(
                  //           fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                  // ]),
                  // Row(mainAxisSize: MainAxisSize.min, children: [
                  //   const Icon(Icons.percent, size: 15, color: Colors.black54),
                  //   const SizedBox(width: 6),
                  //   Text('VAT: ${fmtMoney(g.vatBill ?? 0)}',
                  //       style: const TextStyle(
                  //           fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                  // ]),
                  // Row(mainAxisSize: MainAxisSize.min, children: [
                  //   const Icon(Icons.money_off_csred_outlined,
                  //       size: 15, color: Colors.black54),
                  //   const SizedBox(width: 6),
                  //   Text('WHT: ${fmtInt(g.whtBill)}',
                  //       style: const TextStyle(
                  //           fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                  // ]),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.note, size: 15, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(bname,
                        style: const TextStyle(
                            fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                  ]),
                  if (serPayweb.toString() == '0') ...[
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        Icons.warning_amber,
                        size: 15,
                        color: Colors.red.shade800,
                      ),
                      const SizedBox(width: 6),
                      chip(
                          widget.cuslang == 'EN'
                              ? "The payment is not available at this time."
                              : "ระบบปิดการชำระเงินชั่วคราว ",
                          Colors.red.withOpacity(.08),
                          Colors.red.shade700),
                    ]),
                  ],

                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Spacer(),
                    const Icon(Icons.receipt, size: 15, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                        '${widget.cuslang == "EN" ? "Bill All  : ${g.bill!.length ?? 0} " : "บิลทั้งหมด  : ${g.bill!.length ?? 0} "}',
                        style: const TextStyle(
                            color: Colors.grey,
                            fontFamily: Font_.Fonts_T,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(4),
                      child: Text(
                        widget.cuslang == "EN" ? "Press to pay" : "กดเพื่อชำระ",
                        style: TextStyle(
                          color: Colors.indigo.shade700,
                          fontFamily: Font_.Fonts_T,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.indigo.shade700,
                        ),
                      ),
                      onTap: () async {
                        if (serPayweb.toString() == '1') {
                          List<String>? selectedDocNos;
                          if ((g.bill ?? []).length > 1) {
                            selectedDocNos =
                                await _showBillSelectionDialog(g.bill!);
                            if (selectedDocNos == null)
                              return; // User cancelled
                          } else {
                            selectedDocNos = (g.bill ?? [])
                                .map((b) => b.docno ?? '')
                                .where((d) => d.isNotEmpty)
                                .toList();
                          }

                          setState(() {
                            tap_pay = 1;
                            _serPayment = payser;
                            _serptPayment = payptser;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => paymentSubV3InvAll(
                                mainScreenAnimation:
                                    Tween<double>(begin: 0.0, end: 1.0).animate(
                                        CurvedAnimation(
                                            parent: widget
                                                .mainScreenAnimationController!,
                                            curve: Interval(
                                                (1 / count) * 5, 1.0,
                                                curve: Curves.fastOutSlowIn))),
                                mainScreenAnimationController:
                                    widget.mainScreenAnimationController!,
                                teNantModel: widget.teNantModel,
                                cuslang: widget.cuslang,
                                serPayment: payser.toString(),
                                serptPayment: payptser.toString(),
                                selectedDocNos: selectedDocNos,
                              ),
                            ),
                          );
                        } else {
                          PanaraInfoDialog.showAnimatedGrow(
                            context,
                            title: widget.cuslang == 'EN' ? "Sorry" : "ขออภัย",
                            message: widget.cuslang == 'EN'
                                ? "The payment is not available at this time. Please contact the system administrator."
                                : "ไม่สามารถชำระเงินได้ขณะนี้ระบบปิดการชำระเงินชั่วคราว กรุณาติดต่อฝ่ายบริการลูกค้า",
                            buttonText: widget.cuslang == 'EN'
                                ? "Acknowledge"
                                : "รับทราบ",
                            onTapDismiss: () async {
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            panaraDialogType: PanaraDialogType.warning,
                            barrierDismissible: false,
                          );
                        }
                      },
                    ),
                    // IconButton(
                    //   icon: const Icon(
                    //     Icons.chevron_right,
                    //     color: Colors.green,
                    //   ),
                    //   onPressed: () async {
                    //     setState(() {
                    //       tap_pay = 1;
                    //       _serPayment = payser;
                    //       _serptPayment = payptser;
                    //     });
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => paymentSubV2InvAll(
                    //           mainScreenAnimation:
                    //               Tween<double>(begin: 0.0, end: 1.0).animate(
                    //                   CurvedAnimation(
                    //                       parent: widget
                    //                           .mainScreenAnimationController!,
                    //                       curve: Interval((1 / count) * 5, 1.0,
                    //                           curve: Curves.fastOutSlowIn))),
                    //           mainScreenAnimationController:
                    //               widget.mainScreenAnimationController!,
                    //           teNantModel: widget.teNantModel,
                    //           cuslang: widget.cuslang,
                    //           serPayment: payser.toString(),
                    //           serptPayment: payptser.toString(),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // )
                  ]),
                ],
              ),
            ),
            children: [
              const Divider(height: 1),
              const SizedBox(height: 8),
              ...(g.bill ?? const <Bill>[]).map(_billRow).toList(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 8),
                  Text(
                    widget.cuslang == "EN"
                        ? 'Note: The amount shown does not include any penalties/overdue payments that may occur.'
                        : 'หมายเหตุ:ยอดที่แสดงยังไม่รวมค่าปรับ/ชำระเกินกำหนดที่อาจเกิดขึ้น',
                    style: const TextStyle(
                      color: Colors.red,
                      fontFamily: Font_.Fonts_T,
                      // fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>?> _showBillSelectionDialog(List<Bill> bills) async {
    List<String> selectedDocNos = bills.map((b) => b.docno ?? '').toList();
    final isEN = widget.cuslang == 'EN';

    return await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEN ? 'Select bills to pay' : 'เลือกบิลที่ต้องการชำระ',
                    style: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontWeight: FontWeight.bold,
                        fontSize: 19),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isEN
                        ? 'Choose the items you want to proceed with.'
                        : 'เลือกรายการที่คุณต้องการดำเนินการต่อ',
                    style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                ],
              ),
              contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              content: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: bills.map((bill) {
                      final docno = bill.docno ?? '';
                      final isSelected = selectedDocNos.contains(docno);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.indigo.withOpacity(0.04)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? Colors.indigo.withOpacity(0.4)
                                : Colors.grey.shade200,
                            width: 1.2,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            setDialogState(() {
                              if (!isSelected) {
                                selectedDocNos.add(docno);
                              } else {
                                if (selectedDocNos.length > 1) {
                                  selectedDocNos.remove(docno);
                                } else {
                                  Fluttertoast.showToast(
                                    msg: isEN
                                        ? "Please select at least one bill."
                                        : "กรุณาเลือกอย่างน้อย 1 รายการ",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                }
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  activeColor: Colors.indigo,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  onChanged: (bool? value) {
                                    setDialogState(() {
                                      if (value == true) {
                                        selectedDocNos.add(docno);
                                      } else {
                                        if (selectedDocNos.length > 1) {
                                          selectedDocNos.remove(docno);
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: isEN
                                                ? "Please select at least one bill."
                                                : "กรุณาเลือกอย่างน้อย 1 รายการ",
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                          );
                                        }
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        docno,
                                        style: const TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_month_outlined,
                                              size: 13,
                                              color: Colors.grey.shade600),
                                          const SizedBox(width: 6),
                                          Text(
                                            fmtDate(bill.date),
                                            style: TextStyle(
                                                fontFamily: Font_.Fonts_T,
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      fmtMoney(bill.totalBill),
                                      style: const TextStyle(
                                          fontFamily: Font_.Fonts_T,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.indigo),
                                    ),
                                    Text(
                                      isEN ? 'THB' : 'บาท',
                                      style: TextStyle(
                                          fontFamily: Font_.Fonts_T,
                                          fontSize: 10,
                                          color: Colors.grey.shade500,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          isEN ? 'Cancel' : 'ยกเลิก',
                          style: TextStyle(
                              fontFamily: Font_.Fonts_T,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, selectedDocNos),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          isEN ? 'Confirm' : 'ยืนยัน',
                          style: const TextStyle(
                              fontFamily: Font_.Fonts_T,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
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
