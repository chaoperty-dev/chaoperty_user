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
import '../Api_V2/payment_intents.dart';
import '../Api_V2/payment_qr_session.dart';
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
import 'pay_bill_PayMainscreen.dart';
import 'pay_bill_screen_Choice.dart';
import 'package:side_sheet/side_sheet.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class PaybillSubMainScreen extends StatefulWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<TeNantModel>? teNantModel;
  final String? cuslang;
  final int? serpayment;
  final int? serptpayment;
  final List<CustomerModel>? customerModel;

  const PaybillSubMainScreen({
    super.key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
    this.teNantModel,
    this.cuslang,
    required this.serpayment,
    this.customerModel,
    required this.serptpayment,
  });

  @override
  State<PaybillSubMainScreen> createState() => _PaybillSubMainScreenState();
}

class _PaybillSubMainScreenState extends State<PaybillSubMainScreen> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  DateTime datex = DateTime.now();
  int tap_pay = 0;
  ////--------------------->
  List<InvoicePayModel> invoicePayModels = [];
  List<InvoiceModel> _InvoiceModels = [];
  List<InvoiceModel> invoicePayModels2 = [];
  List<dynamic> InvoicePay = [];
  List<ContractInvoice> coninv = [];
  ////--------------------->

  int ref_new = 0;
  String? return_qr_img, invoiceAll, return_qr_refapi, return_img;
  bool _isLoading = true;
  bool _isLoadingStatusChips = true;
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
// บันทึกบิลที่ถูกเลือก (key = docno)
  final Set<String> _selectedDocnos = {};
  ////--------------------->
  List<PaymentIntent> paymentIntents = [];
  ////--------------------->
  @override
  void initState() {
    super.initState();
    // เริ่มโหลดหลังเฟรมแรก เพื่อให้ context พร้อมและเลี่ยง layout work ระหว่าง build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Make sure to cancel the timer when widget is disposed
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      setState(() => _isLoading = true);

      // 1) โหลด payment intents ก่อน
      await redPaymentIntents();
      if (!mounted) return;

      // 2) แล้วค่อยโหลด invoice (จะอัพเดตสถานะจาก intents ภายใน)
      await red_Invoice();
      if (!mounted) return;

      // 3) งานอื่น ๆ เช่น ตรวจเวลา
      Check_time();
    } catch (e, st) {
      debugPrint('bootstrap error: $e\n$st');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  // ===== Helper: กรองตาม payser แล้วคำนวณยอดรวมใหม่ =====
  ContractInvoice filterByPayser(ContractInvoice inv, int targetPayser) {
    final groups = (inv.data ?? const <Data>[])
        .where((d) => (d.payser ?? -1) == targetPayser)
        .toList();

    // สรุปใหม่จาก groups ที่ผ่านการกรอง
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

  bool _isAllSelected(ContractInvoice inv) {
    final all = _collectAllBillDocnos([inv]).toSet();
    return all.isNotEmpty && _selectedDocnos.containsAll(all);
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

////=======================>
  // List<PaymentIntents> paymentIntents = [];
  // เปลี่ยนตรงนี้ให้ถูกชนิด
  // List<PaymentIntent> paymentIntents = [];
  Set<String> _paidDocnos = {};

  Future<void> redPaymentIntents() async {
    // print('🔄 เรียกใช้งาน redPaymentIntents() $serPay');

    if (mounted) {
      setState(() => _isLoading = true);
      setState(() {
        paymentIntents.clear(); // ✅ แก้ชนิดให้ถูก
        _paidDocnos.clear(); // ✅
      });
    }
    String serPay = widget.serpayment.toString();
    print(serPay);
    print('🔄 เรียกใช้งาน redPaymentIntents() $serPay');
    try {
      final response = (_statusFilter == '3')
          ? await getPaymentIntentsCanceled(cusno: '00007')
          : await getPaymentIntents(cusno: '00007', bankMerchantId: serPay);
      if (response == null) {
        print('❌ ไม่มี response จาก server');
        return;
      }

      final root = json.decode(response.body);
      if (root is! Map<String, dynamic>) {
        print('❌ รูปแบบ JSON ไม่ใช่ Map<String, dynamic>');
        return;
      }

      final intentsListRaw = root['data'];
      final intents = (intentsListRaw is List
              ? intentsListRaw.whereType<Map<String, dynamic>>()
              : const <Map<String, dynamic>>[])
          .map((m) => PaymentIntent.fromJson(m))
          .toList();

      final paidDocnos = <String>{};
      for (final it in intents) {
        for (final inv in it.invoices) {
          final br = inv.billReference?.trim();
          if (br != null && br.isNotEmpty) paidDocnos.add(br);
        }
      }

      if (mounted) {
        setState(() {
          paymentIntents = intents; // ✅ แก้ชนิดให้ถูก
          _paidDocnos = paidDocnos; // ✅
        });
      }

      print('🧾 paidDocnos (${paidDocnos.length}): $paidDocnos');
      print('✅ intents loaded: ${intents.length}');
    } catch (e, stack) {
      print('❌ Exception parsing payment intents: $e');
      print('🧭 StackTrace:\n$stack');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int? bankMerchantId;
  String? ref1 = '', ref2 = '', ref3 = '';
  Future<void> PostPaymentIntents(
      {required int payser,
      required int typepayser,
      required double requestedAmount,
      required List<Map<String, dynamic>> inVoices}) async {
    print('🔄 เรียกใช้งาน redPaymentIntents()');

    final response = await postPaymentIntents(
        cusNo: '00007',
        bankMerchantId: payser,
        bankMerchantType: typepayser,
        createdById: '00007',
        chanNel: "qr_bill",
        requestedAmount: requestedAmount,
        inVoices: inVoices);
    if (response == null) {
      print('❌ ไม่มี response จาก server');
      return;
    }

    try {
      final jsonRes = json.decode(response.body);
      print('🧾 Raw JSON: $jsonRes');
      setState(() {
        bankMerchantId = 0;
        ref1 = '';
        ref2 = '';
        ref3 = '';
      });
    } catch (e, stack) {
      print('❌ Exception parsing payment intents: $e');
      print('🧭 StackTrace:\n$stack');
    }
  }

////=======================>
  Future<void> red_Invoice() async {
    setState(() {
      coninv.clear();
      _isLoading = true;
      _isLoadingStatusChips = true;
    });

    try {
      final url =
          'http://192.168.1.227/chao_api/GC_billGropInv_PaytypeV2.php?isAdd=true&ren=146&custno_inv=00007';
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final int? target = widget.serpayment;

        List<ContractInvoice> list;
        if (decoded is Map<String, dynamic>) {
          list = [ContractInvoice.fromJson(decoded)];
        } else if (decoded is List) {
          list = decoded
              .whereType<Map<String, dynamic>>()
              .map((e) => ContractInvoice.fromJson(e))
              .toList();
        } else {
          debugPrint('Unexpected JSON shape');
          setState(() => _isLoading = false);
          setState(() => _isLoadingStatusChips = false);
          return;
        }

        if (target != null) {
          list = list
              .map((inv) => filterByPayser(inv, target))
              .where((inv) => (inv.data?.isNotEmpty ?? false))
              .toList();
        }

        for (final inv in list) {
          updateInvoiceStatusWithPayments(inv);
        }

        setState(() {
          coninv = list;
          _isLoading = false;
          _isLoadingStatusChips = false;
        });

        // ✅ เก็บ docno เฉพาะใบที่ status == 1
        final allDocnos = _collectAllBillDocnos(coninv);
        _selectedDocnos
          ..clear()
          ..addAll(
            allDocnos.where(
              (docno) {
                // หาตัวใบแจ้งหนี้ตาม docno แล้วเช็ก status
                for (final inv in coninv) {
                  for (final d in (inv.data ?? [])) {
                    for (final b in (d.bill ?? [])) {
                      if (b.docno == docno) {
                        return (_statusFilter == '0' ||
                                _statusFilter == '1' ||
                                _statusFilter == null)
                            ? b.status! == '1' || b.status! == '0'
                            : b.status! ==
                                '$_statusFilter'; // ✅ เก็บเฉพาะ status == 1
                      }
                    }
                  }
                }
                return false;
              },
            ),
          );

        debugPrint('✅ kept only docno with status == 1 -> $_selectedDocnos');
      } else {
        debugPrint('HTTP error: ${res.statusCode}');
        setState(() => _isLoading = false);
        setState(() => _isLoadingStatusChips = false);
      }
    } catch (e) {
      debugPrint('red_Invoice error: $e');
      setState(() => _isLoading = false);
      setState(() => _isLoadingStatusChips = false);
    }
  }

  ////=======================> ทำให้รูปแบบ docno/bill_reference คงที่ก่อนเปรียบเทียบ_paidDocnos
  String _norm(Object? v) =>
      v?.toString().trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
  // ---------- Normalizer ----------
  String _toArabicDigits(String s) {
    const th = '๐๑๒๓๔๕๖๗๘๙';
    const ar = '0123456789';
    final map = {for (var i = 0; i < th.length; i++) th[i]: ar[i]};
    return s.split('').map((ch) => map[ch] ?? ch).join();
  }

  String canonDocRef(Object? v,
      {bool zeroPadLastNumber = false, int padTo = 6}) {
    if (v == null) return '';
    var s = v.toString();

    // ตัดอักขระควบคุม/ผี (ZWSP/ZWJ/ZWNJ/FEFF)
    s = s.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');

    // ตัดช่องว่างหัว/ท้าย แล้วแปลงเลขไทย และเป็นพิมพ์ใหญ่
    s = _toArabicDigits(s.trim()).toUpperCase();

    // รวมขีดทุกชนิดให้เป็น '-' เดียว
    s = s.replaceAll(
        RegExp(r'[----—―_]+'), '-'); // dash variants + underscore → '-'
    // ยุบช่องว่างให้เป็นขีด (กันเคส "INV 68 10 001091")
    s = s.replaceAll(RegExp(r'\s+'), '-');

    // เก็บเฉพาะ A-Z 0-9 และ '-'
    s = s.replaceAll(RegExp(r'[^A-Z0-9-]'), '');

    // ยุบขีดซ้ำ และตัดขีดต้น/ท้าย
    s = s.replaceAll(RegExp(r'-{2,}'), '-').replaceAll(RegExp(r'^-|-$'), '');

    if (zeroPadLastNumber) {
      final parts = s.split('-');
      if (parts.isNotEmpty) {
        final last = parts.last;
        if (RegExp(r'^\d+$').hasMatch(last)) {
          parts[parts.length - 1] = last.padLeft(padTo, '0');
          s = parts.join('-');
        }
      }
    }
    return s;
  }

  Set<String> _collectPaidDocnosFromIntents() {
    final set = <String>{};

    // ✅ เก็บจากโมเดลหลัก (PaymentIntent → invoices → billReference)
    for (final intent in paymentIntents) {
      for (final inv in intent.invoices) {
        final ref = canonDocRef(inv.billReference, zeroPadLastNumber: true);
        if (ref.isNotEmpty) set.add(ref);
      }
    }

    // ✅ fallback: ใช้ _paidDocnos ที่ดึงจาก JSON ดิบ ถ้าโมเดลยังว่าง
    if (set.isEmpty && _paidDocnos.isNotEmpty) {
      set.addAll(
        _paidDocnos.map((s) => canonDocRef(s, zeroPadLastNumber: true)),
      );
    }

    return set;
  }

////=======================> เรียกหลังจากโหลดทั้ง paymentIntents และ coninv แล้ว
  void updateInvoiceStatusWithPayments(ContractInvoice inv) {
    final paidDocnos = _collectPaidDocnosFromIntents();
    debugPrint('🧾 paidDocnos (effective) ${paidDocnos.length}: $paidDocnos');

    int hit = 0;
    for (final group in inv.data ?? const []) {
      for (final b in group.bill ?? const []) {
        final doc = canonDocRef(b.docno, zeroPadLastNumber: true);
        if (doc.isNotEmpty && paidDocnos.contains(doc)) {
          b.status = '2'; // หรือ int 2 ถ้า field เป็นตัวเลข
          hit++;
          debugPrint('✔️ matched & set status=2 -> $doc');
        }
      }
    }
    debugPrint('✅ อัปเดตสถานะใบแจ้งหนี้ $hit รายการ เป็น status=2');
  }

////=======================>

  Map<String, num> _sumSelectedAmount(ContractInvoice inv) {
    num pvat = 0;
    num vat = 0;
    num wht = 0;
    num total = 0;

    for (final g in (inv.data ?? const <Data>[])) {
      for (final b in (g.bill ?? const <Bill>[])) {
        final id = b.docno?.trim();
        if (id != null && _selectedDocnos.contains(id)) {
          pvat += (b.pvatBill ?? 0);
          vat += (b.vatBill ?? 0);
          wht += (b.whtBill ?? 0);
          total += (b.totalBill ?? 0);
        }
      }
    }

    return {
      'pvat': pvat,
      'vat': vat,
      'wht': wht,
      'total': total,
    };
  }

  Map<String, num> _sumAll(ContractInvoice inv) {
    num pvat = 0, vat = 0, wht = 0, total = 0;
    for (final g in (inv.data ?? const <Data>[])) {
      for (final b in (g.bill ?? const <Bill>[])) {
        pvat += (b.pvatBill ?? 0);
        vat += (b.vatBill ?? 0);
        wht += (b.whtBill ?? 0);
        total += (b.totalBill ?? 0);
      }
    }
    return {'pvat': pvat, 'vat': vat, 'wht': wht, 'total': total};
  }

  Map<String, num> _sumSelected(ContractInvoice inv) {
    num pvat = 0, vat = 0, wht = 0, total = 0;
    for (final g in (inv.data ?? const <Data>[])) {
      for (final b in (g.bill ?? const <Bill>[])) {
        final id = b.docno?.trim();
        if (id != null && _selectedDocnos.contains(id)) {
          pvat += (b.pvatBill ?? 0);
          vat += (b.vatBill ?? 0);
          wht += (b.whtBill ?? 0);
          total += (b.totalBill ?? 0);
        }
      }
    }
    return {'pvat': pvat, 'vat': vat, 'wht': wht, 'total': total};
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading();
    if (coninv.isEmpty) return _buildEmptyState();

    final inv = coninv.first;
    final groups = inv.data ?? const <Data>[];
    if (groups.isEmpty) return _buildEmptyState(); // <-- เพิ่มบรรทัดนี้
    final selectedCount = _selectedDocnos.length;
    final allCount = _collectAllBillDocnos([inv]).length;

    final allSum = _sumAll(inv);
    final selSum = _sumSelected(inv);

    return AnimatedBuilder(
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
                  ...(inv.data ?? const <Data>[]).map(_groupTile).toList(),
                  const SizedBox(height: 8),
                  // _summaryCard(inv), const SizedBox(height: 8),
                  // ✅ แสดงแถบสรุปการเลือก
                  _selectedBar(selectedCount, allCount, selSum, allSum),
                  _statusChips(inv),
                  // const SizedBox(height: 8),
                  // กลุ่มการชำระ
                  // ...(inv.data ?? const <Data>[]).map(_groupTile).toList(),

                  if (_statusFilter == '2') ...[
                    if (selectedCount != 0)
                      ...paymentIntents
                          .expand((p) =>
                              groups.map((g) => _groupTileSub_Intents(p, g)))
                          .toList(),
                    // ...paymentIntents.map(_groupTileSub_Intents).toList(),
                  ] else if (_statusFilter == '3') ...[
                    // if (selectedCount != 0)
                    ...paymentIntents
                        .map(_groupTileSub_IntentsCanceled)
                        .toList(),
                  ] else ...[
                    if (_isLoadingStatusChips || selectedCount == 0) ...[
                      if (selectedCount == 0)
                        SizedBox(
                            height: 300,
                            child: Center(
                              child: Text(
                                'ไม่พบข้อมูล',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            )),
                      SizedBox(
                          height: 300, child: Center(child: _buildLoading()))
                    ] else ...[
                      if (selectedCount != 0)
                        ...(inv.data ?? const <Data>[])
                            .map(_groupTileSub)
                            .toList(),
                    ],
                  ]
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

// ===== 1) state สำหรับตัวกรองสถานะ (วางบนสุดใน State) =====
  String? _statusFilter = '1'; // null = ไม่กรอง
  final Map<String, IconData> _statusIcon = {
    'ที่ต้องชำระ': Icons.pending_actions,
    'รอดำเนินการ': Icons.timelapse,
    'สำเร็จ': Icons.check_circle,
    'ยกเลิก': Icons.cancel,
  };
  final Map<String, Color> _statusColor = {
    'ที่ต้องชำระ': Colors.orange,
    'รอดำเนินการ': Colors.amber,
    'สำเร็จ': Colors.green,
    'ยกเลิก': Colors.red,
  };

// ===== 2) helper นับจำนวนตามสถานะจาก inv =====
  Map<String, int> _countStatus(ContractInvoice inv) {
    final m = {'ที่ต้องชำระ': 0, 'รอดำเนินการ': 0, 'สำเร็จ': 0, 'ยกเลิก': 0};
    for (final g in (inv.data ?? const <Data>[])) {
      for (final b in (g.bill ?? const <Bill>[])) {
        final st = (b.st ?? '').trim();
        if (st.isEmpty) continue;
        if (st.contains('ค้าง') || st.contains('ต้องชำระ'))
          m['ที่ต้องชำระ'] = (m['ที่ต้องชำระ'] ?? 0) + 1;
        else if (st.contains('รอ'))
          m['รอดำเนินการ'] = (m['รอดำเนินการ'] ?? 0) + 1;
        else if (st.contains('สำเร็จ') || st.contains('ชำระแล้ว'))
          m['สำเร็จ'] = (m['สำเร็จ'] ?? 0) + 1;
        else if (st.contains('ยกเลิก')) m['ยกเลิก'] = (m['ยกเลิก'] ?? 0) + 1;
      }
    }
    return m;
  }

// ===== 3) widget chips สวย ๆ (แทน Row เดิม) =====
  Widget _statusChips(ContractInvoice inv) {
    final counts = _countStatus(inv);

    final List<Map<String, dynamic>> items = const [
      {'id': 1, 'name': 'ที่ต้องชำระ'},
      {'id': 2, 'name': 'รอดำเนินการ'},
      {'id': 3, 'name': 'ยกเลิก'},
    ];

    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 12),
      padding: const EdgeInsets.all(2),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((m) {
          final int id = m['id'] as int;
          final String name = m['name'] as String;

          final c = _statusColor[name] ?? Colors.grey;
          final active = _statusFilter == id.toString();
          final count = counts[id] ?? 0;

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () async {
              if (!mounted) return;

              // คิด filter ล่วงหน้า → ใช้ local จะไม่สับสนกับ state ที่เปลี่ยนระหว่างทำงาน
              final String? nextFilter = active ? null : id.toString();

              setState(() {
                _isLoadingStatusChips = true;
                _statusFilter = nextFilter;
              });

              if (_statusFilter == '3') {
                try {
                  await redPaymentIntents();
                } catch (_) {
                  // handle/log
                } finally {
                  if (!mounted) return;
                  await Future.delayed(const Duration(seconds: 2));
                  if (mounted) setState(() => _isLoadingStatusChips = false);
                }
              } else if (_statusFilter == '1') {
                try {
                  await redPaymentIntents();
                } catch (_) {
                  // handle/log
                } finally {
                  if (!mounted) return;
                  await Future.delayed(const Duration(seconds: 2));
                  if (mounted) setState(() => _isLoadingStatusChips = false);
                }
              } else {
                try {
                  await redPaymentIntents();
                  // สร้างชุดสถานะที่อนุญาตจาก nextFilter
                  final Set<String> allowStatuses = (nextFilter == null ||
                          nextFilter == '0' ||
                          nextFilter == '1')
                      ? {'0', '1'}
                      : {nextFilter};

                  // รวม docno ทุกบิล
                  final allDocnos = _collectAllBillDocnos(coninv);

                  // ทำ map docno -> status เพื่อให้ค้นหา O(1)
                  final Map<String, String?> docStatus = {};
                  for (final inv in coninv) {
                    for (final d in (inv.data ?? const [])) {
                      for (final b in (d.bill ?? const [])) {
                        if (b.docno != null) {
                          docStatus[b.docno!] = b.status;
                        }
                      }
                    }
                  }

                  // กรอง docno ตามสถานะที่ยอมรับ
                  final filtered = allDocnos.where((docno) {
                    final st = docStatus[docno];
                    return st != null && allowStatuses.contains(st);
                  });

                  setState(() {
                    _selectedDocnos
                      ..clear()
                      ..addAll(filtered);
                  });
                } catch (_) {
                  // handle/log
                } finally {
                  if (!mounted) return;
                  await Future.delayed(const Duration(seconds: 2));
                  if (mounted) setState(() => _isLoadingStatusChips = false);
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: active ? c.withOpacity(.12) : c.withOpacity(.06),
                border: Border.all(
                  color: active ? c.withOpacity(.5) : c.withOpacity(.25),
                  width: .8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_statusIcon[id] ?? Icons.help,
                      size: 16, color: c.withOpacity(.95)),
                  const SizedBox(width: 8),
                  Text(
                    '$_statusFilter' + name, // ใช้ชื่อ
                    style: TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Colors.black.withOpacity(.85),
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: c.withOpacity(.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: c.withOpacity(.95),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
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

  Widget _selectedBar(
    int selectedCount,
    int allCount,
    Map<String, num> sel,
    Map<String, num> all,
  ) {
    if (allCount == 0) return const SizedBox.shrink();

    // Helper
    double ratio(num a, num b) => (b == 0) ? 0 : (a.toDouble() / b.toDouble());

    final selPvat = sel['pvat'] ?? 0, allPvat = all['pvat'] ?? 0;
    final selVat = sel['vat'] ?? 0, allVat = all['vat'] ?? 0;
    final selWht = sel['wht'] ?? 0, allWht = all['wht'] ?? 0;
    final selTotal = sel['total'] ?? 0, allTotal = all['total'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // glassmorphism เบา ๆ
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(.85),
            Colors.white.withOpacity(.60)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            offset: const Offset(0, 8),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.black12, width: .6),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(.25)),
                  ),
                  child: Icon(Icons.check_circle,
                      color: Colors.green.shade700, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.cuslang == 'EN'
                        ? 'Selected $selectedCount / $allCount bills'
                        : 'เลือกแล้ว $selectedCount / $allCount ใบแจ้งหนี้',
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                ),
                // ปุ่มลัด: เลือกทั้งหมด / ล้าง

                Wrap(
                  spacing: 6,
                  children: [
                    _pillBtn(
                      icon: Icons.done_all,
                      label: widget.cuslang == 'EN'
                          ? 'Select all'
                          : 'เลือกทั้งหมด',
                      onTap: () {
                        setState(() {
                          _selectedDocnos
                            ..clear()
                            ..addAll(_collectAllBillDocnos(coninv).toSet());
                        });
                      },
                    ),
                    _pillBtn(
                      icon: Icons.clear_all,
                      label: widget.cuslang == 'EN' ? 'Clear' : 'ล้าง',
                      onTap: () {
                        setState(() => _selectedDocnos.clear());
                      },
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 12),

            // Metrics grid

            LayoutBuilder(
              builder: (_, c) {
                // responsive: 2 คอลัมน์บนจอแคบ, 4 คอลัมน์บนจอกว้าง
                final isWide = c.maxWidth > 700;
                final metrics = <_Metric>[
                  _Metric(
                    label: widget.cuslang == 'EN' ? 'PVAT' : 'ก่อน VAT',
                    icon: Icons.receipt_long,
                    color: Colors.teal,
                    sel: selPvat,
                    all: allPvat,
                    fmt: fmtMoney,
                  ),
                  _Metric(
                    label: widget.cuslang == 'EN' ? 'VAT' : 'ภาษีมูลค่าเพิ่ม',
                    icon: Icons.percent,
                    color: Colors.orange,
                    sel: selVat,
                    all: allVat,
                    fmt: fmtMoney,
                  ),
                  _Metric(
                    label: widget.cuslang == 'EN' ? 'WHT' : 'หัก ณ ที่จ่าย',
                    icon: Icons.money_off_csred_outlined,
                    color: Colors.pink,
                    sel: selWht,
                    all: allWht,
                    fmt: fmtMoney,
                  ),
                  _Metric(
                    label: widget.cuslang == 'EN' ? 'TOTAL' : 'ยอดรวม',
                    icon: Icons.payments,
                    color: Colors.blue,
                    sel: selTotal,
                    all: allTotal,
                    fmt: fmtMoney,
                  ),
                ];

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: metrics.map((m) {
                    final width =
                        isWide ? (c.maxWidth - 30) / 4 : (c.maxWidth - 10) / 2;
                    return _metricCard(
                      width: width,
                      color: m.color,
                      icon: m.icon,
                      label: m.label,
                      leftVal: m.fmt(m.sel),
                      rightVal: m.fmt(m.all),
                      progress: ratio(m.sel, m.all),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sumCompareBox(String label, num sel, num all, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(.2), width: .7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: Font_.Fonts_T,
              color: color.withOpacity(.9),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${fmtMoney(sel)} / ${fmtMoney(all)}',
            style: const TextStyle(
              fontFamily: Font_.Fonts_T,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(ContractInvoice inv) {
    return Card(
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Checkbox(
            //       value: _isAllSelected(inv),
            //       tristate: false,
            //       onChanged: (v) {
            //         setState(() {
            //           if (v == true) {
            //             _selectedDocnos
            //               ..clear()
            //               ..addAll(_collectAllBillDocnos([inv]));
            //           } else {
            //             _selectedDocnos.clear();
            //           }
            //         });
            //       },
            //     ),
            //     Text(widget.cuslang == 'EN' ? 'Select all' : 'เลือกทั้งหมด',
            //         style: const TextStyle(fontFamily: Font_.Fonts_T)),
            //   ],
            // ),
            Text(widget.cuslang == 'EN' ? 'Summary' : 'สรุปภาพรวม',
                style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                _kv((widget.cuslang == 'EN') ? 'BILLS' : 'บิลทั้งหมด',
                    fmtInt(inv.billAll), Colors.indigo),
                _kv((widget.cuslang == 'EN') ? 'PVAT' : 'ก่อนภาษีมูลค่าเพิ่ม',
                    fmtInt(inv.pvatAll), Colors.teal),
                _kv((widget.cuslang == 'EN') ? 'VAT' : 'ภาษีมูลค่าเพิ่ม',
                    fmtMoney(inv.vatAll ?? 0), Colors.orange),
                _kv((widget.cuslang == 'EN') ? 'WHT' : 'ภาษีหัก ณ ที่จ่าย',
                    fmtInt(inv.whtAll), Colors.pink),
                _kv((widget.cuslang == 'EN') ? 'TOTAL' : 'ยอดสุทธิ',
                    fmtMoney(inv.totalAll ?? 0), Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.withOpacity(.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withOpacity(.2), width: .7),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k,
              style: TextStyle(
                  fontFamily: Font_.Fonts_T,
                  color: c.withOpacity(.9),
                  fontWeight: FontWeight.w700,
                  fontSize: 12)),
          const SizedBox(height: 4),
          Text(v,
              style: const TextStyle(
                  fontFamily: Font_.Fonts_T,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
        ],
      ),
    );
  }

  Widget _groupTile(Data g) {
    final payser = g.payser ?? null;
    final bank = g.bank ?? '';
    final bno = g.bno ?? '';
    final title =
        g.bank ?? (widget.cuslang == 'EN' ? 'Payment method' : 'ช่องทางชำระ');
    // หารหัสไฟล์โลโก้

    final bankInfo = bankCodeMap[bank];
    final logoFile = bankInfo?['logo'];
    final bankCode = bankInfo?['code'];
    final bankEn = bankInfo?['en'];

    // docno ทั้งหมดของกลุ่มนี้
    final groupDocnos = (g.bill ?? const <Bill>[])
        .map((b) => b.docno?.trim())
        .where((id) => id != null && id!.isNotEmpty)
        .cast<String>()
        .toList();

    final allSelectedInGroup =
        groupDocnos.isNotEmpty && groupDocnos.every(_selectedDocnos.contains);
    final someSelectedInGroup =
        groupDocnos.any(_selectedDocnos.contains) && !allSelectedInGroup;

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
              // โลโก้
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

              // ✅ Master checkbox ของกลุ่ม
              // Checkbox(
              //   value: allSelectedInGroup
              //       ? true
              //       : (someSelectedInGroup ? null : false),
              //   tristate: true,
              //   onChanged: (_) {
              //     setState(() {
              //       if (allSelectedInGroup) {
              //         // ยกเลิกทั้งกลุ่ม
              //         _selectedDocnos.removeAll(groupDocnos);
              //       } else {
              //         // เลือกทั้งกลุ่ม
              //         _selectedDocnos.addAll(groupDocnos);
              //       }
              //     });
              //   },
              // ),
              // Text(widget.cuslang == 'EN' ? 'All' : 'ทั้งกลุ่ม',
              //     style: const TextStyle(fontFamily: Font_.Fonts_T)),
              const SizedBox(width: 8),

              chip(widget.cuslang == 'EN' ? 'Bills' : 'ใบแจ้งหนี้',
                  Colors.indigo.withOpacity(.08), Colors.indigo.shade700),
            ],
          ),
          // ... (subtitle เดิม)
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
    final bank = g.bank ?? '';
    final bno = g.bno ?? '';
    final bankInfo = bankCodeMap[bank];
    final logoFile = bankInfo?['logo'];
    final bankCode = bankInfo?['code'];

    return Card(
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ แถวหัวเรื่อง
            Row(
              children: [
                if (logoFile != null)
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.list_alt,
                      size: 20,
                      color: Colors.orange[700],
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.cuslang == 'EN'
                        ? 'Payable'
                        : 'ที่ต้องชำระ ${paymentIntents.length}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                chip('$bankCode', Colors.indigo.withOpacity(.08),
                    Colors.indigo.shade700),
              ],
            ),
            const SizedBox(height: 10),

            // ✅ รายละเอียดย่อย
            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (bno.isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.account_balance,
                        size: 15, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      bno,
                      style: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 12.5,
                      ),
                    ),
                  ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.payments, size: 15, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.cuslang == "EN" ? "Total" : "ยอดรวม"}: ${fmtMoney(g.totalBill ?? 0)}',
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            // === แทนที่ Wrap เดิมตรงท้ายการ์ดด้วยบล็อกนี้ ===
            LayoutBuilder(
              builder: (_, c) {
                final isNarrow =
                    c.maxWidth < 420; // หน้าจอแคบให้เรียงเป็นคอลัมน์
                final children = <Widget>[
                  _secondaryAction(
                    icon: Icons.close,
                    label: widget.cuslang == 'EN'
                        ? 'Cancel payment'
                        : 'ยกเลิกการชำระเงิน',
                    onTap: () async {},
                  ),
                  const SizedBox(width: 10, height: 10),
                  _primaryAction(
                      icon: Icons.payments,
                      label: widget.cuslang == 'EN' ? 'Pay now' : 'ชำระเงิน',
                      color: Colors.deepOrange,
                      onTap: () async {
                        if (!mounted) return; // ✅ กันตั้งแต่ต้น
                        final size = MediaQuery.of(context).size;
                        final inv = coninv.first;
                        final allSum = _sumAll(inv);
                        final selSum = _sumSelected(inv);
                        final double totalBill =
                            double.parse(selSum['total'].toString()) ?? 0.00;
                        // ให้แน่ใจว่า g.bill != null และ _selectedDocnos เป็น List<String> หรือ List<dynamic> ที่เป็น String ได้
                        final List<Map<String, dynamic>> invs = g.bill!
                            .where((b) =>
                                b.status.toString() == '1' &&
                                (b.docno ?? '').isNotEmpty &&
                                _selectedDocnos.contains(b.docno))
                            .map<Map<String, dynamic>>((b) {
                          // --- แปลง type ให้ชัด ---
                          final String docno = b.docno?.toString() ?? '';
                          final String cid = b.cid?.toString() ?? '';
                          final String custno = b.custno?.toString() ?? '';
                          final String st = b.st?.toString() ?? '';
                          final int statusVal =
                              int.tryParse(b.status.toString()) ?? 0;
                          final int payserVal =
                              int.tryParse(b.payser.toString()) ?? 0;
                          final String docnoAll = b.docnoAll?.toString() ?? '';

                          final double totalBill =
                              (b.totalBill ?? 0).toDouble();
                          final double pvatBill = (b.pvatBill ?? 0).toDouble();
                          final double vatBill = (b.vatBill ?? 0).toDouble();
                          final double whtBill = (b.whtBill ?? 0).toDouble();

                          final double selPvat =
                              (selSum['pvat'] ?? 0).toDouble();
                          final double selVat = (selSum['vat'] ?? 0).toDouble();
                          final double selWht = (selSum['wht'] ?? 0).toDouble();
                          final double selTotal =
                              (selSum['total'] ?? 0).toDouble();

                          final List<String> docnosSelected = List<String>.from(
                              _selectedDocnos); // ให้แน่ใจว่าเป็น List<String>

                          return {
                            "invoice_id": 0,
                            "bill_reference": docno,
                            "original_amount": totalBill,
                            "total": totalBill,
                            "late_fee": 0,
                            "metadata": [
                              {
                                'docno': docno,
                                'date': b.date,
                                'cid': cid,
                                'custno': custno,
                                'st': st,
                                'status': statusVal,
                                'payser': payserVal,
                                'docno_all': docnoAll,
                                'pvat_bill': pvatBill,
                                'vat_bill': vatBill,
                                'wht_bill': whtBill,
                                'late_fee': 0,
                                'total_bill': totalBill,
                                'selected': docnosSelected,
                              }
                            ],
                          };
                        }).toList();

                        debugPrint('invs payload: ${jsonEncode(invs)}');

                        if (invs.isEmpty) {
                          debugPrint('No invoices selected.');
                          return;
                        }

                        // print(invs);
                        await PostPaymentIntents(
                            payser: g.payser ?? 0,
                            typepayser: g.ptser ?? 0,
                            requestedAmount: totalBill!,
                            inVoices: invs);

                        final result = await SideSheet.right(
                          context: context,
                          width: size.width, // เต็มจอ
                          barrierColor: Colors.black54,
                          sheetColor: Colors.white, barrierDismissible: true,
                          // dismissible: true,
                          body: Builder(
                            // ✅ เอา context ภายใน sheet
                            builder: (sheetCtx) => SafeArea(
                              child: SizedBox(
                                height: size.height,
                                child: Column(
                                  children: [
                                    // Header
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 8, 12, 8),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            tooltip: widget.cuslang == 'EN'
                                                ? 'back'
                                                : 'กลับ',
                                            icon: const Icon(Icons.arrow_back),
                                            onPressed: () =>
                                                Navigator.of(sheetCtx).pop(
                                                    'closed'), // ✅ ใช้ sheetCtx
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            widget.cuslang == 'EN'
                                                ? 'Payment details'
                                                : 'รายระเอียดการชำระ',
                                            style: const TextStyle(
                                              fontFamily: Font_.Fonts_T,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                            ),
                                          ),
                                          // const Spacer(),
                                          // TextButton.icon(
                                          //   onPressed: () =>
                                          //       Navigator.of(sheetCtx).pop(
                                          //           'confirmed'), // ✅ ใช้ sheetCtx
                                          //   icon: const Icon(Icons.check),
                                          //   label: Text(
                                          //     widget.cuslang == 'EN'
                                          //         ? 'Confirm'
                                          //         : 'ยืนยัน',
                                          //     style: const TextStyle(
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 1),

                                    // เนื้อหา
                                    Expanded(
                                      child: PaybillPayMainScreen(
                                        mainScreenAnimation:
                                            widget.mainScreenAnimation,
                                        mainScreenAnimationController: widget
                                            .mainScreenAnimationController!,
                                        teNantModel: widget.teNantModel,
                                        cuslang: widget.cuslang,
                                        serpayment: widget.serpayment,
                                        customerModel: widget.customerModel,
                                        datas: g,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );

                        if (!mounted) return; // ✅ กันหลัง await
                        if (result == 'confirmed') {
                          // TODO: handle confirmed
                        }
                      }),
                ];

                return Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: isNarrow
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: children,
                          )
                        // Column(
                        //     crossAxisAlignment: CrossAxisAlignment.stretch,
                        //     children: children,
                        //   )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: children,
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> cancelIntent(BuildContext context, String intentUuid) async {
    try {
      final resp =
          await PatchPaymentIntents_UuidCanceled(intentsUuid: intentUuid);

      if (resp == null) {
        if (!context.mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้')),
        );
        return false;
      }

      final sc = resp.statusCode;
      if (sc >= 200 && sc < 300) {
        String msg = 'OK';
        try {
          final obj = jsonDecode(resp.body);
          if (obj is Map && obj['message'] is String) msg = obj['message'];
        } catch (_) {
          // เผื่อ 204 หรือ body ไม่ใช่ JSON
        }
        if (!context.mounted) return true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('ยกเลิกสำเร็จ ($msg)'),
              backgroundColor: Colors.green),
        );
        return true;
      } else {
        String err = '(${resp.statusCode})';
        try {
          final obj = jsonDecode(resp.body);
          if (obj is Map && obj['message'] is String) err = obj['message'];
        } catch (_) {}
        if (!context.mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('ยกเลิกไม่สำเร็จ $err'),
              backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e, st) {
      debugPrint('⚠️ cancelIntent exception: $e\n$st');
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.orange),
      );
      return false;
    }
  }

  Widget _groupTileSub_Intents(PaymentIntent p, Data g) {
    // helpers
    String _fmtDT(DateTime? d) =>
        d == null ? '-' : DateFormat('d-MM-yyyy HH:mm').format(d.toLocal());

    // typed + safe
    final String intentUuid = p.intentUuid ?? '-';
    final double amount = p.requestedAmount ?? 0.0; // ใช้ double ตรง ๆ
    final String createdStr = _fmtDT(p.createdAt);
    final String expireStr = _fmtDT(p.softExpireAt);
    final String statusVerb = p.statusExtended?.statusVerbose ?? '';
    final String statusThai = p.statusExtended?.statusThai ?? '';

    return Card(
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // หัวการ์ด
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child:
                      Icon(Icons.list_alt, size: 20, color: Colors.orange[700]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.cuslang == 'EN' ? statusVerb : statusThai,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                chip(expireStr, Colors.indigo.withOpacity(.08),
                    Colors.indigo.shade700),
              ],
            ),
            const SizedBox(height: 10),

            // รายละเอียด
            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.numbers, size: 15, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(intentUuid,
                      style: const TextStyle(
                          fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.date_range,
                      size: 15, color: Color.fromARGB(137, 54, 53, 53)),
                  const SizedBox(width: 6),
                  Text(createdStr,
                      style: const TextStyle(
                          fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.payments, size: 15, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.cuslang == "EN" ? "Total" : "ยอดรวม"}: ${fmtMoney(amount)}',
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 10),

            // ปุ่ม
            LayoutBuilder(
              builder: (_, c) {
                final isNarrow = c.maxWidth < 420;
                final children = <Widget>[
                  _secondaryAction(
                    icon: Icons.close,
                    label: widget.cuslang == 'EN'
                        ? 'Cancel payment'
                        : 'ยกเลิกการชำระเงิน',
                    onTap: () async {
                      if (_isLoading) return;
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('ยืนยัน'),
                          content: const Text('ต้องการยกเลิกรายการนี้หรือไม่?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('ยกเลิก')),
                            ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('ตกลง')),
                          ],
                        ),
                      );
                      if (ok != true) return;
                      if (!mounted) return;
                      setState(() => _isLoading = true);
                      final okCanceled =
                          await cancelIntent(context, intentUuid);
                      if (okCanceled) await redPaymentIntents();
                      if (!mounted) return;
                      setState(() => _isLoading = false);
                    },
                  ),
                  const SizedBox(width: 10, height: 10),
                  _primaryAction(
                    icon: Icons.payments,
                    label: widget.cuslang == 'EN' ? 'Pay now' : 'ชำระเงิน',
                    color: Colors.deepOrange,
                    onTap: () async {
                      // const _passphrase = 'my106'; // รหัสผ่านสั้นๆของคุณ

                      // enc.Key _deriveKey(String passphrase) {
                      //   final digest = sha256.convert(utf8.encode(passphrase));
                      //   return enc.Key(Uint8List.fromList(
                      //       digest.bytes)); // 32 bytes -> AES-256
                      // }

                      // String dartEncrypt(String plaintext) {
                      //   final key = _deriveKey(_passphrase);
                      //   final iv = enc.IV.fromSecureRandom(16); // สุ่มทุกครั้ง
                      //   final encrypter =
                      //       enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
                      //   final cipher = encrypter.encrypt(plaintext, iv: iv);
                      //   return base64Encode(
                      //       iv.bytes + cipher.bytes); // IV||CT -> base64
                      // }

                      // String dartDecrypt(String base64IvCt) {
                      //   final key = _deriveKey(_passphrase);
                      //   final raw = base64Decode(base64IvCt);
                      //   final iv = enc.IV(raw.sublist(0, 16));
                      //   final ct = enc.Encrypted(raw.sublist(16));
                      //   final encrypter =
                      //       enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
                      //   return encrypter.decrypt(ct, iv: iv);
                      // }

                      // final encText = dartEncrypt(
                      //     'hESjgWZtszLXXXdFpgxzzxjTkQESCDheYednFK56OmWdzbkKOcmAfuvGlUnKZVpP8ScAUq8ASJ7HCVxARS2odg==');
                      // print('ENC: $encText');
                      // final decText = dartDecrypt(
                      //     'hESjgWZtszLXXXdFpgxzzxjTkQESCDheYednFK56OmWdzbkKOcmAfuvGlUnKZVpP8ScAUq8ASJ7HCVxARS2odg==');
                      // print('DEC: $decText');

                      if (!mounted) return;
                      final merchantId =
                          int.tryParse('${widget.serpayment}') ?? 0;
                      final typemerchantId =
                          int.tryParse('${widget.serptpayment}') ?? 0;
                      final uuid = intentUuid;
                      if (p.payments.isEmpty) {
                        await postPaymentIntentsQRsession(
                          cusNo: '00007',
                          intentsUuid: uuid,
                          bankMerchantId: merchantId,
                          bankMerchantType: typemerchantId,
                          ref2: '',
                        );
                      }
                      final size = MediaQuery.of(context).size;
                      await SideSheet.right(
                        context: context,
                        width: size.width,
                        barrierColor: Colors.black54,
                        sheetColor: Colors.white,
                        barrierDismissible: true,
                        body: Builder(
                          builder: (sheetCtx) => SafeArea(
                            child: SizedBox(
                              height: size.height,
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          tooltip: widget.cuslang == 'EN'
                                              ? 'back'
                                              : 'กลับ',
                                          icon: const Icon(Icons.arrow_back),
                                          onPressed: () =>
                                              Navigator.of(sheetCtx)
                                                  .pop('closed'),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          widget.cuslang == 'EN'
                                              ? 'Payment details'
                                              : 'รายระเอียดการชำระ',
                                          style: const TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  Expanded(
                                    child: PaybillPayMainScreen(
                                      mainScreenAnimation:
                                          widget.mainScreenAnimation,
                                      mainScreenAnimationController:
                                          widget.mainScreenAnimationController!,
                                      teNantModel: widget.teNantModel,
                                      cuslang: widget.cuslang,
                                      serpayment: widget.serpayment,
                                      customerModel: widget.customerModel,
                                      intentUuid: uuid,
                                      datas: g,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ];

                return Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: isNarrow
                        ? Row(
                            mainAxisSize: MainAxisSize.min, children: children)
                        : Row(
                            mainAxisSize: MainAxisSize.min, children: children),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget _groupTileSub_Intents(PaymentIntent p, Data g) {
  //   final intentUuid = p.intentUuid ?? '';
  //   final requestedAmount = p.requestedAmount ?? 0; // ถ้าเป็น num
  //   final createdAt = p.createdAt ?? '';
  //   final ExpireAt = p.softExpireAt ?? '';
  //   final statusVerbose = p.statusExtended!.statusVerbose ?? '';
  //   final statusThai = p.statusExtended!.statusThai ?? '';
  //   return Card(
  //     elevation: 0.6,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  //     child: Padding(
  //       padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // ✅ แถวหัวเรื่อง
  //           Row(
  //             children: [
  //               // if (logoFile != null)
  //               CircleAvatar(
  //                 radius: 18,
  //                 backgroundColor: Colors.white,
  //                 child: Icon(
  //                   Icons.list_alt,
  //                   size: 20,
  //                   color: Colors.orange[700],
  //                 ),
  //               ),
  //               const SizedBox(width: 10),

  //               Expanded(
  //                 child: Text(
  //                   widget.cuslang == 'EN' ? '$statusVerbose' : '$statusThai ',
  //                   maxLines: 1,
  //                   overflow: TextOverflow.ellipsis,
  //                   style: const TextStyle(
  //                     fontFamily: Font_.Fonts_T,
  //                     fontWeight: FontWeight.w700,
  //                     fontSize: 15.5,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(width: 8),
  //               chip('${ExpireAt}', Colors.indigo.withOpacity(.08),
  //                   Colors.indigo.shade700),
  //             ],
  //           ),
  //           const SizedBox(height: 10),

  //           // ✅ รายละเอียดย่อย
  //           Wrap(
  //             spacing: 12,
  //             runSpacing: 6,
  //             crossAxisAlignment: WrapCrossAlignment.center,
  //             children: [
  //               // if (bno.isNotEmpty)
  //               Row(mainAxisSize: MainAxisSize.min, children: [
  //                 const Icon(Icons.numbers, size: 15, color: Colors.black54),
  //                 const SizedBox(width: 6),
  //                 Text(
  //                   intentUuid.toString(),
  //                   style: const TextStyle(
  //                     fontFamily: Font_.Fonts_T,
  //                     fontSize: 12.5,
  //                   ),
  //                 ),
  //               ]),
  //               Row(mainAxisSize: MainAxisSize.min, children: [
  //                 const Icon(Icons.date_range,
  //                     size: 15, color: Color.fromARGB(137, 54, 53, 53)),
  //                 const SizedBox(width: 6),
  //                 Text(
  //                   createdAt.toString(),
  //                   style: const TextStyle(
  //                     fontFamily: Font_.Fonts_T,
  //                     fontSize: 12.5,
  //                   ),
  //                 ),
  //               ]),
  //               Row(mainAxisSize: MainAxisSize.min, children: [
  //                 const Icon(Icons.payments, size: 15, color: Colors.black54),
  //                 const SizedBox(width: 6),
  //                 Text(
  //                   '${widget.cuslang == "EN" ? "Total" : "ยอดรวม"}: ${fmtMoney(int.parse(requestedAmount.toString()) ?? 0)}',
  //                   style: const TextStyle(
  //                     fontFamily: Font_.Fonts_T,
  //                     fontSize: 12.5,
  //                     fontWeight: FontWeight.w700,
  //                   ),
  //                 ),
  //               ]),
  //             ],
  //           ),
  //           SizedBox(
  //             height: 10,
  //           ),
  //           // === แทนที่ Wrap เดิมตรงท้ายการ์ดด้วยบล็อกนี้ ===
  //           LayoutBuilder(
  //             builder: (_, c) {
  //               final isNarrow =
  //                   c.maxWidth < 420; // หน้าจอแคบให้เรียงเป็นคอลัมน์
  //               final children = <Widget>[
  //                 _secondaryAction(
  //                     icon: Icons.close,
  //                     label: widget.cuslang == 'EN'
  //                         ? 'Cancel payment'
  //                         : 'ยกเลิกการชำระเงิน',
  //                     onTap: () async {
  //                       // กันกดซ้ำ
  //                       if (_isLoading) return;

  //                       final ok = await showDialog<bool>(
  //                         context: context,
  //                         builder: (_) => AlertDialog(
  //                           title: const Text('ยืนยัน'),
  //                           content:
  //                               const Text('ต้องการยกเลิกรายการนี้หรือไม่?'),
  //                           actions: [
  //                             TextButton(
  //                                 onPressed: () =>
  //                                     Navigator.pop(context, false),
  //                                 child: const Text('ยกเลิก')),
  //                             ElevatedButton(
  //                                 onPressed: () => Navigator.pop(context, true),
  //                                 child: const Text('ตกลง')),
  //                           ],
  //                         ),
  //                       );
  //                       if (ok != true) return;

  //                       if (!mounted) return;
  //                       setState(() => _isLoading = true);

  //                       // (ออปชัน) optimistic UI: mark เป็น canceled ไว้ก่อน
  //                       // final idx = paymentIntents.indexWhere((p) => p.intentUuid == intentUuid);
  //                       // if (idx != -1) {
  //                       //   final p = paymentIntents[idx].copyWith(status: 'canceled');
  //                       //   setState(() => paymentIntents[idx] = p);
  //                       // }

  //                       final okCanceled =
  //                           await cancelIntent(context, intentUuid.toString());
  //                       if (!mounted) return;

  //                       // reload รายการ หลังยกเลิก
  //                       if (okCanceled) {
  //                         await redPaymentIntents();
  //                       }

  //                       if (!mounted) return;
  //                       setState(() => _isLoading = false);
  //                     }),
  //                 const SizedBox(width: 10, height: 10),
  //                 _primaryAction(
  //                     icon: Icons.payments,
  //                     label: widget.cuslang == 'EN' ? 'Pay now' : 'ชำระเงิน',
  //                     color: Colors.deepOrange,
  //                     onTap: () async {
  //                       if (!mounted) return;

  //                       final merchantId =
  //                           int.tryParse(widget.serpayment.toString()) ?? 0;
  //                       final uuid = intentUuid.toString();
  //                       if (p.payments.isEmpty) {
  //                         final resp = await postPaymentIntentsQRsession(
  //                           cusNo: '00007', // <- ใส่ customer_no จริง
  //                           intentsUuid: uuid,
  //                           bankMerchantId: merchantId,
  //                           // ref1: 'ref1',
  //                           ref2: '',
  //                         );
  //                       }

  //                       final size = MediaQuery.of(context).size;
  //                       final result = await SideSheet.right(
  //                         context: context,
  //                         width: size.width, // เต็มจอ
  //                         barrierColor: Colors.black54,
  //                         sheetColor: Colors.white, barrierDismissible: true,
  //                         // dismissible: true,
  //                         body: Builder(
  //                           // ✅ เอา context ภายใน sheet
  //                           builder: (sheetCtx) => SafeArea(
  //                             child: SizedBox(
  //                               height: size.height,
  //                               child: Column(
  //                                 children: [
  //                                   // Header
  //                                   Padding(
  //                                     padding: const EdgeInsets.fromLTRB(
  //                                         12, 8, 12, 8),
  //                                     child: Row(
  //                                       children: [
  //                                         IconButton(
  //                                           tooltip: widget.cuslang == 'EN'
  //                                               ? 'back'
  //                                               : 'กลับ',
  //                                           icon: const Icon(Icons.arrow_back),
  //                                           onPressed: () =>
  //                                               Navigator.of(sheetCtx).pop(
  //                                                   'closed'), // ✅ ใช้ sheetCtx
  //                                         ),
  //                                         const SizedBox(width: 8),
  //                                         Text(
  //                                           widget.cuslang == 'EN'
  //                                               ? 'Payment details'
  //                                               : 'รายระเอียดการชำระ',
  //                                           style: const TextStyle(
  //                                             fontFamily: Font_.Fonts_T,
  //                                             fontWeight: FontWeight.w800,
  //                                             fontSize: 16,
  //                                           ),
  //                                         ),
  //                                         // const Spacer(),
  //                                         // TextButton.icon(
  //                                         //   onPressed: () =>
  //                                         //       Navigator.of(sheetCtx).pop(
  //                                         //           'confirmed'), // ✅ ใช้ sheetCtx
  //                                         //   icon: const Icon(Icons.check),
  //                                         //   label: Text(
  //                                         //     widget.cuslang == 'EN'
  //                                         //         ? 'Confirm'
  //                                         //         : 'ยืนยัน',
  //                                         //     style: const TextStyle(
  //                                         //         fontFamily: Font_.Fonts_T),
  //                                         //   ),
  //                                         // ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                   const Divider(height: 1),

  //                                   // เนื้อหา
  //                                   Expanded(
  //                                     child: PaybillPayMainScreen(
  //                                       mainScreenAnimation:
  //                                           widget.mainScreenAnimation,
  //                                       mainScreenAnimationController: widget
  //                                           .mainScreenAnimationController!,
  //                                       teNantModel: widget.teNantModel,
  //                                       cuslang: widget.cuslang,
  //                                       serpayment: widget.serpayment,
  //                                       customerModel: widget.customerModel,
  //                                       intentUuid: intentUuid ?? "",
  //                                       datas: g,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       );

  //                       if (!mounted) return; // ✅ กันหลัง await
  //                       if (result == 'confirmed') {
  //                         // TODO: handle confirmed
  //                       }
  //                       // กันกดซ้ำ (ถ้ามี state)
  //                       // if (_isLoading) return;
  //                       // setState(() => _isLoading = true);

  //                       // final merchantId =
  //                       //     int.tryParse(widget.serpayment.toString()) ?? 0;
  //                       // final uuid = intentUuid.toString();

  //                       // try {
  //                       //   final resp = await postPaymentIntentsQRsession(
  //                       //     cusNo: '00007', // <- ใส่ customer_no จริง
  //                       //     intentsUuid: uuid,
  //                       //     bankMerchantId: merchantId,
  //                       //     // ref1: 'ref1',
  //                       //     ref2: 'ref200007',
  //                       //   );

  //                       //   if (resp == null) {
  //                       //     if (!mounted) return;
  //                       //     ScaffoldMessenger.of(context).showSnackBar(
  //                       //       const SnackBar(
  //                       //           content: Text('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้')),
  //                       //     );
  //                       //     return;
  //                       //   }

  //                       //   if (resp.statusCode >= 200 && resp.statusCode < 300) {
  //                       //     // success
  //                       //     String msg = 'สร้าง QR session สำเร็จ';
  //                       //     try {
  //                       //       final obj = jsonDecode(resp.body);
  //                       //       if (obj is Map && obj['message'] is String)
  //                       //         msg = obj['message'];
  //                       //     } catch (_) {}
  //                       //     if (!mounted) return;
  //                       //     ScaffoldMessenger.of(context).showSnackBar(
  //                       //       SnackBar(
  //                       //           content: Text(msg),
  //                       //           backgroundColor: Colors.green),
  //                       //     );
  //                       //     // TODO: ใช้ข้อมูลที่ตอบกลับมา (เช่น qr_url / session_id)
  //                       //   } else {
  //                       //     String err = '(${resp.statusCode})';
  //                       //     try {
  //                       //       final obj = jsonDecode(resp.body);
  //                       //       if (obj is Map && obj['message'] is String)
  //                       //         err = obj['message'];
  //                       //     } catch (_) {}
  //                       //     if (!mounted) return;
  //                       //     ScaffoldMessenger.of(context).showSnackBar(
  //                       //       SnackBar(
  //                       //           content:
  //                       //               Text('สร้าง QR session ไม่สำเร็จ $err'),
  //                       //           backgroundColor: Colors.red),
  //                       //     );
  //                       //   }
  //                       // } catch (e, st) {
  //                       //   debugPrint('❌ onTap QR session exception: $e\n$st');
  //                       //   if (!mounted) return;
  //                       //   ScaffoldMessenger.of(context).showSnackBar(
  //                       //     SnackBar(
  //                       //         content: Text('เกิดข้อผิดพลาด: $e'),
  //                       //         backgroundColor: Colors.orange),
  //                       //   );
  //                       // } finally {
  //                       //   if (mounted) setState(() => _isLoading = false);
  //                       // }
  //                     }),
  //               ];

  //               return Align(
  //                 alignment: Alignment.centerRight,
  //                 child: ConstrainedBox(
  //                   constraints: const BoxConstraints(maxWidth: 520),
  //                   child: isNarrow
  //                       ? Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: children,
  //                         )
  //                       // Column(
  //                       //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //                       //     children: children,
  //                       //   )
  //                       : Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: children,
  //                         ),
  //                 ),
  //               );
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _groupTileSub_IntentsCanceled(PaymentIntent p) {
    final intentUuid = p.intentUuid ?? '';
    final requestedAmount = p.requestedAmount ?? 0; // ถ้าเป็น num
    final createdAt = p.createdAt ?? '';
    final ExpireAt = p.softExpireAt ?? '';
    final statusVerbose = p.statusExtended!.statusVerbose ?? '';
    final statusThai = p.statusExtended!.statusThai ?? '';
    return Card(
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ แถวหัวเรื่อง
            Row(
              children: [
                // if (logoFile != null)
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.list_alt,
                    size: 20,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    widget.cuslang == 'EN' ? '$statusVerbose' : '$statusThai ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                chip('${ExpireAt}', Colors.red.withOpacity(.08),
                    Colors.red.shade700),
              ],
            ),
            const SizedBox(height: 10),

            // ✅ รายละเอียดย่อย
            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // if (bno.isNotEmpty)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.numbers, size: 15, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    intentUuid.toString(),
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontSize: 12.5,
                    ),
                  ),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.date_range,
                      size: 15, color: Color.fromARGB(137, 54, 53, 53)),
                  const SizedBox(width: 6),
                  Text(
                    createdAt.toString(),
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontSize: 12.5,
                    ),
                  ),
                ]),

                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.payments, size: 15, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.cuslang == "EN" ? "Total" : "ยอดรวม"}: ${fmtMoney(int.parse(requestedAmount.toString()) ?? 0)}',
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]),
              ],
            ),
            // SizedBox(
            //   height: 10,
            // ),
            // // === แทนที่ Wrap เดิมตรงท้ายการ์ดด้วยบล็อกนี้ ===
            // LayoutBuilder(
            //   builder: (_, c) {
            //     final isNarrow =
            //         c.maxWidth < 420; // หน้าจอแคบให้เรียงเป็นคอลัมน์
            //     final children = <Widget>[
            //       _secondaryAction(
            //         icon: Icons.close,
            //         label: widget.cuslang == 'EN'
            //             ? 'Cancel payment'
            //             : 'ยกเลิกการชำระเงิน',
            //         onTap: () async {},
            //       ),
            //       const SizedBox(width: 10, height: 10),
            //       _primaryAction(
            //           icon: Icons.payments,
            //           label: widget.cuslang == 'EN' ? 'Pay now' : 'ชำระเงิน',
            //           color: Colors.deepOrange,
            //           onTap: () async {
            //             if (!mounted) return; // ✅ กันตั้งแต่ต้น
            //             final size = MediaQuery.of(context).size;
            //           }),
            //     ];

            //     return Align(
            //       alignment: Alignment.centerRight,
            //       child: ConstrainedBox(
            //         constraints: const BoxConstraints(maxWidth: 520),
            //         child: isNarrow
            //             ? Row(
            //                 mainAxisSize: MainAxisSize.min,
            //                 children: children,
            //               )
            //             // Column(
            //             //     crossAxisAlignment: CrossAxisAlignment.stretch,
            //             //     children: children,
            //             //   )
            //             : Row(
            //                 mainAxisSize: MainAxisSize.min,
            //                 children: children,
            //               ),
            //       ),
            //     );
            //   },
            // ),
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
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.28),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: Font_.Fonts_T,
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                color: Colors.white,
              ),
            ),
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
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black12, width: .7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: Font_.Fonts_T,
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                color: Colors.grey.shade800,
              ),
            ),
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
    final selected = id.isNotEmpty && _selectedDocnos.contains(id);

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
          // ✅ Checkbox ของรายการ
          if ((b.status == '1'))
            Checkbox(
              value: selected,
              onChanged: (b.status != '1')
                  ? null
                  : (v) {
                      setState(() {
                        if (v == true) {
                          if (id.isNotEmpty) _selectedDocnos.add(id);
                        } else {
                          _selectedDocnos.remove(id);
                        }
                      });
                    },
            ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                        (b.status == '2')
                            ? b.docno! +
                                '${(widget.cuslang == 'EN') ? ' (Pending)' : ' (รอดำเนินการ)'} '
                            : b.docno!,
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
                      stCol,
                    ),
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
            LoadingAnimationWidget.inkDrop(color: Colors.green, size: 70),
          ],
        ),
      ),
    );
  }
}

class _Metric {
  final String label;
  final IconData icon;
  final Color color;
  final num sel;
  final num all;
  final String Function(num) fmt;
  _Metric(
      {required this.label,
      required this.icon,
      required this.color,
      required this.sel,
      required this.all,
      required this.fmt});
}

Widget _metricCard({
  required double width,
  required Color color,
  required IconData icon,
  required String label,
  required String leftVal, // selected
  required String rightVal, // all
  required double progress,
}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
    width: width,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          Text(
            label,
            style: TextStyle(
              fontFamily: Font_.Fonts_T,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: Colors.black.withOpacity(.85),
            ),
          ),
          // const Spacer(),
          // // badge % ขวาสุด
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //   decoration: BoxDecoration(
          //     color: color.withOpacity(.09),
          //     borderRadius: BorderRadius.circular(999),
          //     border: Border.all(color: color.withOpacity(.25), width: .7),
          //   ),
          //   child: Text(
          //     '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
          //     style: TextStyle(
          //       fontFamily: Font_.Fonts_T,
          //       fontWeight: FontWeight.w800,
          //       fontSize: 11,
          //       color: color.withOpacity(.95),
          //     ),
          //   ),
          // ),
        ]),
        const SizedBox(height: 8),
        // value L/R
        Row(
          children: [
            Expanded(
              child: Text(leftVal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.black87,
                  )),
            ),
            const SizedBox(width: 6),
            Text('/',
                style: TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                )),
            const SizedBox(width: 6),
            Expanded(
              child: Text(rightVal,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: Colors.black54,
                  )),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 8,
            backgroundColor: color.withOpacity(.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    ),
  );
}

Widget _pillBtn(
    {required IconData icon,
    required String label,
    required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(999),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.035),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12, width: .6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black.withOpacity(.7)),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                fontFamily: Font_.Fonts_T,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              )),
        ],
      ),
    ),
  );
}
