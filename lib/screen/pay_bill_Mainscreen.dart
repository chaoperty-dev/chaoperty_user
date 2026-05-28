import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constant/Myconstant.dart';
import '../Model/GetCustomer_Model.dart';
import '../Model/GetInvoice_Model.dart';
import '../Model/GetInvoice_pay_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../color.dart';
import '../main.dart';
import '../screen_Intents_V3/payment_mainV3_InvAll.dart';
import 'Screen_new/fitness_app_home_screen.dart';
import 'Screen_new/fitness_app_theme.dart';
import 'Screen_new/training/training_pay_screen.dart';
import 'Screen_new/ui_view/running_view_pay.dart';
import 'model/contractInvoice.dart';
import 'pay_bill_PayMainscreen.dart';
import 'pay_bill_SubMainscreen.dart';
import 'pay_bill_screen_Choice.dart';

class PaybillMainScreen extends StatefulWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<TeNantModel>? teNantModel;
  final List<CustomerModel>? customerModel;
  final String? cuslang;
  const PaybillMainScreen(
      {super.key,
      this.mainScreenAnimationController,
      this.mainScreenAnimation,
      this.teNantModel,
      this.customerModel,
      this.cuslang});

  @override
  State<PaybillMainScreen> createState() => _PaybillMainScreenState();
}

class _PaybillMainScreenState extends State<PaybillMainScreen> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
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

  ////--------------------->
  @override
  void initState() {
    red_Invoice();
    // red_Invoice().then((value) => Check_genref_pay());
    Check_time();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Make sure to cancel the timer when widget is disposed
    super.dispose();
  }

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

    try {
      final url =
          'http://192.168.1.227/chao_api/GC_billGropInv_PaytypeV2.php?isAdd=true&ren=146&custno_inv=00007';
      final response = await http.get(Uri.parse(url));

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

    return (tap_pay == 1 && _serPayment != null)
        ?
        // PaybillPayMainScreen(
        //     mainScreenAnimation: widget.mainScreenAnimation,
        //     mainScreenAnimationController:
        //         widget.mainScreenAnimationController!,
        //     teNantModel: widget.teNantModel,
        //     cuslang: widget.cuslang,
        //     serpayment: _serPayment,
        //     customerModel: widget.customerModel,
        //   )

        paymentMainV3InvAll(
            mainScreenAnimation: widget.mainScreenAnimation,
            mainScreenAnimationController:
                widget.mainScreenAnimationController!,
            teNantModel: widget.teNantModel,
            cuslang: widget.cuslang,
            customerModel: widget.customerModel,
          )
        // paymentMainV3InvAll(
        //     mainScreenAnimation: widget.mainScreenAnimation,
        //     mainScreenAnimationController:
        //         widget.mainScreenAnimationController!,
        //     teNantModel: widget.teNantModel,
        //     cuslang: widget.cuslang,
        //     serpayment: _serPayment,
        //     serptpayment: _serptPayment,
        //     customerModel: widget.customerModel,
        //   )
        : AnimatedBuilder(
            animation: widget.mainScreenAnimationController!,
            builder: (_, __) => FadeTransition(
              opacity: widget.mainScreenAnimation!,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - widget.mainScreenAnimation!.value)),
                child: RefreshIndicator(
                  onRefresh: red_Invoice,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RunningViewPay(
                          animation: Tween<double>(begin: 0.0, end: 1.0)
                              .animate(CurvedAnimation(
                                  parent: widget.mainScreenAnimationController!,
                                  curve: Interval((1 / 5) * 3, 1.0,
                                      curve: Curves.fastOutSlowIn))),
                          animationController:
                              widget.mainScreenAnimationController!,
                          cuslang: widget.cuslang,
                          customerModel: widget.customerModel,
                        ),
                        _summaryCard(inv),
                        const SizedBox(height: 8),
                        // กลุ่มการชำระ
                        ...(inv.data ?? const <Data>[])
                            .map(_groupTile)
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  String fmtMoney(num? n) =>
      '${nFormat.format(double.parse((n ?? 0).toStringAsFixed(2)))}';
  String fmtInt(num? n) =>
      '${nFormat.format(double.parse((n ?? 0).toInt().toString()))}';

  // (n ?? 0).toInt().toString();

  String fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return DateFormat('dd-MM-yyyy').format(d);
  }

// แท็บสีตามสถานะสัญญา (ถ้าต้องการ)
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
  Widget _summaryCard(ContractInvoice inv) {
    // คำนวนสัดส่วนเทียบยอดรวม (กันหารศูนย์)
    final totalAll = (inv.totalAll ?? 0).toDouble();
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
            const SizedBox(height: 12),

            // กริด 2–4 คอลัมน์ตามความกว้าง
            LayoutBuilder(builder: (_, c) {
              final w = c.maxWidth;
              final cols = w >= 1100 ? 4 : (w >= 740 ? 3 : 2);
              final itemW = (w - ((cols - 1) * 10)) / cols;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _metricTile(
                    width: itemW,
                    icon: Icons.receipt_long,
                    label: isEN ? 'PVAT' : 'ก่อนภาษีมูลค่าเพิ่ม',
                    value: fmtInt(inv.pvatAll),
                    color: Colors.teal,
                    // สัดส่วน PVAT/Total
                    progress: ratio(inv.pvatAll ?? 0),
                  ),
                  _metricTile(
                    width: itemW,
                    icon: Icons.percent,
                    label: isEN ? 'VAT' : 'ภาษีมูลค่าเพิ่ม',
                    value: fmtMoney(inv.vatAll ?? 0),
                    color: Colors.orange,
                    progress: ratio(inv.vatAll ?? 0),
                  ),
                  _metricTile(
                    width: itemW,
                    icon: Icons.money_off_csred_outlined,
                    label: isEN ? 'WHT' : 'ภาษีหัก ณ ที่จ่าย',
                    value: fmtInt(inv.whtAll),
                    color: Colors.pink,
                    progress: ratio(inv.whtAll ?? 0),
                  ),
                  _metricTile(
                    width: itemW,
                    icon: Icons.payments,
                    label: isEN ? 'TOTAL' : 'ยอดสุทธิ',
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

// --------- Helpers (ใส่ในคลาสเดียวกัน) ---------

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
            // badge เปอร์เซ็นต์ (ซ่อนถ้า progress == 0)
            // if (progress > 0)
            //   Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //     decoration: BoxDecoration(
            //       color: color.withOpacity(.09),
            //       borderRadius: BorderRadius.circular(999),
            //       border: Border.all(color: color.withOpacity(.25), width: .7),
            //     ),
            //     child: Text(
            //       '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
            //       style: TextStyle(
            //         fontFamily: Font_.Fonts_T,
            //         fontWeight: FontWeight.w800,
            //         fontSize: 11,
            //         color: color.withOpacity(.95),
            //       ),
            //     ),
            //   ),
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
          // const SizedBox(height: 8),
          // // แถบสัดส่วน
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(6),
          //   child: LinearProgressIndicator(
          //     value: 100.00,
          //     //  progress.clamp(0, 1),
          //     minHeight: 7,
          //     backgroundColor: color.withOpacity(.12),
          //     valueColor: AlwaysStoppedAnimation<Color>(color),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _groupTile(Data g) {
    final payser = g.payser ?? null;
    final payptser = g.ptser ?? null;
    final bank = g.bank ?? '';
    final bno = g.bno ?? '';
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
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.receipt_long,
                      size: 15, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                      '${widget.cuslang == "EN" ? "PVAT" : "ก่อน VAT"}: ${fmtInt(g.pvatBill)}',
                      style: const TextStyle(
                          fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.percent, size: 15, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text('VAT: ${fmtMoney(g.vatBill ?? 0)}',
                      style: const TextStyle(
                          fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.money_off_csred_outlined,
                      size: 15, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text('WHT: ${fmtInt(g.whtBill)}',
                      style: const TextStyle(
                          fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.payments, size: 15, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                      '${widget.cuslang == "EN" ? "Total" : "ยอดรวม"}: ${fmtMoney(g.totalBill ?? 0)}',
                      style: const TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        tap_pay = 1;
                        _serPayment = payser;
                        _serptPayment = payptser;
                      });
                      // TODO: map Bill -> พารามิเตอร์ของ openPay()/PayBillscreenChoice
                      // ตัวอย่าง: openPayFromBill(b);
                    },
                  )
                ]),
              ],
            ),
          ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...(g.bill ?? const <Bill>[]).map(_billRow).toList(),
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
}
