// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

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
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import '../CRC_16_Prompay/generate_qrcode.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Model/GetCFinnancetrans_Model.dart';
import '../Model/GetContractx_Fine_Model.dart';
import '../Model/GetInvoice_Model.dart';
import '../Model/GetInvoice_history_Model.dart';
import '../Model/GetInvoice_pay_Model.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTranBill_model.dart';
import '../Model/GetTrans_Model.dart';
import '../Translate.dart';
import '../screen_Intents/bankCodeMap.dart';
import '../color.dart';
import '../main.dart';
import 'Screen_new/fitness_app_theme.dart';
import 'box/contentbox.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:html' if (dart.library.io) 'package:chaoperty_user/fake_html.dart'
    as html;
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'Screen_new/fitness_app_home_screen.dart';
import 'model/GetTrans_fine_Model.dart';
import 'package:otp_timer_button/otp_timer_button.dart';

class PayBillscreenChoice extends StatefulWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<TeNantModel>? teNantModel;
  final List<InvoiceModel>? invoicePayModels2;
  final List<InvoiceModel>? totalinvoicePayModels;
  final List<InvoiceModel>? selectedInvoiceModels;
  final Map<String, double>? invoiceFineAmounts;
  final Future<void> Function(List<String> docNos)? onPaymentRecordCreated;
  final VoidCallback? onWaitingPaymentStarted;
  final String? cuslang;
  final String? ref_new;
  final String? get_qr_img;
  final String? invoiceAll;
  final String? get_refapi;
  final String? get_img;
  PayBillscreenChoice({
    Key? key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
    this.teNantModel,
    this.cuslang,
    this.ref_new,
    this.get_qr_img,
    this.invoiceAll,
    this.invoicePayModels2,
    this.get_refapi,
    this.get_img,
    this.totalinvoicePayModels,
    this.selectedInvoiceModels,
    this.invoiceFineAmounts,
    this.onPaymentRecordCreated,
    this.onWaitingPaymentStarted,
  }) : super(key: key);
  // Payscreen({Key? key, required this.item, required this.InvoiceHistoryModels})
  // : super(key: key);
  @override
  State<PayBillscreenChoice> createState() => _PayBillscreenChoiceState();
}

class _PayBillscreenChoiceState extends State<PayBillscreenChoice> {
  // final _item = [widget.item.length];
  File? _image;
  Uint8List webimage = Uint8List(8);
  GlobalKey _globalKey = GlobalKey();
  final payformkey = GlobalKey<FormState>();
  var nFormat = NumberFormat("#,##0.00", "en_US");
  DateTime datex = DateTime.now();
  bool? isChecked = false;
  GlobalKey qrImageKey = GlobalKey();
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
  List<InvoiceModel> _InvoiceModels2 = [];
  String? selectedValue;
  String? numinvoice, paymentSer1, paymentName1, paymentSer2, paymentName2;
  final Form_payment1 = TextEditingController();
  final Form_payment2 = TextEditingController();
  List<TeNantModel> teNantModels = [];
  List<ContractxFineModel> contractxFineModels = [];
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
  int tap = 0, select_pay = 0, gopay = 0, show_qr = 0, ref_isnew = 0;
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
  List<InvoiceHistoryModel> _InvoiceHistoryModels = [];
  int _invoiceCalculationVersion = 0;
  final Set<String> _loadedInvoiceHistoryDocNos = <String>{};
  final Map<String, Future<void>> _invoiceHistoryRequests =
      <String, Future<void>>{};

  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  bool _isLoading = true;
  bool _isBillDetailsExpanded = false;
  bool _timeRestrictionDialogShown = false;
  bool _isCreatingQr = false;
  bool _isQrImageRevealReady = false;
  int _qrImageRevealVersion = 0;
  String? _generatedQrPayload;
  String? _generatedQrReferenceId;

  bool get _isExistingQrSession =>
      widget.ref_new.toString() == '0' ||
      (_generatedQrPayload?.trim().isNotEmpty ?? false);

  String get _activeQrPayload =>
      _generatedQrPayload?.trim() ?? widget.get_qr_img?.trim() ?? '';

  String get _activeQrReferenceId =>
      _generatedQrReferenceId?.trim() ??
      widget.get_refapi?.trim() ??
      refpay?.trim() ??
      '';

  void _startQrImageRevealDelay() {
    final revealVersion = ++_qrImageRevealVersion;
    if (mounted) {
      setState(() => _isQrImageRevealReady = false);
    }
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (mounted && revealVersion == _qrImageRevealVersion) {
        setState(() => _isQrImageRevealReady = true);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _initializePaymentScreen();
  }

  Future<void> _initializePaymentScreen() async {
    if (!await Check_time()) {
      return;
    }

    if (widget.ref_new.toString() == '0') {
      await _prepareExistingQr();
      return;
    }

    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      PanaraInfoDialog.showAnimatedGrow(
        context,
        title: widget.cuslang == 'EN' ? 'Warning' : "คำเตือน",
        message: widget.cuslang == 'EN'
            ? 'If you find any errors, please contact the staff for further investigation.'
            : "หากพบข้อผิดพลาด โปรดติดต่อเจ้าหน้าที่เพื่อดำเนินการตรวจสอบ",

        buttonText: widget.cuslang == 'EN' ? 'OK' : "รับทราบ",
        onTapDismiss: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          var custno = preferences.getString('custno');
          Navigator.of(
            context,
            rootNavigator: true,
          ).pop();
        },
        panaraDialogType: PanaraDialogType.warning,
        barrierDismissible: false, // optional parameter (default is true)
      );
    });
    checkPreferance().then(
      (value) {
        read_GC_rental().then((value) => Main_get());
      },
    );
  }

  // checkPreferance().then((value) {
  //   Value_newDateY1 = DateFormat('yyyy-MM-dd').format(newDatetime);
  //   Value_newDateD1 = DateFormat('dd-MM-yyyy').format(newDatetime);
  //   Value_newDateY = DateFormat('yyyy-MM-dd').format(newDatetime);
  //   Value_newDateD = DateFormat('dd-MM-yyyy').format(newDatetime);
  //   if (widget.teNantModel == null) {
  //     read_data();
  //   }
  //   generateRandomString();
  //   read_GC_rental().then(
  //     (value) => red_payMent().then(
  //       (value) => read_GC_fine().then(
  //         (value) => red_Invoice().then(
  //           (value) {
  //             print('_InvoiceModels >>>>> ${widget.teNantModel!.length}');
  //             for (int indexx = 0; indexx < _InvoiceModels.length; indexx++) {
  //               // if (contractxFineModels.isNotEmpty) {
  //               //   // in_Trans_fine_re(indexx);
  //               // } else {
  //               //   Map<String, dynamic> mapi = Map();
  //               //   mapi['ser'] = _InvoiceModels[indexx].ser;
  //               //   mapi['docno'] = _InvoiceModels[indexx].docno;
  //               //   mapi['amtall'] = _InvoiceModels[indexx].amtall;
  //               //   mapi['fine'] = '0';
  //               //   mapi['discount'] = _InvoiceModels[indexx].disendbill;
  //               //   InvoicePayModel invoicePayModel =
  //               //       InvoicePayModel.fromJson(mapi);
  //               //   invoicePayModels.add(invoicePayModel);
  //               // }
  //               red_Trans_select(indexx);
  //             }
  //             // if (contractxFineModels.isNotEmpty) {
  //             in_Trans_fine_re();
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // });
  // initPlatformState();

  Future<void> _prepareExistingQr() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    setState(() {
      cid_ren = preferences.getString('renTalSer');
    });
    await read_GC_rental();
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);
    _startQrImageRevealDelay();
  }

  Future<bool> Check_time() async {
    final now = DateTime.now();
    print('เช็คว่าเวลาปัจจุบัน ${now.hour}:${now.minute}');

    // เช็คว่าเวลาปัจจุบันอยู่ในช่วง 23:00 - 01:00
    if (now.hour == 23 || now.hour == 0) {
      if (_timeRestrictionDialogShown) {
        return false;
      }
      _timeRestrictionDialogShown = true;
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) {
          return;
        }
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
      return false;
    }

    return true;
  }

  Future<void> Main_get() async {
    if (widget.ref_new.toString() == '0') {
      print('Main_get');
      // PanaraInfoDialog.showAnimatedGrow(
      //   context,
      //   title: widget.cuslang == 'EN' ? 'Warning' : "คำเตือน",
      //   message: widget.cuslang == 'EN'
      //       ? 'Please check the accuracy and pay within the specified time. Thank you.'
      //       : "กรุณาตรวจสอบความถูกต้องและชำระเงินภายในเวลาที่กำหนด ขอบคุณครับ/ค่ะ",

      //   buttonText: widget.cuslang == 'EN' ? 'OK' : "รับทราบ",
      //   onTapDismiss: () async {
      //     SharedPreferences preferences = await SharedPreferences.getInstance();
      //     var custno = preferences.getString('custno');
      //     Navigator.of(
      //       context,
      //       rootNavigator: true,
      //     ).pop();
      //   },
      //   panaraDialogType: PanaraDialogType.warning,
      //   barrierDismissible: false, // optional parameter (default is true)
      // );
    } else {
      checkPreferance().then((value) {
        Value_newDateY1 = DateFormat('yyyy-MM-dd').format(newDatetime);
        Value_newDateD1 = DateFormat('dd-MM-yyyy').format(newDatetime);
        Value_newDateY = DateFormat('yyyy-MM-dd').format(newDatetime);
        Value_newDateD = DateFormat('dd-MM-yyyy').format(newDatetime);
        if (widget.teNantModel == null) {
          read_data();
        }
        generateRandomString();
        read_GC_rental().then(
          (value) => red_payMent().then(
            (value) => read_GC_fine().then(
              (value) => red_Invoice().then(
                (value) async {
                  print('_InvoiceModels >>>>> ${widget.teNantModel!.length}');
                  final calculationVersion = _startInvoiceCalculation();
                  await Future.wait(
                    List<Future<void>>.generate(
                      _InvoiceModels.length,
                      (index) => red_Trans_select(
                        index,
                        calculationVersion: calculationVersion,
                      ),
                    ),
                  );
                  if (!_isCurrentInvoiceCalculation(calculationVersion)) {
                    return;
                  }
                  await in_Trans_fine_re(
                    calculationVersion: calculationVersion,
                  );
                },
              ),
            ),
          ),
        );
      });
    }
  }

  Future<Null> chack_up_refino() async {
    print(
        'res >>>>> $refpay >>>> $refpayup >>>  ${double.parse(Form_payment1.text)}');
    if (double.parse(Form_payment1.text) != 0) {
      var url =
          "${MyConstant().domain_chao}/chack_qr_status.php?ren=$cid_ren&ref_id=$refpay&incid=$cid_docqr&sum=${double.parse(Form_payment1.text)}&extension=.png";

      print(url);
      try {
        var response = await http.get(Uri.parse(url));
        var result = json.decode(response.body);
        print('chack_qr_status>> ${result.toString()}');
        if (result.toString() == 'error') {
          setState(() {
            refpay = getRandomString(10);
            refpayup = getRandomString(10);
          });
          up_refino(_InvoiceModels[0].docno);
          print('error');
        } else if (result.toString() == 'success') {
          up_refino(_InvoiceModels[0].docno);
          print('success');
        }
      } catch (e) {}
    }
  }

  void _showQrPaymentError() {
    if (!mounted) {
      return;
    }

    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: "เกิดข้อผิดพลาด..(กรุณาลองใหม่อีกครั้ง)",
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        Navigator.of(context, rootNavigator: true).pop();
      },
      panaraDialogType: PanaraDialogType.error,
      barrierDismissible: false,
    );
  }

  Future<bool> Check_genref(_indocno, double amt) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    print('Check_genref222 ${_InvoiceModels.length}');
    // print('_InvoiceModels.length >>${_InvoiceModels.length}');
    if (_InvoiceModels.length == 1) {
      print(
          '_InvoiceModels[0].refapi >>${_InvoiceModels[0].refapi}>>${_InvoiceModels[0].amt}>>${_InvoiceModels[0].amtall}');
      // setState(() {
      //   refpay = getRandomString(10);
      //   refpayup = getRandomString(10);
      // });
      String url = '${MyConstant().domain_chaoV2}/check_genref_qr.php';
      // 'https://chaoperties.com/chao_api/v2/check_genref_qr.php';
      // '${MyConstant().domain_chao}/check_genref_qr.php?isAdd=true&ren=$ren&ciddoc=$_indocno&amt=$amt';
      print('up_ref_qr >>>> $url');
      try {
        var response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "isAdd": "true",
            "ren": "$ren",
            "ref_id": "$_indocno",
            "company": "Chaoperty",
            "amount": "$amt"
          }),
        );

        print(
          jsonEncode({
            "isAdd": "true",
            "ren": "$ren",
            "ref_id": "$_indocno",
            "company": "Chaoperty",
            "amount": "$amt"
          }),
        );
        // var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        print('$amt result $_indocno');
        // print({
        //   "isAdd": "true",
        //   "ren": "$ren",
        //   "ref_id": "$_indocno",
        //   "company": "Chaoperty",
        //   "amount": "$amt"
        // });
        // print(result.toString());
        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (result['data'] == null || result['data'].toString() == '') {
            print('11XXX result.toString()');
            setState(() {
              refpay = getRandomString(10);
              refpayup = '';
              ref_isnew = 1;
            });
          } else {
            print('22XXX result.toString()');
            setState(() {
              refpay = result['data'].toString();
              refpayup = result['data'].toString();
              ref_isnew = 0;
            });
          }
          // chack_up_refino_new();
          return true;
        } else {
          print('check_genref_qr failed: ${response.statusCode}');
          return false;
        }
      } catch (e) {
        print('inv1 xxResponse1: $e');
        return false;
      }
    } else {
      String url = '${MyConstant().domain_chaoV2}/check_genref_qr.php';
      //'https://chaoperties.com/chao_api/v2/check_genref_qr.php';
      // '${MyConstant().domain_chao}/check_genref_qr.php?isAdd=true&ren=$ren&ciddoc=$_indocno&amt=$amt';
      // print('2222 up_ref_qr >>>> $url');
      try {
        var response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "isAdd": "true",
            "ren": "$ren",
            "ref_id": "$_indocno",
            "company": "Chaoperty",
            "amount": "$amt"
          }),
        );

        // var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        // print('xxResponse: ${result.toString()}');

        print('result[data]222222');
        // print(result['status'].toString());
        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (result['data'] == null || result['data'].toString() == '') {
            print('11XXX result.toString()');
            setState(() {
              refpay = getRandomString(10);
              refpayup = '';
              ref_isnew = 1;
            });
          } else {
            setState(() {
              print('22XXX result.toString()');
              refpay = result['data'].toString();
              refpayup = result['data'].toString();
              ref_isnew = 0;
            });
          }
          // chack_up_refino_new();
          return true;
        } else {
          print('check_genref_qr failed: ${response.statusCode}');
          return false;
        }
      } catch (e) {
        print('zzzzxxResponse: $e');
        return false;
      }
    }
    print('$amt result $_indocno');
    print(' refpay : $refpay');
  }
  // Future<Null> chack_up_refino() async {
  //   print(
  //       'res >>>>> $refpay >>>> $refpayup >>>  ${double.parse(Form_payment1.text)}');
  //   if (double.parse(Form_payment1.text) != 0) {
  //     var url =
  //         "${MyConstant().domain_chao}/chack_qr_status.php?ren=$cid_ren&ref_id=$refpay&incid=$cid_docqr&sum=${double.parse(Form_payment1.text)}&extension=.png";

  //     print(url);
  //     try {
  //       var response = await http.get(Uri.parse(url));
  //       var result = json.decode(response.body);
  //       print('chack_qr_status>> ${result.toString()}');
  //       if (result.toString() == 'error') {
  //         setState(() {
  //           refpay = getRandomString(10);
  //           refpayup = getRandomString(10);
  //         });
  //         up_refino(_InvoiceModels[0].docno);
  //         print('error');
  //       } else if (result.toString() == 'success') {
  //         up_refino(_InvoiceModels[0].docno);
  //         print('success');
  //       }
  //     } catch (e) {}
  //   }
  // }

  // Future<Null> Check_genref(_indocno, double amt) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();

  //   var ren = preferences.getString('renTalSer');
  //   print('Check_genref222 ${_InvoiceModels.length}');
  //   // print('_InvoiceModels.length >>${_InvoiceModels.length}');
  //   if (_InvoiceModels.length == 1) {
  //     print(
  //         '_InvoiceModels[0].refapi >>${_InvoiceModels[0].refapi}>>${_InvoiceModels[0].amt}>>${_InvoiceModels[0].amtall}');
  //     if (double.parse(_InvoiceModels[0].amtall!) == amt) {
  //       setState(() {
  //         refpay = _InvoiceModels[0].refapi.toString();
  //         refpayup = _InvoiceModels[0].refapi.toString();
  //       });
  //       print('if222 ${_InvoiceModels.length}');
  //     } else {
  //       // setState(() {
  //       //   refpay = getRandomString(10);
  //       //   refpayup = getRandomString(10);
  //       // });
  //       String url = '${MyConstant().domain_chaoV2}/check_genref_qr.php';
  //       // 'https://chaoperties.com/chao_api/v2/check_genref_qr.php';
  //       // '${MyConstant().domain_chao}/check_genref_qr.php?isAdd=true&ren=$ren&ciddoc=$_indocno&amt=$amt';
  //       print('up_ref_qr >>>> $url');
  //       try {
  //         var response = await http.post(
  //           Uri.parse(url),
  //           headers: {
  //             "Content-Type": "application/json",
  //           },
  //           body: jsonEncode({
  //             "isAdd": "true",
  //             "ren": "$ren",
  //             "ref_id": "$_indocno",
  //             "company": "Chaoperty",
  //             "amount": "$amt"
  //           }),
  //         );

  //         print(
  //           jsonEncode({
  //             "isAdd": "true",
  //             "ren": "$ren",
  //             "ref_id": "$_indocno",
  //             "company": "Chaoperty",
  //             "amount": "$amt"
  //           }),
  //         );
  //         // var response = await http.get(Uri.parse(url));

  //         var result = json.decode(response.body);
  //         print('result[data]1111');
  //         print({
  //           "isAdd": "true",
  //           "ren": "$ren",
  //           "ref_id": "$_indocno",
  //           "company": "Chaoperty",
  //           "amount": "$amt"
  //         });
  //         print(result.toString());
  //         if (response.statusCode == 200 || response.statusCode == 404) {
  //           if (result['data'].toString() == null ||
  //               result['data'] == null ||
  //               result['data'].toString() == '') {
  //             print('11XXX result.toString()');
  //             setState(() {
  //               refpay = getRandomString(10);
  //               refpayup = '';
  //               ref_isnew = 1;
  //             });
  //           } else {
  //             print('22XXX result.toString()');
  //             setState(() {
  //               refpay = result['data'].toString();
  //               refpayup = result['data'].toString();
  //               ref_isnew = 0;
  //             });
  //           }
  //           // chack_up_refino_new();
  //         } else {
  //           // กรณี status 404 หรือไม่มี data
  //           // setState(() {
  //           //   refpay = getRandomString(10);
  //           //   refpayup = '';
  //           // });
  //           PanaraInfoDialog.showAnimatedGrow(
  //             context,
  //             title: "Oops",
  //             message: "เกิดข้อผิดพลาด..(กรุณาลองใหม่อีกครั้ง)",
  //             buttonText: "รับทราบ",
  //             onTapDismiss: () async {
  //               SharedPreferences preferences =
  //                   await SharedPreferences.getInstance();
  //               var custno = preferences.getString('custno');
  //               Navigator.of(
  //                 context,
  //                 rootNavigator: true,
  //               ).pop();
  //               Navigator.pushAndRemoveUntil(context,
  //                   MaterialPageRoute(builder: (context) {
  //                 return FitnessAppHomeScreen(custno_s: custno);
  //               }), (route) => false);
  //             },
  //             panaraDialogType: PanaraDialogType.error,
  //             barrierDismissible: false, // optional parameter (default is true)
  //           );
  //         }
  //       } catch (e) {
  //         print('inv1 xxResponse1: $e');
  //       }
  //     }
  //   } else {
  //     String url = '${MyConstant().domain_chaoV2}/check_genref_qr.php';
  //     //'https://chaoperties.com/chao_api/v2/check_genref_qr.php';
  //     // '${MyConstant().domain_chao}/check_genref_qr.php?isAdd=true&ren=$ren&ciddoc=$_indocno&amt=$amt';
  //     print('2222 up_ref_qr >>>> $url');
  //     try {
  //       var response = await http.post(
  //         Uri.parse(url),
  //         headers: {
  //           "Content-Type": "application/json",
  //         },
  //         body: jsonEncode({
  //           "isAdd": "true",
  //           "ren": "$ren",
  //           "ref_id": "$_indocno",
  //           "company": "Chaoperty",
  //           "amount": "$amt"
  //         }),
  //       );

  //       // var response = await http.get(Uri.parse(url));

  //       var result = json.decode(response.body);
  //       print('xxResponse: ${result.toString()}');

  //       print('result[data]222222');
  //       print(result['status'].toString());
  //       if (response.statusCode == 200 || response.statusCode == 404) {
  //         if (result['data'].toString() == null ||
  //             result['data'] == null ||
  //             result['data'].toString() == '') {
  //           print('11XXX result.toString()');
  //           setState(() {
  //             refpay = getRandomString(10);
  //             refpayup = '';
  //             ref_isnew = 1;
  //           });
  //         } else {
  //           setState(() {
  //             print('22XXX result.toString()');
  //             refpay = result['data'].toString();
  //             refpayup = result['data'].toString();
  //             ref_isnew = 0;
  //           });
  //         }
  //         // chack_up_refino_new();
  //       } else {
  //         // กรณี status 404 หรือไม่มี data
  //         // setState(() {
  //         //   refpay = getRandomString(10);
  //         //   refpayup = '';
  //         // });
  //         PanaraInfoDialog.showAnimatedGrow(
  //           context,
  //           title: "Oops",
  //           message: "เกิดข้อผิดพลาด..(กรุณาลองใหม่อีกครั้ง)",
  //           buttonText: "รับทราบ",
  //           onTapDismiss: () async {
  //             SharedPreferences preferences =
  //                 await SharedPreferences.getInstance();
  //             var custno = preferences.getString('custno');
  //             Navigator.of(
  //               context,
  //               rootNavigator: true,
  //             ).pop();
  //             Navigator.pushAndRemoveUntil(context,
  //                 MaterialPageRoute(builder: (context) {
  //               return FitnessAppHomeScreen(custno_s: custno);
  //             }), (route) => false);
  //           },
  //           panaraDialogType: PanaraDialogType.error,
  //           barrierDismissible: false, // optional parameter (default is true)
  //         );
  //       }
  //     } catch (e) {
  //       print('zzzzxxResponse: $e');
  //     }
  //   }
  // }

  Future<Null> Check_genref_inv1(_indocno, amt) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    print('up_ref_qr $refpay $refpayup $_indocno');
    String url =
        '${MyConstant().domain_chao}/check_genref_qr_inv.php?isAdd=true&ren=$ren&ciddoc=$_indocno&amt=$amt';
    print('up_ref_qr >>>> $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(result.toString());
      if (result.toString() != 'false') {
        setState(() {
          refpay = result.toString();
          refpayup = result.toString();
        });
      } else {
        setState(() {
          setState(() {
            refpay = getRandomString(10);
            refpayup = getRandomString(10);
          });
        });
      }
    } catch (e) {}
  }

  Future<bool> chack_up_refino_new(_indocno, amt) async {
    var gen_url = await in_Trans_invoice_genqr(_indocno);
    print(
        'res >>>>> $refpay >>>> $refpayup >>>  ${double.parse(Form_payment1.text)}');
    if (double.parse(Form_payment1.text) != 0) {
      var io2 = invoicePay == null || invoicePay == ''
          ? '0'
          : invoicePay!.substring(0, invoicePay!.length - 1);

      var url =
          //"${MyConstant().domain_chao}/chack_qr_status.php?ren=$cid_ren&ref_id=$refpay&incid=$cid_docqr&sum=${double.parse(Form_payment1.text)}&extension=.png";
          //"${MyConstant().domain_chao}/chack_qr_status.php?ren=$cid_ren&invoice=$io2&ref_id=$refpay&incid=$cid_docqr&sum=${double.parse(Form_payment1.text)}&extension=.png";
          ///"https://chaoperties.com/Admin_Test/chao_api/chack_qr_status.php?ren=$cid_ren&ref_id=$refpay&incid=$cid_docqr&sum=${double.parse(Form_payment1.text)}&extension=.png";
          // "http://192.168.1.227/test_chao/chao_api/v2/chack_qr_status.php";
          "${MyConstant().domain_chaoV3}/chack_qr_status.php";
      // print(url);
      try {
        var response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "isAdd": "true",
            "ren": "$cid_ren",
            "ref_id": "$refpay",
            "company": "Chaoperty",
            "incid": "$cid_docqr",
            "sum": "${double.parse(Form_payment1.text)}",
            "invoice": "$_indocno",
            "isNew": "$ref_isnew",
            "get_gen_url": "$gen_url"
          }),
        );

        print('RESPONSE BODY: ${response.body}');

        if (response.statusCode < 200 || response.statusCode >= 300) {
          print('chack_qr_status failed: ${response.statusCode}');
          return false;
        }

        final bodyText = response.body.trim();
        if (bodyText.startsWith('{')) {
          var result = json.decode(response.body);

          if (result["status"].toString() == 'error') {
            setState(() {
              refpay = getRandomString(10);
              refpayup = getRandomString(10);
            });
            print('error');
            PanaraInfoDialog.showAnimatedGrow(
              context,
              title: "Oops",
              message: "เกิดข้อผิดพลาด..(กรุณาลองใหม่อีกครั้ง)",
              buttonText: "รับทราบ",
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
              barrierDismissible: false, // optional parameter (default is true)
            );
            return false;
          } else if (result["status"].toString() == 'success') {
            print('status Success!');
            // แสดง success
            return true;
          }
          print('chack_qr_status returned an unknown status.');
          return false;
        } else {
          // ถ้าไม่ใช่ JSON, ให้ parse แบบข้อความธรรมดาแทน
          if (bodyText == 'insert OK') {
            print('Success!');
            // ทำต่อได้เลย
            return true;
          } else {
            setState(() {
              refpay = getRandomString(10);
              refpayup = getRandomString(10);
            });
            print('error');
            PanaraInfoDialog.showAnimatedGrow(
              context,
              title: "Oops",
              message: "เกิดข้อผิดพลาด..(กรุณาลองใหม่อีกครั้ง)",
              buttonText: "รับทราบ",
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
              barrierDismissible: false, // optional parameter (default is true)
            );
            print('Unexpected response: $bodyText');
            return false;
          }
        }
      } catch (e) {
        print('111POST request error: $e');
        setState(() {
          refpay = getRandomString(10);
          refpayup = getRandomString(10);
        });
        print('error');
        PanaraInfoDialog.showAnimatedGrow(
          context,
          title: "Oops",
          message: "เกิดข้อผิดพลาด..(กรุณาลองใหม่อีกครั้ง)",
          buttonText: "รับทราบ",
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
          barrierDismissible: false, // optional parameter (default is true)
        );
        return false;
      }

      // try {
      //   var response = await http.post(
      //     Uri.parse(url),
      //     headers: {
      //       "Content-Type": "application/json",
      //     },
      //     body: jsonEncode({
      //       "isAdd": "true",
      //       "ren": "$cid_ren",
      //       "ref_id": "$refpay",
      //       "company": "Chaoperty",
      //       "incid": "$cid_docqr",
      //       "sum": "${double.parse(Form_payment1.text)}",
      //       "invoice": "$_indocno",
      //       "isNew": "$ref_isnew",
      //       "get_gen_url": "$gen_url"
      //     }),
      //     // body: {
      //     //   'get_gen_url': '$gen_url',
      //     //   'invoice': '$io2',
      //     // },
      //   );

      //   var result = json.decode(response.body);
      //   print(jsonEncode({
      //     "isAdd": "true",
      //     "ren": "$cid_ren",
      //     "ref_id": "$refpay",
      //     "company": "Chaoperty",
      //     "incid": "$cid_docqr",
      //     "sum": "${double.parse(Form_payment1.text)}",
      //     "invoice": "$_indocno",
      //     "isNew": "$ref_isnew",
      //     "get_gen_url": "$gen_url"
      //   }));
      //   print('jsonEncodexxx');
      //   print(result);
      //   print('jsonEncode');
      //   print(jsonEncode({
      //     "isAdd": "true",
      //     "ren": "$cid_ren",
      //     "ref_id": "$refpay",
      //     "company": "Chaoperty",
      //     "incid": "$cid_docqr",
      //     "sum": "${double.parse(Form_payment1.text)}",
      //     "invoice": "$_indocno",
      //     "isNew": "$ref_isnew",
      //     "get_gen_url": "$gen_url"
      //   }));

      //   if (result.toString() == 'error') {
      //     setState(() {
      //       refpay = getRandomString(10);
      //       refpayup = getRandomString(10);
      //     });
      //     print('error');
      //     PanaraInfoDialog.showAnimatedGrow(
      //       context,
      //       title: "Oops",
      //       message: "เกิดข้อผิดพลาด..(กรุณาลองใหม่อีกครั้ง)",
      //       buttonText: "รับทราบ",
      //       onTapDismiss: () async {
      //         SharedPreferences preferences =
      //             await SharedPreferences.getInstance();
      //         var custno = preferences.getString('custno');
      //         Navigator.of(
      //           context,
      //           rootNavigator: true,
      //         ).pop();
      //         Navigator.pushAndRemoveUntil(context,
      //             MaterialPageRoute(builder: (context) {
      //           return FitnessAppHomeScreen(custno_s: custno);
      //         }), (route) => false);
      //       },
      //       panaraDialogType: PanaraDialogType.error,
      //       barrierDismissible: false, // optional parameter (default is true)
      //     );
      //   } else if (result.toString() == 'success') {
      //     print('success isnew : $ref_isnew');
      //     print(
      //         '${MyConstant().domain_chao}/gen_qr_img.php?ren=$cid_ren&ref_id=$refpay&incid=$cid_docqr&sum=${double.parse(Form_payment1.text)}&extension=.png');
      //   }
      // } catch (e) {
      //   print('111POST request error: $e');
      // }
    }
    return false;
  }

  Future<Null> up_refino(_indocno) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    // print('up_ref_qr $refpay $refpayup $_indocno');
    String url =
        '${MyConstant().domain_chao}/up_ref_qr.php?isAdd=true&ren=$ren&ciddoc=$_indocno&refpay=$refpayup';
    // print('up_ref_qr >>>> $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result.toString());
      if (result.toString() == 'true') {}
    } catch (e) {}
  }

  int _startInvoiceCalculation() {
    final calculationVersion = ++_invoiceCalculationVersion;
    _loadedInvoiceHistoryDocNos.clear();
    _invoiceHistoryRequests.clear();
    setState(() {
      _InvoiceHistoryModels.clear();
      invoicePayModels.clear();
      sum_pvat_in = 0;
      sum_vat_in = 0;
      sum_wht_in = 0;
      sum_amt_in = 0;
      sum_tran_fine_in = 0;
      Form_payment1.text = '0.00';
    });
    return calculationVersion;
  }

  bool _isCurrentInvoiceCalculation(int calculationVersion) =>
      mounted && calculationVersion == _invoiceCalculationVersion;

  void _recalculatePaymentAmount() {
    Form_payment1.text = (sum_pvat +
            sum_tran_fine -
            dis_sum_Pakan -
            (sum_disamt + sum_disamt_in) +
            (sum_amt_in + sum_tran_fine_in) +
            fine_total)
        .toStringAsFixed(2);
  }

  Future<void> red_Trans_select(
    int index, {
    required int calculationVersion,
  }) async {
    if (!_isCurrentInvoiceCalculation(calculationVersion) ||
        index < 0 ||
        index >= _InvoiceModels.length) {
      return;
    }

    final docNo = _InvoiceModels[index].docno?.trim() ?? '';
    if (docNo.isEmpty || _loadedInvoiceHistoryDocNos.contains(docNo)) {
      return;
    }

    final activeRequest = _invoiceHistoryRequests[docNo];
    if (activeRequest != null) {
      await activeRequest;
      return;
    }

    final request = _loadInvoiceHistory(
      docNo,
      calculationVersion: calculationVersion,
    );
    _invoiceHistoryRequests[docNo] = request;
    try {
      await request;
    } finally {
      if (identical(_invoiceHistoryRequests[docNo], request)) {
        _invoiceHistoryRequests.remove(docNo);
      }
    }
  }

  Future<void> _loadInvoiceHistory(
    String docNo, {
    required int calculationVersion,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = preferences.getString('usercid');
    final queryParams = <String, dynamic>{
      'isAdd': 'true',
      'ren': ren,
      'user': user,
      'ciddoc': ciddoc,
      'docnoin': docNo,
    };
    final uri =
        Uri.parse('${MyConstant().domain_chao}/GC_bill_invoiceHistory_v2.php')
            .replace(queryParameters: queryParams);
    try {
      final response = await http.get(uri);
      final result = json.decode(response.body);
      if (!_isCurrentInvoiceCalculation(calculationVersion)) {
        return;
      }

      final histories = <InvoiceHistoryModel>[];
      var pvat = 0.0;
      var vat = 0.0;
      var wht = 0.0;
      var amount = 0.0;
      if (result is List) {
        for (final map in result) {
          final history = InvoiceHistoryModel.fromJson(map);
          histories.add(history);
          pvat += double.tryParse(history.amt ?? '') ?? 0;
          vat += double.tryParse(history.vat ?? '') ?? 0;
          wht += double.tryParse(history.wht ?? '') ?? 0;
          amount += double.tryParse(history.total_t ?? '') ?? 0;
        }
      }

      if (!_isCurrentInvoiceCalculation(calculationVersion)) {
        return;
      }
      setState(() {
        _InvoiceHistoryModels.addAll(histories);
        sum_pvat_in += pvat;
        sum_vat_in += vat;
        sum_wht_in += wht;
        sum_amt_in += amount;
        _loadedInvoiceHistoryDocNos.add(docNo);
      });
    } catch (_) {}
  }

  Future<void> in_Trans_fine_re({required int calculationVersion}) async {
    if (!_isCurrentInvoiceCalculation(calculationVersion)) {
      return;
    }
    final invoicePays = await Future.wait(
      _InvoiceModels.map(_loadInvoiceFine).toList(growable: false),
    );
    if (!_isCurrentInvoiceCalculation(calculationVersion)) {
      return;
    }
    final totalFine = invoicePays.fold<double>(
      0,
      (sum, invoice) => sum + (double.tryParse(invoice.fine_book ?? '') ?? 0),
    );
    setState(() {
      invoicePayModels
        ..clear()
        ..addAll(invoicePays);
      sum_tran_fine_in = totalFine;
      _recalculatePaymentAmount();
    });
  }

  Future<InvoicePayModel> _loadInvoiceFine(InvoiceModel invoice) async {
    var fine = 0.0;
    if (contractxFineModels.isNotEmpty) {
      try {
        final preferences = await SharedPreferences.getInstance();
        final uri = Uri.parse(
          '${MyConstant().domain_chao}/In_tran_select_fine_inv.php',
        ).replace(queryParameters: <String, dynamic>{
          'isAdd': 'true',
          'ren': preferences.getString('renTalSer'),
          'ciddoc': preferences.getString('usercid'),
          'qutser': '1',
          'tser': invoice.ser,
          'tdocno': invoice.docno,
          'user': preferences.getString('ser'),
        });
        final response = await http.get(uri);
        final result = json.decode(response.body).toString();
        final separator = result.indexOf(',');
        if (separator >= 0) {
          fine = double.tryParse(result.substring(separator + 1)) ?? 0;
        }
      } catch (_) {}
    }
    return InvoicePayModel.fromJson(<String, dynamic>{
      'ser': invoice.ser,
      'docno': invoice.docno,
      'amtall': invoice.amtall,
      'fine': fine.toString(),
      'discount': invoice.disendbill,
      'fine_book': fine.toString(),
      'discount_book': invoice.disendbill,
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
    String url =
        '${MyConstant().domain_chao}/In_tran_select_fine.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user&pos=1';
    try {
      var response = await http.get(Uri.parse(url));

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
    if (contractxFineModels.isNotEmpty) {
      setState(() {
        contractxFineModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    // var zone = preferences.getString('zoneSer');
    if (widget.teNantModel == null) {
      var ciddoc = preferences.getString('usercid');
      var qutser = 1;

      String url =
          '${MyConstant().domain_chao}/GC_fine.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';

      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        // //print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--------------  $result');

        if (result.toString() != 'true') {
          for (var map in result) {
            ContractxFineModel contractxFineModel =
                ContractxFineModel.fromJson(map);

            setState(() {
              contractxFineModels.add(contractxFineModel);
            });
          }
        }
      } catch (e) {}

      // //print('contractxFineModels>>> ${contractxFineModels.length}');
    } else {
      for (var i = 0; i < widget.teNantModel!.length; i++) {
        var ciddoc = widget.teNantModel![i].cid;
        var qutser = 1;

        String url =
            '${MyConstant().domain_chao}/GC_fine.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';

        try {
          var response = await http.get(Uri.parse(url));

          var result = json.decode(response.body);
          // //print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--------------  $result');

          if (result.toString() != 'true') {
            for (var map in result) {
              ContractxFineModel contractxFineModel =
                  ContractxFineModel.fromJson(map);

              setState(() {
                contractxFineModels.add(contractxFineModel);
              });
            }
          }
        } catch (e) {}
      }
    }
    //print('contractxFineModels>>> ${contractxFineModels.length}');
  }

  Future<Null> red_Invoice() async {
    final selectedInvoices = widget.selectedInvoiceModels;
    if (selectedInvoices != null) {
      setState(() {
        _InvoiceModels.clear();
        _InvoiceModels2.clear();
        sum_disamt_in = 0;
        in_amt = 0;

        for (final invoice in selectedInvoices) {
          _InvoiceModels.add(invoice);
          _InvoiceModels2.add(invoice);
          sum_disamt_in += double.tryParse(invoice.disendbill ?? '0') ?? 0;
          in_amt += double.tryParse(invoice.amtall ?? '0') ?? 0;
        }
      });
      return;
    }

    List<String> result = widget.invoiceAll
        .toString()
        .split(',')
        .map((e) => e.replaceAll("'", "").trim())
        .toList();
    setState(() {
      _InvoiceModels.clear();
      _InvoiceModels2.clear();
      // invoicePayModels.clear();
      sum_disamt_in = 0;
      in_amt = 0;
    });
    print(' result _InvoiceModels >> ${result}');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var qutser_ = preferences.getString('qutser');
    if (widget.teNantModel == null) {
      ////////////////------------------------------------------------------>
      var ciddoc_ = preferences.getString('usercid');
      ////////////////------------------------------------------------------>

      String url =
          '${MyConstant().domain_chao}/GC_bill_invoice.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_';
      print(url);
      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);

        if (result.toString() != 'null') {
          for (var map in result) {
            InvoiceModel invoiceModel = InvoiceModel.fromJson(map);

            final docno = invoiceModel.docno?.toString();

            final isDuplicate = widget.invoicePayModels2!.any(
              (e) => e.docno?.toString() == docno,
            );

            if (!isDuplicate) {
              final amtAll =
                  double.tryParse(invoiceModel.amtall ?? '0.00') ?? 0.00;
              final disEndBill =
                  double.tryParse(invoiceModel.disendbill ?? '0.00') ?? 0.00;

              setState(() {
                sum_disamt_in += disEndBill;
                in_amt += amtAll;
                _InvoiceModels.add(invoiceModel);
                _InvoiceModels2.add(invoiceModel);
              });
            }
          }
        }
      } catch (e) {}
      setState(() {
        _InvoiceModels.removeWhere((invoice) => result.contains(invoice.docno));
      });
      _InvoiceModels.sort((a, b) {
        final aDoc = a.docno ?? '';
        final bDoc = b.docno ?? '';
        return aDoc.compareTo(bDoc);
      });

      // //print(
      //     'setState >>>> ${(sum_pvat + sum_tran_fine - dis_sum_Pakan - (sum_disamt + sum_disamt_in) + (sum_pvat_in + sum_tran_fine_in) + (fine_total))}');
    } else {
      ////////////////------------------------------------------------------>
      for (var i = 0; i < widget.teNantModel!.length; i++) {
        var ciddoc_ = widget.teNantModel![i].cid;
        // //print(ciddoc_);
        String url =
            '${MyConstant().domain_chao}/GC_bill_invoice.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_';
        // print(url);
        try {
          var response = await http.get(Uri.parse(url));

          var result = json.decode(response.body);

          if (result.toString() != 'null') {
            // sum_disamt_in = 0;
            // in_amt = 0;
            // _InvoiceModels.clear();
            for (var map in result) {
              InvoiceModel invoiceModel = InvoiceModel.fromJson(map);

              final docno = invoiceModel.docno?.toString();

              final isDuplicate = widget.invoicePayModels2!.any(
                (e) => e.docno?.toString() == docno,
              );

              if (!isDuplicate) {
                final amtAll =
                    double.tryParse(invoiceModel.amtall ?? '0.00') ?? 0.00;
                final disEndBill =
                    double.tryParse(invoiceModel.disendbill ?? '0.00') ?? 0.00;

                setState(() {
                  sum_disamt_in += disEndBill;
                  in_amt += amtAll;
                  _InvoiceModels.add(invoiceModel);
                  _InvoiceModels2.add(invoiceModel);
                });
              }
            }

            print('_InvoiceModels >> ${result.length}');
          }
        } catch (e) {}
      }
    }
    setState(() {
      _InvoiceModels.removeWhere((invoice) => result.contains(invoice.docno));
    });
    _InvoiceModels.sort((a, b) {
      final aDoc = a.docno ?? '';
      final bDoc = b.docno ?? '';
      return aDoc.compareTo(bDoc);
    });
    // }
    print(' result _InvoiceModels >> ${result.length}');
  }

  Future<Null> red_Trans_bill() async {
    if (_TransBillModels.length != 0) {
      setState(() {
        _TransBillModels.clear();
        _TransBillstring.clear();
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');

    var qutser = preferences.getString('qutser');
    // var ren = 65;
    // var ciddoc = 'LE000063';
    var cc = preferences.getString('usercid');
    print('usercid >>>>>>>>> $cc');
    if (widget.teNantModel == null) {
      var ciddoc = preferences.getString('usercid');

      String url =
          '${MyConstant().domain_chao}/GC_tran_pays.php?isAdd=true&ren=$ren&ciddoc=$ciddoc';
      print(url);
      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        // //print(result);
        if (result.toString() != 'null') {
          for (var map in result) {
            TransBillModel _TransBillModel = TransBillModel.fromJson(map);
            var menu = double.parse(_TransBillModel.total.toString())
                .toStringAsFixed(2);
            // //print('menumenumenu>>>>>>>>>$menu');
            // //print(result);
            setState(() {
              // _TransBillModels.add(_TransBillModel);
              if (_TransBillModel.invoice == null) {
                if (menu != '0.00') {
                  _TransBillModels.add(_TransBillModel);
                  var docnox = _TransBillModel.docno.toString();

                  TransBillStringModel _TransBillStringModel =
                      TransBillStringModel.fromJson(map);
                  _TransBillstring.add(_TransBillStringModel);
                }
              }
              // _TransBillModels.add(_TransBillModel);
            });
          }
        }
      } catch (e) {}
    } else {
      for (var i = 0; i < widget.teNantModel!.length; i++) {
        var ciddoc = widget.teNantModel![i].cid;
        String url =
            '${MyConstant().domain_chao}/GC_tran_pays.php?isAdd=true&ren=$ren&ciddoc=$ciddoc';

        try {
          var response = await http.get(Uri.parse(url));

          var result = json.decode(response.body);
          // //print(result);
          if (result.toString() != 'null') {
            for (var map in result) {
              TransBillModel _TransBillModel = TransBillModel.fromJson(map);
              var menu = double.parse(_TransBillModel.total.toString())
                  .toStringAsFixed(2);
              // //print('menumenumenu>>>>>>>>>$menu');
              // //print(result);
              setState(() {
                // _TransBillModels.add(_TransBillModel);
                if (_TransBillModel.invoice == null) {
                  if (menu != '0.00') {
                    _TransBillModels.add(_TransBillModel);
                    var docnox = _TransBillModel.docno.toString();

                    TransBillStringModel _TransBillStringModel =
                        TransBillStringModel.fromJson(map);
                    _TransBillstring.add(_TransBillStringModel);
                  }
                }
                // _TransBillModels.add(_TransBillModel);
              });
            }
          }
        } catch (e) {}
      }
    }
    setState(() {
      read_GC_fine();
    });
  }

  System_New_Update(context) async {
    // String accept_ = showst_update_!;
    showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white70,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: Center(
          child: Text(
            '📢',
            textAlign: TextAlign.end,
            style: TextStyle(
                fontSize: 20,
                color: Colors.orange[900],
                fontWeight: FontWeight.bold,
                fontFamily: FontWeight_.Fonts_T),
          ),
        ),
        content: Container(
          width: 400,
          // decoration: BoxDecoration(
          //   image: const DecorationImage(
          //     image: AssetImage("images/pngegg.png"),
          //     // fit: BoxFit.cover,
          //   ),
          // ),
          child: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'โปรดตรวจสอบความถูกต้อง ก่อนรายการทุกครั้ง และกรุณาใส่ข้อมูลให้ครบถ้วนเพราะอาจส่งผลต่อการทำรายการได้',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: FontWeight_.Fonts_T),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Column(
                  children: [
                    const SizedBox(
                      height: 5.0,
                    ),
                    const Divider(
                      color: Colors.grey,
                      height: 4.0,
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton(
                              onPressed: () async {
                                Navigator.pop(context, 'OK');
                              },
                              child: const Text(
                                'รับทราบ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontWeight_.Fonts_T),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              })
        ],
      ),
    );
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
          });
        }
      }
    } catch (e) {}
  }

  List<Color> _kDefaultRainbowColors = const [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];
  Future<void> _showSingleAnimationDialog(BuildContext context,
      Indicator indicator, bool showPathBackground) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(ctx).pop(true);
        });
        return Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: LoadingIndicator(
              indicatorType: indicator,
              colors: _kDefaultRainbowColors,
              strokeWidth: 4.0,
              pathBackgroundColor: showPathBackground ? Colors.black45 : null,
            ),
          ),
        );
      },
    );
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
    // _showSingleAnimationDialog(
    //   context,
    //   Indicator.values[30],
    //   false,
    // );
    // System_New_Update(context);
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
        // Map<String, dynamic> map = Map();
        // map['ser'] = '0';
        // map['datex'] = '';
        // map['timex'] = '';
        // map['ptser'] = '';
        // map['ptname'] = 'เลือก';
        // map['bser'] = '';
        // map['bank'] = '';
        // map['bno'] = '';
        // map['bname'] = '';
        // map['bsaka'] = '';
        // map['btser'] = '';
        // map['btype'] = '';
        // map['st'] = '1';
        // map['rser'] = '';
        // map['accode'] = '';
        // map['co'] = '';
        // map['data_update'] = '';
        // map['auto'] = '0';

        // PayMentModel _PayMentModel = PayMentModel.fromJson(map);

        // setState(() {
        //   _PayMentModels.add(_PayMentModel);
        // });

        for (var map in result) {
          PayMentModel _PayMentModel = PayMentModel.fromJson(map);
          var autox = _PayMentModel.auto;
          var serx = _PayMentModel.ser;
          var ptnamex = _PayMentModel.ptname;
          if (_PayMentModel.ser_payweb.toString() == '1') {
            setState(() {
              _PayMentModels.add(_PayMentModel);
            });
          } else {}
        }

        // if (paymentName1 == null) {
        //   paymentSer1 = 0.toString();
        //   paymentName1 = 'เลือก'.toString();

        //   Form_payment1.text =
        //       (sum_amt - sum_disamt).toStringAsFixed(2).toString();
        // }
      }
    } catch (e) {}
  }

  // Future<void> pickimage() async {
  //   if (!kIsWeb) {
  //     final ImagePicker imagePicker = ImagePicker();
  //     final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
  //     //print(image!.path);
  //     if (image != null) {
  //       final imagetemporary = File(image.path);
  //       setState(() {
  //         _image = imagetemporary;
  //         //print(_image);
  //       });
  //     } else {
  //       //print("No image picked");
  //     }
  //   } else if (kIsWeb) {
  //     final ImagePicker imagePicker = ImagePicker();
  //     final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
  //     //print(image!.path);
  //     if (image != null) {
  //       var f = await image.readAsBytes();
  //       setState(() {
  //         webimage = f;
  //         _image = File("a");

  //         //print(_image);
  //       });
  //     } else {
  //       //print("No image picked");
  //     }
  //   } else {
  //     //print("Someting went werong");
  //   }
  // }

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
                '${MyConstant().domain_chao_img}/files/$foder/logo/${renTalModel.imglogo!.trim()}';
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

    // //print('name>>>>>  $renname');
  }

////////////////////////////////>
  String? base64_Slip, fileName_Slip;
  var extension_;
  var file_;
  bool _isSlipUploadSubmitting = false;
  String? _slipSubmissionFailureStage;
  String? _slipSubmissionFailureMessage;

  bool _isSuccessfulSlipResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return false;
    }
    final body = response.body.trim();
    if (body.isEmpty) {
      return true;
    }
    try {
      final decoded = jsonDecode(body);
      if (decoded is bool) {
        return decoded;
      }
      if (decoded is Map) {
        final error = decoded['error']?.toString().trim();
        if (error != null && error.isNotEmpty) {
          return false;
        }
        final success = decoded['success'];
        if (success != null) {
          final normalizedSuccess = success.toString().toLowerCase();
          return success == true ||
              normalizedSuccess == 'true' ||
              normalizedSuccess == '1' ||
              normalizedSuccess == 'success' ||
              normalizedSuccess == 'ok';
        }
        final status = decoded['status']?.toString().toLowerCase();
        return status != 'error' && status != 'false' && status != 'failed';
      }
    } catch (_) {}
    final normalized = body.toLowerCase();
    return normalized != 'false' &&
        normalized != 'error' &&
        normalized != 'failed';
  }

  String _uploadedSlipFileName(http.Response response, String fallback) {
    try {
      final decoded = jsonDecode(response.body.trim());
      if (decoded is Map) {
        final filename = decoded['filename']?.toString().trim();
        if (filename != null && filename.isNotEmpty) {
          return filename.split(RegExp(r'[/\\]')).last;
        }
      }
    } catch (_) {}
    return fallback;
  }

  String? _slipResponseMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body.trim());
      if (decoded is Map) {
        final message = decoded['error'] ?? decoded['message'];
        final text = message?.toString().trim();
        if (text != null && text.isNotEmpty) {
          return text;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<bool> _pickSlipImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 1600,
      maxWidth: 1600,
      imageQuality: 88,
    );

    if (pickedFile == null) {
      return false;
    }
    final imageBytes = await pickedFile.readAsBytes();
    final mimeType = lookupMimeType(
      pickedFile.name,
      headerBytes: imageBytes,
    );
    final extension = mimeType == 'image/jpeg'
        ? 'jpg'
        : mimeType == 'image/png'
            ? 'png'
            : null;
    if (extension == null) {
      return false;
    }
    setState(() {
      base64_Slip = base64Encode(imageBytes);
      extension_ = extension;
    });
    return true;
  }

  Future<bool> uploadFile_Slip() async {
    final picked = await _pickSlipImage();
    if (!picked) {
      return false;
    }
    return OKuploadFile_Slip();
  }

  Future<bool> OKuploadFile_Slip() async {
    _slipSubmissionFailureStage = null;
    _slipSubmissionFailureMessage = null;
    if (base64_Slip == null ||
        base64_Slip!.isEmpty ||
        extension_?.toString().isEmpty != false) {
      _slipSubmissionFailureStage = 'upload';
      return false;
    }
    String dateTimeNow = DateTime.now().toString();
    String date = DateFormat('ddMMyyyy')
        .format(DateTime.parse('${dateTimeNow}'))
        .toString();
    final dateTimeNow2 = DateTime.now().toUtc().add(const Duration(hours: 7));
    final formatter2 = DateFormat('HHmmss');
    final formattedTime2 = formatter2.format(dateTimeNow2);
    String Time_ = formattedTime2.toString();

    final referenceId =
        _isExistingQrSession ? _activeQrReferenceId : refpay?.trim() ?? '';
    final folder = foder?.trim() ?? '';
    if (referenceId.isEmpty || folder.isEmpty) {
      _slipSubmissionFailureStage = 'upload';
      return false;
    }
    final fileName = 'slip_${referenceId}_${date}_$Time_.$extension_';
    if (mounted) {
      setState(() => fileName_Slip = fileName);
    }
    try {
      final url =
          '${MyConstant().domain_chao}/File_uploadSlip_NewEdit.php?name=$fileName&Foder=$folder&extension=$extension_';

      final response = await http.post(
        Uri.parse(url),
        body: {
          'image': base64_Slip,
          'Foder': folder,
          'name': fileName,
          'ex': extension_.toString()
        },
      );
      if (!_isSuccessfulSlipResponse(response)) {
        _slipSubmissionFailureStage = 'upload';
        _slipSubmissionFailureMessage = _slipResponseMessage(response);
        return false;
      }
      final storedFileName = _uploadedSlipFileName(response, fileName);
      if (mounted) {
        setState(() => fileName_Slip = storedFileName);
      }
      final linked = await OKuploadName_Slip(storedFileName);
      if (!linked) {
        _slipSubmissionFailureStage = 'link';
      }
      return linked;
    } catch (error, stackTrace) {
      debugPrint('Slip upload failed: $error\n$stackTrace');
      _slipSubmissionFailureStage = 'upload';
      _slipSubmissionFailureMessage = error.toString();
      return false;
    }
  }

  Future<bool> OKuploadName_Slip(String fileName) async {
    var _indocno;
    if (widget.ref_new.toString() == '1') {
      setState(() {
        _indocno = (_InvoiceModels.length == 1)
            ? '"${_InvoiceModels[0].docno}"'
            : _InvoiceModels.map((e) => e.docno)
                .where((docno) =>
                    docno != null && docno.toString().trim().isNotEmpty)
                .join(',');
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer') ?? '0';
    var user = preferences.getString('ser');
    String? custno = preferences.getString('custno');
    String formattedDocnos =
        _InvoiceModels.where((e) => e.docno != null && e.docno!.isNotEmpty)
            .map((e) => "'${e.docno}'")
            .join(',');

    print('OKuploadName_Slip');
    print('$custno invs: ${widget.invoiceAll}');
    try {
      final url = '${MyConstant().domain_chaoV2}/In_gen_qr_ref.php';
      print('In_gen_qr_ref');
      print(url);
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "isAdd": "true",
          "ren": "$ren",
          "company": "Chaoperty",
          "ref_id": _isExistingQrSession ? _activeQrReferenceId : "$refpay",
          "invoices":
              _isExistingQrSession ? "${widget.invoiceAll}" : "$_indocno",
          "custno": "$custno",
          "img": fileName
        }),
      );
      print(jsonEncode({
        "isAdd": "true",
        "ren": "$ren",
        "company": "Chaoperty",
        "ref_id": _isExistingQrSession ? _activeQrReferenceId : "$refpay",
        "invoices": _isExistingQrSession ? "${widget.invoiceAll}" : "$_indocno",
        "custno": "$custno",
        "img": fileName
      }));
      final linked = _isSuccessfulSlipResponse(response);
      if (!linked) {
        _slipSubmissionFailureMessage = _slipResponseMessage(response);
      }
      return linked;
    } catch (error, stackTrace) {
      debugPrint('Slip-to-payment link failed: $error\n$stackTrace');
      _slipSubmissionFailureMessage = error.toString();
      return false;
    }
  }

  // Future<void> OKuploadFile_Sliptest() async {
  //   //print('User canceled image selection');
  //   String Path_foder = 'slip';
  //   String dateTimeNow = DateTime.now().toString();
  //   String date = DateFormat('ddMMyyyy')
  //       .format(DateTime.parse('${dateTimeNow}'))
  //       .toString();
  //   final dateTimeNow2 = DateTime.now().toUtc().add(const Duration(hours: 7));
  //   final formatter2 = DateFormat('HHmmss');
  //   final formattedTime2 = formatter2.format(dateTimeNow2);
  //   String Time_ = formattedTime2.toString();

  //   ////////////////------------------------------------------------------>
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ciddoc_ = widget.teNantModel == null
  //       ? preferences.getString('usercid')
  //       : preferences.getString('custno');
  //   var qutser_ = preferences.getString('qutser');
  //   ////////////////------------------------------------------------------>
  //   var fileName_Slip_ = 'slip_${ciddoc_}_${date}_$Time_';
  //   setState(() {
  //     fileName_Slip = 'slip_${ciddoc_}_${date}_$Time_.jpg';
  //   });
  //   try {
  //     final url =
  //         'http://192.168.1.23/thi_upload/snap/OPD_Upload_Img.php?name=$fileName_Slip&foder=$foder&extension=$extension_';

  //     final response = await http.post(
  //       Uri.parse(url),
  //       body: {
  //         'image': base64_Slip,
  //         'foder': 'snapshot/',
  //         'name': 'slip_${ciddoc_}_${date}_$Time_.jpg',
  //         'ex': extension_.toString()
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       // //print('Image uploaded successfully');
  //     } else {
  //       // //print('Image upload failed');
  //     }
  //   } catch (e) {
  //     // //print('Error during image processing: $e');
  //   }
  // }
  // Future<void> uploadFile_Slip() async {
  //   // InsertFile_SQL(fileName, MixPath_);
  //   // Open the file picker and get the selected file
  //   final input = html.FileUploadInputElement();
  //   // input..accept = 'application/pdf';
  //   input.accept = 'image/jpeg,image/png,image/jpg';
  //   input.click();
  //   // deletedFile_('IDcard_LE000001_25-02-2023.pdf');
  //   await input.onChange.first;

  //   final file = input.files!.first;
  //   final reader = html.FileReader();
  //   reader.readAsArrayBuffer(file);
  //   await reader.onLoadEnd.first;
  //   String fileName_ = file.name;
  //   String extension = fileName_.split('.').last;
  //   //print('File name: $fileName_');
  //   //print('Extension: $extension');
  //   setState(() {
  //     base64_Slip = base64Encode(reader.result as Uint8List);
  //   });
  //   // //print(base64_Slip);
  //   setState(() {
  //     extension_ = extension;
  //     file_ = file;
  //   });
  //   // OKuploadFile_Slip(extension, file);
  // }

  // Future<void> OKuploadFile_Slip(newValuePDFimg) async {
  //   ////////////////------------------------------------------------------>
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ciddoc_ = preferences.getString('usercid');
  //   var qutser_ = preferences.getString('qutser');
  //   ////////////////------------------------------------------------------>
  //   if (base64_Slip != null) {
  //     String Path_foder = 'slip';
  //     String dateTimeNow = DateTime.now().toString();
  //     String date = DateFormat('ddMMyyyy')
  //         .format(DateTime.parse('${dateTimeNow}'))
  //         .toString();
  //     final dateTimeNow2 = DateTime.now().toUtc().add(const Duration(hours: 7));
  //     final formatter2 = DateFormat('HHmmss');
  //     final formattedTime2 = formatter2.format(dateTimeNow2);
  //     String Time_ = formattedTime2.toString();
  //     setState(() {
  //       fileName_Slip = 'slip_${ciddoc_}_${date}_$Time_.$extension_';
  //     });
  //     // String fileName = 'slip_${widget.Get_Value_cid}_${date}_$Time_.$extension_';
  //     // InsertFile_SQL(fileName, MixPath_, formattedTime1);
  //     // Create a new FormData object and add the file to it
  //     final formData = html.FormData();
  //     formData.appendBlob('file', file_, fileName_Slip);
  //     // Send the request
  //     final request = html.HttpRequest();
  //     request.open('POST',
  //         '${MyConstant().domain_img}/File_uploadSlip.php?name=$fileName_Slip&Foder=$foder&Pathfoder=$Path_foder');
  //     request.send(formData);
  //     //print(formData);

  //     // Handle the response
  //     await request.onLoad.first;

  //     if (request.status == 200) {
  //       //print('File uploaded successfully!');
  //       await in_Trans_invoice(newValuePDFimg);
  //     } else {
  //       //print('File upload failed with status code: ${request.status}');
  //     }
  //   } else {
  //     //print('ยังไม่ได้เลือกรูปภาพ');
  //   }
  // }

  ///----------------------------------------------->
  ScrollController _scrollController = ScrollController();
  Widget _buildSelectedInvoiceDetail(int index) {
    final invoice = _InvoiceModels[index];
    final amount = double.tryParse(invoice.amtall ?? '') ?? 0;
    final dueDate = DateTime.tryParse(invoice.date ?? '');
    final description = invoice.descr?.trim() ?? '';
    final dueText = dueDate == null
        ? ''
        : '${DateFormat('dd-MM').format(dueDate)}-${dueDate.year + 543}';

    final isEn = widget.cuslang == 'EN';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1F3),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 18,
                  color: Color(0xFF45565C),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.docno ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF17262A),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isEn ? 'Amount due' : 'ยอดที่ต้องชำระ',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10.5,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${nFormat.format(amount)} ${isEn ? 'THB' : 'บาท'}',
                    style: const TextStyle(
                      color: Color(0xFF166534),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isEn ? 'Outstanding' : 'ค้างชำระ',
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (dueText.isNotEmpty)
                Text(
                  '${isEn ? 'Due' : 'กำหนดชำระ'} $dueText',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageAnimation =
        widget.mainScreenAnimation ?? const AlwaysStoppedAnimation<double>(1);
    final pageListenable =
        widget.mainScreenAnimationController ?? pageAnimation;
    var now = DateTime.now();
    var datenow = DateFormat('yyyy-MM-dd').format(now);
    double amount = 0;
    listitem.forEach((element) {
      double total = double.parse(element['total']);
      amount = amount + total;
    });

    if (_isLoading) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Center(
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
                color: Colors.indigo,
                size: 70,
              ),
            ],
          ),
        ),
      );
    }

    if (_isCreatingQr) {
      return _buildQrPreparing();
    }

    if (_isExistingQrSession) {
      return _buildExistingQr();
    }

    return AnimatedBuilder(
        animation: pageListenable,
        builder: (BuildContext context, Widget? child) {
          return FadeTransition(
            opacity: pageAnimation,
            child: Transform(
              transform: Matrix4.translationValues(
                  0.0, 30 * (1.0 - pageAnimation.value), 0.0),
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                }),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 2),
                    child: Column(
                      children: [
                        // Container(
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(20),
                        //       color: const Color.fromRGBO(196, 188, 133, 1),
                        //     ),
                        //     alignment: Alignment.center,
                        //     child: Column(children: [
                        //       Text(
                        //         "${nFormat.format(provider.amount)}",
                        //         style: const TextStyle(
                        //           fontSize: 50,
                        //           color: Colors.white,
                        //         ),
                        //         textAlign: TextAlign.center,
                        //       ),
                        //     ])),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                            top: 12.0,
                            right: 10.0,
                            bottom: 8.0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (tap == 1) {
                                  tap = 0;
                                } else {
                                  tap = 1;
                                }
                                gopay = 0;
                              });
                              print('<<<${invoicePayModels.length}<<<');
                              invoicePay = '';
                              invoicePayfine = '';
                              for (var i = 0;
                                  i < invoicePayModels.length;
                                  i++) {
                                setState(() {
                                  invoicePay = invoicePay! +
                                      '${invoicePayModels[i].docno},';
                                  invoicePayfine = invoicePayfine! +
                                      '${invoicePayModels[i].fine},';
                                });
                              }
                              print(
                                  '<<<${double.parse(Form_payment1.text).toStringAsFixed(2)}<<< ${nFormat.format((sum_pvat + sum_tran_fine) - (sum_disamt + sum_disamt_in) + (sum_amt_in + sum_tran_fine_in))}');
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: const Radius.circular(16),
                                  bottom: Radius.circular(
                                    tap == 0 ? 16 : 0,
                                  ),
                                ),
                                border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                    style: BorderStyle.solid),
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 8.0,
                                              right: 8.0,
                                              left: 8.0,
                                              bottom: 2.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 28,
                                                height: 28,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFF1F5F9),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.receipt_long_outlined,
                                                  size: 17,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                widget.cuslang == 'EN'
                                                    ? 'Payment list'
                                                    : 'รายการชำระ',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      const Color(0xFF17262A),
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '${(_TransBillModels.length + _InvoiceModels.length)} ${widget.cuslang == 'EN' ? 'bills' : 'บิล'}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      const Color(0xFF64748B),
                                                  fontFamily: Font_.Fonts_T,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 7,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFFFF7E6),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          999),
                                                ),
                                                child: Text(
                                                  widget.cuslang == 'EN'
                                                      ? 'Outstanding'
                                                      : 'ค้างชำระ',
                                                  style: TextStyle(
                                                    fontSize: 9.5,
                                                    color:
                                                        const Color(0xFFB45309),
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 3),
                                              Icon(
                                                tap == 0
                                                    ? Icons
                                                        .keyboard_arrow_down_rounded
                                                    : Icons
                                                        .keyboard_arrow_up_rounded,
                                                size: 19,
                                                color: const Color(0xFF475569),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              left: 12, top: 10, bottom: 10),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF1F5F9),
                                            borderRadius:
                                                BorderRadius.horizontal(
                                              left: Radius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            widget.cuslang == 'EN'
                                                ? 'Payment due'
                                                : 'ยอดที่ต้องชำระ',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: const Color(0xFF66777D),
                                              fontFamily: Font_.Fonts_T,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              top: 10, right: 12, bottom: 10),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF0F5F6),
                                            borderRadius:
                                                BorderRadius.horizontal(
                                              right: Radius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            '${nFormat.format(sum_pvat + sum_tran_fine - dis_sum_Pakan - (sum_disamt + sum_disamt_in) + (sum_amt_in + sum_tran_fine_in) + (fine_total))} ${widget.cuslang == 'EN' ? 'THB' : 'บาท'}',
                                            // _TransModels.length != 0
                                            //     ? _InvoiceModels.length != 0
                                            //         ? '${nFormat.format((_TransModels.map((e) => double.parse(e.total.toString())).reduce((a, b) => a + b)) + (_InvoiceModels.map((e) => double.parse(e.amtall.toString())).reduce((a, b) => a + b)))}'
                                            //         : '${nFormat.format((_TransModels.map((e) => double.parse(e.total.toString())).reduce((a, b) => a + b)))}'
                                            //     : _InvoiceModels.length != 0
                                            //         ? '${nFormat.format((_InvoiceModels.map((e) => double.parse(e.amtall.toString())).reduce((a, b) => a + b)))}'
                                            //         : '0.00',
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF166534),
                                              fontFamily: Font_.Fonts_T,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ),
                            ),
                          ),
                        ),
                        (tap == 0)
                            ? SizedBox()
                            : Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  top: 0.0,
                                  right: 8.0,
                                  bottom: 8.0,
                                ),
                                child: Container(
                                    alignment: Alignment.topCenter,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(16),
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                      color: Colors.white,
                                    ),
                                    height: min<double>(
                                      MediaQuery.of(context).size.height * 0.4,
                                      110 +
                                          ((_TransBillModels.length +
                                                  _InvoiceModels.length) *
                                              92.0),
                                    ),
                                    child:
                                        _TransBillModels.length == 0 &&
                                                _InvoiceModels.length == 0
                                            ? Center(
                                                child: Text(
                                                  widget.cuslang == 'EN'
                                                      ? 'Payment item not founds'
                                                      : "ไม่พบรายการชำระ",
                                                  style: TextStyle(
                                                      color: Colors.black38),
                                                ),
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                widget.cuslang ==
                                                                        'EN'
                                                                    ? 'Payment details'
                                                                    : 'รายละเอียดการชำระ',
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  color: const Color(
                                                                      0xFF17262A),
                                                                  fontFamily:
                                                                      FontWeight_
                                                                          .Fonts_T,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          for (int index_in = 0;
                                                              index_in <
                                                                  _InvoiceModels
                                                                      .length;
                                                              index_in++)
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                // color: Color.fromRGBO(
                                                                //         228, 220, 172, 1)!
                                                                //     .withOpacity(0.2),
                                                                border: Border(
                                                                  bottom:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .black12,
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                              ),
                                                              child: widget
                                                                          .selectedInvoiceModels !=
                                                                      null
                                                                  ? _buildSelectedInvoiceDetail(
                                                                      index_in)
                                                                  : ListTile(
                                                                      contentPadding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      title:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              '${(index_in + 1)}. ${_InvoiceModels[index_in].docno}',
                                                                              textAlign: TextAlign.start,
                                                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child: _InvoiceModels[index_in].disendbill == '0.00'
                                                                                ? Text(
                                                                                    'ก่อนVAT : ${nFormat.format(double.parse(_InvoiceModels[index_in].amtall.toString()))}',
                                                                                    textAlign: TextAlign.end,
                                                                                    style: TextStyle(
                                                                                      fontSize: 14,
                                                                                      fontFamily: FontWeight_.Fonts_T,
                                                                                    ),
                                                                                  )
                                                                                : Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    children: [
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: Text(
                                                                                              '${nFormat.format(double.parse(_InvoiceModels[index_in].amt.toString()))}',
                                                                                              textAlign: TextAlign.end,
                                                                                              style: TextStyle(
                                                                                                decoration: TextDecoration.lineThrough,
                                                                                                decorationColor: Colors.red,
                                                                                                fontSize: 12,
                                                                                                fontFamily: Font_.Fonts_T,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: Text(
                                                                                              'ก่อนVAT : ${nFormat.format(double.parse(_InvoiceModels[index_in].amtall.toString()))}',
                                                                                              textAlign: TextAlign.end,
                                                                                              style: TextStyle(
                                                                                                fontSize: 14,
                                                                                                fontFamily: FontWeight_.Fonts_T,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      subtitle:
                                                                          Column(
                                                                        children: [
                                                                          Row(children: [
                                                                            Expanded(
                                                                              child: Padding(
                                                                                padding: EdgeInsets.only(right: 4.0),
                                                                                child: Text(widget.cuslang == 'EN' ? 'Payment due' : "กำหนดชำระ"),
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              '( ${_InvoiceModels[index_in].descr} ) ${DateFormat('dd-MM').format(DateTime.parse('${_InvoiceModels[index_in].date}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_InvoiceModels[index_in].date}'))}') + 543}',
                                                                              style: const TextStyle(
                                                                                fontFamily: Font_.Fonts_T,
                                                                              ),
                                                                            )
                                                                          ]),
                                                                          if (invoicePayfine !=
                                                                              '')
                                                                            invoicePayfine!.substring(0, invoicePayfine!.length - 1).split(',')[index_in].trim() == '0'
                                                                                ? SizedBox()
                                                                                : Row(children: [
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        widget.cuslang == 'EN' ? 'Fines - Overdue' : 'ค่าปรับ - เกินกำหนดชำระ',
                                                                                        textAlign: TextAlign.start,
                                                                                        style: const TextStyle(
                                                                                          fontSize: 12,
                                                                                          color: Colors.red,
                                                                                          fontFamily: FitnessAppTheme.fontName,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        '${nFormat.format(double.parse(invoicePayfine!.substring(0, invoicePayfine!.length - 1).split(',')[index_in].toString()))}',
                                                                                        textAlign: TextAlign.end,
                                                                                        style: TextStyle(fontSize: 12, fontFamily: FitnessAppTheme.fontName, color: Colors.red),
                                                                                      ),
                                                                                    )
                                                                                  ]),
                                                                        ],
                                                                      ),
                                                                      trailing:
                                                                          IconButton(
                                                                        onPressed: (1 ==
                                                                                1)
                                                                            ? null
                                                                            : () {
                                                                                if (invoicePayModels.elementAtOrNull(index_in)!.ser.toString() == _InvoiceModels[index_in].ser) {
                                                                                  var fine_in = double.parse(invoicePayModels.elementAtOrNull(index_in)!.fine_book.toString());

                                                                                  var fine_dis = double.parse(invoicePayModels.elementAtOrNull(index_in)!.discount_book.toString());
                                                                                  Map<String, dynamic> mapi = Map();
                                                                                  mapi['ser'] = '0';
                                                                                  mapi['docno'] = '0';
                                                                                  mapi['amtall'] = '0';
                                                                                  mapi['fine'] = '0';
                                                                                  mapi['discount'] = '0';
                                                                                  mapi['fine_book'] = fine_in.toString();
                                                                                  mapi['discount_book'] = fine_dis.toString();
                                                                                  InvoicePayModel invoicePayModel = InvoicePayModel.fromJson(mapi);

                                                                                  setState(() {
                                                                                    invoicePayModels.replaceRange(index_in, index_in + 1, [
                                                                                      invoicePayModel
                                                                                    ]);
                                                                                    sum_disamt_in = sum_disamt_in - fine_dis;
                                                                                    sum_vat_in = sum_vat_in - double.parse(_InvoiceModels[index_in].vat!);
                                                                                    sum_wht_in = sum_wht_in - double.parse(_InvoiceModels[index_in].wht!);
                                                                                    sum_pvat_in = sum_pvat_in - double.parse(_InvoiceModels[index_in].pvatall!) - fine_dis;
                                                                                    sum_amt_in = sum_amt_in - double.parse(_InvoiceModels[index_in].amtall!) - fine_dis;
                                                                                    sum_tran_fine_in = sum_tran_fine_in - fine_in;
                                                                                  });
                                                                                  // print(
                                                                                  //     'Axxx $fine_in A1. $sum_disamt_in A1. $sum_vat_in A1. $sum_wht_in A1. $sum_pvat_in A1. $sum_amt_in A1. $sum_tran_fine_in');
                                                                                } else {
                                                                                  // setState(() {
                                                                                  //   invoicePayModels
                                                                                  //       .removeWhere(
                                                                                  //           (element) =>
                                                                                  //               element
                                                                                  //                   .ser ==
                                                                                  //               '0');
                                                                                  // });
                                                                                  var fine_in = double.parse(invoicePayModels.elementAtOrNull(index_in)!.fine_book.toString());

                                                                                  var fine_dis = double.parse(invoicePayModels.elementAtOrNull(index_in)!.discount_book.toString());
                                                                                  Map<String, dynamic> mapi = Map();
                                                                                  mapi['ser'] = _InvoiceModels[index_in].ser;
                                                                                  mapi['docno'] = _InvoiceModels[index_in].docno;
                                                                                  mapi['amtall'] = _InvoiceModels[index_in].amtall;
                                                                                  mapi['fine'] = fine_in.toString();
                                                                                  mapi['discount'] = fine_dis.toString();
                                                                                  mapi['fine_book'] = fine_in.toString();
                                                                                  mapi['discount_book'] = fine_dis.toString();

                                                                                  InvoicePayModel invoicePayModel = InvoicePayModel.fromJson(mapi);

                                                                                  setState(() {
                                                                                    invoicePayModels.replaceRange(index_in, index_in + 1, [
                                                                                      invoicePayModel
                                                                                    ]);
                                                                                    sum_disamt_in = sum_disamt_in + fine_dis;
                                                                                    sum_vat_in = sum_vat_in + double.parse(_InvoiceModels[index_in].vat!);
                                                                                    sum_wht_in = sum_wht_in + double.parse(_InvoiceModels[index_in].wht!);
                                                                                    sum_pvat_in = sum_pvat_in + double.parse(_InvoiceModels[index_in].pvatall!) + fine_dis;
                                                                                    sum_amt_in = sum_amt_in + double.parse(_InvoiceModels[index_in].amtall!) + fine_dis;
                                                                                    sum_tran_fine_in = sum_tran_fine_in + fine_in;
                                                                                  });
                                                                                  // print(
                                                                                  //     'xxx $fine_in s1. $sum_disamt_in s1. $sum_vat_in s1. $sum_wht_in s1. $sum_pvat_in s1. $sum_amt_in s1. $sum_tran_fine_in');
                                                                                }
                                                                                setState(() {
                                                                                  gopay = 0;
                                                                                  Form_payment1.text = (sum_pvat + sum_tran_fine - dis_sum_Pakan - (sum_disamt + sum_disamt_in) + (sum_amt_in + sum_tran_fine_in) + (fine_total)).toStringAsFixed(2).toString();
                                                                                });
                                                                                print('1. $sum_pvat 2. $sum_tran_fine 3. $dis_sum_Pakan 4. $sum_disamt 5. $sum_disamt_in 6. $sum_amt_in 7. $sum_tran_fine_in  8. $fine_total >>>> ${invoicePayfine} >> ${invoicePay} >> ${Form_payment1.text}');
                                                                                // var ind =
                                                                                //     invoicePayModels
                                                                                //         .elementAtOrNull(
                                                                                //             index_in)!
                                                                                //         .ser
                                                                                //         .toString();

                                                                                // //print(ind);
                                                                                // _vehicleList.removeWhere((element) => element["vehicleNumber"] == 'KL-14-V-5208');
                                                                              },
                                                                        icon:
                                                                            Icon(
                                                                          invoicePayModels.elementAtOrNull(index_in)!.ser.toString() == _InvoiceModels[index_in].ser
                                                                              ? Icons.check_circle_outline
                                                                              : Icons.highlight_off_outlined,
                                                                          color: invoicePayModels.elementAtOrNull(index_in)!.ser.toString() == _InvoiceModels[index_in].ser
                                                                              ? Colors.green
                                                                              : Colors.red,
                                                                        ),
                                                                      ),
                                                                    ),
                                                            ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          _TransBillModels
                                                                      .length ==
                                                                  0
                                                              ? SizedBox()
                                                              : Container(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                    left: 8.0,
                                                                    top: 0.0,
                                                                    right: 0.0,
                                                                    bottom: 0.0,
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        widget.cuslang ==
                                                                                'EN'
                                                                            ? 'Unpaid items'
                                                                            : 'รายการค้างชำระ',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontFamily:
                                                                              FitnessAppTheme.fontName,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                          for (int index = 0;
                                                              index <
                                                                  _TransBillModels
                                                                      .length;
                                                              index++)
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                // color: Color.fromRGBO(
                                                                //         228, 220, 172, 1)!
                                                                //     .withOpacity(0.2),
                                                                border: Border(
                                                                  bottom:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .black12,
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                              ),
                                                              child: ListTile(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                title: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        '${(_InvoiceModels.length + (index + 1))}. ${_TransBillModels[index].expname}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontFamily:
                                                                              FitnessAppTheme.fontName,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        '${nFormat.format(double.parse(_TransBillModels[index].total.toString()))}',
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontFamily:
                                                                              FitnessAppTheme.fontName,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                subtitle: Row(
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(right: 4.0),
                                                                        child:
                                                                            Text(
                                                                          widget.cuslang == 'EN'
                                                                              ? 'Payment due'
                                                                              : "กำหนดชำระ",
                                                                          style:
                                                                              const TextStyle(
                                                                            fontFamily:
                                                                                FitnessAppTheme.fontName,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        '${DateFormat('dd-MM').format(DateTime.parse('${_TransBillModels[index].date}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_TransBillModels[index].date}'))}') + 543}',
                                                                        style:
                                                                            const TextStyle(
                                                                          fontFamily:
                                                                              FitnessAppTheme.fontName,
                                                                        ),
                                                                      )
                                                                    ]),
                                                                trailing:
                                                                    IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    if (_TransBillstring.elementAtOrNull(index)!
                                                                            .docno
                                                                            .toString() ==
                                                                        _TransBillModels[index]
                                                                            .docno) {
                                                                      de_Trans_select(
                                                                          index);

                                                                      Map<String,
                                                                              dynamic>
                                                                          mapi =
                                                                          Map();
                                                                      mapi['ser'] =
                                                                          _TransBillModels[index]
                                                                              .ser;
                                                                      mapi['docno'] =
                                                                          '0';

                                                                      TransBillStringModel
                                                                          transBillStringModel =
                                                                          TransBillStringModel.fromJson(
                                                                              mapi);

                                                                      setState(
                                                                          () {
                                                                        _TransBillstring.replaceRange(
                                                                            index,
                                                                            index + 1,
                                                                            [
                                                                              transBillStringModel
                                                                            ]);
                                                                      });
                                                                    } else {
                                                                      in_Trans_select(
                                                                              index)
                                                                          .then(
                                                                              (value) {
                                                                        if (contractxFineModels
                                                                            .isNotEmpty) {
                                                                          in_Trans_fine(
                                                                              index);
                                                                          // red_Trans_select2_fin();
                                                                        }
                                                                      });
                                                                      ;
                                                                      Map<String,
                                                                              dynamic>
                                                                          mapi =
                                                                          Map();
                                                                      mapi['ser'] =
                                                                          _TransBillModels[index]
                                                                              .ser;
                                                                      mapi['docno'] =
                                                                          _TransBillModels[index]
                                                                              .docno;

                                                                      TransBillStringModel
                                                                          transBillStringModel =
                                                                          TransBillStringModel.fromJson(
                                                                              mapi);

                                                                      setState(
                                                                          () {
                                                                        _TransBillstring.replaceRange(
                                                                            index,
                                                                            index + 1,
                                                                            [
                                                                              transBillStringModel
                                                                            ]);
                                                                      });
                                                                    }

                                                                    //print(
                                                                    // '${_TransModels.length} >>> ${_TransBillModels.length} >> ${_TransBillstring.length}');

                                                                    //print(
                                                                    // '${_TransBillstring.map((e) => '${e.ser}> ${e.docno}')}');
                                                                  },
                                                                  icon:
                                                                      //  Icon(Icons
                                                                      //     .check_circle_outline)
                                                                      Icon(
                                                                    _TransBillstring.elementAtOrNull(index)!.docno.toString() ==
                                                                            _TransBillModels[index]
                                                                                .docno
                                                                        ? Icons
                                                                            .check_circle_outline
                                                                        : Icons
                                                                            .highlight_off_outlined,
                                                                    color: _TransBillstring.elementAtOrNull(index)!.docno.toString() ==
                                                                            _TransBillModels[index]
                                                                                .docno
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .red,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                              ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: 10.0,
                            left: 10.0,
                            top: 8.0,
                            bottom: 10.0,
                          ),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0x1A0F2530),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4))
                              ],
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        widget.cuslang == 'EN'
                                            ? 'Details'
                                            : "รายละเอียด",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 12,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        widget.cuslang == 'EN'
                                            ? '(Transaction date: ${DateFormat('d MMM yyyy').format(DateTime.now())})'
                                            : '(วันที่ทำรายการ: ${DateFormat('d MMM', 'th_TH').format(DateTime.now())} ${DateTime.now().year + 543})',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          color: const Color(0xFF66777D),
                                          fontFamily: FitnessAppTheme.fontName,
                                          //fontSize: 10.0
                                          //fontSize: 10.0
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Divider(
                                    height: 1,
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                sum_tran_fine == 0 && sum_tran_fine_in == 0
                                    ? SizedBox()
                                    : Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 15,
                                              widget.cuslang == 'EN'
                                                  ? 'Total service charge'
                                                  : 'ยอดค่าบริการ',
                                              style: TextStyle(
                                                color: Colors.black,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    FitnessAppTheme.fontName,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 15,
                                              textAlign: TextAlign.end,
                                              '${nFormat.format(sum_pvat + sum_pvat_in)}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    FitnessAppTheme.fontName,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                sum_tran_fine == 0 && sum_tran_fine_in == 0
                                    ? SizedBox()
                                    : Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 15,
                                              widget.cuslang == 'EN'
                                                  ? 'Fine'
                                                  : 'ค่าปรับ',
                                              style: TextStyle(
                                                color: Colors.red,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    FitnessAppTheme.fontName,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 15,
                                              textAlign: TextAlign.end,
                                              '${nFormat.format(sum_tran_fine + sum_tran_fine_in)}',
                                              style: const TextStyle(
                                                color: Colors.red,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    FitnessAppTheme.fontName,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 15,
                                        widget.cuslang == 'EN'
                                            ? 'Subtotal'
                                            : 'รวม',
                                        style: TextStyle(
                                          color: Colors.black,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: FitnessAppTheme.fontName,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 15,
                                        textAlign: TextAlign.end,
                                        '${nFormat.format((sum_pvat + sum_tran_fine) + (sum_pvat_in + sum_tran_fine_in))}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: FitnessAppTheme.fontName,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 15,
                                        widget.cuslang == 'EN'
                                            ? 'Value added tax (Vat)'
                                            : 'ภาษีมูลค่าเพิ่ม(vat)',
                                        style: TextStyle(
                                          color: Colors.black,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: FitnessAppTheme.fontName,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 15,
                                        textAlign: TextAlign.end,
                                        '${nFormat.format(sum_vat + sum_vat_in)}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: FitnessAppTheme.fontName,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 15,
                                        widget.cuslang == 'EN'
                                            ? 'Withholding (Wth)'
                                            : 'หัก ณ ที่จ่าย',
                                        style: TextStyle(
                                          color: Colors.black,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: FitnessAppTheme.fontName,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 15,
                                        textAlign: TextAlign.end,
                                        '${nFormat.format(sum_wht + sum_wht_in)}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: FitnessAppTheme.fontName,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 15,
                                        widget.cuslang == 'EN'
                                            ? 'Discount'
                                            : 'ส่วนลด',
                                        style: TextStyle(
                                          color: Colors.black,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: FitnessAppTheme.fontName,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 15,
                                        textAlign: TextAlign.end,
                                        '${nFormat.format(sum_disamt + sum_disamt_in)}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: FitnessAppTheme.fontName,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 15,
                                        widget.cuslang == 'EN'
                                            ? 'Total'
                                            : 'ยอดรวม',
                                        style: TextStyle(
                                          color: Colors.black,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: FitnessAppTheme.fontName,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 15,
                                        textAlign: TextAlign.end,
                                        '${nFormat.format((sum_pvat + sum_tran_fine) - (sum_disamt + sum_disamt_in) + (sum_amt_in + sum_tran_fine_in))}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: FitnessAppTheme.fontName,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                fine_total == 0.00
                                    ? SizedBox()
                                    : Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 15,
                                              widget.cuslang == 'EN'
                                                  ? 'Charge'
                                                  : 'ค่าธรรมเนียม',
                                              style: TextStyle(
                                                color: Colors.red,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    FitnessAppTheme.fontName,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 15,
                                              textAlign: TextAlign.end,
                                              '${nFormat.format(fine_total)}',
                                              style: const TextStyle(
                                                color: Colors.red,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    FitnessAppTheme.fontName,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 6, bottom: 10),
                                  child: Divider(
                                    height: 1,
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F3FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline_rounded,
                                        size: 18,
                                        color: Color(0xFF4059B7),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          widget.cuslang == 'EN'
                                              ? 'Review before payment'
                                              : 'ตรวจสอบความถูกต้องก่อนชำระ',
                                          style: TextStyle(
                                            color: const Color(0xFF3049AA),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            fontFamily:
                                                FitnessAppTheme.fontName,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // _PayMentModels.length == 1
                                //     ? SizedBox()
                                //     :
                                Row(
                                  children: [
                                    if (_PayMentModels.length != 1)
                                      Expanded(
                                        child: Text(
                                          paymentName1 == null
                                              ? ''
                                              : "$paymentName1",
                                          style: TextStyle(
                                            fontFamily:
                                                FitnessAppTheme.fontName,
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: _PayMentModels.length == 1
                                          ? SizedBox(
                                              width: double.infinity,
                                              height: 58,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF4059B7),
                                                  disabledBackgroundColor:
                                                      const Color(0xFFAEBBEE),
                                                  elevation: 0,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 32,
                                                      height: 32,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Text(
                                                        '${(_TransBillModels.length + _InvoiceModels.length)}',
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xFF4059B7),
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        widget.cuslang == 'EN'
                                                            ? 'Pay now'
                                                            : 'ชำระค่าบริการ',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '฿${nFormat.format(sum_pvat + sum_tran_fine - dis_sum_Pakan - (sum_disamt + sum_disamt_in) + (sum_amt_in + sum_tran_fine_in) + fine_total)}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onPressed: () async {
                                                  if (!await Check_time()) {
                                                    return;
                                                  }
                                                  // invoicePay = '';
                                                  // invoicePayfine = '';
                                                  // for (var i = 0;
                                                  //     i < invoicePayModels.length;
                                                  //     i++) {
                                                  //   setState(() {
                                                  //     invoicePay = invoicePay! +
                                                  //         '${invoicePayModels[i].docno},';
                                                  //     invoicePayfine = invoicePayfine! +
                                                  //         '${invoicePayModels[i].fine},';
                                                  //   });
                                                  // }
                                                  print(Form_payment1.text);
                                                  if (invoicePayModels.length !=
                                                      0) {
                                                    if (double.parse(
                                                                Form_payment1
                                                                    .text) !=
                                                            0.00 &&
                                                        double.parse(
                                                                Form_payment1
                                                                    .text) !=
                                                            0) {
                                                      invoicePay = '';
                                                      invoicePayfine = '';
                                                      for (var i = 0;
                                                          i <
                                                              invoicePayModels
                                                                  .length;
                                                          i++) {
                                                        setState(() {
                                                          invoicePay = invoicePay! +
                                                              '${invoicePayModels[i].docno},';
                                                          invoicePayfine =
                                                              invoicePayfine! +
                                                                  '${invoicePayModels[i].fine},';
                                                        });
                                                      }

                                                      print(
                                                          'invoicePay>>.. $invoicePay >> $invoicePayfine');
                                                      // setState(() {
                                                      //   if (select_pay == 1) {
                                                      //     select_pay = 0;
                                                      //   } else {
                                                      //     select_pay = 1;
                                                      //   }
                                                      // });

                                                      var fine_amt = _PayMentModels[0]
                                                                  .fine ==
                                                              '1'
                                                          ? _PayMentModels[0]
                                                                      .fine_c ==
                                                                  '0.00'
                                                              ? double.parse(double.parse(
                                                                      _PayMentModels[0]
                                                                          .fine_a!)
                                                                  .toStringAsFixed(
                                                                      2)
                                                                  .toString())
                                                              : double.parse((((sum_amt -
                                                                              sum_disamt -
                                                                              dis_sum_Pakan) *
                                                                          double.parse(
                                                                              _PayMentModels[0].fine_c!)) /
                                                                      100)
                                                                  .toStringAsFixed(2)
                                                                  .toString())
                                                          : fine_total;

                                                      final timrsta = DateTime
                                                              .now()
                                                          .millisecondsSinceEpoch;
                                                      setState(() {
                                                        gopay = 1;
                                                        fine_total =
                                                            _PayMentModels[0]
                                                                        .fine ==
                                                                    '1'
                                                                ? fine_amt
                                                                : 0.00;
                                                        // select_pay = 0;
                                                        paymentName1 =
                                                            _PayMentModels[0]
                                                                .ptname;
                                                        selectedValue =
                                                            _PayMentModels[0]
                                                                .bno
                                                                .toString();
                                                        paymentSer1 =
                                                            _PayMentModels[0]
                                                                .ser
                                                                .toString();

                                                        payment_tser =
                                                            _PayMentModels[0]
                                                                .ptser
                                                                .toString();
                                                        payment_img =
                                                            _PayMentModels[0]
                                                                .img
                                                                .toString();
                                                        payment_co =
                                                            _PayMentModels[0]
                                                                .co
                                                                .toString();

                                                        payment_bname =
                                                            _PayMentModels[0]
                                                                .bname
                                                                .toString();
                                                        payment_bank =
                                                            _PayMentModels[0]
                                                                .bank
                                                                .toString();

                                                        Form_payment1
                                                            .text = (sum_pvat +
                                                                sum_tran_fine -
                                                                dis_sum_Pakan -
                                                                (sum_disamt +
                                                                    sum_disamt_in) +
                                                                (sum_amt_in +
                                                                    sum_tran_fine_in) +
                                                                (fine_total))
                                                            .toStringAsFixed(2)
                                                            .toString();
                                                      });

                                                      if (_PayMentModels[0]
                                                              .ptser ==
                                                          '8') {
                                                        var _indocno = (_InvoiceModels
                                                                    .length ==
                                                                1)
                                                            ? _InvoiceModels[0]
                                                                .docno
                                                            : _InvoiceModels
                                                                    .map((e) =>
                                                                        e.docno)
                                                                .where((docno) =>
                                                                    docno !=
                                                                        null &&
                                                                    docno
                                                                        .toString()
                                                                        .trim()
                                                                        .isNotEmpty)
                                                                .join(',');

                                                        var amt = double.parse(
                                                            Form_payment1.text);
                                                        print(
                                                            "ช่องทางการชำระ-Choice");
                                                        print(_InvoiceModels
                                                            .length);

                                                        setState(() {
                                                          _isCreatingQr = true;
                                                        });

                                                        final referenceReady =
                                                            await Check_genref(
                                                          _indocno,
                                                          amt,
                                                        );
                                                        if (!referenceReady) {
                                                          if (mounted) {
                                                            setState(() {
                                                              _isCreatingQr =
                                                                  false;
                                                            });
                                                          }
                                                          _showQrPaymentError();
                                                          return;
                                                        }

                                                        final qrReady =
                                                            await chack_up_refino_new(
                                                          _indocno,
                                                          amt,
                                                        );
                                                        if (!qrReady ||
                                                            !mounted) {
                                                          if (mounted) {
                                                            setState(() {
                                                              _isCreatingQr =
                                                                  false;
                                                            });
                                                          }
                                                          return;
                                                        }

                                                        final createdDocNos = (widget
                                                                    .selectedInvoiceModels ??
                                                                _InvoiceModels)
                                                            .map((invoice) =>
                                                                invoice.docno
                                                                    ?.trim() ??
                                                                '')
                                                            .where((docNo) =>
                                                                docNo
                                                                    .isNotEmpty)
                                                            .toList(
                                                                growable:
                                                                    false);
                                                        await widget
                                                            .onPaymentRecordCreated
                                                            ?.call(
                                                                createdDocNos);

                                                        final qrAmount =
                                                            double.tryParse(
                                                                  Form_payment1
                                                                      .text,
                                                                ) ??
                                                                0;
                                                        final qrReference =
                                                            refpay?.trim() ??
                                                                '';
                                                        final qrCid =
                                                            cid_docqr?.trim() ??
                                                                '';
                                                        if (qrReference
                                                                .isEmpty ||
                                                            qrCid.isEmpty ||
                                                            qrAmount <= 0) {
                                                          setState(() {
                                                            _isCreatingQr =
                                                                false;
                                                          });
                                                          _showQrPaymentError();
                                                          return;
                                                        }

                                                        setState(() {
                                                          _generatedQrReferenceId =
                                                              qrReference;
                                                          _generatedQrPayload =
                                                              'ref_id=${Uri.encodeQueryComponent(qrReference)}&incid=${Uri.encodeQueryComponent(qrCid)}&sum=${qrAmount.toStringAsFixed(2)}';
                                                          _isBillDetailsExpanded =
                                                              false;
                                                          _isCreatingQr = false;
                                                        });
                                                        _startQrImageRevealDelay();
                                                        widget
                                                            .onWaitingPaymentStarted
                                                            ?.call();
                                                      } else {
                                                        setState(() {
                                                          if (widget
                                                                  .teNantModel ==
                                                              null) {
                                                            refpay =
                                                                'WR$cid_doc${DateFormat('ddMM').format(datex)}${(datex.year + 543)}';
                                                          } else {
                                                            refpay =
                                                                'WR$cid_doc$timrsta';
                                                          }
                                                        });
                                                      }
                                                    } else {
                                                      PanaraInfoDialog
                                                          .showAnimatedGrow(
                                                        context,
                                                        title: "Oops",
                                                        message: widget
                                                                    .cuslang ==
                                                                'EN'
                                                            ? 'No payment amount!!!'
                                                            : "ไม่มียอดชำระ !!!",
                                                        buttonText:
                                                            widget.cuslang ==
                                                                    'EN'
                                                                ? 'OK'
                                                                : "รับทราบ",
                                                        onTapDismiss: () async {
                                                          Navigator.of(
                                                            context,
                                                            rootNavigator: true,
                                                          ).pop();
                                                        },
                                                        panaraDialogType:
                                                            PanaraDialogType
                                                                .error,
                                                        barrierDismissible:
                                                            false, // optional parameter (default is true)
                                                      );
                                                    }
                                                  } else {
                                                    PanaraInfoDialog
                                                        .showAnimatedGrow(
                                                      context,
                                                      title: "Oops",
                                                      message: widget.cuslang ==
                                                              'EN'
                                                          ? 'No payment amount!!!'
                                                          : "ไม่มีรายการค้างชำระ !!!",
                                                      buttonText:
                                                          widget.cuslang == 'EN'
                                                              ? 'OK'
                                                              : "รับทราบ",
                                                      onTapDismiss: () async {
                                                        Navigator.of(
                                                          context,
                                                          rootNavigator: true,
                                                        ).pop();
                                                      },
                                                      panaraDialogType:
                                                          PanaraDialogType
                                                              .error,
                                                      barrierDismissible:
                                                          false, // optional parameter (default is true)
                                                    );
                                                  }
                                                },
                                              ),
                                            )

                                          //  Container(
                                          //     width: 150,
                                          //     child: ElevatedButton(
                                          //       onPressed: () async {
                                          //         // invoicePay = '';
                                          //         // invoicePayfine = '';
                                          //         // for (var i = 0;
                                          //         //     i < invoicePayModels.length;
                                          //         //     i++) {
                                          //         //   setState(() {
                                          //         //     invoicePay = invoicePay! +
                                          //         //         '${invoicePayModels[i].docno},';
                                          //         //     invoicePayfine = invoicePayfine! +
                                          //         //         '${invoicePayModels[i].fine},';
                                          //         //   });
                                          //         // }
                                          //         print(Form_payment1
                                          //             .text);
                                          //         if (invoicePayModels
                                          //                 .length !=
                                          //             0) {
                                          //           if (double.parse(
                                          //                       Form_payment1
                                          //                           .text) !=
                                          //                   0.00 &&
                                          //               double.parse(
                                          //                       Form_payment1
                                          //                           .text) !=
                                          //                   0) {
                                          //             invoicePay = '';
                                          //             invoicePayfine =
                                          //                 '';
                                          //             for (var i = 0;
                                          //                 i <
                                          //                     invoicePayModels
                                          //                         .length;
                                          //                 i++) {
                                          //               setState(() {
                                          //                 invoicePay =
                                          //                     invoicePay! +
                                          //                         '${invoicePayModels[i].docno},';
                                          //                 invoicePayfine =
                                          //                     invoicePayfine! +
                                          //                         '${invoicePayModels[i].fine},';
                                          //               });
                                          //             }

                                          //             print(
                                          //                 'invoicePay>>.. $invoicePay >> $invoicePayfine');
                                          //             // setState(() {
                                          //             //   if (select_pay == 1) {
                                          //             //     select_pay = 0;
                                          //             //   } else {
                                          //             //     select_pay = 1;
                                          //             //   }
                                          //             // });

                                          //             var fine_amt = _PayMentModels[
                                          //                             0]
                                          //                         .fine ==
                                          //                     '1'
                                          //                 ? _PayMentModels[0]
                                          //                             .fine_c ==
                                          //                         '0.00'
                                          //                     ? double.parse(double.parse(_PayMentModels[0]
                                          //                             .fine_a!)
                                          //                         .toStringAsFixed(
                                          //                             2)
                                          //                         .toString())
                                          //                     : double.parse((((sum_amt - sum_disamt - dis_sum_Pakan) * double.parse(_PayMentModels[0].fine_c!)) /
                                          //                             100)
                                          //                         .toStringAsFixed(
                                          //                             2)
                                          //                         .toString())
                                          //                 : fine_total;

                                          //             setState(() {
                                          //               gopay = 1;
                                          //               fine_total =
                                          //                   _PayMentModels[0].fine ==
                                          //                           '1'
                                          //                       ? fine_amt
                                          //                       : 0.00;
                                          //               // select_pay = 0;
                                          //               paymentName1 =
                                          //                   _PayMentModels[
                                          //                           0]
                                          //                       .ptname;
                                          //               selectedValue =
                                          //                   _PayMentModels[
                                          //                           0]
                                          //                       .bno
                                          //                       .toString();
                                          //               paymentSer1 =
                                          //                   _PayMentModels[
                                          //                           0]
                                          //                       .ser
                                          //                       .toString();

                                          //               payment_tser =
                                          //                   _PayMentModels[
                                          //                           0]
                                          //                       .ptser
                                          //                       .toString();
                                          //               payment_img =
                                          //                   _PayMentModels[
                                          //                           0]
                                          //                       .img
                                          //                       .toString();
                                          //               payment_co =
                                          //                   _PayMentModels[
                                          //                           0]
                                          //                       .co
                                          //                       .toString();

                                          //               payment_bname =
                                          //                   _PayMentModels[
                                          //                           0]
                                          //                       .bname
                                          //                       .toString();
                                          //               payment_bank =
                                          //                   _PayMentModels[
                                          //                           0]
                                          //                       .bank
                                          //                       .toString();

                                          //               var timrsta =
                                          //                   DateTime.now()
                                          //                       .millisecondsSinceEpoch;
                                          //               Form_payment1
                                          //                   .text = (sum_pvat +
                                          //                       sum_tran_fine -
                                          //                       dis_sum_Pakan -
                                          //                       (sum_disamt +
                                          //                           sum_disamt_in) +
                                          //                       (sum_amt_in +
                                          //                           sum_tran_fine_in) +
                                          //                       (fine_total))
                                          //                   .toStringAsFixed(
                                          //                       2)
                                          //                   .toString();
                                          //               if (_PayMentModels[
                                          //                           0]
                                          //                       .ptser ==
                                          //                   '8') {
                                          //                 var _indocno = (_InvoiceModels
                                          //                             .length ==
                                          //                         1)
                                          //                     ? _InvoiceModels[
                                          //                             0]
                                          //                         .docno
                                          //                     : _InvoiceModels.map(
                                          //                             (e) => e.docno)
                                          //                         .where((docno) =>
                                          //                             docno != null &&
                                          //                             docno.toString().trim().isNotEmpty)
                                          //                         .join(',');

                                          //                 var amt = double.parse(
                                          //                     Form_payment1
                                          //                         .text);
                                          //                 print(
                                          //                     "ช่องทางการชำระ-Choice");
                                          //                 print(_InvoiceModels
                                          //                     .length);

                                          //                 Check_genref(
                                          //                         _indocno,
                                          //                         amt)
                                          //                     .then(
                                          //                         (value) {
                                          //                   if (refpay !=
                                          //                       null) {
                                          //                     chack_up_refino_new(
                                          //                         _indocno,
                                          //                         amt);
                                          //                     PanaraInfoDialog
                                          //                         .showAnimatedGrow(
                                          //                       context,
                                          //                       title: widget.cuslang ==
                                          //                               'EN'
                                          //                           ? 'Warning'
                                          //                           : "คำเตือน",
                                          //                       message: widget.cuslang ==
                                          //                               'EN'
                                          //                           ? 'Please check the accuracy and pay within the specified time. Thank you.'
                                          //                           : "กรุณาตรวจสอบความถูกต้องและชำระเงินภายในเวลาที่กำหนด",

                                          //                       buttonText: widget.cuslang ==
                                          //                               'EN'
                                          //                           ? 'OK'
                                          //                           : "รับทราบ",
                                          //                       onTapDismiss:
                                          //                           () async {
                                          //                         Navigator
                                          //                             .of(
                                          //                           context,
                                          //                           rootNavigator:
                                          //                               true,
                                          //                         ).pop();
                                          //                       },
                                          //                       panaraDialogType:
                                          //                           PanaraDialogType.error,
                                          //                       barrierDismissible:
                                          //                           false, // optional parameter (default is true)
                                          //                     );
                                          //                   }
                                          //                 });
                                          //               } else {
                                          //                 if (widget
                                          //                         .teNantModel ==
                                          //                     null) {
                                          //                   refpay =
                                          //                       'WR$cid_doc${DateFormat('ddMM').format(datex)}${(datex.year + 543)}';
                                          //                 } else {
                                          //                   refpay =
                                          //                       'WR$cid_doc$timrsta';
                                          //                 }
                                          //               }
                                          //             });
                                          //           } else {
                                          //             PanaraInfoDialog
                                          //                 .showAnimatedGrow(
                                          //               context,
                                          //               title: "Oops",
                                          //               message: widget
                                          //                           .cuslang ==
                                          //                       'EN'
                                          //                   ? 'No payment amount!!!'
                                          //                   : "ไม่มียอดชำระ !!!",
                                          //               buttonText:
                                          //                   widget.cuslang ==
                                          //                           'EN'
                                          //                       ? 'OK'
                                          //                       : "รับทราบ",
                                          //               onTapDismiss:
                                          //                   () async {
                                          //                 Navigator.pop(
                                          //                     context);
                                          //               },
                                          //               panaraDialogType:
                                          //                   PanaraDialogType
                                          //                       .error,
                                          //               barrierDismissible:
                                          //                   false, // optional parameter (default is true)
                                          //             );
                                          //           }
                                          //         } else {
                                          //           PanaraInfoDialog
                                          //               .showAnimatedGrow(
                                          //             context,
                                          //             title: "Oops",
                                          //             message: widget
                                          //                         .cuslang ==
                                          //                     'EN'
                                          //                 ? 'No payment amount!!!'
                                          //                 : "ไม่มีรายการค้างชำระ !!!",
                                          //             buttonText:
                                          //                 widget.cuslang ==
                                          //                         'EN'
                                          //                     ? 'OK'
                                          //                     : "รับทราบ",
                                          //             onTapDismiss:
                                          //                 () async {
                                          //               Navigator.pop(
                                          //                   context);
                                          //             },
                                          //             panaraDialogType:
                                          //                 PanaraDialogType
                                          //                     .error,
                                          //             barrierDismissible:
                                          //                 false, // optional parameter (default is true)
                                          //           );
                                          //         }
                                          //       },
                                          //       style: ButtonStyle(
                                          //         shape: MaterialStateProperty.all<
                                          //                 OutlinedBorder>(
                                          //             RoundedRectangleBorder(
                                          //                 borderRadius:
                                          //                     BorderRadius
                                          //                         .circular(
                                          //                             30))),
                                          //         foregroundColor:
                                          //             MaterialStateProperty
                                          //                 .all<Color>(
                                          //                     Colors
                                          //                         .white),
                                          //         backgroundColor:
                                          //             MaterialStateProperty
                                          //                 .all<Color>(Colors
                                          //                     .green
                                          //                     .shade900),
                                          //       ),
                                          //       child: AutoSizeText(
                                          //         minFontSize: 6,
                                          //         maxFontSize: 18,
                                          //         maxLines: 1,
                                          //         widget.cuslang == 'EN'
                                          //             ? 'Pay the service fee'
                                          //             : "ชำระค่าบริการ",
                                          //         textAlign:
                                          //             TextAlign.start,
                                          //         style: TextStyle(
                                          //           color: Colors.white,
                                          //           fontFamily:
                                          //               FitnessAppTheme
                                          //                   .fontName,
                                          //           //fontSize: 10.0
                                          //           //fontSize: 10.0
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   )
                                          : Container(
                                              width: 150,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  if (!await Check_time()) {
                                                    return;
                                                  }
                                                  // invoicePay = '';
                                                  // invoicePayfine = '';
                                                  // for (var i = 0;
                                                  //     i < invoicePayModels.length;
                                                  //     i++) {
                                                  //   setState(() {
                                                  //     invoicePay = invoicePay! +
                                                  //         '${invoicePayModels[i].docno},';
                                                  //     invoicePayfine = invoicePayfine! +
                                                  //         '${invoicePayModels[i].fine},';
                                                  //   });
                                                  // }

                                                  if (double.parse(Form_payment1
                                                              .text) !=
                                                          0.00 &&
                                                      double.parse(Form_payment1
                                                              .text) !=
                                                          0) {
                                                    setState(() {
                                                      if (select_pay == 1) {
                                                        select_pay = 0;
                                                      } else {
                                                        select_pay = 1;
                                                      }
                                                    });
                                                  }
                                                },
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty
                                                      .all<OutlinedBorder>(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30))),
                                                  foregroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Colors.white),
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(paymentName1 ==
                                                              null
                                                          ? Colors
                                                              .green.shade900
                                                          : Colors
                                                              .orange.shade900),
                                                ),
                                                child: AutoSizeText(
                                                  minFontSize: 6,
                                                  maxFontSize: 18,
                                                  maxLines: 1,
                                                  paymentName1 == null
                                                      ? widget.cuslang == 'EN'
                                                          ? 'Choose form of payment'
                                                          : "เลือกรูปแบบการชำระ"
                                                      : widget.cuslang == 'EN'
                                                          ? 'Change the form of payment'
                                                          : "เปลี่ยนรูปแบบการชำระ",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: FitnessAppTheme
                                                        .fontName,
                                                    //fontSize: 10.0
                                                    //fontSize: 10.0
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        select_pay == 0
                            ? SizedBox()
                            : Padding(
                                padding: EdgeInsets.only(
                                  right: 8.0,
                                  left: 8.0,
                                  top: 4.0,
                                  bottom: 8.0,
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 0))
                                    ],
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            widget.cuslang == 'EN'
                                                ? 'Choose form of payment'
                                                : "เลือกรูปแบบการชำระ",
                                            style: TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              // fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                      for (int index = 0;
                                          index < _PayMentModels.length;
                                          index++)
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${(index + 1)}. ${_PayMentModels[index].ptname}',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  '${_PayMentModels[index].bank}',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: FitnessAppTheme
                                                        .fontName,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Row(children: [
                                            Expanded(
                                              child: Text(
                                                _PayMentModels[index]
                                                            .fine
                                                            .toString() ==
                                                        '0'
                                                    ? widget.cuslang == 'EN'
                                                        ? 'Free of charge'
                                                        : 'ฟรีค่าธรรมเนียม'
                                                    : _PayMentModels[index]
                                                                .fine_c
                                                                .toString() ==
                                                            '0.00'
                                                        ? widget.cuslang == 'EN'
                                                            ? 'Charge ${_PayMentModels[index].fine_a} BHT'
                                                            : 'ค่าธรรมเนียม ${_PayMentModels[index].fine_a} บาท'
                                                        : widget.cuslang == 'EN'
                                                            ? 'Charge ${_PayMentModels[index].fine_a} %'
                                                            : 'ค่าธรรมเนียม ${_PayMentModels[index].fine_c} %',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  fontFamily:
                                                      FitnessAppTheme.fontName,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ]),
                                          trailing: IconButton(
                                              onPressed: () {
                                                var fine_amt = _PayMentModels[index]
                                                            .fine ==
                                                        '1'
                                                    ? _PayMentModels[index]
                                                                .fine_c ==
                                                            '0.00'
                                                        ? double.parse(double.parse(
                                                                _PayMentModels[
                                                                        index]
                                                                    .fine_a!)
                                                            .toStringAsFixed(2)
                                                            .toString())
                                                        : double.parse((((sum_amt -
                                                                        sum_disamt -
                                                                        dis_sum_Pakan) *
                                                                    double.parse(
                                                                        _PayMentModels[index].fine_c!)) /
                                                                100)
                                                            .toStringAsFixed(2)
                                                            .toString())
                                                    : fine_total;

                                                setState(() {
                                                  // _scrollController.animateTo(
                                                  //     _scrollController.offset +
                                                  //         450,
                                                  //     curve: Curves.linear,
                                                  //     duration: const Duration(
                                                  //         milliseconds: 500));
                                                  fine_total =
                                                      _PayMentModels[index]
                                                                  .fine ==
                                                              '1'
                                                          ? fine_amt
                                                          : 0.00;
                                                  select_pay = 0;
                                                  paymentName1 =
                                                      _PayMentModels[index]
                                                          .ptname;
                                                  selectedValue =
                                                      _PayMentModels[index]
                                                          .bno
                                                          .toString();
                                                  paymentSer1 =
                                                      _PayMentModels[index]
                                                          .ser
                                                          .toString();

                                                  payment_tser =
                                                      _PayMentModels[index]
                                                          .ptser
                                                          .toString();
                                                  payment_co =
                                                      _PayMentModels[index]
                                                          .co
                                                          .toString();
                                                  payment_img =
                                                      _PayMentModels[index]
                                                          .img
                                                          .toString();
                                                  payment_bname =
                                                      _PayMentModels[index]
                                                          .bname
                                                          .toString();
                                                  payment_bank =
                                                      _PayMentModels[index]
                                                          .bank
                                                          .toString();
                                                  var timrsta = DateTime.now()
                                                      .millisecondsSinceEpoch;

                                                  if (_PayMentModels[index]
                                                          .ptser ==
                                                      '8') {
                                                    refpay =
                                                        getRandomString(10);
                                                  } else {
                                                    if (widget.teNantModel ==
                                                        null) {
                                                      refpay =
                                                          'WR$cid_doc${DateFormat('ddMM').format(datex)}${(datex.year + 543)}';
                                                    } else {
                                                      refpay =
                                                          'WR$cid_doc$timrsta';
                                                    }
                                                  }
                                                  // if (widget.teNantModel == null) {
                                                  //   refpay =
                                                  //       'WR$cid_doc${DateFormat('ddMM').format(datex)}${(datex.year + 543)}';
                                                  // } else {
                                                  //   refpay = 'WR$cid_doc$timrsta';
                                                  // }

                                                  // Form_payment1.text = (sum_pvat +
                                                  //         sum_tran_fine -
                                                  //         dis_sum_Pakan +
                                                  //         (fine_total))
                                                  //     .toStringAsFixed(2)
                                                  //     .toString();

                                                  Form_payment1
                                                      .text = (sum_pvat +
                                                          sum_tran_fine -
                                                          dis_sum_Pakan -
                                                          (sum_disamt +
                                                              sum_disamt_in) +
                                                          (sum_amt_in +
                                                              sum_tran_fine_in) +
                                                          (fine_total))
                                                      .toStringAsFixed(2)
                                                      .toString();
                                                });
                                              },
                                              icon: Icon(
                                                Icons.check_circle_outline,
                                                color: paymentSer1 ==
                                                        _PayMentModels[index]
                                                            .ser
                                                    ? Colors.green
                                                    : Colors.grey,
                                              )),
                                        )
                                    ],
                                  ),
                                ),
                              ),
                        paymentSer1 == null
                            ? SizedBox()
                            : gopay == 0
                                ? SizedBox()
                                : Padding(
                                    padding: EdgeInsets.only(
                                        right: 8, left: 8, top: 4, bottom: 8),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: const Offset(0, 0))
                                        ],
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        children: [
                                          // Padding(
                                          //   padding: EdgeInsets.all(10),
                                          //   child: Row(
                                          //     mainAxisAlignment:
                                          //         MainAxisAlignment.center,
                                          //     children: [
                                          //       Container(
                                          //           padding: EdgeInsets.all(5),
                                          //           decoration: BoxDecoration(
                                          //             color: Colors.grey.shade50,
                                          //             borderRadius:
                                          //                 BorderRadius.only(
                                          //                     topLeft:
                                          //                         Radius.circular(
                                          //                             10),
                                          //                     topRight:
                                          //                         Radius.circular(
                                          //                             10),
                                          //                     bottomLeft:
                                          //                         Radius.circular(
                                          //                             10),
                                          //                     bottomRight:
                                          //                         Radius.circular(
                                          //                             10)),
                                          //             border: Border.all(
                                          //                 color: Colors
                                          //                     .grey.shade100,
                                          //                 width: 1),
                                          //           ),
                                          //           width: MediaQuery.of(context)
                                          //                   .size
                                          //                   .width *
                                          //               0.75,
                                          //           child: Column(
                                          //             children: [
                                          //               Row(
                                          //                 children: [
                                          //                   Expanded(
                                          //                       flex: 1,
                                          //                       child: Icon(
                                          //                         Icons
                                          //                             .info_outline,
                                          //                         color: Colors
                                          //                             .blue
                                          //                             .shade700,
                                          //                       )),
                                          //                   Expanded(
                                          //                       flex: 6,
                                          //                       child: Text(
                                          //                         "คำเตือน",
                                          //                         textAlign:
                                          //                             TextAlign
                                          //                                 .start,
                                          //                         style: TextStyle(
                                          //                             color: Colors
                                          //                                 .orange
                                          //                                 .shade700,
                                          //                             fontFamily:
                                          //                                 Font_
                                          //                                     .Fonts_T,
                                          //                             fontWeight:
                                          //                                 FontWeight
                                          //                                     .bold),
                                          //                       ))
                                          //                 ],
                                          //               ),
                                          //               Row(
                                          //                 children: [
                                          //                   Expanded(
                                          //                       flex: 1,
                                          //                       child:
                                          //                           SizedBox()),
                                          //                   Expanded(
                                          //                       flex: 6,
                                          //                       child: Row(
                                          //                         children: [
                                          //                           Expanded(
                                          //                             child: Text(
                                          //                               "หากชำระแล้วกรุณาแนบหลักฐานการโอน ดำเนินการต่อขั้นตอนถัดไป",
                                          //                               // "หากชำระแล้วกรุณาแนบหลักฐานการโอน ดำเนินการต่อขั้นตอนถัดไป",
                                          //                               textAlign:
                                          //                                   TextAlign
                                          //                                       .start,
                                          //                               maxLines:
                                          //                                   2,
                                          //                               style:
                                          //                                   TextStyle(
                                          //                                 fontSize:
                                          //                                     14,
                                          //                                 color: Colors
                                          //                                     .orange
                                          //                                     .shade700,
                                          //                                 fontFamily:
                                          //                                     Font_.Fonts_T,
                                          //                               ),
                                          //                             ),
                                          //                           ),
                                          //                           Icon(
                                          //                               Icons.abc)
                                          //                         ],
                                          //                       ))
                                          //                 ],
                                          //               ),
                                          //             ],
                                          //           )),
                                          //     ],
                                          //   ),
                                          // ),
                                          // Center(
                                          //   child: TimerCountdown(
                                          //     format: CountDownTimerFormat
                                          //         .minutesSeconds,
                                          //     minutesDescription: 'นาที mm',
                                          //     secondsDescription: 'วินาที ss',
                                          //     timeTextStyle: TextStyle(
                                          //         color: Colors.orange,
                                          //         // fontWeight:
                                          //         //     FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //     endTime: DateTime.now().add(
                                          //       Duration(
                                          //         minutes: 15,
                                          //         seconds: 1,
                                          //       ),
                                          //     ),
                                          //     onTick: (velue) {
                                          //       print(velue);
                                          //     },
                                          //     onEnd: () {
                                          //       // Navigator.pop(context, 'OK');
                                          //     },
                                          //   ),
                                          // ),
                                          // Row(
                                          //   mainAxisAlignment:
                                          //       MainAxisAlignment.spaceBetween,
                                          //   children: [
                                          //     Text(
                                          //       widget.cuslang == 'EN'
                                          //           ? 'Payment details'
                                          //           : "รายละเอียดการชำระ",
                                          //       textAlign: TextAlign.start,
                                          //       style: TextStyle(
                                          //         fontWeight: FontWeight.bold,
                                          //         fontSize: 14,
                                          //       ),
                                          //     ),
                                          //     payment_tser == '7'
                                          //         ? SizedBox()
                                          //         : payment_tser == '2'
                                          //             ? SizedBox()
                                          //             : TextButton(
                                          //                 onPressed: () async {
                                          //                   RenderRepaintBoundary
                                          //                       boundary =
                                          //                       qrImageKey
                                          //                               .currentContext!
                                          //                               .findRenderObject()
                                          //                           as RenderRepaintBoundary;
                                          //                   ui.Image image =
                                          //                       await boundary
                                          //                           .toImage();
                                          //                   ByteData? byteData =
                                          //                       await image
                                          //                           .toByteData(
                                          //                               format: ui
                                          //                                   .ImageByteFormat
                                          //                                   .png);
                                          //                   Uint8List bytes =
                                          //                       byteData!.buffer
                                          //                           .asUint8List();
                                          //                   html.Blob blob =
                                          //                       html.Blob(
                                          //                           [bytes]);
                                          //                   String url = html.Url
                                          //                       .createObjectUrlFromBlob(
                                          //                           blob);

                                          //                   html.AnchorElement
                                          //                       anchor =
                                          //                       html.AnchorElement()
                                          //                         ..href = url
                                          //                         ..setAttribute(
                                          //                             'download',
                                          //                             'qrcode.png')
                                          //                         ..click();
                                          //                   html.Url
                                          //                       .revokeObjectUrl(
                                          //                           url);
                                          //                   // print(
                                          //                   //     '$_platformVersion');
                                          //                 },
                                          //                 child: Text(
                                          //                   "ดาวโหลด QR Code",
                                          //                   style: TextStyle(
                                          //                       fontFamily:
                                          //                           FontWeight_
                                          //                               .Fonts_T,
                                          //                       color:
                                          //                           Colors.black),
                                          //                 )),
                                          //     // if (payment_tser == '2')
                                          //     payment_img == ''
                                          //         ? SizedBox()
                                          //         : Row(
                                          //             children: [
                                          //               TextButton(
                                          //                   onPressed: () async {
                                          //                     setState(() {
                                          //                       if (show_qr ==
                                          //                           1) {
                                          //                         show_qr = 0;
                                          //                       } else {
                                          //                         show_qr = 1;
                                          //                       }
                                          //                     });
                                          //                   },
                                          //                   child: Text(
                                          //                     "QR Code",
                                          //                     style: TextStyle(
                                          //                         fontFamily:
                                          //                             FontWeight_
                                          //                                 .Fonts_T,
                                          //                         color: Colors
                                          //                             .black),
                                          //                   )),
                                          //               // show_qr == 1
                                          //               //     ? IconButton(
                                          //               //         onPressed:
                                          //               //             () async {
                                          //               //           RenderRepaintBoundary
                                          //               //               boundary =
                                          //               //               qrImageKey
                                          //               //                       .currentContext!
                                          //               //                       .findRenderObject()
                                          //               //                   as RenderRepaintBoundary;
                                          //               //           ui.Image image =
                                          //               //               await boundary
                                          //               //                   .toImage();
                                          //               //           ByteData?
                                          //               //               byteData =
                                          //               //               await image.toByteData(
                                          //               //                   format: ui
                                          //               //                       .ImageByteFormat
                                          //               //                       .png);
                                          //               //           Uint8List bytes =
                                          //               //               byteData!
                                          //               //                   .buffer
                                          //               //                   .asUint8List();
                                          //               //           html.Blob blob =
                                          //               //               html.Blob(
                                          //               //                   [bytes]);
                                          //               //           String url = html
                                          //               //                   .Url
                                          //               //               .createObjectUrlFromBlob(
                                          //               //                   blob);

                                          //               //           html.AnchorElement
                                          //               //               anchor =
                                          //               //               html.AnchorElement()
                                          //               //                 ..href = url
                                          //               //                 ..setAttribute(
                                          //               //                     'download',
                                          //               //                     'qrcode.png')
                                          //               //                 ..click();

                                          //               //           html.Url
                                          //               //               .revokeObjectUrl(
                                          //               //                   url);
                                          //               //         },
                                          //               //         icon: Icon(Icons
                                          //               //             .file_download))
                                          //               //     : SizedBox()
                                          //             ],
                                          //           ),
                                          //     // Image.network(
                                          //     //     '${MyConstant().domain_chao}/files/$foder/payment/$payment_img',
                                          //     //     height:
                                          //     //         MediaQuery.of(context)
                                          //     //                 .size
                                          //     //                 .height *
                                          //     //             0.3,
                                          //     //   )
                                          //   ],
                                          // ),
                                          // Divider(),
                                          if (payment_tser == '2')
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    show_qr == 1
                                                        ? Container(
                                                            child: Stack(
                                                              children: [
                                                                RepaintBoundary(
                                                                    key:
                                                                        qrImageKey,
                                                                    child: Container(
                                                                        color: Colors.white,
                                                                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                          Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Image.network(
                                                                                  '${MyConstant().domain_chao_img}/files/$foder/payment/$payment_img',
                                                                                  height: MediaQuery.of(context).size.height * 0.3,
                                                                                  cacheWidth: 500,
                                                                                )
                                                                              ])
                                                                        ]))),
                                                                // Positioned(
                                                                //   bottom: 0,
                                                                //   right: 0,
                                                                //   child: Container(
                                                                //     width: 50,
                                                                //     height: 40,
                                                                //     decoration:
                                                                //         BoxDecoration(
                                                                //       color: Colors
                                                                //           .white,
                                                                //       borderRadius:
                                                                //           const BorderRadius
                                                                //               .only(
                                                                //         topLeft: Radius
                                                                //             .circular(
                                                                //                 20),
                                                                //         topRight: Radius
                                                                //             .circular(
                                                                //                 20),
                                                                //         bottomLeft:
                                                                //             Radius.circular(
                                                                //                 20),
                                                                //         bottomRight:
                                                                //             Radius.circular(
                                                                //                 20),
                                                                //       ),
                                                                //       border: Border.all(
                                                                //           color: Colors
                                                                //               .grey,
                                                                //           width: 1),
                                                                //     ),
                                                                //     child: Row(
                                                                //       mainAxisAlignment:
                                                                //           MainAxisAlignment
                                                                //               .center,
                                                                //       children: [
                                                                //         Padding(
                                                                //           padding:
                                                                //               const EdgeInsets.all(
                                                                //                   4.0),
                                                                //           child:
                                                                //               IconButton(
                                                                //             icon:
                                                                //                 const Icon(
                                                                //               Icons
                                                                //                   .file_download,
                                                                //               color:
                                                                //                   Colors.black,
                                                                //               size:
                                                                //                   16,
                                                                //             ),
                                                                //             onPressed:
                                                                //                 () async {
                                                                //               RenderRepaintBoundary
                                                                //                   boundary =
                                                                //                   qrImageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                                                                //               ui.Image
                                                                //                   image =
                                                                //                   await boundary.toImage();
                                                                //               ByteData?
                                                                //                   byteData =
                                                                //                   await image.toByteData(format: ui.ImageByteFormat.png);
                                                                //               Uint8List
                                                                //                   bytes =
                                                                //                   byteData!.buffer.asUint8List();
                                                                //               html.Blob
                                                                //                   blob =
                                                                //                   html.Blob([
                                                                //                 bytes
                                                                //               ]);
                                                                //               String
                                                                //                   url =
                                                                //                   html.Url.createObjectUrlFromBlob(blob);

                                                                //               html.AnchorElement
                                                                //                   anchor =
                                                                //                   html.AnchorElement()
                                                                //                     ..href = url
                                                                //                     ..setAttribute('download', 'qrcode.png')
                                                                //                     ..click();

                                                                //               html.Url.revokeObjectUrl(
                                                                //                   url);
                                                                //             },
                                                                //           ),
                                                                //         ),
                                                                //       ],
                                                                //     ),
                                                                //   ),
                                                                // ),
                                                              ],
                                                            ),
                                                          )
                                                        : Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                widget.cuslang ==
                                                                        'EN'
                                                                    ? 'Account number'
                                                                    : 'เลขบัญชี',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  border: Border.all(
                                                                      color:
                                                                          grey,
                                                                      style: BorderStyle
                                                                          .solid),
                                                                  color: Colors
                                                                      .grey
                                                                      .shade100,
                                                                ),
                                                                child: Text(
                                                                  '$selectedValue',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 2,
                                                              ),
                                                              IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    Clipboard.setData(
                                                                        new ClipboardData(
                                                                            text:
                                                                                '$selectedValue'));
                                                                    Fluttertoast.showToast(
                                                                        msg:
                                                                            'Copy',
                                                                        backgroundColor:
                                                                            Colors
                                                                                .black,
                                                                        textColor:
                                                                            Colors
                                                                                .white,
                                                                        webPosition:
                                                                            "center",
                                                                        webBgColor:
                                                                            "#000000",
                                                                        toastLength:
                                                                            Toast.LENGTH_SHORT);
                                                                  },
                                                                  icon: Icon(
                                                                    Icons
                                                                        .content_copy_outlined,
                                                                  ))
                                                            ],
                                                          ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          child: AutoSizeText(
                                                            minFontSize: 10,
                                                            maxFontSize: 15,
                                                            maxLines: 1,
                                                            widget.cuslang ==
                                                                    'EN'
                                                                ? 'Account name : $payment_bname'
                                                                : 'ชื่อบัญชี : $payment_bname',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    Font_
                                                                        .Fonts_T
                                                                //fontSize: 10.0
                                                                //fontSize: 10.0
                                                                ),
                                                          ),
                                                        ),
                                                        // SizedBox(
                                                        //   child: Text(
                                                        //     'ชื่อบัญชี : $payment_bname',
                                                        //     maxLines: 1,
                                                        //     style: TextStyle(),
                                                        //   ),
                                                        // ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          child: Text(
                                                            widget.cuslang ==
                                                                    'EN'
                                                                ? 'Bank : $payment_bank'
                                                                : 'ธนาคาร : $payment_bank',
                                                            style: TextStyle(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        RichText(
                                                          text: TextSpan(
                                                            text: widget.cuslang ==
                                                                    'EN'
                                                                ? 'Amount of money : '
                                                                : 'จำนวนเงิน : ',
                                                            children: <TextSpan>[
                                                              TextSpan(
                                                                  text:
                                                                      '${nFormat.format(double.parse(Form_payment1.text))}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        18,
                                                                  )),
                                                              TextSpan(
                                                                  text: widget.cuslang ==
                                                                          'EN'
                                                                      ? ' BHT'
                                                                      : ' บาท'),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.6,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                      child: base64_Slip == null
                                                          ? SizedBox(
                                                              height: MediaQuery
                                                                          .of(
                                                                              context)
                                                                      .size
                                                                      .width *
                                                                  0.4,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.6,
                                                              child: Center(
                                                                child: Text(
                                                                  "กรุณาอัพโหลดหลักฐานการโอนเงินและกดยืนยันการชำระ ขอบคุณครับ/ค่ะ",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontFamily:
                                                                          FitnessAppTheme
                                                                              .fontName,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ))
                                                          // Icon(Icons
                                                          //     .image_not_supported_sharp))
                                                          : Image.memory(
                                                              base64Decode(
                                                                  base64_Slip
                                                                      .toString()),
                                                              // height: 200,
                                                              // fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                    // Row(
                                                    //   children: [
                                                    //     Padding(
                                                    //       padding:
                                                    //           const EdgeInsets.only(
                                                    //               top: 4.0),
                                                    //       child: Container(
                                                    //         alignment: Alignment
                                                    //             .centerRight,
                                                    //         child: SizedBox(
                                                    //             width: MediaQuery.of(
                                                    //                         context)
                                                    //                     .size
                                                    //                     .width *
                                                    //                 0.6,
                                                    //             child:
                                                    //                 ElevatedButton(
                                                    //               style:
                                                    //                   ButtonStyle(
                                                    //                       shape: MaterialStateProperty.all<OutlinedBorder>(const RoundedRectangleBorder(
                                                    //                           borderRadius: BorderRadius.all(Radius.circular(
                                                    //                               5)))),
                                                    //                       foregroundColor: MaterialStateProperty.all<
                                                    //                               Color>(
                                                    //                           Colors
                                                    //                               .black),
                                                    //                       backgroundColor:
                                                    //                           MaterialStateProperty.all<
                                                    //                               Color>(
                                                    //                         const Color.fromRGBO(
                                                    //                             167,
                                                    //                             168,
                                                    //                             168,
                                                    //                             1),
                                                    //                       )),
                                                    //               onPressed: () {
                                                    //                 uploadFile_Slip();
                                                    //               },
                                                    //               child: Text(
                                                    //                 base64_Slip ==
                                                    //                         null
                                                    //                     ? widget.cuslang ==
                                                    //                             'EN'
                                                    //                         ? 'Upload evidence'
                                                    //                         : "อัพโหลดหลักฐาน "
                                                    //                     : widget.cuslang ==
                                                    //                             'EN'
                                                    //                         ? 'Upload again'
                                                    //                         : "อัพโหลดอีกครั้ง",
                                                    //                 style: TextStyle(
                                                    //                     fontFamily:
                                                    //                         Font_
                                                    //                             .Fonts_T,
                                                    //                     fontWeight:
                                                    //                         FontWeight
                                                    //                             .bold),
                                                    //               ),
                                                    //             )),
                                                    //       ),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                  ],
                                                )
                                              ],
                                            ),

                                          if (payment_tser != '2' &&
                                              payment_tser != '8')
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        RepaintBoundary(
                                                          key: qrImageKey,
                                                          child: Container(
                                                            color: Colors.white,
                                                            child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  // Container(
                                                                  //   color: Colors
                                                                  //       .white,
                                                                  //   // height: 30,
                                                                  //   width: MediaQuery.of(
                                                                  //               context)
                                                                  //           .size
                                                                  //           .width *
                                                                  //       0.6,
                                                                  //   child: Center(
                                                                  //     child:
                                                                  //         Container(
                                                                  //       alignment:
                                                                  //           Alignment
                                                                  //               .center,
                                                                  //       child: Image
                                                                  //           .asset(
                                                                  //         "assets/images/thai_qr_payment.png",
                                                                  //         height: MediaQuery.of(context)
                                                                  //                 .size
                                                                  //                 .width *
                                                                  //             0.18,
                                                                  //         width: MediaQuery.of(context)
                                                                  //                 .size
                                                                  //                 .width *
                                                                  //             0.6,
                                                                  //         fit: BoxFit
                                                                  //             .cover,
                                                                  //       ),
                                                                  //     ),
                                                                  //   ),
                                                                  // ),
                                                                  Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.6,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.6,
                                                                    color: Colors
                                                                        .white,
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Center(
                                                                          child:
                                                                              //https://github.com/saladpuk/PromptPay
                                                                              // PrettyQr(
                                                                              //   // typeNumber: 3,
                                                                              //   image: AssetImage(
                                                                              //     "Icon-chao.png",
                                                                              //   ),
                                                                              //   size: 110,
                                                                              //   data:
                                                                              //       '|004999022887193\r0865080001\r05082565\r10000\r',
                                                                              //   errorCorrectLevel:
                                                                              //       QrErrorCorrectLevel
                                                                              //           .M,
                                                                              //   roundEdges: true,
                                                                              // ),
                                                                              Center(
                                                                                  child: Container(
                                                                            height:
                                                                                MediaQuery.of(context).size.width * 0.6,
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.6,
                                                                            child:
                                                                                Center(
                                                                              child: payment_tser == '6'
                                                                                  ? PrettyQr(
                                                                                      // typeNumber: 3,
                                                                                      // image: Image.asset(
                                                                                      //   "assets/images/Icon-chao.png",
                                                                                      // ).image,
                                                                                      size: 200,
                                                                                      data: '|$selectedValue\r$refpay\r${DateFormat('ddMM').format(datex)}${datex.year + 543}\r${Form_payment1.text.replaceAll('.', '').toString()}\r',
                                                                                      errorCorrectLevel: QrErrorCorrectLevel.M,
                                                                                      roundEdges: true,
                                                                                    )
                                                                                  : PrettyQr(
                                                                                      // typeNumber: 3,
                                                                                      // image: Image.asset(
                                                                                      //   "assets/images/Icon-chao.png",
                                                                                      // ).image,
                                                                                      size: 200,
                                                                                      data: generateQRCode(promptPayID: "$selectedValue", amount: double.parse(Form_payment1.text)),
                                                                                      errorCorrectLevel: QrErrorCorrectLevel.M,
                                                                                      roundEdges: true,
                                                                                    ),
                                                                            ),
                                                                            //     SfBarcodeGenerator(
                                                                            //   value:
                                                                            //       "$selectedValue",
                                                                            //   symbology:
                                                                            //       QRCode(),
                                                                            //   showValue:
                                                                            //       false,
                                                                            // ),
                                                                          )),
                                                                          //     PrettyQr(
                                                                          //   // typeNumber: 3,
                                                                          //   image: AssetImage(
                                                                          //     "Icon-chao.png",
                                                                          //   ),
                                                                          //   size: 120,
                                                                          //   data:
                                                                          //       '004999022887193',
                                                                          //   // generateQRCode(
                                                                          //   //     promptPayID:
                                                                          //   //         "$selectedValue",
                                                                          //   //     amount: double
                                                                          //   //         .parse(provider
                                                                          //   //             .amount
                                                                          //   //             .toString())),
                                                                          //   errorCorrectLevel:
                                                                          //       QrErrorCorrectLevel
                                                                          //           .M,
                                                                          //   roundEdges: true,
                                                                          // ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Text(
                                                                    widget.cuslang ==
                                                                            'EN'
                                                                        ? 'Account number : $selectedValue'
                                                                        : 'เลขบัญชี : $selectedValue',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    widget.cuslang ==
                                                                            'EN'
                                                                        ? 'Amount of money : ${nFormat.format(double.parse(Form_payment1.text))} BHT'
                                                                        : 'จำนวนเงิน : ${nFormat.format(double.parse(Form_payment1.text))} บาท',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                ]),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    // Row(
                                                    //   children: [
                                                    //     Column(
                                                    //       children: [
                                                    //         Container(
                                                    //           width: MediaQuery.of(
                                                    //                       context)
                                                    //                   .size
                                                    //                   .width *
                                                    //               0.6,
                                                    //           height: MediaQuery.of(
                                                    //                       context)
                                                    //                   .size
                                                    //                   .width *
                                                    //               0.4,
                                                    //           child: base64_Slip ==
                                                    //                   null
                                                    //               ? SizedBox(
                                                    //                   height: 100,
                                                    //                   width: 100,
                                                    //                   child: Text(
                                                    //                     "กรุณาอัพโหลดหลักฐานการโอนเงินและกดยืนยันการชำระ ขอบคุณครับ/ค่ะ",
                                                    //                     textAlign:
                                                    //                         TextAlign
                                                    //                             .center,
                                                    //                     style: TextStyle(
                                                    //                         color: Colors
                                                    //                             .red,
                                                    //                         fontFamily:
                                                    //                             Font_
                                                    //                                 .Fonts_T,
                                                    //                         fontWeight:
                                                    //                             FontWeight.bold),
                                                    //                   ))
                                                    //               // Icon(Icons
                                                    //               //     .image_not_supported_sharp))
                                                    //               : Image.memory(
                                                    //                   base64Decode(
                                                    //                       base64_Slip
                                                    //                           .toString()),
                                                    //                   // height: 200,
                                                    //                   // fit: BoxFit.cover,
                                                    //                 ),
                                                    //         ),
                                                    //         Row(
                                                    //           mainAxisAlignment:
                                                    //               MainAxisAlignment
                                                    //                   .center,
                                                    //           children: [
                                                    //             Padding(
                                                    //               padding:
                                                    //                   const EdgeInsets
                                                    //                           .only(
                                                    //                       top: 4.0),
                                                    //               child: Container(
                                                    //                 alignment: Alignment
                                                    //                     .centerRight,
                                                    //                 child: SizedBox(
                                                    //                     width: MediaQuery.of(context)
                                                    //                             .size
                                                    //                             .width *
                                                    //                         0.6,
                                                    //                     child:
                                                    //                         ElevatedButton(
                                                    //                       style: ButtonStyle(
                                                    //                           shape: MaterialStateProperty.all<OutlinedBorder>(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))),
                                                    //                           foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                                    //                           backgroundColor: MaterialStateProperty.all<Color>(
                                                    //                             const Color.fromRGBO(
                                                    //                                 167,
                                                    //                                 168,
                                                    //                                 168,
                                                    //                                 1),
                                                    //                           )),
                                                    //                       onPressed:
                                                    //                           () {
                                                    //                         uploadFile_Slip();
                                                    //                       },
                                                    //                       child:
                                                    //                           AutoSizeText(
                                                    //                         base64_Slip ==
                                                    //                                 null
                                                    //                             ? widget.cuslang == 'EN'
                                                    //                                 ? 'Upload evidence'
                                                    //                                 : "อัพโหลดหลักฐาน "
                                                    //                             : widget.cuslang == 'EN'
                                                    //                                 ? 'Upload again'
                                                    //                                 : "อัพโหลดอีกครั้ง",
                                                    //                         overflow:
                                                    //                             TextOverflow.ellipsis,
                                                    //                         maxLines:
                                                    //                             2,
                                                    //                         minFontSize:
                                                    //                             8,
                                                    //                         maxFontSize:
                                                    //                             16,
                                                    //                         textAlign:
                                                    //                             TextAlign.center,
                                                    //                         style:
                                                    //                             TextStyle(
                                                    //                           color:
                                                    //                               Colors.black,
                                                    //                           fontWeight:
                                                    //                               FontWeight.bold,
                                                    //                           fontFamily:
                                                    //                               Font_.Fonts_T,
                                                    //                         ),
                                                    //                       ),
                                                    //                     )),
                                                    //               ),
                                                    //             ),
                                                    //           ],
                                                    //         )
                                                    //       ],
                                                    //     ),
                                                    //   ],
                                                    // )
                                                  ],
                                                )
                                              ],
                                            ),
                                          if (payment_tser == '8')
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        // decoration: BoxDecoration(
                                                        //   color: Colors.grey[100],
                                                        //   borderRadius:
                                                        //       BorderRadius.all(
                                                        //           Radius.circular(
                                                        //               8)),
                                                        //   border: Border.all(
                                                        //       color: Colors
                                                        //           .grey.shade100,
                                                        //       width: 1),
                                                        // ),
                                                        child: TimerCountdown(
                                                          format:
                                                              CountDownTimerFormat
                                                                  .minutesSeconds,
                                                          minutesDescription:
                                                              widget.cuslang ==
                                                                      'EN'
                                                                  ? 'min'
                                                                  : 'นาที',
                                                          secondsDescription:
                                                              widget.cuslang ==
                                                                      'EN'
                                                                  ? 'sec'
                                                                  : 'วินาที',
                                                          timeTextStyle:
                                                              TextStyle(
                                                                  color: Colors
                                                                      .red[600],
                                                                  // fontWeight:
                                                                  //     FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                          endTime:
                                                              DateTime.now()
                                                                  .add(
                                                            Duration(
                                                              minutes: 15,
                                                              seconds: 30,
                                                            ),
                                                          ),
                                                          onEnd: () {
                                                            // Navigator.pop(
                                                            //     context, 'OK');
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        RepaintBoundary(
                                                          key: qrImageKey,
                                                          child: Container(
                                                            color: Colors.white,
                                                            child: Stack(
                                                              children: [
                                                                double.parse(Form_payment1
                                                                            .text) ==
                                                                        0.0
                                                                    ? SizedBox()
                                                                    : Container(
                                                                        height:
                                                                            320,
                                                                        width:
                                                                            220,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              AppbackgroundColor.Sub_Abg_Colors,
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(8)),
                                                                          border: Border.all(
                                                                              color: Colors.grey,
                                                                              width: 1),
                                                                        ),
                                                                        child: RepaintBoundary(
                                                                            key: _globalKey,
                                                                            child: Container(
                                                                              height: MediaQuery.of(context).size.height,
                                                                              width: MediaQuery.of(context).size.width,
                                                                              decoration: BoxDecoration(
                                                                                image: DecorationImage(image: NetworkImage('${MyConstant().domain_chao}/gen_qr_img.php?ren=$cid_ren&ref_id=$refpay&incid=$cid_docqr&sum=${double.parse(Form_payment1.text)}&extension=.png'), fit: BoxFit.fill),
                                                                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                                                              ),
                                                                            )),
                                                                      ),
                                                                // Positioned(
                                                                //   top: 0,
                                                                //   left: MediaQuery.of(
                                                                //               context)
                                                                //           .size
                                                                //           .width *
                                                                //       0.72,
                                                                //   child: Container(
                                                                //     width: 84,
                                                                //     height: 84,
                                                                //     decoration:
                                                                //         BoxDecoration(
                                                                //       color: FitnessAppTheme
                                                                //           .nearlyWhite
                                                                //           .withOpacity(
                                                                //               0.2),
                                                                //       shape: BoxShape
                                                                //           .circle,
                                                                //     ),
                                                                //     child: InkWell(
                                                                //       onTap: () async {
                                                                //         var _url =
                                                                //             "${MyConstant().domain_chao}/gen_qr_img.php?ren=$cid_ren&ref_id=$refpay&incid=$cid_docqr&sum=${double.parse(Form_payment1.text)}&extension=.png";
                                                                //         // saveImage(_url);
                                                                //         // if (kIsWeb) {
                                                                //         downloadImage(
                                                                //             _url);
                                                                //         // }
                                                                //         // else {
                                                                //         //   _saveNetworkImage(
                                                                //         //       _url);
                                                                //         // }

                                                                //         // downloadImage(
                                                                //         //     _url);
                                                                //         // await WebImageDownloader
                                                                //         //     .downloadImageFromWeb(
                                                                //         //   _url,
                                                                //         //   name:
                                                                //         //       '$refpay',
                                                                //         //   imageType:
                                                                //         //       ImageType
                                                                //         //           .jpeg,
                                                                //         // );
                                                                //       }, // button pressed
                                                                //       child: Column(
                                                                //         mainAxisAlignment:
                                                                //             MainAxisAlignment
                                                                //                 .center,
                                                                //         children: <Widget>[
                                                                //           Icon(Icons
                                                                //               .get_app), // icon
                                                                //           Text(
                                                                //               "Load QR"), // text
                                                                //         ],
                                                                //       ),
                                                                //     ),
                                                                //   ),
                                                                // ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    // Divider(),
                                                    // Row(
                                                    //   mainAxisAlignment:
                                                    //       MainAxisAlignment
                                                    //           .spaceBetween,
                                                    //   children: [
                                                    //     Text(
                                                    //       widget.cuslang == 'EN'
                                                    //           ? 'Payment details'
                                                    //           : "รายละเอียดการชำระ",
                                                    //       textAlign:
                                                    //           TextAlign.start,
                                                    //       style: TextStyle(
                                                    //         fontWeight:
                                                    //             FontWeight.bold,
                                                    //         fontSize: 12,
                                                    //       ),
                                                    //     ),
                                                    //     payment_tser == '7'
                                                    //         ? SizedBox()
                                                    //         : payment_tser == '2'
                                                    //             ? SizedBox()
                                                    //             : TextButton(
                                                    //                 onPressed:
                                                    //                     () async {
                                                    //                   // RenderRepaintBoundary
                                                    //                   //     boundary =
                                                    //                   //     qrImageKey
                                                    //                   //         .currentContext!
                                                    //                   //         .findRenderObject() as RenderRepaintBoundary;
                                                    //                   // ui.Image
                                                    //                   //     image =
                                                    //                   //     await boundary
                                                    //                   //         .toImage();
                                                    //                   // ByteData?
                                                    //                   //     byteData =
                                                    //                   //     await image.toByteData(
                                                    //                   //         format:
                                                    //                   //             ui.ImageByteFormat.png);
                                                    //                   // Uint8List
                                                    //                   //     bytes =
                                                    //                   //     byteData!
                                                    //                   //         .buffer
                                                    //                   //         .asUint8List();
                                                    //                   // html.Blob
                                                    //                   //     blob =
                                                    //                   //     html.Blob([
                                                    //                   //   bytes
                                                    //                   // ]);
                                                    //                   // String url = html
                                                    //                   //         .Url
                                                    //                   //     .createObjectUrlFromBlob(
                                                    //                   //         blob);

                                                    //                   // html.AnchorElement
                                                    //                   //     anchor =
                                                    //                   //     html.AnchorElement()
                                                    //                   //       ..href =
                                                    //                   //           url
                                                    //                   //       ..setAttribute(
                                                    //                   //           'download',
                                                    //                   //           'qrcode.png')
                                                    //                   //       ..click();
                                                    //                   // html.Url
                                                    //                   //     .revokeObjectUrl(
                                                    //                   //         url);
                                                    //                   // print(
                                                    //                   //     '$_platformVersion');
                                                    //                 },
                                                    //                 child: Text(
                                                    //                   "ดาวโหลด QR Code",
                                                    //                   style: TextStyle(
                                                    //                       fontSize:
                                                    //                           14,
                                                    //                       fontFamily:
                                                    //                           FontWeight_
                                                    //                               .Fonts_T,
                                                    //                       color: Colors
                                                    //                           .black),
                                                    //                 )),
                                                    //     // if (payment_tser == '2')
                                                    //     payment_img == ''
                                                    //         ? SizedBox()
                                                    //         : Row(
                                                    //             children: [
                                                    //               TextButton(
                                                    //                   onPressed:
                                                    //                       () async {
                                                    //                     setState(
                                                    //                         () {
                                                    //                       if (show_qr ==
                                                    //                           1) {
                                                    //                         show_qr =
                                                    //                             0;
                                                    //                       } else {
                                                    //                         show_qr =
                                                    //                             1;
                                                    //                       }
                                                    //                     });
                                                    //                   },
                                                    //                   child: Text(
                                                    //                     "QR Code",
                                                    //                     style: TextStyle(
                                                    //                         fontFamily: FontWeight_
                                                    //                             .Fonts_T,
                                                    //                         color:
                                                    //                             Colors.black),
                                                    //                   )),
                                                    //             ],
                                                    //           ),
                                                    //   ],
                                                    // ),
                                                    Divider(),
                                                    // SizedBox(
                                                    //   height: 5,
                                                    // )
                                                    // Row(
                                                    //   children: [
                                                    //     Column(
                                                    //       children: [
                                                    //         Container(
                                                    //           decoration:
                                                    //               BoxDecoration(
                                                    //             color: Colors.yellow
                                                    //                 .shade200,
                                                    //             borderRadius: BorderRadius.only(
                                                    //                 topLeft: Radius
                                                    //                     .circular(
                                                    //                         10),
                                                    //                 topRight: Radius
                                                    //                     .circular(
                                                    //                         10),
                                                    //                 bottomLeft: Radius
                                                    //                     .circular(
                                                    //                         10),
                                                    //                 bottomRight: Radius
                                                    //                     .circular(
                                                    //                         10)),
                                                    //             // border: Border.all(color: Colors.grey, width: 1),
                                                    //           ),
                                                    //           width: MediaQuery.of(
                                                    //                       context)
                                                    //                   .size
                                                    //                   .width *
                                                    //               0.6,
                                                    //           height: MediaQuery.of(
                                                    //                       context)
                                                    //                   .size
                                                    //                   .width *
                                                    //               0.4,
                                                    //           child: base64_Slip ==
                                                    //                   null
                                                    //               ? SizedBox(
                                                    //                   height: 100,
                                                    //                   width: 100,
                                                    //                   child: Text(
                                                    //                     "กรุณาอัพโหลดหลักฐานการโอนเงินและกดยืนยันการชำระ ขอบคุณครับ/ค่ะ",
                                                    //                     textAlign:
                                                    //                         TextAlign
                                                    //                             .center,
                                                    //                     style: TextStyle(
                                                    //                         color: Colors
                                                    //                             .red,
                                                    //                         fontFamily:
                                                    //                             Font_
                                                    //                                 .Fonts_T,
                                                    //                         fontWeight:
                                                    //                             FontWeight.bold),
                                                    //                   ))
                                                    //               //  Icon(Icons
                                                    //               //     .image_not_supported_sharp))
                                                    //               : Image.memory(
                                                    //                   base64Decode(
                                                    //                       base64_Slip
                                                    //                           .toString()),
                                                    //                   // height: 200,
                                                    //                   // fit: BoxFit.cover,
                                                    //                 ),
                                                    //         ),
                                                    //         Row(
                                                    //           mainAxisAlignment:
                                                    //               MainAxisAlignment
                                                    //                   .center,
                                                    //           children: [
                                                    //             Padding(
                                                    //               padding:
                                                    //                   const EdgeInsets
                                                    //                           .only(
                                                    //                       top: 4.0),
                                                    //               child: Container(
                                                    //                 alignment: Alignment
                                                    //                     .centerRight,
                                                    //                 child: SizedBox(
                                                    //                     width: MediaQuery.of(context)
                                                    //                             .size
                                                    //                             .width *
                                                    //                         0.6,
                                                    //                     child:
                                                    //                         ElevatedButton(
                                                    //                       style: ButtonStyle(
                                                    //                           shape: MaterialStateProperty.all<OutlinedBorder>(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))),
                                                    //                           foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                                    //                           backgroundColor: MaterialStateProperty.all<Color>(
                                                    //                             const Color.fromRGBO(
                                                    //                                 167,
                                                    //                                 168,
                                                    //                                 168,
                                                    //                                 1),
                                                    //                           )),
                                                    //                       onPressed:
                                                    //                           () {
                                                    //                         uploadFile_Slip();
                                                    //                       },
                                                    //                       child:
                                                    //                           AutoSizeText(
                                                    //                         base64_Slip ==
                                                    //                                 null
                                                    //                             ? widget.cuslang == 'EN'
                                                    //                                 ? 'Upload evidence'
                                                    //                                 : "อัพโหลดหลักฐาน "
                                                    //                             : widget.cuslang == 'EN'
                                                    //                                 ? 'Upload again'
                                                    //                                 : "อัพโหลดอีกครั้ง",
                                                    //                         overflow:
                                                    //                             TextOverflow.ellipsis,
                                                    //                         maxLines:
                                                    //                             2,
                                                    //                         minFontSize:
                                                    //                             8,
                                                    //                         maxFontSize:
                                                    //                             16,
                                                    //                         textAlign:
                                                    //                             TextAlign.center,
                                                    //                         style:
                                                    //                             TextStyle(
                                                    //                           color:
                                                    //                               Colors.black,
                                                    //                           fontWeight:
                                                    //                               FontWeight.bold,
                                                    //                           fontFamily:
                                                    //                               Font_.Fonts_T,
                                                    //                         ),
                                                    //                       ),
                                                    //                     )),
                                                    //               ),
                                                    //             ),
                                                    //           ],
                                                    //         )
                                                    //       ],
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          // Divider(),
                                          // Padding(
                                          //   padding: const EdgeInsets.all(8),
                                          //   child: Row(
                                          //     mainAxisAlignment:
                                          //         MainAxisAlignment.end,
                                          //     children: [
                                          //       SizedBox(
                                          //         width: 250,
                                          //         height: 40,
                                          //         child: ElevatedButton(
                                          //           onPressed: (base64_Slip ==
                                          //                       null ||
                                          //                   selectedValue == null)
                                          //               ? () async {
                                          //                   // var io2 = invoicePay ==
                                          //                   //             null ||
                                          //                   //         invoicePay == ''
                                          //                   //     ? '0'
                                          //                   //     : invoicePay!.substring(
                                          //                   //         0,
                                          //                   //         invoicePay!
                                          //                   //                 .length -
                                          //                   //             1); // string
                                          //                   // var io4 = invoicePayfine ==
                                          //                   //             null ||
                                          //                   //         invoicePayfine ==
                                          //                   //             ''
                                          //                   //     ? '0'
                                          //                   //     : invoicePayfine!.substring(
                                          //                   //         0,
                                          //                   //         invoicePayfine!
                                          //                   //                 .length -
                                          //                   //             1); // string

                                          //                   // var payby = 'U';
                                          //                   // var paybywidget =
                                          //                   //     '0'; // paybyselect == 'PAYCONTACT' ? '0' : custno;

                                          //                   // print(
                                          //                   //     '$invoicePay ..... $invoicePayfine ...... i i $paybywidget ii $io2 >>>>444>>>$io4>>>');
                                          //                   PanaraInfoDialog
                                          //                       .showAnimatedGrow(
                                          //                     context,
                                          //                     title: "Oops",
                                          //                     message:
                                          //                         "กรุณาอัพโหลดหลักฐานการชำระ !!!",
                                          //                     buttonText: "รับทราบ",
                                          //                     onTapDismiss:
                                          //                         () async {
                                          //                       Navigator.pop(
                                          //                           context);
                                          //                     },
                                          //                     panaraDialogType:
                                          //                         PanaraDialogType
                                          //                             .error,
                                          //                     barrierDismissible:
                                          //                         false, // optional parameter (default is true)
                                          //                   );
                                          //                 }
                                          //               : () async {
                                          //                   List newValuePDFimg =
                                          //                       [];
                                          //                   for (int index = 0;
                                          //                       index < 1;
                                          //                       index++) {
                                          //                     if (renTalModels[0]
                                          //                             .imglogo!
                                          //                             .trim() ==
                                          //                         '') {
                                          //                       // newValuePDFimg.add(
                                          //                       //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
                                          //                     } else {
                                          //                       newValuePDFimg.add(
                                          //                           '${MyConstant().domain_chao}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                                          //                     }
                                          //                   }

                                          //                   try {
                                          //                     sucress();
                                          //                     OKuploadFile_Slip(
                                          //                             newValuePDFimg)
                                          //                         .then((value) =>
                                          //                             in_Trans_invoice(
                                          //                                 newValuePDFimg));
                                          //                   } catch (e) {
                                          //                     _showMyDialogPay_Error(
                                          //                         'เกิดข้อผิดพลาด ตรวจสอบความถูกต้อง กรุณาลองอีกครั้ง!');
                                          //                   }
                                          //                 },
                                          //           style: ButtonStyle(
                                          //               shape: MaterialStateProperty.all<
                                          //                       OutlinedBorder>(
                                          //                   RoundedRectangleBorder(
                                          //                       borderRadius:
                                          //                           BorderRadius
                                          //                               .circular(
                                          //                                   10))),
                                          //               // foregroundColor:
                                          //               //     MaterialStateProperty.all<Color>(
                                          //               //         Colors.black26),
                                          //               backgroundColor:
                                          //                   MaterialStateProperty
                                          //                       .all<Color>(
                                          //                 (base64_Slip == null ||
                                          //                         selectedValue ==
                                          //                             null)
                                          //                     ? Colors.black26
                                          //                     : Colors.green,
                                          //               )),
                                          //           child: Text(
                                          //             widget.cuslang == 'EN'
                                          //                 ? 'Confirm payment'
                                          //                 : "ยืนยันการชำระ",
                                          //             style: TextStyle(
                                          //                 fontWeight:
                                          //                     FontWeight.bold,
                                          //                 fontFamily:
                                          //                     FontWeight_.Fonts_T,
                                          //                 fontSize: 15),
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                        paymentSer1 == null
                            ? SizedBox()
                            : gopay == 0
                                ? SizedBox()
                                : Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                      border: Border.all(
                                          color: Colors.grey.shade100,
                                          width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        // Expanded(flex: 1, child: Container()),
                                        Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  right: 10,
                                                  left: 10,
                                                  bottom: 10),
                                              child: Container(
                                                width: 120,
                                                padding: EdgeInsets.all(2),
                                                child: Center(
                                                  child: ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            // (maintenanceModels[int.parse('${row['index']}')]
                                                            //             .mst
                                                            //             .toString() ==
                                                            //         '3')
                                                            //     ? MaterialStateProperty.all<Color>(Colors.green)
                                                            //     :
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                          Colors.grey.shade600,
                                                        ),
                                                        shape: MaterialStateProperty.all<
                                                                RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ))),
                                                    onPressed: _downloadQrCode,
                                                    child: Translate
                                                        .TranslateAndSet_TextAutoSize(
                                                            'บันทึก QR',
                                                            Colors.black,
                                                            TextAlign.center,
                                                            null,
                                                            FontWeight_.Fonts_T,
                                                            12,
                                                            18,
                                                            1),
                                                  ),
                                                ),
                                              ),
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  right: 5, left: 5, bottom: 5),
                                              child: Center(
                                                child: Container(
                                                    width: 160,
                                                    padding: EdgeInsets.all(2),
                                                    child: OtpTimerButton(
                                                      height: 30,
                                                      text: Text(
                                                        (base64_Slip == null)
                                                            ? 'ยันยันการชำระ'
                                                            : 'ยันยันการชำระ ✔️',
                                                        style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T,
                                                        ),
                                                      ),
                                                      duration: 4,
                                                      radius: 8,
                                                      backgroundColor:
                                                          Colors.green.shade900,
                                                      textColor: Colors.black,
                                                      buttonType: ButtonType
                                                          .elevated_button,
                                                      loadingIndicator:
                                                          const CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.red,
                                                      ),
                                                      loadingIndicatorColor:
                                                          Colors.red,
                                                      onPressed: () async {
                                                        PanaraInfoDialog
                                                            .showAnimatedGrow(
                                                          context,
                                                          title: "คำเตือน",
                                                          message:
                                                              "โปรดแนบหลักฐานการชำระ ให้ตรงกับวันเวลาที่ทำรายการในระบบและเป็นหลักฐานที่ถูกต้อง (หากเกิดข้อผิดพลากกรุณาติดต่อเจ้าหน้าที่)",
                                                          buttonText: "รับทราบ",
                                                          onTapDismiss:
                                                              () async {
                                                            Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true,
                                                            ).pop();
                                                            Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                                () {
                                                              uploadFile_Slip()
                                                                  .then((ok) {
                                                                if (ok) {
                                                                  sucress_awit();
                                                                }
                                                              });
                                                            });
                                                          },
                                                          panaraDialogType:
                                                              PanaraDialogType
                                                                  .warning,
                                                          barrierDismissible:
                                                              false, // optional parameter (default is true)
                                                        );
                                                      },
                                                    )

                                                    //  Center(
                                                    //   child: ElevatedButton(
                                                    //     style: ButtonStyle(
                                                    //         backgroundColor:
                                                    //             // (maintenanceModels[int.parse('${row['index']}')]
                                                    //             //             .mst
                                                    //             //             .toString() ==
                                                    //             //         '3')
                                                    //             //     ? MaterialStateProperty.all<Color>(Colors.green)
                                                    //             //     :
                                                    //             MaterialStateProperty
                                                    //                 .all<
                                                    //                     Color>(
                                                    //           Colors.green
                                                    //               .shade900,
                                                    //         ),
                                                    //         shape: MaterialStateProperty.all<
                                                    //                 RoundedRectangleBorder>(
                                                    //             RoundedRectangleBorder(
                                                    //           borderRadius:
                                                    //               BorderRadius
                                                    //                   .circular(
                                                    //                       10.0),
                                                    //         ))),
                                                    //     onPressed:
                                                    //         () async {
                                                    //       PanaraInfoDialog
                                                    //           .showAnimatedGrow(
                                                    //         context,
                                                    //         title:
                                                    //             "คำเตือน",
                                                    //         message:
                                                    //             "โปรดแนบหลักฐานการชำระ ให้ตรงกับวันเวลาที่ทำรายการในระบบและเป็นหลักฐานที่ถูกต้อง (หากเกิดข้อผิดพลากกรุณาติดต่อเจ้าหน้าที่)",
                                                    //         buttonText:
                                                    //             "รับทราบ",
                                                    //         onTapDismiss:
                                                    //             () async {
                                                    //           Navigator.of(
                                                    //             context,
                                                    //             rootNavigator:
                                                    //                 true,
                                                    //           ).pop();
                                                    //           Future.delayed(
                                                    //               const Duration(
                                                    //                   milliseconds:
                                                    //                       300),
                                                    //               () {
                                                    //             uploadFile_Slip()
                                                    //                 .then(
                                                    //                     (value) {
                                                    //               sucress_awit();
                                                    //             });
                                                    //           });
                                                    //         },
                                                    //         panaraDialogType:
                                                    //             PanaraDialogType
                                                    //                 .warning,
                                                    //         barrierDismissible:
                                                    //             false, // optional parameter (default is true)
                                                    //       );
                                                    //     },
                                                    //     child: (base64_Slip ==
                                                    //             null)
                                                    //         ? Translate.TranslateAndSet_TextAutoSize(
                                                    //             'ยันยันการชำระ',
                                                    //             CustomerScreen_Color
                                                    //                 .Colors_Text3_,
                                                    //             TextAlign
                                                    //                 .center,
                                                    //             null,
                                                    //             FontWeight_
                                                    //                 .Fonts_T,
                                                    //             12,
                                                    //             18,
                                                    //             1)
                                                    //         : Translate.TranslateAndSet_TextAutoSize(
                                                    //             'ยันยันการชำระ ✔️',
                                                    //             CustomerScreen_Color
                                                    //                 .Colors_Text3_,
                                                    //             TextAlign
                                                    //                 .center,
                                                    //             null,
                                                    //             FitnessAppTheme
                                                    //                 .fontName,
                                                    //             12,
                                                    //             18,
                                                    //             1),
                                                    //   ),
                                                    // ),
                                                    ),
                                              ),
                                            )),
                                        // Expanded(
                                        //   flex: 1,
                                        //   child: Padding(
                                        //     padding: EdgeInsets.only(
                                        //         right: 10,
                                        //         left: 10,
                                        //         bottom: 10),
                                        //     child: Container(
                                        //         padding: EdgeInsets.all(5),
                                        //         decoration: BoxDecoration(
                                        //           borderRadius:
                                        //               BorderRadius.all(
                                        //                   Radius.circular(8)),
                                        //           color: Colors.white,
                                        //           border: Border.all(
                                        //               color: Colors.grey,
                                        //               width: 1),
                                        //         ),
                                        //         // width: MediaQuery.of(context)
                                        //         //         .size
                                        //         //         .width *
                                        //         //     0.85,
                                        //         child: GestureDetector(
                                        //           onTap: () {
                                        //             uploadFile_Slip();
                                        //           },
                                        //           child: Container(
                                        //             padding: EdgeInsets.all(2),
                                        //             child: base64_Slip == null
                                        //                 ? Column(
                                        //                     mainAxisAlignment:
                                        //                         MainAxisAlignment
                                        //                             .center,
                                        //                     crossAxisAlignment:
                                        //                         CrossAxisAlignment
                                        //                             .center,
                                        //                     children: [
                                        //                       Row(
                                        //                         children: [
                                        //                           Expanded(
                                        //                               child:
                                        //                                   Icon(
                                        //                             Icons
                                        //                                 .system_update_alt_outlined,
                                        //                             size: 25,
                                        //                             color: Colors
                                        //                                     .blue[
                                        //                                 200],
                                        //                           ))
                                        //                         ],
                                        //                       ),
                                        //                       Row(
                                        //                         children: [
                                        //                           Expanded(
                                        //                             child: Text(
                                        //                               "คลิกหรือกด เพื่อเลือกไฟล์",
                                        //                               textAlign:
                                        //                                   TextAlign
                                        //                                       .center,
                                        //                               style: TextStyle(
                                        //                                   fontSize:
                                        //                                       12,
                                        //                                   color: Colors.grey[
                                        //                                       700],
                                        //                                   fontFamily: Font_
                                        //                                       .Fonts_T,
                                        //                                   fontWeight:
                                        //                                       FontWeight.bold),
                                        //                             ),
                                        //                           )
                                        //                         ],
                                        //                       ),
                                        //                       Row(
                                        //                         children: [
                                        //                           Expanded(
                                        //                             child: Text(
                                        //                               "รองรับไฟล์ภาพ JPG หรือ PNG",
                                        //                               textAlign:
                                        //                                   TextAlign
                                        //                                       .center,
                                        //                               style:
                                        //                                   TextStyle(
                                        //                                 fontSize:
                                        //                                     10,
                                        //                                 color: Colors
                                        //                                     .grey[700],
                                        //                                 fontFamily:
                                        //                                     Font_.Fonts_T,
                                        //                               ),
                                        //                             ),
                                        //                           )
                                        //                         ],
                                        //                       ),
                                        //                       Row(
                                        //                         children: [
                                        //                           Expanded(
                                        //                             child: Text(
                                        //                               "ขนาดไฟล์สูงสุด: 10MB",
                                        //                               textAlign:
                                        //                                   TextAlign
                                        //                                       .center,
                                        //                               style:
                                        //                                   TextStyle(
                                        //                                 fontSize:
                                        //                                     10,
                                        //                                 color: Colors
                                        //                                     .grey[700],
                                        //                                 fontFamily:
                                        //                                     Font_.Fonts_T,
                                        //                               ),
                                        //                             ),
                                        //                           )
                                        //                         ],
                                        //                       ),
                                        //                     ],
                                        //                   )
                                        //                 : Image.memory(
                                        //                     base64Decode(
                                        //                         base64_Slip
                                        //                             .toString()),
                                        //                     // height: 200,
                                        //                     // fit: BoxFit.cover,
                                        //                   ),
                                        //           ),
                                        //         )),
                                        //   ),
                                        // )
                                      ],
                                    ),
                                  ),
                        // paymentSer1 == null
                        //     ? SizedBox()
                        //     : gopay == 0
                        //         ? SizedBox()
                        //         : Padding(
                        //             padding: EdgeInsets.only(
                        //                 right: 8, left: 8, top: 4, bottom: 8),
                        //             child: Container(
                        //               decoration: BoxDecoration(
                        //                 color: Colors.white,
                        //                 borderRadius: BorderRadius.only(
                        //                     topLeft: Radius.circular(10),
                        //                     topRight: Radius.circular(10),
                        //                     bottomLeft: Radius.circular(10),
                        //                     bottomRight: Radius.circular(10)),
                        //                 // border: Border.all(color: Colors.grey, width: 1),
                        //               ),
                        //               child: Column(
                        //                 children: [
                        //                   Padding(
                        //                     padding: EdgeInsets.all(10),
                        //                     child: Row(
                        //                       children: [
                        //                         Container(
                        //                             padding: EdgeInsets.all(5),
                        //                             decoration: BoxDecoration(
                        //                               color: Color.fromARGB(
                        //                                   255, 255, 250, 210),
                        //                               borderRadius:
                        //                                   BorderRadius.only(
                        //                                       topLeft:
                        //                                           Radius.circular(
                        //                                               10),
                        //                                       topRight:
                        //                                           Radius.circular(
                        //                                               10),
                        //                                       bottomLeft:
                        //                                           Radius.circular(
                        //                                               10),
                        //                                       bottomRight:
                        //                                           Radius.circular(
                        //                                               10)),
                        //                               border: Border.all(
                        //                                   color: Colors
                        //                                       .yellow.shade800,
                        //                                   width: 1),
                        //                             ),
                        //                             width: MediaQuery.of(context)
                        //                                     .size
                        //                                     .width *
                        //                                 0.85,
                        //                             child: Column(
                        //                               children: [
                        //                                 Row(
                        //                                   children: [
                        //                                     Expanded(
                        //                                         flex: 1,
                        //                                         child: Icon(Icons
                        //                                             .info_outline)),
                        //                                     Expanded(
                        //                                         flex: 6,
                        //                                         child: Text(
                        //                                           "กรุณาดำเนินการให้เสร็จสมบูรณ์",
                        //                                           textAlign:
                        //                                               TextAlign
                        //                                                   .start,
                        //                                           style: TextStyle(
                        //                                               color: Colors
                        //                                                   .yellow
                        //                                                   .shade800,
                        //                                               fontFamily:
                        //                                                   Font_
                        //                                                       .Fonts_T,
                        //                                               fontWeight:
                        //                                                   FontWeight
                        //                                                       .bold),
                        //                                         ))
                        //                                   ],
                        //                                 ),
                        //                                 Row(
                        //                                   children: [
                        //                                     Expanded(
                        //                                         flex: 1,
                        //                                         child:
                        //                                             SizedBox()),
                        //                                     Expanded(
                        //                                         flex: 6,
                        //                                         child: Text(
                        //                                           "เรียนท่านลูกค้า",
                        //                                           textAlign:
                        //                                               TextAlign
                        //                                                   .start,
                        //                                           style:
                        //                                               TextStyle(
                        //                                             color: Colors
                        //                                                 .yellow
                        //                                                 .shade800,
                        //                                             fontFamily: Font_
                        //                                                 .Fonts_T,
                        //                                           ),
                        //                                         ))
                        //                                   ],
                        //                                 ),
                        //                                 Row(
                        //                                   children: [
                        //                                     Expanded(
                        //                                         flex: 1,
                        //                                         child:
                        //                                             SizedBox()),
                        //                                     Expanded(
                        //                                         flex: 6,
                        //                                         child: Text(
                        //                                           "เพื่อให้การชำระเงินของท่านเสร็จสมบูรณ์ กรุณาดำเนินการดังนี้:",
                        //                                           textAlign:
                        //                                               TextAlign
                        //                                                   .start,
                        //                                           style:
                        //                                               TextStyle(
                        //                                             color: Colors
                        //                                                 .yellow
                        //                                                 .shade800,
                        //                                             fontFamily: Font_
                        //                                                 .Fonts_T,
                        //                                           ),
                        //                                         ))
                        //                                   ],
                        //                                 ),
                        //                                 Row(
                        //                                   children: [
                        //                                     Expanded(
                        //                                         flex: 1,
                        //                                         child:
                        //                                             SizedBox()),
                        //                                     Expanded(
                        //                                         flex: 6,
                        //                                         child: Text(
                        //                                           " - แนบหลักฐานการโอนเงิน เช่นสลิปการโอน หรือ หน้าจอยืนยันการทำรายการ",
                        //                                           textAlign:
                        //                                               TextAlign
                        //                                                   .start,
                        //                                           style:
                        //                                               TextStyle(
                        //                                             color: Colors
                        //                                                 .yellow
                        //                                                 .shade800,
                        //                                             fontFamily: Font_
                        //                                                 .Fonts_T,
                        //                                           ),
                        //                                         ))
                        //                                   ],
                        //                                 ),
                        //                                 Row(
                        //                                   children: [
                        //                                     Expanded(
                        //                                         flex: 1,
                        //                                         child:
                        //                                             SizedBox()),
                        //                                     Expanded(
                        //                                         flex: 6,
                        //                                         child: Text(
                        //                                           " - ตรวจสอบให้แน่ใจว่าภาพที่แนบสามารถมองเห็นรายละเอียดได้ชัดเจน",
                        //                                           textAlign:
                        //                                               TextAlign
                        //                                                   .start,
                        //                                           style:
                        //                                               TextStyle(
                        //                                             color: Colors
                        //                                                 .yellow
                        //                                                 .shade800,
                        //                                             fontFamily: Font_
                        //                                                 .Fonts_T,
                        //                                           ),
                        //                                         ))
                        //                                   ],
                        //                                 ),
                        //                                 Row(
                        //                                   children: [
                        //                                     Expanded(
                        //                                         flex: 1,
                        //                                         child:
                        //                                             SizedBox()),
                        //                                     Expanded(
                        //                                         flex: 6,
                        //                                         child: Text(
                        //                                           " - หากไม่มีการแนบหลักฐาน ระบบจะถือว่าการชำระเงินยังไม่เสร็จสมบูรณ์",
                        //                                           textAlign:
                        //                                               TextAlign
                        //                                                   .start,
                        //                                           style:
                        //                                               TextStyle(
                        //                                             color: Colors
                        //                                                 .yellow
                        //                                                 .shade800,
                        //                                             fontFamily: Font_
                        //                                                 .Fonts_T,
                        //                                           ),
                        //                                         ))
                        //                                   ],
                        //                                 ),
                        //                               ],
                        //                             )),
                        //                       ],
                        //                     ),
                        //                   ),
                        //                   Padding(
                        //                     padding: EdgeInsets.only(
                        //                         top: 5, right: 10, left: 10),
                        //                     child: Container(
                        //                         padding: EdgeInsets.all(5),
                        //                         decoration: BoxDecoration(
                        //                           color: Colors.white70,
                        //                           borderRadius: BorderRadius.only(
                        //                               topLeft: Radius.circular(0),
                        //                               topRight:
                        //                                   Radius.circular(0),
                        //                               bottomLeft:
                        //                                   Radius.circular(0),
                        //                               bottomRight:
                        //                                   Radius.circular(0)),
                        //                           border: Border.all(
                        //                               color: Colors.white54,
                        //                               width: 1),
                        //                         ),
                        //                         width: MediaQuery.of(context)
                        //                                 .size
                        //                                 .width *
                        //                             0.85,
                        //                         child: Row(
                        //                           children: [
                        //                             Expanded(
                        //                                 child: Text(
                        //                               " อัปโหลดหลักฐานการชำระเงิน",
                        //                               textAlign: TextAlign.start,
                        //                               style: TextStyle(
                        //                                   color: Colors.black,
                        //                                   fontFamily:
                        //                                       Font_.Fonts_T,
                        //                                   fontWeight:
                        //                                       FontWeight.bold),
                        //                             ))
                        //                           ],
                        //                         )),
                        //                   ),
                        //                   Padding(
                        //                     padding: EdgeInsets.only(
                        //                         right: 10, left: 10, bottom: 10),
                        //                     child: Container(
                        //                         padding: EdgeInsets.all(20),
                        //                         decoration: BoxDecoration(
                        //                           color: Colors.white,
                        //                         ),
                        //                         width: MediaQuery.of(context)
                        //                                 .size
                        //                                 .width *
                        //                             0.85,
                        //                         child: GestureDetector(
                        //                           onTap: () {
                        //                             uploadFile_Slip();
                        //                           },
                        //                           child: Container(
                        //                             decoration: BoxDecoration(
                        //                               color: Colors.white,
                        //                               borderRadius:
                        //                                   BorderRadius.only(
                        //                                       topLeft:
                        //                                           Radius.circular(
                        //                                               5),
                        //                                       topRight:
                        //                                           Radius.circular(
                        //                                               5),
                        //                                       bottomLeft:
                        //                                           Radius.circular(
                        //                                               5),
                        //                                       bottomRight:
                        //                                           Radius.circular(
                        //                                               5)),
                        //                               border: Border.all(
                        //                                   color:
                        //                                       Colors.grey.shade50,
                        //                                   width: 1),
                        //                             ),
                        //                             padding: EdgeInsets.all(10),
                        //                             child: base64_Slip == null
                        //                                 ? Column(
                        //                                     mainAxisAlignment:
                        //                                         MainAxisAlignment
                        //                                             .center,
                        //                                     crossAxisAlignment:
                        //                                         CrossAxisAlignment
                        //                                             .center,
                        //                                     children: [
                        //                                       Row(
                        //                                         children: [
                        //                                           Expanded(
                        //                                               child: Icon(
                        //                                             Icons
                        //                                                 .system_update_alt_outlined,
                        //                                             size: 65,
                        //                                             color: Colors
                        //                                                 .grey,
                        //                                           ))
                        //                                         ],
                        //                                       ),
                        //                                       Row(
                        //                                         children: [
                        //                                           Expanded(
                        //                                             child: Text(
                        //                                               "คลิกหรือกด เพื่อเลือกไฟล์",
                        //                                               textAlign:
                        //                                                   TextAlign
                        //                                                       .center,
                        //                                               style: TextStyle(
                        //                                                   fontSize:
                        //                                                       16,
                        //                                                   color: Colors
                        //                                                       .grey,
                        //                                                   fontFamily:
                        //                                                       Font_
                        //                                                           .Fonts_T,
                        //                                                   fontWeight:
                        //                                                       FontWeight.bold),
                        //                                             ),
                        //                                           )
                        //                                         ],
                        //                                       ),
                        //                                       Row(
                        //                                         children: [
                        //                                           Expanded(
                        //                                             child: Text(
                        //                                               "รองรับไฟล์ภาพ JPG หรือ PNG",
                        //                                               textAlign:
                        //                                                   TextAlign
                        //                                                       .center,
                        //                                               style:
                        //                                                   TextStyle(
                        //                                                 fontSize:
                        //                                                     12,
                        //                                                 color: Colors
                        //                                                     .grey,
                        //                                                 fontFamily:
                        //                                                     Font_
                        //                                                         .Fonts_T,
                        //                                               ),
                        //                                             ),
                        //                                           )
                        //                                         ],
                        //                                       ),
                        //                                       Row(
                        //                                         children: [
                        //                                           Expanded(
                        //                                             child: Text(
                        //                                               "ขนาดไฟล์สูงสุด: 10MB",
                        //                                               textAlign:
                        //                                                   TextAlign
                        //                                                       .center,
                        //                                               style:
                        //                                                   TextStyle(
                        //                                                 fontSize:
                        //                                                     8,
                        //                                                 color: Colors
                        //                                                     .grey,
                        //                                                 fontFamily:
                        //                                                     Font_
                        //                                                         .Fonts_T,
                        //                                               ),
                        //                                             ),
                        //                                           )
                        //                                         ],
                        //                                       ),
                        //                                     ],
                        //                                   )
                        //                                 : Image.memory(
                        //                                     base64Decode(
                        //                                         base64_Slip
                        //                                             .toString()),
                        //                                     // height: 200,
                        //                                     // fit: BoxFit.cover,
                        //                                   ),
                        //                           ),
                        //                         )),
                        //                   ),
                        //                   Padding(
                        //                     padding: EdgeInsets.only(
                        //                         top: 5,
                        //                         right: 10,
                        //                         left: 10,
                        //                         bottom: 10),
                        //                     child: Container(
                        //                         padding: EdgeInsets.all(5),
                        //                         decoration: BoxDecoration(
                        //                           color: Colors.white70,
                        //                           borderRadius: BorderRadius.only(
                        //                               topLeft: Radius.circular(0),
                        //                               topRight:
                        //                                   Radius.circular(0),
                        //                               bottomLeft:
                        //                                   Radius.circular(0),
                        //                               bottomRight:
                        //                                   Radius.circular(0)),
                        //                           border: Border.all(
                        //                               color: Colors.white54,
                        //                               width: 1),
                        //                         ),
                        //                         width: MediaQuery.of(context)
                        //                                 .size
                        //                                 .width *
                        //                             0.85,
                        //                         child: Row(
                        //                           children: [
                        //                             Expanded(
                        //                               child: SizedBox(
                        //                                 height: 60,
                        //                                 child: ElevatedButton(
                        //                                   onPressed: (base64_Slip ==
                        //                                               null ||
                        //                                           selectedValue ==
                        //                                               null)
                        //                                       ? () async {
                        //                                           // var io2 = invoicePay ==
                        //                                           //             null ||
                        //                                           //         invoicePay == ''
                        //                                           //     ? '0'
                        //                                           //     : invoicePay!.substring(
                        //                                           //         0,
                        //                                           //         invoicePay!
                        //                                           //                 .length -
                        //                                           //             1); // string
                        //                                           // var io4 = invoicePayfine ==
                        //                                           //             null ||
                        //                                           //         invoicePayfine ==
                        //                                           //             ''
                        //                                           //     ? '0'
                        //                                           //     : invoicePayfine!.substring(
                        //                                           //         0,
                        //                                           //         invoicePayfine!
                        //                                           //                 .length -
                        //                                           //             1); // string

                        //                                           // var payby = 'U';
                        //                                           // var paybywidget =
                        //                                           //     '0'; // paybyselect == 'PAYCONTACT' ? '0' : custno;

                        //                                           // print(
                        //                                           //     '$invoicePay ..... $invoicePayfine ...... i i $paybywidget ii $io2 >>>>444>>>$io4>>>');
                        //                                           PanaraInfoDialog
                        //                                               .showAnimatedGrow(
                        //                                             context,
                        //                                             title: "Oops",
                        //                                             message:
                        //                                                 "กรุณาอัพโหลดหลักฐานการชำระ !!!",
                        //                                             buttonText:
                        //                                                 "รับทราบ",
                        //                                             onTapDismiss:
                        //                                                 () async {
                        //                                               Navigator.pop(
                        //                                                   context);
                        //                                             },
                        //                                             panaraDialogType:
                        //                                                 PanaraDialogType
                        //                                                     .error,
                        //                                             barrierDismissible:
                        //                                                 false, // optional parameter (default is true)
                        //                                           );
                        //                                         }
                        //                                       : () async {
                        //                                           List
                        //                                               newValuePDFimg =
                        //                                               [];
                        //                                           for (int index =
                        //                                                   0;
                        //                                               index < 1;
                        //                                               index++) {
                        //                                             if (renTalModels[
                        //                                                         0]
                        //                                                     .imglogo!
                        //                                                     .trim() ==
                        //                                                 '') {
                        //                                               // newValuePDFimg.add(
                        //                                               //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
                        //                                             } else {
                        //                                               newValuePDFimg
                        //                                                   .add(
                        //                                                       '${MyConstant().domain_chao}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                        //                                             }
                        //                                           }

                        //                                           try {
                        //                                             sucress();
                        //                                             OKuploadFile_Slip(
                        //                                                     newValuePDFimg)
                        //                                                 .then((value) =>
                        //                                                     in_Trans_invoice(
                        //                                                         newValuePDFimg));
                        //                                           } catch (e) {
                        //                                             _showMyDialogPay_Error(
                        //                                                 'เกิดข้อผิดพลาด ตรวจสอบความถูกต้อง กรุณาลองอีกครั้ง!');
                        //                                           }
                        //                                         },
                        //                                   style: ButtonStyle(
                        //                                       shape: MaterialStateProperty.all<
                        //                                               OutlinedBorder>(
                        //                                           RoundedRectangleBorder(
                        //                                               borderRadius:
                        //                                                   BorderRadius.circular(
                        //                                                       10))),
                        //                                       // foregroundColor:
                        //                                       //     MaterialStateProperty.all<Color>(
                        //                                       //         Colors.black26),
                        //                                       backgroundColor:
                        //                                           MaterialStateProperty
                        //                                               .all<Color>(
                        //                                         (base64_Slip ==
                        //                                                     null ||
                        //                                                 selectedValue ==
                        //                                                     null)
                        //                                             ? Colors.grey
                        //                                             : Colors
                        //                                                 .green,
                        //                                       )),
                        //                                   child: Text(
                        //                                     widget.cuslang == 'EN'
                        //                                         ? 'Confirm payment'
                        //                                         : "ยืนยันการชำระ",
                        //                                     style: TextStyle(
                        //                                         fontWeight:
                        //                                             FontWeight
                        //                                                 .bold,
                        //                                         fontFamily:
                        //                                             FontWeight_
                        //                                                 .Fonts_T,
                        //                                         fontSize: 15),
                        //                                   ),
                        //                                 ),
                        //                               ),
                        //                             )
                        //                           ],
                        //                         )),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ),

                        SizedBox(
                          height: 200,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<void> _downloadQrCode() async {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    final isMobileUserAgent =
        RegExp(r'android|iphone|ipad|ipod').hasMatch(userAgent);
    final isMobileBrowser =
        isMobileUserAgent && (html.window.screen?.width ?? 0) <= 700;

    // Must open while this button's user gesture is still active. iOS and
    // Android browsers commonly block a new download after awaiting toImage().
    final mobileImageWindow =
        isMobileBrowser ? html.window.open('about:blank', '_blank') : null;
    final renderObject = qrImageKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      mobileImageWindow?.close();
      return;
    }

    final image = await renderObject.toImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      image.dispose();
      mobileImageWindow?.close();
      return;
    }

    final blob = html.Blob([
      byteData.buffer.asUint8List(),
    ], 'image/png');
    final downloadUrl = html.Url.createObjectUrlFromBlob(blob);
    image.dispose();

    if (mobileImageWindow != null) {
      mobileImageWindow.location.href = downloadUrl;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.cuslang == 'EN'
                ? 'QR image opened. Press and hold the image to save it.'
                : 'เปิดรูป QR แล้ว กดค้างที่รูปเพื่อบันทึกลงเครื่อง'),
          ),
        );
      }
    } else {
      html.AnchorElement()
        ..href = downloadUrl
        ..setAttribute('download', 'qrcode.png')
        ..click();
    }

    Future<void>.delayed(const Duration(seconds: 30), () {
      html.Url.revokeObjectUrl(downloadUrl);
    });
  }

  void _showPaymentMethodSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _buildPaymentMethodSheet(sheetContext),
    );
  }

  Widget _buildPaymentMethodSheet(BuildContext sheetContext) {
    final isEn = widget.cuslang == 'EN';
    final qrPayload = widget.get_qr_img?.trim() ?? '';
    final steps = <String>[
      isEn
          ? 'Save the QR code or take a screenshot.'
          : 'กดปุ่ม "บันทึก QR" เพื่อบันทึกรูปไว้ในเครื่อง',
      isEn
          ? 'Open any banking application.'
          : 'เปิดแอปธนาคารใดก็ได้ (K PLUS, SCB EASY, Krungthai NEXT ฯลฯ)',
      isEn
          ? 'Select "Scan / QR Code" and choose the saved image.'
          : 'เลือกเมนู "สแกน / QR Code" แล้วเลือกรูปจากอัลบั้ม',
      isEn
          ? 'After successful payment, press the "Confirm Payment" button below and attach the transfer slip for verification.'
          : 'เมื่อชำระสำเร็จ กดปุ่ม "ยืนยันการชำระ" ด้านล่าง และแนบหลักฐานการโอนเงิน (สลิป) เพื่อให้ระบบตรวจสอบ',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5DEE2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEn ? 'How to pay' : 'วิธีการชำระเงิน',
                      style: const TextStyle(
                        color: Color(0xFF17262A),
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: const Color(0xFF66777D),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        Icons.qr_code_rounded,
                        size: 22,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? 'Pay via QR Payment' : 'ชำระผ่าน QR Payment',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Choice Ministore',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 13, 14, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D0F172A),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF0284C7),
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            isEn
                                ? 'How to pay in 4 easy steps'
                                : 'วิธีชำระเงินง่ายๆ 4 ขั้นตอน',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    for (int i = 0; i < steps.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 23,
                              height: 23,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: i == steps.length - 1
                                    ? const Color(0xFFFFE7D6)
                                    : const Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: i == steps.length - 1
                                      ? const Color(0xFFFED7AA)
                                      : const Color(0xFFDBEAFE),
                                ),
                              ),
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: i == steps.length - 1
                                      ? const Color(0xFFEA580C)
                                      : const Color(0xFF0284C7),
                                ),
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  steps[i],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF334155),
                                    height: 1.45,
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
              if (qrPayload.isEmpty == false && !hasSlipInQrView()) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.qr_code_2_rounded,
                        size: 18,
                        color: Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isEn
                              ? 'A QR code is ready. Save it before switching apps.'
                              : 'มี QR พร้อมใช้งานแล้ว บันทึกไว้ก่อนสลับแอป',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF0C4A6E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool hasSlipInQrView() =>
      (widget.get_img?.trim().isNotEmpty ?? false) &&
      widget.get_img.toString() != '[]';

  String? _attachedSlipFileName() {
    final rawImage = widget.get_img?.trim();
    if (rawImage == null || rawImage.isEmpty || rawImage == '[]') {
      return null;
    }

    try {
      final decoded = jsonDecode(rawImage);
      if (decoded is List && decoded.isNotEmpty) {
        final fileName = decoded.first?.toString().trim() ?? '';
        return fileName.isEmpty ? null : fileName;
      }
      if (decoded is String && decoded.trim().isNotEmpty) {
        return decoded.trim();
      }
    } catch (_) {}

    final fileName = rawImage
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .trim();
    return fileName.isEmpty ? null : fileName;
  }

  String? _attachedSlipUrl() {
    final fileName = _attachedSlipFileName();
    final folder = foder?.trim();
    if (fileName == null || folder == null || folder.isEmpty) {
      return null;
    }
    return '${MyConstant().domain_chao_img}/files/$folder/slip/'
        '${Uri.encodeComponent(fileName)}';
  }

  void _showAttachedSlip() {
    final slipUrl = _attachedSlipUrl();
    if (slipUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบรูปหลักฐานการชำระเงิน')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(dialogContext).size.height * 0.82,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Image.network(
                  slipUrl,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'ไม่สามารถโหลดรูปหลักฐานได้',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xCC0F172A),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(dialogContext).pop(),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlipUnderReviewCard() {
    final hasAttachedSlip = _attachedSlipUrl() != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBE7CD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF3),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 20,
                  color: Color(0xFF15803D),
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'แนบหลักฐานการชำระแล้ว',
                      style: TextStyle(
                        color: Color(0xFF166534),
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'รอระบบตรวจสอบการชำระเงิน',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasAttachedSlip ? _showAttachedSlip : null,
                  icon: const Icon(Icons.image_outlined, size: 16),
                  label: const Text('ดูหลักฐาน'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF15803D),
                    disabledForegroundColor: const Color(0xFF94A3B8),
                    side: BorderSide(
                      color: hasAttachedSlip
                          ? const Color(0xFF86D3A5)
                          : const Color(0xFFE2E8F0),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _confirmSlipAttachment,
                  icon: const Icon(Icons.upload_file_outlined, size: 16),
                  label: const Text('แนบหลักฐานใหม่'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFFBFD3FB)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBillListSheet(List<InvoiceModel> invoices) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _buildBillListSheet(sheetContext, invoices),
    );
  }

  void _showQrZoom(String qrUrl, {bool showSaveInstruction = false}) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(dialogContext).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(14),
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 5.0,
                child: Image.network(
                  qrUrl,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('ไม่สามารถโหลด QR ได้'),
                    ),
                  ),
                ),
              ),
            ),
            if (showSaveInstruction)
              Positioned(
                left: 24,
                right: 24,
                bottom: 20,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xEE17262A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.touch_app_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.cuslang == 'EN'
                                ? 'Press and hold the QR image to save. On a computer, right-click and select Save image.'
                                : 'กดค้างที่รูป QR เพื่อบันทึกลงเครื่อง หรือบนคอมให้คลิกขวาที่รูป แล้วเลือกบันทึกรูปภาพ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Container(
              margin: const EdgeInsets.all(10),
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xCC0F172A),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(dialogContext).pop(),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillListSheet(
    BuildContext sheetContext,
    List<InvoiceModel> invoices,
  ) {
    final isEn = widget.cuslang == 'EN';
    double billAmount(InvoiceModel invoice) =>
        double.tryParse(invoice.total_bill ??
            invoice.amtall ??
            invoice.total ??
            invoice.amt ??
            '0') ??
        0;
    double billFine(InvoiceModel invoice) =>
        widget.invoiceFineAmounts?[invoice.docno?.trim() ?? ''] ?? 0;
    final total = invoices.fold<double>(
      0,
      (sum, invoice) => sum + billAmount(invoice) + billFine(invoice),
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5DEE2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEn
                            ? 'Your bills (${invoices.length})'
                            : 'บิลของคุณ (${invoices.length})',
                        style: const TextStyle(
                          color: Color(0xFF17262A),
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: const Color(0xFF66777D),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE8EEF3)),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    children: invoices.map((invoice) {
                      final description = invoice.descr?.trim() ?? '';
                      final fine = billFine(invoice);
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F8F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    invoice.docno ?? '-',
                                    style: const TextStyle(
                                      color: Color(0xFF17262A),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${nFormat.format(billAmount(invoice) + fine)}'
                                  ' ${isEn ? 'THB' : 'บาท'}',
                                  style: const TextStyle(
                                    color: Color(0xFF17262A),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ],
                            ),
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF66777D),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            if (fine > 0) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    size: 15,
                                    color: Color(0xFFEA580C),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isEn
                                        ? 'Late fee ${nFormat.format(fine)} THB'
                                        : 'ค่าปรับ ${nFormat.format(fine)} บาท',
                                    style: const TextStyle(
                                      color: Color(0xFFEA580C),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE8EEF3))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEn ? 'Amount due' : 'ยอดที่ต้องชำระ',
                      style: const TextStyle(
                        color: Color(0xFF45565C),
                        fontSize: 13.5,
                      ),
                    ),
                    Text(
                      '${nFormat.format(total)} ${isEn ? 'THB' : 'บาท'}',
                      style: const TextStyle(
                        color: Color(0xFF17262A),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _paymentChannelSummary({
    required bool isEn,
    required String bankCode,
    required String bankName,
    required String accountNo,
  }) {
    final parts = <String>[];
    if (bankCode.isNotEmpty) {
      parts.add(bankCode);
    } else if (bankName.isNotEmpty) {
      parts.add(bankName);
    }
    if (accountNo.isNotEmpty) {
      parts.add(accountNo);
    }
    if (parts.isEmpty) {
      return isEn
          ? 'See steps and destination account'
          : 'ดูขั้นตอนและบัญชีปลายทาง';
    }
    return parts.join(' · ');
  }

  Widget _buildQrPreparing() {
    final isEn = widget.cuslang == 'EN';
    return SafeArea(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.96, end: 1),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            child: child,
          ),
          child: Container(
            width: 280,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x160F2530),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE9F7EE),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Color(0xFF00A849),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isEn ? 'Creating QR code' : 'กำลังสร้าง QR Code',
                  style: const TextStyle(
                    color: Color(0xFF17262A),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEn
                      ? 'Please wait a moment.'
                      : 'กำลังเตรียมรายการชำระเงิน กรุณารอสักครู่',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF66777D),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExistingQr() {
    final rentalId = cid_ren?.trim() ?? '';
    final qrPayload = _activeQrPayload;
    final hasSlip = _generatedQrPayload == null &&
        (widget.get_img?.trim().isNotEmpty ?? false) &&
        widget.get_img.toString() != '[]';
    final invoices = widget.selectedInvoiceModels ?? const <InvoiceModel>[];
    double billAmount(InvoiceModel invoice) =>
        double.tryParse(invoice.total_bill ??
            invoice.amtall ??
            invoice.total ??
            invoice.amt ??
            '0') ??
        0;
    double billFine(InvoiceModel invoice) =>
        widget.invoiceFineAmounts?[invoice.docno?.trim() ?? ''] ?? 0;
    final total = invoices.fold<double>(
      0,
      (sum, invoice) => sum + billAmount(invoice),
    );
    final statusText = hasSlip
        ? (widget.cuslang == 'EN' ? 'Waiting for verification' : 'รอตรวจสอบ')
        : (widget.cuslang == 'EN' ? 'Waiting for payment' : 'รอชำระ');
    final statusColor =
        hasSlip ? const Color(0xFFD97706) : const Color(0xFF1D6D3A);
    final statusBackground =
        hasSlip ? const Color(0xFFFFF3E0) : const Color(0xFFE9F7EE);

    if (rentalId.isEmpty || qrPayload.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            widget.cuslang == 'EN'
                ? 'QR information is incomplete. Please return and reload.'
                : 'ข้อมูล QR ไม่ครบ กรุณาย้อนกลับแล้วโหลดใหม่',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final qrUrl = '${MyConstant().domain_chaoV2}/gen_qr_img.php'
        '?ren=${Uri.encodeQueryComponent(rentalId)}'
        '&$qrPayload&extension=.png';
    final qrTotal =
        double.tryParse(Uri.splitQueryString(qrPayload)['sum'] ?? '') ?? total;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                ((MediaQuery.of(context).size.height * 0.40)
                            .clamp(250.0, 520.0) +
                        MediaQuery.of(context).viewPadding.bottom)
                    .toDouble(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (invoices.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x120F2530),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(
                              () => _isBillDetailsExpanded =
                                  !_isBillDetailsExpanded,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.receipt_long_outlined,
                                    color: Color(0xFF17262A),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.cuslang == 'EN'
                                        ? 'Bill details'
                                        : 'รายละเอียดบิล',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Color(0xFF17262A),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${invoices.length} ${widget.cuslang == 'EN' ? 'bills' : 'บิล'}',
                                    style: const TextStyle(
                                      color: Color(0xFF66777D),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusBackground,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    _isBillDetailsExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: const Color(0xFF45565C),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedCrossFade(
                            firstChild: const SizedBox.shrink(),
                            secondChild: Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: Column(
                                children: invoices.map((invoice) {
                                  final description =
                                      invoice.descr?.trim() ?? '';
                                  final fine = billFine(invoice);
                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF6F8F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                invoice.docno ?? '-',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF17262A),
                                                ),
                                              ),
                                              if (description.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  description,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF66777D),
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(height: 7),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: statusBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  statusText,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: statusColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${nFormat.format(billAmount(invoice) + fine)} ${widget.cuslang == 'EN' ? 'THB' : 'บาท'}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF17262A),
                                              ),
                                            ),
                                            if (fine > 0) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                widget.cuslang == 'EN'
                                                    ? 'Fine ${nFormat.format(fine)}'
                                                    : 'ค่าปรับ ${nFormat.format(fine)}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFFB45309),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            crossFadeState: _isBillDetailsExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 180),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF1F3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(widget.cuslang == 'EN'
                                    ? 'Amount due'
                                    : 'ยอดที่ต้องชำระ'),
                                Text(
                                  '${nFormat.format(qrTotal)} ${widget.cuslang == 'EN' ? 'THB' : 'บาท'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF17262A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_2_rounded,
                                      size: 18,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Text(
                                    widget.cuslang == 'EN'
                                        ? 'Pay with QR'
                                        : 'ชำระเงินผ่าน QR',
                                    style: const TextStyle(
                                      color: Color(0xFF17262A),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.cuslang == 'EN'
                                    ? 'Open your bank app and scan to pay.'
                                    : 'เปิดแอปธนาคาร แล้วสแกน QR เพื่อชำระเงิน',
                                style: const TextStyle(
                                  color: Color(0xFF66777D),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!hasSlip)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Material(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => _showQrZoom(
                                  qrUrl,
                                  showSaveInstruction: true,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.download_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        widget.cuslang == 'EN'
                                            ? 'Save QR'
                                            : 'บันทึก QR',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
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
                  GestureDetector(
                    onTap: () => _showQrZoom(qrUrl),
                    child: Container(
                      height: kIsWeb
                          ? 330
                          : MediaQuery.of(context).size.height * 0.44,
                      width: kIsWeb
                          ? 255
                          : MediaQuery.of(context).size.width * 0.73,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8EEF3)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x100F2530),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SizedBox.expand(
                        child: RepaintBoundary(
                          key: qrImageKey,
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              AnimatedOpacity(
                                opacity: _isQrImageRevealReady ? 1 : 0,
                                duration: const Duration(milliseconds: 180),
                                child: Image.network(
                                  qrUrl,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.low,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }

                                    final expectedBytes =
                                        loadingProgress.expectedTotalBytes;
                                    final progress = expectedBytes == null
                                        ? null
                                        : loadingProgress
                                                .cumulativeBytesLoaded /
                                            expectedBytes;
                                    return Center(
                                      child: SizedBox(
                                        width: 34,
                                        height: 34,
                                        child: CircularProgressIndicator(
                                          value: progress,
                                          strokeWidth: 3,
                                          color: const Color(0xFF2563EB),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                    child: Text(
                                      widget.cuslang == 'EN'
                                          ? 'Unable to load QR code'
                                          : 'ไม่สามารถโหลด QR ได้',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              if (!_isQrImageRevealReady)
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 34,
                                        height: 34,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        widget.cuslang == 'EN'
                                            ? 'Preparing QR code...'
                                            : 'กำลังเตรียม QR...',
                                        style: const TextStyle(
                                          color: Color(0xFF45565C),
                                          fontWeight: FontWeight.w600,
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
                  hasSlip
                      ? _buildSlipUnderReviewCard()
                      : InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _showPaymentMethodSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: const Color(0xFFE9EEF3)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A0F172A),
                                  blurRadius: 12,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.menu_book_rounded,
                                    size: 17,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.cuslang == 'EN'
                                            ? 'How to pay'
                                            : 'วิธีการชำระเงิน',
                                        style: const TextStyle(
                                          color: Color(0xFF334155),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.cuslang == 'EN'
                                            ? 'Scan QR to pay'
                                            : 'สแกน QR เพื่อชำระเงิน',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF8A9AA1),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color: Color(0xFF94A3B8),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
          if (!hasSlip)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE1E8EB))),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x140F172A),
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildBillCartButton(
                    count: invoices.length,
                    onTap: () => _showBillListSheet(invoices),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildConfirmPaymentButton(
                      label: widget.cuslang == 'EN'
                          ? 'Confirm payment'
                          : 'ยืนยันการชำระ',
                      trailing: widget.cuslang == 'EN'
                          ? '${nFormat.format(qrTotal)} THB'
                          : '฿${nFormat.format(qrTotal)}',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBillCartButton({
    required int count,
    required VoidCallback onTap,
  }) =>
      SizedBox(
        width: 60,
        height: 64,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 24,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                Positioned(
                  top: -4,
                  right: -2,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3316A34A),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildConfirmPaymentButton({
    required String label,
    required String trailing,
  }) =>
      SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D2563EB),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _confirmSlipAttachment,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      trailing,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> _confirmSlipAttachment() async {
    if (!await Check_time()) {
      return;
    }
    if (base64_Slip != null || extension_ != null) {
      setState(() {
        base64_Slip = null;
        extension_ = null;
      });
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _buildAttachSlipSheet(sheetContext),
    );
  }

  Widget _buildAttachSlipSheet(BuildContext sheetContext) {
    final isEn = widget.cuslang == 'EN';
    final invoices = widget.selectedInvoiceModels ?? const <InvoiceModel>[];
    double billAmount(InvoiceModel invoice) =>
        double.tryParse(invoice.total_bill ??
            invoice.amtall ??
            invoice.total ??
            invoice.amt ??
            '0') ??
        0;
    double billFine(InvoiceModel invoice) =>
        widget.invoiceFineAmounts?[invoice.docno?.trim() ?? ''] ?? 0;
    final netTotal = invoices.fold<double>(
      0,
      (sum, invoice) => sum + billAmount(invoice) + billFine(invoice),
    );

    return StatefulBuilder(
      builder: (context, setSheetState) => _attachSlipSheetBody(
        sheetContext,
        isEn: isEn,
        netTotal: netTotal,
        setSheetState: setSheetState,
      ),
    );
  }

  Widget _attachSlipSheetBody(
    BuildContext sheetContext, {
    required bool isEn,
    required double netTotal,
    required StateSetter setSheetState,
  }) {
    final hasPicked = base64_Slip != null && base64_Slip!.isNotEmpty;
    final isUploading = _isSlipUploadSubmitting;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5DEE2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEn ? 'Payment confirmation' : 'ยืนยันการชำระเงิน',
                      style: const TextStyle(
                        color: Color(0xFF17262A),
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: const Color(0xFF66777D),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Color(0xFFB45309),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEn
                            ? 'Please attach proof of payment that matches the transaction date and time.'
                            : 'โปรดแนบหลักฐานการชำระ ให้ตรงกับวันและเวลาที่ทำรายการในระบบ',
                        style: const TextStyle(
                          color: Color(0xFF8A5312),
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(
                    Icons.upload_file_rounded,
                    size: 20,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEn ? 'Upload slip' : 'อัปโหลดสลิป',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECEC),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isEn ? 'Required' : 'จำเป็น',
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  if (isUploading) {
                    return;
                  }
                  final picked = await _pickSlipImage();
                  if (!mounted || !picked) {
                    return;
                  }
                  setSheetState(() {});
                },
                child: Container(
                  height: hasPicked ? 200 : 132,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F9FC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasPicked
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFCBD9E4),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasPicked
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(
                              base64Decode(base64_Slip!),
                              fit: BoxFit.contain,
                            ),
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1F0F172A),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.refresh_rounded,
                                      size: 15,
                                      color: Color(0xFF2563EB),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isEn ? 'Change' : 'เปลี่ยนรูป',
                                      style: const TextStyle(
                                        color: Color(0xFF2563EB),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 34,
                              color: Color(0xFF7B8B93),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isEn
                                  ? 'Tap to choose a slip image'
                                  : 'แตะเพื่อเลือกรูปสลิป',
                              style: const TextStyle(
                                color: Color(0xFF45565C),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isEn ? 'JPG, PNG' : 'รองรับ JPG, PNG',
                              style: const TextStyle(
                                color: Color(0xFF8A9AA1),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEn ? 'Amount due' : 'ยอดที่ต้องชำระ'),
                    Text(
                      '${nFormat.format(netTotal)} ${isEn ? 'THB' : 'บาท'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF17262A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (isUploading) ...[
                const LinearProgressIndicator(
                  minHeight: 3,
                  color: Color(0xFF2563EB),
                  backgroundColor: Color(0xFFE2E8F0),
                ),
                const SizedBox(height: 12),
              ],
              _SlideToConfirmBar(
                enabled: hasPicked && !isUploading,
                label: isUploading
                    ? (isEn ? 'Uploading proof...' : 'กำลังอัปโหลดหลักฐาน...')
                    : hasPicked
                        ? (isEn
                            ? 'Slide to confirm payment'
                            : 'เลื่อนเพื่อยืนยันการชำระ')
                        : (isEn
                            ? 'Attach a slip to continue'
                            : 'แนบสลิปเพื่อดำเนินการต่อ'),
                onConfirmed: () async {
                  if (base64_Slip == null || base64_Slip!.isEmpty) {
                    return false;
                  }
                  setSheetState(() => _isSlipUploadSubmitting = true);
                  final saved = await OKuploadFile_Slip();
                  if (!mounted) {
                    return false;
                  }
                  setSheetState(() => _isSlipUploadSubmitting = false);
                  if (!saved) {
                    final linkFailed = _slipSubmissionFailureStage == 'link';
                    final detail = _slipSubmissionFailureMessage?.trim();
                    final fallback = linkFailed
                        ? (isEn
                            ? 'Proof uploaded, but payment status was not updated. Please try again.'
                            : 'อัปโหลดหลักฐานแล้ว แต่ยังอัปเดตรายการชำระไม่สำเร็จ กรุณาลองใหม่อีกครั้ง')
                        : (isEn
                            ? 'Unable to upload proof. Please try again.'
                            : 'อัปโหลดหลักฐานไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(detail == null || detail.isEmpty
                            ? fallback
                            : '$fallback\n$detail'),
                      ),
                    );
                    return false;
                  }
                  if (Navigator.of(sheetContext).canPop()) {
                    Navigator.of(sheetContext).pop();
                  }
                  await sucress_awit();
                  return true;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showQr_again() {
    print('showQr_again');
    print(
        '${MyConstant().domain_chaoV2}/gen_qr_img.php?ren=$cid_ren&${widget.get_qr_img}&extension=.png');
    // List<String> result = widget.invoiceAll
    //     .toString()
    //     .split(',')
    //     .map((e) => e.replaceAll("'", "").trim())
    //     .toList();
    List<String> result = widget.invoiceAll
        .toString()
        .split(',')
        .map((e) => e.replaceAll("'", "").replaceAll('"', '').trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Container(
        child: Column(children: [
      // Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: Container(
      //     decoration: BoxDecoration(
      //       boxShadow: [
      //         BoxShadow(
      //             color: Colors.grey.withOpacity(0.5),
      //             spreadRadius: 2,
      //             blurRadius: 5,
      //             offset: const Offset(0, 0))
      //       ],
      //       borderRadius: BorderRadius.circular(20),
      //       color: Colors.white,
      //     ),
      //     padding: const EdgeInsets.all(2.0),
      //     child: Row(
      //       children: [
      //         Icon(
      //           Icons.history_toggle_off_outlined,
      //           color: Colors.orange[800],
      //           size: 25,
      //         ),
      //         Text(
      //           widget.cuslang == 'EN' ? 'Waiting to check.' : 'รอตรวจสอบ',
      //           maxLines: 1,
      //           overflow: TextOverflow.ellipsis,
      //           style: TextStyle(
      //             fontFamily: FitnessAppTheme.fontName,
      //             fontWeight: FontWeight.bold,
      //             fontSize: 15,
      //             letterSpacing: 0.2,
      //             color: Colors.orange[600],
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      Padding(
          padding: EdgeInsets.only(right: 8, left: 8, top: 4, bottom: 8),
          child: LayoutBuilder(builder: (context, constraints) {
            double width_x = MediaQuery.of(context).size.width * 0.87;
            double height_x = MediaQuery.of(context).size.height * 0.58;
            if (kIsWeb) {
              width_x = 300;
              height_x = 450;
              // เฉพาะบน Web/Desktop
              // if (constraints.maxWidth >= 1400) {
              //   width_x = 400;
              //   height_x = 300;
              // } else if (constraints.maxWidth >= 1000) {
              //   width_x = 400;
              //   height_x = 300;
              // } else if (constraints.maxWidth >= 800) {
              //   width_x = 400;
              //   height_x = 300;
              // } else if (constraints.maxWidth >= 400) {
              //   width_x = 400;
              //   height_x = 300;
              // }
            }
            // เช็คว่าหน้าจอกว้างพอที่จะเป็น 2 คอลัมน์ไหม
            final isWideScreen = constraints.maxWidth > 600;
            return Container(
              height: height_x,
              width: width_x,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 0))
                ],
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(children: [
                // if (payment_tser == '8')
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: RepaintBoundary(
                      key: qrImageKey,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color: Colors.white,
                          child: Stack(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: AppbackgroundColor.Sub_Abg_Colors,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                child: RepaintBoundary(
                                  key: _globalKey,
                                  child: Container(
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        '${MyConstant().domain_chaoV2}/gen_qr_img.php?ren=$cid_ren&${widget.get_qr_img}&extension=.png',
                                        fit: BoxFit.fill,
                                        cacheWidth: 400,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[300],
                                            alignment: Alignment.center,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(Icons
                                                      .image_not_supported),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    widget.cuslang == 'EN'
                                                        ? 'QR An error occurred. Please try again.'
                                                        : 'QR เกิดข้อผิดพลาดกรุณาลองใหม่อีกครั้ง',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          FitnessAppTheme
                                                              .fontName,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      letterSpacing: 0.2,
                                                      color: Colors.black45,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  // Container(
                                  //   height: MediaQuery.of(context).size.height,
                                  //   width: MediaQuery.of(context).size.width,
                                  //   decoration: BoxDecoration(
                                  //     image: DecorationImage(
                                  //         image: NetworkImage(
                                  //             '${MyConstant().domain_chaoV2}/gen_qr_img.php?ren=50&${widget.get_qr_img}&extension=.png'
                                  //             // '${MyConstant().domain_chao}/gen_qr_img.php?ren=$cid_ren&ref_id=$refpay&incid=$cid_docqr&sum=${double.parse(Form_payment1.text)}&extension=.png',
                                  //             ),
                                  //         fit: BoxFit.fill),
                                  //     borderRadius:
                                  //         BorderRadius.all(Radius.circular(8)),
                                  //   ),
                                  // ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Row(
                //     children: [
                //       // for (int indexx = 0; indexx < result.length; indexx++)
                //       Text(
                //         '${result.map((e) => "$e").join(' , ')}',
                //         maxLines: 5,
                //         overflow: TextOverflow.ellipsis,
                //         style: TextStyle(
                //           fontFamily: FitnessAppTheme.fontName,
                //           fontWeight: FontWeight.bold,
                //           fontSize: 14,
                //           letterSpacing: 0.2,
                //           color: Colors.orange[600],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ]),
            );
          })),
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0)),
            // border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Expanded(flex: 1, child: Container()),
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10, left: 10, bottom: 10),
                    child: Container(
                      width: 120,
                      padding: EdgeInsets.all(2),
                      child: Center(
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  // (maintenanceModels[int.parse('${row['index']}')]
                                  //             .mst
                                  //             .toString() ==
                                  //         '3')
                                  //     ? MaterialStateProperty.all<Color>(Colors.green)
                                  //     :
                                  MaterialStateProperty.all<Color>(
                                Colors.black,
                              ),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ))),
                          onPressed: (widget.get_img == null ||
                                  widget.get_img.toString() == '' ||
                                  widget.get_img.toString() == '[]')
                              ? _downloadQrCode
                              : () async {
                                  final cleanImg = widget.get_img
                                      .toString()
                                      .replaceAll('[', '')
                                      .replaceAll(']', '')
                                      .trim();

                                  print(
                                      '${MyConstant().domain_chao_img}/files/$foder/slip/${cleanImg}');
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0))),
                                      backgroundColor:
                                          AppbackgroundColor.Sub_Abg_Colors,
                                      titlePadding: const EdgeInsets.all(0.0),
                                      contentPadding:
                                          const EdgeInsets.all(10.0),
                                      actionsPadding: const EdgeInsets.all(6.0),
                                      title: Row(
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
                                      content: Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          Image.network(
                                              '${MyConstant().domain_chao_img}/files/$foder/slip/${cleanImg}')
                                        ],
                                      ),
                                    ),
                                  );
                                },
                          child: (widget.get_img == null ||
                                  widget.get_img.toString() == '' ||
                                  widget.get_img.toString() == '[]')
                              ? Text(
                                  widget.cuslang == 'EN'
                                      ? 'Save QR'
                                      : 'บันทึก QR',
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    letterSpacing: 0.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  widget.cuslang == 'EN'
                                      ? 'Evidence of payment.'
                                      : 'ดูหลักฐานการชำระ',
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    letterSpacing: 0.2,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  )),
              Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.only(right: 10, left: 10, bottom: 10),
                        child: Container(
                          width: 180,
                          padding: EdgeInsets.all(2),
                          child: Center(
                              child: OtpTimerButton(
                            height: 30,
                            text: Text(
                              (widget.ref_new.toString() == '1' &&
                                      base64_Slip == null)
                                  ? (base64_Slip == null)
                                      ? 'ยันยันการชำระ'
                                      : 'ยันยันการชำระ ✔️'
                                  : (widget.get_img == null ||
                                          widget.get_img.toString() == '' ||
                                          widget.get_img.toString() == '[]')
                                      ? widget.cuslang == 'EN'
                                          ? 'Confirm payment'
                                          : 'ยันยันการชำระ '
                                      : widget.cuslang == 'EN'
                                          ? 'Confirm payment'
                                          : 'แนบหลักฐานใหม่',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T,
                              ),
                            ),
                            duration: 4,
                            radius: 8,
                            backgroundColor:
                                (widget.ref_new.toString() == '1' &&
                                        base64_Slip == null)
                                    ? Colors.green.shade900
                                    : (widget.get_img == null ||
                                            widget.get_img.toString() == '' ||
                                            widget.get_img.toString() == '[]')
                                        ? Colors.green.shade900
                                        : Colors.black,
                            textColor: Colors.black,
                            buttonType: ButtonType.elevated_button,
                            loadingIndicator: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                            loadingIndicatorColor: Colors.red,
                            onPressed: () async {
                              PanaraInfoDialog.showAnimatedGrow(
                                context,
                                title: widget.cuslang == 'EN'
                                    ? 'Warning'
                                    : "คำเตือน",
                                message: widget.cuslang == 'EN'
                                    ? 'Please attach proof of payment that matches the date and time of the transaction in the system and is correct evidence (if there is an error, please contact the officer)'
                                    : "โปรดแนบหลักฐานการชำระ ให้ตรงกับวันเวลาที่ทำรายการในระบบและเป็นหลักฐานที่ถูกต้อง (หากเกิดข้อผิดพลากกรุณาติดต่อเจ้าหน้าที่)",
                                buttonText:
                                    widget.cuslang == 'EN' ? 'OK' : "รับทราบ",
                                onTapDismiss: () async {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pop();
                                  Future.delayed(
                                      const Duration(milliseconds: 300), () {
                                    uploadFile_Slip().then((saved) {
                                      if (saved) {
                                        sucress_awit();
                                      }
                                    });
                                  });
                                },
                                panaraDialogType: PanaraDialogType.warning,
                                barrierDismissible:
                                    false, // optional parameter (default is true)
                              );
                            },
                          )

                              //  ElevatedButton(
                              //     style: ButtonStyle(
                              //         // shadowColor: MaterialStateProperty.all(
                              //         //   HexColor('#FBF3D5')
                              //         //       .withOpacity(0.6), // ✅ ใช้แค่ Color
                              //         // ),
                              //         // elevation: MaterialStateProperty.all(
                              //         //     8), // ปรับความฟุ้งของเงา
                              //         backgroundColor:
                              //             // (maintenanceModels[int.parse('${row['index']}')]
                              //             //             .mst
                              //             //             .toString() ==
                              //             //         '3')
                              //             //     ? MaterialStateProperty.all<Color>(Colors.green)
                              //             //     :
                              //             MaterialStateProperty.all<Color>(
                              //           (widget.ref_new.toString() == '1' &&
                              //                   base64_Slip == null)
                              //               ? Colors.green.shade900
                              //               : (widget.get_img == null ||
                              //                       widget.get_img.toString() ==
                              //                           '' ||
                              //                       widget.get_img.toString() ==
                              //                           '[]')
                              //                   ? Colors.green.shade900
                              //                   : Colors.black,
                              //         ),
                              //         shape: MaterialStateProperty.all<
                              //                 RoundedRectangleBorder>(
                              //             RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.circular(10.0),
                              //         ))),
                              //     onPressed: () async {
                              //       PanaraInfoDialog.showAnimatedGrow(
                              //         context,
                              //         title: widget.cuslang == 'EN'
                              //             ? 'Warning'
                              //             : "คำเตือน",
                              //         message: widget.cuslang == 'EN'
                              //             ? 'Please attach proof of payment that matches the date and time of the transaction in the system and is correct evidence (if there is an error, please contact the officer)'
                              //             : "โปรดแนบหลักฐานการชำระ ให้ตรงกับวันเวลาที่ทำรายการในระบบและเป็นหลักฐานที่ถูกต้อง (หากเกิดข้อผิดพลากกรุณาติดต่อเจ้าหน้าที่)",
                              //         buttonText: widget.cuslang == 'EN'
                              //             ? 'OK'
                              //             : "รับทราบ",
                              //         onTapDismiss: () async {
                              //           Navigator.of(
                              //             context,
                              //             rootNavigator: true,
                              //           ).pop();
                              //           Future.delayed(
                              //               const Duration(milliseconds: 300),
                              //               () {
                              //             uploadFile_Slip().then((value) {
                              //               sucress_awit();
                              //             });
                              //           });
                              //         },
                              //         panaraDialogType: PanaraDialogType.warning,
                              //         barrierDismissible:
                              //             false, // optional parameter (default is true)
                              //       );
                              //     },
                              //     child: (widget.ref_new.toString() == '1' &&
                              //             base64_Slip == null)
                              //         ? Text(
                              //             widget.cuslang == 'EN'
                              //                 ? 'Confirm payment'
                              //                 : 'ยันยันการชำระ',
                              //             style: TextStyle(
                              //               fontFamily: FitnessAppTheme.fontName,
                              //               fontWeight: FontWeight.bold,
                              //               fontSize: 15,
                              //               letterSpacing: 0.2,
                              //               color: Colors.white,
                              //             ),
                              //           )
                              //         : (widget.get_img == null ||
                              //                 widget.get_img.toString() == '' ||
                              //                 widget.get_img.toString() == '[]')
                              //             ? Text(
                              //                 widget.cuslang == 'EN'
                              //                     ? 'Confirm payment'
                              //                     : 'ยันยันการชำระ ',
                              //                 style: TextStyle(
                              //                   fontFamily:
                              //                       FitnessAppTheme.fontName,
                              //                   fontWeight: FontWeight.bold,
                              //                   fontSize: 15,
                              //                   letterSpacing: 0.2,
                              //                   color: Colors.white,
                              //                 ),
                              //               )
                              //             : Text(
                              //                 widget.cuslang == 'EN'
                              //                     ? 'Confirm payment'
                              //                     : 'แนบหลักฐานใหม่',
                              //                 //'ยันยันการชำระ ✔️',
                              //                 style: TextStyle(
                              //                   fontFamily:
                              //                       FitnessAppTheme.fontName,
                              //                   fontWeight: FontWeight.bold,
                              //                   fontSize: 15,
                              //                   letterSpacing: 0.2,
                              //                   color: Colors.white,
                              //                 ),
                              //               )),
                              ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
      // (widget.get_img == null ||
      //         widget.get_img.toString() == '' ||
      //         widget.get_img.toString() == '[]')
      //     ? Container(
      //         padding: EdgeInsets.all(1),
      //         height: 10,
      //         decoration: BoxDecoration(
      //           color: Colors.grey.shade50,
      //           borderRadius: BorderRadius.only(
      //               topLeft: Radius.circular(0),
      //               topRight: Radius.circular(0),
      //               bottomLeft: Radius.circular(10),
      //               bottomRight: Radius.circular(10)),
      //           // border: Border.all(color: Colors.grey.shade100, width: 1),
      //         ),
      //       )
      //     : Padding(
      //         padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      //         child: Container(
      //           padding: EdgeInsets.all(1),
      //           decoration: BoxDecoration(
      //             color: Colors.grey.shade50,
      //             borderRadius: BorderRadius.only(
      //                 topLeft: Radius.circular(0),
      //                 topRight: Radius.circular(0),
      //                 bottomLeft: Radius.circular(10),
      //                 bottomRight: Radius.circular(10)),
      //             // border: Border.all(color: Colors.grey.shade100, width: 1),
      //           ),
      //           child: Padding(
      //             padding: const EdgeInsets.all(0.0),
      //             child: Row(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               mainAxisAlignment: MainAxisAlignment.end,
      //               children: [
      //                 InkWell(
      //                   onTap: () async {
      //                     final cleanImg = widget.get_img
      //                         .toString()
      //                         .replaceAll('[', '')
      //                         .replaceAll(']', '')
      //                         .trim();

      //                     print(
      //                         '${MyConstant().domain_chao_img}/files/$foder/slip/${cleanImg}');
      //                     showDialog(
      //                       context: context,
      //                       builder: (context) => AlertDialog(
      //                         shape: const RoundedRectangleBorder(
      //                             borderRadius:
      //                                 BorderRadius.all(Radius.circular(20.0))),
      //                         backgroundColor:
      //                             AppbackgroundColor.Sub_Abg_Colors,
      //                         titlePadding: const EdgeInsets.all(0.0),
      //                         contentPadding: const EdgeInsets.all(10.0),
      //                         actionsPadding: const EdgeInsets.all(6.0),
      //                         title: Row(
      //                           mainAxisAlignment: MainAxisAlignment.end,
      //                           children: [
      //                             InkWell(
      //                               onTap: () {
      //                                 Navigator.pop(context);
      //                               },
      //                               child: Padding(
      //                                 padding: const EdgeInsets.all(4.0),
      //                                 child: Icon(Icons.highlight_off,
      //                                     size: 30, color: Colors.red[700]),
      //                               ),
      //                             ),
      //                           ],
      //                         ),
      //                         content: Stack(
      //                           alignment: Alignment.center,
      //                           children: <Widget>[
      //                             Image.network(
      //                                 '${MyConstant().domain_chao_img}/files/$foder/slip/${cleanImg}')
      //                           ],
      //                         ),
      //                       ),
      //                     );
      //                   },
      //                   child: Text(
      //                     widget.cuslang == 'EN'
      //                         ? 'Evidence of payment.'
      //                         : 'หลักฐานการรับชำระ',
      //                     maxLines: 2,
      //                     overflow: TextOverflow.ellipsis,
      //                     style: TextStyle(
      //                       decoration: TextDecoration.underline,
      //                       fontFamily: FitnessAppTheme.fontName,
      //                       // fontWeight: FontWeight.bold,
      //                       fontSize: 12,
      //                       letterSpacing: 0.2,
      //                       color: Colors.blue[700],
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      SizedBox(
        height: 10,
      ),
      Container(
        // height: 200,
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 0))
          ],
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  widget.cuslang == 'EN'
                      ? 'History All ${result.length}   Bill'
                      : 'รายการทัังหมด ${result.length} บิล',
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.2,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  widget.cuslang == 'EN'
                      ? '#The amount shown is the net amount excluding fines.'
                      : '#ยอดที่แสดงเป็นยอดสุทธิ์ไม่รวมค่าปรับ',
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontSize: 12,
                    letterSpacing: 0.2,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            for (int indexx = 0; indexx < result.length; indexx++)
              Padding(
                padding: const EdgeInsets.all(1.0),
                child: Container(
                  height: 35,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    // color: Colors.green[100]!
                    //     .withOpacity(0.5),
                    border: const Border(
                      bottom: BorderSide(
                        color: Colors.black12,
                        width: 1,
                      ),
                    ),
                  ),
                  // decoration: BoxDecoration(
                  //   // boxShadow: <BoxShadow>[
                  //   //   BoxShadow(
                  //   //       color: HexColor('#537188').withOpacity(0.6),
                  //   //       offset: const Offset(1.1, 4.0),
                  //   //       blurRadius: 8.0),
                  //   // ],
                  //   // gradient: LinearGradient(
                  //   //   colors: <HexColor>[
                  //   //     // หมด : เช่าอยู่ : เสนอ

                  //   //     HexColor('#6B7AA1'),
                  //   //     HexColor('#354259'),
                  //   //   ],
                  //   //   begin: Alignment.topLeft,
                  //   //   end: Alignment.bottomRight,
                  //   // ),
                  //   borderRadius: const BorderRadius.only(
                  //     bottomRight: Radius.circular(8.0),
                  //     bottomLeft: Radius.circular(8.0),
                  //     topLeft: Radius.circular(8.0),
                  //     topRight: Radius.circular(54.0),
                  //   ),
                  // ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${indexx + 1}. ${result[indexx]}',
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                letterSpacing: 0.2,
                                color: FitnessAppTheme.darkerText,
                              ),
                            )),
                      ),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            (() {
                              final match =
                                  widget.totalinvoicePayModels?.firstWhere(
                                (e) =>
                                    e.docno.toString() ==
                                    result[indexx].toString(),
                                orElse: () => InvoiceModel(
                                    total_bill:
                                        ''), // ใส่ default หรือ empty model
                              );
                              // print(widget.totalinvoicePayModels);
                              // final amt = match!.disendbill.toString() == '0.00'
                              //     ? double.tryParse(match!.amtall ?? '0.00') ??
                              //         0.0
                              //     : double.tryParse(match!.amt ?? '0.00') ??
                              //         0.0;
                              // final total_bill =
                              //     double.tryParse(match!.total_bill ?? '0.00') ?? 0.0;
                              final total_bill = double.tryParse(
                                      match!.total_bill ?? '0.00') ??
                                  0.0;
                              final formatter = NumberFormat('#,##0.00');

                              // return (match!.date == null || match!.date == '')
                              //     ? ''
                              //     : 'กำหนดชำระ ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${match!.date}'))}';
                              return formatter.format(total_bill);
                            })(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              letterSpacing: 0.2,
                              color: FitnessAppTheme.grey,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      SizedBox(
        height: 60,
      )
    ]));
  }

  _saveNetworkImage(String imageUrl) async {
    var response = await Dio()
        .get(imageUrl, options: Options(responseType: ResponseType.bytes));
    await Gal.putImageBytes(Uint8List.fromList(response.data));
    final result = true;
    // final result = await ImageGallerySaver.saveImage(
    //     Uint8List.fromList(response.data),
    //     quality: 60,
    //     name: "hello");
    // print(result);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: Colors.black,
          content: Text('$result',
              style:
                  TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
    );
    // Utils.toast("$result");
  }

  // Future<void> downloadImage(String imageUrl) async {
  //   GallerySaver.saveImage(imageUrl);

  //   //  PickedFile?  image = await ImagePicker().getImage(source: ImageSource.gallery);

  //   //   if (image == null) {
  //   //     //  imagetemporary = File(image!.path);
  //   //    GallerySaver.saveImage(image!.path);
  //   //   }
  // }

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
      // await ImageGallerySaver.saveImage(image);
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
    String url =
        '${MyConstant().domain_chao}/In_tran_select_Chao_user.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user&shopno=$shopno&pos=$pos';
    try {
      var response = await http.get(Uri.parse(url));

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
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //       content: Text(
        //           'มีผู้ใช้อื่นกำลังทำรายการอยู่ หรือ ท่านเลือกรายการนี้แล้ว....',
        //           style: TextStyle(
        //               color: Colors.white, fontFamily: Font_.Fonts_T))),
        // );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //       content: Text(
      //           'มีผู้ใช้อื่นกำลังทำรายการอยู่ หรือ ท่านเลือกรายการนี้แล้ว....',
      //           style:
      //               TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
      // );
      // //print('rrrrrrrrrrrrrr $e');
    }
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

    String url =
        '${MyConstant().domain_chao}/D_tran_select_ser_User.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user';
    try {
      var response = await http.get(Uri.parse(url));

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

      String url =
          '${MyConstant().domain_chao}/GC_tran_select.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc';
      try {
        var response = await http.get(Uri.parse(url));

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

        String url =
            '${MyConstant().domain_chao}/GC_tran_select.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc';
        try {
          var response = await http.get(Uri.parse(url));

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

      String url =
          '${MyConstant().domain_chao}/GC_tran_select_fin.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc';

      try {
        var response = await http.get(Uri.parse(url));

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

        String url =
            '${MyConstant().domain_chao}/GC_tran_select_fin.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc';

        try {
          var response = await http.get(Uri.parse(url));

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
      // Form_payment1.text =
      //     (sum_amt - sum_disamt - dis_sum_Pakan).toStringAsFixed(2).toString();
    });
    // //print('sum_tran_fine>>>> $sum_tran_fine');
  }

  Future<String> in_Trans_invoice_genqr(_indocno) async {
    List newValuePDFimg = [];
    for (int index = 0; index < 1; index++) {
      if (renTalModels[0].imglogo!.trim() == '') {
        // newValuePDFimg.add(
        //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
      } else {
        newValuePDFimg.add(
            '${MyConstant().domain_chao_img}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
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

    print(
        '$invoicePay ..... $invoicePayfine ...... i $ciddoc i $paybywidget ii $io2 >>>>444>>>$io4>>>$tran_fine');

    String url =
        '${MyConstant().domain_chao}/In_tran_financet_User.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&sumdis=$sumdis&sumdisp=$sumdisp&dateY=$dateY&dateY1=$dateY1&time=$time&payment1=$payment1&payment2=$payment2&pSer1=$pSer1&pSer2=$pSer2&sum_whta=$sum_whta&bill=$bill&fileNameSlip=$fileName_Slip_&comment=$comment&dis_Pakan=$dis_akan&shopno=$shopno&pos=$pos&fine_total_amt=$fine_total_tt&tran_fine=$tran_fine&invoice=$io2&fin_in=$io4&ref=$refpay&payby=$payby&paybywidget=$paybywidget&user_bill=$user_bill';
    // print('Generated URL: $url');

    Map<String, dynamic> payload = {
      "isAdd": "true",
      "ren": ren,
      "ciddoc": ciddoc,
      "qutser": qutser,
      "user": user,
      "sumdis": sumdis,
      "sumdisp": sumdisp,
      "dateY": dateY,
      "dateY1": dateY1,
      "time": time,
      "payment1": payment1,
      "payment2": payment2,
      "pSer1": pSer1,
      "pSer2": pSer2,
      "sum_whta": sum_whta,
      "bill": bill,
      "fileNameSlip": fileName_Slip_,
      "comment": comment,
      "dis_Pakan": dis_akan,
      "shopno": shopno,
      "pos": pos,
      "fine_total_amt": fine_total_tt,
      "tran_fine": tran_fine,
      "invoice": _indocno,

      ///io2
      "fin_in": io4,
      "ref": refpay,
      "payby": payby,
      "paybywidget": paybywidget,
      "user_bill": user_bill,
    }; // แปลงเป็น JSON string และ print
    String jsonPayload = json.encode(payload);
    // print('Generated JSON Payload: $jsonPayload');
    print('Generated JSON Payload');
    return jsonPayload;
  }

  Future<Null> in_Trans_invoice(newValuePDFimg) async {
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

    // invoicePay = '';
    // invoicePayfine = '';
    // for (var i = 0; i < invoicePayModels.length; i++) {
    //   setState(() {
    //     invoicePay = invoicePay! + '${invoicePayModels[i].docno},';
    //     invoicePayfine = invoicePayfine! + '${invoicePayModels[i].fine},';
    //   });
    // }

    ////////////////------------------------------------------------------>
    // if (widget.teNantModel == null) {
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
    // //print('dis_akan()///$dis_akan');
    // //print(
    //     'in_Trans_invoice>>> $payment1  $payment2 $bill   ////   > $pSer1   //  $pSer2   ///----> $fileName_Slip_  ///> ${tableData00.length}');
    var pamentpage = 0;
    var Slip_status = 0;
    // String? discount_;In_tran_financet1_pay_Chaoperty_User
//  //print(invoicePay! + invoicePayfine!);
    // var io0 = invoicePayModels.length == 0
    //     ? ''
    //     : invoicePayModels.map((e) => e.docno).toString();
    // var io00 = invoicePayModels.length == 0
    //     ? ''
    //     : invoicePayModels.map((e) => e.fine).toString();
    // var io001 = io0.substring(1, io0.length - 1);
    // var io00001 = io00.substring(1, io00.length - 1);

    // //print('io001 $io001 >>>>io00001>>>$io00001');

    // //print('invoicePay $invoicePay >>>>invoicePayfine>>>$invoicePayfine');

    var io2 = invoicePay == null || invoicePay == ''
        ? '0'
        : invoicePay!.substring(0, invoicePay!.length - 1); // string
    var io4 = invoicePayfine == null || invoicePayfine == ''
        ? '0'
        : invoicePayfine!.substring(0, invoicePayfine!.length - 1); // string

    var payby = 'U';
    var paybywidget = '0'; // paybyselect == 'PAYCONTACT' ? '0' : custno;

    print(
        '$invoicePay ..... $invoicePayfine ...... i $ciddoc i $paybywidget ii $io2 >>>>444>>>$io4>>>$tran_fine');

    String url =
        '${MyConstant().domain_chao}/In_tran_financet_User.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&sumdis=$sumdis&sumdisp=$sumdisp&dateY=$dateY&dateY1=$dateY1&time=$time&payment1=$payment1&payment2=$payment2&pSer1=$pSer1&pSer2=$pSer2&sum_whta=$sum_whta&bill=$bill&fileNameSlip=$fileName_Slip_&comment=$comment&dis_Pakan=$dis_akan&shopno=$shopno&pos=$pos&fine_total_amt=$fine_total_tt&tran_fine=$tran_fine&invoice=$io2&fin_in=$io4&ref=$refpay&payby=$payby&paybywidget=$paybywidget&user_bill=$user_bill';
    print('$paybyselect url $url ');

    // String url =
    //     '${MyConstant().domain_chao}/In_tran_financet_User.php?isAdd=true';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(  check_userpaychoice_api
      //     ' fileName_Slip_///// $fileName_Slip_///pamentpage//$pamentpage//////////*------> ${result.toString()} ');
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
        // Navigator.pushAndRemoveUntil(context,
        //     MaterialPageRoute(builder: (context) {
        //   return FitnessAppHomeScreen(custno_s: custno);
        // }), (route) => false);
        // sucress().then((value) => Navigator.pushAndRemoveUntil(context,
        //         MaterialPageRoute(builder: (context) {
        //       return FitnessAppHomeScreen(custno_s: custno);
        //     }), (route) => false));

        // Insert_log.Insert_logs(
        //     'บัญชี',
        //     (Slip_status.toString() == '1')
        //         ? 'รับชำระ:$numinvoice '
        //         : 'รับชำระ:$cFinn ');
        // PdfgenReceipt.exportPDF_Receipt(
        //     tableData00,
        //     context,
        //     Slip_status,
        //     _TransModels,
        //     '${ciddoc_}',
        //     // '${widget.namenew}',
        //     '${sum_pvat}',
        //     '${sum_vat}',
        //     '${sum_wht}',
        //     '${sum_amt}',
        //     (discount_ == null) ? '0' : '${discount_} ',
        //     '${nFormat.format(sum_disamt)}',
        //     '${sum_amt - sum_disamt}',
        //     // '${nFormat.format(sum_amt - sum_disamt)}',
        //     // '${renTal_name.toString()}',
        //     '${Form_bussshop}',
        //     '${Form_address}',
        //     '${Form_tel}',
        //     '${Form_email}',
        //     '${Form_tax}',
        //     '${Form_nameshop}',
        //     '${renTalModels[0].bill_addr}',
        //     '${renTalModels[0].bill_email}',
        //     '${renTalModels[0].bill_tel}',
        //     '${renTalModels[0].bill_tax}',
        //     '${renTalModels[0].bill_name}',
        //     newValuePDFimg,
        //     pamentpage,
        //     paymentName1,
        //     paymentName2,
        //     Form_payment1.text,
        //     Form_payment2.text,
        //     cFinn,
        //     Value_newDateD);
      }
    } catch (e) {
      // //print('$e');
    }
    // } else {
    //   var custno = preferences.getString('custno');custno
    //   // for (var i = 0; i < widget.teNantModel!.length; i++) {
    //   //   var ciddoc_ = widget.teNantModel![i].cid;
    //   var ciddoc_ = preferences.getString('usercid');
    //   var ren = preferences.getString('renTalSer');
    //   var user = preferences.getString('ser');
    //   var ciddoc = ciddoc_;
    //   var qutser = 1;
    //   var sumdis = (sum_disamt + sum_disamt_in).toStringAsFixed(2).toString();
    //   var sumdisp = '0.00'.toString();
    //   var dateY = Value_newDateY;
    //   var dateY1 = Value_newDateY1;
    //   var time = '$hour:$minute:$second';
    //   var bill = bills_name_ == 'บิลธรรมดา' ? 'P' : 'F';
    //   var dis_akan = dis_sum_Pakan.toString();
    //   //pamentpage == 0
    //   var payment1 = Form_payment1.text.toString();
    //   var payment2 = Form_payment2.text.toString();
    //   var pSer1 = paymentSer1;
    //   var pSer2 = paymentSer2;
    //   var sum_whta = (sum_wht + sum_wht_in).toString();
    //   var comment = '';
    //   var shopno = '1';
    //   var pos = '1';
    //   var fine_total_tt = fine_total;
    //   var tran_fine = (sum_tran_fine + sum_tran_fine_in).toString();

    //   var pamentpage = 0;
    //   var Slip_status = 0;

    //   var io2 = invoicePay == null || invoicePay == ''
    //       ? ''
    //       : invoicePay!.substring(0, invoicePay!.length - 1); // string
    //   var io4 = invoicePayfine == null || invoicePayfine == ''
    //       ? ''
    //       : invoicePayfine!.substring(0, invoicePayfine!.length - 1); // string

    //   var payby = 'U';
    //   var paybywidget = custno;

    //   //print('iiii $io2 >>>>444>>>$tran_fine');

    //   String url =
    //       '${MyConstant().domain_chao}/In_tran_financet_User.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&sumdis=$sumdis&sumdisp=$sumdisp&dateY=$dateY&dateY1=$dateY1&time=$time&payment1=$payment1&payment2=$payment2&pSer1=$pSer1&pSer2=$pSer2&sum_whta=$sum_whta&bill=$bill&fileNameSlip=$fileName_Slip_&comment=$comment&dis_Pakan=$dis_akan&shopno=$shopno&pos=$pos&fine_total_amt=$fine_total_tt&tran_fine=$tran_fine&invoice=$io2&fin_in=$io4&ref=$refpay&payby=$payby&paybywidget=$paybywidget';
    //   //print('url $url ');

    //   // String url =
    //   //     '${MyConstant().domain_chao}/In_tran_financet_User.php?isAdd=true';
    //   try {
    //     var response = await http.get(Uri.parse(url));

    //     var result = json.decode(response.body);
    //     //print(
    //         ' fileName_Slip_///// $fileName_Slip_///pamentpage//$pamentpage//////////*------> ${result.toString()} ');
    //     if (result.toString() != 'No') {
    //       for (var map in result) {
    //         CFinnancetransModel cFinnancetransModel =
    //             CFinnancetransModel.fromJson(map);
    //         setState(() {
    //           cFinn = cFinnancetransModel.docno;
    //           listitem.clear();
    //           base64_Slip = null;
    //           fileName_Slip = null;
    //           extension_ = null;
    //           file_ = null;
    //           selectedValue = null;
    //         });
    //       }

    //       Insert_log.Insert_logs('ชำระ', ' $ciddoc ($cFinn)');
    //     }
    //   } catch (e) {}
    // }

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
      return FitnessAppHomeScreen(custno_s: custno);
    }), (route) => false);

    // sucress().then((value) => Navigator.pushAndRemoveUntil(context,
    //         MaterialPageRoute(builder: (context) {
    //       return FitnessAppHomeScreen(custno_s: custno);
    //     }), (route) => false));
    // }
  }

  Future<dynamic> sucress_awit() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              titlePadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Container(
                height: 80,
                width: 80,
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     image: AssetImage("thank.png"),
                //     fit: BoxFit.contain,
                //   ),
                //   color: Colors.white,
                // ),
                child: Icon(
                  Icons.history_toggle_off_outlined,
                  color: Colors.green,
                  size: 80,
                ),
              ),
              content: SingleChildScrollView(
                  child: ListBody(children: <Widget>[
                Center(
                  child: Text(
                    widget.cuslang == 'EN'
                        ? 'Thank you for your payment'
                        : "ขอบคุณสำหรับการชำระ",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: FontWeight_.Fonts_T,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.cuslang == 'EN'
                        ? 'The system will confirm your payment within 15 minutes to 3 business days..'
                        : "ระบบจะยืนยันการชำระภายใน 15 นาที ถึง 3 วันทำการ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: Font_.Fonts_T,
                    ),
                  ),
                ),
              ])),
              actions: [
                Center(
                  child: Container(
                    width: 230,
                    height: 50,
                    padding: EdgeInsets.all(2),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              // (maintenanceModels[int.parse('${row['index']}')]
                              //             .mst
                              //             .toString() ==
                              //         '3')
                              //     ? MaterialStateProperty.all<Color>(Colors.green)
                              //     :
                              MaterialStateProperty.all<Color>(
                            Colors.green.shade600,
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ))),
                      onPressed: () async {
                        ////////////////------------------------------------------------------>
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        var custno = preferences.getString('custno');
                        var qutser_ = preferences.getString('qutser');
                        Navigator.of(context).pop();
//                         Future.delayed(const Duration(milliseconds: 500), () {
// // Here you can write your code

//                           setState(() {
//                             // Here you can write your code for open new view
//                           });
//                         });
                        Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (context) {
                          return FitnessAppHomeScreen(custno_s: custno);
                        }), (route) => false);
                      },
                      child: Translate.TranslateAndSet_TextAutoSize(
                          'รับทราบ',
                          Colors.black,
                          TextAlign.center,
                          null,
                          FontWeight_.Fonts_T,
                          18,
                          25,
                          1),
                    ),
                  ),
                ),
              ],
            );
          });
        });
  }

  Future<dynamic> sucress() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                titlePadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                content: Container(
                  height: 300,
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.of(context).pop();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 150,
                          width: 250,
                          // decoration: BoxDecoration(
                          //   image: DecorationImage(
                          //     image: AssetImage("thank.png"),
                          //     fit: BoxFit.contain,
                          //   ),
                          //   color: Colors.white,
                          // ),
                          child: Icon(
                            Icons.history_toggle_off_outlined,
                            color: Colors.green,
                            size: 120,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.cuslang == 'EN'
                              ? 'Completed'
                              : "ดำเนินการเสร็จสิ้น",
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: FontWeight_.Fonts_T,
                          ),
                        ),
                        Text(
                          widget.cuslang == 'EN'
                              ? 'You can check your payment within 3 business days. Thank you.'
                              : "สามารถตรวจสอบการชำระภายใน 3 วันทำการ ขอบคุณครับ/ค่ะ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          });
        });
  }
  // Future<Null> in_Trans_invoice(newValuePDFimg) async {
  //   DateTime now = DateTime.now();
  //   int hour = now.hour;
  //   int minute = now.minute;
  //   int second = now.second;
  //   String? fileName_Slip_ = fileName_Slip.toString().trim();
  //   ////////////////------------------------------------------------------>
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ciddoc_ = preferences.getString('usercid');
  //   var qutser_ = preferences.getString('qutser');
  //   ////////////////------------------------------------------------------>
  //   var ren = preferences.getString('renTalSer');
  //   var user = preferences.getString('ser');
  //   var ciddoc = ciddoc_;
  //   var qutser = qutser_;
  //   var sumdis = sum_disamt.toString();
  //   var sumdisp = sum_disp.toString();
  //   var dateY = Value_newDateY;
  //   var dateY1 = Value_newDateY1;
  //   var time = '$hour:$minute:$second';
  //   var bill = bills_name_ == 'บิลธรรมดา' ? 'P' : 'F';
  //   //pamentpage == 0
  //   var payment1 = Form_payment1.text.toString();
  //   var payment2 = Form_payment2.text.toString();
  //   var pSer1 = paymentSer1;
  //   var pSer2 = paymentSer2;
  //   var sum_whta = sum_wht.toString();
  //   var comment = '';

  //   //print('in_Trans_invoice()///$fileName_Slip_');
  //   //print('in_Trans_invoice>>> $payment1 >> $payment2 >> $bill');
  //   //print('>>> $ciddoc >> $qutser///>>$dateY >>$dateY1 >> $time');
  //   //print('>>> $newValuePDFimg');
  //   var pamentpage = 0;
  //   String url = pamentpage == 0
  //       ? 'https://dzentric.com/chao_perty/chao_api/In_tran_financet1.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&sumdis=$sumdis&sumdisp=$sumdisp&dateY=$dateY&dateY1=$dateY1&time=$time&payment1=$payment1&payment2=$payment2&pSer1=$pSer1&pSer2=$pSer2&sum_whta=$sum_whta&bill=$bill&fileNameSlip=$fileName_Slip_&comment=$comment'
  //       : 'https://dzentric.com/chao_perty/chao_api/In_tran_financet2.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&sumdis=$sumdis&sumdisp=$sumdisp&dateY=$dateY&dateY1=$dateY1&time=$time&payment1=$payment1&payment2=$payment2&pSer1=$pSer1&pSer2=$pSer2&sum_whta=$sum_whta&bill=$bill&fileNameSlip=$fileName_Slip_&comment=$comment';
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     //print(
  //         ' fileName_Slip_///// $fileName_Slip_///pamentpage//$pamentpage//////////*------> $result ');
  //     if (result.toString() != 'No') {
  //       for (var map in result) {
  //         CFinnancetransModel cFinnancetransModel =
  //             CFinnancetransModel.fromJson(map);
  //         setState(() {
  //           cFinn = cFinnancetransModel.docno;
  //         });
  //         //print('in_Trans_invoice///zzzzasaaa123454>>>>  $cFinn');
  //         //print(
  //             'in_Trans_invoice///bnobnobnobno123454>>>>  ${cFinnancetransModel.bno}');
  //       }

  //       // Insert_log.Insert_logs(
  //       //     'บัญชี',
  //       //     (Slip_status.toString() == '1')
  //       //         ? 'รับชำระ:$numinvoice '
  //       //         : 'รับชำระ:$cFinn ');

  //       setState(() async {
  //         // await red_Trans_bill();
  //         // red_Trans_select2();

  //         Form_payment1.clear();
  //         Form_payment2.clear();

  //         bills_name_ = 'บิลธรรมดา';
  //         cFinn = null;

  //         base64_Slip = null;
  //       });
  //       //print('rrrrrrrrrrrrrr');
  //     }
  //   } catch (e) {}
  // }
}

class _SlideToConfirmBar extends StatefulWidget {
  const _SlideToConfirmBar({
    required this.label,
    required this.enabled,
    required this.onConfirmed,
  });

  final String label;
  final bool enabled;
  final Future<bool> Function() onConfirmed;

  @override
  State<_SlideToConfirmBar> createState() => _SlideToConfirmBarState();
}

class _SlideToConfirmBarState extends State<_SlideToConfirmBar> {
  static const double _height = 58.0;
  static const double _handleWidth = 50.0;
  static const double _pad = 4.0;

  double _position = 0.0;
  bool _confirmed = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDrag =
            (constraints.maxWidth - _handleWidth - _pad * 2).clamp(1.0, 1e6);
        final double pct = (_position / maxDrag).clamp(0.0, 1.0);
        final Color base =
            widget.enabled ? const Color(0xFF2563EB) : const Color(0xFF9AA7AE);
        final Color dark =
            widget.enabled ? const Color(0xFF1E40AF) : const Color(0xFF7C8A91);

        return Container(
          height: _height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.lerp(base, dark, pct)!, dark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(_height / 2),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: base.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Opacity(
                  opacity: (1.0 - pct * 2).clamp(0.0, 1.0),
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
                  ),
                ),
              ),
              if (!_confirmed)
                AnimatedPositioned(
                  duration: _isDragging
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  left: _pad + _position,
                  top: (_height - _handleWidth) / 2,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (!widget.enabled) {
                        return;
                      }
                      setState(() {
                        _isDragging = true;
                        _position =
                            (_position + details.delta.dx).clamp(0.0, maxDrag);
                      });
                    },
                    onHorizontalDragEnd: (_) async {
                      if (!widget.enabled) {
                        return;
                      }
                      if (_position >= maxDrag * 0.72) {
                        setState(() {
                          _isDragging = false;
                          _position = maxDrag;
                          _confirmed = true;
                        });
                        final confirmed = await widget.onConfirmed();
                        if (!confirmed && mounted) {
                          setState(() {
                            _position = 0;
                            _confirmed = false;
                          });
                        }
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
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: base,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              if (_confirmed)
                Positioned(
                  right: _pad,
                  top: (_height - _handleWidth) / 2,
                  child: Container(
                    width: _handleWidth,
                    height: _handleWidth,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: base,
                      size: 27,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
