import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Api_V2/payment_intents.dart';
import '../Api_V2/payment_intents_upslip.dart';
import '../Api_V2/payment_qr_session.dart';
import '../CRC_16_Prompay/generate_qrcode.dart';
import '../Constant/Myconstant.dart';
import '../Model/GetCustomer_Model.dart';
import '../Model/GetInvoice_Model.dart';
import '../Model/GetInvoice_pay_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/Model_V2/payment_IntentsModel.dart';
import '../color.dart';
import '../main.dart';
import 'Screen_new/fitness_app_home_screen.dart';
import 'Screen_new/fitness_app_theme.dart';
import 'Screen_new/training/training_pay_screen.dart';
import 'model/contractInvoice.dart';
import 'pay_bill_screen_Choice.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'dart:ui' as ui; // ✅ use only alias
// late import to keep mobile build safe
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' if (dart.library.io) 'package:chaoperty_user/fake_html.dart'
    as html;
// NOTE: do NOT import dart:html at top-level to keep iOS/Android builds working.

class PaybillPayMainScreen extends StatefulWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<TeNantModel>? teNantModel;
  final String? cuslang;
  final int? serpayment;
  final List<CustomerModel>? customerModel;
  final String? intentUuid;
  final Data datas;

  const PaybillPayMainScreen({
    super.key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
    this.teNantModel,
    this.cuslang,
    this.serpayment,
    this.customerModel,
    this.intentUuid,
    required this.datas,
  });

  @override
  State<PaybillPayMainScreen> createState() => _PaybillPayMainScreenState();
}

class _PaybillPayMainScreenState extends State<PaybillPayMainScreen> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  DateTime datex = DateTime.now();
  int tap_pay = 0;
  ////--------------------->
  List<InvoicePayModel> invoicePayModels = [];
  List<InvoiceModel> _InvoiceModels = [];
  List<InvoiceModel> invoicePayModels2 = [];
  List<dynamic> InvoicePay = [];
  ////--------------------->

  int ref_new = 0;
  double requestedAmount = 0.00;
  String? return_qr_img,
      qr_payload,
      invoiceAll,
      qr_softExpiresAt,
      qr_expiresAt,
      return_qr_refapi1,
      return_qr_refapi2,
      return_img;
  bool _isLoading = true;
  Timer? _timer;
  String countdownText = '';

  final Map<String, Map<String, String>> bankCodeMap = {
    'ธนาคารกรุงเทพ': {'code': 'BBL', 'en': 'Bangkok Bank', 'logo': 'BBL.png'},
    'ธนาคารกสิกรไทย': {
      'code': 'KBANK',
      'en': 'Kasikornbank',
      'logo': 'KBANK.png'
    },
    'ธนาคารกรุงไทย': {
      'code': 'KTB',
      'en': 'Krung Thai Bank',
      'logo': 'KTB.png'
    },
    'ธนาคารทหารไทยธนชาต': {
      'code': 'TTB',
      'en': 'TMBThanachart Bank',
      'logo': 'TTB.png'
    },
    'ธนาคารไทยพาณิชย์': {
      'code': 'SCB',
      'en': 'Siam Commercial Bank',
      'logo': 'SCB.png'
    },
    'ธนาคารกรุงศรีอยุธยา': {
      'code': 'BAY',
      'en': 'Bank of Ayudhya',
      'logo': 'BAY.png'
    },
    'ธนาคารเกียรตินาคินภัทร': {
      'code': 'KKP',
      'en': 'Kiatnakin Phatra Bank',
      'logo': 'KKP.png'
    },
    'ธนาคารซีไอเอ็มบีไทย': {
      'code': 'CIMBT',
      'en': 'CIMB Thai Bank',
      'logo': 'CIMBT.png'
    },
    'ธนาคารทิสโก้': {'code': 'TISCO', 'en': 'TISCO Bank', 'logo': 'TISCO.png'},
    'ธนาคารยูโอบี': {
      'code': 'UOBT',
      'en': 'United Overseas Bank (Thai)',
      'logo': 'UOBT.png'
    },
    'ธนาคารไทยเครดิตเพื่อรายย่อย': {
      'code': 'TCD',
      'en': 'Thai Credit Retail Bank',
      'logo': 'TCD.png'
    },
    'ธนาคารแลนด์ แอนด์ เฮ้าส์': {
      'code': 'LHFG',
      'en': 'Land and Houses Bank',
      'logo': 'LHFG.png'
    },
    'ธนาคารไอซีบีซี (ไทย)': {
      'code': 'ICBCT',
      'en': 'ICBC (Thai)',
      'logo': 'ICBCT.png'
    },
    'ธนาคารพัฒนาวิสาหกิจขนาดกลางและขนาดย่อมแห่งประเทศไทย': {
      'code': 'SME',
      'en': 'SME Development Bank',
      'logo': 'SME.png'
    },
    'ธนาคารเพื่อการเกษตรและสหกรณ์การเกษตร': {
      'code': 'BAAC',
      'en': 'Bank for Agriculture and Agricultural Cooperatives',
      'logo': 'BAAC.png'
    },
    'ธนาคารออมสิน': {
      'code': 'GSB',
      'en': 'Government Savings Bank',
      'logo': 'GSB.png'
    },
    'ธนาคารอาคารสงเคราะห์': {
      'code': 'GHB',
      'en': 'Government Housing Bank',
      'logo': 'GHB.png'
    },
    'ธนาคารอิสลามแห่งประเทศไทย': {
      'code': 'ISBT',
      'en': 'Islamic Bank of Thailand',
      'logo': 'ISBT.png'
    },
    'ธนาคารอิสลามแห่งประเทศไทย2': {
      'code': 'ISBT2',
      'en': 'Islamic Bank of Thailand 2',
      'logo': 'ISBT2.png'
    },
    'BeamCheckOut': {'code': 'BEAM', 'en': 'Beam Checkout', 'logo': 'BEAM.png'},
    'ທະນາຄານການຄ້າຕ່າງປະເທດລາວ': {
      'code': 'BCEL',
      'en': 'Banque Pour Le Commerce Exterieur Lao',
      'logo': 'BCEL.png'
    },
    'Lao Development Bank': {
      'code': 'LDB',
      'en': 'Lao Development Bank',
      'logo': 'LDB.png'
    },
  };

  // Mapping (อย่างง่าย) จาก bank_merchant_id -> ชื่อธนาคาร (ไทย)
  // ปรับตามของจริงที่ระบบคุณใช้
  final Map<int, String> bankMerchantIdToThaiName = {
    1: 'ธนาคารกรุงเทพ',
    2: 'ธนาคารกสิกรไทย',
    3: 'ธนาคารกรุงไทย',
    4: 'ธนาคารไทยพาณิชย์',
    5: 'ธนาคารกรุงศรีอยุธยา',
    6: 'ธนาคารทหารไทยธนชาต',
    7: 'ธนาคารยูโอบี',
    8: 'ธนาคารเกียรตินาคินภัทร',
    9: 'ธนาคารกสิกรไทย', // <-- ตัวอย่าง: ใส่ให้ id=9 โยงกับ KBANK (ปรับตามจริง)
  };

  // บันทึกบิลที่ถูกเลือก (key = docno)
  final Set<String> _selectedDocnos = {};
  List<PaymentIntent> paymentIntents = [];

  @override
  void initState() {
    redPaymentIntents();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // helpers
  String _fmtDT(DateTime? d) =>
      d == null ? '-' : DateFormat('d-MM-yyyy HH:mm').format(d.toLocal());
  List<ContractInvoice> coninv = [];

  // ===== Helper: กรองตาม payser แล้วคำนวณยอดรวมใหม่ =====
  ContractInvoice filterByPayser(ContractInvoice inv, int targetPayser) {
    final groups = (inv.data ?? const <Data>[])
        .where((d) => (d.payser ?? -1) == targetPayser)
        .toList();

    final billAll =
        groups.fold<int>(0, (sum, g) => sum + (g.bill?.length ?? 0));
    final pvatAll = groups.fold<double>(0, (sum, g) => sum + (g.pvatBill ?? 0));
    final vatAll =
        groups.fold<double>(0.0, (sum, g) => sum + (g.vatBill ?? 0.0));
    final whtAll = groups.fold<double>(0, (sum, g) => sum + (g.whtBill ?? 0));
    final totalAll =
        groups.fold<double>(0.0, (sum, g) => sum + (g.totalBill ?? 0.0));

    return ContractInvoice(
      billAll: billAll,
      pvatAll: pvatAll,
      vatAll: vatAll,
      whtAll: whtAll,
      totalAll: totalAll,
      data: groups,
    );
  }

  Iterable<String> _collectAllBillDocnos(List<ContractInvoice> cons) sync* {
    for (final c in cons) {
      for (final g in (c.data ?? const <Data>[])) {
        for (final b in (g.bill ?? const <Bill>[])) {
          final id = b.docno?.trim();
          if (id != null && id.isNotEmpty) yield id;
        }
      }
    }
  }

  // === NEW: build ContractInvoice model from intent JSON structure ===
  ContractInvoice _buildContractFromIntent(Map<String, dynamic> data) {
    final invoices = (data['invoices'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    // group bills by payser
    final Map<int, List<Bill>> byPayser = {};
    double totalPvat = 0.0;
    double totalVat = 0.0;
    double totalWht = 0.0;
    double totalAmount = 0.0;
    int totalCount = 0;

    for (final inv in invoices) {
      final metaList = (inv['metadata'] as List? ?? const []);
      if (metaList.isEmpty) continue;
      final m = metaList.first as Map<String, dynamic>;

      final payser = (m['payser'] as num?)?.toInt() ?? -1;
      final pvat = (m['pvat_bill'] as num?)?.toDouble() ?? 0.0;
      final vat = (m['vat_bill'] as num?)?.toDouble() ?? 0.0;
      final wht = (m['wht_bill'] as num?)?.toDouble() ?? 0.0;
      final total = (m['total_bill'] as num?)?.toDouble() ??
          double.tryParse('${inv['original_amount']}') ??
          0.0;

      final bill = Bill(
        docno: m['docno']?.toString(),
        date: m['date']?.toString(),
        cid: m['cid']?.toString(),
        totalBill: total,
        st: m['st']?.toString(),
      );

      byPayser.putIfAbsent(payser, () => <Bill>[]).add(bill);

      totalPvat += pvat;
      totalVat += vat;
      totalWht += wht;
      totalAmount += total;
      totalCount += 1;
    }

    final bankMerchantId = (data['bank_merchant_id'] as num?)?.toInt();
    final thaiBankName = bankMerchantIdToThaiName[bankMerchantId ?? -999] ?? '';

    final groups = <Data>[];
    byPayser.forEach((payser, bills) {
      final sumPvat = bills.fold<double>(0, (s, b) => s + ((b.pvatBill ?? 0)));
      final sumVat =
          bills.fold<double>(0.0, (s, b) => s + ((b.vatBill ?? 0.0)));
      final sumWht = bills.fold<double>(0, (s, b) => s + ((b.whtBill ?? 0)));
      final sumTotal =
          bills.fold<double>(0.0, (s, b) => s + (b.totalBill ?? 0.0));

      groups.add(Data(
        bank: thaiBankName,
        bno: null,
        payser: payser,
        bill: bills,
        pvatBill: sumPvat,
        vatBill: sumVat,
        whtBill: sumWht,
        totalBill: sumTotal,
      ));
    });

    return ContractInvoice(
      billAll: totalCount,
      pvatAll: totalPvat,
      vatAll: totalVat,
      whtAll: totalWht,
      totalAll: totalAmount,
      data: groups,
    );
  }

  Future<void> redPaymentIntents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      paymentIntents.clear();
    });

    try {
      final uuid = widget.intentUuid.toString();
      final response =
          await getPaymentIntentsUuid(cusno: '00007', intentsUuid: uuid);
      if (response == null) {
        debugPrint('❌ ไม่มี response จาก server');
        return;
      }

      final root = json.decode(response.body);
      if (root is! Map<String, dynamic>) {
        debugPrint('❌ รูปแบบ JSON ไม่ใช่ Map<String, dynamic>');
        return;
      }

      final data = root['data'];

      // ✅ รองรับทั้ง object และ list
      late final List<PaymentIntent> intents;
      Map<String, dynamic>? firstDataObj;
      if (data is Map<String, dynamic>) {
        intents = [PaymentIntent.fromJson(data)];
        firstDataObj = data;
      } else if (data is List) {
        intents = data
            .whereType<Map<String, dynamic>>()
            .map(PaymentIntent.fromJson)
            .toList();
        firstDataObj = data.isNotEmpty && data.first is Map<String, dynamic>
            ? data.first as Map<String, dynamic>
            : null;
      } else {
        intents = const [];
      }

      // ===== build coninv from the same JSON (so UI is not empty) =====
      if (firstDataObj != null) {
        try {
          final ci = _buildContractFromIntent(firstDataObj);
          if (mounted) {
            final payserFilter = widget.serpayment;
            final useCi =
                (payserFilter != null) ? filterByPayser(ci, payserFilter) : ci;
            setState(() {
              coninv = [useCi];
            });
          }

          // wire QR session fields
          final sess =
              (firstDataObj['active_qr_session'] as Map<String, dynamic>?) ??
                  const {};
          qr_payload = (sess['qr_payload'] as String?)?.trim();
          return_qr_refapi1 = (sess['ref1']?.toString() ?? '').trim();
          return_qr_refapi2 = (sess['ref2']?.toString() ?? '').trim();
          qr_softExpiresAt =
              (intents.first.softExpireAt?.toString() ?? '').trim();
          qr_expiresAt = (sess['expires_at']?.toString() ?? '').trim();

          requestedAmount =
              double.parse((sess['amount']?.toString() ?? '0').trim()) ?? 0;
        } catch (e) {
          debugPrint('❌ Build ContractInvoice failed: $e');
        }
      }

      if (!mounted) return;
      setState(() {
        paymentIntents = intents;
      });

      debugPrint('✅ intents loaded: ${intents.length}');
    } catch (e, st) {
      debugPrint('❌ Exception parsing payment intents: $e');
      debugPrint('🧭 StackTrace:\n$st');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  final GlobalKey qrBlockKey = GlobalKey();

  // ===== Web-only saver (kept inside function to avoid import crash on mobile) =====
  Future<void> downloadWidgetAsPng(
    GlobalKey key, {
    String fileName = 'QRPAY.png',
  }) async {
    // รอให้เฟรมวาดเสร็จก่อน เผื่อ boundary ยังไม่พร้อม
    await WidgetsBinding.instance.endOfFrame;

    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null || key.currentContext == null) return;

    // 🎯 ใช้ DPR ของ context ปัจจุบัน (สำคัญมากบน Web-HTML)
    final dpr = MediaQuery.devicePixelRatioOf(key.currentContext!);

    // สร้างภาพด้วย DPR ที่ถูกต้อง
    final image = await boundary.toImage(pixelRatio: dpr);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final pngBytes = byteData.buffer.asUint8List();

    final blob = html.Blob([pngBytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';
    html.document.body!.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }

  Widget _stepItem({required int index, required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(.08),
              borderRadius: BorderRadius.circular(999),
              border:
                  Border.all(color: Colors.indigo.withOpacity(.25), width: .7),
            ),
            child: Text(
              '$index',
              style: TextStyle(
                fontFamily: Font_.Fonts_T,
                fontWeight: FontWeight.w900,
                color: Colors.indigo.shade700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: Font_.Fonts_T,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading();
    if (paymentIntents.isEmpty && coninv.isEmpty) return _buildEmptyState();

    if (coninv.isEmpty || (coninv.first.data?.isEmpty ?? true)) {
      // allow UI to show even if coninv missing groups (but we have intents)
      return _buildEmptyState();
    }

    final inv = coninv.first;
    final groups = inv.data ?? const <Data>[];

    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (_, __) => FadeTransition(
        opacity: widget.mainScreenAnimation!,
        child: Transform.translate(
          offset: Offset(0, 30 * (1 - widget.mainScreenAnimation!.value)),
          child: RefreshIndicator(
            onRefresh: redPaymentIntents,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...(inv.data ?? const <Data>[]).map(_groupTileSub).toList(),
                  const SizedBox(height: 8),
                  _selectedBar(),
                  const SizedBox(height: 8),
                  ...(inv.data ?? const <Data>[]).map(_groupTile).toList(),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (_, c) {
                      // ---------- 3) เตรียมข้อมูลแสดงผล ----------
                      Widget step(int i, String t) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.orange.shade600.withOpacity(.08),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                        color: Colors.orange.shade600
                                            .withOpacity(.25),
                                        width: .7),
                                  ),
                                  child: Text('$i',
                                      style: TextStyle(
                                          fontFamily: Font_.Fonts_T,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.orange.shade800)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(t,
                                        style: const TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            fontSize: 13.5))),
                              ],
                            ),
                          );
                      final maxW = c.maxWidth.clamp(0, 680).toDouble();
                      final isNarrow = maxW < 520;
                      // final String expireStr =
                      //     _fmtDT(DateTime.parse(qr_softExpiresAt.toString()));
                      // ---------- 1) ถ้าหมดอายุแล้ว----------
                      final softExpiresAtIso =
                          qr_softExpiresAt?.toString() ?? '';
                      final softexpiresAt = DateTime.tryParse(softExpiresAtIso);
                      final isSoftExpired = softexpiresAt != null &&
                          DateTime.now().isAfter(softexpiresAt);

                      final double btnWidth =
                          isNarrow ? double.infinity : (maxW - 10) / 2;

                      Widget buildBtn(Widget child) =>
                          SizedBox(width: btnWidth, height: 48, child: child);

                      final attachBtn = buildBtn(_secondaryAction(
                        icon: Icons.image,
                        label: widget.cuslang == 'EN'
                            ? 'Attach proof of payment'
                            : 'แนบหลักฐานการชำระ',
                        onTap: () async {
                          final slip = await payPickAndUpload(
                            reportedDate:
                                DateFormat('yyyy-MM-dd').format(DateTime.now()),
                            intentUuid: widget.intentUuid!,
                          );

                          if (slip != null) {
                            // slip['base64'], slip['extension']
                            // จะเอาไปแสดงรูป หรือส่งต่อ API อื่นก็ได้
                            await ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'อัปโหลดสำเร็จ',
                                ),
                              ),
                            );
                            redPaymentIntents();
                          }
                        },
                      ));

                      final qrBtn = buildBtn(
                        _primaryAction(
                          icon: Icons.qr_code,
                          label: isSoftExpired
                              ? (widget.cuslang == 'EN'
                                  ? 'Expired QR Code'
                                  : 'หมดอายุ QR Code')
                              : (widget.cuslang == 'EN'
                                  ? 'Show QR Code'
                                  : 'แสดง QR Code'),
                          color: isSoftExpired ? Colors.grey : Colors.indigo,
                          onTap: isSoftExpired
                              ? () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Center(
                                        child: Text('QR Code หมดอายุ'),
                                      ),
                                      content: SizedBox(
                                        height: 200,
                                        child: Column(
                                          children: [
                                            step(1,
                                                'หากชำระสำเร็จแล้วให้กดแนบหลักฐานการชำระ'),
                                            step(2,
                                                'หากหมดเวลารับชำระและยังไม่ได้ชำระให้กด "Gen QR" อีกครั้ง'),
                                            step(3,
                                                'หากยังไม่ได้ชำระแล้วเกิดข้อผิดพลาดใดๆ ให้ "หยุดการชำระ" ไว้ก่อนแล้วติดต่อเจ้าหน้าที่ทันที'),
                                            step(4,
                                                'หากข้อผิดพลาดอื่นๆ กรุณาติดต่อเจ้าหน้าที่ทันที'),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('ตกลง'),
                                        ),
                                      ],
                                    ),
                                  );
                                  return; // ✅ จบ onTap ตรงนี้
                                }
                              : _openQrSheet, // ✅ ยังไม่หมดอายุ -> เปิด QR sheet ตามปกติ
                        ),
                      );

                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: isNarrow
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                      attachBtn,
                                      const SizedBox(height: 10),
                                      qrBtn
                                    ])
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      attachBtn,
                                      const SizedBox(width: 10),
                                      qrBtn
                                    ]),
                        ),
                      );
                    },
                  ),
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
      '${NumberFormat("#,##0", "en_US").format(double.parse((n ?? 0).toInt().toString()))}';

  String fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return DateFormat('dd-MM-yyyy').format(d);
  }

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

  Future<bool> _renewQrAndReload() async {
    try {
      final resp = await putPaymentIntentsQRsession(
        intentsUuid: widget.intentUuid!,
        bankMerchantId: widget.datas.payser.toString(),
        bankMerchantType: widget.datas.ptser.toString(),
        ref2: '',
      );
      if (resp == null || resp.statusCode < 200 || resp.statusCode >= 300) {
        debugPrint('renew fail: ${resp?.statusCode} ${resp?.body}');
        return false;
      }

      final root = json.decode(resp.body);
      setState(() {
        qr_expiresAt = root['data']['expires_at']; // ISO8601
        return_qr_refapi1 = root['data']['ref1']; // ISO8601
        return_qr_refapi2 = root['data']['ref2']; // ISO8601
      });
      return true;
    } catch (e, st) {
      debugPrint('renew exception: $e\n$st');
      return false;
    }
  }

  Future<void> _openQrSheet() async {
    // ---------- 1) ถ้าหมดอายุแล้วให้ขอ renew ก่อน ----------
    final expiresAtIso = qr_expiresAt?.toString() ?? '';
    final expiresAt = DateTime.tryParse(expiresAtIso);
    final isExpired = expiresAt != null && DateTime.now().isAfter(expiresAt);

    if (isExpired) {
      debugPrint('❌ QR หมดอายุแล้ว → ขอ renew');
      final ok =
          await _renewQrAndReload(); // คุณต้องมีฟังก์ชันนี้ (ดูตัวอย่างในข้อความก่อนหน้า)
      if (!mounted) return;
      if (!ok) {
        // แจ้งผู้ใช้แล้วหยุด
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.cuslang == 'EN'
                  ? 'Renew QR failed, please try again.'
                  : 'ต่ออายุ QR ไม่สำเร็จ กรุณาลองอีกครั้ง',
            ),
          ),
        );
        return;
      }
    }

    // ---------- 2) ตั้งค่าเวลาหมดอายุ/ตัวช่วยแสดงผล ----------
    // ใช้ค่าล่าสุด (อาจถูกอัปเดตจาก renew)
    final String nowExpiresIso = qr_expiresAt?.toString() ?? '';
    final DateTime expiryLocal =
        (DateTime.tryParse(nowExpiresIso) ?? DateTime.now()).toLocal();
    final DateTime expiryUtc = expiryLocal.toUtc();

    // อายุเต็ม (วินาที) — หากระบบคุณรู้แน่ชัดว่า 5 นาที ให้คง 300
    // หรือจะคำนวณจาก now→expiry ตอนเปิดก็ได้
    const int _totalSecs = 300;

    int secondsUntilExpire() {
      final nowUtc = DateTime.now().toUtc();
      final sec = expiryUtc.difference(nowUtc).inSeconds;
      return sec < 0 ? 0 : sec;
    }

    String _hhmmssFromSecs(int secs) {
      final h = (secs ~/ 3600).toString().padLeft(2, '0');
      final m = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
      final s = (secs % 60).toString().padLeft(2, '0');
      return '$h:$m:$s';
    }

    String _fmtExpireLocal(String? isoUtc) {
      final d =
          (isoUtc == null || isoUtc.isEmpty) ? null : DateTime.tryParse(isoUtc);
      if (d == null) return '-';
      return DateFormat('d-MM-yyyy HH:mm').format(d.toLocal());
    }

    final ref1 = return_qr_refapi1 ?? '-';
    final ref2 = return_qr_refapi2 ?? '-';
    final bno = widget.datas.bno ?? '-';
    final bname = widget.datas.bname ?? '-';
    final imgUrl = (MyConstant().domain_chao) + (widget.datas.img ?? '');
    final amtStr =
        nFormat.format(double.tryParse('${requestedAmount ?? 0}') ?? 0);
    final amtRaw =
        (double.tryParse('${requestedAmount ?? 0}') ?? 0).toStringAsFixed(2);
    final ptser = '${widget.datas.ptser}'; // ช่องทาง
    final expLbl = _fmtExpireLocal(qr_expiresAt); // แสดงเวลา local

    // payload สำหรับ QR ตาม ptser
    final qrData = (ptser == '7')
        ? qr_payload.toString()
        : (ptser == '6')
            ? '|$bno\r$ref1\r$ref2\r${amtRaw.replaceAll('.', '')}'
            : (ptser == '5')
                ? generateQRCode(
                    promptPayID: bno, amount: double.tryParse(amtRaw) ?? 0)
                : '';

    // ---------- 4) เปิดแผ่น QR ----------
    await showStickyFlexibleBottomSheet<void>(
      context: context,
      isDismissible: false, // ห้ามกดนอกเพื่อปิด
      isCollapsible: false, // ห้ามยุบลง
      isSafeArea: true,
      minHeight: 0.48,
      initHeight: 1.0,
      maxHeight: 1.0,
      anchors: const [0.48, 0.55, 1.0],
      headerHeight: 70,
      bottomSheetColor: Colors.white,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      // ------------ Header ------------
      headerBuilder: (ctx, _) => Material(
        child: Container(
          height: 70,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 4, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                              color: Colors.white30,
                              borderRadius: BorderRadius.circular(999)))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(ctx).pop(),
                        tooltip: widget.cuslang == 'EN' ? 'Close' : 'ปิด',
                      ),
                      const SizedBox(width: 6),
                      // Countdown + Progress (อ้างอิงวินาทีเดียว)
                      Expanded(
                        child: StreamBuilder<int>(
                          stream: Stream.periodic(
                            const Duration(seconds: 1),
                            (_) => secondsUntilExpire(),
                          ),
                          initialData: secondsUntilExpire(),
                          builder: (_, snap) {
                            final secs = (snap.data ?? 0);
                            final clamped = secs < 0 ? 0 : secs;
                            final prog = (clamped / _totalSecs).clamp(0.0, 1.0);

                            final label = widget.cuslang == 'EN'
                                ? (clamped == 0
                                    ? 'Expired'
                                    : 'Expire ${_hhmmssFromSecs(clamped)}')
                                : (clamped == 0
                                    ? 'หมดอายุแล้ว'
                                    : 'หมดอายุ ${_hhmmssFromSecs(clamped)}');

                            // ถ้าหมดอายุแล้ว – ปิดแผ่น + เสนอให้ต่ออายุ
                            if (clamped == 0) {
                              Future.microtask(() async {
                                if (!mounted) return;
                                Navigator.of(ctx).maybePop();
                                // คุณจะเรียก _renewQrAndReload() ที่นี่ก็ได้
                              });
                            }

                            return Row(
                              children: [
                                Icon(
                                  clamped == 0 ? Icons.timer_off : Icons.timer,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: prog,
                                      minHeight: 6,
                                      backgroundColor: Colors.white24,
                                      valueColor: AlwaysStoppedAnimation(
                                        clamped == 0
                                            ? Colors.redAccent
                                            : Colors.amber,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ------------ Body ------------
      bodyBuilder: (_, __) => SliverChildListDelegate([
        const Divider(height: 1),
        LayoutBuilder(builder: (context, c) {
          final maxW = c.maxWidth;
          final isMobile = maxW < 480;
          final isTablet = maxW >= 480 && maxW < 900;
          final isDesktop = maxW >= 900;
          final double contentW =
              isDesktop ? 980 : (isTablet ? 720 : double.infinity);
          final double cardW =
              isDesktop ? 720 : (isTablet ? 560 : double.infinity);
          final qrSize = isDesktop ? 260.0 : (isTablet ? 220.0 : 180.0);
          final pad = EdgeInsets.fromLTRB(isDesktop ? 24 : 16,
              isMobile ? 12 : 16, isDesktop ? 24 : 16, isMobile ? 24 : 24);

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentW),
              child: Padding(
                padding: pad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.cuslang == 'EN'
                          ? 'Scan this QR code to pay.'
                          : 'สแกน QR นี้เพื่อชำระเงิน',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.w700,
                          fontSize: isDesktop ? 16 : 14,
                          color: Colors.black.withOpacity(.65)),
                    ),
                    const SizedBox(height: 6),

                    // กล่อง QR + countdown ซ้ำ (อ้างอิง secondsUntilExpire เดียวกัน)
                    StreamBuilder<int>(
                      stream: Stream.periodic(
                        const Duration(seconds: 1),
                        (_) => secondsUntilExpire(),
                      ),
                      initialData: secondsUntilExpire(),
                      builder: (_, snap) {
                        final secs = snap.data ?? 0;
                        final prog = (secs / _totalSecs).clamp(0.0, 1.0);

                        return Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: cardW),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.black12, width: .5),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(.06),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8))
                                ],
                              ),
                              padding: const EdgeInsets.all(2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  RepaintBoundary(
                                    key: qrBlockKey,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: Colors.black12, width: .5),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(.06),
                                              blurRadius: 16,
                                              offset: const Offset(0, 8))
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        children: [
                                          if (prog == 0) ...[
                                            SizedBox(
                                              width: double.infinity,
                                              height: qrSize + qrSize,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.qr_code,
                                                      color: Colors.redAccent,
                                                      size: 40),
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    'หมดเวลา QR',
                                                    style: TextStyle(
                                                      fontFamily: Font_.Fonts_T,
                                                      color: Colors.black54,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  ElevatedButton.icon(
                                                    icon: const Icon(
                                                        Icons.refresh),
                                                    label: Text(
                                                      widget.cuslang == 'EN'
                                                          ? 'Renew QR'
                                                          : 'ขอ QR ใหม่',
                                                    ),
                                                    onPressed: () async {
                                                      final ok =
                                                          await _renewQrAndReload();
                                                      if (!mounted) return;
                                                      if (ok) {
                                                        Navigator.of(context)
                                                            .pop();
                                                        _openQrSheet();
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(widget
                                                                        .cuslang ==
                                                                    'EN'
                                                                ? 'Renew QR failed, please try again.'
                                                                : 'ต่ออายุ QR ไม่สำเร็จ กรุณาลองอีกครั้ง'),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ] else if (ptser == '2') ...[
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: Image.network(
                                                imgUrl.isNotEmpty
                                                    ? imgUrl
                                                    : 'https://via.placeholder.com/300x300?text=No+QR',
                                                width: double.infinity,
                                                height: qrSize + qrSize,
                                                fit: BoxFit.contain,
                                                loadingBuilder:
                                                    (context, child, progress) {
                                                  if (progress == null) {
                                                    return child;
                                                  }
                                                  return SizedBox(
                                                    height: qrSize + qrSize,
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: progress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? progress
                                                                    .cumulativeBytesLoaded /
                                                                (progress
                                                                        .expectedTotalBytes ??
                                                                    1)
                                                            : null,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    width: double.infinity,
                                                    height: qrSize + qrSize,
                                                    color: Colors.grey.shade200,
                                                    alignment: Alignment.center,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: const [
                                                        Icon(
                                                            Icons.error_outline,
                                                            color: Colors
                                                                .redAccent,
                                                            size: 40),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          'ไม่สามารถโหลด QR ได้',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ] else if (ptser == '7' ||
                                              ptser == '6' ||
                                              ptser == '5') ...[
                                            Image.asset(
                                              'assets/images/thai_qr_payment.png',
                                              width: double.infinity,
                                              fit: BoxFit.contain,
                                            ),
                                            SizedBox(
                                                height: isMobile ? 10 : 12),
                                            PrettyQr(
                                              size: qrSize,
                                              data: qrData.isNotEmpty
                                                  ? qrData
                                                  : 'EMPTY',
                                              image: const AssetImage(
                                                  'assets/images/icon_thaiqr.png'),
                                              errorCorrectLevel:
                                                  QrErrorCorrectLevel.M,
                                              roundEdges: true,
                                            ),
                                          ] else ...[
                                            Container(
                                              width: double.infinity,
                                              height: qrSize + qrSize,
                                              color: Colors.grey.shade200,
                                              alignment: Alignment.center,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(Icons.error_outline,
                                                      color: Colors.redAccent,
                                                      size: 40),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'ไม่สามารถโหลด QR ได้',
                                                    style: TextStyle(
                                                      fontFamily: Font_.Fonts_T,
                                                      color: Colors.black54,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          SizedBox(height: isMobile ? 8 : 10),
                                          Text(
                                            amtStr,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: Font_.Fonts_T,
                                              fontWeight: FontWeight.w700,
                                              fontSize: isDesktop ? 18 : 16,
                                              color: Colors.red.shade900,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            bname,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: Font_.Fonts_T,
                                              fontWeight: FontWeight.w700,
                                              fontSize: isDesktop ? 16 : 14,
                                              color:
                                                  Colors.black.withOpacity(.65),
                                            ),
                                          ),
                                          Text(
                                            bno.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: Font_.Fonts_T,
                                              fontWeight: FontWeight.w700,
                                              fontSize: isDesktop ? 16 : 14,
                                              color:
                                                  Colors.black.withOpacity(.65),
                                            ),
                                          ),
                                          Divider(
                                              height: 2,
                                              color: Colors.grey.shade600),
                                          const SizedBox(height: 2),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                radius: 10,
                                                child: Image.asset(
                                                  'assets/images/Icon-chao.png',
                                                  width: double.infinity,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                widget.cuslang == 'EN'
                                                    ? 'Pay within $expLbl  |  $ref1'
                                                    : 'ชำระภายใน $expLbl  |  $ref1',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: Font_.Fonts_T,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: isDesktop ? 13 : 11,
                                                  color: Colors.black
                                                      .withOpacity(.65),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // ปุ่ม Save / Share
                                  LayoutBuilder(builder: (_, c2) {
                                    final inRow = c2.maxWidth >= 420;
                                    final saveBtn = _solidBtn(
                                      color: Colors.indigo,
                                      icon: Icons.save_alt,
                                      label: widget.cuslang == 'EN'
                                          ? 'Save'
                                          : 'บันทึก',
                                      onTap: () async {
                                        await downloadWidgetAsPng(
                                          qrBlockKey,
                                          fileName: 'QRPAY_$bname.png',
                                        );
                                      },
                                    );
                                    final shareBtn = _ghostBtn(
                                      icon: Icons.share,
                                      label: widget.cuslang == 'EN'
                                          ? 'Share'
                                          : 'แชร์',
                                      onTap: () async {
                                        await downloadWidgetAsPng(
                                          qrBlockKey,
                                          fileName: 'QRPAY_$bname.png',
                                        );
                                      },
                                    );
                                    return inRow
                                        ? Row(children: [
                                            Expanded(child: saveBtn),
                                            const SizedBox(width: 12),
                                            Expanded(child: shareBtn),
                                          ])
                                        : Column(children: [
                                            saveBtn,
                                            const SizedBox(height: 10),
                                            shareBtn,
                                          ]);
                                  }),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // กล่อง “วิธีชำระ”
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: cardW),
                        child: _howToBox(), // ใช้ของเดิมคุณ
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ]),
    );
  }

  Widget _howToBox() {
    Widget step(int i, String t) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                      color: Colors.indigo.withOpacity(.25), width: .7),
                ),
                child: Text('$i',
                    style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontWeight: FontWeight.w900,
                        color: Colors.indigo.shade700)),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(t,
                      style: const TextStyle(
                          fontFamily: Font_.Fonts_T, fontSize: 13.5))),
            ],
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: .5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.cuslang == 'EN' ? 'How to Payment ' : 'วิธีชำระเงิน',
              style: const TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontWeight: FontWeight.w800,
                  fontSize: 15)),
          const SizedBox(height: 10),
          step(
              1,
              widget.cuslang == 'EN'
                  ? 'Check that the “information” is correct.'
                  : 'ตรวจสอบ “ข้อมูล”  ว่าถูกต้องหรือไม่'),
          step(
              2,
              widget.cuslang == 'EN'
                  ? 'Tap "Save" the QR image.'
                  : 'กด “บันทึก” รูป QR พร้อมเพย์ด้านบนลงในโทรศัพท์มือถือของคุณ'),
          step(
              3,
              widget.cuslang == 'EN'
                  ? 'Open your banking application to make a payment.'
                  : 'เปิดแอปพลิเคชันธนาคารที่คุณมี เพื่อชำระเงิน'),
          step(
              4,
              widget.cuslang == 'EN'
                  ? 'Use "Scan" → pick from photos → select the saved QR.'
                  : 'ไปที่เมนู “สแกน/สแกนจ่าย” แล้วกด “รูปภาพ” เพื่อเลือกรูป QR ที่บันทึกไว้'),
        ],
      ),
    );
  }

  Widget _pillInfo({
    required IconData leading,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.25), width: .7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(leading, size: 16, color: color.withOpacity(.95)),
          const SizedBox(width: 8),
          Text('$label: ',
              style: TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: color.withOpacity(.95))),
          Flexible(
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color: Colors.black87)),
          ),
        ],
      ),
    );
    return onTap == null
        ? child
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: child);
  }

  Widget _ghostBtn(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12, width: .7),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _solidBtn(
      {required Color color,
      required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(.28),
                blurRadius: 16,
                offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget chip(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: fg.withOpacity(.25), width: .7)),
        child: Text(text,
            style: TextStyle(
                fontFamily: Font_.Fonts_T,
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
                color: fg)),
      );

  Widget _selectedBar() {
    final cus =
        (widget.customerModel != null && widget.customerModel!.isNotEmpty)
            ? widget.customerModel!.first
            : null;
    final _cname = cus?.cname ?? '-';
    final _tel = cus?.tel ?? '-';
    final _tax = cus?.tax ?? '-';
    final _custno = cus?.custno ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [
          Colors.white.withOpacity(.85),
          Colors.white.withOpacity(.60)
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.06),
              offset: const Offset(0, 8),
              blurRadius: 18,
              spreadRadius: 2)
        ],
        border: Border.all(color: Colors.black12, width: .6),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.cuslang == 'EN' ? 'Payee' : 'ผู้รับชำระ',
                style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.green.withOpacity(.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(.25))),
                  child: Icon(Icons.person,
                      color: Colors.green.shade700, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          text:
                              widget.cuslang == 'EN' ? '$_cname ' : '$_cname ',
                          style: const TextStyle(
                              fontFamily: Font_.Fonts_T,
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5),
                        ),
                      ),
                      Text(
                          widget.cuslang == 'EN'
                              ? 'รหัสสมาชิก : $_custno'
                              : 'รหัสสมาชิก : $_custno',
                          style: const TextStyle(
                              fontFamily: Font_.Fonts_T,
                              fontWeight: FontWeight.w400,
                              fontSize: 13.5)),
                      Text(
                          widget.cuslang == 'EN'
                              ? 'ลขบัตรประชน/ผู้เสียภาษี : $_tax'
                              : 'เลขบัตรประชน/ผู้เสียภาษี : $_tax',
                          style: const TextStyle(
                              fontFamily: Font_.Fonts_T,
                              fontWeight: FontWeight.w400,
                              fontSize: 13.5)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupTile(Data g) {
    final bank = widget.datas.bank ?? '';
    final bno = g.bno ?? '';
    final title =
        g.bank ?? (widget.cuslang == 'EN' ? 'Payment method' : 'ช่องทางชำระ');

    final bankInfo = bankCodeMap[bank] ?? const {};
    final logoFile = bankInfo['logo'];
    final bankCode = bankInfo['code'] ?? '-';
    final bankEn = bankInfo['en'] ?? bank;

    final groupDocnos = (g.bill ?? const <Bill>[])
        .map((b) => b.docno?.trim())
        .where((id) => id != null && id!.isNotEmpty)
        .cast<String>()
        .toList();
    final uuid = widget.intentUuid.toString();
    // final String expireStr =
    //     _fmtDT(DateTime.parse(qr_softExpiresAt.toString()));

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
                    ? Image.asset('assets/images/LogoBank/$logoFile',
                        height: 26,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.account_balance,
                            size: 20,
                            color: Colors.grey))
                    : const Icon(Icons.account_balance,
                        size: 20, color: Colors.grey),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.cuslang == 'EN'
                      ? '$bankEn ($bankCode)'
                      : '${bank.isEmpty ? bankEn : bank} ($bankCode)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5),
                ),
              ),
              // const SizedBox(width: 8),
              // chip(expireStr.toString(), Colors.indigo.withOpacity(.08),
              //     Colors.indigo.shade700),
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
                    const Icon(Icons.receipt_sharp,
                        size: 15, color: Colors.black54),
                    Text(
                        '${widget.cuslang == "EN" ? " Bils" : " ใบแจ้งหนี้/วางบิล"}',
                        style: const TextStyle(
                            fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                  ]),

                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.numbers, size: 15, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(uuid.toString(),
                      style: const TextStyle(
                          fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  const Icon(Icons.payments, size: 15, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                      '${widget.cuslang == "EN" ? "Total" : "ยอดรวม"}: ${fmtMoney(g.totalBill ?? 0)}',
                      style: const TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700)),
                ]),
                // Row(mainAxisSize: MainAxisSize.min, children: [
                //   Text(return_qr_refapi1.toString(),
                //       style: const TextStyle(
                //           fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                //   const SizedBox(width: 6),
                //   Text(return_qr_refapi2.toString(),
                //       style: const TextStyle(
                //           fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                // ]),
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

  Widget _groupTileSub(Data g) {
    final bank = widget.datas.bank ?? '';
    final bno = g.bno ?? '';
    final bankInfo = bankCodeMap[bank] ?? const {};
    final logoFile = bankInfo['logo'];
    final bankCode = bankInfo['code'] ?? '-';
    final String expireStr =
        _fmtDT(DateTime.parse(qr_softExpiresAt.toString()));
    return Card(
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.indigo[600],
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                border: Border.all(color: Colors.black12, width: .7),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.cuslang == 'EN'
                            ? 'Payment within'
                            : 'ชำระเงินภายใน',
                        maxLines: 1,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: Font_.Fonts_T,
                            fontWeight: FontWeight.w700,
                            fontSize: 15.5),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      expireStr ?? "",
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  if (logoFile != null)
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.account_balance,
                          size: 20, color: Colors.grey[700]),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.cuslang == 'EN' ? '$bank' : '$bank',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.grey,
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  chip('ยกเลิก', Colors.grey.withOpacity(.08),
                      Colors.grey.shade700),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black12, width: .7),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _secondaryAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black12, width: .7),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: Colors.grey.shade800)),
          ],
        ),
      ),
    );
  }

  Widget _billRow(Bill b) {
    final amount = fmtMoney(b.totalBill ?? 0);
    final stTxt = b.st ?? '';
    final stCol = tagColor(stTxt);
    final id = b.docno?.trim() ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12, width: .4)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  ],
                ),
              ],
            ),
          ),
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
              backgroundImage: AssetImage('assets/fitness_app/area2x.png')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.cuslang == 'EN'
                  ? 'No information or no items to be paid'
                  : '${paymentIntents.length}ไม่มีข้อมูลหรือไม่มีรายการที่ต้องชำระ',
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
                  backgroundImage: AssetImage('assets/images/Icon-chao.png')),
            ),
            LoadingAnimationWidget.inkDrop(color: Colors.indigo, size: 70),
          ],
        ),
      ),
    );
  }
}
