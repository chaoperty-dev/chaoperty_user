import 'dart:async';
import 'dart:convert';
import 'package:chaoperty_user/screen_Intents/bankCodeMap.dart';
import 'package:chaoperty_user/screen_Intents/payment_subV2_InvAll.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant/Myconstant.dart';
import '../Model/GetCustomer_Model.dart';
import '../Model/GetInvoice_Model.dart';
import '../Model/GetInvoice_pay_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../color.dart';
import '../screen/Screen_new/fitness_app_home_screen.dart';
import '../screen/Screen_new/ui_view/running_view_pay.dart';
import '../screen/model/contractInvoice.dart';
import '../screen/pay_bill_screen.dart';

class paymentMainV2InvAll extends StatefulWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<TeNantModel>? teNantModel;
  final List<CustomerModel>? customerModel;
  final String? cuslang;
  const paymentMainV2InvAll(
      {super.key,
      this.mainScreenAnimationController,
      this.mainScreenAnimation,
      this.teNantModel,
      this.customerModel,
      this.cuslang});

  @override
  State<paymentMainV2InvAll> createState() => _paymentMainV2InvAllState();
}

class _paymentMainV2InvAllState extends State<paymentMainV2InvAll> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  String fmtMoney(num? n) =>
      '${nFormat.format(double.parse((n ?? 0).toStringAsFixed(2)))}';
  String fmtInt(num? n) =>
      '${NumberFormat("#,##0", "en_US").format(double.parse((n ?? 0).toInt().toString()))}';
  String fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return DateFormat('dd-MM-yyyy').format(d);
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
  Timer? _timer;
  String countdownText = '';
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
  }

  ////--------------------->
  @override
  void dispose() {
    _timer?.cancel(); // Make sure to cancel the timer when widget is disposed
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
    setState(() {
      coninv.clear();
      _isLoading = true; // <-- เปิดโหลด
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final custNo = preferences.getString('custno');
    try {
      final url =
          '${MyConstant().domain}/GC_billGropInv_UserPaytypeV2.php?isAdd=true&ren=146&custno_inv=$custNo';
      final response = await http.get(Uri.parse(url));
      print(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        debugPrint('raw: ${response.body}');

        if (decoded is Map<String, dynamic>) {
          final inv = ContractInvoice.fromJson(decoded);
          setState(() {
            coninv = [inv];
            _isLoading = false; // <-- ปิดโหลด
          });
        } else if (decoded is List) {
          final list = decoded
              .whereType<Map<String, dynamic>>()
              .map((e) => ContractInvoice.fromJson(e))
              .toList();
          setState(() {
            coninv = list;
            _isLoading = false; // <-- ปิดโหลด
          });
        } else {
          debugPrint('Unexpected JSON shape');
          setState(() => _isLoading = false);
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('red_Invoice error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading();
    if (coninv.isEmpty) return _buildEmptyState();

    final inv = coninv.first;
    final groups = inv.data ?? const <Data>[];
    if (groups.isEmpty) return _buildEmptyState(); // <-- เพิ่มบรรทัดนี้

    // Safe access
    final controller = widget.mainScreenAnimationController;
    final animation = widget.mainScreenAnimation;

    if (controller == null || animation == null) {
      // Fallback: No animation
      return RefreshIndicator(
        onRefresh: red_Invoice,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Use RunningViewPay safely if possible, or fallback?
              // RunningViewPay requires controller.
              // We'll skip RunningViewPay if no controller, or pass dummy?
              // For now, let's just show the list.
              _summaryCard(inv),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8),
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
              // กลุ่มการชำระ
              ...(inv.data ?? const <Data>[]).map(_groupTile).toList(),
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => FadeTransition(
        opacity: animation,
        child: Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: RefreshIndicator(
            onRefresh: red_Invoice,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RunningViewPay(
                    animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                            parent: controller,
                            curve: Interval((1 / 5) * 3, 1.0,
                                curve: Curves.fastOutSlowIn))),
                    animationController: controller,
                    cuslang: widget.cuslang,
                    customerModel: widget.customerModel,
                  ),
                  _summaryCard(inv),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 2, vertical: 2),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                  // กลุ่มการชำระ
                  ...(inv.data ?? const <Data>[]).map(_groupTile).toList(),
                ],
              ),
            ),
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
    // คำนวนสัดส่วนเทียบยอดรวม (กันหารศูนย์)
    final totalAll = (inv.totalAll ?? 0).toDouble();
    double totalDisendbill = (inv.totalDisendbill ?? 0).toDouble();

    // If root-level discount is 0, try to sum from data groups
    if (totalDisendbill == 0 && (inv.data?.isNotEmpty ?? false)) {
      totalDisendbill = (inv.data ?? []).fold<double>(
          0.0, (sum, item) => sum + (item.totalDisendbill ?? 0.0));
    }

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
                    value: fmtMoney(inv.totalAll ?? 0),
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
      elevation: 0.4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          childrenPadding: const EdgeInsets.only(left: 6, right: 6, bottom: 12),
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
                        ? (bankEn ?? bank) + ' ($bankCode)'
                        : bank + ' ($bankCode)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5)),
              ),
              const SizedBox(width: 4),
              chip(widget.cuslang == 'EN' ? 'Bills' : 'ใบแจ้งหนี้',
                  Colors.indigo.withOpacity(.08), Colors.indigo.shade700),
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
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Spacer(),
                  const Icon(Icons.receipt, size: 15, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                      '${widget.cuslang == "EN" ? "Bill All  : ${(g.bill ?? []).length} " : "บิลทั้งหมด  : ${(g.bill ?? []).length} "}',
                      style: const TextStyle(
                          color: Colors.grey,
                          fontFamily: Font_.Fonts_T,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  InkWell(
                    child: SizedBox(
                      // width: 100,
                      child: Row(
                        children: [
                          Text(
                              '${widget.cuslang == "EN" ? "Press to pay" : "กดเพื่อชำระ"}',
                              style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  // decorationThickness: 2.0,
                                  // decorationStyle: TextDecorationStyle.wavy,
                                  color: Colors.green,
                                  fontFamily: Font_.Fonts_T,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700)),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.green,
                          )
                        ],
                      ),
                    ),
                    onTap: () async {
                      setState(() {
                        tap_pay = 1;
                        _serPayment = payser;
                        _serptPayment = payptser;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => paymentSubV2InvAll(
                            mainScreenAnimation:
                                widget.mainScreenAnimationController != null
                                    ? Tween<double>(begin: 0.0, end: 1.0)
                                        .animate(CurvedAnimation(
                                            parent: widget
                                                .mainScreenAnimationController!,
                                            curve: Interval(
                                                (1 / count) * 5, 1.0,
                                                curve: Curves.fastOutSlowIn)))
                                    : null,
                            mainScreenAnimationController:
                                widget.mainScreenAnimationController,
                            teNantModel: widget.teNantModel,
                            cuslang: widget.cuslang,
                            serPayment: payser.toString(),
                            serptPayment: payptser.toString(),
                          ),
                        ),
                      );
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
    );
  }
}
