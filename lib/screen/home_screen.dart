// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
// import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
// import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chaoperty_user/screen/pay_bill_Mainscreen_Choice.dart';
import 'package:chaoperty_user/screen/pay_bill_screen_Choice.dart';
import 'package:chaoperty_user/screen/pay_scan_bill_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:chaoperty_user/screen/mobile_scanner_page.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:x_message/x_message.dart';

import '../Constant/Myconstant.dart';
import '../Constant/session_service.dart';
import '../Model/GetContractx_Model.dart';
import '../Model/GetInvoice_Model.dart';
import '../Model/GetInvoice_history_Model.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTranBill_model.dart';
import '../Model/GetTrans_Model.dart';
import '../Model/Get_Image_pro_model.dart';
import '../Model/Get_Image_text_model.dart';
import '../Responsive/responsive.dart';
import '../color.dart';
// import '../main.dart';
import 'bill_history.dart';
// import 'box/contentbox.dart';
// import 'buttonnavbar.dart';
import 'home_select_cid.dart';
import 'loginscreen.dart';
import 'meter_screen.dart';
import 'provider/homeprovider.dart';
import 'provider/payhisprovider.dart';
import 'provider/payprovider.dart';
// import 'metercheck_screen.dart';
import 'package:http/http.dart' as http;
// import 'package:grouped_list/grouped_list.dart';
// import 'package:provider/provider.dart';
// import 'dart:io' show Platform;
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';
// import 'package:syncfusion_localizations/syncfusion_localizations.dart';

// import 'pay_Tran_screen.dart';
import 'pay_bill_Mainscreen.dart';
import 'pay_bill_screen.dart';
// import 'pay_screen.dart';
import 'status_screen.dart';

// enum Screen { home, personalinfo, rentalarea, payscreen, editaccount }
// void Amount(amount) {
//   double AAmount = amount;
// }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageStorageBucket bucket = PageStorageBucket();

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
      imgl,
      cid_doc,
      _barcode;
  List<RenTalModel> renTalModels = [];
  List<ImageTextModel> imgList = [];
  List<String> textList = [];
  List<Widget> imageSliders = [];
  String? Ser_PAy;
  bool check_box = false;
  late List<List<dynamic>> check_box_list;
  var nFormat = NumberFormat("#,##0.00", "en_US");
  List<TransBillModel> _TransBillModels = [];
  List<InvoiceModel> _InvoiceModels = [];
  List<InvoiceHistoryModel> _InvoiceHistoryModels = [];
  List<TransModel> _TransModels = [];
  // List<PayMentModel> _PayMentModels = [];
  List<ContractxModel> _ContractxModels = [];
  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_disamt = 0.00,
      sum_disp = 0,
      in_amt = 0,
      amount = 0;
  String? numinvoice, renTal_name;
  String? Ser_re,
      renTal_user,
      ren_name,
      Value_cid,
      custno_,
      cus_ser,
      cus_cname,
      cus_sname,
      cus_email,
      cus_photo,
      cus_address,
      cus_contact,
      cus_stype,
      cus_tel,
      cus_tax,
      cus_imglogo_,
      cus_foder,
      cus_username,
      cus_password,
      cus_lintid,
      cus_lncode,
      cus_zn,
      imgbag_;
  int select_page = 0;

  @override
  void initState() {
    super.initState();
    // red_Trans_bill();

    deall_Trans_select();
    red_Invoice();
    red_payMent();
    read_GC_rental();
    checkPreferance();
    red_exp_wherser();
    read_GC_imagepro().then((value) {
      for (var i = 0; i < imgList.length; i++) {
        Widget imageSlider = Container(
          child: Container(
            margin: const EdgeInsets.all(2.0),
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        //////print(imgList[i].url.toString());
                        if (imgList[i].url.toString() != '' &&
                            imgList[i].url != null &&
                            imgList[i].url.toString() != 'null') {
                          Uri url = Uri.parse(imgList[i].url.toString());
                          if (!await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          )) {
                            throw Exception('Could not launch $url');
                          }
                        }
                      },
                      child: Image.network(imgList[i].image.toString(),
                          fit: BoxFit.cover,
                          width: 1500.0,
                          cacheWidth: 480),
                    ),
                  ],
                )),
          ),
        );
        setState(() {
          imageSliders.add(imageSlider);
        });
      }
    });
  }

  Future<Null> red_exp_wherser() async {
    if (_ContractxModels.length != 0) {
      setState(() {
        _ContractxModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = preferences.getString('usercid');
    var qutser = 1;

    String url =
        '${MyConstant().domain_chao}/GC_exp_wherser.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      //////print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          ContractxModel _ContractxModel = ContractxModel.fromJson(map);
          setState(() {
            _ContractxModels.add(_ContractxModel);
          });
        }
      } else {
        setState(() {
          _ContractxModels.clear();
        });
      }
    } catch (e) {}
  }

  Future<Null> read_GC_imagepro() async {
    if (imageSliders.isNotEmpty) {
      imageSliders.clear();
      imgList.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String new_Url = MyConstant().domain_chao;
    //  '${Uri.base.toString().substring(0, Uri.base.toString().length - 8)}/chao_api';
    String url = '${MyConstant().domain}/GC_img_pro.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      // //////print(result);
      if (result != null) {
        for (var map in result) {
          ImageProModel imageProModel = ImageProModel.fromJson(map);

          setState(() {
            if (imageProModel.type == 'IM') {
              var foderx = '$new_Url/${imageProModel.imgName.toString()}';
              var urlx = imageProModel.url;
              Map<String, dynamic> map = Map();
              map['image'] = foderx;
              map['url'] = urlx;

              ImageTextModel imageTextModel = ImageTextModel.fromJson(map);

              imgList.add(imageTextModel);
            } else {
              var foderx = imageProModel.textPro.toString();
              textList.add(foderx);
            }
          });
        }
      } else {}
    } catch (e) {}
  }

  Future<Null> checkPreferance() async {
    DateTime currentDate = DateTime.now();

    String new_Url = MyConstant().domain_chao;
    //   '${Uri.base.toString().substring(0, Uri.base.toString().length - 8)}/chao_api';
    // Format the date as 'YYYY-MM-DD'
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? DateLogin;
    setState(() {
      Ser_re = preferences.getString('renTalSer');
      renTal_user = preferences.getString('renTalSer');
      ren_name = preferences.getString('renTalName');
      custno_ = preferences.getString('custno');
      DateLogin = preferences.getString('Date_Login');
      cus_ser = preferences.getString('ser');
      cus_cname = preferences.getString('cname');
      cus_sname = preferences.getString('sname');
      cus_email = preferences.getString('email');
      cus_photo = preferences.getString('photo');
      cus_address = preferences.getString('address');
      cus_contact = preferences.getString('contact');
      cus_stype = preferences.getString('stype');
      cus_tel = preferences.getString('tel');
      cus_tax = preferences.getString('tax');
      cus_foder = preferences.getString('foder');
      cus_username = preferences.getString('UsernameUSer');
      cus_password = preferences.getString('pass_word');
      cus_lintid = preferences.getString('lintid');
      cus_lncode = preferences.getString('lncode');
      cus_zn = preferences.getString('zn');
    });
    if (cus_photo != null ||
        cus_photo.toString() != '' ||
        cus_photo.toString() != 'null') {
      cus_imglogo_ = '$new_Url/files/$cus_foder/contract/$cus_photo';
    }

    //////print('ser user >>>>>>>>>> ${preferences.getString('ser')}');
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
/////////////////////////--------------------------->ลบรายการที่จะชำระที่เลือกไว้ในฐานออกก่อน
  Future<Null> deall_Trans_select() async {
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ciddoc_ = preferences.getString('usercid');
    var qutser_ = preferences.getString('qutser');
    var Message_ = preferences.getString('Message_ToUser');
    setState(() {
      cid_doc = ciddoc_;
      renTal_name = preferences.getString('renTalName');
    });
    ////////////////------------------------------------------------------>
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = ciddoc_;
    var qutser = qutser_;

    String url =
        '${MyConstant().domain_chao}/D_tran_select.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //////print(result);
      if (result.toString() == 'true') {
        setState(() {
          red_Trans_select2();
        });
        // //////print('rrrrrrrrrrrrrr');
      } else if (result.toString() == 'false') {
        setState(() {
          red_Trans_select2();
        });
        // //////print('rrrrrrrrrrrrrrfalse');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('มีผู้ใช้อื่นกำลังทำรายการอยู่....',
                  style: TextStyle(
                    color: Colors.white,
                  ))),
        );
      }
    } catch (e) {
      // //////print('rrrrrrrrrrrrrr $e');
    }
    // checkNews(context, Message_);
  }

  ////////////////////-------------------------->
  Future<Null> read_GC_rental() async {
    if (renTalModels.isNotEmpty) {
      renTalModels.clear();
    }

    // dynamic Url_ = 'https://chaoperties.com/user/#/';
    // // String new_Url =
    // //     '${Url_.toString().substring(0, Url_.toString().length - 3)}/chao_api';
    // String new_Url =
    //     '${Uri.base.toString().substring(0, Uri.base.toString().length - 8)}/chao_api';
    // String new_Url2 =
    //     '${Uri.base.toString().substring(0, Uri.base.toString().length - 8)}';

    dynamic Url_ = 'https://chaoperties.com/user/#/';
    String new_Url =
        MyConstant().domain_chao; // 'https://chaoperties.com/chao_api';
    String new_Url2 = MyConstant().domain_chao_img; //'https://chaoperties.com';

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    //https://dzentric.com/chao_perty/chao_api/GC_rental_setring.php?isAdd=true&ren=50
    String url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
    //renTal_name = preferences.getString('renTalName');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //////print(result);
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
            imgl = renTalModel.imglogo;
            imglogo_ =
                '$new_Url/files/$foder/logo/${renTalModel.imglogo!.trim()}';
            imgbag_ = '$new_Url2/files/LOGO-removebg-preview.png';
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

    //////print('imglogo_>>>>>  $imglogo_');
  }

/////////////---------------->
  Future<Null> red_payMent() async {
    setState(() {
      Ser_PAy = null;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_payMent.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //////print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          PayMentModel _PayMentModel = PayMentModel.fromJson(map);

          if (_PayMentModel.ser_payweb.toString() == '1') {
            Ser_PAy = '1';
          }
          // setState(() {

          //   _PayMentModels.add(_PayMentModel);
          // });
        }
      }
    } catch (e) {}
  }

//////////////----------------------------------------->
  Future<Null> red_Invoice() async {
    if (_InvoiceModels.length != 0) {
      setState(() {
        _InvoiceModels.clear();
      });
    }
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc_ = preferences.getString('usercid');
    var qutser_ = preferences.getString('qutser');
    ////////////////------------------------------------------------------>
    var now = DateTime.now();
    var datenow = DateFormat('yyyy-MM-dd').format(now);

    String url =
        '${MyConstant().domain_chao}/GC_bill_invoice.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);

      if (result.toString() != 'null') {
        in_amt = 0;
        daytotal = 0;
        for (var map in result) {
          InvoiceModel _InvoiceModel = InvoiceModel.fromJson(map);
          var in_amtx = double.parse(_InvoiceModel.amtall!);
          var disendbill = double.parse(_InvoiceModel.disendbill!);
          //////print('in_amtx...$in_amtx');
          setState(() {
            in_amt = in_amt + in_amtx + disendbill;
            _InvoiceModels.add(_InvoiceModel);

            if (datenow == _InvoiceModel.date) {
              daytotal = daytotal + in_amtx + disendbill;
            }
          });
        }
      }
    } catch (e) {}
    //////print('pppp...$in_amt');
  }

///////////---------------------------------->
  Future<Null> in_Trans_select(index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('user');
    var ciddoc = preferences.getString('ciddoc');
    var qutser = preferences.getString('qutser');

    var tser = _TransBillModels[index].ser;
    var tdocno = _TransBillModels[index].docno;

    // //////print(' object5555555objectobjectobject $tdocno');
    String url =
        '${MyConstant().domain}/In_tran_select.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //////print('rr>>>>>> $result');
      if (result.toString() == 'true') {
        setState(() {
          red_Trans_select2();
        });
        // //////print('rrrrrrrrrrrrrr');
      } else if (result.toString() == 'false') {
        setState(() {
          red_Trans_select2();
        });
        // //////print('rrrrrrrrrrrrrrfalse');
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
      // //////print('rrrrrrrrrrrrrr $e');
    }
  }

  Future<Null> red_Trans_select2() async {
    //  'รวม(บาท)',
    //    '${nFormat.format(sum_pvat)}',
    //         'ภาษีมูลค่าเพิ่ม(vat)',
    //                                                   '${nFormat.format(sum_vat)}',
    //                                            'หัก ณ ที่จ่าย',
    //                                                   '${nFormat.format(sum_wht)}',
    //                                                      'ยอดรวม',
    //                                                   '${nFormat.format(sum_amt)}',
    if (_TransModels.isNotEmpty) {
      setState(() {
        _TransModels.clear();
        sum_pvat = 0;
        sum_vat = 0;
        sum_wht = 0;
        sum_amt = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('user');
    var ciddoc = preferences.getString('ciddoc');
    var qutser = preferences.getString('qutser');

    String url =
        '${MyConstant().domain}/GC_tran_select.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //////print(result);
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

      // setState(() {
      //   Form_payment1.text = (sum_amt - sum_disamt).toStringAsFixed(2).toString();
      // });
    } catch (e) {}
  }

  ////////////////--------------------------------------->

  Future<Null> red_Trans_bill() async {
    if (_TransBillModels.length != 0) {
      setState(() {
        _TransBillModels.clear();
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('user');
    var ciddoc = preferences.getString('usercid');
    var qutser = preferences.getString('qutser');
    // var ren = 65;
    // var ciddoc = 'LE000063';
    // var qutser = '';

    String url =
        '${MyConstant().domain}/GC_tran_pays.php?isAdd=true&ren=$ren&ciddoc=$ciddoc';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //////print(result);
      if (result.toString() != 'null') {
        setState(() {
          _TransBillModels.clear();
        });
        for (var map in result) {
          TransBillModel _TransBillModel = TransBillModel.fromJson(map);
          var menu =
              double.parse(_TransBillModel.total.toString()).toStringAsFixed(2);
          // //////print('menumenumenu>>>>>>>>>$menu');
          // //////print(result);
          setState(() {
            // _TransBillModels.add(_TransBillModel);
            if (_TransBillModel.invoice == null) {
              if (menu != '0.00') {
                _TransBillModels.add(_TransBillModel);
                amount = amount + double.parse(menu);
                var now = DateTime.now();
                var datenow = DateFormat('yyyy-MM-dd').format(now);
                if (datenow == _TransBillModel.date) {
                  daytotal_t = daytotal_t + double.parse(menu);
                }
              }
            }
            // _TransBillModels.add(_TransBillModel);
          });
        }
        for (var index = 0; index < _TransBillModels.length; index++) {
          List<String> month = [
            "มกราคม",
            "กุมภาพันธ์",
            "มีนาคม",
            "เมษายน",
            "พฤษภาคม",
            "มิถุนายน",
            "กรกฎาคม",
            "สิงหาคม",
            "กันยายน",
            "ตุลาคม",
            "พฤศจิกายน",
            "ธันวาคม"
          ];
          var dt = _TransBillModels[index].date;
          //ตำแหน่งเดือน ตัวที่ 5-6
          int dt1 = int.parse(dt![5] + dt[6]);
          int dat = dt1 - 1;
          listitem.add({
            'ser': "${_TransBillModels[index].ser}",
            'date': "${_TransBillModels[index].date}",
            'expname': "${_TransBillModels[index].expname}",
            'month': "${month[dat]}",
            'total': "${_TransBillModels[index].total}",
            'docno': "${_TransBillModels[index].docno}",
            'value': true,
          });
        }
      }
    } catch (e) {}
  }

  Future<Null> red_Trans_select(index) async {
    if (_InvoiceHistoryModels.length != 0) {
      setState(() {
        _InvoiceHistoryModels.clear();
        sum_pvat = 0;
        sum_vat = 0;
        sum_wht = 0;
        sum_amt = 0;
        sum_disamt = 0;
        sum_disp = 0;
      });
    }
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc_ = preferences.getString('usercid');
    var qutser_ = preferences.getString('qutser');
    ////////////////------------------------------------------------------>

    var user = preferences.getString('ser');

    var docnoin = _InvoiceModels[index].docno;

    String url =
        '${MyConstant().domain_chao}/GC_bill_invoice_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc_&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //////print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceHistoryModel _InvoiceHistoryModel =
              InvoiceHistoryModel.fromJson(map);

          var sum_pvatx = double.parse(_InvoiceHistoryModel.pvat_t!);
          var sum_vatx = double.parse(_InvoiceHistoryModel.vat_t!);
          var sum_whtx = double.parse(_InvoiceHistoryModel.wht!);
          var sum_amtx = double.parse(_InvoiceHistoryModel.total_t!);
          var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          setState(() {
            sum_pvat = sum_pvat + sum_pvatx;
            sum_vat = sum_vat + sum_vatx;
            sum_wht = sum_wht + sum_whtx;
            sum_amt = sum_amt + sum_amtx;
            sum_disamt = sum_disamtx;
            sum_disp = sum_dispx;
            numinvoice = _InvoiceHistoryModel.docno;
            _InvoiceHistoryModels.add(_InvoiceHistoryModel);
          });
        }
      } else if (result.toString() == 'false') {
        for (var map in result) {
          InvoiceHistoryModel _InvoiceHistoryModel =
              InvoiceHistoryModel.fromJson(map);

          var sum_pvatx = double.parse(_InvoiceHistoryModel.pvat_t!);
          var sum_vatx = double.parse(_InvoiceHistoryModel.vat_t!);
          var sum_whtx = double.parse(_InvoiceHistoryModel.wht!);
          var sum_amtx = double.parse(_InvoiceHistoryModel.total_t!);
          var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          setState(() {
            sum_pvat = sum_pvat + sum_pvatx;
            sum_vat = sum_vat + sum_vatx;
            sum_wht = sum_wht + sum_whtx;
            sum_amt = sum_amt + sum_amtx;
            sum_disamt = sum_disamtx;
            sum_disp = sum_dispx;
            numinvoice = _InvoiceHistoryModel.docno;
            _InvoiceHistoryModels.add(_InvoiceHistoryModel);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('มีผู้ใช้อื่นกำลังทำรายการอยู่....',
                  style: TextStyle(
                    color: Colors.white,
                  ))),
        );
      }

      setState(() {
        // Form_payment1.text = (sum_amt - sum_disamt - dis_sum_Pakan)
        //     .toStringAsFixed(2)
        //     .toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('มีผู้ใช้อื่นกำลังทำรายการอยู่....',
                style: TextStyle(
                  color: Colors.white,
                ))),
      );
    }
  }

  ////////////////--------------------------------------->
  List<String> mmonth = [
    "มกราคม",
    "กุมภาพันธ์",
    "มีนาคม",
    "เมษายน",
    "พฤษภาคม",
    "มิถุนายน",
    "กรกฎาคม",
    "สิงหาคม",
    "กันยายน",
    "ตุลาคม",
    "พฤศจิกายน",
    "ธันวาคม"
  ];
  String day = "";
  String month = "";
  int tap = 1;
  var date = "";
  var datestart = "";
  var dateend = "";
  List<DateTime> datelist = [];
  int selected = 0;
  DateTime? maxdate;
  double daytotal = 0, daytotal_t = 0;
  List listitem = [];
  ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    // //////print("${selected}");
    //////////////////////////////////////////////////

    return Scaffold(
      backgroundColor: bgcolor,
      body: Padding(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
          ),
          child: select_page == 0
              ? SingleChildScrollView(
                  controller: _scrollController,
                  child: home_page(),
                )
              : SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              deall_Trans_select();
                              select_page = 0;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: grey, style: BorderStyle.solid),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: const Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.arrow_back_ios),
                                    Text(
                                      'หน้าหลัก',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color.fromRGBO(100, 108, 110, 1),
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: select_page == 1
                            ? PayScanBillscreen(
                                barcode: _barcode) // PayTranscreen()//_barcode
                            : select_page == 2
                                ? (renTal_user.toString() == '106' ||
                                        renTal_user.toString() == '50')
                                    ? PaybillMainScreenChoice() //PayBillscreenChoice()
                                    : PaybillMainScreen()
                                // PayBillscreen()
                                : select_page == 3
                                    ? const MwterScreen()
                                    : select_page == 4
                                        ? const StatusScreen2()
                                        : select_page == 5
                                            ? const BillHistory()
                                            //  Text(
                                            //     'ดาวโหลดใบเสร็จ Coming soon...',
                                            //     textAlign: TextAlign.center,
                                            //     style: TextStyle(
                                            //       fontSize: 16,
                                            //       color: Color.fromRGBO(
                                            //           100, 108, 110, 1),
                                            //       fontFamily: Font_.Fonts_T,
                                            //     ),
                                            //   )
                                            : select_page == 6
                                                ? const Text(
                                                    'แจ้งซ่อม Coming soon...',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color.fromRGBO(
                                                          100, 108, 110, 1),
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  )
                                                : const Text(
                                                    'Coming soon...',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color.fromRGBO(
                                                          100, 108, 110, 1),
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                      ),
                    ],
                  ),
                )),
    );
  }

  Column home_page() {
    var now = DateTime.now();
    var datenow = DateFormat('yyyy-MM-dd').format(now);
    var dddate = DateFormat('dd').format(now);
    var yyyydate = DateFormat('yyyy').format(now);
    var mmdate = DateFormat('MM').format(now);
    // //แสดงเดือนตรงยอดชำระ
    int mnum = int.parse(mmdate) - 1;
    int mm = int.parse(mmdate);
    int dd = int.parse(dddate);
    int year = int.parse(yyyydate) + 543;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              selectCid(context);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: grey, style: BorderStyle.solid),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                          child: Text(
                            'ข้อมูลผู้เช่า',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontFamily: FontWeight_.Fonts_T,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                          child: Text(
                            'เลือกสัญญา>>',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: Font_.Fonts_T,
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
                          padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                          child: Text(
                            'ชื่อ: $cus_cname',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(100, 108, 110, 1),
                              fontFamily: Font_.Fonts_T,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, right: 8.0, left: 8.0),
                          child: Text(
                            'เลขที่สัญญา: $cid_doc ',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(100, 108, 110, 1),
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
                          padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                          child: Text(
                            'ร้าน: $cus_stype',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(100, 108, 110, 1),
                              fontFamily: Font_.Fonts_T,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 8.0, right: 8.0, left: 8.0),
                          child: Text(
                            'โซน: $cus_zn พื้นที่: $cus_lncode',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(100, 108, 110, 1),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: grey, style: BorderStyle.solid),
                image: DecorationImage(
                    image: const AssetImage("LOGO-removebg-preview.png"),
                    //  NetworkImage(imgbag_.toString()), // AssetImage("image/LOGO-removebg-preview.png"),.
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.1), BlendMode.dstATop)),
                color: Colors.white,
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.only(
                  top: 8, bottom: 8, left: 10.0, right: 10.0),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ยอดค้างชำระ',
                      style: TextStyle(
                          fontSize: 18,
                          color: Color.fromRGBO(100, 108, 110, 1),
                          // fontFamily: FontWeight_.Fonts_T,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "วันที่ ${dddate} ${mmonth[mnum]} ${year}",
                        style: const TextStyle(
                          color: Color.fromRGBO(100, 108, 110, 1),
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(100, 108, 110, 1),
                                // fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "${nFormat.format(amount + in_amt)}",
                                style: TextStyle(fontSize: 35, color: grey),
                              ),
                              Container(
                                alignment: Alignment.bottomCenter,
                                height: 35,
                                child: Text(
                                  "บาท",
                                  style: TextStyle(
                                    color: grey,
                                    fontFamily: FontWeight_.Fonts_T,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Text(
                            "ยอดค้างชำระวันนี้ : ${nFormat.format((amount + in_amt) - ((amount + in_amt) - (daytotal + daytotal_t)))}",
                            style: TextStyle(
                              color: grey,
                              fontFamily: Font_.Fonts_T,
                            ),
                          ),
                          // Text(
                          //   "ยอดค้างชำระ : ${nFormat.format(amount - daytotal)}",
                          //   style: TextStyle(color: grey),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     // ชำระล่วงหน้า
                //     ElevatedButtonBox(null, null, () {
                //       setState(() {
                //         showdialog_date();
                //       });
                //     },
                //         BorderRadius.circular(15),
                //         Colors.white,
                //         Colors.green,
                //         "ชำระล่วงหน้า",
                //         const TextStyle(
                //           // fontWeight: FontWeight.bold,
                //           fontSize: 18,
                //         )),

                //     // ชำระ
                //     ElevatedButtonBox(100, null, () async {
                //       List item = [];
                //       setState(() {
                //         listitem.forEach((element) {
                //           if (element['value'] == true) {
                //             item.add({
                //               'ser': "${element['ser']}",
                //               'date': "${element['date']}",
                //               'expname': "${element['expname']}",
                //               'month': "${element['month']}",
                //               'docno': "${element['docno']}",
                //               'total': "${element['total']}"
                //             });
                //           }
                //         });
                //       });
                //       red_payMent().then((value) => {
                //             if (item.length < 1)
                //               {
                //                 showDialog(
                //                     context: context,
                //                     builder: (BuildContext context) {
                //                       return AlertDialog(
                //                         titlePadding: EdgeInsets.zero,
                //                         shape: RoundedRectangleBorder(
                //                             borderRadius:
                //                                 BorderRadius.circular(20)),
                //                         clipBehavior: Clip.hardEdge,
                //                         title: Container(
                //                             padding: EdgeInsets.symmetric(
                //                                 horizontal: 10.0,
                //                                 vertical: 6.0),
                //                             color: Color.fromRGBO(
                //                                 196, 188, 133, 1),
                //                             child: Center(
                //                               child: Text(
                //                                 "ขออภัย",
                //                                 style: TextStyle(
                //                                     color: Colors.black),
                //                               ),
                //                             )),
                //                         content: SizedBox(
                //                           height: 50,
                //                           child: Center(
                //                             child: Text(
                //                               "ไม่มีรายการรับชำระ",
                //                               style: TextStyle(
                //                                 color: Colors.black,
                //                                 fontFamily: Font_.Fonts_T,
                //                               ),
                //                             ),
                //                           ),
                //                         ),
                //                         actions: <Widget>[
                //                           Column(
                //                             children: [
                //                               const SizedBox(
                //                                 height: 5.0,
                //                               ),
                //                               const Divider(
                //                                 color: Colors.grey,
                //                                 height: 4.0,
                //                               ),
                //                               const SizedBox(
                //                                 height: 5.0,
                //                               ),
                //                               Padding(
                //                                 padding:
                //                                     const EdgeInsets.all(
                //                                         8.0),
                //                                 child: Row(
                //                                   mainAxisAlignment:
                //                                       MainAxisAlignment
                //                                           .center,
                //                                   children: [
                //                                     Container(
                //                                       padding:
                //                                           const EdgeInsets
                //                                               .all(8.0),
                //                                       width: 150,
                //                                       child: InkWell(
                //                                         onTap: () {
                //                                           Navigator.pop(
                //                                               context);
                //                                         },
                //                                         child: Container(
                //                                             decoration:
                //                                                 BoxDecoration(
                //                                               color: Colors
                //                                                   .black,
                //                                               borderRadius: const BorderRadius
                //                                                   .only(
                //                                                   topLeft:
                //                                                       Radius.circular(
                //                                                           6),
                //                                                   topRight:
                //                                                       Radius.circular(
                //                                                           6),
                //                                                   bottomLeft:
                //                                                       Radius.circular(
                //                                                           6),
                //                                                   bottomRight:
                //                                                       Radius.circular(
                //                                                           6)),
                //                                               border: Border.all(
                //                                                   color: Colors
                //                                                       .grey,
                //                                                   width: 1),
                //                                             ),
                //                                             child:
                //                                                 const Row(
                //                                               mainAxisAlignment:
                //                                                   MainAxisAlignment
                //                                                       .center,
                //                                               children: [
                //                                                 Padding(
                //                                                   padding:
                //                                                       EdgeInsets.all(
                //                                                           4.0),
                //                                                   child:
                //                                                       Icon(
                //                                                     Icons
                //                                                         .highlight_off,
                //                                                     color: Colors
                //                                                         .white,
                //                                                     size:
                //                                                         16,
                //                                                   ),
                //                                                 ),
                //                                                 Padding(
                //                                                   padding:
                //                                                       EdgeInsets.all(
                //                                                           4.0),
                //                                                   child:
                //                                                       Text(
                //                                                     'ปิด',
                //                                                     style:
                //                                                         TextStyle(
                //                                                       fontSize:
                //                                                           14,
                //                                                       color:
                //                                                           Colors.white,
                //                                                       fontFamily:
                //                                                           Font_.Fonts_T,
                //                                                       // fontWeight:
                //                                                       //     FontWeight.bold,
                //                                                     ),
                //                                                   ),
                //                                                 ),
                //                                               ],
                //                                             )),
                //                                       ),
                //                                     ),
                //                                     // Container(
                //                                     //   width: 100,
                //                                     //   decoration:
                //                                     //       const BoxDecoration(
                //                                     //     color: Colors
                //                                     //         .redAccent,
                //                                     //     borderRadius: BorderRadius.only(
                //                                     //         topLeft: Radius
                //                                     //             .circular(
                //                                     //                 10),
                //                                     //         topRight: Radius
                //                                     //             .circular(
                //                                     //                 10),
                //                                     //         bottomLeft: Radius
                //                                     //             .circular(
                //                                     //                 10),
                //                                     //         bottomRight: Radius
                //                                     //             .circular(
                //                                     //                 10)),
                //                                     //   ),
                //                                     //   padding:
                //                                     //       const EdgeInsets
                //                                     //           .all(8.0),
                //                                     //   child: TextButton(
                //                                     //     onPressed: () =>
                //                                     //         Navigator.pop(
                //                                     //             context,
                //                                     //             'OK'),
                //                                     //     child: const Text(
                //                                     //       'ปิด',
                //                                     //       style: TextStyle(
                //                                     //         color: Colors
                //                                     //             .white,
                //                                     //         fontWeight:
                //                                     //             FontWeight
                //                                     //                 .bold,
                //                                     //       ),
                //                                     //     ),
                //                                     //   ),
                //                                     // ),
                //                                   ],
                //                                 ),
                //                               ),
                //                             ],
                //                           ),
                //                         ],
                //                       );
                //                     })
                //               }
                //             else if (Ser_PAy != null ||
                //                 Ser_PAy.toString() == '1')
                //               {
                //                 Navigator.push(context,
                //                     MaterialPageRoute(builder: (ctx) {
                //                   return Payscreen(
                //                       item: item,
                //                       InvoiceHistoryModels:
                //                           _InvoiceHistoryModels);
                //                   //Payscreen( _TransModels : data);
                //                 }))
                //               }
                //             else if (item.length > 0 && Ser_PAy == null ||
                //                 Ser_PAy.toString() == '0')
                //               {
                //                 showDialog(
                //                     context: context,
                //                     builder: (BuildContext context) {
                //                       return AlertDialog(
                //                         titlePadding: EdgeInsets.zero,
                //                         shape: RoundedRectangleBorder(
                //                             borderRadius:
                //                                 BorderRadius.circular(20)),
                //                         clipBehavior: Clip.hardEdge,
                //                         title: Container(
                //                             padding: EdgeInsets.symmetric(
                //                                 horizontal: 10.0,
                //                                 vertical: 6.0),
                //                             color: Color.fromRGBO(
                //                                 196, 188, 133, 1),
                //                             child: Center(
                //                               child: Text(
                //                                 "ขออภัย",
                //                                 style: TextStyle(
                //                                   color: Colors.black,
                //                                   fontFamily: Font_.Fonts_T,
                //                                 ),
                //                               ),
                //                             )),
                //                         content: SizedBox(
                //                           height: 50,
                //                           child: Center(
                //                             child: Text(
                //                               "ผู้ให้เช่าไม่อนุญาตให้ชำระผ่านเว็ป โปรดชำระได้ที่เจ้าหน้าที่",
                //                               style: TextStyle(
                //                                 color: Colors.black,
                //                                 fontFamily: Font_.Fonts_T,
                //                               ),
                //                             ),
                //                           ),
                //                         ),
                //                         actions: <Widget>[
                //                           Column(
                //                             children: [
                //                               const SizedBox(
                //                                 height: 5.0,
                //                               ),
                //                               const Divider(
                //                                 color: Colors.grey,
                //                                 height: 4.0,
                //                               ),
                //                               const SizedBox(
                //                                 height: 5.0,
                //                               ),
                //                               Padding(
                //                                 padding:
                //                                     const EdgeInsets.all(
                //                                         8.0),
                //                                 child: Row(
                //                                   mainAxisAlignment:
                //                                       MainAxisAlignment
                //                                           .center,
                //                                   children: [
                //                                     Container(
                //                                       padding:
                //                                           const EdgeInsets
                //                                               .all(8.0),
                //                                       width: 150,
                //                                       child: InkWell(
                //                                         onTap: () {
                //                                           Navigator.pop(
                //                                               context);
                //                                         },
                //                                         child: Container(
                //                                             decoration:
                //                                                 BoxDecoration(
                //                                               color: Colors
                //                                                   .black,
                //                                               borderRadius: const BorderRadius
                //                                                   .only(
                //                                                   topLeft:
                //                                                       Radius.circular(
                //                                                           6),
                //                                                   topRight:
                //                                                       Radius.circular(
                //                                                           6),
                //                                                   bottomLeft:
                //                                                       Radius.circular(
                //                                                           6),
                //                                                   bottomRight:
                //                                                       Radius.circular(
                //                                                           6)),
                //                                               border: Border.all(
                //                                                   color: Colors
                //                                                       .grey,
                //                                                   width: 1),
                //                                             ),
                //                                             child:
                //                                                 const Row(
                //                                               mainAxisAlignment:
                //                                                   MainAxisAlignment
                //                                                       .center,
                //                                               children: [
                //                                                 Padding(
                //                                                   padding:
                //                                                       EdgeInsets.all(
                //                                                           4.0),
                //                                                   child:
                //                                                       Icon(
                //                                                     Icons
                //                                                         .highlight_off,
                //                                                     color: Colors
                //                                                         .white,
                //                                                     size:
                //                                                         16,
                //                                                   ),
                //                                                 ),
                //                                                 Padding(
                //                                                   padding:
                //                                                       EdgeInsets.all(
                //                                                           4.0),
                //                                                   child:
                //                                                       Text(
                //                                                     'ปิด',
                //                                                     style:
                //                                                         TextStyle(
                //                                                       fontSize:
                //                                                           14,
                //                                                       color:
                //                                                           Colors.white,
                //                                                       fontFamily:
                //                                                           Font_.Fonts_T,
                //                                                       // fontWeight:
                //                                                       //     FontWeight.bold,
                //                                                     ),
                //                                                   ),
                //                                                 ),
                //                                               ],
                //                                             )),
                //                                       ),
                //                                     ),
                //                                     // Container(
                //                                     //   width: 100,
                //                                     //   decoration:
                //                                     //       const BoxDecoration(
                //                                     //     color: Colors
                //                                     //         .redAccent,
                //                                     //     borderRadius: BorderRadius.only(
                //                                     //         topLeft: Radius
                //                                     //             .circular(
                //                                     //                 10),
                //                                     //         topRight: Radius
                //                                     //             .circular(
                //                                     //                 10),
                //                                     //         bottomLeft: Radius
                //                                     //             .circular(
                //                                     //                 10),
                //                                     //         bottomRight: Radius
                //                                     //             .circular(
                //                                     //                 10)),
                //                                     //   ),
                //                                     //   padding:
                //                                     //       const EdgeInsets
                //                                     //           .all(8.0),
                //                                     //   child: TextButton(
                //                                     //     onPressed: () =>
                //                                     //         Navigator.pop(
                //                                     //             context,
                //                                     //             'OK'),
                //                                     //     child: const Text(
                //                                     //       'ปิด',
                //                                     //       style: TextStyle(
                //                                     //         color: Colors
                //                                     //             .white,
                //                                     //         fontWeight:
                //                                     //             FontWeight
                //                                     //                 .bold,
                //                                     //       ),
                //                                     //     ),
                //                                     //   ),
                //                                     // ),
                //                                   ],
                //                                 ),
                //                               ),
                //                             ],
                //                           ),
                //                         ],
                //                       );
                //                     })
                //               }
                //           });
                //     },
                //         BorderRadius.circular(15),
                //         Colors.white,
                //         const Color.fromARGB(255, 254, 0, 0),
                //         "ชำระ",
                //         const TextStyle(
                //           // fontWeight: FontWeight.bold,
                //           fontSize: 18,
                //           fontFamily: Font_.Fonts_T,
                //         )),
                //   ],
                // ),
                const Divider(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                IconButton(
                                  iconSize: 30,
                                  onPressed: () {
                                    scanQRMobile();
                                  },
                                  icon: Icon(
                                    Icons
                                        .qr_code_scanner, //Icons.currency_exchange_outlined,
                                    color: _TransBillModels.length == 0
                                        ? Colors.black
                                        : Colors.red,
                                  ),
                                ),
                                Text(
                                  'Scan',
                                ), // Text('ค้างชำระ',)
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Column(
                                children: [
                                  IconButton(
                                    iconSize: 30,
                                    onPressed: () {
                                      setState(() {
                                        select_page = 2;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.request_page_outlined,
                                      color: _InvoiceModels.length == 0
                                          ? Colors.black
                                          : Colors.red,
                                    ),
                                  ),
                                  _InvoiceModels.length == 0
                                      ? const Text('บิลเรียกเก็บ')
                                      : RichText(
                                          text: TextSpan(
                                            text: "บิลเรียกเก็บ",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontFamily: Font_.Fonts_T,
                                            ),
                                            children: <TextSpan>[
                                              _InvoiceModels.length == 0
                                                  ? const TextSpan(
                                                      text: '',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        // fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                      ),
                                                    )
                                                  : TextSpan(
                                                      text:
                                                          ' ${_InvoiceModels.length}',
                                                      style: const TextStyle(
                                                        color: Colors.red,
                                                        // fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                IconButton(
                                  iconSize: 30,
                                  onPressed: () {
                                    // setState(() {
                                    //   select_page = 1;
                                    // });
                                    // if (Theme.of(context).platform ==
                                    //     TargetPlatform.android) {
                                    //   //////print("Android");
                                    //   scanQRMobile();
                                    //   // platformName = "Android";
                                    // } else if (Theme.of(context).platform ==
                                    //     TargetPlatform.iOS) {
                                    //   //////print("IOS");
                                    //   scanQRMobile();
                                    //   // platformName = "IOS";
                                    // }
                                    // } else if (Theme.of(context).platform ==
                                    //     TargetPlatform.fuchsia) {
                                    //   //////print("Fuchsia");
                                    //   scanQRMobile();
                                    //   // platformName = "Fuchsia";
                                    // } else if (Theme.of(context).platform ==
                                    //     TargetPlatform.linux) {
                                    //   //////print("Linux");
                                    //   scanQRMobile();
                                    //   // platformName = "Linux";
                                    // } else if (Theme.of(context).platform ==
                                    //     TargetPlatform.macOS) {
                                    //   //////print("MacOS");
                                    //   scanQRMobile();
                                    //   // platformName = "MacOS";
                                    // } else if (Theme.of(context).platform ==
                                    //     TargetPlatform.windows) {
                                    //   //////print("Windows");
                                    //   scanQRMobile();
                                    //   // platformName = "Windows";
                                    // }
                                    // else {
                                    //   //////print("Web");
                                    //   scanQR();
                                    // }
                                    // scanQR();
                                    // Payscreen();
                                  },
                                  icon: const Icon(
                                    Icons
                                        .qr_code_scanner, //Icons.currency_exchange_outlined,
                                    color: Colors.black,
                                    // color: _TransBillModels.length == 0
                                    //     ? Colors.black
                                    //     : Colors.red,
                                  ),
                                ),
                                const Text(
                                  'Scan',
                                ), // Text('ค้างชำระ',)
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                IconButton(
                                  iconSize: 30,
                                  onPressed: () {
                                    if (_ContractxModels.isEmpty) {
                                      showdialog_Coming();
                                    } else {
                                      setState(() {
                                        select_page = 3;
                                      });
                                    }

                                    // setState(() {
                                    //   select_page = 3;
                                    // });
                                  },
                                  icon: const Icon(
                                      Icons.document_scanner_outlined),
                                ),
                                const Text('มิเตอร์')
                              ],
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                IconButton(
                                  iconSize: 30,
                                  onPressed: () {
                                    // showdialog_Coming();
                                    setState(() {
                                      select_page = 4;
                                    });
                                  },
                                  icon: const Icon(Icons.article_outlined),
                                ),
                                const Text('สถานะการชำระ')
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                IconButton(
                                  iconSize: 30,
                                  onPressed: () {
                                    // showdialog_Coming();
                                    setState(() {
                                      select_page = 5;
                                    });
                                  },
                                  icon: const Icon(Icons.receipt_long_outlined),
                                ),
                                const Text('ดาวโหลดใบเสร็จ')
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                IconButton(
                                  iconSize: 30,
                                  onPressed: () {
                                    showdialog_Coming();
                                    // setState(() {
                                    //   select_page = 6;
                                    // });
                                  },
                                  icon: const Icon(Icons.handyman_outlined),
                                ),
                                const Text('แจ้งซ่อม')
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ])),
        ),
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _scrollController.animateTo(_scrollController.offset + 450,
                  curve: Curves.linear,
                  duration: const Duration(milliseconds: 500));
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 8, bottom: 8.0),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "ข่าวสาร",
                style: TextStyle(
                  fontSize: 18,
                  color: grey,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontWeight_.Fonts_T,
                ),
              ),
            ),
          ),
        ),
        // SizedBox(
        //   height: 10,
        // ),
        Container(
          padding: const EdgeInsets.all(8),
          child: CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 2.0,
              enlargeCenterPage: true,
            ),
            items: imageSliders,
          ),
        ),
        SizedBox(
          height: 50,
          child: Row(
            children: [
              Expanded(
                child: Marquee(
                  text: '${textList.map((e) => e)}',
                  style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                  ),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  blankSpace: 20.0,
                  velocity: 30.0,
                  // pauseAfterRound: Duration(seconds: 1),
                  startPadding: 10.0,
                  // accelerationDuration: Duration(seconds: 1),
                  // accelerationCurve: Curves.linear,
                  // decelerationDuration: Duration(milliseconds: 500),
                  // decelerationCurve: Curves.easeOut,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 150,
        ),
      ],
    );
  }

  // Future<void> scanQR() async {
  //   var res = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const SimpleBarcodeScannerPage(
  //             scanType: ScanType.qr, appBarTitle: 'แสกน QR Code'),
  //       ));
  //   setState(() {
  //     if (res is String) {
  //       var result = res;
  //       if (result.substring(0, 1).toString() == '|') {
  //         var barcodeSca1 = result.replaceAll('\r', '/').split('/');
  //         var barcodeSca2 = barcodeSca1[1].substring(0, 5) +
  //             "-" +
  //             barcodeSca1[1].substring(5, 7) +
  //             "-" +
  //             barcodeSca1[1].substring(7, barcodeSca1[1].length);
  //         //////print('barcodeScanRes>>> $barcodeSca2 >>> ${barcodeSca1[1]}');

  //         setState(() {
  //           _barcode = barcodeSca2;
  //           select_page = 1;
  //         });
  //       }
  //     }
  //   });

  //   // String barcodeScanRes;
  //   // // Platform messages may fail, so we use a try/catch PlatformException.
  //   // try {
  //   //   barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
  //   //       '#ff6666', 'Cancel', true, ScanMode.QR);
  //   //   //////print(barcodeScanRes);
  //   // } on PlatformException {
  //   //   barcodeScanRes = 'Failed to get platform version.';
  //   // }

  //   // // If the widget was removed from the tree while the asynchronous platform
  //   // // message was in flight, we want to discard the reply rather than calling
  //   // // setState to update our non-existent appearance.
  //   // if (!mounted) return;

  //   // if (barcodeScanRes.substring(0, 1).toString() == '|') {
  //   //   var barcodeSca1 = barcodeScanRes.replaceAll('\r', '/').split('/');
  //   //   var barcodeSca2 = barcodeSca1[1].substring(0, 5) +
  //   //       "-" +
  //   //       barcodeSca1[1].substring(5, 7) +
  //   //       "-" +
  //   //       barcodeSca1[1].substring(7, barcodeSca1[1].length);
  //   //   //////print('barcodeScanRes>>> $barcodeSca2 >>> ${barcodeSca1[1]}');

  //   //   setState(() {
  //   //     // select_page = 1;
  //   //   });
  //   // } else {}
  // }

  Future<void> scanQRMobile() async {
    // String barcodeScanRes;
    // // Platform messages may fail, so we use a try/catch PlatformException.
    // try {
    //   var res = await Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => const MobileScannerPage(),
    //       ));
    //   if (res is String) {
    //     barcodeScanRes = res;
    //   } else {
    //     barcodeScanRes = '-1';
    //   }
    //   //////print(barcodeScanRes);
    // } catch (e) {
    //   barcodeScanRes = 'Failed to get platform version.';
    // }

    // // If the widget was removed from the tree while the asynchronous platform
    // // message was in flight, we want to discard the reply rather than calling
    // // setState to update our non-existent appearance.
    // if (!mounted) return;

    // if (barcodeScanRes.substring(0, 1).toString() == '|') {
    //   var barcodeSca1 = barcodeScanRes.replaceAll('\r', '/').split('/');
    //   var barcodeSca2 = barcodeSca1[1].substring(0, 5) +
    //       "-" +
    //       barcodeSca1[1].substring(5, 7) +
    //       "-" +
    //       barcodeSca1[1].substring(7, barcodeSca1[1].length);
    //   //////print('barcodeScanRes>>> $barcodeSca2 >>> ${barcodeSca1[1]}');

    //   setState(() {
    //     _barcode = barcodeSca2;
    //     select_page = 1;
    //   });
    // } else {}
  }

  Future<String?> selectCid(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: const Center(
            child: Text(
          'เลือกสัญญา',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: FontWeight_.Fonts_T),
        )),
        actions: <Widget>[
          Column(
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
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
                            // widget.navigateToMeter(0);
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            var custno_ = preferences.getString('custno');
                            MaterialPageRoute route = MaterialPageRoute(
                              builder: (context) =>
                                  SelectCid(custno_s: custno_),
                            );
                            Navigator.pushAndRemoveUntil(
                                context, route, (route) => false);
                          },
                          child: const Text(
                            'ยืนยัน',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text(
                                'ยกเลิก',
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> logOut(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: const Center(
            child: Text(
          'ออกจากระบบ',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: FontWeight_.Fonts_T),
        )),
        actions: <Widget>[
          Column(
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
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
                            // ✅ Clear ทุกอย่าง: SharedPreferences, ApiSession,
                            //    AppMarkets, web localStorage, Provider state
                            await SessionService.clearAll(
                                providers: <ChangeNotifier>[
                                  context.read<WaitPayListProvider>(),
                                  context.read<PayFormProvider>(),
                                  context.read<PayHisProvider>(),
                                ]);
                            if (!context.mounted) return;
                            MaterialPageRoute route = MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            );
                            Navigator.pushAndRemoveUntil(
                                context, route, (route) => false);
                          },
                          child: const Text(
                            'ยืนยัน',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text(
                                'ยกเลิก',
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  showdialog_Coming() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Container(
              height: MediaQuery.of(context).size.width * 0.2,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Center(
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        'Coming soon...',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: Font_.Fonts_T,
                        ),
                      )),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildBottomSheet(
    BuildContext context,
    ScrollController scrollController,
    double bottomSheetOffset,
  ) {
    return Material(
      child: Container(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              color: const Color.fromARGB(255, 184, 198, 133),
              // height: 50,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'รายการวางบิล ',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: FontWeight_.Fonts_T,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 8),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 5))
                    ],
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 201, 196, 186),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(0)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Center(
                                      child: Text(
                                        maxLines: 1,
                                        'ประเภท',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T,
                                        ),
                                      ),
                                    ),
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Center(
                                      child: Text(
                                        maxLines: 1,
                                        'กำหนดชำระ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T,
                                        ),
                                      ),
                                    ),
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Center(
                                      child: Text(
                                        maxLines: 1,
                                        'เลขตั้งหนี้',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T,
                                        ),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 30),
                          child: _InvoiceModels.isEmpty
                              ? SizedBox(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: LoadingIndicator(
                                          indicatorType: Indicator.values[30],
                                          colors: _kDefaultRainbowColors,
                                          strokeWidth: 4.0,
                                          // pathBackgroundColor:
                                          //     showPathBackground ? Colors.black45 : null,
                                        ),
                                      ),
                                      StreamBuilder(
                                        stream: Stream.periodic(
                                            const Duration(milliseconds: 25),
                                            (i) => i),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData)
                                            return const Text('');
                                          double elapsed = double.parse(
                                                  snapshot.data.toString()) *
                                              0.05;
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: (elapsed > 8.00)
                                                ? const Text(
                                                    '',
                                                    style: TextStyle(

                                                        //fontSize: 10.0
                                                        ),
                                                  )
                                                : Text(
                                                    'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                                                    // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                                                    style: const TextStyle(
                                                      fontFamily: Font_.Fonts_T,

                                                      //fontSize: 10.0
                                                    ),
                                                  ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  // itemExtent: 50,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(), //NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _InvoiceModels.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ListTile(
                                        onTap: () async {
                                          red_Trans_select(index);
                                          showdialog_Detail();
                                        },
                                        title: Container(
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.black12,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: TextSpan(
                                                    text:
                                                        '${_InvoiceModels[index].descr}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T,

                                                      //fontSize: 10.0
                                                    ),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Colors.grey[200],
                                                  ),
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 25,
                                                    maxLines: 1,
                                                    '${_InvoiceModels[index].descr}',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: TextSpan(
                                                    text:
                                                        '${DateFormat('dd-MM').format(DateTime.parse('${_InvoiceModels[index].date} 00:00:00'))}-${DateTime.parse('${_InvoiceModels[index].date} 00:00:00').year + 543}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T,

                                                      //fontSize: 10.0
                                                    ),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Colors.grey[200],
                                                  ),
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 25,
                                                    maxLines: 1,
                                                    '${DateFormat('dd-MM').format(DateTime.parse('${_InvoiceModels[index].date} 00:00:00'))}-${DateTime.parse('${_InvoiceModels[index].date} 00:00:00').year + 543}',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: Font_.Fonts_T,
                                                      //fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: TextSpan(
                                                    text:
                                                        '${_InvoiceModels[index].docno}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: Font_.Fonts_T,

                                                      //fontSize: 10.0
                                                    ),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Colors.grey[200],
                                                  ),
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 25,
                                                    maxLines: 1,
                                                    '${_InvoiceModels[index].docno}',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ));
                                  }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 8, left: 15, right: 15, bottom: 20),
              child: Container(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 110,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        Navigator.of(context, rootNavigator: false).pop();
                      });
                    },
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromRGBO(171, 172, 172, 1),
                        )),
                    child: const Text(
                      "กลับไป",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: FontWeight_.Fonts_T,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  showdialog_Detail() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 0)),
              builder: (context, snapshot) {
                return AlertDialog(
                  titlePadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  clipBehavior: Clip.hardEdge,
                  // title: Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Center(
                  //     child: Text(
                  //       'เลขที่ใบแจ้งหนี้ $numinvoice',
                  //       style: TextStyle(color: Colors.black, fontSize: 18),
                  //     ),
                  //   ),
                  // ),
                  content: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            }),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Container(
                                    // color: Colors.amber,
                                    width: (Responsive.isDesktop(context))
                                        ? MediaQuery.of(context).size.width *
                                            0.9
                                        : 900,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                height: 50,
                                                decoration: const BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 184, 198, 133),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(0),
                                                    bottomLeft:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(0),
                                                  ),
                                                  // border: Border.all(
                                                  //     color: Colors.grey, width: 1),
                                                ),
                                                // padding: const EdgeInsets.all(8.0),
                                                child: const Center(
                                                  child: Text(
                                                    'รายละเอียด', //numinvoice
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T,

                                                      //fontSize: 10.0
                                                      //fontSize: 10.0
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                height: 50,
                                                decoration: const BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 184, 198, 133),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(0),
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(0),
                                                  ),
                                                  // border: Border.all(
                                                  //     color: Colors.grey, width: 1),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(15),
                                                      topRight:
                                                          Radius.circular(15),
                                                      bottomLeft:
                                                          Radius.circular(15),
                                                      bottomRight:
                                                          Radius.circular(15),
                                                    ),
                                                    // border: Border.all(
                                                    //     color: Colors.grey, width: 1),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'เลขที่ใบแจ้งหนี้ ${numinvoice}', //
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            FontWeight_.Fonts_T,

                                                        //fontSize: 10.0
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                            // width:
                                            //     (Responsive.isDesktop(context))
                                            //         ? MediaQuery.of(context)
                                            //                 .size
                                            //                 .width *
                                            //             0.9
                                            //         : 900,
                                            decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 201, 196, 186),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(0),
                                                  topRight: Radius.circular(0),
                                                  bottomLeft:
                                                      Radius.circular(0),
                                                  bottomRight:
                                                      Radius.circular(0)),
                                            ),
                                            padding: const EdgeInsets.all(8.0),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'ลำดับ',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'กำหนดชำระ',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'รายการ',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'จำนวน',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'หน่วย',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'VAT(฿)',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'WHT(฿)',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'ยอดสุทธิ',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                        Expanded(
                                          child: Container(
                                            color: Colors.white,
                                            child: _InvoiceHistoryModels.isEmpty
                                                ? SizedBox(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          height: 50,
                                                          width: 50,
                                                          child:
                                                              LoadingIndicator(
                                                            indicatorType:
                                                                Indicator
                                                                    .values[30],
                                                            colors:
                                                                _kDefaultRainbowColors,
                                                            strokeWidth: 4.0,
                                                            // pathBackgroundColor:
                                                            //     showPathBackground ? Colors.black45 : null,
                                                          ),
                                                        ),
                                                        StreamBuilder(
                                                          stream: Stream.periodic(
                                                              const Duration(
                                                                  milliseconds:
                                                                      25),
                                                              (i) => i),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (!snapshot
                                                                .hasData)
                                                              return const Text(
                                                                  '');
                                                            double elapsed =
                                                                double.parse(snapshot
                                                                        .data
                                                                        .toString()) *
                                                                    0.05;
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: (elapsed >
                                                                      8.00)
                                                                  ? const Text(
                                                                      '',
                                                                      style: TextStyle(

                                                                          //fontSize: 10.0
                                                                          ),
                                                                    )
                                                                  : Text(
                                                                      'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                                                                      // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                                                                      style:
                                                                          const TextStyle(
                                                                        fontFamily:
                                                                            Font_.Fonts_T,
                                                                        //fontSize: 10.0
                                                                      ),
                                                                    ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : ListView.builder(
                                                    // controller: _scrollController2,
                                                    // itemExtent: 50,
                                                    physics:
                                                        const AlwaysScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        _InvoiceHistoryModels
                                                            .length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return Material(
                                                        color: Colors.white,
                                                        child: ListTile(
                                                          onTap: () {},
                                                          title: Container(
                                                            decoration:
                                                                const BoxDecoration(
                                                              border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                                  color: Colors
                                                                      .black12,
                                                                  width: 1,
                                                                ),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        15,
                                                                    maxLines: 1,
                                                                    '${index + 1}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      //fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        15,
                                                                    maxLines: 1,
                                                                    '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${_InvoiceHistoryModels[index].date} 00:00:00'))}', //${_InvoiceHistoryModels[index].date}
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      //fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        15,
                                                                    maxLines: 1,
                                                                    '${_InvoiceHistoryModels[index].descr}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      //fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        15,
                                                                    maxLines: 1,
                                                                    '${nFormat.format(double.parse(_InvoiceHistoryModels[index].qty!))}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      //fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        15,
                                                                    maxLines: 1,
                                                                    _InvoiceHistoryModels[index].nvalue !=
                                                                            '0'
                                                                        ? '${nFormat.format(double.parse(_InvoiceHistoryModels[index].pri!))}'
                                                                        : '${nFormat.format(double.parse(_InvoiceHistoryModels[index].nvat!))}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      //fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        15,
                                                                    maxLines: 1,
                                                                    '${nFormat.format(double.parse(_InvoiceHistoryModels[index].vat!))}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      //fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        15,
                                                                    maxLines: 1,
                                                                    '${nFormat.format(double.parse(_InvoiceHistoryModels[index].wht!))}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      //fontWeight: FontWeight.bold,),
                                                                    ),
                                                                  ),
                                                                ),
                                                                // Expanded(
                                                                //   flex: 1,
                                                                //   child: AutoSizeText(
                                                                //     minFontSize: 10,
                                                                //     maxFontSize: 15,
                                                                //     maxLines: 1,
                                                                //     '${nFormat.format(double.parse(_InvoiceHistoryModels[index].pvat!))}',
                                                                //     textAlign: TextAlign.end,
                                                                //     style: const TextStyle(
                                                                //         color:
                                                                //             PeopleChaoScreen_Color
                                                                //                 .Colors_Text2_,
                                                                //         //fontWeight: FontWeight.bold,
                                                                //         fontFamily: Font_.Fonts_T),
                                                                //   ),
                                                                // ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        15,
                                                                    maxLines: 1,
                                                                    '${nFormat.format(double.parse(_InvoiceHistoryModels[index].amt!))}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      //fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              color: const Color.fromARGB(255, 201, 196, 186),
                              // height: 100,
                              width: 300,
                              padding: const EdgeInsets.all(8.0),
                              child: Column(children: [
                                Row(
                                  children: [
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'รวม(บาท)',
                                        style: TextStyle(
                                          color: Colors.black, fontSize: 14,
                                          fontFamily: Font_.Fonts_T,
                                          //fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        textAlign: TextAlign.end,
                                        '${nFormat.format(sum_pvat)}',
                                        style: const TextStyle(
                                          color: Colors.black, fontSize: 14,
                                          fontFamily: Font_.Fonts_T,
                                          //fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ภาษีมูลค่าเพิ่ม(vat)',
                                        style: TextStyle(
                                          color: Colors.black, fontSize: 14,
                                          fontFamily: Font_.Fonts_T,
                                          //fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        textAlign: TextAlign.end,
                                        '${nFormat.format(sum_vat)}',
                                        style: const TextStyle(
                                          color: Colors.black, fontSize: 14,
                                          fontFamily: Font_.Fonts_T,
                                          //fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'หัก ณ ที่จ่าย',
                                        style: TextStyle(
                                          color: Colors.black, fontSize: 14,
                                          fontFamily: Font_.Fonts_T,
                                          //fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        textAlign: TextAlign.end,
                                        '${nFormat.format(sum_wht)}',
                                        style: const TextStyle(
                                          color: Colors.black, fontSize: 14,
                                          fontFamily: Font_.Fonts_T,
                                          //fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ยอดรวม',
                                        style: TextStyle(
                                          //fontWeight: FontWeight.bold,
                                          color: Colors.black, fontSize: 14,
                                          fontFamily: Font_.Fonts_T,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        textAlign: TextAlign.end,
                                        '${nFormat.format(sum_amt)}',
                                        style: const TextStyle(
                                          color: Colors.black, fontSize: 14,
                                          fontFamily: Font_.Fonts_T,
                                          //fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          const Text(
                                            'ส่วนลด',
                                            style: TextStyle(
                                              color: Colors.black, fontSize: 14,
                                              fontFamily: Font_.Fonts_T,
                                              //fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: 60,
                                            height: 20,
                                            child: Text(
                                              '$sum_disp  %',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: Font_.Fonts_T,
                                                //fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '${nFormat.format(sum_disamt)}',
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          color: Colors.black, fontSize: 14,
                                          fontFamily: Font_.Fonts_T,
                                          //fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // AutoSizeText(
                                      //   minFontSize: 10,
                                      //   maxFontSize: 15,
                                      //   textAlign: TextAlign.end,
                                      //   '${nFormat.format(0.00)}',
                                      //   style: TextStyle(
                                      //       color: PeopleChaoScreen_Color
                                      //           .Colors_Text2_,
                                      //       //fontWeight: FontWeight.bold,
                                      //       fontFamily: Font_.Fonts_T),
                                      // ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ยอดชำระ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Font_.Fonts_T,
                                          //fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        textAlign: TextAlign.end,
                                        '${nFormat.format(sum_amt - sum_disamt)}',
                                        style: const TextStyle(
                                          color: Colors.black, fontSize: 14,
                                          fontFamily: Font_.Fonts_T,
                                          //fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                width: 150,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            topRight: Radius.circular(6),
                                            bottomLeft: Radius.circular(6),
                                            bottomRight: Radius.circular(6)),
                                        border: Border.all(
                                            color: Colors.grey, width: 1),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.highlight_off,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Text(
                                              'ปิด',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontFamily: Font_.Fonts_T,
                                                // fontWeight:
                                                //     FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                              ),
                              // Container(
                              //   width: 100,
                              //   decoration: const BoxDecoration(
                              //     color: Colors.redAccent,
                              //     borderRadius: BorderRadius.only(
                              //         topLeft: Radius.circular(10),
                              //         topRight: Radius.circular(10),
                              //         bottomLeft: Radius.circular(10),
                              //         bottomRight: Radius.circular(10)),
                              //   ),
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: TextButton(
                              //     onPressed: () {
                              //       Navigator.pop(context, 'OK');
                              //     },
                              //     child: const Text(
                              //       'ปิด',
                              //       style: TextStyle(
                              //         color: Colors.white,
                              //         fontWeight: FontWeight.bold,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              });
        });
  }
}
