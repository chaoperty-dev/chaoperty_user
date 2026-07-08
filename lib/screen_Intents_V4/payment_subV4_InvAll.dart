// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:chaoperty_user/screen_Intents/APIS-V2/payment-intents.dart';
import 'package:chaoperty_user/screen_Intents/Model/IntentsContractx_Fine_Model.dart';
import 'package:chaoperty_user/screen_Intents/Model/IntentsInv_history_Model.dart';
import 'package:chaoperty_user/screen_Intents/bankCodeMap.dart';
import 'package:flutter/material.dart';
// หรือ
import 'package:flutter/widgets.dart';

import 'package:auto_size_text/auto_size_text.dart';
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
import 'package:image/image.dart' as img_lib;
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
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image/image.dart' as img;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr/qr.dart' as qr_lib;

import 'package:gal/gal.dart';

import '../screen_Intents/APIS-V2/config-intents.dart';

class paymentSubV4InvAll extends StatefulWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<TeNantModel>? teNantModel;
  final String? cuslang;
  final String? serPayment;
  final String? serptPayment;

  final List<String>? selectedDocNos;
  paymentSubV4InvAll({
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
  State<paymentSubV4InvAll> createState() => _paymentSubV4InvAllState();
}

class _paymentSubV4InvAllState extends State<paymentSubV4InvAll>
    with TickerProviderStateMixin {
  var nFormat = NumberFormat("#,##0.00", "en_US");
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
  bool _initialLoading = true; // show 1-sec splash on first enter
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

  String? Payment_bno,
      Payment_bname,
      Payment_bname_en,
      Payment_bank_ncode,
      Payment_paytype_ncode,
      Payment_remark;

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
  bool _isBillDead = false;
  // Trigger to update QR dialog without StreamBuilder loop
  final ValueNotifier<int> _qrUpdateTrigger = ValueNotifier(0);
  String? custno;
  String? renTal_user, renTal_name;
  String? return_qr_refapi1, return_qr_refapi2, return_qr_refapi3;
  String? qr_expiresAt, qr_softExpiresAt, activeQrSessionSoftExpire;
  String? qr_payload;
  String? qrDataNoIntens;
  // ใช้ค่าล่าสุด (อาจถูกอัปเดตจาก renew)
  String? nowExpiresIso;
  DateTime? expiryLocal;
  Uint8List? _slipImageBytes;
  String? _slipImageName;
  String? intentsAttacheSlipNo; // Added
  late Stream<int> _timerStream;
  // Added 2026-07-08: hold subscription so we can cancel on dispose.
  StreamSubscription<int>? _timerSub;
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
    // Hold a listener so we can cancel it on dispose; previously
    // the broadcast stream kept running 1Hz until app exit.
    _timerSub = _timerStream.listen((_) {});
    if (widget.mainScreenAnimationController == null) {
      _usingLocalController = true;
      _localController = AnimationController(vsync: this, value: 1.0);
      _localAnimation = AlwaysStoppedAnimation(1.0);
    }

    // splash loading 1 วินาที ตอนเข้าหน้าครั้งแรก
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _initialLoading = false);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) _showAttachSlipWarning();
      });
    });

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _showAttachSlipWarning();
    // });

    checkPreferance().then((value) {
      Value_newDateY1 = DateFormat('yyyy-MM-dd').format(newDatetime);
      Value_newDateD1 = DateFormat('dd-MM-yyyy').format(newDatetime);
      Value_newDateY = DateFormat('yyyy-MM-dd').format(newDatetime);
      Value_newDateD = DateFormat('dd-MM-yyyy').format(newDatetime);

      _initData();
    });
  }

  void _showAttachSlipWarning() {
    final isEN = widget.cuslang == 'EN';
    double dx = 0.0;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => StatefulBuilder(
            builder: (_, setSS) => Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.85,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 28),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.warning_rounded,
                                  color: Colors.red, size: 38),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              isEN
                                  ? 'Important Notice'
                                  : 'ประกาศสำคัญสำหรับผู้เช่า',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isEN
                                  ? 'After making a payment, tenants must attach payment evidence via the tenant app every time.'
                                  : 'หลังจากทำการชำระเงินแล้ว\nผู้เช่าจะต้องแนบหลักฐานการชำระเงิน\nผ่านแอปผู้เช่าทุกครั้ง',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, height: 1.6),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.4),
                                    width: 1.5),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      isEN
                                          ? 'If no evidence is attached,\nthe system will treat it as\n"No Payment Made" in all cases'
                                          : 'หากไม่แนบหลักฐานในแอปผู้เช่า\nระบบจะถือว่า\n"ยังไม่มีการชำระเงิน" ทุกกรณี',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                        height: 1.65,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // ── Slide-to-dismiss button ──
                            LayoutBuilder(builder: (_, constraints) {
                              const double handleSize = 46.0;
                              const double trackHeight = 52.0;
                              const double pad = 4.0;
                              final double maxDrag =
                                  constraints.maxWidth - handleSize - pad * 2;
                              final double pct = (dx / maxDrag).clamp(0.0, 1.0);

                              return Container(
                                height: trackHeight,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.lerp(Colors.grey,
                                          Colors.grey.shade800, pct)!,
                                      Colors.grey.shade800,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(trackHeight / 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.grey.withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    // label — จางลงเมื่อเลื่อน
                                    Center(
                                      child: Opacity(
                                        opacity:
                                            (1.0 - pct * 2).clamp(0.0, 1.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              isEN
                                                  ? 'Slide to close'
                                                  : 'เลื่อนเพื่อปิด',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // handle
                                    AnimatedPositioned(
                                      duration: dx == 0
                                          ? const Duration(milliseconds: 300)
                                          : Duration.zero,
                                      curve: Curves.elasticOut,
                                      left: pad + dx,
                                      child: GestureDetector(
                                        onHorizontalDragUpdate: (d) {
                                          setSS(() {
                                            dx = (dx + d.delta.dx)
                                                .clamp(0.0, maxDrag);
                                          });
                                        },
                                        onHorizontalDragEnd: (_) {
                                          if (dx >= maxDrag * 0.72) {
                                            Navigator.of(ctx,
                                                    rootNavigator: true)
                                                .pop();
                                          } else {
                                            setSS(() => dx = 0.0);
                                          }
                                        },
                                        child: Container(
                                          width: handleSize,
                                          height: handleSize,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 6,
                                                offset: Offset(2, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.grey.shade700,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                )));
  }

  @override
  void dispose() {
    if (_usingLocalController) {
      _localController.dispose();
    }
    _timerSub?.cancel();
    _qrUpdateTrigger.dispose();
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

    await redPaymentIntents(
        cusno: custno16Bit, propertyno: ren16Bit.toString() ?? '');
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
    }
  }

  Future<void> redPaymentIntents(
      {required String cusno, required String propertyno}) async {
    if (mounted) {
      setState(() {
        paymentIntents.clear();
      });
    }

    debugPrint('Step: redPaymentIntents: START');
    debugPrint('Step: redPaymentIntents: cusno=$cusno, propertyno=$propertyno');

    try {
      final response =
          await postPaymentIntentsState(cusno: cusno, propertyno: propertyno);

      if (response == null) {
        debugPrint('Step: redPaymentIntents: ❌ Response is Null');
        return;
      }

      // debugPrint('Step: redPaymentIntents: Body: ${response.body}');

      if (response.body.isEmpty) {
        debugPrint('Step: redPaymentIntents: ❌ response.body ว่าง');
        return;
      }

      final root = json.decode(response.body);

      if (root is! Map<String, dynamic>) {
        debugPrint(
            'Step: redPaymentIntents: ❌ รูปแบบ JSON ไม่ใช่ Map<String, dynamic>');
        return;
      }

      final intentsListRaw = root['data'];

      final intents = (intentsListRaw is List
              ? intentsListRaw.whereType<Map<String, dynamic>>()
              : const <Map<String, dynamic>>[])
          .map((m) => PaymentIntent.fromJson(m))
          .where((p) => p.bankmerchantid.toString() == '${widget.serPayment}')
          .toList();

      if (mounted) {
        setState(() {
          paymentIntents = intents;
        });
      }

      debugPrint(
          'Step: redPaymentIntents: ✅ intents loaded: ${intents.length}');
      if (intents.isNotEmpty) {
        for (var i = 0; i < intents.length; i++) {
          debugPrint(
              '   [$i] intentUuid: ${intents[i].intentUuid}, Status: ${intents[i].status}');
          if (intents[i].invoices.isNotEmpty) {
            for (var inv in intents[i].invoices) {
              debugPrint('       -> Invoice: ${inv.billReference}');
            }
          } else {
            debugPrint('       -> No Invoices');
          }
        }
      } else {
        debugPrint('   No intents in the list.');
      }
    } catch (e, stack) {
      debugPrint(
          'Step: redPaymentIntents: ❌ Exception parsing payment intents: $e');
      debugPrint('🧭 StackTrace:\n$stack');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

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
          return const Center(child: CircularProgressIndicator());
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
      final All_discountAmount = double.tryParse(sum_disamt.toString()) ?? 0.0;
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
      if (requestedAmountTotalBill <= 0) {
        throw Exception('ยอดชำระทั้งหมดต้องมากกว่า 0');
      }
      if (invs.isEmpty) {
        throw Exception('ไม่พบข้อมูลใบแจ้งหนี้ที่ถูกต้อง');
      }
      if (widget.serPayment == null || widget.serPayment!.isEmpty) {
        throw Exception('กรุณาเลือกวิธีการชำระเงิน');
      }
      await PostPaymentIntent(
        cusNo: custno16Bit,
        propertyNo: ren16Bit,
        payedType: "invoice",
        payser: int.tryParse('${widget.serPayment}') ?? 0,
        typepayser: int.tryParse('${widget.serptPayment}') ?? 0,
        requestedAmount: _d(requestedAmountTotalBill), // ✅ ไม่ใช้ string format
        requestedTotal: _d(requestedAmountTotalBill), // ✅ API ต้องการ
        lateFee: All_lateFee,
        discountAmount: All_discountAmount,
        depositAmount: All_depositAmount,
        insuranceAmount: All_insuranceAmount,
        withholdingAmount: All_withholdingAmount,
        inVoices: invs,
        transselect: _InvoiceHistory.map((e) => e.toJson()).toList(),

        PayBno: Payment_bno ?? '',
        PayBname: Payment_bname ?? '',
        PayBname_en: Payment_bname_en ?? '',
        PayBank_ncode: Payment_bank_ncode ?? '',
        PayPaytype_ncode: Payment_paytype_ncode ?? '',
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
  Future<void> PostPaymentIntent(
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
      required double requestedTotal,
      required List<Map<String, dynamic>> inVoices,
      required List<Map<String, dynamic>> transselect,
      required String PayBno,
      required String PayBname,
      required String PayBname_en,
      required String PayBank_ncode,
      required String PayPaytype_ncode}) async {
    debugPrint('🔄 เรียกใช้งาน PostPaymentIntents()');
    final accountType = (PayPaytype_ncode == '' ||
            PayPaytype_ncode == 'null' ||
            PayPaytype_ncode == null)
        ? PayBank_ncode
        : PayPaytype_ncode;
    if (accountType == null || accountType.isEmpty) {
      debugPrint(
          '❌ accountType ว่าง: PayBank_ncode="$PayBank_ncode", PayPaytype_ncode="$PayPaytype_ncode"');
      return;
    }
    final response = await postPaymentIntents(
        cusNo: cusNo,
        propertyNo: propertyNo,
        payedType: payedType,
        chanNel: "invoice",
        requestedAmount: requestedAmount,
        lateFee: lateFee,
        discountAmount: discountAmount,
        depositAmount: depositAmount,
        insuranceAmount: insuranceAmount,
        withholdingAmount: withholdingAmount,
        requestedTotal: requestedTotal,
        // createdById: "10101010101010",
        isAdminCreated: true,
        bankMerchantId: payser,
        bankMerchantType: typepayser,
        descripTion: "",
        inVoices: inVoices,
        transSelect: transselect,
        accountType: accountType,
        accountNumber: PayBno,
        accountNameTh: PayBname,
        accountNameEn: PayBname_en);

    if (response == null) {
      debugPrint('❌ ไม่มี response จาก server');
      return;
    }

    try {
      final jsonRes = json.decode(response.body);
      debugPrint('🧾 Raw JSON: $jsonRes');

      // ✅ 1. Update numinvoice with new UUID (handle nested data structure)
      final data = jsonRes['data'] ??
          jsonRes; // Support both {data: {...}} and direct {...}
      final newUuid = data['uuid'];
      setState(() {
        numinvoice = newUuid;
        bankMerchantId = 0;
        ref1 = '';
        ref2 = '';
        ref3 = '';
      });

      // ✅ 2. Reload intents to ensure QrGenRef finds the new intent
      if (newUuid != null) {
        await redPaymentIntents(cusno: cusNo, propertyno: propertyNo);
      }

      // ✅ 3. Call QrGenRef
      await QrGenRef(
        QR_Ref1: data['ref1'] ?? '',
        QR_Ref2: data['ref2'] ?? '',
        QR_Ref3: data['ref3'] ?? '',
        softExpireAt: data['soft_expire_at'] ?? '',
      );
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
    // expiry is already parsed correctly (UTC if ends with Z, local otherwise)
    final sec = expiry.difference(now).inSeconds;

    return sec < 0 ? 0 : sec;
  }

  bool _isQrExpired() {
    return secondsUntilExpire() <= 0;
  }

  String _hhmmssFromSecs(int secs) {
    final h = (secs ~/ 3600).toString().padLeft(2, '0');
    final m = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<Null> QrGenRef(
      {String? QR_Ref1,
      String? QR_Ref2,
      String? QR_Ref3,
      String? softExpireAt}) async {
    String _fmtDT(DateTime? d) =>
        d == null ? '-' : DateFormat('dd-MM-yyyy HH:mm').format(d.toLocal());
    final String targetUuid = '$numinvoice';

    // ✅ ตรวจสอบว่ามี intent หรือไม่
    final filteredIntents =
        paymentIntents.where((p) => p.intentUuid == targetUuid).toList();

    if (filteredIntents.isEmpty) {
      debugPrint('❌ ไม่พบ Intent ที่ตรงกับ UUID: $targetUuid');
      return;
    }

    // final firstIntent = filteredIntents.first; // Replaced
    var currentIntent =
        filteredIntents.first; // ✅ Declare as var to allow update

    final bankId = currentIntent.bankmerchantid ?? 0;
    final bankItem = _PayMentModels.firstWhere(
      (p) => p.ser.toString() == '$bankId',
      orElse: () => PayMentModel(
        ser: '-',
        bname: '-',
        bno: '-',
        ptser: '-',
      ),
    );

    final paybname = bankItem.bname;
    final paybno = bankItem.bno;
    final payptser = bankItem.ptser;
    final payser = bankItem.ser;
    final payimg = bankItem.img;

    final intentStatusThai = currentIntent.statusExtended?.statusThai ?? '-';

    // final intentSoftExpireAt = _fmtDT(currentIntent.softExpireAt);
    // final intentCreatedAt = _fmtDT(currentIntent.createdAt);
    // final intentUpdatedAt = _fmtDT(currentIntent.updatedAt);
    // Unused variables commented out

    // ✅ ตั้งค่า qr_expiresAt จาก intent ที่มีอยู่ (ถ้ามี) เพื่อป้องกันการสร้าง QR ซ้ำ
    if (currentIntent.softExpireAt != null) {
      qr_expiresAt = currentIntent.softExpireAt!.toIso8601String();
    }

    // ---------- 0) ถ้ายังไม่มี QR ให้สร้างครั้งแรก ----------
    final dData = await _DetailsPaymentIntentsReload();

    // Store uploaded slip data if exists (แก้ไข Type Error: _uploadedSlipData เป็น Uint8List)
    if (dData != null && dData['attaches'] != null) {
      // _uploadedSlipData = dData['attaches']; // ❌ Error: dData['attaches'] เป็น Map ไม่ใช่ Uint8List
      // เราอาจจะแค่ log ไว้ หรือถ้าต้องการแสดงผลต้องโหลดรูปจริง
      _intentsSlipData = dData['attaches'] as Map<String, dynamic>;
      intentsAttacheSlipNo = _intentsSlipData!['slip_no'] as String?;
      debugPrint('📎 พบหลักฐานการชำระ: ${_intentsSlipData!['slip_no']}');
      debugPrint('📎 ข้อมูล attaches: $_intentsSlipData');
      debugPrint('📎 พบหลักฐานการชำระ (Metadata): ${dData['attaches']}');

      // กรณีนี้เราอาจจะถือว่า user มีสลิปแล้ว แต่เรายังไม่มี bytes ในเครื่อง
      // หาก logic คือ "ถ้ามีสลิปแล้วไม่ต้อง check expire" เราอาจจะใช้ flag อื่นช่วย
      // หรือถ้าต้องการให้ _uploadedSlipData ไม่ว่าง เพื่อให้ UI รู้ว่ามีสลิปแล้ว (hack)
      // _uploadedSlipData = Uint8List(0); // ✅ Hack: ใส่ข้อมูลว่างเพื่อให้ไม่ null (แต่ตรวจสอบ logic อื่นด้วย)
    } else {
      _intentsSlipData = null;
      _uploadedSlipData = null;
      debugPrint('📎 ไม่พบหลักฐานการชำระ');
    }

    // ✅ ใช้ค่าจาก Argument ถ้ามี
    if (QR_Ref1 != null && QR_Ref1.isNotEmpty) return_qr_refapi1 = QR_Ref1;
    if (QR_Ref2 != null && QR_Ref2.isNotEmpty) return_qr_refapi2 = QR_Ref2;
    if (QR_Ref3 != null && QR_Ref3.isNotEmpty) return_qr_refapi3 = QR_Ref3;
    if (softExpireAt != null && softExpireAt.isNotEmpty) {
      qr_expiresAt = softExpireAt;
      qr_softExpiresAt = softExpireAt;
    }

    // ✅ ถ้ามี active_qr_session อยู่แล้ว ให้โหลดข้อมูลมาใช้ (กรณี Argument ว่าง)
    if (dData != null && dData['active_qr_session'] != null) {
      debugPrint('🔄 มี active_qr_session → โหลดข้อมูล QR ที่มีอยู่');
      final qrSession = dData['active_qr_session'] as Map<String, dynamic>;

      final ref1 = qrSession['ref1'] as String?;
      final ref2 = qrSession['ref2'] as String?;
      final ref3 = qrSession['ref3'] as String?;
      activeQrSessionSoftExpire = qrSession['soft_expire_at'] as String?;
      debugPrint('✅ โหลด QR Session: ref1=$ref1, ref2=$ref2, ref3=$ref3');

      // Always update refs if we have valid QR session data
      if (ref1 != null && ref1.isNotEmpty) return_qr_refapi1 = ref1;
      if (ref2 != null && ref2.isNotEmpty) return_qr_refapi2 = ref2;
      if (ref3 != null && ref3.isNotEmpty) return_qr_refapi3 = ref3;

      final expiresIso = qrSession['soft_expire_at'] as String?;
      if (qr_expiresAt == null || qr_expiresAt!.isEmpty) {
        qr_expiresAt = expiresIso;
        qr_softExpiresAt = expiresIso;
      }
    } else {
      // ไม่มี active session → สร้างใหม่
      debugPrint('🆕 ยังไม่มี QR → สร้างครั้งแรก');
      final ok = await _renewQrAndReload();
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('สร้าง QR ไม่สำเร็จ กรุณาลองอีกครั้ง'),
          ),
        );
        return;
      }
      // ✅ Refresh local variable 'currentIntent' with the newly loaded data
      if (paymentIntents.isNotEmpty) {
        currentIntent = paymentIntents.first;
      }

      // ✅ Load the new QR session expiry immediately after creation
      final dDataRenewed = await _DetailsPaymentIntentsReload();
      if (dDataRenewed != null && dDataRenewed['active_qr_session'] != null) {
        final qrSession =
            dDataRenewed['active_qr_session'] as Map<String, dynamic>;
        activeQrSessionSoftExpire = qrSession['soft_expire_at'] as String?;
        debugPrint(
            '✅ Set activeQrSessionSoftExpire after creation: $activeQrSessionSoftExpire');
      }
    }

    // ✅ Fallback: ถ้ายังไม่มี Ref ให้ลองใช้ค่าจาก Intent (ใช้ currentIntent ที่ update แล้ว)
    if (return_qr_refapi1 == null || return_qr_refapi1!.isEmpty) {
      String? fallbackCid;
      // พยายามหา cid จาก metadata ตัวแรก
      if (currentIntent.invoices.isNotEmpty) {
        final inv = currentIntent.invoices.first;
        if (inv.metadata.isNotEmpty) {
          fallbackCid = inv.metadata.first.cid;
        }
      }

      if (fallbackCid != null && fallbackCid.isNotEmpty) {
        return_qr_refapi1 = fallbackCid;
      } else if (currentIntent.customerNo != null &&
          currentIntent.customerNo!.isNotEmpty) {
        return_qr_refapi1 = currentIntent.customerNo;
      }
    }
    if (return_qr_refapi2 == null || return_qr_refapi2!.isEmpty) {
      if (currentIntent.paymentIntentNo != null &&
          currentIntent.paymentIntentNo!.isNotEmpty) {
        return_qr_refapi2 = currentIntent.paymentIntentNo;
      }
    }

    // ---------- 1) Expiration Logic Split ----------
    // A) Bill deadline: ใช้ softExpireAt ของ intent เป็น bill deadline
    //    แต่ถ้า server ส่ง soft_expire_at เท่ากับ session (1 ค่าเดียว)
    //    ให้ถือว่า bill ยังไม่หมด (อนุญาต renew ได้เสมอ)
    final billDeadline = currentIntent.softExpireAt;
    final sessionExpiryStr = activeQrSessionSoftExpire;
    final sessionDate =
        sessionExpiryStr != null ? DateTime.tryParse(sessionExpiryStr) : null;
    final isSessionExpired =
        sessionDate == null || DateTime.now().isAfter(sessionDate);

    // ถ้า billDeadline ≤ sessionDate → server ใช้ค่าเดียวกัน → ไม่ block renewal
    final billAndSessionSame = billDeadline != null &&
        sessionDate != null &&
        !billDeadline.isAfter(sessionDate);
    final isBillDead = !billAndSessionSame &&
        billDeadline != null &&
        DateTime.now().isAfter(billDeadline);

    debugPrint(
        '⏱️ bill=$billDeadline, session=$sessionDate, same=$billAndSessionSame, isBillDead=$isBillDead');

    final hasUploadedSlip = _uploadedSlipData != null;

    if (isSessionExpired && !hasUploadedSlip) {
      if (!isBillDead) {
        debugPrint('✅ Session Expired & Bill Valid -> Auto Renewing...');
        final ok = await _renewQrAndReload();
        if (!mounted) return;
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ต่ออายุ QR ไม่สำเร็จ กรุณาลองอีกครั้ง')),
          );
          return;
        }
      } else {
        debugPrint('❌ Bill Expired -> Cannot Renew QR.');
        if (!mounted) return;
        setState(() => _isBillDead = true);
      }
    } else if (isSessionExpired && hasUploadedSlip) {
      debugPrint('⚠️ QR หมดอายุ แต่มีสลิปอัปโหลดแล้ว → ข้ามการ renew');
    } else {
      // ✅ Session Valid -> Reset flag to false so UI shows QR
      _expireDialogShown = false;
    }

    // Refresh Session Expiry for UI after potential renew
    final currentSessionExpiryIso = activeQrSessionSoftExpire;
    // Set qr_expiresAt for UI Display (Timer) to reference SESSION time
    qr_expiresAt = currentSessionExpiryIso;
    qr_softExpiresAt = currentSessionExpiryIso;

    // ---------- 2) ตั้งค่าเวลาหมดอายุ/ตัวช่วยแสดงผล ----------
    // ใช้ค่าล่าสุด (อาจถูกอัปเดตจาก renew)
    String nowExpiresIso = qr_expiresAt?.toString() ?? '';
    DateTime expiryLocal =
        (DateTime.tryParse(nowExpiresIso) ?? DateTime.now()).toLocal();

    // ถ้า server คืนเวลาที่หมดแล้ว ใช้ค่านั้นตามจริง (_isQrExpired จะ handle)
    final DateTime expiryUtc = expiryLocal.toUtc();

    // อายุเต็ม (วินาที) — หากระบบคุณรู้แน่ชัดว่า 5 นาที ให้คง 300
    // หรือจะคำนวณจาก now→expiry ตอนเปิดก็ได้
    final nowUtc = DateTime.now().toUtc();
    final diff = expiryUtc.difference(nowUtc).inSeconds;
    debugPrint(
        '⏱️ QR session total: ${diff}s (${(diff / 60).toStringAsFixed(1)} min), expire=$expiryUtc');

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

    // Assign local vars for display
    final ref1 = return_qr_refapi1 ?? '-';
    final ref2 = return_qr_refapi2 ?? '-';
    final ref3 = return_qr_refapi3 ?? '-';
    final bno = paybno ?? '-';
    final bname = paybname ?? '-';
    // final imgUrl = (MyConstant().domain) + (payimg ?? '');
    // ใช้ amountIntents (ที่ถูกต้องแล้ว)
    final amtVal = currentIntent.requestedAmount ?? 0.0;
    final amtStr = nFormat.format(amtVal);
    final amtRaw = amtVal.toStringAsFixed(2);

    final ptser = '${payptser}';
    final expLbl = _fmtExpireLocal(qr_expiresAt);

    // Update class state include vars used in UI
    setState(() {
      _totalSecs = diff > 0 ? diff : 0;
      this.return_qr_refapi1 = ref1;
      this.return_qr_refapi2 = ref2;
      this.return_qr_refapi3 = ref3;
      this.QR_Date15Min = expLbl;
      this.qr_softExpiresAt = qr_expiresAt;
      this.payment_tser = ptser;
      this.QR_Ref1 = ref1;
      this.QR_Ref2 = ref2;
      this.QR_Ref3 = ref3;
      _expireDialogShown = false;
      gopay = 1; // ✅ แสดง QR box บนหน้าหลัก
    });

    // Payload debugging logs removed for production/cleanup
    /*
    debugPrint('💳 Payment Type (ptser): $ptser');
    debugPrint('💳 ref1: $ref1, ref2: $ref2');
    debugPrint('💳 Bank No: $bno');
    debugPrint('💳 Amount: $amtVal');
    debugPrint('💳 qr_payload: $qr_payload');
    */

    // ✅ ใช้ selectedValue (PromptPay ID จาก dropdown) สำหรับสร้าง QR
    // paybno จาก intent อาจเป็นเลขอ้างอิงไม่ใช่ PromptPay ID (เช่น 010554605728801 = 15 หลัก)
    // selectedValue คือ bno ของ bank ที่ผู้ใช้เลือก (เช่น 0843631897 = 10 หลัก) ซึ่งเป็น PromptPay ID ที่ถูกต้อง
    final qrBno = selectedValue ?? paybno ?? '-';
    debugPrint(
        '💳 QrGenRef DEBUG: ptser=$ptser, paybno=$paybno, selectedValue=$selectedValue, qrBno=$qrBno, qrBno.length=${qrBno.length}, bankId=$bankId');
    final qrData = (ptser == '7')
        ? qr_payload.toString()
        : (ptser == '6')
            ? '|$qrBno\r$ref1\r$ref2\r${amtRaw.replaceAll('.', '')}' // Bill Payment
            : (ptser == '5')
                ? generateQRCode(
                    promptPayID: qrBno, amount: amtVal) // PromptPay
                : (ptser == '2')
                    ? '${payimg}'
                    : '';

    // Store qrData for use in _QRBox and save QR
    qrDataNoIntens = qrData;

    // Notify Listeners (Dialog) that QR data changed
    _qrUpdateTrigger.value++;

    debugPrint(
        '💳 QrGenRef: ptser=$ptser, qrBno=$qrBno, qrData length=${qrData.length}');
    debugPrint(
        '💳 QrGenRef: qrData=${qrData.substring(0, qrData.length > 80 ? 80 : qrData.length)}...');
    debugPrint('💳 QrGenRef: paybno=$paybno, selectedValue=$selectedValue');

    // ... validation logic ...
    if (qrData.isEmpty) {
      debugPrint(
          '❌ ไม่สามารถสร้าง QR ได้ - Payment type $ptser ไม่รองรับ QR หรือข้อมูลไม่ครบ');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ptser == '1'
                ? 'การชำระเงินสดไม่รองรับ QR Code'
                : 'ไม่สามารถสร้าง QR Code ได้ ข้อมูลไม่ครบถ้วน',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ---------- 4) เปิดแสดง QR ----------
    final _loadingFuture = Future.delayed(const Duration(seconds: 2));
    debugPrint('🔵 About to show sticky flexible bottom sheet');
    debugPrint('QR Data: $qrData');

    // เรียก bottom sheet หรือ update UI อื่นๆ ตาม logic เดิม

    debugPrint('Amount: $amtStr');
    debugPrint('Bank Name: $bname');

    // เรียก bottom sheet หรือ update UI อื่นๆ ตาม logic เดิมของคุณ
    // เช่น _showPaymentConfirmationSheet(context); หรือ setState ตัวแปรที่ใช้แสดงผล
  }

  // Future<Null> QrGenRef(
  //     {required String QR_Ref1,
  //     required String QR_Ref2,
  //     required String QR_Ref3,
  //     required String softExpireAt}) async {
  //   // Debug print inputs
  //   print('DEBUG: QrGenRef called with softExpireAt: "$softExpireAt"');

  //   setState(() {
  //     this.QR_Ref1 = QR_Ref1;
  //     this.QR_Ref2 = QR_Ref2;
  //     this.QR_Ref3 = QR_Ref3;

  //     qr_expiresAt = softExpireAt;
  //     QR_Date15Min = _fmtExpireLocal(softExpireAt);

  //     nowExpiresIso = softExpireAt;
  //     final parsed = DateTime.tryParse(nowExpiresIso!);
  //     print('DEBUG: parsed softExpireAt: $parsed');

  //     // Use parsed time or fallback to now (which means expired immediately)
  //     // Ideally we should handle null better, but for now let's see what we get.
  //     expiryLocal = (parsed ?? DateTime.now()).toLocal();
  //     expiryUtc = expiryLocal!.toUtc();

  //     final nowUtc = DateTime.now().toUtc();
  //     final diff = expiryUtc.difference(nowUtc).inSeconds;
  //     print('DEBUG: expiryUtc: $expiryUtc, nowUtc: $nowUtc, diff: $diff');

  //     _totalSecs = diff > 0 ? diff : 0;
  //     print('DEBUG: _totalSecs set to: $_totalSecs');
  //   });
  // }

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
        Uri.parse('${MyConstant().domain_chao}/GC_bill_invoiceHistory_v2.php')
            .replace(queryParameters: queryParams);
    // var uri =
    //     Uri.parse('${MyConstant().domain_chao}/GC_bill_invoice_history.php')
    //         .replace(queryParameters: queryParams);
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
    List<Future<void>> futures =
        List.generate(_InvoiceModels.length, (index) async {
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

        // print('ชำระเกินกำหนด ${_InvoiceModels[index].ser}');
        // print('ชำระเกินกำหนด ${uri}');
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

  Future<Null> red_payMent() async {
    if (_PayMentModels.length != 0) {
      setState(() {
        _PayMentModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain_chao}/GC_payMent.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          PayMentModel _PayMentModel = PayMentModel.fromJson(map);
          var autox = _PayMentModel.auto;
          var serx = _PayMentModel.ser;
          var ptnamex = _PayMentModel.ptname;
          // if (_PayMentModel.ser_payweb.toString() == '1') {
          if (_PayMentModel.ser.toString() == '${widget.serPayment}') {
            // setState(() {
            _PayMentModels.add(_PayMentModel);
            Payment_bno = _PayMentModel.bno;
            Payment_bname = _PayMentModel.bname;
            Payment_bname_en = _PayMentModel.bnameEn;
            Payment_bank_ncode = _PayMentModel.bankNcode;
            Payment_paytype_ncode = _PayMentModel.paytypeNcode;
            Payment_remark = _PayMentModel.remark;
            // });
          } else {}
        }
      }
    } catch (e) {}
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
      imageQuality: 55,
      maxWidth: 700,
      maxHeight: 700,
    );

    if (pickedFile == null) {
      return;
    } else {
      var imageBytes = await pickedFile.readAsBytes();

      try {
        img.Image? originalImage = img.decodeImage(imageBytes);
        if (originalImage != null) {
          if (originalImage.width > 800 || originalImage.height > 800) {
            img.Image resizedImage = img.copyResize(originalImage,
                width: originalImage.width > originalImage.height ? 800 : null,
                height:
                    originalImage.height >= originalImage.width ? 800 : null);
            imageBytes = Uint8List.fromList(img.encodePng(resizedImage));
          }
        }
      } catch (e) {
        print('Error resizing image: $e');
      }

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

  Future<void> OKuploadFile_Slip(newValuePDFimg) async {
    String Path_foder = 'slip';
    String dateTimeNow = DateTime.now().toString();
    String date = DateFormat('ddMMyyyy')
        .format(DateTime.parse('${dateTimeNow}'))
        .toString();
    final dateTimeNow2 = DateTime.now().toUtc().add(const Duration(hours: 7));
    final formatter2 = DateFormat('HHmmss');
    final formattedTime2 = formatter2.format(dateTimeNow2);
    String Time_ = formattedTime2.toString();

    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ciddoc_ = widget.teNantModel == null
        ? preferences.getString('usercid')
        : preferences.getString('custno');
    var qutser_ = preferences.getString('qutser');
    ////////////////------------------------------------------------------>
    var fileName_Slip_ = 'slip_${ciddoc_}_${date}_$Time_';
    setState(() {
      fileName_Slip = 'slip_${ciddoc_}_${date}_$Time_.$extension_';
    });
    try {
      final imageBase64 = (base64_Slip == 'ready' && _slipImageBytes != null)
          ? base64Encode(_slipImageBytes!)
          : base64_Slip;
      final url =
          '${MyConstant().domain_chao}/File_uploadSlip_NewEdit.php?name=$fileName_Slip&Foder=$foder&extension=$extension_';

      final response = await http.post(
        Uri.parse(url),
        body: {
          'image': imageBase64,
          'Foder': foder,
          'name': fileName_Slip,
          'ex': extension_.toString()
        },
      );

      if (response.statusCode == 200) {
        // //print('Image uploaded successfully');
      } else {
        // //print('Image upload failed');
      }
    } catch (e) {
      // //print('Error during image processing: $e');
    }
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
          Text(widget.cuslang == 'EN' ? 'Payment method' : 'วิธีชำระเงิน',
              style: const TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontWeight: FontWeight.w800,
                  fontSize: 15)),
          const SizedBox(height: 10),
          step(
              1,
              widget.cuslang == 'EN'
                  ? 'Verify that the "information" is correct.'
                  : 'ตรวจสอบ “ข้อมูล”  ว่าถูกต้องหรือไม่'),
          step(
              2,
              widget.cuslang == 'EN'
                  ? 'Press “Save” the PromptPay QR code image above to your mobile phone.'
                  : 'กด “บันทึก” รูป QR พร้อมเพย์ด้านบนลงในโทรศัพท์มือถือของคุณ'),
          step(
              3,
              widget.cuslang == 'EN'
                  ? 'Open your banking application to make a payment.'
                  : 'เปิดแอปพลิเคชันธนาคารที่คุณมี เพื่อชำระเงิน'),
          step(
              4,
              widget.cuslang == 'EN'
                  ? 'Go to the "Scan/Scan to Pay" menu and press "Image" to select the saved QR image.'
                  : 'ไปที่เมนู “สแกน/สแกนจ่าย” แล้วกด “รูปภาพ” เพื่อเลือกรูป QR ที่บันทึกไว้'),
          step(
              5,
              widget.cuslang == 'EN'
                  ? 'After completing the payment, return to the app to confirm the payment.'
                  : 'กลับมาที่แอพ เพื่อยืนยันการชำระเงิน'),
          step(
              6,
              widget.cuslang == 'EN'
                  ? 'After confirming the payment, the system will verify your payment. It may take 1-3 business days, depending on the bank.'
                  : 'เมื่อยืนยันการชำระเงินเรียบร้อยแล้ว ระบบจะตรวจสอบการชำระของคุณ อาจใช้เวลา 1-3 วันทำการ ขึ้นอยู่กับแต่ละธนาคาร'),
          step(
              7,
              widget.cuslang == 'EN'
                  ? 'Please keep the payment proof for future reference when contacting customer service.'
                  : 'โปรดเก็บหลักฐานการชำระเงินไว้ทุกครั้ง เพื่อใช้ในการติดต่อฝ่ายบริการลูกค้า'),
          step(
              8,
              widget.cuslang == 'EN'
                  ? 'If you encounter any issues during payment, please contact customer service.'
                  : 'หากเกิดปัญหาในการชำระเงิน กรุณาติดต่อฝ่ายบริการลูกค้า'),
        ],
      ),
    );
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
    double qrSize = isDesktop ? 120 : 120;
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
    final bank = (payment_bank ?? '').toString();
    final bankInfo = bankCodeMap[bank];
    final bankCode = bankInfo?['code'];
    final bankEn = bankInfo?['en'];
    final bankName = widget.cuslang == 'EN' ? (bankEn ?? bank) : bank;
    final bankCodeText =
        (bankCode == null || bankCode.isEmpty) ? '' : ' ($bankCode)';
    final bankDisplayName =
        '${widget.cuslang == 'EN' ? 'Bank ' : 'ธนาคาร '}$bankName$bankCodeText';
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

    debugPrint('💳 _QRBox refs: ref1=$ref1, ref2=$ref2, ref3=$ref3');
    debugPrint(
        '💳 return_qr_refapi values: ${return_qr_refapi1 ?? "NULL"}, ${return_qr_refapi2 ?? "NULL"}, ${return_qr_refapi3 ?? "NULL"}');

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

    // ✅ ใช้ qrDataNoIntens ที่ถูกสร้างใน QrGenRef แล้ว (เหมือน V3)
    final qrData = qrDataNoIntens ?? "";

    // debugPrint('💳 Generated QR Data ');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          Card(
            color: Colors.white,
            elevation: 0.4,
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // QR Code Area
                RepaintBoundary(
                  key: useKey,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                                              await QrGenRef(
                                                  QR_Ref1: '',
                                                  QR_Ref2: '',
                                                  QR_Ref3: '',
                                                  softExpireAt: '');
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
                                : (_isExporting)
                                    ? Container(
                                        width: double.infinity,
                                        height: qrSize + qrSize,
                                        color: Colors.white, // Safe placeholder
                                      )
                                    : Image.network(
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
                                              child: CircularProgressIndicator(
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
                                                    fontFamily: Font_.Fonts_T,
                                                    color: Colors.black54,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        ] else if (payment_tser == '7' ||
                            payment_tser == '6' ||
                            payment_tser == '5') ...[
                          // Image.asset(
                          //   'images/thai_qr_payment.png',
                          //   width: double.infinity,
                          //   fit: BoxFit.contain,
                          // ),
                          // SizedBox(height: isMobile ? 4 : 4),
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14)),
                            child: Image.asset(
                              'images/thai_qr_payment_2.png',
                              width: double.infinity,
                              height: 65,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          // Reminder to attach slip — flush with banner
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.indigo.shade100, width: 0.7),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_outlined,
                                    size: 14, color: Colors.red.shade700),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      widget.cuslang == 'EN'
                                          ? 'Don \'t forget to attach your payment slip after paying.'
                                          : 'อย่าลืมแนบหลักฐานการชำระเงินหลังจากชำระแล้ว',
                                      style: TextStyle(
                                        fontFamily: Font_.Fonts_T,
                                        fontSize: 11,
                                        color: Colors.indigo.shade700,
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // const SizedBox(height: 2),
                          if (Payment_remark != 'null' &&
                              Payment_remark != '' &&
                              Payment_remark!.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                border: Border(
                                  bottom: BorderSide(
                                      color: Colors.indigo.shade100,
                                      width: 0.7),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      size: 14, color: Colors.orange.shade700),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        widget.cuslang == 'EN'
                                            ? Payment_remark! ?? ""
                                            : Payment_remark! ?? "",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: Font_.Fonts_T,
                                          fontSize: 11,
                                          color: Colors.orange.shade700,
                                          fontWeight: FontWeight.w600,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  InkWell(
                                      onTap: () {
                                        Clipboard.setData(new ClipboardData(
                                            text: '$Payment_remark'));
                                        Fluttertoast.showToast(
                                            timeInSecForIosWeb: 3,
                                            msg: widget.cuslang == 'EN'
                                                ? 'Copy : $Payment_remark'
                                                : 'คัดลอก : $Payment_remark',
                                            backgroundColor: Colors.black,
                                            textColor: Colors.white,
                                            webPosition: "center",
                                            webBgColor: "#000000",
                                            toastLength: Toast.LENGTH_SHORT);
                                      },
                                      child: Icon(
                                        Icons.content_copy_outlined,
                                        size: 14,
                                        color: Colors.grey.shade600,
                                      )),
                                ],
                              ),
                            ),
                            // Text(
                            //   widget.cuslang == 'EN'
                            //       ? 'Remark: ' + Payment_remark! ?? ""
                            //       : 'หมายเหตุ: ' + Payment_remark! ?? "",
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     fontFamily: Font_.Fonts_T,
                            //     fontWeight: FontWeight.w700,
                            //     fontSize: isDesktop ? 12 : 11,
                            //     color: Colors.black.withOpacity(.65),
                            //   ),
                            // ),
                          ],
                          const SizedBox(height: 8),
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
                                            await QrGenRef(
                                                QR_Ref1: '',
                                                QR_Ref2: '',
                                                QR_Ref3: '',
                                                softExpireAt: '');
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
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.contain)
                                          : PrettyQr(
                                              size: 100,
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
                        SizedBox(height: isMobile ? 2 : 2),
                        Text(
                          '฿${nFormat.format(double.parse(Form_payment1.text))}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontWeight: FontWeight.w700,
                            fontSize: isDesktop ? 18 : 16,
                            color: Colors.red.shade800,
                          ),
                        ),
                        const SizedBox(height: 0),
                        Text(
                          '$payment_bname',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontWeight: FontWeight.w700,
                            fontSize: isDesktop ? 15 : 14,
                            color: Colors.black.withOpacity(.65),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$selectedValue',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: Font_.Fonts_T,
                                fontWeight: FontWeight.w700,
                                fontSize: isDesktop ? 15 : 14,
                                color: Colors.black.withOpacity(.65),
                              ),
                            ),
                            if (payment_tser != '5' && payment_tser != '6') ...[
                              const SizedBox(width: 6),
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
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  )),
                            ]
                          ],
                        ),
                        const SizedBox(height: 2),
                        Divider(height: 1, color: Colors.grey.shade300),
                        const SizedBox(height: 2),
                        Text(
                          bankDisplayName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontWeight: FontWeight.w700,
                            fontSize: isDesktop ? 12 : 11,
                            color: Colors.black.withOpacity(.65),
                          ),
                        ),
                        const SizedBox(height: 2),
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: Font_.Fonts_T,
                                fontWeight: FontWeight.w700,
                                fontSize: isDesktop ? 10 : 8,
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

                                // ✅ ใช้ qrDataNoIntens ที่ถูกสร้างใน QrGenRef แล้ว (เหมือน _QRBox)
                                try {
                                  final qrData = qrDataNoIntens ?? '';

                                  final cpuQrBytes =
                                      await buildQrPngWithCenterLogo(
                                    data: qrData,
                                    assetLogoPath: 'images/icon_thaiqr.png',
                                    sizePx: 800,
                                    bottomText:
                                        '฿${nFormat.format(double.parse(Form_payment1.text))}',
                                    bottomname: '$payment_bname',
                                    bottombankno: '$selectedValue',
                                    bottomRef: widget.cuslang == 'EN'
                                        ? 'Pay within $QR_Date15Min  |  Ref: $return_qr_refapi1'
                                        : 'ชำระภายใน $QR_Date15Min  |  Ref: $return_qr_refapi1',
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
                                        timeInSecForIosWeb: 3,
                                        msg: widget.cuslang == 'EN'
                                            ? "Saved (Text not supported on iOS Web)"
                                            : "บันทึกแล้ว (ไม่รองรับข้อความบน iOS Web)",
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                        webPosition: "center",
                                        webBgColor: "#000000",
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
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      clipBehavior: Clip.antiAlias,
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
                          '${widget.cuslang == 'EN' ? 'Fine' : 'ค่าปรับ'}: ${nFormat.format(lateFee)}',
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

    if (paymentIntents.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayIntents = paymentIntents.take(4).toList();

    return Column(
      children: displayIntents.map((intent) {
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

        final bool isWaitingCheck =
            statusIntentUuid.toString() == 'รอตรวจสอบ' ||
                statusIntentUuid.toString() == 'รอการตรวจสอบ';
        final bool isSlipUploaded =
            systemStatusIntentUuid.toString() == 'slip_uploaded';
        final bool showSlipAction =
            intent.latestSlip != null || isSlipUploaded || isWaitingCheck;

        final Color stBgColor =
            isWaitingCheck ? Colors.orange.shade100 : Colors.cyan.shade100;
        final Color stTextColor =
            isWaitingCheck ? Colors.orange.shade700 : Colors.cyan.shade700;

        return Card(
          elevation: 0.4,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -4),
              initiallyExpanded: false,
              tilePadding:
                  const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 0),
              childrenPadding:
                  const EdgeInsets.only(left: 12, right: 12, bottom: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              trailing: const Icon(Icons.keyboard_arrow_down,
                  color: Colors.grey, size: 20),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: stBgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: stTextColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                                widget.cuslang == 'EN'
                                    ? '${systemStatusIntentUuid}'
                                    : '${statusIntentUuid}',
                                style: TextStyle(
                                  color: stTextColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '#${paymentIntentUuid ?? '-'}',
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11.5,
                              fontFamily: Font_.Fonts_T),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '฿${nFormat.format(totalAmount)}',
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 5),
                        Flexible(
                          flex: 3,
                          child: Text(
                            widget.cuslang == 'EN'
                                ? 'Expire ${_fmtExpireLocal(softExpireAt)}'
                                : 'หมดอายุ ${_fmtExpireLocal(softExpireAt)}',
                            style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 11.5,
                                fontFamily: Font_.Fonts_T),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.receipt_long,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 5),
                        Flexible(
                          flex: 1,
                          child: Text(
                            widget.cuslang == "EN"
                                ? "$billCount Bill"
                                : "$billCount บิล",
                            style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 11.5,
                                fontFamily: Font_.Fonts_T),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: showSlipAction
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () async {
                              setState(() {
                                numinvoice = intent.intentUuid;
                                sum_amt = totalAmount;
                              });
                              await QrGenRef(
                                QR_Ref1: intent.ref1 ?? '',
                                QR_Ref2: intent.ref2 ?? '',
                                QR_Ref3: intent.ref3 ?? '',
                                softExpireAt:
                                    intent.softExpireAt?.toIso8601String() ??
                                        '',
                              );
                              if (!mounted) return;
                              _showPaymentConfirmationSheet(context,
                                  totalAmount: totalAmount);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.description_outlined,
                                      color: Colors.indigo.shade800, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.cuslang == "EN"
                                        ? "Payment proof"
                                        : "หลักฐานการชำระ",
                                    style: TextStyle(
                                      color: Colors.indigo.shade800,
                                      fontFamily: Font_.Fonts_T,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(Icons.chevron_right,
                                      color: Colors.indigo.shade800, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () async {
                              setState(() {
                                numinvoice = intent.intentUuid;
                                sum_amt = totalAmount;
                              });
                              await QrGenRef(
                                QR_Ref1: intent.ref1 ?? '',
                                QR_Ref2: intent.ref2 ?? '',
                                QR_Ref3: intent.ref3 ?? '',
                                softExpireAt:
                                    intent.softExpireAt?.toIso8601String() ??
                                        '',
                              );
                              if (!mounted) return;
                              _showPaymentConfirmationSheet(context,
                                  totalAmount: totalAmount);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.credit_card,
                                      color: Colors.indigo.shade800, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.cuslang == "EN"
                                        ? "Press to pay"
                                        : "กดเพื่อยืนยัน",
                                    style: TextStyle(
                                      color: Colors.indigo.shade800,
                                      fontFamily: Font_.Fonts_T,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // const Spacer(),
                                  // Icon(Icons.chevron_right,
                                  //     color: Colors.indigo.shade800, size: 20),
                                ],
                              ),
                            ),
                          ),
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
    final PaymaentRemark =
        _PayMentModels.isNotEmpty ? (_PayMentModels[0].remark ?? '') : '';
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
                          '${widget.cuslang == 'EN' ? 'Fine' : 'ค่าปรับ'}: ${nFormat.format(fine)}',
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
      color: Colors.white,
      elevation: 0.4,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
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
                // 10. Payment Remark
                if (PaymaentRemark != null && PaymaentRemark.isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.info, size: 15, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text('${PaymaentRemark}',
                        style: const TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontSize: 12.5,
                            color: Colors.black54)),
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
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
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
            mainAxisAlignment: MainAxisAlignment.center,
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
    if (_initialLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F3F8),
        body: Center(
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
              LoadingAnimationWidget.inkDrop(
                color: Colors.indigo,
                size: 70,
              ),
            ],
          ),
        ),
      );
    }
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
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (ctx) {
                        final isEN = widget.cuslang == 'EN';
                        return Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.orange.shade200,
                                        width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.orange
                                              .withValues(alpha: 0.25),
                                          blurRadius: 14,
                                          offset: const Offset(0, 4))
                                    ],
                                  ),
                                  child: Icon(Icons.warning_amber_rounded,
                                      color: Colors.orange.shade700, size: 38),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  isEN ? 'Warning' : 'แจ้งเตือน',
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade900,
                                      fontFamily: Font_.Fonts_T),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  isEN
                                      ? 'If paid, please attach proof and confirm.\nOr close to pay later.'
                                      : 'หากชำระแล้ว กรุณาแนบหลักฐานและยืนยัน',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      fontFamily: Font_.Fonts_T,
                                      height: 1.6),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                // Primary: แนบหลักฐาน
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                          colors: [
                                            Colors.indigo,
                                            Color(0xFF283593)
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.indigo
                                                .withValues(alpha: 0.35),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4))
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(14),
                                        onTap: () async {
                                          Navigator.of(ctx, rootNavigator: true)
                                              .pop();
                                        },
                                        child: Center(
                                            child: Text(
                                                isEN
                                                    ? 'Attach Proof'
                                                    : 'แนบหลักฐาน',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Secondary: ชำระภายหลัง
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: Colors.grey.shade400),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                    ),
                                    onPressed: () async {
                                      final nav = Navigator.of(ctx,
                                          rootNavigator: true);
                                      final rootNav = Navigator.of(context);
                                      SharedPreferences preferences =
                                          await SharedPreferences.getInstance();
                                      var custno =
                                          preferences.getString('custno');
                                      nav.pop();
                                      rootNav.pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  FitnessAppHomeScreen(
                                                      custno_s: custno)),
                                          (route) => false);
                                    },
                                    child: Text(
                                        isEN ? 'Pay Later' : 'ชำระภายหลัง',
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                    // PanaraConfirmDialog.showAnimatedGrow(
                    //   context,
                    //   title: widget.cuslang == 'EN' ? "Warning" : "แจ้งเตือน",
                    //   message: widget.cuslang == 'EN'
                    //       ? "If paid, please attach proof and confirm. Or close to pay later."
                    //       : "หากชำระแล้วอย่าลืมแนบหลักฐานและยืนยัน หรือปิดไว้ชำระอีกครั้งภายหลัง",
                    //   confirmButtonText: widget.cuslang == 'EN'
                    //       ? "Attach Proof"
                    //       : "แนบหลักฐาน",
                    //   cancelButtonText: widget.cuslang == 'EN'
                    //       ? "Pay Later"
                    //       : "ปิดไว้ชำระภายหลัง",
                    //   onTapConfirm: () {
                    //     Navigator.pop(context); // Close dialog
                    //     // _showPaymentConfirmationSheet(context);
                    //   },
                    //   onTapCancel: () {
                    //     Navigator.pop(context); // Close dialog
                    //     Navigator.pop(context); // Close screen
                    //   },
                    //   panaraDialogType: PanaraDialogType.warning,
                    //   barrierDismissible: true,
                    // );
                  },
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'images/Icon-chao.png',
                        width: 26,
                        height: 26,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.cuslang == 'EN' ? 'Payment' : 'การชำระ',
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                bottom: (selectTap == 1 &&
                        gopay != 0 &&
                        qr_expiresAt != null &&
                        activeQrSessionSoftExpire != null &&
                        activeQrSessionSoftExpire!.isNotEmpty)
                    ? PreferredSize(
                        preferredSize: const Size.fromHeight(26),
                        child: StreamBuilder<int>(
                          stream: _timerStream,
                          initialData: secondsUntilExpire(),
                          builder: (_, snap) {
                            final secs = snap.data ?? 0;
                            final clamped = secs < 0 ? 0 : secs;
                            final prog = _totalSecs > 0
                                ? (clamped / _totalSecs).clamp(0.0, 1.0)
                                : 0.0;
                            if (clamped == 0 &&
                                _uploadedSlipData == null &&
                                !_expireDialogShown &&
                                _isQrExpired()) {
                              Future.microtask(() {
                                if (!mounted) return;
                                setState(() => _expireDialogShown = true);
                              });
                            }
                            final isExp = clamped == 0;
                            final barColor = isExp
                                ? Colors.red.shade500
                                : const Color(0xFFE67E00);
                            return SizedBox(
                              height: 26,
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  Container(
                                      color: isExp
                                          ? Colors.red.shade50
                                          : const Color(0xFFFFF8F0)),
                                  if (!isExp)
                                    FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: prog,
                                      child: Container(
                                          color: barColor.withOpacity(0.18)),
                                    ),
                                  Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isExp
                                              ? Icons.timer_off_rounded
                                              : Icons.timer_rounded,
                                          size: 12,
                                          color: barColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isExp
                                              ? 'QR หมดอายุแล้ว'
                                              : 'QR ใช้ได้อีก  ${_hhmmssFromSecs(clamped)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: barColor,
                                            fontFamily: Font_.Fonts_T,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : const PreferredSize(
                        preferredSize: Size.fromHeight(0),
                        child: SizedBox.shrink(),
                      )), // FAB Removed
            backgroundColor: const Color(0xFFF2F3F8),
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
                              Container(
                                margin: const EdgeInsets.only(top: 0),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: 1.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Tab 1: ค้างชำระ
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          await _initData();
                                          setState(() => selectTap = 1);
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 11),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.receipt_long_rounded,
                                                    size: 15,
                                                    color: selectTap == 1
                                                        ? Colors.black87
                                                        : Colors.grey.shade400,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    'ค้างชำระ',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: selectTap == 1
                                                          ? FontWeight.w700
                                                          : FontWeight.w500,
                                                      color: selectTap == 1
                                                          ? Colors.black87
                                                          : Colors
                                                              .grey.shade400,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 200),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 7,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: selectTap == 1
                                                          ? Colors.red.shade400
                                                          : Colors
                                                              .grey.shade200,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Text(
                                                      '${_InvoiceModels.length}',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: selectTap == 1
                                                            ? Colors.white
                                                            : Colors
                                                                .grey.shade500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 250),
                                              height: 2.5,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              decoration: BoxDecoration(
                                                color: selectTap == 1
                                                    ? Colors.black87
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Tab 2: รอยืนยัน
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          await _initData();
                                          setState(() => selectTap = 2);
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 11),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .hourglass_bottom_rounded,
                                                    size: 15,
                                                    color: selectTap == 2
                                                        ? Colors.black87
                                                        : Colors.grey.shade400,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    'รอยืนยัน',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: selectTap == 2
                                                          ? FontWeight.w700
                                                          : FontWeight.w500,
                                                      color: selectTap == 2
                                                          ? Colors.black87
                                                          : Colors
                                                              .grey.shade400,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 200),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 7,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: selectTap == 2
                                                          ? Colors
                                                              .orange.shade500
                                                          : Colors
                                                              .grey.shade200,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Text(
                                                      '${paymentIntents.length}',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: selectTap == 2
                                                            ? Colors.white
                                                            : Colors
                                                                .grey.shade500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 250),
                                              height: 2.5,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              decoration: BoxDecoration(
                                                color: selectTap == 2
                                                    ? Colors.black87
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            bottomNavigationBar: (selectTap == 2)
                ? null
                : Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: () {
                        final bool noInvoice = _InvoiceModels.isEmpty;
                        final bool isConfirm = paymentSer1 != null &&
                            gopay != 0 &&
                            qr_expiresAt != null;
                        final bool isEN = widget.cuslang == 'EN';

                        final List<Color> grad = noInvoice
                            ? [Colors.grey.shade300, Colors.grey.shade400]
                            : isConfirm
                                ? [
                                    const Color(0xFFFF8F00),
                                    const Color(0xFFE65100),
                                  ]
                                : [
                                    const Color(0xFF43A047),
                                    const Color(0xFF00897B),
                                  ];

                        final IconData icon = noInvoice
                            ? Icons.remove_circle_outline_rounded
                            : isConfirm
                                ? Icons.attach_file_rounded
                                : select_pay == 0
                                    ? Icons.arrow_forward_rounded
                                    : Icons.payment_rounded;

                        final String label = noInvoice
                            ? (isEN ? 'No Payment Amount' : 'ไม่มียอดชำระ')
                            : select_pay == 0
                                ? (isEN ? 'Payment Next' : 'ชำระเงินต่อไป')
                                : isConfirm
                                    ? (isEN
                                        ? 'Confirm Payment'
                                        : 'กดเพื่อ "แนบหลักฐานและยืนยัน"')
                                    : (isEN
                                        ? 'Start Payment'
                                        : 'กดเพื่อ "เริ่มการชำระ"');

                        return Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: grad,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: noInvoice
                                ? []
                                : [
                                    BoxShadow(
                                      color: grad.last.withValues(alpha: 0.45),
                                      blurRadius: 14,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: noInvoice
                                  ? () {
                                      _showNoPaymentWarningDialog(isEN);
                                    }
                                  : isConfirm
                                      ? () async {
                                          _showPaymentConfirmationSheet(context,
                                              totalAmount: double.parse(
                                                  Form_payment1.text ?? "0"));
                                        }
                                      : () async {
                                          // Reset expired QR state before creating new
                                          if (_isQrExpired()) {
                                            setState(() {
                                              qr_expiresAt = null;
                                              qr_softExpiresAt = null;
                                              activeQrSessionSoftExpire = null;
                                              numinvoice = null;
                                              gopay = 0;
                                            });
                                          }
                                          await CreatePaymentItem();
                                        },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(icon, color: Colors.white, size: 22),
                                  const SizedBox(width: 10),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }(),
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

  Future<void> _showNoPaymentWarningDialog(bool isEN) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange.shade200, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Oops',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                    fontFamily: Font_.Fonts_T,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isEN ? 'No payment amount!!!' : 'ไม่มียอดชำระ !!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontFamily: Font_.Fonts_T,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.indigo, Color(0xFF283593)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
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
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.of(ctx, rootNavigator: true).pop();
                        },
                        child: Center(
                          child: Text(
                            isEN ? 'acknowledge' : 'รับทราบ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: Font_.Fonts_T,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
        : invoicePay!.substring(0, invoicePay!.length - 1); // string
    var io4 = invoicePayfine == null || invoicePayfine == ''
        ? '0'
        : invoicePayfine!.substring(0, invoicePayfine!.length - 1); // string

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

  Future<Null> in_Trans_invoice(newValuePDFimg) async {
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
        : invoicePay!.substring(0, invoicePay!.length - 1); // string
    var io4 = invoicePayfine == null || invoicePayfine == ''
        ? '0'
        : invoicePayfine!.substring(0, invoicePayfine!.length - 1); // string

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

    // print('$paybyselect url $uri ');

    try {
      var response = await http.get(uri);

      var result = json.decode(response.body);

      if (result.toString() != 'No') {
        for (var map in result) {
          CFinnancetransModel cFinnancetransModel =
              CFinnancetransModel.fromJson(map);
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
      if (mounted) {
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

  Future<void> _processPaymentConfirmation(BuildContext ctx) async {
    Navigator.of(ctx).pop(); // Close the dialog
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List newValuePDFimg = [];
    for (int index = 0; index < 1; index++) {
      if (renTalModels[0].imglogo!.trim() != '') {
        newValuePDFimg.add(
            '${MyConstant().domain_chao}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
      }
    }
    try {
      sucress(onDismiss: () {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
          return FitnessAppHomeScreen(
              custno_s: preferences.getString('custno'));
        }), (route) => false);
      });
      OKuploadFile_Slip(newValuePDFimg)
          .then((value) => in_Trans_invoice(newValuePDFimg));
    } catch (e) {
      _showMyDialogPay_Error(widget.cuslang == 'EN'
          ? "An error occurred. Please check the information. Please try again!"
          : 'เกิดข้อผิดพลาด ตรวจสอบความถูกต้อง กรุณาลองอีกครั้ง!');
    }
  }

  void _showSlideConfirmDialog() {
    if (!mounted) return;
    showDialog(
      context: context, // uses this.context
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        width: 4,
                        height: 22,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        widget.cuslang == 'EN'
                            ? 'Confirm Payment'
                            : 'ยืนยันการชำระเงิน',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple),
                      ),
                    ]),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 14),
              if (_uploadedSlipData != null)
                Container(
                  height: 240,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.1,
                      maxScale: 4.0,
                      child:
                          Image.memory(_uploadedSlipData!, fit: BoxFit.contain),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      widget.cuslang == 'EN'
                          ? 'Slip attached'
                          : 'หลักฐานแนบแล้ว',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade700,
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          widget.cuslang == 'EN'
                              ? "${nFormat.format(double.parse(Form_payment1.text))} THB"
                              : "${nFormat.format(double.parse(Form_payment1.text))} บาท",
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: _SlideToConfirm(
                  label: widget.cuslang == 'EN'
                      ? 'Slide to Confirm'
                      : 'เลื่อนเพื่อยืนยัน',
                  enabled: true,
                  onConfirmation: () async {
                    // Trigger file picker
                    // final success = await _pickSlipImage();
                    if (base64_Slip != null) {
                      if (!mounted) return;
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );
                      final successUp = await _uploadSlipImage(
                          amtRawSlip: sum_amt.toString());
                      if (mounted) {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (context) {
                          return FitnessAppHomeScreen(custno_s: custno);
                        }), (route) => false);
                        if (successUp) {
                          Fluttertoast.showToast(
                              timeInSecForIosWeb: 3,
                              msg: widget.cuslang == 'EN'
                                  ? "Slip upload successful"
                                  : 'อัปโหลดสลิปสำเร็จ',
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              webPosition: "center",
                              webBgColor: "#000000",
                              toastLength: Toast.LENGTH_SHORT);
                        }
                      }
                    }
                    // _processPaymentConfirmation(ctx);
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _DetailsPaymentIntentsReload() async {
    String _toU16(String? v) => (v ?? '0').trim();

    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer');
      final String custnoLocal =
          _TransModels.isNotEmpty ? '${_TransModels.first.custno ?? ''}' : '';

      final custno16Bit = _toU16(custnoLocal).toString();
      final ren16Bit = _toU16('$ren').toString();

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

      // ✅ ถ้า session ยังไม่หมดอายุ → ไม่ต้องยิง /generate (จะ error 409)
      // โหลดค่าเดิมจาก GET /intent/{uuid} ได้เลย
      if (!_isQrExpired() && activeQrSessionSoftExpire != null) {
        debugPrint('⏳ Session ยังไม่หมด → โหลดจาก details แทน /generate');
        final details = await _DetailsPaymentIntentsReload();
        final existingSession =
            details?['active_qr_session'] as Map<String, dynamic>?;
        if (existingSession == null) return false;

        final sessionExpire = existingSession['soft_expire_at'] as String?;
        setState(() {
          return_qr_refapi1 = existingSession['ref1'] as String?;
          return_qr_refapi2 = existingSession['ref2'] as String?;
          return_qr_refapi3 = existingSession['ref3'] as String?;
          qr_payload = (existingSession['payload'] as String?) ?? '';
          activeQrSessionSoftExpire = sessionExpire;
          qr_expiresAt = sessionExpire;
          qr_softExpiresAt = sessionExpire;
          _expireDialogShown = false;
        });
        debugPrint('✅ Loaded existing session: expire=$sessionExpire');
        return true;
      }

      // Session หมดอายุแล้ว → ยิง /generate สร้างใหม่
      debugPrint('🆕 Session หมดอายุ → POST /generate');
      final resp = await postGeneratePaymentIntents(
        cusNo: custno16Bit,
        propertyNo: ren16Bit,
        intentsUuid: intentsUuid,
        bankMerchantId: int.tryParse('$paymentSer1') ?? 0,
      );

      // 409 = server ยังถือว่า session active → โหลดดูว่าหมดอายุจริงหรือเปล่า
      if (resp?.statusCode == 409) {
        debugPrint('⚠️ 409 → checking if existing session is truly expired');
        final details = await _DetailsPaymentIntentsReload();
        final existingSession =
            details?['active_qr_session'] as Map<String, dynamic>?;
        if (existingSession == null) return false;

        final sessionExpire = existingSession['soft_expire_at'] as String?;
        final sessionDate =
            sessionExpire != null ? DateTime.tryParse(sessionExpire) : null;
        final isExpired =
            sessionDate == null || DateTime.now().isAfter(sessionDate);

        if (isExpired) {
          // session หมดจริง → รอ 1 วิแล้วยิง /generate อีกครั้ง
          debugPrint(
              '🔁 Existing session expired → wait 1s then retry /generate');
          await Future.delayed(const Duration(seconds: 1));
          final retryResp = await postGeneratePaymentIntents(
            cusNo: custno16Bit,
            propertyNo: ren16Bit,
            intentsUuid: intentsUuid,
            bankMerchantId: int.tryParse('$paymentSer1') ?? 0,
          );
          if (retryResp != null &&
              retryResp.statusCode >= 200 &&
              retryResp.statusCode < 300) {
            debugPrint('✅ Retry /generate succeeded');
            // ดำเนินการต่อด้านล่าง
            final retryRoot = json.decode(retryResp.body);
            final retryData = retryRoot['data'] ?? retryRoot;
            Map<String, dynamic>? retrySession =
                retryData['active_qr_session'] as Map<String, dynamic>?;
            if (retrySession == null) {
              final d = await _DetailsPaymentIntentsReload();
              retrySession = d?['active_qr_session'] as Map<String, dynamic>?;
            }
            final retryExpire = retrySession?['soft_expire_at'] as String?;
            setState(() {
              return_qr_refapi1 =
                  (retrySession?['ref1'] as String?) ?? retryData['ref1'];
              return_qr_refapi2 =
                  (retrySession?['ref2'] as String?) ?? retryData['ref2'];
              return_qr_refapi3 =
                  (retrySession?['ref3'] as String?) ?? retryData['ref3'];
              qr_payload = (retrySession?['payload'] as String?) ??
                  retryData['payload'] ??
                  '';
              activeQrSessionSoftExpire =
                  retryExpire ?? retryData['soft_expire_at'];
              qr_expiresAt = activeQrSessionSoftExpire;
              qr_softExpiresAt = activeQrSessionSoftExpire;
              _expireDialogShown = false;
            });
            debugPrint('✅ New session: expire=$retryExpire');
            return true;
          }
          // Server ยัง 409 → QR เก่าบน server ยังใช้ได้จริง
          // ใช้ session เดิมกับ timer จาก bill deadline
          debugPrint(
              '⚠️ Retry 409 → QR still valid on server, using existing session');
          final billDeadlineStr = details?['soft_expire_at'] as String?;
          final useExpire = (billDeadlineStr?.isNotEmpty == true)
              ? billDeadlineStr
              : sessionExpire;
          setState(() {
            return_qr_refapi1 = existingSession['ref1'] as String?;
            return_qr_refapi2 = existingSession['ref2'] as String?;
            return_qr_refapi3 = existingSession['ref3'] as String?;
            qr_payload = (existingSession['payload'] as String?) ?? '';
            activeQrSessionSoftExpire = useExpire;
            qr_expiresAt = useExpire;
            qr_softExpiresAt = useExpire;
            _expireDialogShown = false;
          });
          debugPrint('✅ Using existing session with bill deadline: $useExpire');
          return true;
        }

        // session ยังไม่หมดจริง → ใช้ค่าเดิม
        setState(() {
          return_qr_refapi1 = existingSession['ref1'] as String?;
          return_qr_refapi2 = existingSession['ref2'] as String?;
          return_qr_refapi3 = existingSession['ref3'] as String?;
          qr_payload = (existingSession['payload'] as String?) ?? '';
          activeQrSessionSoftExpire = sessionExpire;
          qr_expiresAt = sessionExpire;
          qr_softExpiresAt = sessionExpire;
          _expireDialogShown = false;
        });
        debugPrint('✅ Session still valid: expire=$sessionExpire');
        return true;
      }

      if (resp == null || resp.statusCode < 200 || resp.statusCode >= 300) {
        debugPrint('renew fail: ${resp?.statusCode} ${resp?.body}');
        return false;
      }

      final root = json.decode(resp.body);
      debugPrint('🟢 QR Generate Response: $root');

      // Extract data from nested structure
      final data = root['data'] ?? root;

      // generate endpoint อาจไม่มี active_qr_session → reload details
      Map<String, dynamic>? activeSession =
          data['active_qr_session'] as Map<String, dynamic>?;

      if (activeSession == null) {
        final details = await _DetailsPaymentIntentsReload();
        activeSession = details?['active_qr_session'] as Map<String, dynamic>?;
        debugPrint('🔄 Reloaded details for session: $activeSession');
      }

      final sessionExpire = activeSession?['soft_expire_at'] as String?;
      final billExpire = data['soft_expire_at'] as String?;

      // Debug: แสดงอายุ session และ bill
      final sessionDate = sessionExpire != null
          ? DateTime.tryParse(sessionExpire)?.toLocal()
          : null;
      final billDate =
          billExpire != null ? DateTime.tryParse(billExpire)?.toLocal() : null;
      final sessionMins = sessionDate != null
          ? sessionDate.difference(DateTime.now()).inSeconds / 60
          : 0;
      final billMins = billDate != null
          ? billDate.difference(DateTime.now()).inSeconds / 60
          : 0;
      debugPrint(
          '🆕 Gen ครั้งแรก: session=${sessionMins.toStringAsFixed(1)} นาที ($sessionExpire)');
      debugPrint(
          '🆕 Gen ครั้งแรก: bill=${billMins.toStringAsFixed(1)} นาที ($billExpire)');

      setState(() {
        return_qr_refapi1 = (activeSession?['ref1'] as String?) ?? data['ref1'];
        return_qr_refapi2 = (activeSession?['ref2'] as String?) ?? data['ref2'];
        return_qr_refapi3 = (activeSession?['ref3'] as String?) ?? data['ref3'];
        qr_payload =
            (activeSession?['payload'] as String?) ?? data['payload'] ?? '';
        activeQrSessionSoftExpire = sessionExpire ?? billExpire;
        qr_expiresAt = activeQrSessionSoftExpire;
        qr_softExpiresAt = activeQrSessionSoftExpire;
        _expireDialogShown = false;
      });

      debugPrint(
          '✅ Renew done: session=$sessionExpire, bill=${data['soft_expire_at']}');
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
      barrierDismissible: true,
    );
  }

  Future<bool> _pickSlipImage() async {
    final completer = Completer<bool>();
    var isProcessingVisible = false;

    // Helper to show loading
    void _showProcessing() {
      if (isProcessingVisible || !mounted) return;
      isProcessingVisible = true;
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
      if (!isProcessingVisible || !mounted) return;
      isProcessingVisible = false;
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
            final Uint8List? finalImage =
                images.length == 1 ? images.first : await _mergeImages(images);

            if (finalImage != null) {
              if (mounted) {
                setState(() {
                  _slipImageBytes = finalImage;
                  _slipImageName =
                      files.length > 1 ? "merged_slip.jpg" : "slip_upload.jpg";
                  _uploadedSlipData = _slipImageBytes;
                  base64_Slip = 'ready';
                  extension_ = 'jpg';
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
        final List<XFile> images = await picker.pickMultiImage(
          imageQuality: 55,
          maxWidth: 700,
          maxHeight: 700,
        );

        if (images.isNotEmpty) {
          _showProcessing();
          await Future.delayed(const Duration(milliseconds: 80));

          final List<Uint8List> imageBytesList = await Future.wait(
            images.map((imgFile) => imgFile.readAsBytes()),
          );

          final Uint8List? finalImage = imageBytesList.length == 1
              ? imageBytesList.first
              : await _mergeImages(imageBytesList);

          if (finalImage != null) {
            if (mounted) {
              setState(() {
                _slipImageBytes = finalImage;
                _slipImageName =
                    images.length > 1 ? "merged_slip.jpg" : "slip_upload.jpg";
                _uploadedSlipData = _slipImageBytes;
                base64_Slip = 'ready';
                extension_ = 'jpg';
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
        _hideProcessing();
        completer.complete(false);
      }
    }

    return completer.future;
  }

  Future<Uint8List?> _mergeImages(List<Uint8List> images) async {
    return compute(_processSlipMergeImages, SlipMergeParams(images: images))
        .timeout(
      const Duration(seconds: 12),
      onTimeout: () {
        debugPrint('Slip image processing timed out');
        return images.isNotEmpty ? images.first : null;
      },
    );
  }

  Uint8List? _slipPreviewBytes() {
    if (_uploadedSlipData != null) return _uploadedSlipData;
    if (_slipImageBytes != null) return _slipImageBytes;
    final raw = base64_Slip;
    if (raw == null || raw.isEmpty || raw == 'ready') return null;

    try {
      return base64Decode(raw);
    } catch (e) {
      debugPrint('Invalid slip preview base64: $e');
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

  Future<void> _showCancelPaymentDialog(BuildContext ctx) {
    Widget _howToBoxExpired() {
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
                    color: Colors.orange.withOpacity(.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: Colors.orange.withOpacity(.25), width: .7),
                  ),
                  child: Text('$i',
                      style: TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.w900,
                          color: Colors.orange.shade700)),
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
                widget.cuslang == 'EN'
                    ? 'Please follow the steps below to restart the payment.'
                    : 'กรุณาทำตามขั้นตอนด้านล่างเพื่อเริ่มการชำระเงินใหม่',
                style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w800,
                    fontSize: 15)),
            const SizedBox(height: 10),
            step(
                1,
                widget.cuslang == 'EN'
                    ? 'If you have already made the payment, please attach the proof of transfer and press "Confirm Payment" below.'
                    : 'หากชำระแล้วกรุณาแนบหลักฐานการโอนเงิน และกด "ยืนยันการชำระเงิน" ด้านล่าง'),
            step(
                2,
                widget.cuslang == 'EN'
                    ? 'If you have not made the payment and the payment reference number has expired, please cancel the payment reference number and start a new payment.'
                    : 'หากยังไม่ชำระ และเลขที่ชำระเงินหมดอายุ ให้กดยกเลิกเลขที่รายการชำระเงิน แล้วกดเริ่มต้นการชำระเงินใหม่'),
            step(
                3,
                widget.cuslang == 'EN'
                    ? 'Once you have attached the proof of transfer, you will not be able to cancel the payment.'
                    : 'หากแนบหลักฐานการโอนเงินแล้ว จะไม่สามารถยกเลิกการชำระเงินได้'),
          ],
        ),
      );
    }

    return showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (BuildContext dialogCtx) {
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.cuslang == 'EN'
                              ? "Cancel Payment"
                              : "ยกเลิกการชำระเงิน",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: Font_.Fonts_T),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                _howToBoxExpired(),
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
                        color: Colors.red,
                        label: widget.cuslang == 'EN'
                            ? 'Confirm Cancellation and Restart'
                            : 'ยืนยันการยกเลิกและเริ่มต้นใหม่',
                        enabled: base64_Slip == null || base64_Slip == '',
                        onConfirmation: () async {
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final ren = prefs.getString('renTalSer');
                            final ren16Bit = _toU16('$ren').toString();
                            final String custnoLocal = _TransModels.isNotEmpty
                                ? '${_TransModels.first.custno ?? ''}'
                                : (prefs.getString('custno') ?? '');
                            final custno16Bit = _toU16(custnoLocal).toString();
                            final response =
                                await DeletePaymentIntents_UuidCanceled(
                                    cusNo: custno16Bit,
                                    propertyNo: ren16Bit,
                                    intentsUuid: numinvoice.toString(),
                                    bankMerchantId: bankMerchantId ?? 0);
                            if (response != null &&
                                response.statusCode >= 200 &&
                                response.statusCode < 300) {
                              Fluttertoast.showToast(
                                  timeInSecForIosWeb: 3,
                                  msg: widget.cuslang == 'EN'
                                      ? "Payment cancelled successfully."
                                      : 'ยกเลิกการชำระเงินสำเร็จแล้ว',
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  webPosition: "center",
                                  webBgColor: "#000000",
                                  toastLength: Toast.LENGTH_SHORT);
                              if (!mounted) return;
                              Navigator.pushAndRemoveUntil(ctx,
                                  MaterialPageRoute(builder: (context) {
                                return FitnessAppHomeScreen(custno_s: custno);
                              }), (route) => false);
                            } else {
                              Navigator.pop(ctx);
                              Navigator.pop(ctx);
                            }
                          } catch (e) {
                            debugPrint('❌ Cancel Payment Exception: $e');
                            Navigator.pop(ctx);
                            Navigator.pop(ctx);
                          }
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
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

                                  // QR หมดอายุ → ปิด popup ให้อัตโนมัติ
                                  if (clamped == 0 &&
                                      _uploadedSlipData == null &&
                                      !_expireDialogShown &&
                                      _isQrExpired()) {
                                    Future.microtask(() {
                                      if (!ctx.mounted) return;
                                      setState(() => _expireDialogShown = true);
                                      Navigator.of(ctx).pop();
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

  void _showPaymentConfirmationSheet(BuildContext context,
      {required double totalAmount}) {
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
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (BuildContext context) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setStateSheet) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(22)),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 22,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Text(
                                  widget.cuslang == 'EN'
                                      ? 'Payment Confirmation'
                                      : 'ยืนยันการชำระเงิน',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),

                      Flexible(
                          child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 2, 20, 18),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Instructions
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 11),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.orange.shade100,
                                            Colors.orange.shade50
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                            color: Colors.orange.shade300,
                                            width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange
                                                .withValues(alpha: 0.18),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                right: 12),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade200,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.check_rounded,
                                                color: Colors.orange.shade800,
                                                size: 16),
                                          ),
                                          Expanded(
                                            child: Text(
                                              widget.cuslang == 'EN'
                                                  ? "Upload completed"
                                                  : "อัปโหลดเรียบร้อยแล้ว",
                                              style: TextStyle(
                                                color: Colors.orange.shade900,
                                                fontFamily: Font_.Fonts_T,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Container(
                                      color: Colors.white,
                                      margin: EdgeInsets.zero,
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
                                              Expanded(
                                                child: SizedBox(
                                                  height: 42,
                                                  child: OutlinedButton.icon(
                                                    onPressed: () async {
                                                      // Reset uploaded data to allow new upload
                                                      setState(() {
                                                        _uploadedSlipData =
                                                            null;
                                                      });
                                                      // Trigger file picker
                                                      final success =
                                                          await _pickSlipImage();
                                                      if (success &&
                                                          _slipImageBytes !=
                                                              null) {
                                                        if (!mounted) return;
                                                        showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              false,
                                                          builder: (BuildContext
                                                              context) {
                                                            return Center(
                                                              child: Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  const Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        CircleAvatar(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      radius:
                                                                          30,
                                                                      backgroundImage:
                                                                          AssetImage(
                                                                              'assets/images/Icon-chao.png'),
                                                                    ),
                                                                  ),
                                                                  LoadingAnimationWidget
                                                                      .inkDrop(
                                                                    color: Colors
                                                                        .indigo,
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
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(widget
                                                                            .cuslang ==
                                                                        'EN'
                                                                    ? 'Slip upload successful!'
                                                                    : 'อัปโหลดสลิปสำเร็จ!'),
                                                                backgroundColor:
                                                                    Colors
                                                                        .indigo,
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      }
                                                    },
                                                    icon: const Icon(
                                                        Icons.refresh,
                                                        size: 16),
                                                    label: Text(
                                                        widget.cuslang == 'EN'
                                                            ? 'Re-attach'
                                                            : 'แนบอีกครั้ง',
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.indigo,
                                                      side: BorderSide(
                                                          color: Colors
                                                              .indigo.shade100),
                                                      backgroundColor:
                                                          Colors.indigo.shade50,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(22),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              Expanded(
                                                child: SizedBox(
                                                  height: 42,
                                                  child: ElevatedButton.icon(
                                                    onPressed: () async {
                                                      final response =
                                                          await getSlipPreviewPaymentIntents(
                                                              slipUuid:
                                                                  intentsAttacheSlipNo ??
                                                                      "");
                                                      if (!mounted) return;

                                                      await showDialog<void>(
                                                        context: context,
                                                        barrierDismissible:
                                                            true,
                                                        builder: (BuildContext
                                                            context) {
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
                                                                      .circular(
                                                                          20),
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
                                                                            Font_.Fonts_T),
                                                                  ),
                                                                  IconButton(
                                                                    icon: Icon(
                                                                        Icons
                                                                            .close,
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
                                                                    Image
                                                                        .memory(
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
                                                                            color:
                                                                                Colors.grey),
                                                                        const SizedBox(
                                                                            height:
                                                                                10),
                                                                        Text(
                                                                          widget.cuslang == 'EN'
                                                                              ? 'Unable to load image\n(Status: ${response?.statusCode ?? 'N/A'})'
                                                                              : 'ไม่สามารถโหลดรูปภาพได้\n(Status: ${response?.statusCode ?? 'N/A'})',
                                                                          textAlign:
                                                                              TextAlign.center,
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
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.indigo,
                                                      foregroundColor:
                                                          Colors.white,
                                                      elevation: 0,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(22),
                                                      ),
                                                    ),
                                                  ),
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
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 22,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Text(
                                  widget.cuslang == 'EN'
                                      ? 'Payment Confirmation'
                                      : 'ยืนยันการชำระเงิน',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
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
                              // Instructions (V3 style: gradient + circle icon)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.shade100,
                                      Colors.orange.shade50
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Colors.orange.shade300,
                                      width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.orange.withValues(alpha: 0.18),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 1, right: 12),
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade200,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.info_rounded,
                                          color: Colors.orange.shade800,
                                          size: 18),
                                    ),
                                    Expanded(
                                      child: Text(
                                        widget.cuslang == 'EN'
                                            ? "Please upload proof of payment to complete the transaction and confirm your payment."
                                            : "กรุณาแนบหลักฐานการโอนเงินเพื่อดำเนินการให้เสร็จสมบูรณ์ และยืนยันการชำระเงิน",
                                        style: TextStyle(
                                          color: Colors.orange.shade900,
                                          fontFamily: Font_.Fonts_T,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),

                              // Upload Section header (V3 style: deepPurple icon + Required chip)
                              Row(
                                children: [
                                  const Icon(Icons.upload_file_rounded,
                                      color: Colors.indigo, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.cuslang == 'EN'
                                        ? "Upload Slip"
                                        : "อัปโหลดสลิป",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: Colors.red.shade200),
                                    ),
                                    child: Text(
                                      widget.cuslang == 'EN'
                                          ? 'Required'
                                          : 'จำเป็น',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (_isBillDead)
                                    InkWell(
                                      child: chip(
                                          widget.cuslang == 'EN'
                                              ? 'Order Expired - Cancel Order'
                                              : 'รายการ หมดอายุ - ยกเลิกรายการ',
                                          Colors.red.withValues(alpha: .08),
                                          Colors.red.shade700),
                                      onTap: () =>
                                          _showCancelPaymentDialog(context),
                                    )
                                  else
                                    InkWell(
                                      child: chip(
                                          widget.cuslang == 'EN'
                                              ? 'Show QR Code'
                                              : 'แสดง QR Code',
                                          Colors.orange.withValues(alpha: .08),
                                          Colors.orange.shade700),
                                      onTap: () async {
                                        final ctx = context;
                                        if (!_isQrExpired() &&
                                            qr_expiresAt != null) {
                                          _showQrDialog(ctx);
                                          return;
                                        }
                                        showDialog(
                                          context: ctx,
                                          barrierDismissible: false,
                                          builder: (_) => const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        );
                                        await QrGenRef(
                                            QR_Ref1: '',
                                            QR_Ref2: '',
                                            QR_Ref3: '',
                                            softExpireAt: '');
                                        if (!ctx.mounted) return;
                                        Navigator.of(ctx).pop();
                                        _showQrDialog(ctx);
                                      },
                                    ),
                                  Spacer(),
                                  InkWell(
                                    child: Icon(Icons.info_outline,
                                        color: Colors.blueGrey, size: 20),
                                    onTap: () =>
                                        _showCancelPaymentDialog(context),
                                  ),
                                ],
                              ),

                              SizedBox(height: 10),

                              GestureDetector(
                                onTap: () async {
                                  // await uploadFile_Slip();
                                  final success = await _pickSlipImage();

                                  // Force rebuild of the sheet to show the image
                                  setStateSheet(() {});

                                  // Show auto dialog removed - using Slider instead
                                  if (success) {
                                    _showSlideConfirmDialog();
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 210,
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: Colors.indigo.shade200,
                                        width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.indigo
                                            .withValues(alpha: 0.06),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: _slipPreviewBytes() == null
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 72,
                                              height: 72,
                                              decoration: BoxDecoration(
                                                color: Colors.indigo
                                                    .withValues(alpha: 0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.cloud_upload_outlined,
                                                size: 38,
                                                color: Colors.indigo,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              widget.cuslang == 'EN'
                                                  ? "Tap to upload payment slip"
                                                  : "กดเพื่ออัปโหลดสลิป",
                                              style: TextStyle(
                                                  color: Colors.indigo.shade700,
                                                  fontFamily: Font_.Fonts_T,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "JPG, PNG (Max 10MB)",
                                              style: TextStyle(
                                                  color: Colors.indigo.shade300,
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
                                                  _slipPreviewBytes()!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Container(
                                                color: Colors.black
                                                    .withValues(alpha: 0.3),
                                                child: Center(
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 8),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.8),
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
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.indigo.shade200, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              const Icon(Icons.receipt_long_rounded,
                                  color: Colors.indigo, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                widget.cuslang == 'EN'
                                    ? 'Total Amount'
                                    : 'จำนวนที่ต้องชำระ',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.indigo.shade700,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ]),
                            Text(
                              widget.cuslang == 'EN'
                                  ? "${nFormat.format(double.parse(totalAmount.toString()))} "
                                  : "${nFormat.format(double.parse(totalAmount.toString()))} ",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Text(
                      //   widget.cuslang == 'EN'
                      //       ? "Total amount to be paid: ${sum_amt.toStringAsFixed(2)} THB"
                      //       : "รวมจำนวนเงินที่ต้องชำระ: ${sum_amt.toStringAsFixed(2)} บาท",
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: Colors.grey.shade600,
                      //     fontFamily: Font_.Fonts_T,
                      //   ),
                      // ),
                      SizedBox(height: 2),
                      // Footer Action
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
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
                                  : 'เลื่อนเพื่อยืนยันการชำระเงิน',
                              enabled: base64_Slip != null ||
                                  _slipImageBytes != null,
                              onConfirmation: () async {
                                // Trigger file picker
                                // final success = await _pickSlipImage();
                                if (base64_Slip != null ||
                                    _slipImageBytes != null) {
                                  if (!mounted) return;
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  );
                                  final successUp = await _uploadSlipImage(
                                      amtRawSlip: sum_amt.toString());
                                  if (mounted) {
                                    Navigator.of(context).pop(); // Close dialog
                                    Navigator.pushAndRemoveUntil(context,
                                        MaterialPageRoute(builder: (context) {
                                      return FitnessAppHomeScreen(
                                          custno_s: custno);
                                    }), (route) => false);
                                    if (successUp) {
                                      Fluttertoast.showToast(
                                          timeInSecForIosWeb: 3,
                                          msg: widget.cuslang == 'EN'
                                              ? "Slip upload successful"
                                              : 'อัปโหลดสลิปสำเร็จ',
                                          backgroundColor: Colors.black,
                                          textColor: Colors.white,
                                          webPosition: "center",
                                          webBgColor: "#000000",
                                          toastLength: Toast.LENGTH_SHORT);
                                    }
                                  }
                                }
                                // Confirm Logic
                                // List newValuePDFimg = [];
                                // for (int index = 0; index < 1; index++) {
                                //   if (renTalModels[0].imglogo!.trim() != '') {
                                //     newValuePDFimg.add(
                                //         '${MyConstant().domain_chao}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                                //   }
                                // }
                                // try {
                                //   sucress();
                                //   OKuploadFile_Slip(newValuePDFimg).then(
                                //       (value) => in_Trans_invoice(newValuePDFimg));
                                //   Navigator.pop(
                                //       context); // Close sheet after success
                                // } catch (e) {
                                //   _showMyDialogPay_Error(widget.cuslang == 'EN'
                                //       ? "An error occurred. Please check the information. Please try again!"
                                //       : 'เกิดข้อผิดพลาด ตรวจสอบความถูกต้อง กรุณาลองอีกครั้ง!');
                                // }
                              },
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
                              return const Center(
                                child: CircularProgressIndicator(),
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
    this.color = Colors.indigo,
    this.enabled = true,
  }) : super(key: key);

  @override
  __SlideToConfirmState createState() => __SlideToConfirmState();
}

class __SlideToConfirmState extends State<_SlideToConfirm> {
  double _position = 0.0;
  bool _confirmed = false;
  bool _isDragging = false;
  final double _height = 56.0;
  final double _handleWidth = 48.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double pad = 4.0;
        final double maxDrag = constraints.maxWidth - _handleWidth - pad * 2;
        final double pct = (_position / maxDrag).clamp(0.0, 1.0);

        return Container(
          height: _height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.enabled
                  ? [
                      Color.lerp(Colors.indigo, Colors.indigo.shade800, pct)!,
                      Colors.indigo.shade800,
                    ]
                  : [Colors.grey.shade500, Colors.grey.shade700],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(_height / 2),
            boxShadow: [
              BoxShadow(
                color: (widget.enabled ? Colors.indigo : Colors.grey.shade600)
                    .withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Opacity(
                  opacity: (1.0 - pct * 2).clamp(0.0, 1.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: Font_.Fonts_T,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!_confirmed)
                AnimatedPositioned(
                  duration: _isDragging
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  left: pad + _position,
                  top: (_height - _handleWidth) / 2,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (!widget.enabled) return;
                      setState(() {
                        _isDragging = true;
                        _position =
                            (_position + details.delta.dx).clamp(0.0, maxDrag);
                      });
                    },
                    onHorizontalDragEnd: (_) {
                      if (!widget.enabled) return;
                      if (_position >= maxDrag * 0.72) {
                        setState(() {
                          _isDragging = false;
                          _position = maxDrag;
                          _confirmed = true;
                        });
                        widget.onConfirmation();
                      } else {
                        setState(() {
                          _isDragging = false;
                          _position = 0.0;
                        });
                      }
                    },
                    child: Container(
                      width: _handleWidth,
                      height: _handleWidth,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(2, 2))
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: widget.enabled ? Colors.indigo : Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              if (_confirmed)
                Positioned(
                  right: pad,
                  top: (_height - _handleWidth) / 2,
                  child: Container(
                    width: _handleWidth,
                    height: _handleWidth,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.indigo, size: 26),
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}

class SlipMergeParams {
  final List<Uint8List> images;

  const SlipMergeParams({required this.images});
}

Future<Uint8List?> _processSlipMergeImages(SlipMergeParams params) async {
  try {
    const int maxWidth = 450;
    final decodedImages = <img.Image>[];
    var totalHeight = 0;

    for (final bytes in params.images) {
      var decoded = img.decodeImage(bytes);
      if (decoded == null) continue;

      if (decoded.width > maxWidth) {
        decoded = img.copyResize(
          decoded,
          width: maxWidth,
          interpolation: img.Interpolation.nearest,
        );
      }

      decodedImages.add(decoded);
      totalHeight += decoded.height;
    }

    if (decodedImages.isEmpty) return null;

    final mergedDisplay = img.Image(width: maxWidth, height: totalHeight);
    img.fill(mergedDisplay, color: img.ColorRgb8(255, 255, 255));

    var currentY = 0;
    for (final image in decodedImages) {
      img.compositeImage(mergedDisplay, image, dstX: 0, dstY: currentY);
      currentY += image.height;
    }

    return Uint8List.fromList(img.encodeJpg(mergedDisplay, quality: 35));
  } catch (e) {
    debugPrint("Error merging images in isolate: $e");
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
  int sizePx = 1000,
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

  // (ถ้าจะไม่ใช้ footer จริง ๆ ตัด height ให้เท่า qrSize ก็ได้)
  final int footerHeight = (qrSize * 0.40).round();
  final int totalHeight = qrSize + footerHeight;

  // 2) base image
  final img = img_lib.Image(width: qrSize, height: totalHeight, numChannels: 4);
  img_lib.fill(img, color: img_lib.ColorRgba8(255, 255, 255, 255));
  final black = img_lib.ColorRgba8(0, 0, 0, 255);

  // 3) draw modules
  for (int y = 0; y < moduleCount; y++) {
    for (int x = 0; x < moduleCount; x++) {
      if (qrImage.isDark(y, x)) {
        final xPos = (quietModule + x) * scale;
        final yPos = (quietModule + y) * scale;
        img_lib.fillRect(
          img,
          x1: xPos,
          y1: yPos,
          x2: xPos + scale - 1, // ✅ กันล้น
          y2: yPos + scale - 1, // ✅ กันล้น
          color: black,
        );
      }
    }
  }

  // 4) center logo
  try {
    final bytes = await rootBundle.load(assetLogoPath);
    final logoInput = img_lib.decodePng(bytes.buffer.asUint8List());
    if (logoInput != null) {
      final int logoW = (qrSize * 0.22).round();
      final logoResized =
          img_lib.copyResize(logoInput, width: logoW, height: logoW);

      final int qrCenter = (qrSize / 2).round();
      final int half = (logoW / 2).round();
      final int bgPad = (logoW * 0.10).round();

      img_lib.fillRect(
        img,
        x1: qrCenter - half - bgPad,
        y1: qrCenter - half - bgPad,
        x2: qrCenter + half + bgPad,
        y2: qrCenter + half + bgPad,
        color: img_lib.ColorRgba8(255, 255, 255, 255),
      );

      img_lib.compositeImage(img, logoResized,
          dstX: qrCenter - half, dstY: qrCenter - half);
    }
  } catch (e) {
    debugPrint("Logo CPU Error: $e");
  }

  // 5) Draw Footer (Pure CPU - English/Num Only)
  try {
    // Note: Image Lib v4 doesn't support TTF directly without external packages.
    // Using built-in Arial font (Supports English & Numbers only).

    // Positioning
    int textY = qrSize + 40;

    final chaoBytes = await rootBundle.load('images/Icon-chao.png');
    final chaoImg = img_lib.decodePng(chaoBytes.buffer.asUint8List());
    if (chaoImg != null) {
      final int chaoW = (qrSize * 0.12).round();
      final chaoResized =
          img_lib.copyResize(chaoImg, width: chaoW, height: chaoW);
      final int xPos = (qrSize - chaoW) ~/ 2;
      final int yPos = totalHeight - chaoW - 20;
      img_lib.compositeImage(img, chaoResized, dstX: xPos, dstY: yPos);
    }
  } catch (e) {
    debugPrint("Footer CPU Error: $e");
  }

  return img_lib.encodePng(img);
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
