// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
// หรือ
import 'package:flutter/widgets.dart';

// Removed unused import
import 'package:chaoperty_user/Model/GetTranBill_string_model.dart';
import 'package:chaoperty_user/screen/buttonnavbar.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fl_pin_code/pin_code.dart';
import 'package:fl_pin_code/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http_parser/http_parser.dart';
// import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mime/mime.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import '../CRC_16_Prompay/generate_qrcode.dart';
import '../Constant/Myconstant.dart';
import '../Constant/global_http.dart';
import '../INSERT_Log/Insert_log.dart';

import '../Model/GetCFinnancetrans_Model.dart';
import '../Model/GetContractx_Fine_Model.dart';
import '../Model/GetInvoice_Model.dart';
import '../Model/GetInvoice_diapay_Model.dart';
import '../Model/GetInvoice_history_Model.dart';
import '../Model/GetInvoice_pay_Model.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTranBill_model.dart';
import '../Model/GetTrans_Model.dart';
import '../Model/GetTrans_fine_Model.dart';
import '../Model/Model_V2/payment_IntentsModel.dart';
import '../color.dart';
import '../screen/Screen_new/fitness_app_home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image/image.dart' as img;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr/qr.dart' as qr_lib;

import '../screen_Intents/APIS-V2/config-intents.dart';
import 'APIS-V3/payment-intents.dart';
import 'Model/IntentsContractx_Fine_Model.dart';
import 'Model/IntentsInv_history_Model.dart';
import 'bankCodeMap.dart';

class paymentSubV3InvAll extends StatefulWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<TeNantModel>? teNantModel;
  final String? cuslang;
  final String? serPayment;
  final String? serptPayment;
  final List<String>? selectedDocNos;
  paymentSubV3InvAll({
    Key? key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
    this.teNantModel,
    this.cuslang,
    this.serPayment,
    this.serptPayment,
    this.selectedDocNos,
  }) : super(key: key);

  @override
  State<paymentSubV3InvAll> createState() => _paymentSubV3InvAllState();
}

class _paymentSubV3InvAllState extends State<paymentSubV3InvAll>
    with TickerProviderStateMixin {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  String fmtMoney(num? n) =>
      '${nFormat.format(double.parse((n ?? 0).toStringAsFixed(2)))}';
  String fmtInt(num? n) =>
      '${nFormat.format(double.parse((n ?? 0).toInt().toString()))}';
  String fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return DateFormat('dd-MM-yyyy').format(d);
  }

  File? _image;
  Uint8List webimage = Uint8List(8);

  final payformkey = GlobalKey<FormState>();

  DateTime datex = DateTime.now();
  bool? isChecked = false;
  bool isLoading = true;
  bool _isProcessingLink = false; // Prevent double submission
  bool _isExporting = false;
  Uint8List? _exportQrBytes;
  GlobalKey qrImageKey = GlobalKey();
  GlobalKey qrBlockKey = GlobalKey();
  final namecontroller = TextEditingController();
  final datecontroller = TextEditingController();

  String? rtname,
      type,
      typex,
      renname,
      bill_name,
      bill_addr,
      bill_tax,
      bill_tel,
      bill_email,
      expbill,
      expbill_name,
      bill_default,
      bill_tser,
      foder,
      bills_name_,
      imglogo_,
      cid_doc,
      refpay;
  String? Form_nameshop,
      Form_typeshop,
      Form_bussshop,
      Form_bussscontact,
      Form_address,
      Form_tel,
      Form_email,
      Form_tax,
      rental_count_text,
      Form_area,
      Form_ln,
      Form_sdate,
      Form_ldate,
      Form_period,
      Form_rtname,
      Form_docno,
      Form_zn,
      Form_aser,
      Form_qty,
      discount_,
      payment_tser,
      payment_img,
      payment_co,
      payment_bname,
      payment_bank,
      invoicePay,
      invoicePayfine,
      cid_ren,
      cid_docqr,
      refpayup;
  List<PayMentModel> _PayMentModels = [];
  List<RenTalModel> renTalModels = [];
  List<InvoiceModel> _InvoiceModels = [];
  List<InvoiceModel> _InvoiceInIntent = [];

  String? selectedValue;
  String? numinvoice, paymentSer1, paymentName1, paymentSer2, paymentName2;
  final Form_payment1 = TextEditingController();
  final Form_payment2 = TextEditingController();
  List<TeNantModel> teNantModels = [];
  List<IntentsContractxFineModel> contractxFineModels = [];
  List<TransFineModel> transFineModels = [];

  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_disamt = 0.00,
      sum_disp = 0,
      in_amt = 0,
      sum_tran_fine = 0,
      fine_total = 0,
      sum_tran_fine_in = 0,
      sum_pvat_in = 0,
      sum_vat_in = 0,
      sum_wht_in = 0,
      sum_amt_in = 0,
      sum_disamt_in = 0;
  int tap = 0, select_pay = 0, gopay = 0, show_qr = 0, selectTap = 1;
  double dis_sum_Pakan = 0.00;
  String? cFinn,
      Value_newDateY = '',
      Value_newDateD = '',
      Value_newDateY1 = '',
      Value_newDateD1 = '';
  DateTime newDatetime = DateTime.now();
  List listitem = [];
  List<InvoicePayModel> invoicePayModels = [];
  List<TransBillStringModel> _TransBillstring = [];

  List<IntentsInvoiceHistoryModel> _InvoiceHistoryModels = [];
  List<PaymentIntent> paymentIntents = [];
  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  String QR_Ref1 = '', QR_Ref2 = '', QR_Ref3 = '', QR_Date15Min = '';

  // Countdown variables
  late DateTime expiryUtc;
  int _totalSecs = 300; // 15 minutes
  Uint8List? _uploadedSlipData;
  Map<String, dynamic>? _intentsSlipData;
  bool _expireDialogShown = false;
  // Trigger to update QR dialog without StreamBuilder loop
  final ValueNotifier<int> _qrUpdateTrigger = ValueNotifier(0);
  String? custno;
  String? renTal_user, renTal_name;
  String? return_qr_refapi1, return_qr_refapi2, return_qr_refapi3;
  String? qr_expiresAt, qr_softExpiresAt, activeQrSessionSoftExpire;
  String? qr_payload;
  // ใช้ค่าล่าสุด (อาจถูกอัปเดตจาก renew)
  String? nowExpiresIso;
  DateTime? expiryLocal;
  Uint8List? _slipImageBytes;
  String? _slipImageName;
  String? intentsAttacheSlipNo; // Added
  late Stream<int> _timerStream;
  String? qrDataNoIntens;
  // ================= Helpers for Right Panel =================

  double _d(dynamic v) {
    final s = (v ?? '0').toString().trim();
    return double.tryParse(s.isEmpty ? '0' : s) ?? 0;
  }

  String _fmtNum(dynamic v) => nFormat.format(_d(v));

  String _fmtDate(String? iso) {
    try {
      return DateFormat('dd-MM-yyyy')
          .format(DateTime.parse('${(iso ?? '').trim()} 00:00:00'));
    } catch (_) {
      return '';
    }
  }

  // =================  =================
  late AnimationController _localController;
  late Animation<double> _localAnimation;
  bool _usingLocalController = false;

  AnimationController get _effectiveController =>
      widget.mainScreenAnimationController ?? _localController;
  Animation<double> get _effectiveAnimation =>
      widget.mainScreenAnimation ?? _localAnimation;
  @override
  void initState() {
    super.initState();
    _timerStream =
        Stream.periodic(const Duration(seconds: 1), (_) => secondsUntilExpire())
            .asBroadcastStream();
    if (widget.mainScreenAnimationController == null) {
      _usingLocalController = true;
      _localController = AnimationController(vsync: this, value: 1.0);
      _localAnimation = AlwaysStoppedAnimation(1.0);
    }

    checkPreferance().then((value) {
      Value_newDateY1 = DateFormat('yyyy-MM-dd').format(newDatetime);
      Value_newDateD1 = DateFormat('dd-MM-yyyy').format(newDatetime);
      Value_newDateY = DateFormat('yyyy-MM-dd').format(newDatetime);
      Value_newDateD = DateFormat('dd-MM-yyyy').format(newDatetime);

      _initData();
    });
  }

  @override
  void dispose() {
    if (_usingLocalController) {
      _localController.dispose();
    }
    super.dispose();
  }

  String _toU16(String? v) => (v ?? '0').trim();
  Future<void> _initData() async {
    setState(() {
      isLoading = true;
      paymentSer1 = null;
      gopay = 0;
      qr_expiresAt = null;
    });
    if (widget.teNantModel == null) {
      await read_data();
    }
    await generateRandomString();

    SharedPreferences preferences = await SharedPreferences.getInstance();

    var custnoPreferences = await preferences.getString('custno');

    var renPreferences = await preferences.getString('renTalSer');

    String? custno16Bit = _toU16('$custnoPreferences');
    final ren16Bit = _toU16('$renPreferences');
    debugPrint(
        '_initData Step: redPaymentIntents: cusno=$custnoPreferences, propertyno=$renPreferences');
    debugPrint(
        '_initData 16Bit Step: redPaymentIntents: cusno=$custno16Bit, propertyno=$ren16Bit');
    await read_GC_rental();
    await red_payMent();

    // await redPaymentIntents(
    //     cusno: custno16Bit, propertyno: ren16Bit.toString() ?? '');
    await read_GC_fine();
    await red_Invoice();

    print('_InvoiceModels >>>>> ${widget.teNantModel?.length ?? 0}');

    print('_InvoiceModels >>>>> ${widget.teNantModel?.length ?? 0}');

    if (_PayMentModels.isNotEmpty) {
      _selectPayment(0);
    } else {
      setState(() {
        select_pay = 1;
      });
    }

    // Consolidated initialization to prevent race conditions & duplication
    await _initSubData();
    // await QrGenRef();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Null> _initSubData() async {
    setState(() {
      sum_disamt = 0;
      sum_disamt_in = 0;
      sum_pvat_in = 0;
      sum_vat_in = 0;
      sum_wht_in = 0;
      sum_amt_in = 0;
      sum_tran_fine_in = 0;
      sum_disamt_in = 0;
    });
    await read_GC_fine();
    // if (contractxFineModels.isNotEmpty) {
    await in_Trans_fine_re();
    // }
    // ---------- dteilData ----------
    for (var Indexinv = 0; Indexinv < _InvoiceModels.length; Indexinv++) {
      final rowInv = _InvoiceModels[Indexinv];

      // Clear history accumulator before fetching for this invoice to avoid duplication
      setState(() {
        _InvoiceHistoryModels.clear();
      });

      // 1) รอให้โหลด/select เสร็จก่อน
      await red_Trans_select(Indexinv);

      // 2) ทำต่อหลัง select เสร็จ (เหมือนใน then)
      // await in_Trans_dis_inv(rowInv);
    }
  }

  // Future<void> redPaymentIntents(
  //     {required String cusno, required String propertyno}) async {
  //   if (mounted) {
  //     setState(() {
  //       paymentIntents.clear();
  //     });
  //   }

  //   debugPrint('Step: redPaymentIntents: START');
  //   debugPrint('Step: redPaymentIntents: cusno=$cusno, propertyno=$propertyno');

  //   try {
  //     final response =
  //         await postPaymentIntentsState(cusno: cusno, propertyno: propertyno);

  //     if (response == null) {
  //       debugPrint('Step: redPaymentIntents: ❌ Response is Null');
  //       return;
  //     }

  //     // debugPrint('Step: redPaymentIntents: Body: ${response.body}');

  //     if (response.body.isEmpty) {
  //       debugPrint('Step: redPaymentIntents: ❌ response.body ว่าง');
  //       return;
  //     }

  //     final root = json.decode(response.body);

  //     if (root is! Map<String, dynamic>) {
  //       debugPrint(
  //           'Step: redPaymentIntents: ❌ รูปแบบ JSON ไม่ใช่ Map<String, dynamic>');
  //       return;
  //     }

  //     final intentsListRaw = root['data'];

  //     final intents = (intentsListRaw is List
  //             ? intentsListRaw.whereType<Map<String, dynamic>>()
  //             : const <Map<String, dynamic>>[])
  //         .map((m) => PaymentIntent.fromJson(m))
  //         .where((p) => p.bankmerchantid.toString() == '${widget.serPayment}')
  //         .toList();

  //     if (mounted) {
  //       setState(() {
  //         paymentIntents = intents;
  //       });
  //     }

  //     debugPrint(
  //         'Step: redPaymentIntents: ✅ intents loaded: ${intents.length}');
  //     if (intents.isNotEmpty) {
  //       for (var i = 0; i < intents.length; i++) {
  //         debugPrint(
  //             '   [$i] intentUuid: ${intents[i].intentUuid}, Status: ${intents[i].status}');
  //         if (intents[i].invoices.isNotEmpty) {
  //           for (var inv in intents[i].invoices) {
  //             debugPrint('       -> Invoice: ${inv.billReference}');
  //           }
  //         } else {
  //           debugPrint('       -> No Invoices');
  //         }
  //       }
  //     } else {
  //       debugPrint('   No intents in the list.');
  //     }
  //   } catch (e, stack) {
  //     debugPrint(
  //         'Step: redPaymentIntents: ❌ Exception parsing payment intents: $e');
  //     debugPrint('🧭 StackTrace:\n$stack');
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   }
  // }

  void _selectPayment(int index) {
    if (index < 0 || index >= _PayMentModels.length) return;

    var fine_amt = _PayMentModels[index].fine == '1'
        ? _PayMentModels[index].fine_c == '0.00'
            ? double.parse(double.parse(_PayMentModels[index].fine_a!)
                .toStringAsFixed(2)
                .toString())
            : double.parse((((sum_amt - sum_disamt - dis_sum_Pakan) *
                        double.parse(_PayMentModels[index].fine_c!)) /
                    100)
                .toStringAsFixed(2)
                .toString())
        : fine_total;

    setState(() {
      fine_total = _PayMentModels[index].fine == '1' ? fine_amt : 0.00;
      select_pay = 1; // Keep list visible
      gopay = 1; // Show QR section

      paymentName1 = _PayMentModels[index].ptname;
      selectedValue = _PayMentModels[index].bno.toString();
      paymentSer1 = _PayMentModels[index].ser.toString();

      payment_tser = _PayMentModels[index].ptser.toString();
      payment_co = _PayMentModels[index].co.toString();
      payment_img = _PayMentModels[index].img.toString();
      payment_bname = _PayMentModels[index].bname.toString();
      payment_bank = _PayMentModels[index].bank.toString();
      var timrsta = DateTime.now().millisecondsSinceEpoch;

      // if (_PayMentModels[index].ptser == '8') {
      //   refpay = 'GEN$timrsta${getRandomString(5)}';
      // } else {
      //   if (widget.teNantModel == null) {
      //     refpay =
      //         'WR$cid_doc${DateFormat('ddMM').format(datex)}${(datex.year + 543)}';
      //   } else {
      //     refpay = 'WR$cid_doc$timrsta';
      //   }
      // }

      Form_payment1.text = (sum_pvat +
              sum_tran_fine -
              dis_sum_Pakan -
              (sum_disamt + sum_disamt_in) +
              (sum_amt_in + sum_tran_fine_in) +
              (fine_total))
          .toStringAsFixed(2)
          .toString();
    });
  }

  String getUuid() {
    var r = Random();
    return List.generate(36, (i) {
      if (i == 8 || i == 13 || i == 18 || i == 23) return '-';
      if (i == 14) return '4';
      if (i == 19) return ((r.nextInt(4) + 8).toRadixString(16));
      return r.nextInt(16).toRadixString(16);
    }).join();
  }

  String stringEncryption(String text, String key) {
    if (key.isEmpty) return text;
    String chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    String res = '';
    for (int i = 0; i < text.length; i++) {
      int charIndex = chars.indexOf(text[i]);
      if (charIndex == -1) {
        res += text[i];
        continue;
      }
      int keyChar = key.codeUnitAt(i % key.length);
      int newIndex = (charIndex + keyChar) % chars.length;
      res += chars[newIndex];
    }
    return res;
  }

  Future<Null> CreatePaymentItem() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 30, // ปรับขนาดของ CircleAvatar
                    backgroundImage: AssetImage('assets/images/Icon-chao.png'),
                  ),
                ),
                LoadingAnimationWidget.inkDrop(
                  color: Colors.green,
                  size: 70,
                ),
              ],
            ),
          );
        },
      );
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer');

      final ren16Bit = _toU16('$ren').toString();

      // custno ใช้ตัวเดียว (ทุก invoice ลูกค้าเดียวกัน)
      // ✅ Fix: ถ้า _TransModels ว่าง (เพราะไม่เจอข้อมูล) ให้ใช้ custno ที่ login มาแทน
      final String custnoLocal = _TransModels.isNotEmpty
          ? '${_TransModels.first.custno ?? ''}'
          : (prefs.getString('custno') ?? '');

      final custno16Bit = _toU16(custnoLocal).toString();
      final All_lateFee = double.tryParse(sum_tran_fine_in.toString()) ?? 0.0;
      final allDiscountAmount = double.tryParse(sum_disamt.toString()) ?? 0.0;
      final All_depositAmount = 0.0;
      final All_insuranceAmount = 0.0;
      final All_withholdingAmount = 0.0;

      // Reset accumulators to prevent double counting on retry
      setState(() {
        sum_pvat_in = 0;
        sum_vat_in = 0;
        sum_wht_in = 0;
        sum_amt_in = 0;
        sum_tran_fine_in = 0;
        sum_disamt_in = 0;
      });

      // ----------
      List<IntentsInvoiceHistoryModel> _InvoiceHistory = [];
      List<InvoiceDisPayModel> _InvoiceDisPay = [];
      List<IntentsContractxFineModel> contractxFine = [];
      final List<Map<String, dynamic>> invs = [];

      // 0) Prepare fine data once
      await read_GC_fine();
      // Always populate invoicePayModels — handles both with/without fine internally
      await in_Trans_fine_re();

      // ---------- dteilData ----------
      for (var Indexinv = 0; Indexinv < _InvoiceModels.length; Indexinv++) {
        final rowInv = _InvoiceModels[Indexinv];

        // Clear history accumulator before fetching for this invoice to avoid duplication
        setState(() {
          _InvoiceHistoryModels.clear();
        });

        // 1) รอให้โหลด/select เสร็จก่อน
        await red_Trans_select(Indexinv);

        // 2) ทำต่อหลัง select เสร็จ (เหมือนใน then)
        // await in_Trans_dis_inv(rowInv);

        setState(() {
          _InvoiceHistory.addAll(_InvoiceHistoryModels);
          // _InvoiceDisPay.addAll(_InvoiceDisPayModels);
          contractxFine.addAll(contractxFineModels);
        });

        final refnosSelected =
            _InvoiceHistoryModels.map((m) => m.refno).toSet().join(',');

        final invFine = await GC_Inv_fine(docno: rowInv.docno.toString());
        final double fineTotal = (invFine['total'] as num?)?.toDouble() ?? 0.0;

        final List<Map<String, dynamic>> listFineINV =
            (invFine['ok'] == true && fineTotal > 0)
                ? [
                    {
                      "docno": rowInv.docno,
                      "expser": int.tryParse('${invFine['expser'] ?? 0}') ?? 0,
                      "expname": invFine['expname'] ?? "ชำระเกินกำหนด",
                      "no": int.tryParse('${invFine['no'] ?? 0}') ?? 0,
                      "pvat": (invFine['pvat'] as num?)?.toDouble() ?? 0.0,
                      "vser": int.tryParse('${invFine['vser'] ?? 0}') ?? 0,
                      "vtype": invFine['vtype'] ?? '',
                      "nvat": (invFine['nvat'] as num?)?.toInt() ?? 0,
                      "vat": (invFine['vat'] as num?)?.toDouble() ?? 0.0,
                      "wht": (invFine['wht'] as num?)?.toDouble() ?? 0.0,
                      "total": fineTotal,
                    }
                  ]
                : [];

        // ---------- metadata (Use CURRENT invoice history, not accumulated) ----------
        final List<Map<String, dynamic>> metadataList =
            _InvoiceHistoryModels.map<Map<String, dynamic>>((b) {
          final expname = '${b.descr ?? ''}';
          print('total: ${b.total_t}');
          final totalBill = double.tryParse('${b.total_t ?? 0}') ?? 0.0;
          final List<Map<String, dynamic>> listFine = []; // ✅ สำคัญมาก
          return {
            'expname': expname,
            'docno': '${b.refno ?? ''}',
            'date': (b.date is DateTime)
                ? (b.date as DateTime).toIso8601String()
                : b.date,
            'cid': '${b.cid ?? ''}',
            // 'custno': custno16Bit,
            // 'st': '${b.st ?? ''}',
            // 'status': '',
            'payser': int.tryParse('$paymentSer1') ?? 0,
            // 'docno_all': refnosSelected,
            'pri_bill': double.tryParse('${b.pri ?? 0}') ?? 0.0,
            'pvat_bill': double.tryParse('${b.pvat ?? 0}') ?? 0.0,
            'vat_bill': double.tryParse('${b.vat ?? 0}') ?? 0.0,
            'nvat': int.tryParse('${b.nvat ?? 0}') ?? 0.0,
            'wht_bill': double.tryParse('${b.wht ?? 0}') ?? 0.0,
            'late_fee': 0,
            'list_fee': listFine,
            'total_bill': totalBill,
            'selected': rowInv.docno,
          };
        }).toList();

        final pvat = _d(rowInv.pvat);
        final vat = _d(rowInv.vat);
        final wht = _d(rowInv.wht);
        final amtnet = (_d(rowInv.amt) + _d(rowInv.vat)) - _d(rowInv.wht);
        final dis = _d(rowInv.dis);
        final total = _d(rowInv.amtall);

        String fineStr = '0';
        try {
          final foundFine = invoicePayModels.firstWhere(
            (m) => m.docno.toString() == rowInv.docno.toString(),
            orElse: () => InvoicePayModel(fine: '0'),
          );
          fineStr = foundFine.fine ?? '0';
        } catch (e) {
          fineStr = '0';
        }
        final totalfine = _d(fineStr);

        // ---------- invoices ----------
        invs.add({
          "invoice_id": 0,
          "bill_reference": rowInv.docno,
          "amount": amtnet,
          "late_fee": totalfine,
          "discount_amount": dis,
          "deposit_amount": 0, // ถ้ามี
          "insurance_amount": 0, // ถ้ามี
          "withholding_amount": 0,
          "total": total,
          "list_fee": listFineINV, // ✅ ใส่ตรงนี้
          "metadata": metadataList,
        });
      }

      // print({
      //   'cusNo': custno16Bit,
      //   'propertyNo': ren16Bit,
      //   'payedType': "invoice",
      //   'payser': int.tryParse('${widget.serPayment}') ?? 0,
      //   'typepayser': int.tryParse('${widget.serptPayment}') ?? 0,
      //   'requestedAmount': _d(0),
      //   // _netPayAmount + _d(sumFineTotalFooter), // ✅ ไม่ใช้ string format
      //   'inVoices': invs,
      //   'transselect': _InvoiceHistory.map((e) => e.toJson()).toList(),
      // });
      final requestedAmountTotalBill = sum_pvat +
          sum_tran_fine -
          dis_sum_Pakan -
          (sum_disamt + sum_disamt_in) +
          (sum_amt_in + sum_tran_fine_in) +
          (fine_total);
      await PostPaymentIntents(
        cusNo: custno16Bit,
        propertyNo: ren16Bit,
        payedType: "invoice",
        payser: int.tryParse('${widget.serPayment}') ?? 0,
        typepayser: int.tryParse('${widget.serptPayment}') ?? 0,
        requestedAmount: _d(requestedAmountTotalBill), // ✅ ไม่ใช้ string format
        lateFee: All_lateFee,
        discountAmount: allDiscountAmount,
        depositAmount: All_depositAmount,
        insuranceAmount: All_insuranceAmount,
        withholdingAmount: All_withholdingAmount,
        inVoices: invs,
        transselect: _InvoiceHistory.map((e) => e.toJson()).toList(),
      );
      // await redPaymentIntents(
      //     cusno: custno16Bit, propertyno: ren16Bit.toString() ?? '');
      // await QrGenRef();
    } catch (e) {
      print('❌ Error in CreatePaymentItem: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Error', style: TextStyle(fontFamily: Font_.Fonts_T)),
            content: Text('$e', style: TextStyle(fontFamily: Font_.Fonts_T)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child:
                      Text('OK', style: TextStyle(fontFamily: Font_.Fonts_T)))
            ],
          ),
        );
      }
    } finally {
      // setState(() {
      //   selectedPaymentKey = null;
      //   _expandedInnerGroupKey = null;
      // });
      // await _resetToInitialState(targetPage: 1, billAll: false);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // ----------------------
// UI layer caller
// ----------------------
  int? bankMerchantId;
  String? ref1 = '', ref2 = '', ref3 = '';
  Future<void> PostPaymentIntents(
      {required String cusNo,
      required String propertyNo,
      required String payedType,
      required int payser,
      required int typepayser,
      required double requestedAmount,
      required double lateFee,
      required double discountAmount,
      required double depositAmount,
      required double insuranceAmount,
      required double withholdingAmount,
      required List<Map<String, dynamic>> inVoices,
      required List<Map<String, dynamic>> transselect}) async {
    debugPrint('🔄 เรียกใช้งาน PostPaymentIntents()');

    // final response = await postPaymentIntents(
    //     cusNo: cusNo,
    //     propertyNo: propertyNo,
    //     payedType: payedType,
    //     chanNel: "testerx",
    //     requestedAmount: requestedAmount,
    //     lateFee: lateFee,
    //     discountAmount: discountAmount,
    //     depositAmount: depositAmount,
    //     insuranceAmount: insuranceAmount,
    //     withholdingAmount: withholdingAmount,
    //     // createdById: "10101010101010",
    //     isAdminCreated: true,
    //     bankMerchantId: payser,
    //     bankMerchantType: typepayser,
    //     descripTion: "",
    //     inVoices: inVoices,
    //     transSelect: transselect);

    // if (response == null) {
    //   debugPrint('❌ ไม่มี response จาก server');
    //   return;
    // }

    try {
//       final jsonRes = json.decode(response.body);
//       debugPrint('🧾 Raw JSON: $jsonRes');
// //     🧾 Raw JSON: {uuid: 1e4170c2-9c61-4624-962f-355ee19a5577, payment_intent_no: 4750242302, status: draft, amount: 8420.00, currency: THB, customer_no: 65535, property_no:
// // 65681, channel: testerx, soft_expire_at: 2026-01-30T16:49:59.000000Z, bank_merchant_id: 39}

//       // ✅ 1. Update numinvoice with new UUID
//       final newUuid = jsonRes['uuid'];
      setState(() {
        // numinvoice = newUuid;
        bankMerchantId = 0;
        ref1 = '';
        ref2 = '';
        ref3 = '';
      });

      // ✅ 2. Reload intents to ensure QrGenRef finds the new intent
      // if (newUuid != null) {
      //   // await redPaymentIntents(cusno: cusNo, propertyno: propertyNo);
      // }

      // ✅ 3. Call QrGenRef
      await QrGenRef();
    } catch (e, stack) {
      debugPrint('❌ Exception parsing payment intents: $e');
      debugPrint('🧭 StackTrace:\n$stack');
    }
  }

  String _fmtExpireLocal(String? isoUtc) {
    final d =
        (isoUtc == null || isoUtc.isEmpty) ? null : DateTime.tryParse(isoUtc);
    if (d == null) return '-';
    return DateFormat('d-MM-yyyy HH:mm').format(d.toLocal());
  }

  int secondsUntilExpire() {
    // Fix: Use qr_softExpiresAt as source of truth for UI timer
    if (qr_softExpiresAt == null || qr_softExpiresAt!.isEmpty) {
      return 0;
    }
    final expiry = DateTime.tryParse(qr_softExpiresAt!);
    if (expiry == null) return 0;

    final now = DateTime.now();
    // Use .toLocal() or just rely on difference handling timezones (it does convert to common if needed, usually)
    // But safe to just compare them.
    final sec = expiry.toLocal().difference(now).inSeconds;
    return sec < 0 ? 0 : sec;
  }

  String _hhmmssFromSecs(int secs) {
    final h = (secs ~/ 3600).toString().padLeft(2, '0');
    final m = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // Future<Null> QrGenRef(
  //     {String? QR_Ref1,
  //     String? QR_Ref2,
  //     String? QR_Ref3,
  //     String? softExpireAt}) async {
  //   String _fmtDT(DateTime? d) =>
  //       d == null ? '-' : DateFormat('dd-MM-yyyy HH:mm').format(d.toLocal());
  //   final String targetUuid = '$numinvoice';

  //   // ✅ ตรวจสอบว่ามี intent หรือไม่
  //   final filteredIntents =
  //       paymentIntents.where((p) => p.intentUuid == targetUuid).toList();

  //   if (filteredIntents.isEmpty) {
  //     debugPrint('❌ ไม่พบ Intent ที่ตรงกับ UUID: $targetUuid');
  //     return;
  //   }

  //   // final firstIntent = filteredIntents.first; // Replaced
  //   var currentIntent =
  //       filteredIntents.first; // ✅ Declare as var to allow update

  //   final bankId = currentIntent.bankmerchantid ?? 0;
  //   final bankItem = _PayMentModels.firstWhere(
  //     (p) => p.ser.toString() == '$bankId',
  //     orElse: () => PayMentModel(
  //       ser: '-',
  //       bname: '-',
  //     ),
  //   );

  //   final paybname = bankItem.bname;
  //   final paybno = bankItem.bno;
  //   final payptser = bankItem.ptser;
  //   final payser = bankItem.ser;
  //   final payimg = bankItem.img;

  //   final intentStatusThai = currentIntent.statusExtended?.statusThai ?? '-';

  //   // final intentSoftExpireAt = _fmtDT(currentIntent.softExpireAt);
  //   // final intentCreatedAt = _fmtDT(currentIntent.createdAt);
  //   // final intentUpdatedAt = _fmtDT(currentIntent.updatedAt);
  //   // Unused variables commented out

  //   // ✅ ตั้งค่า qr_expiresAt จาก intent ที่มีอยู่ (ถ้ามี) เพื่อป้องกันการสร้าง QR ซ้ำ
  //   if (currentIntent.softExpireAt != null) {
  //     qr_expiresAt = currentIntent.softExpireAt!.toIso8601String();
  //   }

  //   // ---------- 0) ถ้ายังไม่มี QR ให้สร้างครั้งแรก ----------
  //   final dData = await _DetailsPaymentIntentsReload();

  //   // Store uploaded slip data if exists (แก้ไข Type Error: _uploadedSlipData เป็น Uint8List)
  //   if (dData != null && dData['attaches'] != null) {
  //     // _uploadedSlipData = dData['attaches']; // ❌ Error: dData['attaches'] เป็น Map ไม่ใช่ Uint8List
  //     // เราอาจจะแค่ log ไว้ หรือถ้าต้องการแสดงผลต้องโหลดรูปจริง
  //     _intentsSlipData = dData['attaches'] as Map<String, dynamic>;
  //     intentsAttacheSlipNo = _intentsSlipData!['slip_no'] as String?;
  //     debugPrint('📎 พบหลักฐานการชำระ: ${_intentsSlipData!['slip_no']}');
  //     debugPrint('📎 ข้อมูล attaches: $_intentsSlipData');
  //     debugPrint('📎 พบหลักฐานการชำระ (Metadata): ${dData['attaches']}');

  //     // กรณีนี้เราอาจจะถือว่า user มีสลิปแล้ว แต่เรายังไม่มี bytes ในเครื่อง
  //     // หาก logic คือ "ถ้ามีสลิปแล้วไม่ต้อง check expire" เราอาจจะใช้ flag อื่นช่วย
  //     // หรือถ้าต้องการให้ _uploadedSlipData ไม่ว่าง เพื่อให้ UI รู้ว่ามีสลิปแล้ว (hack)
  //     // _uploadedSlipData = Uint8List(0); // ✅ Hack: ใส่ข้อมูลว่างเพื่อให้ไม่ null (แต่ตรวจสอบ logic อื่นด้วย)
  //   } else {
  //     _intentsSlipData = null;
  //     _uploadedSlipData = null;
  //     debugPrint('📎 ไม่พบหลักฐานการชำระ');
  //   }

  //   // ✅ ใช้ค่าจาก Argument ถ้ามี
  //   if (QR_Ref1 != null && QR_Ref1.isNotEmpty) return_qr_refapi1 = QR_Ref1;
  //   if (QR_Ref2 != null && QR_Ref2.isNotEmpty) return_qr_refapi2 = QR_Ref2;
  //   if (QR_Ref3 != null && QR_Ref3.isNotEmpty) return_qr_refapi3 = QR_Ref3;
  //   if (softExpireAt != null && softExpireAt.isNotEmpty) {
  //     qr_expiresAt = softExpireAt;
  //     qr_softExpiresAt = softExpireAt;
  //   }

  //   // ✅ ถ้ามี active_qr_session อยู่แล้ว ให้โหลดข้อมูลมาใช้ (กรณี Argument ว่าง)
  //   if (dData != null && dData['active_qr_session'] != null) {
  //     debugPrint('🔄 มี active_qr_session → โหลดข้อมูล QR ที่มีอยู่');
  //     final qrSession = dData['active_qr_session'] as Map<String, dynamic>;

  //     final ref1 = qrSession['ref1'] as String?;
  //     final ref2 = qrSession['ref2'] as String?;
  //     final ref3 = qrSession['ref3'] as String?;
  //     activeQrSessionSoftExpire = qrSession['soft_expire_at'] as String?;
  //     debugPrint('✅ โหลด QR Session: ref1=$ref1, ref2=$ref2, ref3=$ref3');

  //     if (return_qr_refapi1 == null || return_qr_refapi1!.isEmpty)
  //       return_qr_refapi1 = ref1;
  //     if (return_qr_refapi2 == null || return_qr_refapi2!.isEmpty)
  //       return_qr_refapi2 = ref2;
  //     if (return_qr_refapi3 == null || return_qr_refapi3!.isEmpty)
  //       return_qr_refapi3 = ref3;

  //     final expiresIso = qrSession['soft_expire_at'] as String?;
  //     if (qr_expiresAt == null || qr_expiresAt!.isEmpty) {
  //       qr_expiresAt = expiresIso;
  //       qr_softExpiresAt = expiresIso;
  //     }
  //   } else {
  //     // ไม่มี active session → สร้างใหม่
  //     debugPrint('🆕 ยังไม่มี QR → สร้างครั้งแรก');
  //     final ok = await _renewQrAndReload();
  //     if (!mounted) return;
  //     if (!ok) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('สร้าง QR ไม่สำเร็จ กรุณาลองอีกครั้ง'),
  //         ),
  //       );
  //       return;
  //     }
  //     // ✅ Refresh local variable 'currentIntent' with the newly loaded data
  //     if (paymentIntents.isNotEmpty) {
  //       currentIntent = paymentIntents.first;
  //     }
  //   }

  //   // ✅ Fallback: ถ้ายังไม่มี Ref ให้ลองใช้ค่าจาก Intent (ใช้ currentIntent ที่ update แล้ว)
  //   if (return_qr_refapi1 == null || return_qr_refapi1!.isEmpty) {
  //     String? fallbackCid;
  //     // พยายามหา cid จาก metadata ตัวแรก
  //     if (currentIntent.invoices.isNotEmpty) {
  //       final inv = currentIntent.invoices.first;
  //       if (inv.metadata.isNotEmpty) {
  //         fallbackCid = inv.metadata.first.cid;
  //       }
  //     }

  //     if (fallbackCid != null && fallbackCid.isNotEmpty) {
  //       return_qr_refapi1 = fallbackCid;
  //     } else if (currentIntent.customerNo != null &&
  //         currentIntent.customerNo!.isNotEmpty) {
  //       return_qr_refapi1 = currentIntent.customerNo;
  //     }
  //   }
  //   if (return_qr_refapi2 == null || return_qr_refapi2!.isEmpty) {
  //     if (currentIntent.paymentIntentNo != null &&
  //         currentIntent.paymentIntentNo!.isNotEmpty) {
  //       return_qr_refapi2 = currentIntent.paymentIntentNo;
  //     }
  //   }

  //   // ---------- 1) Expiration Logic Split ----------
  //   // A) soft_expire_at (Bill Deadline): Determines if we are ALLOWED to create/renew.
  //   final billDeadline = currentIntent.softExpireAt;
  //   final isBillDead =
  //       billDeadline != null && DateTime.now().isAfter(billDeadline);

  //   // B) activeQrSessionSoftExpire (Session Time): Determines if the current QR is valid or needs renewal.
  //   final sessionExpiryStr = activeQrSessionSoftExpire;
  //   final sessionDate =
  //       sessionExpiryStr != null ? DateTime.tryParse(sessionExpiryStr) : null;
  //   final isSessionExpired =
  //       sessionDate == null || DateTime.now().isAfter(sessionDate);

  //   // ⚠️ ถ้ามีสลิปอัปโหลดแล้ว ไม่ต้อง renew QR เพราะไม่จำเป็นต้องใช้ QR อีกแล้ว
  //   final hasUploadedSlip = _uploadedSlipData != null;

  //   // ⚠️ Check if we need (and are allowed) to renew
  //   // User Rule: If soft_expire_at is NOT expired, can create/renew forever.
  //   // If it IS expired, presumably stop? (Or maybe just don't renew, showing old?)
  //   // Logic: If Session Expired AND Bill NOT Dead -> Renew.

  //   if (isSessionExpired && !hasUploadedSlip) {
  //     if (!isBillDead) {
  //       debugPrint('✅ Session Expired & Bill Valid -> Auto Renewing...');
  //       final ok = await _renewQrAndReload();
  //       if (!mounted) return;
  //       if (!ok) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('ต่ออายุ QR ไม่สำเร็จ กรุณาลองอีกครั้ง')),
  //         );
  //         return;
  //       }
  //     } else {
  //       debugPrint(
  //           '❌ Bill Expired (soft_expire_at) -> Cannot Renew/Generate new QR.');
  //       // Optional: Show warning or allow showing old QR?
  //       // For now, we just don't renew. The UI might show Expired state.
  //     }
  //   } else if (isSessionExpired && hasUploadedSlip) {
  //     debugPrint('⚠️ QR หมดอายุ แต่มีสลิปอัปโหลดแล้ว → ข้ามการ renew');
  //   } else {
  //     // ✅ Session Valid -> Reset flag to false so UI shows QR
  //     _expireDialogShown = false;
  //   }

  //   // Refresh Session Expiry for UI after potential renew
  //   final currentSessionExpiryIso = activeQrSessionSoftExpire;
  //   // Set qr_expiresAt for UI Display (Timer) to reference SESSION time
  //   qr_expiresAt = currentSessionExpiryIso;
  //   qr_softExpiresAt = currentSessionExpiryIso;

  //   // ---------- 2) ตั้งค่าเวลาหมดอายุ/ตัวช่วยแสดงผล ----------
  //   // ใช้ค่าล่าสุด (อาจถูกอัปเดตจาก renew)
  //   String nowExpiresIso = qr_expiresAt?.toString() ?? '';
  //   DateTime expiryLocal =
  //       (DateTime.tryParse(nowExpiresIso) ?? DateTime.now()).toLocal();

  //   // Safety Override: If server returns expired time, force 5 minutes valid window locally
  //   if (expiryLocal.isBefore(DateTime.now())) {
  //     debugPrint(
  //         '⚠️ Server returned expired time ($expiryLocal). Forcing local 5-minute override.');
  //     expiryLocal = DateTime.now().add(const Duration(minutes: 5));
  //     nowExpiresIso = expiryLocal.toIso8601String();

  //     // Update state variables to match override
  //     qr_expiresAt = nowExpiresIso;
  //     qr_softExpiresAt = nowExpiresIso;
  //     activeQrSessionSoftExpire = nowExpiresIso;
  //   }
  //   final DateTime expiryUtc = expiryLocal.toUtc();

  //   // อายุเต็ม (วินาที) — หากระบบคุณรู้แน่ชัดว่า 5 นาที ให้คง 300
  //   // หรือจะคำนวณจาก now→expiry ตอนเปิดก็ได้
  //   final nowUtc = DateTime.now().toUtc();
  //   final diff = expiryUtc.difference(nowUtc).inSeconds;

  //   String _hhmmssFromSecs(int secs) {
  //     final h = (secs ~/ 3600).toString().padLeft(2, '0');
  //     final m = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
  //     final s = (secs % 60).toString().padLeft(2, '0');
  //     return '$h:$m:$s';
  //   }

  //   String _fmtExpireLocal(String? isoUtc) {
  //     final d =
  //         (isoUtc == null || isoUtc.isEmpty) ? null : DateTime.tryParse(isoUtc);
  //     if (d == null) return '-';
  //     return DateFormat('d-MM-yyyy HH:mm').format(d.toLocal());
  //   }

  //   // Assign local vars for display
  //   final ref1 = return_qr_refapi1 ?? '-';
  //   final ref2 = return_qr_refapi2 ?? '-';
  //   final ref3 = return_qr_refapi3 ?? '-';
  //   final bno = paybno ?? '-';
  //   final bname = paybname ?? '-';
  //   // final imgUrl = (MyConstant().domain) + (payimg ?? '');
  //   // ใช้ amountIntents (ที่ถูกต้องแล้ว)
  //   final amtVal = currentIntent.requestedAmount ?? 0.0;
  //   final amtStr = nFormat.format(amtVal);
  //   final amtRaw = amtVal.toStringAsFixed(2);

  //   final ptser = '${payptser}';
  //   final expLbl = _fmtExpireLocal(qr_expiresAt);

  //   // Update class state include vars used in UI
  //   setState(() {
  //     _totalSecs = diff > 0 ? diff : 0;
  //     this.return_qr_refapi1 = ref1;
  //     this.return_qr_refapi2 = ref2;
  //     this.return_qr_refapi3 = ref3;
  //     this.QR_Date15Min = expLbl;
  //     // Fixed: Keep qr_softExpiresAt as ISO string for logic checks
  //     this.qr_softExpiresAt = qr_expiresAt;
  //     this.payment_tser = ptser;
  //     _expireDialogShown = false; // Reset expire dialog flag
  //   });

  //   // Payload debugging logs removed for production/cleanup
  //   /*
  //   debugPrint('💳 Payment Type (ptser): $ptser');
  //   debugPrint('💳 ref1: $ref1, ref2: $ref2');
  //   debugPrint('💳 Bank No: $bno');
  //   debugPrint('💳 Amount: $amtVal');
  //   debugPrint('💳 qr_payload: $qr_payload');
  //   */

  //   final qrData = (ptser == '7')
  //       ? qr_payload.toString()
  //       : (ptser == '6')
  //           ? '|$bno\r$ref1\r$ref2\r${amtRaw.replaceAll('.', '')}' // PromptPay Bill Payment
  //           : (ptser == '5')
  //               ? generateQRCode(promptPayID: bno, amount: amtVal) // PromptPay
  //               : (ptser == '2')
  //                   ? '${payimg}'
  //                   : '';

  //   // Notify Listeners (Dialog) that QR data changed
  //   _qrUpdateTrigger.value++;

  //   // debugPrint('💳 Generated QR Data (length: ${qrData.length}): $qrData');

  //   // ... validation logic ...
  //   if (qrData.isEmpty) {
  //     debugPrint(
  //         '❌ ไม่สามารถสร้าง QR ได้ - Payment type $ptser ไม่รองรับ QR หรือข้อมูลไม่ครบ');
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           ptser == '1'
  //               ? 'การชำระเงินสดไม่รองรับ QR Code'
  //               : 'ไม่สามารถสร้าง QR Code ได้ ข้อมูลไม่ครบถ้วน',
  //         ),
  //         backgroundColor: Colors.orange,
  //       ),
  //     );
  //     return;
  //   }

  //   // ---------- 4) เปิดแสดง QR ----------
  //   final _loadingFuture = Future.delayed(const Duration(seconds: 2));
  //   debugPrint('🔵 About to show sticky flexible bottom sheet');
  //   debugPrint('QR Data: $qrData');

  //   // เรียก bottom sheet หรือ update UI อื่นๆ ตาม logic เดิม

  //   debugPrint('Amount: $amtStr');
  //   debugPrint('Bank Name: $bname');

  //   // เรียก bottom sheet หรือ update UI อื่นๆ ตาม logic เดิมของคุณ
  //   // เช่น _showPaymentConfirmationSheet(context); หรือ setState ตัวแปรที่ใช้แสดงผล
  // }

  Future<void> QrGenRef() async {
    final DateTime now = DateTime.now();

    // ไม่ให้มี comma ท้าย
    final invoicePayStr = invoicePayModels.map((e) => '${e.docno}').join(',');
    final invoicePayFineStr =
        invoicePayModels.map((e) => '${e.fine}').join(',');

    final String ptser = (widget.serptPayment ?? '').toString();

    // bankId ให้เป็น string ที่ชัวร์
    final String bankId = (widget.serPayment ?? '').toString();

    final bankItem = _PayMentModels.firstWhere(
      (p) => (p.ser ?? '').toString() == bankId,
      orElse: () => PayMentModel(ser: '-', bname: '-', bno: '-', ptser: '-'),
    );

    final bno = (bankItem.bno ?? '-').toString();
    final bname = (bankItem.bname ?? '-').toString();
    final payimg = (bankItem.img ?? '').toString();

    // กัน total ติดลบ + ปัดทศนิยม 2 ตำแหน่ง
    double totalBill = sum_pvat +
        sum_tran_fine -
        dis_sum_Pakan -
        (sum_disamt + sum_disamt_in) +
        (sum_amt_in + sum_tran_fine_in) +
        fine_total;
    String totalBills = totalBill.toStringAsFixed(2);
    if (totalBill.isNegative) totalBill = 0.0;
    totalBill = double.parse(totalBill.toStringAsFixed(2));

    // ใช้ตัวแปรวันที่ตัวเดียวกัน (ไม่ใช้ datex ที่ไม่ชัวร์)
    final String expiresText = DateFormat('dd-MM-yyyy HH:mm')
        .format(now.add(const Duration(minutes: 15)));

    // สร้าง ref1/ref2/ref3 ก่อน แล้วค่อย setState ทีเดียว
    String ref1 = '';
    String ref2 = '';
    String ref3 = '';

    if (_InvoiceModels.length == 1) {
      ref1 = _InvoiceModels[0].docno.toString().replaceAll('-', '');

      final dt = DateTime.tryParse(_InvoiceModels[0].date.toString()) ?? now;
      ref2 = '${DateFormat('ddMM').format(dt)}${dt.year + 543}';

      ref3 = getRandomString(5);
    } else if (_InvoiceModels.length > 1) {
      final uuid3 = getUuid().substring(0, 3);
      final custno = _InvoiceModels[0].custno.toString().replaceAll('-', '');
      final key = now.millisecondsSinceEpoch.toString();

      final encodedUUID = stringEncryption(uuid3, key);
      final encodedCustno = stringEncryption(custno, key);

      ref1 = encodedCustno + encodedUUID + getRandomString(5);
      ref2 = '${DateFormat('ddMM').format(now)}${now.year + 543}';
      ref3 = getRandomString(5);
    }
    // ใช้ ref1/ref2 ที่เพิ่งสร้าง (อย่าใช้ ref1/ref2 คนละตัวแปร)
    // String? qrData;

    if (!mounted) return;
    setState(() {
      QR_Date15Min = expiresText;

      invoicePay = invoicePayStr;
      invoicePayfine = invoicePayFineStr;

      return_qr_refapi1 = ref1;
      return_qr_refapi2 = ref2;
      return_qr_refapi3 = ref3;
      refpay = '$return_qr_refapi1';
      // refpay = 'GEN$ref1$ref2$ref3';
      refpayup = refpay;

      this.qr_softExpiresAt =
          now.add(const Duration(minutes: 15)).toIso8601String();

      this.payment_tser = ptser;
      this.qr_expiresAt =
          now.add(const Duration(minutes: 15)).toIso8601String();

      this.activeQrSessionSoftExpire =
          now.add(const Duration(minutes: 15)).toIso8601String();
      this.qrDataNoIntens = (ptser == '7')
          ? qr_payload.toString()
          : (ptser == '6')
              ? '|$bno\r$ref1\r$ref2\r${totalBills.replaceAll('.', '')}' // Bill Payment
              : (ptser == '5')
                  ? generateQRCode(
                      promptPayID: bno,
                      amount: double.tryParse(totalBills) ?? 0.0) // PromptPay
                  : (ptser == '2')
                      ? payimg
                      : '';
      _expireDialogShown = false;
    });

    _qrUpdateTrigger.value++;

    debugPrint('💳 Payment Type (ptser): $ptser');
    debugPrint('💳 ref1: $ref1, ref2: $ref2');
    debugPrint('totalBill: $totalBill');
    debugPrint('qr_expiresAt: $qr_expiresAt');
    debugPrint('qr_softExpiresAt: $qr_softExpiresAt');
    debugPrint('qrData: ${qrDataNoIntens}');
    debugPrint('_expireDialogShown: ${_expireDialogShown}');
  }

  Future<Map<String, dynamic>> GC_Inv_fine({required String docno}) async {
    final preferences = await SharedPreferences.getInstance();
    final ren = preferences.getString('renTalSer') ?? '';

    final uri =
        Uri.parse('${MyConstant().domain_chao}/GC_selectFine_inv.php').replace(
      queryParameters: {
        'isAdd': 'true',
        'ren': ren,
        'tdocno': docno,
      },
    );
    print(uri);
    try {
      final response = await httpClient.get(uri);
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return {
          'ok': true,
          'expname': decoded['expname'],
          'expser': decoded['expser'],
          'no': decoded['no'],
          'pvat': (decoded['pvat'] as num?)?.toDouble() ?? 0.0,
          'vser': (decoded['vser'] as num?)?.toDouble() ?? 0.0,
          'vtype': decoded['vtype'],
          'nvat': (decoded['nvat'] as num?)?.toInt() ?? 0,
          'vat': (decoded['vat'] as num?)?.toDouble() ?? 0.0,
          'total': (decoded['total'] as num?)?.toDouble() ?? 0.0,
          'wht': (decoded['wht'] as num?)?.toDouble() ?? 0.0,
          'docno': decoded['docno'] ?? docno,
        };
      }

      return {'ok': false, 'error': 'Unexpected response type'};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  Future<Null> red_Trans_select(index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = preferences.getString('usercid');
    var qutser = 1;
    var docnoin = _InvoiceModels[index].docno;
    // //print('docnoin>> $docnoin');
    Map<String, dynamic> queryParams = {
      'isAdd': 'true',
      'ren': ren,
      'user': user,
      'ciddoc': ciddoc,
      'docnoin': docnoin,
    };

    var uri =
        Uri.parse('${MyConstant().domain_chao}/GC_bill_invoice_history.php')
            .replace(queryParameters: queryParams);
    print('uri: $uri');
    try {
      var response = await http.get(uri);

      var result = json.decode(response.body);

      if (result.toString() != 'null') {
        for (var map in result) {
          IntentsInvoiceHistoryModel _InvoiceHistoryModel =
              IntentsInvoiceHistoryModel.fromJson(map);
          var sum_pvatx = double.parse(_InvoiceHistoryModel.amt!);
          var sum_vatx = double.parse(_InvoiceHistoryModel.vat!);
          var sum_whtx = double.parse(_InvoiceHistoryModel.wht!);
          var sum_amtx = double.parse(_InvoiceHistoryModel.total_t!);
          var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          setState(() {
            sum_pvat_in = sum_pvat_in + sum_pvatx;
            sum_vat_in = sum_vat_in + sum_vatx;
            sum_wht_in = sum_wht_in + sum_whtx;
            sum_amt_in = sum_amt_in + sum_amtx;
            sum_disamt = sum_disamtx;
            _InvoiceHistoryModels.add(_InvoiceHistoryModel);
          });
        }
      }

      setState(() {
        Form_payment1.text = (sum_pvat +
                sum_tran_fine -
                dis_sum_Pakan -
                (sum_disamt + sum_disamt_in) +
                (sum_amt_in + sum_tran_fine_in) +
                (fine_total))
            .toStringAsFixed(2)
            .toString();
      });
    } catch (e) {}
  }

  Future<Null> in_Trans_fine_re() async {
    if (invoicePayModels.isNotEmpty) {
      setState(() {
        invoicePayModels.clear();
      });
    }
    print('in_Trans_fine_re : ==================> in_Trans_fine_re');
    List<Future<void>> futures =
        List.generate(_InvoiceModels.length, (index) async {
      print('futures InvoiceModels : ${_InvoiceModels[index].docno}');
      if (contractxFineModels.isNotEmpty) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        var ren = preferences.getString('renTalSer');
        var user = preferences.getString('ser');
        var ciddoc = preferences.getString('usercid');
        var qutser = '1';
        var tser = _InvoiceModels[index].ser;
        var tdocno = _InvoiceModels[index].docno;

        Map<String, dynamic> queryParams = {
          'isAdd': 'true',
          'ren': ren,
          'ciddoc': ciddoc,
          'qutser': qutser,
          'tser': tser,
          'tdocno': tdocno,
          'user': user,
        };

        var uri =
            Uri.parse('${MyConstant().domain_chao}/In_tran_select_fine_inv.php')
                .replace(queryParameters: queryParams);

        print('ชำระเกินกำหนด ${uri}');
        print('In_tran_select_fine_inv : $queryParams');
        try {
          var response = await http.get(uri);
          var result = json.decode(response.body);
          var resultStr = result.toString();
          var fine_inv = resultStr.indexOf(',');
          var sum_totalx = 0.0;

          if (fine_inv != -1) {
            var fine_Name = resultStr.substring(0, fine_inv);
            var fine_pri = resultStr.substring(fine_inv + 1);
            sum_totalx = fine_pri == '' ? 0 : double.parse(fine_pri);
          }
          // sum_tran_fine = 0;
          var in_docnox = _InvoiceModels[index].docno;
          var in_ser = _InvoiceModels[index].ser;
          var in_amtall = _InvoiceModels[index].amtall;
          var in_fine = sum_totalx.toString();
          var disendbill = _InvoiceModels[index].disendbill.toString();
          Map<String, dynamic> mapi = Map();
          mapi['ser'] = in_ser;
          mapi['docno'] = in_docnox;
          mapi['amtall'] = in_amtall;
          mapi['fine'] = in_fine;
          mapi['discount'] = disendbill;
          mapi['fine_book'] = in_fine;
          mapi['discount_book'] = disendbill;

          InvoicePayModel invoicePayModel = InvoicePayModel.fromJson(mapi);

          if (mounted) {
            setState(() {
              invoicePayModels.add(invoicePayModel);
              // sum_tran_fine_in = sum_tran_fine_in + sum_totalx;
              sum_tran_fine_in = sum_tran_fine_in + sum_totalx;
            });
          }

          // print('ชำระเกินกำหนดser ${invoicePayModels.map((e) => e.ser)}');
        } catch (e) {}
      } else {
        Map<String, dynamic> mapi = Map();
        mapi['ser'] = _InvoiceModels[index].ser;
        mapi['docno'] = _InvoiceModels[index].docno;
        mapi['amtall'] = _InvoiceModels[index].amtall;
        mapi['fine'] = '0';
        mapi['discount'] = _InvoiceModels[index].disendbill;
        mapi['fine_book'] = '0';
        mapi['discount_book'] = _InvoiceModels[index].disendbill;
        InvoicePayModel invoicePayModel = InvoicePayModel.fromJson(mapi);
        print('ชำระInvoiceModels : ${_InvoiceModels[index].docno}');
        if (mounted) {
          setState(() {
            invoicePayModels.add(invoicePayModel);
          });
        }
      }
    });

    await Future.wait(futures);
    // Populate the fallback source string from the freshly loaded models
    String newPayFine = '';
    for (var m in invoicePayModels) {
      newPayFine += '${m.fine_book ?? '0'},';
    }
    setState(() {
      invoicePayfine = newPayFine;
    });
    setState(() {
      Form_payment1.text = (double.parse(Form_payment1.text) + sum_tran_fine_in)
          .toStringAsFixed(2)
          .toString();
    });
  }

  Future<Null> in_Trans_fine(index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = preferences.getString('usercid');
    var qutser = 1;

    var tser = _TransBillModels[index].ser;
    var tdocno = _TransBillModels[index].docno;

    // //print('object $tdocno');
    Map<String, dynamic> queryParams = {
      'isAdd': 'true',
      'ren': ren,
      'ciddoc': ciddoc,
      'qutser': qutser.toString(),
      'tser': tser,
      'tdocno': tdocno,
      'user': user,
      'pos': '1',
    };

    var uri = Uri.parse('${MyConstant().domain_chao}/In_tran_select_fine.php')
        .replace(queryParameters: queryParams);
    try {
      var response = await http.get(uri);

      var result = json.decode(response.body);
      // //print('rr>>>>>> $result');
      if (result.toString() == 'true') {
        // setState(() {
        //   red_Trans_select2();
        // });
        //print('rrrrrrrrrrrrrr');
      } else if (result.toString() == 'false') {
        //  setState(() {
        //   red_Trans_select2();
        // });
        //print('rrrrrrrrrrrrrrfalse');
      } else {}
    } catch (e) {}
    // setState(() {
    //   red_Trans_select2_fin();
    // });
  }

  Future<Null> read_GC_fine() async {
    setState(() {
      contractxFineModels.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    // var zone = preferences.getString('zoneSer');
    if (widget.teNantModel == null) {
      var ciddoc = preferences.getString('usercid');
      var qutser = '1';

      Map<String, dynamic> queryParams = {
        'isAdd': 'true',
        'ren': ren,
        'ciddoc': ciddoc,
        'qutser': qutser,
      };

      var uri = Uri.parse('${MyConstant().domain_chao}/GC_fine.php')
          .replace(queryParameters: queryParams);
      print('null >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--------------  $uri');
      try {
        var response = await http.get(uri);

        var result = json.decode(response.body);
        // //print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--------------  $result');

        if (result.toString() != 'true') {
          for (var map in result) {
            IntentsContractxFineModel contractxFineModel =
                IntentsContractxFineModel.fromJson(map);

            setState(() {
              contractxFineModels.add(contractxFineModel);
            });
          }
        }
      } catch (e) {}

      // //print('contractxFineModels>>> ${contractxFineModels.length}');
    } else {
      List<Future<void>> futures = widget.teNantModel!.map((e) async {
        var ciddoc = e.cid;
        var qutser = '1';
        Map<String, dynamic> queryParams = {
          'isAdd': 'true',
          'ren': ren,
          'ciddoc': ciddoc,
          'qutser': qutser,
        };

        var uri = Uri.parse('${MyConstant().domain_chao}/GC_fine.php')
            .replace(queryParameters: queryParams);
        print('!null >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--------------  $uri');
        try {
          var response = await http.get(uri);

          var result = json.decode(response.body);
          // //print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--------------  $result');

          if (result.toString() != 'true') {
            for (var map in result) {
              IntentsContractxFineModel contractxFineModel =
                  IntentsContractxFineModel.fromJson(map);

              if (mounted) {
                setState(() {
                  contractxFineModels.add(contractxFineModel);
                });
              }
            }
          }
        } catch (e) {}
      }).toList();

      await Future.wait(futures);
    }
    //print('contractxFineModels>>> ${contractxFineModels.length}');
  }

  Future<Null> red_Invoice() async {
    // Reset state initially
    setState(() {
      _InvoiceModels.clear();
      _InvoiceInIntent.clear();
      sum_disamt_in = 0;
      in_amt = 0;
      sum_pvat_in = 0;
      sum_vat_in = 0;
      sum_wht_in = 0;
      sum_amt_in = 0;
      sum_tran_fine_in = 0;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var qutser_ = preferences.getString('qutser');

    // Local accumulators
    List<InvoiceModel> tempInvoiceModels = [];
    List<InvoiceModel> tempInvoiceInIntent = [];
    double tempSumDis = 0;
    double tempInAmt = 0;

    Future<void> processResult(dynamic result) async {
      if (result != null && result.toString() != 'null') {
        for (var map in result) {
          InvoiceModel _InvoiceModel = InvoiceModel.fromJson(map);
          final targetUuid = (_InvoiceModel.docno ?? '').trim();

          final intents = paymentIntents
              .where((p) => p.invoices
                  .any((b) => (b.billReference ?? '').trim() == targetUuid))
              .toList();

          if (_InvoiceModel.payser.toString() == '${widget.serPayment}') {
            // ✅ Only proceed if the bill is in the selected list (if provided)
            if (widget.selectedDocNos != null &&
                !widget.selectedDocNos!.contains(targetUuid)) {
              continue;
            }

            if (intents.isEmpty) {
              // Not currently in any active intent -> Available to pay
              print('NO MATCH target=$targetUuid');
              var in_amtx = double.parse(_InvoiceModel.amtall!);
              var disendbill = double.parse(_InvoiceModel.disendbill!);

              tempSumDis += disendbill;
              tempInAmt += in_amtx;
              tempInvoiceModels.add(_InvoiceModel);
            } else {
              // Already in an intent
              print(
                  'MATCH target=$targetUuid -> intentNos=${intents.map((e) => e.bankmerchantid).toList()}');
              tempInvoiceInIntent.add(_InvoiceModel);
            }
          }
        }
      }
    }

    if (widget.teNantModel == null) {
      ////////////////------------------------------------------------------>
      var ciddoc_ = preferences.getString('usercid');
      ////////////////------------------------------------------------------>
      Map<String, dynamic> queryParams = {
        'isAdd': 'true',
        'ren': ren,
        'ciddoc': ciddoc_,
        'qutser': qutser_,
      };

      var uri = Uri.parse('${MyConstant().domain_chao}/GC_bill_invoice.php')
          .replace(queryParameters: queryParams);
      try {
        var response = await http.get(uri);
        var result = json.decode(response.body);
        await processResult(result);
      } catch (e) {}
    } else {
      ////////////////------------------------------------------------------>
      List<Future<void>> futures = widget.teNantModel!.map((e) async {
        var ciddoc_ = e.cid;
        Map<String, dynamic> queryParams = {
          'isAdd': 'true',
          'ren': ren,
          'ciddoc': ciddoc_,
          'qutser': qutser_,
        };

        var uri = Uri.parse('${MyConstant().domain_chao}/GC_bill_invoice.php')
            .replace(queryParameters: queryParams);
        print(uri);
        try {
          var response = await http.get(uri);
          var result = json.decode(response.body);
          await processResult(result);
        } catch (e) {}
      }).toList();

      await Future.wait(futures);
    }

    // Single setState update at the end
    if (mounted) {
      setState(() {
        _InvoiceModels.addAll(tempInvoiceModels);
        _InvoiceInIntent.addAll(tempInvoiceInIntent);
        sum_disamt_in += tempSumDis;
        in_amt += tempInAmt;
      });
    }
  }

  Future<Null> read_data() async {
    if (teNantModels.length != 0) {
      setState(() {
        teNantModels.clear();
      });
    }
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc_ = preferences.getString('usercid');
    var qutser_ = preferences.getString('qutser');
    ////////////////------------------------------------------------------>

    String url =
        '${MyConstant().domain}/GC_tenantlookAS.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          setState(() {
            teNantModels.add(teNantModel);

            Form_nameshop = teNantModel.sname.toString();
            Form_typeshop = teNantModel.stype.toString();
            Form_bussshop = teNantModel.cname.toString();
            Form_bussscontact = teNantModel.attn.toString();
            Form_address = teNantModel.addr.toString();
            Form_tel = teNantModel.tel.toString();
            Form_email = teNantModel.email.toString();
            Form_tax =
                teNantModel.tax == null ? "-" : teNantModel.tax.toString();
            Form_area = teNantModel.area.toString();
            Form_ln = teNantModel.area_c.toString();

            Form_sdate = DateFormat('dd-MM-yyyy')
                .format(DateTime.parse('${teNantModel.sdate} 00:00:00'))
                .toString();
            Form_ldate = DateFormat('dd-MM-yyyy')
                .format(DateTime.parse('${teNantModel.ldate} 00:00:00'))
                .toString();
            Form_period = teNantModel.period.toString();
            Form_rtname = teNantModel.rtname.toString();
            Form_docno = teNantModel.docno.toString();
            Form_zn = teNantModel.zn.toString();
            Form_aser = teNantModel.aser.toString();
            Form_qty = teNantModel.qty.toString();
            Form_qty = teNantModel.qty.toString();
          });
        }
      }
    } catch (e) {}
  }

  Future<Null> checkPreferance() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ciddoc_ = preferences.getString('usercid');
    var qutser_ = preferences.getString('qutser');
    var custno = preferences.getString('custno');
    var Message_ = preferences.getString('Message_ToUser');
    var ren = preferences.getString('renTalSer');
    setState(() {
      if (widget.teNantModel == null) {
        cid_doc = ciddoc_;
        cid_docqr = ciddoc_;
      } else {
        cid_doc = custno;
        cid_docqr = widget.teNantModel![0].cid;
      }
      cid_ren = ren;
    });
  }

  String randomString = '';
  generateRandomString() {
    final random = Random();
    const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final length = 4; // Change this to the desired length

    for (int i = 0; i < length; i++) {
      final index = random.nextInt(characters.length);
      randomString += characters[index];
    }

    // return randomString;
  }

  Future<void> red_payMent() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final ren = preferences.getString('renTalSer');

    if (ren == null || ren.isEmpty) return;

    final url =
        '${MyConstant().domain_chao}/GC_payMent.php?isAdd=true&ren=$ren';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 500) return;

      final result = json.decode(response.body);
      if (result == null || result.toString() == 'null') return;

      final targetSer = '${widget.serPayment}';

      // แปลง json -> model
      final all = <PayMentModel>[];
      for (final map in result) {
        all.add(PayMentModel.fromJson(map));
      }

      // หา payment ที่ตรง ser
      final matched = all.where((p) => p.ser.toString() == targetSer).toList();

      if (matched.isEmpty) {
        if (!mounted) return;
        setState(() => _PayMentModels = []);
        return;
      }

      // ถ้ามีตัวที่เปิด payweb=1 ให้ใช้
      final opened =
          matched.where((p) => p.ser_payweb.toString() == '1').toList();

      if (!mounted) return;

      if (opened.isNotEmpty) {
        setState(() {
          _PayMentModels
            ..clear()
            ..addAll(opened);
        });
      } else {
        // เคลียร์ก่อนเพื่อกันข้อมูลเก่าค้าง
        setState(() => _PayMentModels.clear());

        PanaraInfoDialog.showAnimatedGrow(
          context,
          title: widget.cuslang == 'EN' ? "Sorry" : "ขออภัย",
          message: widget.cuslang == 'EN'
              ? "The payment is not available at this time. Please contact the system administrator."
              : "ไม่สามารถชำระเงินได้ขณะนี้ระบบปิดการชำระเงินชั่วคราว กรุณาติดต่อฝ่ายบริการลูกค้า",
          buttonText: widget.cuslang == 'EN' ? "Acknowledge" : "รับทราบ",
          onTapDismiss: () async {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
              return FitnessAppHomeScreen(custno_s: custno);
            }), (route) => false);
          },
          panaraDialogType: PanaraDialogType.warning,
          barrierDismissible: false,
        );
      }
    } catch (e) {
      // อย่างน้อย log ไว้ตอน dev
      debugPrint('red_payMent error: $e');
    }
  }

  Future<Null> read_GC_rental() async {
    if (renTalModels.isNotEmpty) {
      renTalModels.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    //https://dzentric.com/chao_perty/chao_api/GC_rental_setring.php?isAdd=true&ren=50
    String url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
    //renTal_name = preferences.getString('renTalName');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        for (var map in result) {
          RenTalModel renTalModel = RenTalModel.fromJson(map);
          var rtnamex = renTalModel.rtname!.trim();
          var typexs = renTalModel.type!.trim();
          var typexx = renTalModel.typex!.trim();
          var bill_namex = renTalModel.bill_name!.trim();
          var bill_addrx = renTalModel.bill_addr!.trim();
          var bill_taxx = renTalModel.bill_tax!.trim();
          var bill_telx = renTalModel.bill_tel!.trim();
          var bill_emailx = renTalModel.bill_email!.trim();
          var bill_defaultx = renTalModel.bill_default;
          var bill_tserx = renTalModel.tser;
          var name = renTalModel.pn!.trim();
          var foderx = renTalModel.dbn;
          setState(() {
            foder = foderx;
            rtname = rtnamex;
            type = typexs;
            typex = typexx;
            renname = name;
            bill_name = bill_namex;
            bill_addr = bill_addrx;
            bill_tax = bill_taxx;
            bill_tel = bill_telx;
            bill_email = bill_emailx;
            bill_default = bill_defaultx;
            bill_tser = bill_tserx;
            imglogo_ =
                '${MyConstant().domain}/files/$foder/logo/${renTalModel.imglogo!.trim()}';
            renTalModels.add(renTalModel);
            if (bill_defaultx == 'P') {
              bills_name_ = 'บิลธรรมดา';
            } else {
              bills_name_ = 'ใบกำกับภาษี';
            }
          });
        }
      } else {}
    } catch (e) {}
  }

////////////////////////////////>
  String? base64_Slip, fileName_Slip;
  var extension_;
  var file_;
  Future<void> uploadFile_Slip() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 450,
      maxHeight: 450,
    );

    if (pickedFile == null) {
      return;
    } else {
      var imageBytes = await pickedFile.readAsBytes();

      // 3. Encode the image as a base64 string
      final base64Image = base64Encode(imageBytes);
      setState(() {
        base64_Slip = base64Image;
        _uploadedSlipData = imageBytes;
      });
      // //print(base64_Slip);
      setState(() {
        extension_ = 'png';
        // file_ = file;
      });
    }
  }

  String _uniqueSuffix() {
    final us = DateTime.now()
        .toUtc()
        .add(const Duration(hours: 7))
        .microsecondsSinceEpoch;
    final r = Random.secure().nextInt(90000000) + 10000000; // 8 digits
    return '${us}_$r';
  }

  Future<void> OKuploadFile_Slip(newValuePDFimg) async {
    setState(() => extension_ = 'png');

    final preferences = await SharedPreferences.getInstance();
    final ciddoc_ = widget.teNantModel == null
        ? preferences.getString('usercid')
        : preferences.getString('custno');

    final unique = _uniqueSuffix();

    final base = 'slip_${ciddoc_ ?? "NA"}_$unique';
    fileName_Slip = '$base.$extension_';

    final url =
        '${MyConstant().domain_chao}/File_uploadSlip_NewEdit.php?name=$fileName_Slip&Foder=$foder&extension=$extension_';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'image': base64_Slip,
          'Foder': foder,
          'name': fileName_Slip,
          'ex': extension_.toString(),
        },
      );
    } catch (_) {}
  }

  ///----------------------------------------------->
  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      if (value.isEmpty) return 0.0;
      return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    }
    return 0.0;
  }

  String _safeString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  Widget _howToBox() {
    Widget step(int i, String t) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
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
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.cuslang == 'EN' ? 'Payment Procedure' : 'วิธีชำระเงิน',
              style: const TextStyle(
                fontFamily: Font_.Fonts_T,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),

            /// ------------------------------
            /// 1. ตรวจสอบข้อมูล
            /// ------------------------------
            step(
              1,
              widget.cuslang == 'EN'
                  ? 'Please verify that all payment details are correct.'
                  : 'กรุณาตรวจสอบความถูกต้องของข้อมูลการชำระเงิน',
            ),
            step(
              2,
              widget.cuslang == 'EN'
                  ? 'Select “Start Payment” to proceed.'
                  : 'กด “เริ่มการชำระเงิน” เพื่อดำเนินการต่อ',
            ),

            const SizedBox(height: 8),

            /// ------------------------------
            /// 2. ดำเนินการชำระเงินผ่านธนาคาร
            /// ------------------------------
            step(
              3,
              widget.cuslang == 'EN'
                  ? 'Save the PromptPay QR code displayed above to your device.'
                  : 'บันทึกรูป QR พร้อมเพย์ที่แสดงด้านบนลงในอุปกรณ์ของท่าน',
            ),
            step(
              4,
              widget.cuslang == 'EN'
                  ? 'Open your banking application.'
                  : 'เปิดแอปพลิเคชันธนาคารของท่าน',
            ),
            step(
              5,
              widget.cuslang == 'EN'
                  ? 'Select the “Scan” function and choose the saved QR image to complete the payment.'
                  : 'เลือกเมนู “สแกน” และเลือกรูป QR ที่บันทึกไว้เพื่อดำเนินการชำระเงิน',
            ),

            const SizedBox(height: 8),

            /// ------------------------------
            /// 3. ยืนยันการชำระเงิน
            /// ------------------------------
            step(
              6,
              widget.cuslang == 'EN'
                  ? 'Return to this application and upload the payment proof.'
                  : 'กลับมายังแอปพลิเคชันนี้ และแนบหลักฐานการชำระเงิน',
            ),
            step(
              7,
              widget.cuslang == 'EN'
                  ? 'The system will verify your payment within 1–3 business days, depending on the bank.'
                  : 'ระบบจะตรวจสอบการชำระเงินภายใน 1–3 วันทำการ ทั้งนี้ขึ้นอยู่กับธนาคาร',
            ),

            const SizedBox(height: 8),

            /// ------------------------------
            /// 4. หมายเหตุ
            /// ------------------------------
            step(
              8,
              widget.cuslang == 'EN'
                  ? 'Please retain your payment receipt for future reference.'
                  : 'กรุณาเก็บหลักฐานการชำระเงินไว้เพื่อใช้อ้างอิงในภายหลัง',
            ),
            step(
              9,
              widget.cuslang == 'EN'
                  ? 'If you experience any issues, please contact customer service.'
                  : 'หากพบปัญหาในการชำระเงิน กรุณาติดต่อฝ่ายบริการลูกค้า',
            ),
          ],
        ));
  }

  void showIOSSaveOverlay(Uint8List bytes, {required bool isEN}) {
    // remove old overlay if exists
    html.document.getElementById('qr_save_overlay')?.remove();

    final base64 = base64Encode(bytes);
    final dataUrl = 'data:image/png;base64,$base64';

    final overlay = html.DivElement()
      ..id = 'qr_save_overlay'
      ..style.position = 'fixed'
      ..style.left = '0'
      ..style.top = '0'
      ..style.right = '0'
      ..style.bottom = '0'
      ..style.backgroundColor = 'rgba(0,0,0,0.9)'
      ..style.display = 'flex'
      ..style.flexDirection = 'column'
      ..style.alignItems = 'center'
      ..style.justifyContent = 'center'
      ..style.zIndex = '2147483647' // highest
      ..style.pointerEvents = 'auto';

    final img = html.ImageElement()
      ..src = dataUrl
      ..style.maxWidth = '92vw'
      ..style.maxHeight = '72vh'
      ..style.borderRadius = '12px'
      ..style.pointerEvents = 'auto'
      ..style.userSelect = 'none';

    final hint = html.DivElement()
      ..text = isEN ? 'Long-press the image to Save' : 'กดค้างที่รูปเพื่อบันทึก'
      ..style.color = '#fff'
      ..style.fontSize = '16px'
      ..style.marginTop = '14px'
      ..style.textAlign = 'center'
      ..style.padding = '0 16px'
      ..style.fontFamily =
          '-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Arial';

    final closeBtn = html.ButtonElement()
      ..text = isEN ? 'Close' : 'ปิด'
      ..style.marginTop = '14px'
      ..style.padding = '10px 18px'
      ..style.borderRadius = '10px'
      ..style.border = 'none'
      ..style.fontSize = '16px'
      ..style.cursor = 'pointer';

    closeBtn.onClick.listen((_) => overlay.remove());

    // สำคัญ: อย่าใส่ overlay.onClick ปิดทิ้ง (มันจะไปรบกวน long-press)
    // และกันไม่ให้ click บนรูปไป trigger อะไร
    img.onClick.listen((e) => e.stopPropagation());
    img.onContextMenu.listen((e) {
      // ปล่อยให้ iOS แสดงเมนู save เอง (ไม่ preventDefault)
      e.stopPropagation();
    });

    overlay.children.addAll([img, hint, closeBtn]);
    html.document.body?.append(overlay);
  }

  Widget _QRBox({GlobalKey? customKey}) {
    // Determine which key to use: customKey if provided, otherwise the class-level qrBlockKey
    final GlobalKey useKey = customKey ?? qrBlockKey;

    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 480;
    bool isDesktop = width >= 900;
    double qrSize = isDesktop ? 200 : 160;
    final String targetUuid = '$numinvoice';

    // ✅ หา Intent และ Bank Item (re-logic)
    final filteredIntents =
        paymentIntents.where((p) => p.intentUuid == targetUuid).toList();

    // Default values if not found
    String bno = '-';
    String amtRaw = '0.00';
    String ref1 = return_qr_refapi1 ?? '-';
    String ref2 = return_qr_refapi2 ?? '-';
    String ref3 = return_qr_refapi3 ?? '-';
    // String soft_expire_at = qr_softExpiresAt ?? '-'; // Removed unused
    String imgUrl = '';

    if (filteredIntents.isNotEmpty) {
      final firstIntent = filteredIntents.first;
      final bankId = firstIntent.bankmerchantid ?? 0;

      try {
        final bankItem = _PayMentModels.firstWhere(
          (p) => p.ser.toString() == '$bankId',
        );
        bno = bankItem.bno ?? '-';
      } catch (_) {}

      final amtVal = firstIntent.requestedAmount ?? 0.0;
      amtRaw = amtVal.toStringAsFixed(2);
      Form_payment1.text = amtRaw;
    }

    // Use class member for Ref/Payload if set, otherwise defaults
    ref1 = return_qr_refapi1 ?? '-';
    ref2 = return_qr_refapi2 ?? '-';
    ref3 = return_qr_refapi3 ?? '-';
    // qr_payload (class member)

    final ptser = '${widget.serptPayment}'; // ช่องทาง

    // payload สำหรับ QR ตาม ptser
    // debugPrint('💳 Payment Type (ptser): $ptser');
    // debugPrint('💳 ref1: $ref1, ref2: $ref2, ref3: $ref3');
    // debugPrint('💳 Bank No: $bno');
    // debugPrint('💳 Amount Raw: $amtRaw');
    // debugPrint('💳 active QR Soft Expire At: $activeQrSessionSoftExpire');
    // debugPrint('💳 Soft Expire At: $soft_expire_at');
    // debugPrint('💳 qr_payload: $qr_payload');

    final qrData = qrDataNoIntens ?? "";
    // (ptser == '7')
    //     ? (qr_payload ?? '')
    //     : (ptser == '6')
    //         ? '|$bno\r$ref1\r$ref2\r${amtRaw.replaceAll('.', '')}'
    //         : (ptser == '5' || payment_tser == '5' || payment_tser == '6')
    //             ? generateQRCode(
    //                 promptPayID: "$selectedValue",
    //                 amount: double.tryParse(amtRaw) ?? 0.0)
    //             : (ptser == '2')
    //                 ? '${payment_img}'
    //                 : '';

    debugPrint('💳 Generated QR Data==> $qrData');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          Card(
            color: Colors.white,
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // QR Code Area
                RepaintBoundary(
                  key: useKey,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.white,
                    child: Column(
                      children: [
                        if (payment_tser == '2') ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: (_expireDialogShown == true)
                                ? Container(
                                    width: double.infinity,
                                    height: (qrSize + qrSize) - 100,
                                    color: Colors.grey.shade200,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.timer_off,
                                            color: Colors.redAccent, size: 40),
                                        SizedBox(height: 8),
                                        Text(
                                          widget.cuslang == 'EN'
                                              ? 'The has expired.'
                                              : 'หมดอายุแล้ว',
                                          style: TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            color: Colors.black54,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InkWell(
                                            // onTap: _renewQrAndReload,
                                            onTap: () async {
                                              // await CreatePaymentItem();
                                              await QrGenRef();
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: .7),
                                              ),
                                              child: Text(
                                                widget.cuslang == 'EN'
                                                    ? 'Generate another for payment.'
                                                    : 'สร้างการรับชำระอีกครั้ง',
                                                style: TextStyle(
                                                  fontFamily: Font_.Fonts_T,
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : (_isExporting)
                                    ? Container(
                                        width: double.infinity,
                                        height: qrSize + qrSize,
                                        color: Colors.white, // Safe placeholder
                                      )
                                    : (payment_img!.isNotEmpty &&
                                            payment_img != '' &&
                                            payment_img != 'null')
                                        ? Image.network(
                                            payment_img!.isNotEmpty &&
                                                    payment_img != '' &&
                                                    payment_img != 'null'
                                                ? '${MyConstant().domain_chao}/files/$foder/payment/$payment_img'
                                                : '${MyConstant().domain_chao}/Awaitdownload/imagenot.png',
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
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: double.infinity,
                                                height: qrSize + qrSize,
                                                color: Colors.grey.shade200,
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.error_outline,
                                                        color: Colors.redAccent,
                                                        size: 40),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      widget.cuslang == 'EN'
                                                          ? 'Unable to load QR'
                                                          : 'ไม่สามารถโหลด QR ได้',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                        color: Colors.black54,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 100,
                                                height: 100,
                                                child: Icon(
                                                  Icons.account_balance,
                                                  size: 50,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                widget.cuslang == 'EN'
                                                    ? 'Please pay according to the account number below'
                                                    : 'กรุณาชำระเงินตามหมายเลขบัญชีด้านล่าง',
                                                style: TextStyle(
                                                  fontFamily: Font_.Fonts_T,
                                                  color: Colors.blue,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                          ),
                        ] else if (payment_tser == '7' ||
                            payment_tser == '6' ||
                            payment_tser == '5') ...[
                          Image.asset(
                            'images/thai_qr_payment.png',
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: isMobile ? 4 : 4),
                          (_expireDialogShown == true)
                              ? Container(
                                  width: double.infinity,
                                  height: qrSize + qrSize,
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.timer_off,
                                          color: Colors.redAccent, size: 40),
                                      SizedBox(height: 8),
                                      Text(
                                        widget.cuslang == 'EN'
                                            ? 'The QR code has expired.'
                                            : 'QR หมดอายุแล้ว QR ',
                                        style: TextStyle(
                                          fontFamily: Font_.Fonts_T,
                                          color: Colors.black54,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                          // onTap: _renewQrAndReload,
                                          onTap: () async {
                                            await QrGenRef();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.grey,
                                                  width: .7),
                                            ),
                                            child: Text(
                                              widget.cuslang == 'EN'
                                                  ? 'Generate another QR code for payment.'
                                                  : 'สร้าง QR รับชำระอีกครั้ง',
                                              style: TextStyle(
                                                fontFamily: Font_.Fonts_T,
                                                color: Colors.white,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : payment_tser == '6'
                                  ? (_isExporting && _exportQrBytes != null)
                                      ? Image.memory(_exportQrBytes!,
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.contain)
                                      : PrettyQr(
                                          // typeNumber: 3,
                                          image: Image.asset(
                                            'images/icon_thaiqr.png',
                                          ).image,
                                          size: 150,
                                          data: qrData,
                                          errorCorrectLevel:
                                              QrErrorCorrectLevel.M,
                                          roundEdges: true,
                                        )
                                  : (payment_tser == '5' || payment_tser == '6')
                                      ? (_isExporting && _exportQrBytes != null)
                                          ? Image.memory(_exportQrBytes!,
                                              width: 150,
                                              height: 150,
                                              fit: BoxFit.contain)
                                          : PrettyQr(
                                              size: 150,
                                              // size: qrSize,
                                              data: qrData,
                                              image: const AssetImage(
                                                  'images/icon_thaiqr.png'),
                                              errorCorrectLevel:
                                                  QrErrorCorrectLevel.M,
                                              roundEdges: true,
                                            )
                                      : Container(
                                          width: double.infinity,
                                          height: qrSize + qrSize,
                                          color: Colors.grey.shade200,
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.error_outline,
                                                  color: Colors.redAccent,
                                                  size: 40),
                                              SizedBox(height: 8),
                                              Text(
                                                widget.cuslang == 'EN'
                                                    ? 'Unable to load QR'
                                                    : 'ไม่สามารถโหลด QR ได้',
                                                style: TextStyle(
                                                  fontFamily: Font_.Fonts_T,
                                                  color: Colors.black54,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                        ] else ...[
                          Container(
                            width: double.infinity,
                            height: qrSize + qrSize,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.redAccent, size: 40),
                                SizedBox(height: 8),
                                Text(
                                  widget.cuslang == 'EN'
                                      ? 'Unable to load QR'
                                      : 'ไม่สามารถโหลด QR ได้',
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
                        SizedBox(height: isMobile ? 4 : 6),
                        Text(
                          '฿${nFormat.format(double.parse(Form_payment1.text))}',
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
                          '$payment_bname',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontWeight: FontWeight.w700,
                            fontSize: isDesktop ? 16 : 14,
                            color: Colors.black.withOpacity(.65),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$selectedValue',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: Font_.Fonts_T,
                                fontWeight: FontWeight.w700,
                                fontSize: isDesktop ? 16 : 14,
                                color: Colors.black.withOpacity(.65),
                              ),
                            ),
                            InkWell(
                                onTap: () {
                                  Clipboard.setData(new ClipboardData(
                                      text: '$selectedValue'));
                                  Fluttertoast.showToast(
                                      timeInSecForIosWeb: 3,
                                      msg: widget.cuslang == 'EN'
                                          ? 'Copy : $selectedValue'
                                          : 'คัดลอก : $selectedValue',
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      webPosition: "center",
                                      webBgColor: "#000000",
                                      toastLength: Toast.LENGTH_SHORT);
                                },
                                child: Icon(
                                  Icons.content_copy_outlined,
                                  size: 14,
                                )),
                          ],
                        ),
                        Divider(height: 2, color: Colors.grey.shade600),
                        // const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 10,
                              child: Image.asset(
                                'images/Icon-chao.png',
                                width: double.infinity,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              widget.cuslang == 'EN'
                                  ? 'Pay within ${activeQrSessionSoftExpire != null ? DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(activeQrSessionSoftExpire!).toLocal()) : ''}  |  Ref: $ref3'
                                  : 'ชำระภายใน ${activeQrSessionSoftExpire != null ? DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(activeQrSessionSoftExpire!).toLocal()) : ''}  |  Ref: $ref3',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: Font_.Fonts_T,
                                fontWeight: FontWeight.w700,
                                fontSize: isDesktop ? 13 : 11,
                                color: Colors.black.withOpacity(.65),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Divider(),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              RenderRepaintBoundary boundary =
                                  useKey.currentContext!.findRenderObject()
                                      as RenderRepaintBoundary;
                              ui.Image image =
                                  await boundary.toImage(pixelRatio: 3.0);
                              ByteData? byteData = await image.toByteData(
                                  format: ui.ImageByteFormat.png);
                              Uint8List bytes = byteData!.buffer.asUint8List();

                              if (kIsWeb) {
                                // Check if Web Share API is available (works on mobile browsers)
                                if (html.window.navigator.share != null) {
                                  try {
                                    html.Blob blob =
                                        html.Blob([bytes], 'image/png');
                                    html.File file = html.File(
                                        [blob],
                                        'payment_qr.png',
                                        {'type': 'image/png'});

                                    await html.window.navigator.share({
                                      'files': [file],
                                      'title': 'Payment QR Code',
                                    });

                                    Fluttertoast.showToast(
                                        timeInSecForIosWeb: 3,
                                        msg: widget.cuslang == 'EN'
                                            ? "Shared successfully"
                                            : "แชร์สำเร็จ",
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                        webPosition: "center",
                                        webBgColor: "#000000",
                                        toastLength: Toast.LENGTH_SHORT);
                                  } catch (e) {
                                    print('Web Share error: $e');
                                    Fluttertoast.showToast(
                                        timeInSecForIosWeb: 3,
                                        msg: widget.cuslang == 'EN'
                                            ? "Share cancelled or not supported"
                                            : "ยกเลิกการแชร์หรือไม่รองรับ",
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                        webPosition: "center",
                                        webBgColor: "#000000",
                                        toastLength: Toast.LENGTH_SHORT);
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      timeInSecForIosWeb: 3,
                                      msg: widget.cuslang == 'EN'
                                          ? "Share not supported on this browser"
                                          : "เบราว์เซอร์นี้ไม่รองรับการแชร์",
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      webPosition: "center",
                                      webBgColor: "#000000",
                                      toastLength: Toast.LENGTH_SHORT);
                                }
                              } else {
                                final directory = await getTemporaryDirectory();
                                final file =
                                    File('${directory.path}/payment_qr.png');
                                await file.writeAsBytes(bytes);
                                await Share.shareXFiles([XFile(file.path)],
                                    text: 'Payment QR Code');
                              }
                            } catch (e) {
                              print(e);
                              Fluttertoast.showToast(
                                  timeInSecForIosWeb: 3,
                                  msg: "Failed to share",
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  webPosition: "center",
                                  webBgColor: "#000000",
                                  toastLength: Toast.LENGTH_SHORT);
                            }
                          },
                          icon: Icon(Icons.share, color: Colors.black),
                          label: Text(
                              widget.cuslang == 'EN'
                                  ? 'Share QR'
                                  : 'แบ่งปัน QR',
                              style: TextStyle(color: Colors.black)),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            // Save Logic
                            try {
                              // Special handling for payment_tser == '2' (network image QR)
                              // Avoid toImage() issues on iOS Safari by using direct URL
                              if (kIsWeb &&
                                  payment_tser == '2' &&
                                  payment_img != null &&
                                  payment_img!.isNotEmpty &&
                                  payment_img != 'null') {
                                final imgUrl =
                                    '${MyConstant().domain_chao}/files/$foder/payment/$payment_img';

                                String userAgent = html
                                    .window.navigator.userAgent
                                    .toLowerCase();
                                bool isIOS = userAgent.contains('iphone') ||
                                    userAgent.contains('ipad') ||
                                    userAgent.contains('ipod');

                                if (isIOS) {
                                  // iOS: Show overlay with network image
                                  final overlay = html.DivElement()
                                    ..style.position = 'fixed'
                                    ..style.left = '0'
                                    ..style.top = '0'
                                    ..style.right = '0'
                                    ..style.bottom = '0'
                                    ..style.backgroundColor = 'rgba(0,0,0,0.85)'
                                    ..style.display = 'flex'
                                    ..style.flexDirection = 'column'
                                    ..style.alignItems = 'center'
                                    ..style.justifyContent = 'center'
                                    ..style.zIndex = '999999';

                                  final img = html.ImageElement()
                                    ..src = imgUrl
                                    ..style.maxWidth = '95vw'
                                    ..style.maxHeight = '75vh'
                                    ..style.borderRadius = '12px';

                                  final hint = html.DivElement()
                                    ..text = widget.cuslang == 'EN'
                                        ? 'Long-press the image to Save'
                                        : 'กดค้างที่รูปเพื่อบันทึก'
                                    ..style.color = '#fff'
                                    ..style.fontSize = '16px'
                                    ..style.marginTop = '16px'
                                    ..style.textAlign = 'center';

                                  final closeBtn = html.ButtonElement()
                                    ..text =
                                        widget.cuslang == 'EN' ? 'Close' : 'ปิด'
                                    ..style.marginTop = '14px'
                                    ..style.padding = '10px 16px'
                                    ..style.borderRadius = '10px'
                                    ..style.border = 'none';

                                  closeBtn.onClick
                                      .listen((_) => overlay.remove());
                                  // Don't add overlay.onClick - it interferes with long-press
                                  img.onClick
                                      .listen((e) => e.stopPropagation());

                                  overlay.children
                                      .addAll([img, hint, closeBtn]);
                                  html.document.body?.append(overlay);
                                } else {
                                  // Desktop/Android: Open in new tab
                                  html.window.open(imgUrl, '_blank');
                                  Fluttertoast.showToast(
                                      msg: widget.cuslang == 'EN'
                                          ? "Opening QR image"
                                          : "เปิดรูป QR",
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      webPosition: "center",
                                      webBgColor: "#000000",
                                      toastLength: Toast.LENGTH_SHORT);
                                }
                                return;
                              }

                              // Special handling for PrettyQR (payment_tser '5' and '6')
                              // Generate PNG directly from QR data (avoid toImage() issues on iOS Safari)
                              if (kIsWeb &&
                                  (payment_tser == '5' ||
                                      payment_tser == '6')) {
                                final ua = html.window.navigator.userAgent
                                    .toLowerCase();
                                final isIOS = ua.contains('iphone') ||
                                    ua.contains('ipad') ||
                                    ua.contains('ipod');

                                // FINAL SAFE MODE: Direct CPU Generation (No Text)
                                // Avoids all Capture/Canvas issues on iOS Web.
                                try {
                                  // Gen QR Data
                                  final qrData = (payment_tser == '6')
                                      ? '|$selectedValue\r$QR_Ref1\r$QR_Ref2\r${Form_payment1.text.replaceAll('.', '')}\r'
                                      : generateQRCode(
                                          promptPayID: "$selectedValue",
                                          amount: double.parse(
                                              Form_payment1.text.isEmpty
                                                  ? "0"
                                                  : Form_payment1.text));

                                  // // Prepare footer content
                                  final bank = _PayMentModels.isNotEmpty
                                      ? (_PayMentModels[0].bank ?? '')
                                      : '';
                                  final bankInfo = bankCodeMap[bank];

                                  final bankCode = bankInfo?['code'];

                                  final cpuQrBytes =
                                      await buildQrPngWithCenterLogo(
                                    data: qrData,
                                    assetLogoPath: 'images/icon_thaiqr.png',
                                    sizePx: 400,
                                    bottomText:
                                        '฿${nFormat.format(double.parse(Form_payment1.text ?? '0'))}',
                                    bottomname: '$bankCode',
                                    bottombankno: '$selectedValue',
                                    bottomRef: '$QR_Ref1',
                                    activeQrExpire:
                                        '${activeQrSessionSoftExpire != null ? DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(activeQrSessionSoftExpire!).toLocal()) : ''}',
                                  );

                                  // Save
                                  if (isIOS) {
                                    showIOSSaveOverlay(cpuQrBytes,
                                        isEN: widget.cuslang == 'EN');
                                  } else {
                                    final blob =
                                        html.Blob([cpuQrBytes], 'image/png');
                                    final url =
                                        html.Url.createObjectUrlFromBlob(blob);
                                    final a = html.AnchorElement(href: url)
                                      ..download = "payment_qr.png";
                                    html.document.body?.append(a);
                                    a.click();
                                    a.remove();
                                    html.Url.revokeObjectUrl(url);
                                  }

                                  // Notify User
                                  if (isIOS) {
                                    Fluttertoast.showToast(
                                        msg: widget.cuslang == 'EN'
                                            ? "Saved (Text not supported on iOS Web)"
                                            : "บันทึกแล้ว (ไม่รองรับข้อความบน iOS Web)",
                                        toastLength: Toast.LENGTH_LONG);
                                  }
                                } catch (e) {
                                  debugPrint("CPU SAVE FAIL: $e");
                                  Fluttertoast.showToast(msg: "Save Error: $e");
                                } finally {
                                  // Cleanup
                                  if (mounted) {
                                    setState(() {
                                      _isExporting = false;
                                      _exportQrBytes = null;
                                    });
                                  }
                                }
                                return;
                              }

                              // Fallback: For other cases, use screenshot with iOS-safe approach
                              // Wait for frames to ensure fully rendered (critical for iOS Safari)
                              await Future.delayed(
                                  const Duration(milliseconds: 120));
                              await WidgetsBinding.instance.endOfFrame;
                              await Future.delayed(
                                  const Duration(milliseconds: 50));

                              RenderRepaintBoundary boundary =
                                  qrBlockKey.currentContext!.findRenderObject()
                                      as RenderRepaintBoundary;

                              // Use pixelRatio 2.0 on iOS to reduce memory usage and avoid crashes
                              double pixelRatio = 3.0;
                              if (kIsWeb) {
                                String ua = html.window.navigator.userAgent
                                    .toLowerCase();
                                bool isiOS = ua.contains('iphone') ||
                                    ua.contains('ipad') ||
                                    ua.contains('ipod');
                                if (isiOS) {
                                  pixelRatio = 2.0;
                                }
                              }

                              ui.Image image = await boundary.toImage(
                                  pixelRatio: pixelRatio);
                              ByteData? byteData = await image.toByteData(
                                  format: ui.ImageByteFormat.png);

                              // Critical null check for iOS Safari
                              if (byteData == null) {
                                throw Exception(
                                    'Failed to convert QR to image (byteData is null)');
                              }

                              Uint8List bytes = byteData.buffer.asUint8List();

                              if (kIsWeb) {
                                // Detect platform from user agent
                                String userAgent = html
                                    .window.navigator.userAgent
                                    .toLowerCase();
                                bool isIOS = userAgent.contains('iphone') ||
                                    userAgent.contains('ipad') ||
                                    userAgent.contains('ipod');
                                bool isMobileWeb = isIOS ||
                                    userAgent.contains('android') ||
                                    userAgent.contains('mobile');

                                // iOS: Use overlay to avoid popup blocker
                                if (isIOS) {
                                  showIOSSaveOverlay(bytes,
                                      isEN: widget.cuslang == 'EN');
                                  return;
                                }

                                // Android/Other Mobile: Use data URL (same as iOS for consistent behavior)
                                if (isMobileWeb) {
                                  String base64 = base64Encode(bytes);
                                  String dataUrl =
                                      'data:image/png;base64,$base64';
                                  html.window.open(dataUrl, '_blank');
                                  Fluttertoast.showToast(
                                      timeInSecForIosWeb: 5,
                                      msg: widget.cuslang == 'EN'
                                          ? "Long press image to save"
                                          : "กดค้างที่รูปเพื่อบันทึก",
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      webPosition: "center",
                                      webBgColor: "#000000",
                                      toastLength: Toast.LENGTH_LONG);
                                  return;
                                }

                                // Desktop web: Direct download using blob URL with download attribute
                                html.Blob blob =
                                    html.Blob([bytes], 'image/png');
                                String url =
                                    html.Url.createObjectUrlFromBlob(blob);
                                html.AnchorElement(href: url)
                                  ..setAttribute("download", "payment_qr.png")
                                  ..click();
                                html.Url.revokeObjectUrl(url);
                                Fluttertoast.showToast(
                                    timeInSecForIosWeb: 3,
                                    msg: widget.cuslang == 'EN'
                                        ? "QR Code downloaded"
                                        : "ดาวน์โหลด QR แล้ว",
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                    webPosition: "center",
                                    webBgColor: "#000000",
                                    toastLength: Toast.LENGTH_SHORT);
                                return;
                              } else if (Platform.isWindows) {
                                String? outputFile =
                                    await FlutterFileDialog.saveFile(
                                  params: SaveFileDialogParams(
                                    data: bytes,
                                    fileName: "payment_qr.png",
                                  ),
                                );
                                if (outputFile != null) {
                                  Fluttertoast.showToast(
                                      timeInSecForIosWeb: 3,
                                      msg: widget.cuslang == 'EN'
                                          ? "Saved QR Code"
                                          : "บันทึกเรียบร้อย",
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      webPosition: "center",
                                      webBgColor: "#000000",
                                      toastLength: Toast.LENGTH_SHORT);
                                }
                              } else {
                                var status = await Permission.storage.status;
                                if (!status.isGranted) {
                                  status = await Permission.storage.request();
                                }

                                if (status.isGranted) {
                                  await Gal.putImageBytes(bytes);
                                  // final result =
                                  //     await ImageGallerySaver.saveImage(bytes,
                                  //         name: "payment_qr");
                                  if (true) {
                                    Fluttertoast.showToast(
                                        timeInSecForIosWeb: 3,
                                        msg: widget.cuslang == 'EN'
                                            ? "Saved to Gallery"
                                            : "บันทึกในอัลบั้มแล้ว",
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                        webPosition: "center",
                                        webBgColor: "#000000",
                                        toastLength: Toast.LENGTH_SHORT);
                                  } else {
                                    Fluttertoast.showToast(
                                        timeInSecForIosWeb: 3,
                                        msg: widget.cuslang == 'EN'
                                            ? "Failed to save"
                                            : "บันทึกในอัลบั้มไม่สำเร็จ",
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                        webPosition: "center",
                                        webBgColor: "#000000",
                                        toastLength: Toast.LENGTH_SHORT);
                                  }
                                } else {
                                  // Permission denied
                                  Fluttertoast.showToast(
                                      timeInSecForIosWeb: 3,
                                      msg: widget.cuslang == 'EN'
                                          ? "Permission denied"
                                          : "ไม่ได้รับอนุญาตให้เข้าถึงอัลบั้ม",
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      webPosition: "center",
                                      webBgColor: "#000000",
                                      toastLength: Toast.LENGTH_SHORT);
                                }
                              }
                            } catch (e, st) {
                              debugPrint("SAVE ERROR: $e");
                              debugPrint("$st");

                              if (kIsWeb) {
                                Fluttertoast.showToast(
                                    timeInSecForIosWeb: 4,
                                    msg: widget.cuslang == 'EN'
                                        ? "Failed to generate image (Safari iOS)"
                                        : "สร้างรูปไม่สำเร็จ (Safari iOS)",
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                    webPosition: "center",
                                    webBgColor: "#000000",
                                    toastLength: Toast.LENGTH_SHORT);
                              } else {
                                Fluttertoast.showToast(
                                    timeInSecForIosWeb: 3,
                                    msg: widget.cuslang == 'EN'
                                        ? "Failed to save"
                                        : "บันทึกในอัลบั้มไม่สำเร็จ",
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                    toastLength: Toast.LENGTH_SHORT);
                              }
                            }
                          },
                          icon: Icon(Icons.download, color: Colors.black),
                          label: Text(
                              widget.cuslang == 'EN' ? 'Save QR' : 'บันทึก QR',
                              style: TextStyle(color: Colors.black)),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2),

                // Footer: Trouble Paying?
                // Container(
                //   width: double.infinity,
                //   margin: EdgeInsets.all(8),
                //   decoration: BoxDecoration(
                //     color: Colors.grey.shade100,
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: ListTile(
                //     title: Text(
                //         widget.cuslang == 'EN'
                //             ? "Trouble with payment?"
                //             : "มีปัญหาในการชำระเงินใช่ไหม?",
                //         style: TextStyle(
                //             fontWeight: FontWeight.bold, fontSize: 14)),
                //     trailing: Icon(Icons.chevron_right),
                //     onTap: () {
                //       print("Open slip upload");

                //       Fluttertoast.showToast(msg: "Please upload slip below");
                //     },
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /* Widget _IntentBox() {
    List<PaymentIntent> intens = paymentIntents;
    // final payser = g.payser ?? null;
    // final payptser = g.ptser ?? null;
    // final bank = g.bank ?? '';
    // final bno = g.bno ?? '';
    // final bname = g.bname ?? ''; // Added definition
    // final title =
    //     g.bank ?? (widget.cuslang == 'EN' ? 'Payment method' : 'ช่องทางชำระ');
    // // หารหัสไฟล์โลโก้

    // final bankInfo = bankCodeMap[bank];
    // final logoFile = bankInfo?['logo'];
    // final bankCode = bankInfo?['code'];
    // final bankEn = bankInfo?['en'];
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
                      '${widget.cuslang == "EN" ? "Bill All  : ${g.bill!.length ?? 0} " : "บิลทั้งหมด  : ${g.bill!.length ?? 0} "}',
                      style: const TextStyle(
                          color: Colors.grey,
                          fontFamily: Font_.Fonts_T,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
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
  } */

  Widget _IntentBox() {
    String _fmtExpireLocal(String? isoUtc) {
      final d =
          (isoUtc == null || isoUtc.isEmpty) ? null : DateTime.tryParse(isoUtc);
      if (d == null) return '-';
      return DateFormat('d-MM-yyyy HH:mm').format(d.toLocal());
    }

    // Helper helper for chip
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

    // Helper _invoiceItem (duplicate for local scope)
    Widget _invoiceItem({
      required int index,
      required String docNo,
      required double amount,
      required String date,
      required bool isSelected,
      required double lateFee,
      required VoidCallback onTap,
      double fine = 0,
      bool showCheckbox = true,
    }) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12, width: .4),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showCheckbox)
                      SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Icon(
                            isSelected
                                ? Icons.check_circle_outline
                                : Icons.highlight_off_outlined,
                            color: isSelected ? Colors.green : Colors.grey,
                            size: 18,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        docNo,
                        style: const TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      '${nFormat.format(amount)}',
                      style: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.calendar_today,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontSize: 12,
                          color: Colors.grey),
                    ),
                    if (lateFee > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Text(
                          '${widget.cuslang == 'EN' ? 'Fine' : 'ค่าปรับsdsdsdsd'}: ${nFormat.format(lateFee)}',
                          style: TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                      )
                    ],
                  ])
                ]
              ],
            ),
          ),
        ),
      );
    }

    // Filter logic if needed, currently showing all
    if (paymentIntents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: paymentIntents.map((intent) {
        // 1. Find matching PaymentModel for bank info
        PayMentModel? paymentModel;
        try {
          if (_PayMentModels.isNotEmpty) {
            paymentModel = _PayMentModels.firstWhere(
              (m) => m.ser.toString() == intent.bankmerchantid.toString(),
              orElse: () => _PayMentModels.first,
            );
          }
        } catch (_) {}

        final bankName = paymentModel?.bname ??
            (widget.cuslang == 'EN' ? 'Payment method' : 'ช่องทางชำระ');
        final bankCode = paymentModel?.bank ?? '';
        final logoFile = paymentModel?.img;
        final bno = paymentModel?.bno ?? '';

        // 2. Calculate Total Bill Count
        final billCount = intent.invoices.length;

        // Fix: Use 'amount' instead of 'total'. If 'amount' is null, use 0.
        // Also cast if necessary (though PaymentIntent should be typed).
        // ignore: unnecessary_cast
        final double totalAmount = (intent as dynamic).amount ?? 0.0;
        final String? paymentIntentNo = intent.paymentIntentNo ?? "-";
        final String? paymentIntentUuid = intent.intentUuid ?? "-";
        final String? statusIntentUuid = intent.status ?? "-";
        final String? systemStatusIntentUuid = intent.systemStatus ?? "-";

        final String? softExpireAt =
            intent.softExpireAt?.toIso8601String() ?? "-";

        final String? createdAt = intent.createdAt?.toIso8601String() ?? "-";

        return Card(
          elevation: 0.4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: false,
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              childrenPadding:
                  const EdgeInsets.only(left: 6, right: 6, bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.receipt_long, size: 20, color: Colors.grey),
                    //  logoFile != null && logoFile.isNotEmpty
                    //     ? Image.asset(
                    //         'assets/images/LogoBank/$logoFile',
                    //         height: 26,
                    //         errorBuilder: (_, __, ___) => const Icon(
                    //             Icons.account_balance,
                    //             size: 20,
                    //             color: Colors.grey),
                    //       )
                    //     : const Icon(Icons.account_balance,
                    //         size: 20, color: Colors.grey),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'เลขที่แจ้งชำระ: ${paymentIntentNo ?? '-'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontFamily: Font_.Fonts_T,
                              fontWeight: FontWeight.w700,
                              fontSize: 15.5),
                        ),
                        Text(
                          '# ${paymentIntentUuid ?? '-'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontFamily: Font_.Fonts_T, fontSize: 8.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  chip(
                      widget.cuslang == 'EN'
                          ? '${systemStatusIntentUuid}'
                          : '${statusIntentUuid}',
                      Colors.orange.withOpacity(.08),
                      Colors.orange.shade700),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // if (paymentIntentNo != null)
                    //   Row(mainAxisSize: MainAxisSize.min, children: [
                    //     const Icon(Icons.confirmation_number_outlined,
                    //         size: 15, color: Colors.black54),
                    //     const SizedBox(width: 6),
                    //     Text('$paymentIntentNo',
                    //         style: const TextStyle(
                    //             fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                    //   ]),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.money, size: 15, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                          widget.cuslang == 'EN'
                              ? 'Total: ${nFormat.format(totalAmount)}'
                              : 'ยอดสุทธิ: ${nFormat.format(totalAmount)}',
                          style: const TextStyle(
                              fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                    ]),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.calendar_today,
                          size: 15, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                          widget.cuslang == 'EN'
                              ? 'Created At: ${_fmtExpireLocal(createdAt)}'
                              : 'วันที่สร้าง: ${_fmtExpireLocal(createdAt)}',
                          style: const TextStyle(
                              fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                    ]),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.date_range,
                          size: 15, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                          widget.cuslang == 'EN'
                              ? 'Expire At: ${_fmtExpireLocal(softExpireAt)}'
                              : 'หมดอายุ: ${_fmtExpireLocal(softExpireAt)}',
                          style: const TextStyle(
                              fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                    ]),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      // const Spacer(),
                      const Icon(Icons.receipt,
                          size: 15, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                          widget.cuslang == "EN"
                              ? "Bill All : $billCount "
                              : "บิลทั้งหมด : $billCount ",
                          style: const TextStyle(
                              color: Colors.grey,
                              fontFamily: Font_.Fonts_T,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      if (systemStatusIntentUuid.toString() ==
                              'slip_uploaded' ||
                          statusIntentUuid.toString() == 'รอตรวจสอบ') ...[
                        InkWell(
                          child: SizedBox(
                            child: Row(
                              children: [
                                Text(
                                    widget.cuslang == "EN"
                                        ? "payment proof"
                                        : "หลักฐานการชำระ",
                                    style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.green,
                                        fontFamily: Font_.Fonts_T,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700)),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.green,
                                )
                              ],
                            ),
                          ),
                          onTap: () async {
                            setState(() {
                              // intentsAttacheSlipNo = intent.intentUuid;
                              numinvoice = intent.intentUuid;
                              sum_amt = intent.total ?? 0.0;
                            });
                            final ok = await QrGenRef();
                            _showPaymentConfirmationSheet(context);
                          },
                        ),
                      ] else ...[
                        InkWell(
                          child: SizedBox(
                            child: Row(
                              children: [
                                Text(
                                    widget.cuslang == "EN"
                                        ? "Press to pay"
                                        : "กดเพื่อยืนยัน",
                                    style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.green,
                                        fontFamily: Font_.Fonts_T,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700)),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.green,
                                )
                              ],
                            ),
                          ),
                          onTap: () async {
                            setState(() {
                              // intentsAttacheSlipNo = intent.intentUuid;
                              numinvoice = intent.intentUuid;
                              sum_amt = intent.total ?? 0.0;
                            });
                            final ok = await QrGenRef();
                            _showPaymentConfirmationSheet(context);
                            // if (paymentModel != null) {
                            //   final index = _PayMentModels.indexOf(paymentModel);
                            //   if (index != -1) {
                            //     _selectPayment(index);
                            //   }
                            // }
                          },
                        ),
                      ]
                    ]),
                  ],
                ),
              ),
              children: [
                const Divider(height: 1),
                const SizedBox(height: 8),
                ...intent.invoices.map((inv) {
                  String dateStr = '';
                  if (inv.metadata.isNotEmpty) {
                    dateStr = inv.metadata.first.date ?? '';
                  }

                  // Use 'total' if available in Invoice, otherwise 'amount'
                  // If 'total' was missing in lint error, maybe use 'amount'.
                  // Checking Model: Invoice has 'total'.
                  final double invAmount =
                      (inv as dynamic).total ?? (inv as dynamic).amount ?? 0.0;

                  return _invoiceItem(
                      index: 0,
                      docNo: inv.billReference ?? '',
                      amount: invAmount,
                      date: dateStr,
                      isSelected: true,
                      lateFee: inv.lateFee ?? 0.0,
                      onTap: () {},
                      showCheckbox: false);
                }).toList(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.cuslang == "EN"
                            ? 'Note: The amount shown does not include any penalties/overdue payments that may occur.'
                            : 'หมายเหตุ:ยอดที่แสดงยังไม่รวมค่าปรับ/ชำระเกินกำหนดที่อาจเกิดขึ้น',
                        style: const TextStyle(
                          color: Colors.red,
                          fontFamily: Font_.Fonts_T,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _groupTile() {
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

    Widget _sectionHeader(String titleEn, String titleTh) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1),
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: Text(
          widget.cuslang == 'EN' ? titleEn : titleTh,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
            fontFamily: Font_.Fonts_T,
          ),
        ),
      );
    }

    final bank =
        _PayMentModels.isNotEmpty ? (_PayMentModels[0].bank ?? '') : '';
    final bno = _PayMentModels.isNotEmpty ? (_PayMentModels[0].bno ?? '') : '';
    final bname =
        _PayMentModels.isNotEmpty ? (_PayMentModels[0].bname ?? '') : '';
    Widget _invoiceItem({
      required int index,
      required String docNo,
      required double amount,
      required String date,
      required bool isSelected,
      required VoidCallback onTap,
      double fine = 0,
      bool showCheckbox = true,
    }) {
      return Container(
        // margin: const EdgeInsets.only(bottom: 12, left: 2, right: 2),
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(12),
        //   border: isSelected
        //       ? Border.all(color: Colors.green.shade500, width: 1.5)
        //       : Border.all(color: Colors.grey.shade200, width: 1),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.grey.withOpacity(0.08),
        //       spreadRadius: 0,
        //       blurRadius: 4,
        //       offset: const Offset(0, 2),
        //     ),
        //   ],
        // ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12, width: .4),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: DocNo + Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Icon(
                          isSelected
                              ? Icons.check_circle_outline
                              : Icons.highlight_off_outlined,
                          color: isSelected ? Colors.green : Colors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        docNo,
                        style: const TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      '${nFormat.format(amount)}',
                      style: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Divider line if desired, or just spacing
                // Bottom Info Row
                Row(
                  children: [
                    // Contract / Ref Logic (Placeholder with Icon)
                    // Row(
                    //   children: [
                    //     Icon(Icons.business,
                    //         size: 14, color: Colors.grey.shade500),
                    //     const SizedBox(width: 4),
                    //     Text(
                    //       '10029-11-2025', // Placeholder for contract ID or dynamic field
                    //       style: TextStyle(
                    //         fontFamily: Font_.Fonts_T,
                    //         fontSize: 12.5,
                    //         color: Colors.grey.shade600,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(width: 12),
                    // Date Logic
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd-MM-yyyy').format(
                              DateTime.tryParse(date) ?? DateTime.now()),
                          style: TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontSize: 12.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Status Tag
                    if (fine > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Text(
                          '${widget.cuslang == 'EN' ? 'Fine' : 'ค่าปรับsdsdsdd'}: ${nFormat.format(fine)}',
                          style: TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1), // Light teal
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.cuslang == 'EN'
                              ? 'Current Contract'
                              : 'สัญญาปัจจุบัน',
                          style: TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade800,
                          ),
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

    final vatBill = sum_vat + sum_vat_in;
    final whtBill = sum_wht + sum_wht_in;
    final totalBill = sum_pvat +
        sum_tran_fine -
        dis_sum_Pakan -
        (sum_disamt + sum_disamt_in) +
        (sum_amt_in + sum_tran_fine_in) +
        (fine_total);

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
          onExpansionChanged: (value) async {
            setState(() {
              invoicePay = invoicePayModels.map((e) => '${e.docno},').join();
              invoicePayfine = invoicePayModels.map((e) => '${e.fine},').join();
            });
            // print(
            //     '<<<${double.parse(Form_payment1.text).toStringAsFixed(2)}<<< ${nFormat.format((sum_pvat + sum_tran_fine) - (sum_disamt + sum_disamt_in) + (sum_amt_in + sum_tran_fine_in))}');
          },
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
                        ? (bankEn ?? bank) + ' (${bankCode ?? ""})'
                        : bank + ' (${bankCode ?? ""})',
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
                if (bname.isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.note, size: 15, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(bname,
                        style: const TextStyle(
                            fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                  ]),
                // 1. Fine
                if ((sum_tran_fine + sum_tran_fine_in) > 0)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 15, color: Colors.red),
                    const SizedBox(width: 6),
                    Text(
                        '${widget.cuslang == "EN" ? "Fine" : "ค่าปรับ"}: ${nFormat.format(sum_tran_fine + sum_tran_fine_in)}',
                        style: const TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontSize: 12.5,
                            color: Colors.red)),
                  ]),
                // // 2. Service Charge
                // if ((sum_pvat + sum_pvat_in) > 0)
                //   Row(mainAxisSize: MainAxisSize.min, children: [
                //     const Icon(Icons.room_service,
                //         size: 15, color: Colors.black54),
                //     const SizedBox(width: 6),
                //     Text(
                //         '${widget.cuslang == "EN" ? "Service Chg" : "ค่าบริการ"}: ${nFormat.format(sum_pvat + sum_pvat_in)}',
                //         style: const TextStyle(
                //             fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                //   ]),
                // // 3. Total (Baht) - (PVAT + Fine)
                // Row(mainAxisSize: MainAxisSize.min, children: [
                //   const Icon(Icons.monetization_on_outlined,
                //       size: 15, color: Colors.black54),
                //   const SizedBox(width: 6),
                //   Text(
                //       '${widget.cuslang == "EN" ? "Total(Baht)" : "รวม(บาท)"}: ${nFormat.format((sum_pvat + sum_tran_fine) + (sum_pvat_in + sum_tran_fine_in))}',
                //       style: const TextStyle(
                //           fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                // ]),
                // // 4. VAT
                // Row(mainAxisSize: MainAxisSize.min, children: [
                //   const Icon(Icons.percent, size: 15, color: Colors.black54),
                //   const SizedBox(width: 6),
                //   Text('VAT: ${fmtMoney(vatBill)}',
                //       style: const TextStyle(
                //           fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                // ]),
                // // 5. WHT
                // Row(mainAxisSize: MainAxisSize.min, children: [
                //   const Icon(Icons.money_off_csred_outlined,
                //       size: 15, color: Colors.black54),
                //   const SizedBox(width: 6),
                //   Text('WHT: ${fmtInt(whtBill)}',
                //       style: const TextStyle(
                //           fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                // ]),
                // 6. Discount
                if ((sum_disamt + sum_disamt_in) > 0)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.discount, size: 15, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(
                        '${widget.cuslang == "EN" ? "Discount" : "ส่วนลด"}: ${nFormat.format(sum_disamt + sum_disamt_in)}',
                        style: const TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontSize: 12.5,
                            color: Colors.green)),
                  ]),
                // 7. Total (Net)
                // Row(mainAxisSize: MainAxisSize.min, children: [
                //   const Icon(Icons.calculate, size: 15, color: Colors.black54),
                //   const SizedBox(width: 6),
                //   Text(
                //       '${widget.cuslang == "EN" ? "Net Total" : "ยอดรวม"}: ${nFormat.format((sum_pvat + sum_tran_fine) - (sum_disamt + sum_disamt_in) + (sum_amt_in + sum_tran_fine_in))}',
                //       style: const TextStyle(
                //           fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                // ]),
                // 8. Charge (Fee)
                if (fine_total > 0)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.add_card, size: 15, color: Colors.red),
                    const SizedBox(width: 6),
                    Text(
                        '${widget.cuslang == "EN" ? "Charge" : "ค่าธรรมเนียม"}: ${nFormat.format(fine_total)}',
                        style: const TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontSize: 12.5,
                            color: Colors.red)),
                  ]),
                // 9. Payment Amount (Final)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.payments, size: 15, color: Colors.black87),
                  const SizedBox(width: 6),
                  Text(
                      '${widget.cuslang == "EN" ? "Payment Amount" : "ยอดชำระสุทธิ"}: ${fmtMoney(totalBill)}',
                      style: const TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800)),
                ]),
              ],
            ),
          ),
          children: [
            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(thickness: 0.5, height: 24),
            ),
            // 1. Invoice List
            if (_InvoiceModels.isNotEmpty) ...[
              for (int index_in = 0;
                  index_in < _InvoiceModels.length;
                  index_in++)
                Builder(builder: (context) {
                  final model = _InvoiceModels[index_in];
                  final isSelected = invoicePayModels
                          .elementAtOrNull(index_in)
                          ?.ser
                          .toString() ==
                      model.ser;
                  final amt = _safeDouble(model.total_bill);
                  print(model.docno);
                  print(model.total_bill);
                  final finesList = _safeString(invoicePayfine).split(',');
                  double itemFine = 0.0;
                  if (invoicePayfine != null &&
                      invoicePayfine!.isNotEmpty &&
                      index_in < finesList.length) {
                    itemFine = _safeDouble(finesList[index_in]);
                  }
                  return _invoiceItem(
                    index: index_in + 1,
                    docNo: model.docno ?? '-',
                    amount: amt,
                    date: model.date ?? '',
                    isSelected: isSelected,
                    fine: itemFine,
                    onTap: () {},
                  );
                }),
            ],
            // 2. Unpaid Items (TransBill)
            if (_TransBillModels.isNotEmpty) ...[
              for (int index = 0; index < _TransBillModels.length; index++)
                Builder(builder: (context) {
                  final model = _TransBillModels[index];
                  final isSelected = _TransBillstring.elementAtOrNull(index)
                          ?.docno
                          .toString() ==
                      model.docno;
                  final amt = _safeDouble(model.total);

                  return _invoiceItem(
                    index: _InvoiceModels.length + (index + 1),
                    docNo: model.expname ?? '-',
                    amount: amt,
                    date: model.date ?? '',
                    isSelected: isSelected,
                    fine: 0,
                    onTap: () {},
                  );
                }),
            ]
          ],
        ),
      ),
    );
  }

  Widget _groupTile2() {
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

    final bank =
        _PayMentModels.isNotEmpty ? (_PayMentModels[0].bank ?? '') : '';
    final bno = _PayMentModels.isNotEmpty ? (_PayMentModels[0].bno ?? '') : '';
    final bname =
        _PayMentModels.isNotEmpty ? (_PayMentModels[0].bname ?? '') : '';

    final bankInfo = bankCodeMap[bank];
    final logoFile = bankInfo?['logo'];
    final bankCode = bankInfo?['code'];
    final bankEn = bankInfo?['en'];
//  bool tt =false
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
          onExpansionChanged: null,
          initiallyExpanded: false,
          trailing: const SizedBox(),
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
                        ? (bankEn ?? bank) + ' (${bankCode ?? ""})'
                        : bank + ' (${bankCode ?? ""})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5)),
              ),
              // const SizedBox(width: 4),
              // chip(widget.cuslang == 'EN' ? 'Bills' : 'ใบแจ้งหนี้',
              //     Colors.indigo.withOpacity(.08), Colors.indigo.shade700),
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
                if (bname.isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.note, size: 15, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(bname,
                        style: const TextStyle(
                            fontFamily: Font_.Fonts_T, fontSize: 12.5)),
                  ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _effectiveController,
        builder: (BuildContext context, Widget? child) {
          final double width = MediaQuery.of(context).size.width;
          final bool isMobile = width < 768;
          final bool isDesktop = width >= 900;
          final double qrSize = 140.0;
          return Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () async {
                    PanaraConfirmDialog.showAnimatedGrow(
                      context,
                      title: widget.cuslang == 'EN' ? "Warning" : "แจ้งเตือน",
                      message: widget.cuslang == 'EN'
                          ? "If paid, please attach proof and confirm. Or close to pay later."
                          : "หากชำระแล้ว กรุณาแนบหลักฐานและยืนยัน",
                      confirmButtonText: widget.cuslang == 'EN'
                          ? "Attach Proof"
                          : "แนบหลักฐาน",
                      cancelButtonText:
                          widget.cuslang == 'EN' ? "Pay Later" : "ชำระภายหลัง",
                      onTapConfirm: () async {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pop();
                        // _showPaymentConfirmationSheet(context);
                      },
                      onTapCancel: () async {
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
                      panaraDialogType: PanaraDialogType.warning,
                      barrierDismissible: true,
                    );
                  },
                ),
                title: ListTile(
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  title: Text(
                    widget.cuslang == 'EN' ? 'Payment' : 'ชำระเงิน',
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: Font_.Fonts_T,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: (selectTap == 2)
                      ? null
                      : (activeQrSessionSoftExpire == null ||
                              activeQrSessionSoftExpire!.isEmpty)
                          ? null
                          : Row(
                              children: [
                                // Text(
                                //   'chao-$QR_Ref1',
                                //   style: TextStyle(
                                //     color: Colors.grey,
                                //     fontFamily: Font_.Fonts_T,
                                //   ),
                                // ),
                                // const SizedBox(width: 6),
                                // Countdown + Progress (อ้างอิงวินาทีเดียว)
                                Expanded(
                                  child: StreamBuilder<int>(
                                    stream: _timerStream,
                                    initialData: secondsUntilExpire(),
                                    builder: (_, snap) {
                                      final secs = (snap.data ?? 0);
                                      final clamped = secs < 0 ? 0 : secs;
                                      final prog = _totalSecs > 0
                                          ? (clamped / _totalSecs)
                                              .clamp(0.0, 1.0)
                                          : 0.0;

                                      if (clamped == 0 &&
                                          // _uploadedSlipData == null &&
                                          !_expireDialogShown) {
                                        Future.microtask(() async {
                                          if (!mounted) return;
                                          setState(
                                              () => _expireDialogShown = true);
                                          PanaraConfirmDialog.showAnimatedGrow(
                                            context,
                                            title: widget.cuslang == 'EN'
                                                ? "Expired"
                                                : "หมดเวลา",
                                            message: widget.cuslang == 'EN'
                                                ? "Payment time expired. If paid, please attach proof. If not, please renew QR."
                                                : "หมดเวลาการชำระแล้ว หากชำระแล้วกรุณาแนบหลักฐานและชำระและยืนยัน หรือยังไม่ได้ชำระกรุณากดแสดง QR อีกครั้ง",
                                            confirmButtonText:
                                                widget.cuslang == 'EN'
                                                    ? "Attach Proof"
                                                    : "แนบหลักฐาน",
                                            cancelButtonText:
                                                widget.cuslang == 'EN'
                                                    ? "Close"
                                                    : "ปิด",
                                            onTapConfirm: () {
                                              Navigator.pop(context);
                                              _showPaymentConfirmationSheet(
                                                  context);
                                            },
                                            onTapCancel: () {
                                              Navigator.pop(context);
                                            },
                                            panaraDialogType:
                                                PanaraDialogType.warning,
                                            barrierDismissible: true,
                                          );
                                        });
                                      }

                                      final label = (clamped == 0
                                          ? 'หมดอายุแล้ว'
                                          : 'หมดอายุ ${_hhmmssFromSecs(clamped)}');

                                      // ถ้าหมดอายุแล้ว – ปิดแผ่น + เสนอให้ต่ออายุ
                                      // แต่ถ้ามีสลิปแล้ว (uploadedSlipData != null) ไม่ต้องปิด

                                      return Row(
                                        children: [
                                          Icon(
                                            clamped == 0
                                                ? Icons.timer_off
                                                : Icons.timer,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            label,
                                            style: const TextStyle(
                                              fontFamily: Font_.Fonts_T,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: LinearProgressIndicator(
                                                value: prog,
                                                minHeight: 6,
                                                backgroundColor: Colors.white24,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
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
                )),
// FAB Removed
            // backgroundColor: Colors.white,
            body: Stack(
              children: [
                FadeTransition(
                  opacity: _effectiveAnimation,
                  child: Transform(
                    transform: Matrix4.translationValues(
                        0.0, 30 * (1.0 - _effectiveAnimation.value), 0.0),
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      }),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 8, right: 8, top: 2),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // _InvoiceModels
                              // Container(
                              //   height: 50,
                              //   padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              //   child: Row(
                              //     children: [
                              //       ElevatedButton.icon(
                              //         style: ElevatedButton.styleFrom(
                              //           backgroundColor: selectTap == 1
                              //               ? Colors.black
                              //               : Colors.grey,
                              //         ),
                              //         icon: const Icon(Icons.padding),
                              //         label: Text(
                              //           'ค้างชำระ ${_InvoiceModels.length} ',
                              //         ),
                              //         onPressed: () async {
                              //           await _initData();
                              //           await initPlatformState();
                              //           setState(() {
                              //             selectTap = 1;
                              //           });
                              //         },
                              //       ),
                              //       const SizedBox(
                              //         width: 5,
                              //       ),
                              //       ElevatedButton.icon(
                              //         style: ElevatedButton.styleFrom(
                              //           backgroundColor: selectTap == 2
                              //               ? Colors.black
                              //               : Colors.grey,
                              //         ),
                              //         icon: const Icon(Icons.approval),
                              //         label: Text(
                              //           'รอยืนยัน ${paymentIntents.where((i) => i.bankmerchantid.toString() == '${widget.serPayment}').length}',
                              //         ),
                              //         onPressed: () async {
                              //           await _initData();
                              //           await initPlatformState();
                              //           setState(() {
                              //             selectTap = 2;
                              //           });
                              //         },
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              const SizedBox(
                                height: 5,
                              ),

                              // Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: Text(
                              //     widget.cuslang == 'EN'
                              //         ? 'Details'
                              //         : "รายละเอียด",
                              //     textAlign: TextAlign.start,
                              //     style: TextStyle(
                              //       fontWeight: FontWeight.bold,
                              //       fontSize: 14,
                              //     ),
                              //   ),
                              // ),
                              // _groupTile(),

                              if (selectTap == 2) ...[
                                LayoutBuilder(builder: (context, constraints) {
                                  final maxW = constraints.maxWidth;
                                  return Column(
                                    children: [
                                      _groupTile2(),
                                      const SizedBox(height: 2),
                                      _IntentBox(),
                                    ],
                                  );
                                })
                              ] else if (selectTap == 1) ...[
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final maxW = constraints.maxWidth;
                                    // Conditions to display QR Box
                                    final showQR = paymentSer1 != null &&
                                        gopay != 0 &&
                                        qr_expiresAt != null;

                                    // Determine if we should use Row (Desktop) or Column (Mobile)
                                    if (maxW >= 900) {
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (showQR) ...[
                                            Expanded(flex: 1, child: _QRBox()),
                                            // const SizedBox(width: 16),
                                          ],
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 10, 0, 0),
                                              child: Column(
                                                children: [
                                                  _groupTile(),
                                                  const SizedBox(height: 16),
                                                  _howToBox(),
                                                ],
                                              ),
                                            )),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          _groupTile(),
                                          const SizedBox(height: 2),
                                          if (showQR) ...[
                                            _QRBox(),
                                            const SizedBox(height: 4),
                                          ],
                                          Center(
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxWidth: maxW >= 480
                                                      ? 560
                                                      : double.infinity),
                                              child: _howToBox(),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ],

                              const SizedBox(height: 30),
                              // SizedBox(
                              //   height: 20,
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 30, // ปรับขนาดของ CircleAvatar
                            backgroundImage:
                                AssetImage('assets/images/Icon-chao.png'),
                          ),
                        ),
                        LoadingAnimationWidget.inkDrop(
                          color: Colors.green,
                          size: 70,
                        ),
                      ],
                    ),
                  )
                // Container(
                //   color: Colors.black.withOpacity(0.5),
                //   child: const Center(
                //     child: CircularProgressIndicator(
                //       color: Colors.white,
                //     ),
                //   ),
                // ),
              ],
            ),
            bottomNavigationBar:
                //  (selectTap == 2)
                //     ? null
                //     :
                Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_InvoiceModels.length == 0)
                        ? () {
                            PanaraInfoDialog.showAnimatedGrow(
                              context,
                              title: "Oops",
                              message: widget.cuslang == 'EN'
                                  ? "No payment amount!!!"
                                  : "ไม่มียอดชำระ !!!",
                              buttonText: widget.cuslang == 'EN'
                                  ? "acknowledge"
                                  : "รับทราบ",
                              onTapDismiss: () async {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                              },
                              panaraDialogType: PanaraDialogType.error,
                              barrierDismissible: false,
                            );
                          }
                        : (paymentSer1 != null &&
                                gopay != 0 &&
                                qr_expiresAt != null)
                            ? () async {
                                _showPaymentConfirmationSheet(context);
                              }
                            : () async {
                                await CreatePaymentItem();

                                return;
                              },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      (_InvoiceModels.length == 0)
                          ? widget.cuslang == 'EN'
                              ? "No payment amount"
                              : "ไม่มียอดชำระ"
                          : select_pay == 0
                              ? (widget.cuslang == 'EN'
                                  ? 'Payment Next'
                                  : 'ชำระเงินต่อไป')
                              : (paymentSer1 != null &&
                                      gopay != 0 &&
                                      qr_expiresAt != null)
                                  ? (widget.cuslang == 'EN'
                                      ? 'Confirm Payment'
                                      : 'กดเพื่อ “แนบหลักฐานและยืนยัน”')
                                  : (widget.cuslang == 'EN'
                                      ? 'Start Payment'
                                      : 'กดเพื่อ “เริ่มการชำระ”'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  _saveNetworkImage(String imageUrl) async {
    var response = await Dio()
        .get(imageUrl, options: Options(responseType: ResponseType.bytes));
    await Gal.putImageBytes(Uint8List.fromList(response.data));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: Colors.black,
          content: Text('บันทึกรูปภาพสำเร็จ',
              style:
                  TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
    );
  }

  Future<void> saveImage(String imageUrl) async {
    Uint8List image =
        (await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl))
            .buffer
            .asUint8List();
    try {
      if (Platform.isIOS) {
        PermissionStatus permission = await Permission.photos.status;
        if (permission == PermissionStatus.granted) {
        } else {
          openAppSettings();
          throw 'denied';
        }
      } else if (Platform.isAndroid) {
        PermissionStatus permission = await Permission.storage.status;
        if (permission == PermissionStatus.granted) {
        } else {
          openAppSettings();
          throw 'denied';
        }
      }
      await Gal.putImageBytes(image);
    } catch (e) {
      throw e;
    }
  }

  Future<void> downloadImage(String imageUrl) async {
    try {
      // first we make a request to the url like you did
      // in the android and ios version
      final http.Response r = await http.get(
        Uri.parse(imageUrl),
      );

      // we get the bytes from the body
      final data = r.bodyBytes;
      // and encode them to base64
      final base64data = base64Encode(data);

      // then we create and AnchorElement with the html package
      final a = html.AnchorElement(href: 'data:image/jpeg;base64,$base64data');

      // set the name of the file we want the image to get
      // downloaded to
      a.download = 'Load_QR_$refpay.jpg';

      // and we click the AnchorElement which downloads the image
      a.click();
      // finally we remove the AnchorElement
      a.remove();
    } catch (e) {
      // print(e);
    }
  }

  Future<void> _showMyDialogPay_Error(text) {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            // title: const Text('AlertDialog Title'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '$text',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            // color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        child: Container(
                            width: 100,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              // border: Border.all(color: Colors.white, width: 1),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: Text(
                              widget.cuslang == 'EN' ? 'Close' : 'ปิด',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T
                                  //  fontFamily: FontWeight_.Fonts_T
                                  //fontSize: 10.0
                                  ),
                            ))),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  List<TransBillModel> _TransBillModels = [];
  List<TransModel> _TransModels = [];
  ////////////////------------------------------------------------------>SHOPNO ==1 ผ่านเว็ป

  Future<Null> in_Trans_select(index) async {
    ////////////////------------------------------------------------------>SHOPNO ==1 ผ่านเว็ป
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ciddoc_ = preferences.getString('usercid');
    var qutser_ = preferences.getString('qutser');
    ////////////////------------------------------------------------------>
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = ciddoc_;
    var qutser = qutser_;
    var shopno = '1';
    var pos = '1';
    var tser = '${_TransBillModels[index].ser}';
    //_TransBillModels[index].ser;
    var tdocno = '${_TransBillModels[index].docno}';
    //_TransBillModels[index].docno;

    // //print('object $tdocno');
    Map<String, dynamic> queryParams = {
      'isAdd': 'true',
      'ren': ren,
      'ciddoc': ciddoc,
      'qutser': qutser,
      'tser': tser,
      'tdocno': tdocno,
      'user': user,
      'shopno': shopno,
      'pos': pos,
    };

    var uri =
        Uri.parse('${MyConstant().domain_chao}/In_tran_select_Chao_user.php')
            .replace(queryParameters: queryParams);

    try {
      var response = await http.get(uri);

      var result = json.decode(response.body);
      // //print('rr>>>>>> $result');
      if (result.toString() == 'true') {
        setState(() {
          red_Trans_select2();
        });
        // //print('rrrrrrrrrrrrrr');
      } else if (result.toString() == 'false') {
        setState(() {
          red_Trans_select2();
        });
        // //print('rrrrrrrrrrrrrrfalse');
      } else {
        setState(() {
          red_Trans_select2();
        });
      }
    } catch (e) {}
  }

  Future<Null> de_Trans_select(index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = preferences.getString('usercid');
    var qutser = preferences.getString('qutser');

    var tser = _TransBillModels[index].ser;
    var tdocno = _TransBillModels[index].docno;

    //print('tser >>.> $tser>>. $tdocno');

    Map<String, dynamic> queryParams = {
      'isAdd': 'true',
      'ren': ren,
      'ciddoc': ciddoc,
      'qutser': qutser,
      'tser': tser,
      'tdocno': tdocno,
      'user': user,
    };

    var uri =
        Uri.parse('${MyConstant().domain_chao}/D_tran_select_ser_User.php')
            .replace(queryParameters: queryParams);

    try {
      var response = await http.get(uri);

      var result = json.decode(response.body);
      // //print(result);
      if (result.toString() == 'true') {
        setState(() {
          red_Trans_select2();
        });
        //print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  Future<Null> red_Trans_select2() async {
    if (_TransModels.isNotEmpty) {
      setState(() {
        _TransModels.clear();
      });
    }
    ////////////////------------------------------------------------------> SHOPNO ==1 ผ่านเว็ป // Pos = 1 รออนุมัติ
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ciddoc_ = preferences.getString('usercid');
    var qutser_ = preferences.getString('qutser');
    ////////////////------------------------------------------------------>
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    if (widget.teNantModel == null) {
      var ciddoc = ciddoc_;
      var qutser = qutser_;

      Map<String, dynamic> queryParams = {
        'isAdd': 'true',
        'ren': ren,
        'user': user,
        'ciddoc': ciddoc,
      };

      var uri = Uri.parse('${MyConstant().domain_chao}/GC_tran_select.php')
          .replace(queryParameters: queryParams);
      try {
        var response = await http.get(uri);

        var result = json.decode(response.body);
        // //print(result);
        if (result.toString() != 'null') {
          setState(() {
            _TransModels.clear();
            sum_pvat = 0;
            sum_vat = 0;
            sum_wht = 0;
            sum_amt = 0;
          });
          for (var map in result) {
            TransModel _TransModel = TransModel.fromJson(map);

            var sum_pvatx = double.parse(_TransModel.pvat!);
            var sum_vatx = double.parse(_TransModel.vat!);
            var sum_whtx = double.parse(_TransModel.wht!);
            var sum_amtx = double.parse(_TransModel.total!);
            setState(() {
              sum_pvat = sum_pvat + sum_pvatx;
              sum_vat = sum_vat + sum_vatx;
              sum_wht = sum_wht + sum_whtx;
              sum_amt = sum_amt + sum_amtx;
              _TransModels.add(_TransModel);
            });
          }
        }

        setState(() {
          red_Trans_select2_fin();
          sum_pvat = sum_pvat + sum_tran_fine;
          sum_amt = sum_amt + sum_tran_fine;
          Form_payment1.text = (sum_pvat +
                  sum_tran_fine -
                  dis_sum_Pakan -
                  (sum_disamt + sum_disamt_in) +
                  (sum_amt_in + sum_tran_fine_in) +
                  (fine_total))
              .toStringAsFixed(2)
              .toString();
          // Form_payment1.text = (sum_amt - sum_disamt - dis_sum_Pakan)
          //     .toStringAsFixed(2)
          //     .toString();
        });
      } catch (e) {}
    } else {
      for (var i = 0; i < widget.teNantModel!.length; i++) {
        var ciddoc = widget.teNantModel![i].cid;
        var qutser = qutser_;

        Map<String, dynamic> queryParams = {
          'isAdd': 'true',
          'ren': ren,
          'user': user,
          'ciddoc': ciddoc,
        };

        var uri = Uri.parse('${MyConstant().domain_chao}/GC_tran_select.php')
            .replace(queryParameters: queryParams);
        try {
          var response = await http.get(uri);

          var result = json.decode(response.body);
          // //print(result);
          if (result.toString() != 'null') {
            setState(() {
              _TransModels.clear();
              sum_pvat = 0;
              sum_vat = 0;
              sum_wht = 0;
              sum_amt = 0;
            });
            for (var map in result) {
              TransModel _TransModel = TransModel.fromJson(map);

              var sum_pvatx = double.parse(_TransModel.pvat!);
              var sum_vatx = double.parse(_TransModel.vat!);
              var sum_whtx = double.parse(_TransModel.wht!);
              var sum_amtx = double.parse(_TransModel.total!);
              setState(() {
                sum_pvat = sum_pvat + sum_pvatx;
                sum_vat = sum_vat + sum_vatx;
                sum_wht = sum_wht + sum_whtx;
                sum_amt = sum_amt + sum_amtx;
                _TransModels.add(_TransModel);
              });
            }
          }

          setState(() {
            red_Trans_select2_fin();
            sum_pvat = sum_pvat + sum_tran_fine;
            sum_amt = sum_amt + sum_tran_fine;
            Form_payment1.text = (sum_pvat +
                    sum_tran_fine -
                    dis_sum_Pakan -
                    (sum_disamt + sum_disamt_in) +
                    (sum_amt_in + sum_tran_fine_in) +
                    (fine_total))
                .toStringAsFixed(2)
                .toString();
            // Form_payment1.text = (sum_amt - sum_disamt - dis_sum_Pakan)
            //     .toStringAsFixed(2)
            //     .toString();
          });
        } catch (e) {}
      }
    }
  }

  Future<Null> red_Trans_select2_fin() async {
    if (transFineModels.isNotEmpty) {
      setState(() {
        transFineModels.clear();
        sum_tran_fine = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    if (widget.teNantModel == null) {
      var ciddoc = preferences.getString('usercid');
      var qutser = 1;

      Map<String, dynamic> queryParams = {
        'isAdd': 'true',
        'ren': ren,
        'user': user,
        'ciddoc': ciddoc,
      };

      var uri = Uri.parse('${MyConstant().domain_chao}/GC_tran_select_fin.php')
          .replace(queryParameters: queryParams);

      try {
        var response = await http.get(uri);

        var result = json.decode(response.body);
        // //print(result);
        if (result.toString() != 'null') {
          transFineModels.clear();
          sum_tran_fine = 0;
          for (var map in result) {
            TransFineModel transFineModel = TransFineModel.fromJson(map);

            var sum_totalx = double.parse(transFineModel.total!);
            setState(() {
              // sum_pvat = sum_pvat + sum_totalx;
              // sum_amt = sum_amt + sum_totalx;

              sum_tran_fine = sum_tran_fine + sum_totalx;
              transFineModels.add(transFineModel);
            });
          }
        }
      } catch (e) {}
    } else {
      for (var i = 0; i < widget.teNantModel!.length; i++) {
        var ciddoc = widget.teNantModel![i].cid;
        var qutser = 1;

        Map<String, dynamic> queryParams = {
          'isAdd': 'true',
          'ren': ren,
          'user': user,
          'ciddoc': ciddoc,
        };

        var uri =
            Uri.parse('${MyConstant().domain_chao}/GC_tran_select_fin.php')
                .replace(queryParameters: queryParams);

        try {
          var response = await http.get(uri);

          var result = json.decode(response.body);
          // //print(result);
          if (result.toString() != 'null') {
            transFineModels.clear();
            sum_tran_fine = 0;
            for (var map in result) {
              TransFineModel transFineModel = TransFineModel.fromJson(map);

              var sum_totalx = double.parse(transFineModel.total!);
              setState(() {
                // sum_pvat = sum_pvat + sum_totalx;
                // sum_amt = sum_amt + sum_totalx;

                sum_tran_fine = sum_tran_fine + sum_totalx;
                transFineModels.add(transFineModel);
              });
            }
          }
        } catch (e) {}
      }
    }

    setState(() {
      Form_payment1.text = (sum_pvat +
              sum_tran_fine -
              dis_sum_Pakan -
              (sum_disamt + sum_disamt_in) +
              (sum_amt_in + sum_tran_fine_in) +
              (fine_total))
          .toStringAsFixed(2)
          .toString();
    });
  }

  Future<String> in_Trans_invoice_genqr() async {
    List newValuePDFimg = [];
    for (int index = 0; index < 1; index++) {
      if (renTalModels[0].imglogo!.trim() == '') {
      } else {
        newValuePDFimg.add(
            '${MyConstant().domain_chao}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
      }
    }
    DateTime now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    int second = now.second;

    /////////------------------->
    String? fileName_Slip_ = fileName_Slip.toString().trim();
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var custno = preferences.getString('custno');
    var qutser_ = preferences.getString('qutser');

    var ciddoc_ = preferences.getString('usercid');
    var paybyselect = preferences.getString('payby');
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var user_bill = _InvoiceModels[0].user;
    var ciddoc = widget.teNantModel!.length != 1 ? '0' : ciddoc_;
    var qutser = 1;
    var sumdis = (sum_disamt + sum_disamt_in).toStringAsFixed(2).toString();
    var sumdisp = '0.00'.toString();
    var dateY = Value_newDateY;
    var dateY1 = Value_newDateY1;
    var time = '$hour:$minute:$second';
    var bill = bills_name_ == 'บิลธรรมดา' ? 'P' : 'F';
    var dis_akan = dis_sum_Pakan.toString();
    //pamentpage == 0
    var payment1 = Form_payment1.text.toString();
    var payment2 = Form_payment2.text.toString();
    var pSer1 = paymentSer1;
    var pSer2 = paymentSer2;
    var sum_whta = (sum_wht + sum_wht_in).toString();
    var comment = '';
    var shopno = '1';
    var pos = '1';
    var fine_total_tt = fine_total;
    var tran_fine = (sum_tran_fine + sum_tran_fine_in).toString();
    var pamentpage = 0;
    var Slip_status = 0;
    var io2 = invoicePay == null || invoicePay == ''
        ? '0'
        : invoicePay!.substring(0, invoicePay!.length - 0); // string
    var io4 = invoicePayfine == null || invoicePayfine == ''
        ? '0'
        : invoicePayfine!.substring(0, invoicePayfine!.length - 0); // string
    // var io2 = invoicePay == null || invoicePay == ''
    //     ? '0'
    //     : invoicePay!.substring(0, invoicePay!.length - 1); // string
    // var io4 = invoicePayfine == null || invoicePayfine == ''
    //     ? '0'
    //     : invoicePayfine!.substring(0, invoicePayfine!.length - 1); // string

    var payby = 'U';
    var paybywidget = '0'; // paybyselect == 'PAYCONTACT' ? '0' : custno;

    // print(
    //     '$invoicePay ..... $invoicePayfine ...... i $ciddoc i $paybywidget ii $io2 >>>>444>>>$io4>>>$tran_fine');

    Map<String, dynamic> queryParams = {
      'isAdd': 'true',
      'ren': ren,
      'ciddoc': ciddoc,
      'qutser': qutser.toString(),
      'user': user,
      'sumdis': sumdis,
      'sumdisp': sumdisp,
      'dateY': dateY,
      'dateY1': dateY1,
      'time': time,
      'payment1': payment1,
      'payment2': payment2,
      'pSer1': pSer1,
      'pSer2': pSer2,
      'sum_whta': sum_whta,
      'bill': bill,
      'fileNameSlip': fileName_Slip_,
      'comment': comment,
      'dis_Pakan': dis_akan,
      'shopno': shopno,
      'pos': pos,
      'fine_total_amt': fine_total_tt.toString(),
      'tran_fine': tran_fine,
      'invoice': io2,
      'fin_in': io4,
      'ref': refpay,
      'payby': payby,
      'paybywidget': paybywidget,
      'user_bill': user_bill,
    };

    var uri = Uri.parse('${MyConstant().domain_chao}/In_tran_financet_User.php')
        .replace(queryParameters: queryParams);

    // print('Generated URL: $uri');
    return uri.toString();
  }

  Future<Null> in_Trans_invoice(newValuePDFimg,
      {bool showSuccess = true}) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    DateTime now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    int second = now.second;

    /////////------------------->
    String? fileName_Slip_ = fileName_Slip.toString().trim();
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var custno = preferences.getString('custno');

    ////////////////------------------------------------------------------>
    // if (widget.teNantModel == null) {
    var ciddoc_ = preferences.getString('usercid');
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var user_bill = _InvoiceModels[0].user;
    var ciddoc = widget.teNantModel!.length != 1 ? '0' : ciddoc_;
    var qutser = 1;
    var sumdis = (sum_disamt + sum_disamt_in).toStringAsFixed(2).toString();
    var sumdisp = '0.00'.toString();
    var dateY = Value_newDateY;
    var dateY1 = Value_newDateY1;
    var time = '$hour:$minute:$second';
    var bill = bills_name_ == 'บิลธรรมดา' ? 'P' : 'F';
    var dis_akan = dis_sum_Pakan.toString();
    //pamentpage == 0
    var payment1 = Form_payment1.text.toString();
    var payment2 = Form_payment2.text.toString();
    var pSer1 = paymentSer1;
    var pSer2 = paymentSer2;
    var sum_whta = (sum_wht + sum_wht_in).toString();
    var comment = '';
    var shopno = '1';
    var pos = '1';
    var fine_total_tt = fine_total;
    var tran_fine = (sum_tran_fine + sum_tran_fine_in).toString();

    var pamentpage = 0;
    var Slip_status = 0;

    var io2 = invoicePay == null || invoicePay == ''
        ? '0'
        : (invoicePay!.length == 1)
            ? invoicePay!.substring(0, invoicePay!.length - 0)
            : invoicePay!.substring(0, invoicePay!.length - 0); // string
    var io4 = invoicePayfine == null || invoicePayfine == ''
        ? '0'
        : invoicePayfine!.substring(0, invoicePayfine!.length - 0); // string

    var payby = 'U';
    var paybywidget = '0'; // paybyselect == 'PAYCONTACT' ? '0' : custno;

    // print(
    //     '$invoicePay ..... $invoicePayfine ...... i $ciddoc i $paybywidget ii $io2 >>>>444>>>$io4>>>$tran_fine');

    Map<String, dynamic> queryParams = {
      'isAdd': 'true',
      'ren': ren,
      'ciddoc': ciddoc,
      'qutser': qutser.toString(),
      'user': user,
      'sumdis': sumdis,
      'sumdisp': sumdisp,
      'dateY': dateY,
      'dateY1': dateY1,
      'time': time,
      'payment1': payment1,
      'payment2': payment2,
      'pSer1': pSer1,
      'pSer2': pSer2,
      'sum_whta': sum_whta,
      'bill': bill,
      'fileNameSlip': fileName_Slip_,
      'comment': comment,
      'dis_Pakan': dis_akan,
      'shopno': shopno,
      'pos': pos,
      'fine_total_amt': fine_total_tt.toString(),
      'tran_fine': tran_fine,
      'invoice': io2,
      'fin_in': io4,
      'ref': refpay,
      'payby': payby,
      'paybywidget': paybywidget,
      'user_bill': user_bill,
    };

    var uri = Uri.parse('${MyConstant().domain_chao}/In_tran_financet_User.php')
        .replace(queryParameters: queryParams);
    // print(queryParams);
    print('paybyselect url $uri ');

    try {
      var response = await http.get(uri);

      var result = json.decode(response.body);

      if (result.toString() != 'No') {
        for (var map in result) {
          CFinnancetransModel cFinnancetransModel =
              CFinnancetransModel.fromJson(map);
          if (!mounted) return;
          setState(() {
            cFinn = cFinnancetransModel.docno;
            listitem.clear();
            base64_Slip = null;
            fileName_Slip = null;
            extension_ = null;
            file_ = null;
            selectedValue = null;
          });
        }

        var custno = preferences.getString('custno');
        Insert_log.Insert_logs('ชำระ', ' $ciddoc ($cFinn)');
      }
    } catch (e) {
      // //print('$e');
    } finally {
      if (mounted && showSuccess) {
        await sucress(onDismiss: () {
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) {
            return FitnessAppHomeScreen(custno_s: custno);
          }), (route) => false);
        });
      }
    }
  }

  // void generateRandomString() {
  //   setState(() {
  //     QR_Ref1 = getRandomString(18);
  //     QR_Ref2 = getRandomString(18);
  //     QR_Ref3 = getRandomString(18);
  //   });
  // }

  Future<bool> _processPaymentConfirmation(BuildContext ctx) async {
    // Navigator.of(ctx).pop(); // Close the dialog // Removed to handle manually
    List newValuePDFimg = [];
    for (int index = 0; index < 1; index++) {
      if (renTalModels[0].imglogo!.trim() != '') {
        newValuePDFimg.add(
            '${MyConstant().domain_chao}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
      }
    }
    try {
      await OKuploadFile_Slip(newValuePDFimg);
      await in_Trans_invoice(newValuePDFimg, showSuccess: false);
      return true;
    } catch (e) {
      _showMyDialogPay_Error(widget.cuslang == 'EN'
          ? "An error occurred. Please check the information. Please try again!"
          : 'เกิดข้อผิดพลาด ตรวจสอบความถูกต้อง กรุณาลองอีกครั้ง!');
      return false;
    }
  }

  void _showSlideConfirmDialog() {
    if (!mounted) return;
    showDialog(
      context: context, // uses this.context
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.cuslang == 'EN'
                            ? 'Confirm Payment'
                            : 'ยืนยันการชำระเงิน',
                        style: TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1),
                SizedBox(height: 10),
                if (_uploadedSlipData != null)
                  Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.black12,
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.1,
                      maxScale: 4.0,
                      child: Image.memory(
                        _uploadedSlipData!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                SizedBox(height: 16),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _SlideToConfirm(
                    label: widget.cuslang == 'EN'
                        ? 'Slide to Confirm'
                        : 'เลื่อนเพื่อยืนยัน',
                    enabled: true,
                    onConfirmation: () async {
                      if (_isProcessingLink) return;
                      setState(() => _isProcessingLink = true);

                      try {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      radius: 30,
                                      backgroundImage: AssetImage(
                                          'assets/images/Icon-chao.png'),
                                    ),
                                  ),
                                  LoadingAnimationWidget.inkDrop(
                                    color: Colors.green,
                                    size: 70,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                        // _processPaymentConfirmation(ctx);

                        final success = await _processPaymentConfirmation(ctx);

                        if (!mounted) return;

                        // Close loading dialog
                        Navigator.of(context).pop();

                        if (success) {
                          Navigator.of(ctx).pop(); // Close Alert dialog

                          // Show success dialog and navigate
                          sucress(onDismiss: () {
                            // Use 'cid' from TeNantModel, or fallback
                            // Note: In in_Trans_invoice, it used 'custno' from SharedPreferences.
                            // FitnessAppHomeScreen likely expects 'custno'.
                            // If TeNantModel.cid isn't the custno, we should grab it from Prefs or use 'cid' if it maps.
                            // Looking at GetTeNant_Model.dart, 'cid' exists.
                            // Let's safe bet: fetch custno from prefs again as in_Trans_invoice did,
                            // OR just use widget.teNantModel?[0].cid if appropriate.
                            // Given the context, let's use the safer Prefs approach if we can, or just null since
                            // FitnessAppHomeScreen might handle it.
                            // But wait, we can't be async here easily in onDismiss without mounting issues?
                            // Actually, onDismiss is synchronous callback.
                            // Let's just use widget.teNantModel?[0].cid as a best effort,
                            // or just pass null if it's optional.

                            Navigator.pushAndRemoveUntil(context,
                                MaterialPageRoute(builder: (context) {
                              return FitnessAppHomeScreen(
                                  custno_s: widget.teNantModel?[0].cid);
                            }), (route) => false);
                          });
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isProcessingLink = false);
                        }
                      }
                    },
                    // onConfirmation: () async {
                    //   // Reset uploaded data to allow new upload
                    //   setState(() {
                    //     _uploadedSlipData = null;
                    //   });
                    //   // Trigger file picker
                    //   // final success = await _pickSlipImage();
                    //   if (base64_Slip != null) {
                    //     if (!mounted) return;
                    //     showDialog(
                    //       context: context,
                    //       barrierDismissible: false,
                    //       builder: (BuildContext context) {
                    //         return const Center(
                    //           child: CircularProgressIndicator(),
                    //         );
                    //       },
                    //     );
                    //     final successUp = await _uploadSlipImage(
                    //         amtRawSlip: sum_amt.toString());
                    //     if (mounted) {
                    //       Navigator.of(context).pop(); // Close dialog
                    //       Navigator.of(context).pop(); // Close dialog
                    //       Navigator.pushAndRemoveUntil(context,
                    //           MaterialPageRoute(builder: (context) {
                    //         return FitnessAppHomeScreen(custno_s: custno);
                    //       }), (route) => false);
                    //       if (successUp) {
                    //         Fluttertoast.showToast(
                    //             timeInSecForIosWeb: 3,
                    //             msg: widget.cuslang == 'EN'
                    //                 ? "Slip upload successful"
                    //                 : 'อัปโหลดสลิปสำเร็จ',
                    //             backgroundColor: Colors.black,
                    //             textColor: Colors.white,
                    //             webPosition: "center",
                    //             webBgColor: "#000000",
                    //             toastLength: Toast.LENGTH_SHORT);
                    //       }
                    //     }
                    //   }
                    //   // _processPaymentConfirmation(ctx);
                    // },
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _DetailsPaymentIntentsReload() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer');
      final String custnoLocal =
          _TransModels.isNotEmpty ? '${_TransModels.first.custno ?? ''}' : '';

      // Keep raw values as-is (preserve leading zeros)
      final custno16Bit = custnoLocal.trim();
      final ren16Bit = (ren ?? '').trim();

      final intentsUuid = numinvoice.toString();

      final resp = await getDetailsPaymentIntents(
        cusNo: custno16Bit,
        propertyNo: ren16Bit,
        intentsUuid: intentsUuid,
      );

      if (resp == null || resp.statusCode < 200 || resp.statusCode >= 300) {
        debugPrint('❌ getDetailsPaymentIntents failed: ${resp?.statusCode}');
        return null;
      }

      final root = json.decode(resp.body);
      debugPrint('🟢 DetailsPaymentIntent Response: OK');
      // debugPrint('🟢 DetailsPaymentIntent Response: $root');
      return root['data'] as Map<String, dynamic>?;
    } catch (e, st) {
      debugPrint('❌ DetailsPaymentIntents exception: $e\n$st');
      return null;
    }
  }

  Future<bool> _renewQrAndReload() async {
    String _toU16(String? v) => (v ?? '0').trim();

    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer');
      SharedPreferences preferences = await SharedPreferences.getInstance();

      var custnoPreferences = await preferences.getString('custno');

      String ren16Bit = _toU16('$ren').toString();
      String custno16Bit = _toU16('$custnoPreferences').toString();
      final intentsUuid = numinvoice.toString();
      if (custno16Bit == '65535') {
        return false;
      }
      // ✅ พยายามใช้ customer_no / property_no จาก Intent เดิมเพื่อให้ตรงกัน
      if (paymentIntents.isNotEmpty) {
        try {
          final found =
              paymentIntents.firstWhere((p) => p.intentUuid == intentsUuid);
          if (found.customerNo != null && found.customerNo!.isNotEmpty) {
            custno16Bit = found
                .customerNo!; // ✅ ต้องใช้ค่าจาก Intent เท่านั้น ไม่งั้น API จะ reject (Mismatch)
          }
          if (found.propertyNo != null && found.propertyNo!.isNotEmpty) {
            ren16Bit = found.propertyNo!;
          }
        } catch (_) {}
      }

      final resp = await postGeneratePaymentIntents(
        cusNo: custno16Bit,
        propertyNo: ren16Bit,
        intentsUuid: intentsUuid,
        bankMerchantId: int.tryParse('$paymentSer1') ?? 0,
      );

      if (resp == null || resp.statusCode < 200 || resp.statusCode >= 300) {
        debugPrint('renew fail: ${resp?.statusCode} ${resp?.body}');
        return false;
      }

      final root = json.decode(resp.body);
      debugPrint('🟢 QR Generate Response: $root');

      if (!mounted) return false;
      setState(() {
        qr_expiresAt = root['soft_expire_at'] ?? root['expires_at']; // ISO8601
        return_qr_refapi1 = root['ref1'];
        return_qr_refapi2 = root['ref2'];
        return_qr_refapi3 = root['ref3'];
        qr_payload = root['payload'] ?? ''; // Add payload
        activeQrSessionSoftExpire =
            root['soft_expire_at']; // Update active session expire
        qr_softExpiresAt =
            root['soft_expire_at']; // Also update local soft expire
        _expireDialogShown = false;
      });

      return true;
    } catch (e, st) {
      debugPrint('renew exception: $e\n$st');
      return false;
    }
  }

  Future<dynamic> sucress({VoidCallback? onDismiss}) async {
    if (!mounted) return;
    return PanaraInfoDialog.show(
      context,
      title: widget.cuslang == 'EN' ? 'Completed' : "ดำเนินการเสร็จสิ้น",
      message: widget.cuslang == 'EN'
          ? 'You can check your payment within 1-3 business days.'
          : "สามารถตรวจสอบการชำระภายใน 1-3 วันทำการ",
      buttonText: widget.cuslang == 'EN' ? 'OK' : "ตกลง",
      onTapDismiss: () {
        Navigator.pop(context);
        if (onDismiss != null) onDismiss();
      },
      panaraDialogType: PanaraDialogType.success,
      barrierDismissible: false,
    );
  }

  Future<bool> _pickSlipImage() async {
    final completer = Completer<bool>();

    // Helper to show loading
    void _showProcessing() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text(
                    "กำลังรวมรูปภาพ...",
                    style: TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Helper to request close loading
    void _hideProcessing() {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (kIsWeb) {
      // Web: use FileUploadInputElement
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.multiple = true; // Allow multiple files
      uploadInput.click();

      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files == null || files.isEmpty) {
          return; // Cancelled or empty
        }

        _showProcessing();

        try {
          List<Uint8List> images = [];
          for (var file in files) {
            final reader = html.FileReader();
            reader.readAsArrayBuffer(file);
            await reader.onLoadEnd.first;
            if (reader.result != null) {
              images.add(reader.result as Uint8List);
            }
          }

          if (images.isNotEmpty) {
            Uint8List? finalImage;
            // Merge images (always, to include footer)
            finalImage = await mergeImagesReceiptStyle(
              images,
              ref1: return_qr_refapi1,
              ref2: return_qr_refapi2,
              ref3: return_qr_refapi3,
            );

            if (finalImage != null) {
              if (mounted) {
                setState(() {
                  _slipImageBytes = finalImage;
                  _slipImageName =
                      files.length > 1 ? "merged_slip.jpg" : files[0].name;
                  base64_Slip = base64Encode(_slipImageBytes!);
                  _uploadedSlipData = _slipImageBytes;
                });
                _hideProcessing();
              }
              completer.complete(true);
            } else {
              if (mounted) {
                _hideProcessing();
                Fluttertoast.showToast(msg: "Failed to process images");
              }
              completer.complete(false);
            }
          } else {
            _hideProcessing();
            completer.complete(false);
          }
        } catch (e) {
          debugPrint("Error picking web images: $e");
          _hideProcessing();
          completer.complete(false);
        }
      });
    } else {
      // Mobile/Desktop: use ImagePicker
      final ImagePicker picker = ImagePicker();
      try {
        final List<XFile> images = await picker.pickMultiImage();

        if (images.isNotEmpty) {
          _showProcessing();

          List<Uint8List> imageBytesList = [];
          for (var imgFile in images) {
            imageBytesList.add(await imgFile.readAsBytes());
          }

          Uint8List? finalImage;
          // Merge images (always, to include footer)
          finalImage = await mergeImagesReceiptStyle(
            imageBytesList,
            ref1: return_qr_refapi1,
            ref2: return_qr_refapi2,
            ref3: return_qr_refapi3,
          );

          if (finalImage != null) {
            if (mounted) {
              setState(() {
                _slipImageBytes = finalImage;
                _slipImageName =
                    images.length > 1 ? "merged_slip.jpg" : images[0].name;
                base64_Slip = base64Encode(_slipImageBytes!);
                _uploadedSlipData = _slipImageBytes;
              });
              _hideProcessing();
            }
            completer.complete(true);
          } else {
            if (mounted) {
              _hideProcessing();
              Fluttertoast.showToast(msg: "Failed to merge images");
            }
            completer.complete(false);
          }
        } else {
          completer.complete(false);
        }
      } catch (e) {
        debugPrint("Error picking mobile images: $e");
        completer.complete(false);
      }
    }

    return completer.future;
  }

  Future<Uint8List?> mergeImagesReceiptStyle(
    List<Uint8List> images, {
    String? ref1,
    String? ref2,
    String? ref3,
  }) async {
    try {
      // Calculate Total Bills here on main thread
      double totalBill = sum_pvat +
          sum_tran_fine -
          dis_sum_Pakan -
          (sum_disamt + sum_disamt_in) +
          (sum_amt_in + sum_tran_fine_in) +
          fine_total;
      String totalBills = totalBill.toStringAsFixed(2);
      double tran_fine = (sum_tran_fine + sum_tran_fine_in) ?? 0.00;
      final bank =
          _PayMentModels.isNotEmpty ? (_PayMentModels[0].bank ?? '') : '';
      final bno =
          _PayMentModels.isNotEmpty ? (_PayMentModels[0].bno ?? '') : '';
      final bname =
          _PayMentModels.isNotEmpty ? (_PayMentModels[0].bname ?? '') : '';
      final bankInfo = bankCodeMap[bank];
      final logoFile = bankInfo?['logo'];
      final bankCode = bankInfo?['code'];
      final bankEn = bankInfo?['en'];
      // Use compute to run in background isolate
      return await compute(
        _processMergeImages,
        MergeParams(
          images: images,
          ref1: ref1,
          ref2: ref2,
          ref3: ref3,
          totalBills: nFormat.format(double.parse(totalBills ?? "0")) ?? "-",
          activeQrSessionSoftExpire: activeQrSessionSoftExpire != null
              ? DateFormat('dd-MM-yyyy HH:mm')
                  .format(DateTime.parse(activeQrSessionSoftExpire!).toLocal())
              : '-',
          lateFee: nFormat.format(tran_fine) ?? "-",
          qr: (payment_tser == '6' || payment_tser == '7')
              ? qrDataNoIntens
              : '',
          bankname: bankCode ?? "-",
          banknumber: selectedValue ?? "-",
        ),
      );
    } catch (e) {
      debugPrint('Error initiates merge compute: $e');
      return null;
    }
  }

// Upload slip image to server
  Future<bool> _uploadSlipImage({required String amtRawSlip}) async {
    if (_slipImageBytes == null || _slipImageName == null) return false;

    // Show loading message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('กำลังอัปโหลดสลิป...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );

    try {
      // Get selected payment intent UUID
      final uuid = numinvoice ?? '';
      if (uuid.isEmpty) {
        throw Exception('ไม่พบ Payment Intent UUID');
      }
      final headers = await MyHeadersIntents.build();

      final uri = Uri.parse(
          '${MyconfigIntents().domainIntents}/v1/payment/intent/$uuid/upload/slip');

      final request = http.MultipartRequest('POST', uri);

      // Add form fields
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      print("uri : $uri");
      print({
        'amount': amtRawSlip,
        'transfer_date': dateStr,
        'transfer_ref_no': return_qr_refapi3 ?? '',
        'transfer_type': 'bank_transfer',
        'notes': 'อัปโหลดจาก QR Sheet',
      });
      request.fields.addAll({
        'amount': amtRawSlip,
        'transfer_date': dateStr,
        'transfer_ref_no': return_qr_refapi3 ?? '',
        'transfer_type': 'bank_transfer',
        'notes': 'อัปโหลดจาก QR Sheet',
      });

      // Detect MIME type from file extension to avoid 'application/octet-stream'
      String contentType = 'image/jpeg'; // default
      final extension = _slipImageName!.toLowerCase().split('.').last;
      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        contentType = 'image/jpeg';
      }

      debugPrint('📎 File: $_slipImageName, Type: $contentType');

      // Add image file from bytes (for web compatibility)
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _slipImageBytes!,
          filename: _slipImageName!,
          contentType: MediaType.parse(contentType),
        ),
      );

      request.headers.addAll(headers);

      // Send request
      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        debugPrint('✅ Upload success: $responseBody');

        final jsonResponse = jsonDecode(responseBody);
        setState(() {
          _slipImageBytes = null;
          _slipImageName = null;
          intentsAttacheSlipNo =
              jsonResponse['slip_no'] ?? intentsAttacheSlipNo;
        });

        if (!mounted) return false;
        String _toU16(String? v) => (v ?? '0').trim();

        String? custno16Bit = _toU16('$custno').toString();
        final ren16Bit = _toU16('$renTal_user');

        // User requirement: "await redPaymentIntents(); ให้เสร็จก่อน"
        // await Future.delayed(const Duration(
        //     seconds: 2)); // Simulate loading delay
        // await redPaymentIntents(
        //     cusno: custno16Bit, propertyno: ren16Bit.toString() ?? '');
        // Reload payment intents to reflect updated status
        // await redPaymentIntents();
        return true;
      } else {
        final errorBody = await response.stream.bytesToString();
        debugPrint('❌ Upload failed: ${response.statusCode} - $errorBody');

        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Upload error: $e\n$stackTrace');

      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
    return false;
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'PENDING':
        return 'รอตรวจสอบ';
      case 'APPROVED':
        return 'อนุมัติแล้ว';
      case 'REJECTED':
        return 'ไม่อนุมัติ';
      default:
        return status ?? '-';
    }
  }

  Widget _slipInfoRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                  fontFamily: Font_.Fonts_T,
                  color: Colors.black54,
                  fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              val,
              style: TextStyle(
                  fontFamily: Font_.Fonts_T,
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showQrDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        final GlobalKey dialogQrKey = GlobalKey();
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: EdgeInsets.zero,
          title: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.cuslang == 'EN'
                            ? "Please upload proof of payment."
                            : "กรุณาแนบหลักฐานการโอนเงิน",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: Font_.Fonts_T),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                (activeQrSessionSoftExpire == null ||
                        activeQrSessionSoftExpire!.isEmpty)
                    ? Container(height: 0)
                    : SizedBox(
                        // height: 40,
                        child: Row(
                          children: [
                            // Text(
                            //   'chao-$QR_Ref1',
                            //   style: TextStyle(
                            //     color: Colors.grey,
                            //     fontFamily: Font_.Fonts_T,
                            //   ),
                            // ),
                            // const SizedBox(width: 6),
                            // Countdown + Progress (อ้างอิงวินาทีเดียว)
                            Expanded(
                              child: StreamBuilder<int>(
                                stream: _timerStream,
                                initialData: secondsUntilExpire(),
                                builder: (_, snap) {
                                  final secs = (snap.data ?? 0);
                                  final clamped = secs < 0 ? 0 : secs;
                                  final prog = _totalSecs > 0
                                      ? (clamped / _totalSecs).clamp(0.0, 1.0)
                                      : 0.0;

                                  final label = (clamped == 0
                                      ? 'หมดอายุแล้ว'
                                      : 'หมดอายุ ${_hhmmssFromSecs(clamped)}');

                                  // ถ้าหมดอายุแล้ว – ปิดแผ่น + เสนอให้ต่ออายุ
                                  // แต่ถ้ามีสลิปแล้ว (uploadedSlipData != null) ไม่ต้องปิด

                                  // Restore this block
                                  if (clamped == 0 &&
                                      _uploadedSlipData == null &&
                                      !_expireDialogShown) {
                                    Future.microtask(() async {
                                      if (!mounted) return;
                                      setState(() => _expireDialogShown = true);
                                      PanaraConfirmDialog.showAnimatedGrow(
                                        context,
                                        title: widget.cuslang == 'EN'
                                            ? "Expired"
                                            : "หมดเวลา",
                                        message: widget.cuslang == 'EN'
                                            ? "Payment time expired. If paid, please attach proof. If not, please renew QR."
                                            : "หมดเวลาการชำระแล้ว หากชำระแล้วกรุณาแนบหลักฐานและชำระและยืนยัน หรือยังไม่ได้ชำระกรุณากดแสดง QR อีกครั้ง",
                                        confirmButtonText:
                                            widget.cuslang == 'EN'
                                                ? "Attach Proof"
                                                : "แนบหลักฐาน",
                                        cancelButtonText: widget.cuslang == 'EN'
                                            ? "Close"
                                            : "ปิด",
                                        onTapConfirm: () {
                                          Navigator.pop(context);
                                          _showPaymentConfirmationSheet(
                                              context);
                                        },
                                        onTapCancel: () {
                                          Navigator.pop(context);
                                        },
                                        panaraDialogType:
                                            PanaraDialogType.warning,
                                        barrierDismissible: true,
                                      );
                                    });
                                  }

                                  return Row(
                                    children: [
                                      Icon(
                                        clamped == 0
                                            ? Icons.timer_off
                                            : Icons.timer,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        label,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: Font_.Fonts_T,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
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
                      ),
              ],
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: ValueListenableBuilder<int>(
                  valueListenable: _qrUpdateTrigger,
                  builder: (context, value, child) {
                    return _QRBox(customKey: dialogQrKey);
                  }),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentConfirmationSheet(BuildContext parentContext) {
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
    (_intentsSlipData != null)
        ? showModalBottomSheet(
            isDismissible: false,
            context: parentContext,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (BuildContext context) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setStateSheet) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.cuslang == 'EN'
                                  ? 'Payment Confirmation'
                                  : 'ยืนยันการชำระเงิน',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.grey),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1),

                      Flexible(
                          child: SingleChildScrollView(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Instructions
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.orange.shade200),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.check_circle,
                                                  color: Colors.green.shade800),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  widget.cuslang == 'EN'
                                                      ? "Upload completed"
                                                      : "อัปโหลดเรียบร้อยแล้ว",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .orange.shade900,
                                                      fontFamily: Font_.Fonts_T,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    const SizedBox(height: 8),
                                    Card(
                                      child: Column(
                                        children: [
                                          _slipInfoRow(
                                              widget.cuslang == 'EN'
                                                  ? 'File'
                                                  : 'ไฟล์:',
                                              _intentsSlipData![
                                                      'original_filename'] ??
                                                  '-'),
                                          _slipInfoRow(
                                              widget.cuslang == 'EN'
                                                  ? 'Amount'
                                                  : 'จำนวนเงิน:',
                                              '${_intentsSlipData!['amount']} ${_intentsSlipData!['currency'] ?? ''}'),
                                          _slipInfoRow(
                                              widget.cuslang == 'EN'
                                                  ? 'D'
                                                  : 'วันที่:',
                                              _intentsSlipData![
                                                      'transfer_date'] ??
                                                  '-'),
                                          _slipInfoRow(
                                              'Ref:',
                                              _intentsSlipData![
                                                      'transfer_ref_no'] ??
                                                  '-'),
                                          _slipInfoRow(
                                              widget.cuslang == 'EN'
                                                  ? 'Status'
                                                  : 'สถานะ:',
                                              _getStatusText(
                                                  _intentsSlipData!['status'] ??
                                                      '')),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: () async {
                                                  // Reset uploaded data to allow new upload
                                                  setState(() {
                                                    _uploadedSlipData = null;
                                                  });
                                                  // Trigger file picker
                                                  final success =
                                                      await _pickSlipImage();
                                                  if (success &&
                                                      _slipImageBytes != null) {
                                                    if (!mounted) return;
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (BuildContext
                                                          context) {
                                                        return Center(
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child:
                                                                    CircleAvatar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  radius:
                                                                      30, // ปรับขนาดของ CircleAvatar
                                                                  backgroundImage:
                                                                      AssetImage(
                                                                          'assets/images/Icon-chao.png'),
                                                                ),
                                                              ),
                                                              LoadingAnimationWidget
                                                                  .inkDrop(
                                                                color: Colors
                                                                    .green,
                                                                size: 70,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                    final successUp =
                                                        await _uploadSlipImage(
                                                            amtRawSlip: sum_amt
                                                                .toString());
                                                    if (mounted) {
                                                      Navigator.of(context)
                                                          .pop(); // Close dialog
                                                      if (successUp) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(widget
                                                                        .cuslang ==
                                                                    'EN'
                                                                ? 'Slip upload successful!'
                                                                : 'อัปโหลดสลิปสำเร็จ!'),
                                                            backgroundColor:
                                                                Colors.green,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  }
                                                },
                                                icon: const Icon(Icons.refresh,
                                                    size: 16),
                                                label: Text(
                                                    widget.cuslang == 'EN'
                                                        ? 'Re-attach'
                                                        : 'แนบอีกครั้ง',
                                                    style: TextStyle(
                                                        fontSize: 12)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.grey,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              ElevatedButton.icon(
                                                onPressed: () async {
                                                  final response =
                                                      await getSlipPreviewPaymentIntents(
                                                          slipUuid:
                                                              intentsAttacheSlipNo ??
                                                                  "");
                                                  if (!mounted) return;

                                                  await showDialog<void>(
                                                    context: context,
                                                    barrierDismissible: true,
                                                    builder:
                                                        (BuildContext context) {
                                                      final isSuccess = response !=
                                                              null &&
                                                          response.statusCode >=
                                                              200 &&
                                                          response.statusCode <
                                                              300;

                                                      return AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        backgroundColor:
                                                            AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                        titlePadding:
                                                            const EdgeInsets
                                                                .all(0.0),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        actionsPadding:
                                                            const EdgeInsets
                                                                .all(6.0),
                                                        title: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      16.0,
                                                                  vertical:
                                                                      12.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                widget.cuslang ==
                                                                        'EN'
                                                                    ? 'Payment Slip'
                                                                    : 'หลักฐานการโอนเงิน',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T),
                                                              ),
                                                              IconButton(
                                                                icon: Icon(
                                                                    Icons.close,
                                                                    color: Colors
                                                                        .grey),
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        content:
                                                            SingleChildScrollView(
                                                          child: ListBody(
                                                            children: <Widget>[
                                                              if (isSuccess &&
                                                                  response
                                                                      .bodyBytes
                                                                      .isNotEmpty)
                                                                Image.memory(
                                                                  response
                                                                      .bodyBytes,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                )
                                                              else
                                                                Column(
                                                                  children: [
                                                                    const Icon(
                                                                        Icons
                                                                            .broken_image,
                                                                        size:
                                                                            50,
                                                                        color: Colors
                                                                            .grey),
                                                                    const SizedBox(
                                                                        height:
                                                                            10),
                                                                    Text(
                                                                      widget.cuslang ==
                                                                              'EN'
                                                                          ? 'Unable to load image\n(Status: ${response?.statusCode ?? 'N/A'})'
                                                                          : 'ไม่สามารถโหลดรูปภาพได้\n(Status: ${response?.statusCode ?? 'N/A'})',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ],
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        // actions: [
                                                        //   if (isSuccess &&
                                                        //       response.bodyBytes
                                                        //           .isNotEmpty)
                                                        //     TextButton.icon(
                                                        //       icon: const Icon(
                                                        //           Icons.download,
                                                        //           size: 16,
                                                        //           color: Colors.blue),
                                                        //       label: const Text(
                                                        //           'ดาวน์โหลด',
                                                        //           style: TextStyle(
                                                        //               fontFamily: Font_
                                                        //                   .Fonts_T,
                                                        //               color: Colors
                                                        //                   .blue)),
                                                        //       onPressed: () {
                                                        //         final blob =
                                                        //             html.Blob([
                                                        //           response.bodyBytes
                                                        //         ]);
                                                        //         final url = html.Url
                                                        //             .createObjectUrlFromBlob(
                                                        //                 blob);
                                                        //         final filename =
                                                        //             _intentsSlipData![
                                                        //                     'original_filename'] ??
                                                        //                 'slip.jpg';
                                                        //         html.AnchorElement(
                                                        //             href: url)
                                                        //           ..setAttribute(
                                                        //               "download",
                                                        //               filename)
                                                        //           ..click();
                                                        //         html.Url
                                                        //             .revokeObjectUrl(
                                                        //                 url);
                                                        //       },
                                                        //     ),
                                                        //   TextButton(
                                                        //     child: const Text('ปิด',
                                                        //         style: TextStyle(
                                                        //             fontFamily: Font_
                                                        //                 .Fonts_T)),
                                                        //     onPressed: () {
                                                        //       Navigator.of(context)
                                                        //           .pop();
                                                        //     },
                                                        //   ),
                                                        // ],
                                                      );
                                                    },
                                                  );
                                                },
                                                icon: const Icon(
                                                    Icons.visibility,
                                                    size: 16),
                                                label: Text(
                                                    widget.cuslang == 'EN'
                                                        ? 'View Slip'
                                                        : 'ดูหลักฐาน',
                                                    style: TextStyle(
                                                        fontSize: 12)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.black,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ])))
                    ],
                  ),
                );
              });
            })
        : showModalBottomSheet(
            isDismissible: false,
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (BuildContext context) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setStateSheet) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.cuslang == 'EN'
                                  ? 'Payment Confirmation'
                                  : 'ยืนยันการชำระเงิน',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.grey),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),

                      Divider(height: 1),

                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Instructions
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.orange.shade200),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.info_outline,
                                            color: Colors.orange.shade800),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            widget.cuslang == 'EN'
                                                ? "Please upload proof of payment to complete the transaction."
                                                : "กรุณาแนบหลักฐานการโอนเงินเพื่อดำเนินการให้เสร็จสมบูรณ์",
                                            style: TextStyle(
                                                color: Colors.orange.shade900,
                                                fontFamily: Font_.Fonts_T,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(children: [
                                Text(
                                  widget.cuslang == 'EN'
                                      ? "Upload Slip"
                                      : "อัปโหลดสลิป",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Font_.Fonts_T,
                                      fontSize: 16),
                                ),
                              ]),
                              // Upload Section Check
                              // Row(
                              //   children: [
                              //     Text(
                              //       widget.cuslang == 'EN'
                              //           ? "Upload Slip"
                              //           : "อัปโหลดสลิป",
                              //       style: TextStyle(
                              //           fontWeight: FontWeight.bold,
                              //           fontFamily: Font_.Fonts_T,
                              //           fontSize: 16),
                              //     ),
                              //     SizedBox(width: 10),
                              //     InkWell(
                              //       child: chip(
                              //           widget.cuslang == 'EN'
                              //               ? 'Show QR Code'
                              //               : 'แสดง QR Code',
                              //           Colors.orange.withOpacity(.08),
                              //           Colors.orange.shade700),
                              //       onTap: () async {
                              //         // Show Loading
                              //         showDialog(
                              //           context: context,
                              //           barrierDismissible: false,
                              //           builder: (BuildContext context) {
                              //             return const Center(
                              //                 child:
                              //                     CircularProgressIndicator());
                              //           },
                              //         );

                              //         // Call QrGenRef: It handles checking expiry, renewing if needed, or loading existing Valid QR
                              //         await QrGenRef();

                              //         // Close Loading
                              //         if (mounted) {
                              //           Navigator.of(context).pop();
                              //         }

                              //         // Show QR Dialog (UI relies on state updated by QrGenRef)
                              //         if (mounted) {
                              //           _showQrDialog(context);
                              //         }
                              //       },
                              //     ),
                              //     Spacer(),
                              //     InkWell(
                              //       child: Icon(Icons.info_outline,
                              //           color: Colors.blueGrey, size: 20),
                              //       onTap: () async {
                              //         Widget _howToBoxExpired() {
                              //           Widget step(int i, String t) => Padding(
                              //                 padding:
                              //                     const EdgeInsets.symmetric(
                              //                         vertical: 4),
                              //                 child: Row(
                              //                   crossAxisAlignment:
                              //                       CrossAxisAlignment.start,
                              //                   children: [
                              //                     Container(
                              //                       width: 26,
                              //                       height: 26,
                              //                       alignment: Alignment.center,
                              //                       decoration: BoxDecoration(
                              //                         color: Colors.orange
                              //                             .withOpacity(.08),
                              //                         borderRadius:
                              //                             BorderRadius.circular(
                              //                                 999),
                              //                         border: Border.all(
                              //                             color: Colors.orange
                              //                                 .withOpacity(.25),
                              //                             width: .7),
                              //                       ),
                              //                       child: Text('$i',
                              //                           style: TextStyle(
                              //                               fontFamily:
                              //                                   Font_.Fonts_T,
                              //                               fontWeight:
                              //                                   FontWeight.w900,
                              //                               color: Colors.orange
                              //                                   .shade700)),
                              //                     ),
                              //                     const SizedBox(width: 10),
                              //                     Expanded(
                              //                         child: Text(t,
                              //                             style: const TextStyle(
                              //                                 fontFamily:
                              //                                     Font_.Fonts_T,
                              //                                 fontSize: 13.5))),
                              //                   ],
                              //                 ),
                              //               );

                              //           return Container(
                              //             decoration: BoxDecoration(
                              //               color: Colors.white,
                              //               borderRadius:
                              //                   BorderRadius.circular(16),
                              //               border: Border.all(
                              //                   color: Colors.black12,
                              //                   width: .5),
                              //               boxShadow: [
                              //                 BoxShadow(
                              //                     color: Colors.black
                              //                         .withOpacity(.04),
                              //                     blurRadius: 12,
                              //                     offset: const Offset(0, 6))
                              //               ],
                              //             ),
                              //             padding: const EdgeInsets.fromLTRB(
                              //                 12, 10, 12, 12),
                              //             child: Column(
                              //               crossAxisAlignment:
                              //                   CrossAxisAlignment.start,
                              //               children: [
                              //                 Text(
                              //                     widget.cuslang == 'EN'
                              //                         ? 'Please follow the steps below to restart the payment.'
                              //                         : 'กรุณาทำตามขั้นตอนด้านล่างเพื่อเริ่มการชำระเงินใหม่',
                              //                     style: const TextStyle(
                              //                         fontFamily: Font_.Fonts_T,
                              //                         fontWeight:
                              //                             FontWeight.w800,
                              //                         fontSize: 15)),
                              //                 const SizedBox(height: 10),
                              //                 step(
                              //                     1,
                              //                     widget.cuslang == 'EN'
                              //                         ? 'If you have already made the payment, please attach the proof of transfer and press "Confirm Payment" below.'
                              //                         : 'หากชำระแล้วกรุณาแนบหลักฐานการโอนเงิน และกด "ยืนยันการชำระเงิน" ด้านล่าง'),
                              //                 step(
                              //                     2,
                              //                     widget.cuslang == 'EN'
                              //                         ? 'If you have not made the payment and the payment reference number has expired, please cancel the payment reference number and start a new payment.'
                              //                         : 'หากยังไม่ชำระ และเลขที่ชำระเงินหมดอายุ ให้กดยกเลิกเลขที่รายการชำระเงิน แล้วกดเริ่มต้นการชำระเงินใหม่'),
                              //                 step(
                              //                     3,
                              //                     widget.cuslang == 'EN'
                              //                         ? 'Once you have attached the proof of transfer, you will not be able to cancel the payment.'
                              //                         : 'หากแนบหลักฐานการโอนเงินแล้ว จะไม่สามารถยกเลิกการชำระเงินได้'),
                              //               ],
                              //             ),
                              //           );
                              //         }

                              //         showDialog(
                              //           context: context,
                              //           barrierDismissible: true,
                              //           builder: (BuildContext ctx) {
                              //             return AlertDialog(
                              //               shape: RoundedRectangleBorder(
                              //                   borderRadius:
                              //                       BorderRadius.circular(16)),
                              //               contentPadding: EdgeInsets.zero,
                              //               content: Container(
                              //                 width: double.maxFinite,
                              //                 child: Column(
                              //                   mainAxisSize: MainAxisSize.min,
                              //                   children: [
                              //                     Padding(
                              //                       padding: const EdgeInsets
                              //                               .symmetric(
                              //                           horizontal: 12.0,
                              //                           vertical: 2.0),
                              //                       child: Row(
                              //                         mainAxisAlignment:
                              //                             MainAxisAlignment
                              //                                 .spaceBetween,
                              //                         children: [
                              //                           Expanded(
                              //                             child: Text(
                              //                               widget.cuslang ==
                              //                                       'EN'
                              //                                   ? "Cancel Payment"
                              //                                   : "ยกเลิกการชำระเงิน",
                              //                               style: TextStyle(
                              //                                   fontSize: 18,
                              //                                   fontWeight:
                              //                                       FontWeight
                              //                                           .bold,
                              //                                   fontFamily: Font_
                              //                                       .Fonts_T),
                              //                             ),
                              //                           ),
                              //                           IconButton(
                              //                             icon: Icon(
                              //                                 Icons.close,
                              //                                 color:
                              //                                     Colors.grey),
                              //                             onPressed: () =>
                              //                                 Navigator.pop(
                              //                                     context),
                              //                           ),
                              //                         ],
                              //                       ),
                              //                     ),
                              //                     _howToBoxExpired(), // Footer Action
                              //                     Container(
                              //                       padding: EdgeInsets.all(16),
                              //                       decoration: BoxDecoration(
                              //                         color: Colors.white,
                              //                         boxShadow: [
                              //                           BoxShadow(
                              //                             color: Colors.grey
                              //                                 .withOpacity(0.1),
                              //                             spreadRadius: 1,
                              //                             blurRadius: 5,
                              //                             offset: Offset(0, -3),
                              //                           ),
                              //                         ],
                              //                       ),
                              //                       child: SizedBox(
                              //                         width: double.infinity,
                              //                         height: 60,
                              //                         child: Center(
                              //                           child: _SlideToConfirm(
                              //                             color: Colors.red,
                              //                             label: widget
                              //                                         .cuslang ==
                              //                                     'EN'
                              //                                 ? 'Confirm Cancellation and Restart'
                              //                                 : 'ยืนยันการยกเลิกและเริ่มต้นใหม่',
                              //                             enabled:
                              //                                 base64_Slip ==
                              //                                         null ||
                              //                                     base64_Slip ==
                              //                                         '',
                              //                             onConfirmation:
                              //                                 () async {
                              //                               // Confirm Logic DeletePaymentIntents_UuidCanceled
                              //                               try {
                              //                                 final prefs =
                              //                                     await SharedPreferences
                              //                                         .getInstance();
                              //                                 final ren = prefs
                              //                                     .getString(
                              //                                         'renTalSer');

                              //                                 final ren16Bit =
                              //                                     _toU16('$ren')
                              //                                         .toString();

                              //                                 // custno ใช้ตัวเดียว (ทุก invoice ลูกค้าเดียวกัน)
                              //                                 // ✅ Fix: ถ้า _TransModels ว่าง (เพราะไม่เจอข้อมูล) ให้ใช้ custno ที่ login มาแทน
                              //                                 final String
                              //                                     custnoLocal =
                              //                                     _TransModels
                              //                                             .isNotEmpty
                              //                                         ? '${_TransModels.first.custno ?? ''}'
                              //                                         : (prefs.getString(
                              //                                                 'custno') ??
                              //                                             '');

                              //                                 final custno16Bit =
                              //                                     _toU16(custnoLocal)
                              //                                         .toString();
                              //                                 final response = await DeletePaymentIntents_UuidCanceled(
                              //                                     cusNo:
                              //                                         custno16Bit,
                              //                                     propertyNo:
                              //                                         ren16Bit,
                              //                                     intentsUuid:
                              //                                         numinvoice
                              //                                             .toString(),
                              //                                     bankMerchantId:
                              //                                         bankMerchantId ??
                              //                                             0);
                              //                                 if (response !=
                              //                                         null &&
                              //                                     response.statusCode >=
                              //                                         200 &&
                              //                                     response.statusCode <
                              //                                         300) {
                              //                                   Fluttertoast.showToast(
                              //                                       timeInSecForIosWeb:
                              //                                           3,
                              //                                       msg: widget.cuslang ==
                              //                                               'EN'
                              //                                           ? "Payment cancelled successfully."
                              //                                           : 'ยกเลิกการชำระเงินสำเร็จแล้ว',
                              //                                       backgroundColor:
                              //                                           Colors
                              //                                               .black,
                              //                                       textColor:
                              //                                           Colors
                              //                                               .white,
                              //                                       webPosition:
                              //                                           "center",
                              //                                       webBgColor:
                              //                                           "#000000",
                              //                                       toastLength:
                              //                                           Toast
                              //                                               .LENGTH_SHORT);

                              //                                   if (!mounted)
                              //                                     return;
                              //                                   // Navigator.pushAndRemoveUntil(
                              //                                   //     context,
                              //                                   //     MaterialPageRoute(
                              //                                   //         builder:
                              //                                   //             (context) {
                              //                                   //   return paymentMainV2InvAll(
                              //                                   //     mainScreenAnimation:
                              //                                   //         widget
                              //                                   //             .mainScreenAnimation,
                              //                                   //     mainScreenAnimationController:
                              //                                   //         widget
                              //                                   //             .mainScreenAnimationController,
                              //                                   //     teNantModel: widget
                              //                                   //         .teNantModel,
                              //                                   //     customerModel: [],
                              //                                   //     cuslang: widget
                              //                                   //         .cuslang,
                              //                                   //   );
                              //                                   // }),
                              //                                   //     (route) =>
                              //                                   //         false);

                              //                                   Navigator.pushAndRemoveUntil(
                              //                                       context,
                              //                                       MaterialPageRoute(
                              //                                           builder:
                              //                                               (context) {
                              //                                     return FitnessAppHomeScreen(
                              //                                         custno_s:
                              //                                             custno);
                              //                                   }),
                              //                                       (route) =>
                              //                                           false);
                              //                                   // Navigator.pushAndRemoveUntil(
                              //                                   //     context,
                              //                                   //     MaterialPageRoute(
                              //                                   //         builder:
                              //                                   //             (context) {
                              //                                   //   return paymentMainV2InvAll(
                              //                                   //     mainScreenAnimationController:
                              //                                   //         widget
                              //                                   //             .mainScreenAnimationController,
                              //                                   //     mainScreenAnimation:
                              //                                   //         widget
                              //                                   //             .mainScreenAnimation,
                              //                                   //     teNantModel: widget
                              //                                   //         .teNantModel,
                              //                                   //     cuslang: widget
                              //                                   //         .cuslang,
                              //                                   //   );
                              //                                   // }),
                              //                                   //     (route) =>
                              //                                   //         false);
                              //                                 } else {
                              //                                   Navigator.pop(
                              //                                       context); // Close Dialog
                              //                                   Navigator.pop(
                              //                                       context); // Close Sheet
                              //                                 }
                              //                               } catch (e) {
                              //                                 debugPrint(
                              //                                     '❌ Cancel Payment Exception: $e');
                              //                                 Navigator.pop(
                              //                                     context); // Close Dialog
                              //                                 Navigator.pop(
                              //                                     context); // Close Sheet
                              //                               }
                              //                             },
                              //                           ),
                              //                         ),
                              //                       ),
                              //                     )
                              //                   ],
                              //                 ),
                              //               ),
                              //             );
                              //           },
                              //         );
                              //       },
                              //     ),
                              //   ],
                              // ),

                              SizedBox(height: 10),

                              GestureDetector(
                                onTap: () async {
                                  if (_isProcessingLink) return;
                                  setState(() => _isProcessingLink = true);

                                  try {
                                    // await uploadFile_Slip();
                                    final success = await _pickSlipImage();

                                    if (!mounted) return;

                                    // Force rebuild of the sheet to show the image
                                    setStateSheet(() {});

                                    // Show auto dialog removed - using Slider instead
                                    if (success) {
                                      Navigator.of(context)
                                          .pop(); // Close dialog
                                      _showSlideConfirmDialog(); // No context arg
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isProcessingLink = false);
                                    }
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.grey.shade300, width: 2),
                                  ),
                                  child: base64_Slip == null
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.cloud_upload_outlined,
                                              size: 60,
                                              color: Colors.blue.shade300,
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              widget.cuslang == 'EN'
                                                  ? "Tap to upload payment slip"
                                                  : "กดเพื่ออัปโหลดสลิป",
                                              style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontFamily: Font_.Fonts_T,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "JPG, PNG (Max 10MB)",
                                              style: TextStyle(
                                                  color: Colors.grey.shade400,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              InteractiveViewer(
                                                panEnabled: true,
                                                minScale: 0.1,
                                                maxScale: 4.0,
                                                child: Image.memory(
                                                  base64Decode(
                                                      base64_Slip.toString()),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Container(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                child: Center(
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 8),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.8),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.edit,
                                                            size: 16),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          widget.cuslang == 'EN'
                                                              ? "Change"
                                                              : "เปลี่ยนรูป",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        widget.cuslang == 'EN'
                            ? "Total amount to be paid: ${nFormat.format(double.parse(Form_payment1.text ?? "0"))} THB"
                            : "รวมจำนวนเงินที่ต้องชำระ: ${nFormat.format(double.parse(Form_payment1.text ?? "0"))} บาท",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                      SizedBox(height: 2),
                      // Footer Action
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, -3),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: Center(
                            child: _SlideToConfirm(
                              label: widget.cuslang == 'EN'
                                  ? 'Slide to Confirm'
                                  : 'เลื่อนเพื่อยืนยันการชำระเงิน1234',
                              enabled: base64_Slip != null,
                              onConfirmation: () async {
                                if (_isProcessingLink) return;
                                setStateSheet(() => _isProcessingLink = true);

                                try {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return Center(
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: const CircleAvatar(
                                                backgroundColor:
                                                    Colors.transparent,
                                                radius: 30,
                                                backgroundImage: AssetImage(
                                                    'assets/images/Icon-chao.png'),
                                              ),
                                            ),
                                            LoadingAnimationWidget.inkDrop(
                                              color: Colors.green,
                                              size: 70,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );

                                  // Confirm Logic
                                  List newValuePDFimg = [];
                                  for (int index = 0; index < 1; index++) {
                                    if ((renTalModels.isNotEmpty) &&
                                        (renTalModels[0].imglogo?.trim() ??
                                                '') !=
                                            '') {
                                      newValuePDFimg.add(
                                          '${MyConstant().domain_chao}/files/$foder/logo/${renTalModels[0].imglogo?.trim() ?? ''}');
                                    }
                                  }

                                  // sucress(); // Removed early call
                                  await OKuploadFile_Slip(newValuePDFimg);
                                  await in_Trans_invoice(newValuePDFimg,
                                      showSuccess: false);

                                  if (!mounted) return;

                                  // Close Loading Dialog
                                  Navigator.of(context).pop();

                                  // Close Sheet
                                  Navigator.pop(context);

                                  // Show Success Dialog
                                  sucress(onDismiss: () {
                                    // Use a valid context for navigation
                                    Navigator.pushAndRemoveUntil(parentContext,
                                        MaterialPageRoute(builder: (context) {
                                      // Fix potential null safety issue by falling back to empty string or handling null
                                      // FitnessAppHomeScreen member 'custno_s' is nullable, so passing null is fine.
                                      // But if 'Unexpected null value' occurred, maybe it was because of ! usage elsewhere or inside that widget.
                                      // I will use ?.cid and ensure no bang operator is involved.
                                      return FitnessAppHomeScreen(
                                          custno_s: widget.teNantModel?[0].cid);
                                    }), (route) => false);
                                  });
                                } catch (e) {
                                  // Close Loading Dialog
                                  Navigator.of(context).pop();

                                  _showMyDialogPay_Error(widget.cuslang == 'EN'
                                      ? "An error occurred. Please check the information. Please try again!"
                                      : 'เกิดข้อผิดพลาด ตรวจสอบความถูกต้อง กรุณาลองอีกครั้ง!');
                                } finally {
                                  if (mounted) {
                                    setStateSheet(
                                        () => _isProcessingLink = false);
                                  }
                                }
                              },
                              // onConfirmation: () async {
                              //   // Reset uploaded data to allow new upload
                              //   setState(() {
                              //     _uploadedSlipData = null;
                              //   });
                              //   // Trigger file picker
                              //   // final success = await _pickSlipImage();
                              //   if (base64_Slip != null) {
                              //     if (!mounted) return;
                              //     showDialog(
                              //       context: context,
                              //       barrierDismissible: false,
                              //       builder: (BuildContext context) {
                              //         return const Center(
                              //           child: CircularProgressIndicator(),
                              //         );
                              //       },
                              //     );
                              //     final successUp = await _uploadSlipImage(
                              //         amtRawSlip: sum_amt.toString());
                              //     if (mounted) {
                              //       Navigator.of(context).pop(); // Close dialog
                              //       Navigator.pushAndRemoveUntil(context,
                              //           MaterialPageRoute(builder: (context) {
                              //         return FitnessAppHomeScreen(
                              //             custno_s: custno);
                              //       }), (route) => false);
                              //       if (successUp) {
                              //         Fluttertoast.showToast(
                              //             timeInSecForIosWeb: 3,
                              //             msg: widget.cuslang == 'EN'
                              //                 ? "Slip upload successful"
                              //                 : 'อัปโหลดสลิปสำเร็จ',
                              //             backgroundColor: Colors.black,
                              //             textColor: Colors.white,
                              //             webPosition: "center",
                              //             webBgColor: "#000000",
                              //             toastLength: Toast.LENGTH_SHORT);
                              //       }
                              //     }
                              //   }
                              //   // Confirm Logic
                              //   // List newValuePDFimg = [];
                              //   // for (int index = 0; index < 1; index++) {
                              //   //   if (renTalModels[0].imglogo!.trim() != '') {
                              //   //     newValuePDFimg.add(
                              //   //         '${MyConstant().domain_chao}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                              //   //   }
                              //   // }
                              //   // try {
                              //   //   sucress();
                              //   //   OKuploadFile_Slip(newValuePDFimg).then(
                              //   //       (value) => in_Trans_invoice(newValuePDFimg));
                              //   //   Navigator.pop(
                              //   //       context); // Close sheet after success
                              //   // } catch (e) {
                              //   //   _showMyDialogPay_Error(widget.cuslang == 'EN'
                              //   //       ? "An error occurred. Please check the information. Please try again!"
                              //   //       : 'เกิดข้อผิดพลาด ตรวจสอบความถูกต้อง กรุณาลองอีกครั้ง!');
                              //   // }
                              // },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              });
            });
  }

  Widget _howToBoxSlip({
    required String amount,
    Map<String, dynamic>? uploadedSlipData,
  }) {
    final bool hasUploadedSlip = uploadedSlipData != null;

    debugPrint('🔍 _howToBoxSlip called: hasUploadedSlip=$hasUploadedSlip');
    debugPrint('🔍 uploadedSlipData: $uploadedSlipData');

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('หลักฐานการชำระ',
            style: const TextStyle(
                fontFamily: Font_.Fonts_T,
                fontWeight: FontWeight.w800,
                fontSize: 15)),
        const SizedBox(height: 10),

        // Show uploaded slip info if exists
        if (hasUploadedSlip) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'อัปโหลดเรียบร้อยแล้ว',
                        style: TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _slipInfoRow(
                    'ไฟล์:', uploadedSlipData['original_filename'] ?? '-'),
                _slipInfoRow('จำนวนเงิน:',
                    '${uploadedSlipData['amount']} ${uploadedSlipData['currency'] ?? ''}'),
                _slipInfoRow(
                    'วันที่:', uploadedSlipData['transfer_date'] ?? '-'),
                _slipInfoRow(
                    'Ref:', uploadedSlipData['transfer_ref_no'] ?? '-'),
                _slipInfoRow(
                    'สถานะ:', _getStatusText(uploadedSlipData['status'] ?? '')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Reset uploaded data to allow new upload
                        setState(() {
                          _uploadedSlipData = null;
                        });
                        // Trigger file picker
                        final success = await _pickSlipImage();
                        if (success && _slipImageBytes != null) {
                          if (!mounted) return;
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        radius: 30, // ปรับขนาดของ CircleAvatar
                                        backgroundImage: AssetImage(
                                            'assets/images/Icon-chao.png'),
                                      ),
                                    ),
                                    LoadingAnimationWidget.inkDrop(
                                      color: Colors.green,
                                      size: 70,
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                          final successUp =
                              await _uploadSlipImage(amtRawSlip: amount);
                          if (mounted) {
                            Navigator.of(context).pop(); // Close dialog
                            if (successUp) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('อัปโหลดสลิปสำเร็จ!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('แนบอีกครั้ง',
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final response = await getSlipPreviewPaymentIntents(
                            slipUuid: intentsAttacheSlipNo ?? "");
                        if (!mounted) return;

                        await showDialog<void>(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            final isSuccess = response != null &&
                                response.statusCode >= 200 &&
                                response.statusCode < 300;

                            return AlertDialog(
                              title: const Text('หลักฐานการโอนเงิน',
                                  style: TextStyle(
                                      fontFamily: Font_.Fonts_T, fontSize: 16)),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    if (isSuccess &&
                                        response.bodyBytes.isNotEmpty)
                                      Image.memory(
                                        response.bodyBytes,
                                        fit: BoxFit.contain,
                                      )
                                    else
                                      Column(
                                        children: [
                                          const Icon(Icons.broken_image,
                                              size: 50, color: Colors.grey),
                                          const SizedBox(height: 10),
                                          Text(
                                            'ไม่สามารถโหลดรูปภาพได้\n(Status: ${response?.statusCode ?? 'N/A'})',
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              actions: [
                                if (isSuccess && response.bodyBytes.isNotEmpty)
                                  TextButton.icon(
                                    icon: const Icon(Icons.download,
                                        size: 16, color: Colors.blue),
                                    label: const Text('ดาวน์โหลด',
                                        style: TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            color: Colors.blue)),
                                    onPressed: () {
                                      final blob =
                                          html.Blob([response.bodyBytes]);
                                      final url =
                                          html.Url.createObjectUrlFromBlob(
                                              blob);
                                      final filename = uploadedSlipData[
                                              'original_filename'] ??
                                          'slip.jpg';
                                      html.AnchorElement(href: url)
                                        ..setAttribute("download", filename)
                                        ..click();
                                      html.Url.revokeObjectUrl(url);
                                    },
                                  ),
                                TextButton(
                                  child: const Text('ปิด',
                                      style:
                                          TextStyle(fontFamily: Font_.Fonts_T)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('ดูหลักฐาน',
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else
          ...[],
      ]),
    );
  }
}

// Custom Slide to Confirm Widget
class _SlideToConfirm extends StatefulWidget {
  final VoidCallback onConfirmation;
  final String label;
  final Color color;
  final bool enabled;

  const _SlideToConfirm({
    Key? key,
    required this.onConfirmation,
    required this.label,
    this.color = Colors.green,
    this.enabled = true,
  }) : super(key: key);

  @override
  __SlideToConfirmState createState() => __SlideToConfirmState();
}

class __SlideToConfirmState extends State<_SlideToConfirm> {
  double _position = 0.0;
  bool _confirmed = false;
  final double _height = 55.0;
  final double _handleWidth = 55.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxDrag = maxWidth - _handleWidth;

        return Container(
          height: _height,
          width: maxWidth,
          decoration: BoxDecoration(
            color: widget.enabled
                ? widget.color.withOpacity(0.2)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.enabled ? widget.color : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontFamily: Font_.Fonts_T,
                    fontSize: 16,
                  ),
                ),
              ),
              if (!_confirmed)
                Positioned(
                  left: _position,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (!widget.enabled) return;
                      setState(() {
                        _position += details.delta.dx;
                        _position = _position.clamp(0.0, maxDrag);
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      if (!widget.enabled) return;
                      if (_position >= maxDrag * 0.85) {
                        setState(() {
                          _position = maxDrag;
                          _confirmed = true;
                        });
                        widget.onConfirmation();
                      } else {
                        setState(() {
                          _position = 0.0;
                        });
                      }
                    },
                    child: Container(
                      height: _height,
                      width: _handleWidth,
                      decoration: BoxDecoration(
                        color: widget.enabled ? widget.color : Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              if (_confirmed)
                Positioned(
                  right: 0,
                  child: Container(
                    height: _height,
                    width: _height,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}

// Top-level class for params
class MergeParams {
  final List<Uint8List> images;
  final String? ref1;
  final String? ref2;
  final String? ref3;
  final String? totalBills;
  final String? activeQrSessionSoftExpire;
  final String? lateFee;
  final String? qr;
  final String? bankname;
  final String? banknumber;
  MergeParams({
    required this.images,
    this.ref1,
    this.ref2,
    this.ref3,
    this.totalBills,
    this.activeQrSessionSoftExpire,
    this.lateFee,
    this.qr,
    this.bankname,
    this.banknumber,
  });
}

// Top-level functions for isolate
int _measureTextWidth(img.BitmapFont font, String text) {
  int width = 0;
  for (var codePoint in text.runes) {
    if (font.characters.containsKey(codePoint)) {
      width += font.characters[codePoint]!.xAdvance;
    }
  }
  return width;
}

int _isolateCenterX(img.Image image, String text, img.BitmapFont font) {
  final w = _measureTextWidth(font, text);
  return ((image.width - w) / 2).round();
}

String _isolateFullWidthLineByChar(int width, img.BitmapFont font, String ch) {
  final cw = _measureTextWidth(font, ch);
  if (cw <= 0) return '';
  final count = (width / cw).floor().clamp(1, 99999);
  return List.filled(count, ch).join();
}

String _isolateDoubleLine(int width, img.BitmapFont font) =>
    _isolateFullWidthLineByChar(width, font, '=');

// Background Isolate Function
Future<Uint8List?> _processMergeImages(MergeParams params) async {
  try {
    const int maxWidth = 450;

    // Fonts (large/small)
    final fontTitle = img.arial24; // Big header
    final fontBody = img.arial14; // Small list
    final fontMono = img.arial14; // Mono for separator line

    // Layout
    const int padX = 24;
    const int padTop = 18;
    const int padBottom = 18;
    const int lineGap = 6;
    final int titleLineH = fontTitle.lineHeight + lineGap;
    final int bodyLineH = fontBody.lineHeight + lineGap;

    // Decode + Resize to know total height
    final decodedImages = <img.Image>[];
    int imagesHeight = 0;

    for (final bytes in params.images) {
      var d = img.decodeImage(bytes); // Use robust format detection
      if (d == null) continue;

      // Skip resize if already smaller than maxWidth, or use fast nearest interpretation
      if (d.width > maxWidth) {
        d = img.copyResize(d,
            width: maxWidth, interpolation: img.Interpolation.nearest);
      }
      decodedImages.add(d);
      imagesHeight += d.height;
    }
    if (decodedImages.isEmpty) return null;

    // Prepare footer content
    final nowStr = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
    final nowActiveQr = params.activeQrSessionSoftExpire != null
        ? params.activeQrSessionSoftExpire
        : '-';
    final refs = <String>[];
    if (params.ref1?.isNotEmpty ?? false) refs.add('ref: ${params.ref1}');
    if (params.ref2?.isNotEmpty ?? false) refs.add('system: chaopertyuser');
    if (params.lateFee?.isNotEmpty ?? false)
      refs.add('latefee: ${params.lateFee}');
    if (params.totalBills?.isNotEmpty ?? false)
      refs.add('total: ${params.totalBills}');
    // if (params.ref3?.isNotEmpty ?? false) refs.add('ref3: ${params.ref3}');

    final hasFooter = refs.isNotEmpty;

    // Dynamic Footer Height
    int footerHeight = 0;
    if (hasFooter) {
      // Footer structure:
      // Top Double Line
      // Title
      // DateLines (2 lines)
      // Middle Double Line
      // Refs
      // Bottom Double Line
      // QR Section (if exists)

      int qrHeight = 0;
      if (params.qr != null && params.qr!.isNotEmpty) {
        qrHeight = 80 + bodyLineH; // QR + spacing
      }

      footerHeight = padTop +
          bodyLineH + // Top Double Line
          titleLineH + // Title
          (2 * bodyLineH) + // Date lines
          bodyLineH + // Middle Double Line
          (refs.length * bodyLineH) + // Refs
          bodyLineH + // Bottom Double Line
          qrHeight +
          padBottom;
    }

    final merged =
        img.Image(width: maxWidth, height: imagesHeight + footerHeight);

    // White background
    img.fill(merged, color: img.ColorRgb8(255, 255, 255));

    // Place images
    int y = 0;
    for (final im in decodedImages) {
      img.compositeImage(merged, im, dstX: 0, dstY: y);
      y += im.height;
    }

    // Draw footer
    if (hasFooter) {
      int textY = imagesHeight + padTop;

      // Draw "Receipt Frame" around footer (black line)
      const int framePad = 8;
      final int frameX1 = framePad;
      final int frameY1 = imagesHeight + framePad;
      final int frameX2 = merged.width - framePad - 1;
      final int frameY2 = merged.height - framePad - 1;
      img.drawRect(
        merged,
        x1: frameX1,
        y1: frameY1,
        x2: frameX2,
        y2: frameY2,
        color: img.ColorRgb8(0, 0, 0),
      );

      // Full width double line (inside frame => minus padX both sides)
      final int innerWidth = merged.width - (padX * 2);
      final line = _isolateDoubleLine(innerWidth, fontMono);

      // Top double line (center)
      img.drawString(
        merged,
        line,
        font: fontMono,
        x: padX,
        y: textY,
        color: img.ColorRgb8(0, 0, 0),
      );
      textY += bodyLineH;

      // Big Title (center)
      const title = 'REFERENCE SYSTEM';

      img.drawString(
        merged,
        title,
        font: fontTitle,
        x: _isolateCenterX(merged, title, fontTitle),
        y: textY,
        color: img.ColorRgb8(0, 0, 0),
      );
      textY += titleLineH;
      // Date Section (Restored standard layout)
      // int textStartY = textY; // No longer needed for side-by-side

      final dateLine = 'upload at: $nowStr';
      img.drawString(
        merged,
        dateLine,
        font: fontBody,
        x: padX,
        y: textY,
        color: img.ColorRgb8(0, 0, 0),
      );
      textY += bodyLineH;

      final dateLine2 = 'expires at: $nowActiveQr';
      img.drawString(
        merged,
        dateLine2,
        font: fontBody,
        x: padX,
        y: textY,
        color: img.ColorRgb8(0, 0, 0),
      );
      textY += bodyLineH;

      // Middle double line
      img.drawString(
        merged,
        line,
        font: fontMono,
        x: padX,
        y: textY,
        color: img.ColorRgb8(0, 0, 0),
      );
      textY += bodyLineH;

      // Refs (left align)
      for (final r in refs) {
        img.drawString(
          merged,
          r,
          font: fontBody,
          x: padX,
          y: textY,
          color: img.ColorRgb8(0, 0, 0),
        );
        textY += bodyLineH;
      }

      // Bottom double line
      img.drawString(
        merged,
        line,
        font: fontMono,
        x: padX,
        y: textY,
        color: img.ColorRgb8(0, 0, 0),
      );
      // Draw QR if available (Right aligned, PayQR text left aligned)
      if (params.qr != null && params.qr!.isNotEmpty) {
        try {
          textY += bodyLineH; // Add some spacing from bottom line

          final qrCode = qr_lib.QrCode(4, qr_lib.QrErrorCorrectLevel.M);
          qrCode.addData(params.qr!);
          final qrImage = qr_lib.QrImage(qrCode);

          final moduleCount = qrImage.moduleCount;
          int scale =
              (80 / moduleCount).floor(); // Target 80px (User requested)
          if (scale < 1) scale = 1;
          final int actualQrSize = moduleCount * scale;

          // Draw "PayQR" text on the far left
          int textLineY = textY;

          // img.drawString(
          //   merged,
          //   'Bank of Thailand',
          //   font: fontTitle,
          //   x: padX,
          //   y: textLineY,
          //   color: img.ColorRgb8(0, 0, 0),
          // );
          // textLineY += titleLineH;

          img.drawString(
            merged,
            'bank: ${params.bankname}',
            font: fontBody,
            x: padX,
            y: textLineY,
            color: img.ColorRgb8(0, 0, 0),
          );
          textLineY += bodyLineH;

          img.drawString(
            merged,
            'account: ${params.banknumber}',
            font: fontBody,
            x: padX,
            y: textLineY,
            color: img.ColorRgb8(0, 0, 0),
          );
          // Align QR to far right
          final int qrX = merged.width - padX - actualQrSize;
          final int qrY = textY;

          final black = img.ColorRgb8(0, 0, 0);

          for (int x = 0; x < moduleCount; x++) {
            for (int y = 0; y < moduleCount; y++) {
              if (qrImage.isDark(y, x)) {
                img.fillRect(
                  merged,
                  x1: qrX + (x * scale),
                  y1: qrY + (y * scale),
                  x2: qrX + (x * scale) + scale - 1,
                  y2: qrY + (y * scale) + scale - 1,
                  color: black,
                );
              }
            }
          }
        } catch (e) {
          debugPrint('Isolate QR Error: $e');
        }
      }
    }

    return Uint8List.fromList(img.encodeJpg(merged, quality: 50));
  } catch (e) {
    debugPrint('Error merging images in isolate: $e');
    return null;
  }
}

Future<Uint8List> buildQrPngWithCenterLogo({
  required String data,
  required String assetLogoPath,
  String? bottomText, // Price
  String? bottomname, // name
  String? bottombankno, // bankno
  String? bottomRef, // Ref
  String? activeQrExpire,
  int sizePx = 400, // Higher res for clear small text
}) async {
  // 1) QR matrix
  final qrCode = qr_lib.QrCode(10, qr_lib.QrErrorCorrectLevel.M);
  qrCode.addData(data);
  // qrCode.make(); // ✅ สำคัญมาก
  final qrImage = qr_lib.QrImage(qrCode);

  final moduleCount = qrImage.moduleCount;
  const int quietModule = 4;
  final int totalModules = moduleCount + (quietModule * 2);

  int scale = (sizePx / totalModules).floor();
  if (scale < 1) scale = 1;
  final int qrSize = totalModules * scale;

  // Fonts (large/small)
  final fontTitle = img.arial14; // Big header
  final fontBody = img.arial14; // Small list
  // final fontMono = img.arial14; // Mono for separator line

  // Layout
  const int padX = 24;
  const int padTop = 18;
  const int padBottom = 18;
  const int lineGap = 6;

  // Standard line heights
  final int titleLineH = fontTitle.lineHeight + lineGap;
  final int bodyLineH = fontBody.lineHeight + lineGap;

  // Prepare Footer Info
  final nowStr = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
  final nowActiveQr = activeQrExpire;

  final List<String> refs = [];
  refs.add('system: chaopertyuser');
  if (bottomname != null && bottomname.isNotEmpty)
    refs.add('bank: $bottomname');

  if (bottombankno != null && bottombankno.isNotEmpty)
    refs.add('account: $bottombankno');
  if (bottomText != null && bottomText.isNotEmpty)
    refs.add('amount: $bottomText');
  // if (bottomRef != null && bottomRef.isNotEmpty) refs.add('Ref: $bottomRef');

  // Calculate Footer Height
  int footerHeight = 0;
  if (refs.isNotEmpty) {
    footerHeight = padTop +
        bodyLineH + // Top Double Line
        titleLineH + // Title
        (2 * bodyLineH) + // Date lines
        bodyLineH + // Middle Double Line
        (refs.length * bodyLineH) + // Refs
        bodyLineH + // Bottom Double Line
        padBottom;
  }

  // Add some extra space for the bottom icon if needed, or keep it simple
  if (footerHeight == 0) {
    footerHeight = (qrSize * 0.40).round();
  }

  // (ถ้าจะไม่ใช้ footer จริง ๆ ตัด height ให้เท่า qrSize ก็ได้)
  // final int footerHeight = (qrSize * 0.40).round();
  final int totalHeight = qrSize + footerHeight;

  // 2) base image
  final qrCanvas =
      img.Image(width: qrSize, height: totalHeight, numChannels: 4);
  img.fill(qrCanvas, color: img.ColorRgba8(255, 255, 255, 255));
  final black = img.ColorRgba8(0, 0, 0, 255);

  // 3) draw modules
  for (int y = 0; y < moduleCount; y++) {
    for (int x = 0; x < moduleCount; x++) {
      if (qrImage.isDark(y, x)) {
        final xPos = (quietModule + x) * scale;
        final yPos = (quietModule + y) * scale;
        img.fillRect(
          qrCanvas,
          x1: xPos,
          y1: yPos,
          x2: xPos + scale - 1,
          y2: yPos + scale - 1,
          color: black,
        );
      }
    }
  }

  // Draw Footer
  if (refs.isNotEmpty) {
    // Draw Frame around Footer
    const int framePad = 10;
    final int startY = qrSize + framePad;
    final int startX = framePad;
    final int endX = qrCanvas.width - framePad - 1;
    final int endY = totalHeight - framePad - 1;
    img.drawRect(
      qrCanvas,
      x1: startX,
      y1: startY,
      x2: endX,
      y2: endY,
      color: black,
    );

    int textY = qrSize + padTop;

    // Full width double line (inside frame => minus padX both sides)
    // Note: _isolateDoubleLine generates an image, we might need to scale it too or just simple line?
    // _isolateDoubleLine uses fontMono to draw dashes usually.

    // Let's just draw a simple line rect instead of text dashes for cleaner small look
    final int innerWidth = qrCanvas.width - (padX * 2);

    void drawLine() {
      img.fillRect(qrCanvas,
          x1: padX,
          y1: textY + 4,
          x2: padX + innerWidth,
          y2: textY + 5,
          color: black);
      // img.fillRect(qrCanvas, x1: padX, y1: textY + 6, x2: padX + innerWidth, y2: textY + 7, color: black);
    }

    // Top double line (center)
    drawLine();
    textY += bodyLineH;

    // Big Title (center)
    const title = 'REFERENCE SYSTEM';

    // Center calc is harder with scaling. We just hardcode approximate for now or measure?
    // Let's left align to be safe or approx center.
    // Arial14 ~8px per char * 0.5 = 4px per char.
    // 16 chars * 4 = 64px width.
    int titleX = (qrSize - (title.length * 8)) ~/ 2;
    if (titleX < padX) titleX = padX;

    img.drawString(
      qrCanvas,
      title,
      font: fontTitle,
      x: titleX,
      y: textY,
      color: img.ColorRgb8(0, 0, 0),
    );
    textY += titleLineH;

    final dateLine = 'generated at: $nowStr';
    img.drawString(
      qrCanvas,
      dateLine,
      font: fontBody,
      x: padX,
      y: textY,
      color: img.ColorRgb8(0, 0, 0),
    );
    textY += bodyLineH;

    final dateLine2 = 'expires at: $nowActiveQr';
    img.drawString(
      qrCanvas,
      dateLine2,
      font: fontBody,
      x: padX,
      y: textY,
      color: img.ColorRgb8(0, 0, 0),
    );
    textY += bodyLineH;

    // Middle double line
    drawLine();
    textY += bodyLineH;

    // Refs (left align)
    for (final r in refs) {
      img.drawString(
        qrCanvas,
        r,
        font: fontBody,
        x: padX,
        y: textY,
        color: img.ColorRgb8(0, 0, 0),
      );
      textY += bodyLineH;
    }

    // Bottom double line
    drawLine();
  }

  // 4) center logo
  try {
    final bytes = await rootBundle.load(assetLogoPath);
    final logoInput = img.decodePng(bytes.buffer.asUint8List());
    if (logoInput != null) {
      final int logoW = (qrSize * 0.22).round();
      final logoResized =
          img.copyResize(logoInput, width: logoW, height: logoW);

      final int qrCenter = (qrSize / 2).round();
      final int half = (logoW / 2).round();
      final int bgPad = (logoW * 0.10).round();

      img.fillRect(
        qrCanvas,
        x1: qrCenter - half - bgPad,
        y1: qrCenter - half - bgPad,
        x2: qrCenter + half + bgPad,
        y2: qrCenter + half + bgPad,
        color: img.ColorRgba8(255, 255, 255, 255),
      );

      img.compositeImage(qrCanvas, logoResized,
          dstX: qrCenter - half, dstY: qrCenter - half);
    }
  } catch (e) {
    debugPrint("Logo CPU Error: $e");
  }

  // 5) Draw Footer Icon (if space permits)
  // try {
  //   int textY = qrSize + 40;
  //   // If we have dynamic footer, we might want to put this at the very bottom
  //   if (refs.isNotEmpty) {
  //     // approximate bottom position
  //     textY = totalHeight - 40;
  //   }

  //   final chaoBytes = await rootBundle.load('images/Icon-chao.png');
  //   final chaoImg = img.decodePng(chaoBytes.buffer.asUint8List());
  //   if (chaoImg != null) {
  //     final int chaoW = (qrSize * 0.12).round();
  //     final chaoResized = img.copyResize(chaoImg, width: chaoW, height: chaoW);
  //     final int xPos = (qrSize - chaoW) ~/ 2;
  //     // Position at bottom with some padding
  //     final int yPos = totalHeight - chaoW - 10;

  //     // Only draw if it doesn't overlap too much with text?
  //     // For now just draw it
  //     img.compositeImage(qrCanvas, chaoResized, dstX: xPos, dstY: yPos);
  //   }
  // } catch (e) {
  //   debugPrint("Footer CPU Error: $e");
  // }

  return img.encodePng(qrCanvas);
}

void showIOSSaveOverlay(Uint8List bytes, {required bool isEN}) {
  html.document.getElementById('qr_save_overlay')?.remove();

  final base64 = base64Encode(bytes);
  final dataUrl = 'data:image/png;base64,$base64';

  final overlay = html.DivElement()
    ..id = 'qr_save_overlay'
    ..style.position = 'fixed'
    ..style.left = '0'
    ..style.top = '0'
    ..style.right = '0'
    ..style.bottom = '0'
    ..style.backgroundColor = 'rgba(0,0,0,0.9)'
    ..style.display = 'flex'
    ..style.flexDirection = 'column'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center'
    ..style.zIndex = '2147483647';

  final img = html.ImageElement()
    ..src = dataUrl
    ..style.maxWidth = '85vw'
    ..style.maxHeight = '65vh'
    ..style.borderRadius = '12px'
    ..style.backgroundColor = '#FFFFFF' // ✅ เพิ่มพื้นขาวให้ QR
    ..style.padding = '16px' // ✅ เพิ่ม padding รอบ QR
    ..style.boxShadow = '0 4px 20px rgba(0,0,0,0.3)' // เพิ่มเงาให้สวย
    // ✅ บังคับให้ iOS แสดงเมนู Save เมื่อกดค้าง
    ..style.setProperty('-webkit-touch-callout', 'default')
    ..style.pointerEvents = 'auto';

  final hint = html.DivElement()
    ..text = isEN ? 'Long-press the image to Save' : 'กดค้างที่รูปเพื่อบันทึก'
    ..style.color = '#fff'
    ..style.fontSize = '16px'
    ..style.marginTop = '20px'
    ..style.textAlign = 'center'
    ..style.padding = '0 16px';

  final closeBtn = html.ButtonElement()
    ..text = isEN ? 'Close' : 'ปิด'
    ..style.marginTop = '14px'
    ..style.padding = '10px 18px'
    ..style.borderRadius = '10px'
    ..style.border = 'none'
    ..style.backgroundColor = '#FFFFFF'
    ..style.color = '#000000'
    ..style.fontSize = '16px'
    ..style.cursor = 'pointer';

  closeBtn.onClick.listen((_) => overlay.remove());
  img.onClick.listen((e) => e.stopPropagation());

  overlay.children.addAll([img, hint, closeBtn]);
  html.document.body?.append(overlay);
}
