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
import '../color.dart';
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

class PayBillscreen extends StatefulWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<TeNantModel>? teNantModel;
  final String? cuslang;
  PayBillscreen({
    Key? key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
    this.teNantModel,
    this.cuslang,
  }) : super(key: key);
  // Payscreen({Key? key, required this.item, required this.InvoiceHistoryModels})
  // : super(key: key);
  @override
  State<PayBillscreen> createState() => _PayBillscreenState();
}

class _PayBillscreenState extends State<PayBillscreen> {
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
  int tap = 0, select_pay = 0, gopay = 0, show_qr = 0;
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

  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  @override
  void initState() {
    super.initState();

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
              (value) {
                print('_InvoiceModels >>>>> ${widget.teNantModel!.length}');
                for (int indexx = 0; indexx < _InvoiceModels.length; indexx++) {
                  // if (contractxFineModels.isNotEmpty) {
                  //   // in_Trans_fine_re(indexx);
                  // } else {
                  //   Map<String, dynamic> mapi = Map();
                  //   mapi['ser'] = _InvoiceModels[indexx].ser;
                  //   mapi['docno'] = _InvoiceModels[indexx].docno;
                  //   mapi['amtall'] = _InvoiceModels[indexx].amtall;
                  //   mapi['fine'] = '0';
                  //   mapi['discount'] = _InvoiceModels[indexx].disendbill;
                  //   InvoicePayModel invoicePayModel =
                  //       InvoicePayModel.fromJson(mapi);
                  //   invoicePayModels.add(invoicePayModel);
                  // }
                  red_Trans_select(indexx);
                }
                // if (contractxFineModels.isNotEmpty) {
                in_Trans_fine_re();
              },
            ),
          ),
        ),
      );
    });
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

  Future<Null> Check_genref(_indocno, double amt) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    // print('up_ref_qr $refpay $refpayup $_indocno');
    // print('_InvoiceModels.length >>${_InvoiceModels.length}');
    if (_InvoiceModels.length == 1) {
      // print(
      //     '_InvoiceModels[0].refapi >>${_InvoiceModels[0].refapi}>>${_InvoiceModels[0].amt}>>${_InvoiceModels[0].amtall}');
      if (double.parse(_InvoiceModels[0].amtall!) == amt) {
        setState(() {
          refpay = _InvoiceModels[0].refapi.toString();
          refpayup = _InvoiceModels[0].refapi.toString();
        });
      } else {
        // setState(() {
        //   refpay = getRandomString(10);
        //   refpayup = getRandomString(10);
        // });
        String url =
            '${MyConstant().domain_chao}/check_genref_qr.php?isAdd=true&ren=$ren&ciddoc=$_indocno&amt=$amt';
        // print('up_ref_qr >>>> $url');
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
              refpay = getRandomString(10);
              refpayup = '';
            });
          }
        } catch (e) {}
      }
    } else {
      String url =
          '${MyConstant().domain_chao}/check_genref_qr.php?isAdd=true&ren=$ren&ciddoc=$_indocno&amt=$amt';
      // print('up_ref_qr >>>> $url');
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
            refpay = getRandomString(10);
            refpayup = '';
          });
        }
      } catch (e) {}
    }
  }

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

  Future<Null> chack_up_refino_new() async {
    var gen_url = await in_Trans_invoice_genqr();
    print(
        'res >>>>> $refpay >>>> $refpayup >>>  ${double.parse(Form_payment1.text)}');
    if (double.parse(Form_payment1.text) != 0) {
      var io2 = invoicePay == null || invoicePay == ''
          ? '0'
          : invoicePay!.substring(0, invoicePay!.length - 1);

      var url =
          "${MyConstant().domain_chao}/chack_qr_status.php?ren=$cid_ren&invoice=$io2&ref_id=$refpay&incid=$cid_docqr&sum=${double.parse(Form_payment1.text)}&extension=.png";
      //"https://chaoperties.com/Admin_Test/chao_api/chack_qr_status.php?ren=$cid_ren&invoice=$io2&ref_id=$refpay&incid=$cid_docqr&sum=${double.parse(Form_payment1.text)}&extension=.png";

      print(url);
      try {
        var response = await http.post(
          Uri.parse(url),
          body: {
            'get_gen_url': '$gen_url',
          },
        );

        var result = json.decode(response.body);
        // print('check_qr_status>> ${result.toString()}');

        if (result.toString() == 'error') {
          setState(() {
            refpay = getRandomString(10);
            refpayup = getRandomString(10);
          });
          print('error');
        } else if (result.toString() == 'success') {
          print('success');
        }
      } catch (e) {
        print('POST request error: $e');
      }
      // try {
      //   var response = await http.get(Uri.parse(url));
      //   var result = json.decode(response.body);
      //   // print('chack_qr_status>> ${result.toString()}');
      //   if (result.toString() == 'error') {
      //     setState(() {
      //       refpay = getRandomString(10);
      //       refpayup = getRandomString(10);
      //     });
      //     // up_refino(_InvoiceModels[0].docno);
      //     print('error');
      //   } else if (result.toString() == 'success') {
      //     // up_refino(_InvoiceModels[0].docno);
      //     print('success');
      //   }
      // } catch (e) {}
    }
  }

  Future<Null> up_refino(_indocno) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    print('up_ref_qr $refpay $refpayup $_indocno');
    String url =
        '${MyConstant().domain_chao}/up_ref_qr.php?isAdd=true&ren=$ren&ciddoc=$_indocno&refpay=$refpayup';
    print('up_ref_qr >>>> $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(result.toString());
      if (result.toString() == 'true') {}
    } catch (e) {}
  }

  Future<Null> red_Trans_select(index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = preferences.getString('usercid');
    var qutser = 1;
    var docnoin = _InvoiceModels[index].docno;
    // //print('docnoin>> $docnoin');
    String url =
        '${MyConstant().domain_chao}/GC_bill_invoice_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);

      if (result.toString() != 'null') {
        // //print('_InvoiceHistoryModel>>123');
        // setState(() {
        // _InvoiceHistoryModels.clear();
        // sum_pvat_in = 0;
        // sum_vat_in = 0;
        // sum_wht_in = 0;
        // sum_amt_in = 0;
        // sum_disamt_in = 0;
        // });

        for (var map in result) {
          InvoiceHistoryModel _InvoiceHistoryModel =
              InvoiceHistoryModel.fromJson(map);

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
            // sum_disamt_in = sum_disamt_in + sum_disamtx;

            // sum_pvat = sum_pvat + sum_pvatx;
            // sum_vat = sum_vat + sum_vatx;
            // sum_wht = sum_wht + sum_whtx;
            // sum_amt = sum_amt + sum_amtx;
            // sum_disamt = sum_disamt + sum_disamtx;
            // sum_disp = sum_dispx;
            // numinvoice = _InvoiceHistoryModel.docno;
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

    //print(
    // '_InvoiceHistoryModels>> ${_InvoiceHistoryModels.map((e) => e.docno)}');
  }

  Future<Null> in_Trans_fine_re() async {
    if (invoicePayModels.isNotEmpty) {
      setState(() {
        invoicePayModels.clear();
      });
    }
    for (int index = 0; index < _InvoiceModels.length; index++) {
      if (contractxFineModels.isNotEmpty) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        var ren = preferences.getString('renTalSer');
        var user = preferences.getString('ser');
        var ciddoc = preferences.getString('usercid');
        var qutser = 1;
        var tser = _InvoiceModels[index].ser;
        var tdocno = _InvoiceModels[index].docno;
        String url =
            '${MyConstant().domain_chao}/In_tran_select_fine_inv.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user';
        // print('ชำระเกินกำหนด ${_InvoiceModels[index].ser}');

        try {
          var response = await http.get(Uri.parse(url));
          var result = json.decode(response.body);
          var fine_inv = result.toString().indexOf(',');
          var fine_Name = result.toString().substring(0, fine_inv);
          var fine_pri = result.toString().substring(fine_inv + 1);
          // //print('ชำระเกินกำหนด ${fine_Name.toString()} $fine_pri');
          var sum_totalx = fine_pri == '' ? 0 : double.parse(fine_pri);
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

          setState(() {
            invoicePayModels.add(invoicePayModel);
            // sum_tran_fine_in = sum_tran_fine_in + sum_totalx;
            sum_tran_fine_in = sum_tran_fine_in + sum_totalx;
          });

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
        invoicePayModels.add(invoicePayModel);
      }
    }
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
    if (_InvoiceModels.length != 0) {
      setState(() {
        _InvoiceModels.clear();
        // invoicePayModels.clear();
        sum_disamt_in = 0;
        in_amt = 0;
      });
    }
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
          // _InvoiceModels.clear();
          for (var map in result) {
            InvoiceModel _InvoiceModel = InvoiceModel.fromJson(map);
            var in_amtx = double.parse(_InvoiceModel.amtall!);
            var in_docnox = _InvoiceModel.docno;
            var in_ser = _InvoiceModel.ser;
            var in_amtall = _InvoiceModel.amtall;
            var disendbill = double.parse(_InvoiceModel.disendbill!);
            // print('>>>_InvoiceModel>>>>> ${_InvoiceModel.refapi}');
            setState(() {
              sum_disamt_in = sum_disamt_in + disendbill;
              in_amt = in_amt + in_amtx;
              // invoicePayModels.add(invoicePayModel);
              _InvoiceModels.add(_InvoiceModel);
            });
          }
        }
      } catch (e) {}

      // //print(
      //     'setState >>>> ${(sum_pvat + sum_tran_fine - dis_sum_Pakan - (sum_disamt + sum_disamt_in) + (sum_pvat_in + sum_tran_fine_in) + (fine_total))}');
    } else {
      ////////////////------------------------------------------------------>
      for (var i = 0; i < widget.teNantModel!.length; i++) {
        var ciddoc_ = widget.teNantModel![i].cid;
        // //print(ciddoc_);
        String url =
            '${MyConstant().domain_chao}/GC_bill_invoice.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_';
        print(url);
        try {
          var response = await http.get(Uri.parse(url));

          var result = json.decode(response.body);

          if (result.toString() != 'null') {
            // sum_disamt_in = 0;
            // in_amt = 0;
            // _InvoiceModels.clear();
            for (var map in result) {
              InvoiceModel _InvoiceModel = InvoiceModel.fromJson(map);
              var in_amtx = double.parse(_InvoiceModel.amtall!);
              var in_docnox = _InvoiceModel.docno;
              var in_ser = _InvoiceModel.ser;
              var in_amtall = _InvoiceModel.amtall;
              var disendbill = double.parse(_InvoiceModel.disendbill!);

              setState(() {
                sum_disamt_in = sum_disamt_in + disendbill;
                in_amt = in_amt + in_amtx;
                // invoicePayModels.add(invoicePayModel);
                _InvoiceModels.add(_InvoiceModel);
              });
            }
            print('_InvoiceModels >> ${_InvoiceModels.length}');
          }
        } catch (e) {}
      }
    }
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

    // //print('name>>>>>  $renname');
  }

////////////////////////////////>
  String? base64_Slip, fileName_Slip;
  var extension_;
  var file_;
  Future<void> uploadFile_Slip() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 100, maxWidth: 100);

    if (pickedFile == null) {
      // //print('User canceled image selection');
      return;
    } else {
      // 2. Read the image as bytes
      final imageBytes = await pickedFile.readAsBytes();
      // Define the target width and height
      final int targetWidth = 100;
      final int targetHeight = 100;

      // Resize the image to the target width and height
      // final img.Image resizedImage = img.copyResize(
      //   img.decodeImage(imageBytes)!,
      //   width: targetWidth,
      //   height: targetHeight,
      // );
      // 3. Encode the resized image as a base64 string
      //  final base64Image = base64Encode(img.encodePng(resizedImage));

      // 3. Encode the image as a base64 string
      final base64Image = base64Encode(imageBytes);
      setState(() {
        base64_Slip = base64Image;
      });
      // //print(base64_Slip);
      setState(() {
        extension_ = 'png';
        // file_ = file;
      });
      // //print(extension_);
      // //print(extension_);
    }

    // OKuploadFile_Sliptest();
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
      final url =
          '${MyConstant().domain_chao}/File_uploadSlip_NewEdit.php?name=$fileName_Slip&Foder=$foder&extension=$extension_';

      final response = await http.post(
        Uri.parse(url),
        body: {
          'image': base64_Slip,
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

  Future<void> OKuploadFile_Sliptest() async {
    //print('User canceled image selection');
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
      fileName_Slip = 'slip_${ciddoc_}_${date}_$Time_.jpg';
    });
    try {
      final url =
          'http://192.168.1.23/thi_upload/snap/OPD_Upload_Img.php?name=$fileName_Slip&foder=$foder&extension=$extension_';

      final response = await http.post(
        Uri.parse(url),
        body: {
          'image': base64_Slip,
          'foder': 'snapshot/',
          'name': 'slip_${ciddoc_}_${date}_$Time_.jpg',
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
  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var datenow = DateFormat('yyyy-MM-dd').format(now);
    double amount = 0;
    listitem.forEach((element) {
      double total = double.parse(element['total']);
      amount = amount + total;
    });

    return AnimatedBuilder(
        animation: widget.mainScreenAnimationController!,
        builder: (BuildContext context, Widget? child) {
          return FadeTransition(
            opacity: widget.mainScreenAnimation!,
            child: Transform(
              transform: Matrix4.translationValues(
                  0.0, 30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                }),
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
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          top: 8.0,
                          right: 8.0,
                          bottom: 5.0,
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
                            for (var i = 0; i < invoicePayModels.length; i++) {
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
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: grey, style: BorderStyle.solid),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 8.0, right: 8.0, left: 8.0),
                                        child: Text(
                                          widget.cuslang == 'EN'
                                              ? 'Payment list'
                                              : 'รายการชำระ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontFamily: FontWeight_.Fonts_T,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: 8.0, left: 8.0),
                                        child: Text(
                                          widget.cuslang == 'EN'
                                              ? '${(_TransBillModels.length + _InvoiceModels.length)} list'
                                              : '${(_TransBillModels.length + _InvoiceModels.length)} รายการ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color.fromRGBO(
                                                100, 108, 110, 1),
                                            fontFamily: Font_.Fonts_T,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 8.0, right: 8.0, left: 8.0),
                                        child: Text(
                                          '${nFormat.format(sum_pvat + sum_tran_fine - dis_sum_Pakan - (sum_disamt + sum_disamt_in) + (sum_amt_in + sum_tran_fine_in) + (fine_total))}',
                                          // _TransModels.length != 0
                                          //     ? _InvoiceModels.length != 0
                                          //         ? '${nFormat.format((_TransModels.map((e) => double.parse(e.total.toString())).reduce((a, b) => a + b)) + (_InvoiceModels.map((e) => double.parse(e.amtall.toString())).reduce((a, b) => a + b)))}'
                                          //         : '${nFormat.format((_TransModels.map((e) => double.parse(e.total.toString())).reduce((a, b) => a + b)))}'
                                          //     : _InvoiceModels.length != 0
                                          //         ? '${nFormat.format((_InvoiceModels.map((e) => double.parse(e.amtall.toString())).reduce((a, b) => a + b)))}'
                                          //         : '0.00',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color.fromRGBO(
                                                100, 108, 110, 1),
                                            fontFamily: Font_.Fonts_T,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: 8.0, left: 8.0),
                                        child: Text(
                                          '',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color.fromRGBO(
                                                100, 108, 110, 1),
                                            fontFamily: Font_.Fonts_T,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 8.0, right: 8.0, left: 8.0),
                                        child: Text(
                                          tap == 0
                                              ? widget.cuslang == 'EN'
                                                  ? '>> Show details'
                                                  : '>> แสดงรายละเอียด'
                                              : widget.cuslang == 'EN'
                                                  ? '>> Show less'
                                                  : '>> แสดงน้อยลง',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color.fromRGBO(
                                                100, 108, 110, 1),
                                            fontFamily: Font_.Fonts_T,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
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
                                  padding: const EdgeInsets.all(8),
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
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
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
                                                  child: SingleChildScrollView(
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
                                                              style: TextStyle(
                                                                fontSize: 16,
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
                                                        _InvoiceModels.length ==
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
                                                                          ? 'Invoice list'
                                                                          : 'รายการวางบิล',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontFamily:
                                                                            FontWeight_.Fonts_T,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
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
                                                            child: ListTile(
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              title: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      '${(index_in + 1)}. ${_InvoiceModels[index_in].docno}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: _InvoiceModels[index_in].disendbill ==
                                                                            '0.00'
                                                                        ? Text(
                                                                            'ก่อนVAT : ${nFormat.format(double.parse(_InvoiceModels[index_in].amtall.toString()))}',
                                                                            textAlign:
                                                                                TextAlign.end,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 14,
                                                                              fontFamily: FontWeight_.Fonts_T,
                                                                            ),
                                                                          )
                                                                        : Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
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
                                                              subtitle: Column(
                                                                children: [
                                                                  Row(children: [
                                                                    Expanded(
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.only(right: 4.0),
                                                                        child: Text(widget.cuslang ==
                                                                                'EN'
                                                                            ? 'Payment due'
                                                                            : "กำหนดชำระ"),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      '( ${_InvoiceModels[index_in].descr} ) ${DateFormat('dd-MM').format(DateTime.parse('${_InvoiceModels[index_in].date}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_InvoiceModels[index_in].date}'))}') + 543}',
                                                                      style:
                                                                          const TextStyle(
                                                                        fontFamily:
                                                                            Font_.Fonts_T,
                                                                      ),
                                                                    )
                                                                  ]),
                                                                  if (invoicePayfine !=
                                                                      '')
                                                                    invoicePayfine!.substring(0, invoicePayfine!.length - 1).split(',')[index_in].trim() ==
                                                                            '0'
                                                                        ? SizedBox()
                                                                        : Row(
                                                                            children: [
                                                                                Expanded(
                                                                                  child: Text(
                                                                                    widget.cuslang == 'EN' ? 'Fines - Overdue' : 'ค่าปรับ - เกินกำหนดชำระ',
                                                                                    textAlign: TextAlign.start,
                                                                                    style: const TextStyle(fontSize: 12, color: Colors.red),
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  child: Text(
                                                                                    '${nFormat.format(double.parse(invoicePayfine!.substring(0, invoicePayfine!.length - 1).split(',')[index_in].toString()))}',
                                                                                    textAlign: TextAlign.end,
                                                                                    style: TextStyle(fontSize: 12, fontFamily: Font_.Fonts_T, color: Colors.red),
                                                                                  ),
                                                                                )
                                                                              ]),
                                                                ],
                                                              ),
                                                              trailing:
                                                                  IconButton(
                                                                onPressed:
                                                                    (1 == 1)
                                                                        ? null
                                                                        : () {
                                                                            if (invoicePayModels.elementAtOrNull(index_in)!.ser.toString() ==
                                                                                _InvoiceModels[index_in].ser) {
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
                                                                icon: Icon(
                                                                  invoicePayModels
                                                                              .elementAtOrNull(
                                                                                  index_in)!
                                                                              .ser
                                                                              .toString() ==
                                                                          _InvoiceModels[index_in]
                                                                              .ser
                                                                      ? Icons
                                                                          .check_circle_outline
                                                                      : Icons
                                                                          .highlight_off_outlined,
                                                                  color: invoicePayModels
                                                                              .elementAtOrNull(
                                                                                  index_in)!
                                                                              .ser
                                                                              .toString() ==
                                                                          _InvoiceModels[index_in]
                                                                              .ser
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .red,
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
                                                                          TextAlign
                                                                              .start,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontFamily:
                                                                            FontWeight_.Fonts_T,
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
                                                                    child: Text(
                                                                      '${(_InvoiceModels.length + (index + 1))}. ${_TransBillModels[index].expname}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      '${nFormat.format(double.parse(_TransBillModels[index].total.toString()))}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .end,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontFamily:
                                                                            FontWeight_.Fonts_T,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              subtitle: Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          right:
                                                                              4.0),
                                                                      child: Text(widget.cuslang ==
                                                                              'EN'
                                                                          ? 'Payment due'
                                                                          : "กำหนดชำระ"),
                                                                    ),
                                                                    Text(
                                                                      '${DateFormat('dd-MM').format(DateTime.parse('${_TransBillModels[index].date}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_TransBillModels[index].date}'))}') + 543}',
                                                                      style:
                                                                          const TextStyle(
                                                                        fontFamily:
                                                                            Font_.Fonts_T,
                                                                      ),
                                                                    )
                                                                  ]),
                                                              trailing:
                                                                  IconButton(
                                                                onPressed: () {
                                                                  if (_TransBillstring.elementAtOrNull(
                                                                              index)!
                                                                          .docno
                                                                          .toString() ==
                                                                      _TransBillModels[
                                                                              index]
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
                                                                          index +
                                                                              1,
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
                                                                          index +
                                                                              1,
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
                                                                  _TransBillstring.elementAtOrNull(index)!
                                                                              .docno
                                                                              .toString() ==
                                                                          _TransBillModels[index]
                                                                              .docno
                                                                      ? Icons
                                                                          .check_circle_outline
                                                                      : Icons
                                                                          .highlight_off_outlined,
                                                                  color: _TransBillstring.elementAtOrNull(
                                                                                  index)!
                                                                              .docno
                                                                              .toString() ==
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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: AutoSizeText(
                                      minFontSize: 6,
                                      maxFontSize: 16,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      widget.cuslang == 'EN'
                                          ? '( Transaction date : ${DateFormat.yMMMMd().format(DateTime.now())} )'
                                          : '( วันที่ทำรายการ : ${DateFormat.MMMMEEEEd('th').format(DateTime.now())} ${int.parse(DateFormat('yyyy').format(DateTime.now())) + 543})',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: Font_.Fonts_T
                                          //fontSize: 10.0
                                          //fontSize: 10.0
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
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
                                                fontFamily: Font_.Fonts_T),
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
                                                fontFamily: Font_.Fonts_T),
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
                                                ? 'Total service charge'
                                                : 'ยอดค่าบริการ',
                                            style: TextStyle(
                                                color: Colors.black,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
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
                                                fontFamily: Font_.Fonts_T),
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
                                          ? 'Total(Baht)'
                                          : 'รวม(บาท)',
                                      style: TextStyle(
                                          color: Colors.black,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: Font_.Fonts_T),
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
                                          fontFamily: Font_.Fonts_T),
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
                                          fontFamily: Font_.Fonts_T),
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
                                          fontFamily: Font_.Fonts_T),
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
                                          fontFamily: Font_.Fonts_T),
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
                                          fontFamily: Font_.Fonts_T),
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
                                          fontFamily: Font_.Fonts_T),
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
                                          fontFamily: Font_.Fonts_T),
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
                                          fontFamily: Font_.Fonts_T),
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
                                          fontFamily: Font_.Fonts_T),
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
                                                fontFamily: Font_.Fonts_T),
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
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ),
                                      ],
                                    ),
                              Divider(),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: AutoSizeText(
                                      minFontSize: 10,
                                      maxFontSize: 20,
                                      widget.cuslang == 'EN'
                                          ? 'Payment amount'
                                          : '# ยอดที่ต้องชำระชำระ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: AutoSizeText(
                                      minFontSize: 10,
                                      maxFontSize: 20,
                                      textAlign: TextAlign.end,
                                      '${nFormat.format(sum_pvat + sum_tran_fine - dis_sum_Pakan - (sum_disamt + sum_disamt_in) + (sum_amt_in + sum_tran_fine_in) + (fine_total))}',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              SizedBox(
                                height: 10,
                              ),
                              // _PayMentModels.length == 1
                              //     ? SizedBox()
                              //     :
                              Row(
                                children: [
                                  Expanded(
                                      child: _PayMentModels.length == 1
                                          ? SizedBox()
                                          : Text(
                                              paymentName1 == null
                                                  ? ''
                                                  : "$paymentName1",
                                              style: TextStyle(
                                                fontFamily: Font_.Fonts_T,
                                                // fontWeight: FontWeight.bold,
                                              ),
                                            )),
                                  Expanded(
                                    child: _PayMentModels.length == 1
                                        ? Container(
                                            width: 150,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                PanaraInfoDialog
                                                    .showAnimatedGrow(
                                                  context,
                                                  title: "คำเตือน",
                                                  message:
                                                      "หากชำระแล้วกรุณาอัพโหลดหลักฐานการโอนเงินและกดยืนยันการชำระ หากไม่อัพโหลดหลักฐานการโอนเงินจะถือว่าไม่มีการชำระเงิน ขอบคุณครับ/ค่ะ",
                                                  buttonText: "รับทราบ",
                                                  onTapDismiss: () async {
                                                    Navigator.of(
                                                      context,
                                                      rootNavigator: true,
                                                    ).pop();
                                                  },
                                                  panaraDialogType:
                                                      PanaraDialogType.error,
                                                  barrierDismissible:
                                                      false, // optional parameter (default is true)
                                                );
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
                                                  if (double.parse(Form_payment1
                                                              .text) !=
                                                          0.00 &&
                                                      double.parse(Form_payment1
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

                                                      var timrsta = DateTime
                                                              .now()
                                                          .millisecondsSinceEpoch;
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
                                                      if (_PayMentModels[0]
                                                              .ptser ==
                                                          '8') {
                                                        var _indocno =
                                                            _InvoiceModels[0]
                                                                .docno;
                                                        var amt = double.parse(
                                                            Form_payment1.text);
                                                        Check_genref(
                                                                _indocno, amt)
                                                            .then((value) =>
                                                                chack_up_refino_new());
                                                        // if (widget.teNantModel!
                                                        //         .length ==
                                                        //     1) {
                                                        //   var _indocno =
                                                        //       _InvoiceModels[0]
                                                        //           .docno;
                                                        //   var amt = double.parse(
                                                        //       Form_payment1.text);
                                                        //   Check_genref_inv1(
                                                        //           _indocno, amt)
                                                        //       .then((value) =>
                                                        //           chack_up_refino());

                                                        //   // setState(() {
                                                        //   //   refpay = _InvoiceModels[
                                                        //   //                   0]
                                                        //   //               .refapi !=
                                                        //   //           ''
                                                        //   //       ? _InvoiceModels[
                                                        //   //               0]
                                                        //   //           .refapi
                                                        //   //       : getRandomString(
                                                        //   //           10);
                                                        //   //   refpayup = _InvoiceModels[
                                                        //   //                   0]
                                                        //   //               .refapi !=
                                                        //   //           ''
                                                        //   //       ? _InvoiceModels[
                                                        //   //               0]
                                                        //   //           .refapi
                                                        //   //       : getRandomString(
                                                        //   //           10);
                                                        //   // });
                                                        //   // chack_up_refino();
                                                        // } else {
                                                        //   var _indocno =
                                                        //       _InvoiceModels[0]
                                                        //           .docno;
                                                        //   var amt = double.parse(
                                                        //       Form_payment1.text);
                                                        //   Check_genref(
                                                        //           _indocno, amt)
                                                        //       .then((value) =>
                                                        //           chack_up_refino_new());
                                                        //   // setState(() {
                                                        //   //   refpay =
                                                        //   //       getRandomString(
                                                        //   //           10);
                                                        //   //   refpayup = '';
                                                        //   // });
                                                        // }

                                                        // chack_up_refino();
                                                      } else {
                                                        if (widget
                                                                .teNantModel ==
                                                            null) {
                                                          refpay =
                                                              'WR$cid_doc${DateFormat('ddMM').format(datex)}${(datex.year + 543)}';
                                                        } else {
                                                          refpay =
                                                              'WR$cid_doc$timrsta';
                                                        }
                                                      }
                                                    });
                                                  } else {
                                                    PanaraInfoDialog
                                                        .showAnimatedGrow(
                                                      context,
                                                      title: "Oops",
                                                      message:
                                                          "ไม่มียอดชำระ !!!",
                                                      buttonText: "รับทราบ",
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
                                                    message:
                                                        "ไม่มีรายการค้างชำระ !!!",
                                                    buttonText: "รับทราบ",
                                                    onTapDismiss: () async {
                                                      Navigator.of(
                                                        context,
                                                        rootNavigator: true,
                                                      ).pop();
                                                    },
                                                    panaraDialogType:
                                                        PanaraDialogType.error,
                                                    barrierDismissible:
                                                        false, // optional parameter (default is true)
                                                  );
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
                                                            Color>(
                                                        Colors.green.shade900),
                                              ),
                                              child: AutoSizeText(
                                                minFontSize: 6,
                                                maxFontSize: 18,
                                                maxLines: 1,
                                                widget.cuslang == 'EN'
                                                    ? 'Payment Next'
                                                    : "ช่องทางการชำระ",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: Font_.Fonts_T
                                                    //fontSize: 10.0
                                                    //fontSize: 10.0
                                                    ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: 150,
                                            child: ElevatedButton(
                                              onPressed: () async {
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
                                                        ? Colors.green.shade900
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
                                                    fontFamily: Font_.Fonts_T
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
                                            fontFamily: Font_.Fonts_T,
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
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
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
                                                fontFamily: Font_.Fonts_T,
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
                                                              _PayMentModels[index]
                                                                  .fine_a!)
                                                          .toStringAsFixed(2)
                                                          .toString())
                                                      : double.parse((((sum_amt -
                                                                      sum_disamt -
                                                                      dis_sum_Pakan) *
                                                                  double.parse(
                                                                      _PayMentModels[index]
                                                                          .fine_c!)) /
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
                                                  refpay = getRandomString(10);
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

                                                Form_payment1.text = (sum_pvat +
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
                                                      _PayMentModels[index].ser
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
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade50,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10)),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade100,
                                                        width: 1),
                                                  ),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.85,
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              flex: 1,
                                                              child: Icon(Icons
                                                                  .info_outline)),
                                                          Expanded(
                                                              flex: 6,
                                                              child: Text(
                                                                "คำเตือน",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade700,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ))
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              flex: 1,
                                                              child:
                                                                  SizedBox()),
                                                          Expanded(
                                                              flex: 6,
                                                              child: Text(
                                                                "หากชำระแล้วกรุณาแนบหลักฐานการโอน ดำเนินการต่อขั้นตอนถัดไป",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade700,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                ),
                                                              ))
                                                        ],
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ),
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              widget.cuslang == 'EN'
                                                  ? 'Payment details'
                                                  : "รายละเอียดการชำระ",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            payment_tser == '7'
                                                ? SizedBox()
                                                : payment_tser == '2'
                                                    ? SizedBox()
                                                    : TextButton(
                                                        onPressed: () async {
                                                          RenderRepaintBoundary
                                                              boundary =
                                                              qrImageKey
                                                                      .currentContext!
                                                                      .findRenderObject()
                                                                  as RenderRepaintBoundary;
                                                          ui.Image image =
                                                              await boundary
                                                                  .toImage();
                                                          ByteData? byteData =
                                                              await image
                                                                  .toByteData(
                                                                      format: ui
                                                                          .ImageByteFormat
                                                                          .png);
                                                          Uint8List bytes =
                                                              byteData!.buffer
                                                                  .asUint8List();
                                                          html.Blob blob =
                                                              html.Blob(
                                                                  [bytes]);
                                                          String url = html.Url
                                                              .createObjectUrlFromBlob(
                                                                  blob);

                                                          html.AnchorElement
                                                              anchor =
                                                              html.AnchorElement()
                                                                ..href = url
                                                                ..setAttribute(
                                                                    'download',
                                                                    'qrcode.png')
                                                                ..click();
                                                          html.Url
                                                              .revokeObjectUrl(
                                                                  url);
                                                          // print(
                                                          //     '$_platformVersion');
                                                        },
                                                        child: Text(
                                                          "ดาวโหลด QR Code",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  FontWeight_
                                                                      .Fonts_T,
                                                              color:
                                                                  Colors.black),
                                                        )),
                                            // if (payment_tser == '2')
                                            payment_img == ''
                                                ? SizedBox()
                                                : Row(
                                                    children: [
                                                      TextButton(
                                                          onPressed: () async {
                                                            setState(() {
                                                              if (show_qr ==
                                                                  1) {
                                                                show_qr = 0;
                                                              } else {
                                                                show_qr = 1;
                                                              }
                                                            });
                                                          },
                                                          child: Text(
                                                            "แสดง QR Code",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    FontWeight_
                                                                        .Fonts_T,
                                                                color: Colors
                                                                    .black),
                                                          )),
                                                      // show_qr == 1
                                                      //     ? IconButton(
                                                      //         onPressed:
                                                      //             () async {
                                                      //           RenderRepaintBoundary
                                                      //               boundary =
                                                      //               qrImageKey
                                                      //                       .currentContext!
                                                      //                       .findRenderObject()
                                                      //                   as RenderRepaintBoundary;
                                                      //           ui.Image image =
                                                      //               await boundary
                                                      //                   .toImage();
                                                      //           ByteData?
                                                      //               byteData =
                                                      //               await image.toByteData(
                                                      //                   format: ui
                                                      //                       .ImageByteFormat
                                                      //                       .png);
                                                      //           Uint8List bytes =
                                                      //               byteData!
                                                      //                   .buffer
                                                      //                   .asUint8List();
                                                      //           html.Blob blob =
                                                      //               html.Blob(
                                                      //                   [bytes]);
                                                      //           String url = html
                                                      //                   .Url
                                                      //               .createObjectUrlFromBlob(
                                                      //                   blob);

                                                      //           html.AnchorElement
                                                      //               anchor =
                                                      //               html.AnchorElement()
                                                      //                 ..href = url
                                                      //                 ..setAttribute(
                                                      //                     'download',
                                                      //                     'qrcode.png')
                                                      //                 ..click();

                                                      //           html.Url
                                                      //               .revokeObjectUrl(
                                                      //                   url);
                                                      //         },
                                                      //         icon: Icon(Icons
                                                      //             .file_download))
                                                      //     : SizedBox()
                                                    ],
                                                  ),
                                            // Image.network(
                                            //     '${MyConstant().domain_chao}/files/$foder/payment/$payment_img',
                                            //     height:
                                            //         MediaQuery.of(context)
                                            //                 .size
                                            //                 .height *
                                            //             0.3,
                                            //   )
                                          ],
                                        ),
                                        Divider(),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Image.network(
                                                                                '${MyConstant().domain_chao}/files/$foder/payment/$payment_img',
                                                                                height: MediaQuery.of(context).size.height * 0.3,
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
                                                                  ? 'Account number22'
                                                                  : 'เลขบัญชี22',
                                                              style: TextStyle(
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
                                                                    color: grey,
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
                                                                  fontSize: 18,
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
                                                                onPressed: () {
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
                                                                          Toast
                                                                              .LENGTH_SHORT);
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
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        child: AutoSizeText(
                                                          minFontSize: 10,
                                                          maxFontSize: 15,
                                                          maxLines: 1,
                                                          widget.cuslang == 'EN'
                                                              ? 'Account name : $payment_bname'
                                                              : 'ชื่อบัญชี : $payment_bname',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  Font_.Fonts_T
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
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        child: Text(
                                                          widget.cuslang == 'EN'
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
                                                        MainAxisAlignment.start,
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
                                                                  fontSize: 18,
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
                                                            height:
                                                                MediaQuery.of(
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
                                                              child: InkWell(
                                                                onTap: () {
                                                                  print(
                                                                      '${MyConstant().domain_chao}/files/$foder/payment/$payment_img');
                                                                },
                                                                child: Text(
                                                                  "กรุณาอัพโหลดหลักฐานการโอนเงินและกดยืนยันการชำระ ขอบคุณครับ/ค่ะ",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
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
                                                                Text(
                                                                  widget.cuslang ==
                                                                          'EN'
                                                                      ? 'Account name : $payment_bname'
                                                                      : 'ชื่อบัญชี : $payment_bname',
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
                                                                      ? 'Warning: If the information is incorrect, please contact the staff. Please do not transfer money.'
                                                                      : 'คำเตือน : หากข้อมูลไม่ถูกต้อง กรุณาติดต่อเจ้าหน้าที่กรุณาอย่าโอนเงิน',
                                                                  maxLines: 2,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        12,
                                                                    // fontWeight:
                                                                    //     FontWeight
                                                                    //         .bold,
                                                                  ),
                                                                ),
                                                                // SizedBox(
                                                                //   height: 4,
                                                                // ),
                                                                Container(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.65,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.5,
                                                                  color: Colors
                                                                      .white,
                                                                  child: Column(
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
                                                                              MediaQuery.of(context).size.width * 0.5,
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
                                                                  height: 4,
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
                                                                  height: 5,
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
                                                              Container(
                                                                child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Container(
                                                                        height: MediaQuery.of(context).size.width *
                                                                            0.9,
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.8,
                                                                        color: Colors
                                                                            .white,
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            double.parse(Form_payment1.text) == 0.0
                                                                                ? SizedBox()
                                                                                : RepaintBoundary(
                                                                                    key: _globalKey,
                                                                                    child: Container(
                                                                                      height: MediaQuery.of(context).size.width * 0.9,
                                                                                      width: MediaQuery.of(context).size.width * 0.8,
                                                                                      decoration: BoxDecoration(
                                                                                        image: DecorationImage(
                                                                                          image: NetworkImage('${MyConstant().domain_chao}/gen_qr_img.php?ren=$cid_ren&ref_id=$refpay&incid=$cid_docqr&sum=${double.parse(Form_payment1.text)}&extension=.png'),
                                                                                        ),
                                                                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0)),
                                                                                      ),
                                                                                    )),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            20,
                                                                      ),
                                                                    ]),
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
                              : Padding(
                                  padding: EdgeInsets.only(
                                      right: 8, left: 8, top: 4, bottom: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                      // border: Border.all(color: Colors.grey, width: 1),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    color: Color.fromARGB(
                                                        255, 255, 250, 210),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10)),
                                                    border: Border.all(
                                                        color: Colors
                                                            .yellow.shade800,
                                                        width: 1),
                                                  ),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.85,
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              flex: 1,
                                                              child: Icon(Icons
                                                                  .info_outline)),
                                                          Expanded(
                                                              flex: 6,
                                                              child: Text(
                                                                "กรุณาดำเนินการให้เสร็จสมบูรณ์",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .yellow
                                                                        .shade800,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ))
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              flex: 1,
                                                              child:
                                                                  SizedBox()),
                                                          Expanded(
                                                              flex: 6,
                                                              child: Text(
                                                                "เรียนท่านลูกค้า",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .yellow
                                                                      .shade800,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                ),
                                                              ))
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              flex: 1,
                                                              child:
                                                                  SizedBox()),
                                                          Expanded(
                                                              flex: 6,
                                                              child: Text(
                                                                "เพื่อให้การชำระเงินของท่านเสร็จสมบูรณ์ กรุณาดำเนินการดังนี้:",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .yellow
                                                                      .shade800,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                ),
                                                              ))
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              flex: 1,
                                                              child:
                                                                  SizedBox()),
                                                          Expanded(
                                                              flex: 6,
                                                              child: Text(
                                                                " - แนบหลักฐานการโอนเงิน เช่นสลิปการโอน หรือ หน้าจอยืนยันการทำรายการ",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .yellow
                                                                      .shade800,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                ),
                                                              ))
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              flex: 1,
                                                              child:
                                                                  SizedBox()),
                                                          Expanded(
                                                              flex: 6,
                                                              child: Text(
                                                                " - ตรวจสอบให้แน่ใจว่าภาพที่แนบสามารถมองเห็นรายละเอียดได้ชัดเจน",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .yellow
                                                                      .shade800,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                ),
                                                              ))
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              flex: 1,
                                                              child:
                                                                  SizedBox()),
                                                          Expanded(
                                                              flex: 6,
                                                              child: Text(
                                                                " - หากไม่มีการแนบหลักฐาน ระบบจะถือว่าการชำระเงินยังไม่เสร็จสมบูรณ์",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .yellow
                                                                      .shade800,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                ),
                                                              ))
                                                        ],
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 5, right: 10, left: 10),
                                          child: Container(
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: Colors.white70,
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(0),
                                                    topRight:
                                                        Radius.circular(0),
                                                    bottomLeft:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(0)),
                                                border: Border.all(
                                                    color: Colors.white54,
                                                    width: 1),
                                              ),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                    " อัปโหลดหลักฐานการชำระเงิน",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ))
                                                ],
                                              )),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: 10, left: 10, bottom: 10),
                                          child: Container(
                                              padding: EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                              ),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85,
                                              child: GestureDetector(
                                                onTap: () {
                                                  uploadFile_Slip();
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    5),
                                                            topRight:
                                                                Radius.circular(
                                                                    5),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    5),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    5)),
                                                    border: Border.all(
                                                        color:
                                                            Colors.grey.shade50,
                                                        width: 1),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  child: base64_Slip == null
                                                      ? Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                    child: Icon(
                                                                  Icons
                                                                      .system_update_alt_outlined,
                                                                  size: 65,
                                                                  color: Colors
                                                                      .grey,
                                                                ))
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    "คลิกหรือกด เพื่อเลือกไฟล์",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .grey,
                                                                        fontFamily:
                                                                            Font_
                                                                                .Fonts_T,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    "รองรับไฟล์ภาพ JPG หรือ PNG",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    "ขนาดไฟล์สูงสุด: 10MB",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          8,
                                                                      color: Colors
                                                                          .grey,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        )
                                                      : Image.memory(
                                                          base64Decode(
                                                              base64_Slip
                                                                  .toString()),
                                                          // height: 200,
                                                          // fit: BoxFit.cover,
                                                        ),
                                                ),
                                              )),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 5,
                                              right: 10,
                                              left: 10,
                                              bottom: 10),
                                          child: Container(
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: Colors.white70,
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(0),
                                                    topRight:
                                                        Radius.circular(0),
                                                    bottomLeft:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(0)),
                                                border: Border.all(
                                                    color: Colors.white54,
                                                    width: 1),
                                              ),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: 60,
                                                      child: ElevatedButton(
                                                        onPressed: (base64_Slip ==
                                                                    null ||
                                                                selectedValue ==
                                                                    null)
                                                            ? () async {
                                                                // var io2 = invoicePay ==
                                                                //             null ||
                                                                //         invoicePay == ''
                                                                //     ? '0'
                                                                //     : invoicePay!.substring(
                                                                //         0,
                                                                //         invoicePay!
                                                                //                 .length -
                                                                //             1); // string
                                                                // var io4 = invoicePayfine ==
                                                                //             null ||
                                                                //         invoicePayfine ==
                                                                //             ''
                                                                //     ? '0'
                                                                //     : invoicePayfine!.substring(
                                                                //         0,
                                                                //         invoicePayfine!
                                                                //                 .length -
                                                                //             1); // string

                                                                // var payby = 'U';
                                                                // var paybywidget =
                                                                //     '0'; // paybyselect == 'PAYCONTACT' ? '0' : custno;

                                                                // print(
                                                                //     '$invoicePay ..... $invoicePayfine ...... i i $paybywidget ii $io2 >>>>444>>>$io4>>>');
                                                                PanaraInfoDialog
                                                                    .showAnimatedGrow(
                                                                  context,
                                                                  title: "Oops",
                                                                  message:
                                                                      "กรุณาอัพโหลดหลักฐานการชำระ !!!",
                                                                  buttonText:
                                                                      "รับทราบ",
                                                                  onTapDismiss:
                                                                      () async {
                                                                    Navigator
                                                                        .of(
                                                                      context,
                                                                      rootNavigator:
                                                                          true,
                                                                    ).pop();
                                                                  },
                                                                  panaraDialogType:
                                                                      PanaraDialogType
                                                                          .error,
                                                                  barrierDismissible:
                                                                      false, // optional parameter (default is true)
                                                                );
                                                              }
                                                            : () async {
                                                                List
                                                                    newValuePDFimg =
                                                                    [];
                                                                for (int index =
                                                                        0;
                                                                    index < 1;
                                                                    index++) {
                                                                  if (renTalModels[
                                                                              0]
                                                                          .imglogo!
                                                                          .trim() ==
                                                                      '') {
                                                                    // newValuePDFimg.add(
                                                                    //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
                                                                  } else {
                                                                    newValuePDFimg
                                                                        .add(
                                                                            '${MyConstant().domain_chao}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                                                                  }
                                                                }

                                                                try {
                                                                  sucress();
                                                                  OKuploadFile_Slip(
                                                                          newValuePDFimg)
                                                                      .then((value) =>
                                                                          in_Trans_invoice(
                                                                              newValuePDFimg));
                                                                } catch (e) {
                                                                  _showMyDialogPay_Error(
                                                                      'เกิดข้อผิดพลาด ตรวจสอบความถูกต้อง กรุณาลองอีกครั้ง!');
                                                                }
                                                              },
                                                        style: ButtonStyle(
                                                            shape: MaterialStateProperty.all<
                                                                    OutlinedBorder>(
                                                                RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10))),
                                                            // foregroundColor:
                                                            //     MaterialStateProperty.all<Color>(
                                                            //         Colors.black26),
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all<Color>(
                                                              (base64_Slip ==
                                                                          null ||
                                                                      selectedValue ==
                                                                          null)
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .green,
                                                            )),
                                                        child: Text(
                                                          widget.cuslang == 'EN'
                                                              ? 'Confirm payment'
                                                              : "ยืนยันการชำระ",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  FontWeight_
                                                                      .Fonts_T,
                                                              fontSize: 15),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                      SizedBox(
                        height: 200,
                      ),
                    ],
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
    try {
      await Gal.putImageBytes(Uint8List.fromList(response.data));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.black,
            content: Text('Saved to gallery',
                style:
                    TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error saving: $e',
                style:
                    TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
      );
    }
    // Utils.toast("Saved");
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

  Future<String> in_Trans_invoice_genqr() async {
    List newValuePDFimg = [];
    for (int index = 0; index < 1; index++) {
      if (renTalModels[0].imglogo!.trim() == '') {
        // newValuePDFimg.add(
        //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
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

    print(
        '$invoicePay ..... $invoicePayfine ...... i $ciddoc i $paybywidget ii $io2 >>>>444>>>$io4>>>$tran_fine');

    String url =
        '${MyConstant().domain_chao}/In_tran_financet_User.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&sumdis=$sumdis&sumdisp=$sumdisp&dateY=$dateY&dateY1=$dateY1&time=$time&payment1=$payment1&payment2=$payment2&pSer1=$pSer1&pSer2=$pSer2&sum_whta=$sum_whta&bill=$bill&fileNameSlip=$fileName_Slip_&comment=$comment&dis_Pakan=$dis_akan&shopno=$shopno&pos=$pos&fine_total_amt=$fine_total_tt&tran_fine=$tran_fine&invoice=$io2&fin_in=$io4&ref=$refpay&payby=$payby&paybywidget=$paybywidget&user_bill=$user_bill';
    print('Generated URL: $url');
    return url;
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

    // print(
    //     '$invoicePay ..... $invoicePayfine ...... i $ciddoc i $paybywidget ii $io2 >>>>444>>>$io4>>>$tran_fine');

    String url =
        '${MyConstant().domain_chao}/In_tran_financet_User.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&sumdis=$sumdis&sumdisp=$sumdisp&dateY=$dateY&dateY1=$dateY1&time=$time&payment1=$payment1&payment2=$payment2&pSer1=$pSer1&pSer2=$pSer2&sum_whta=$sum_whta&bill=$bill&fileNameSlip=$fileName_Slip_&comment=$comment&dis_Pakan=$dis_akan&shopno=$shopno&pos=$pos&fine_total_amt=$fine_total_tt&tran_fine=$tran_fine&invoice=$io2&fin_in=$io4&ref=$refpay&payby=$payby&paybywidget=$paybywidget&user_bill=$user_bill';
    // print('$paybyselect url $url ');

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
