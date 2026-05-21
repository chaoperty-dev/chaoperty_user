// ignore_for_file: prefer_is_empty

import 'dart:convert';
import 'dart:io';

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant/Myconstant.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTranBill_model.dart';
import '../Model/GetZone_Model.dart';
import '../Model/trans_re_bill_history_model.dart';
import '../Model/trans_re_bill_model.dart';
import '../color.dart';
import 'editaccount_screen.dart';
import 'home_screen.dart';
import 'home_select_cid.dart';
import 'loginscreen.dart';
import 'metercheck_screen.dart';
import 'model/Home_Model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show ByteData, rootBundle;

import 'pay_screen.dart';
import 'payhistory_screen.dart';
import 'personalinfo_screen.dart';
import 'provider/homeprovider.dart';
import 'provider/payhisprovider.dart';
import 'rentalarea_screen.dart';
import 'select_screen.dart';

class ButtonNavBar extends StatefulWidget {
  final status;
  const ButtonNavBar({super.key, this.status});

  @override
  State<ButtonNavBar> createState() => _ButtonNavBarState();
}

class _ButtonNavBarState extends State<ButtonNavBar> {
  final PageStorageBucket bucket = PageStorageBucket();
  final _pageController = PageController(initialPage: 1);

  /// Controller to handle bottom nav bar and also handles initial page
  final _controller = NotchBottomBarController(index: 1);

  int maxCount = 5;
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
      imglogo_;

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
      imgl;

  @override
  void initState() {
    super.initState();
    _pageController.dispose();
    read_data();
    read_zoneAll();
    red_Trans_bill();
    red_TransRe_bill();
    read_GC_rental();
    checkPreferance();
    deall_Trans_select();
  }

  Future<Null> deall_Trans_select() async {
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var Message_ = preferences.getString('Message_ToUser');

    ////////////////------------------------------------------------------>
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = preferences.getString('usercid');
    var qutser = preferences.getString('qutser');

    String url =
        '${MyConstant().domain_chao}/D_tran_select.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      // if (result.toString() == 'true') {
      // } else if (result.toString() == 'false') {
      // } else {}
    } catch (e) {}
  }

  Future<Null> checkPreferance() async {
    DateTime currentDate = DateTime.now();

    // Format the date as 'YYYY-MM-DD'
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    String new_Url = MyConstant().domain_chao;
    //  '${Uri.base.toString().substring(0, Uri.base.toString().length - 8)}/chao_api';

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? DateLogin;
    setState(() {
      Ser_re = preferences.getString('renTalSer');
      renTal_user = preferences.getString('renTalSer');
      ren_name = preferences.getString('renTalName');
      custno_ = preferences.getString('custno');
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
  }

  var nFormat = NumberFormat("#,##0.00", "en_US");
  List<TransBillModel> _TransBillModels = [];
  List<TransReBillHistoryModel> _TransReBillHistoryModels = [];
  List<TransReBillModel> _TransReBillModels = [];
  List<RenTalModel> renTalModels = [];

  List<TeNantModel> teNantModels = [];
  List<ZoneModel> zoneModels = [];

  Future<Null> read_GC_rental() async {
    if (renTalModels.isNotEmpty) {
      renTalModels.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String new_Url = MyConstant().domain_chao;
    //   '${Uri.base.toString().substring(0, Uri.base.toString().length -8)}/chao_api';
    //https://dzentric.com/chao_perty/chao_api/GC_rental_setring.php?isAdd=true&ren=50
    String url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
    //renTal_name = preferences.getString('renTalName');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
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

    var provider_PayHis = Provider.of<PayHisProvider>(context, listen: false);
    provider_PayHis.Foder(foder);
    // print('name>>>>>  $renname');
  }

/////////////////////////////////////////////////////////////////////////////////
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
      // print(result);
      if (result.toString() != 'null') {
        setState(() {
          _TransBillModels.clear();
        });
        for (var map in result) {
          TransBillModel _TransBillModel = TransBillModel.fromJson(map);
          var menu =
              double.parse(_TransBillModel.total.toString()).toStringAsFixed(2);
          // print('menumenumenu>>>>>>>>>$menu');
          setState(() {
            // _TransBillModels.add(_TransBillModel);
            if (_TransBillModel.invoice == null) {
              if (menu != '0.00') {
                _TransBillModels.add(_TransBillModel);
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

          var provider =
              Provider.of<WaitPayListProvider>(context, listen: false);
          WaitHome statement = WaitHome(
              title: "${_TransBillModels[index].expname}",
              date: "${_TransBillModels[index].date}",
              total: "${_TransBillModels[index].total}",
              month: "${month[dat]}",
              index: index,
              value: false);
          provider.add_wh(statement);
          provider.All_Amount(index);
          // print("${_TransBillModels[index].expname}");
          // print("${_TransBillModels[index].date}");
          // print("${_TransBillModels[index].total}");
          // print("${month[dat]}");
          // print(index);
        }
      }
    } catch (e) {}
  }

///////////////////////////////////////////////////////////////////////////////////////
  Future<Null> red_TransRe_bill() async {
    if (_TransReBillModels.length != 0) {
      setState(() {
        _TransReBillModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // var ren = 65;
    // var ciddoc = 'LE000063';
    // var qutser = '';
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('user');
    var ciddoc = preferences.getString('ciddoc');
    var qutser = preferences.getString('qutser');

    String url =
        '${MyConstant().domain}/GC_bill_pay.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);
          setState(() {
            _TransReBillModels.add(transReBillModel);

            // _TransReBillModels.forEach((element) {
            //   var provider = Provider.of<PayHisProviser>(context, listen: false);
            //   RebillModel data = RebillModel(
            //       doctax: element.doctax,
            //       docno: element.docno,
            //       daterec: element.daterec,
            //       dtype: element.dtype,
            //       expname: element.expname,
            //       total_sum: element.total);
            //   provider.add_rebill(data);
            // });
          });
        }
        // print('result ${_TransReBillModels.length}');
      }
    } catch (e) {}
  }

////////////////////////////////////////////////////////////////////////////////////////
  Future<Null> red_Trans_select(index) async {
    if (_TransReBillHistoryModels.length != 0) {
      setState(() {
        _TransReBillHistoryModels.clear();

        // sum_disamt = 0;
        // sum_disp = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // var ren = preferences.getString('renTalSer');
    // var user = preferences.getString('ser');
    // var ren = 65;
    // // var ciddoc = widget.Get_Value_cid;
    // // var qutser = widget.Get_Value_NameShop_index;
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('user');
    var ciddoc = preferences.getString('ciddoc');
    var qutser = preferences.getString('qutser');
    var docnoin = _TransReBillModels[index].docno;

    String url =
        '${MyConstant().domain}/GC_history_bill_pay.php?isAdd=true&ren=$ren&ciddoc=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillHistoryModel _TransReBillHistoryModel =
              TransReBillHistoryModel.fromJson(map);

          // var sum_pvatx = double.parse(_TransReBillHistoryModel.pvat!);
          // var sum_vatx = double.parse(_TransReBillHistoryModel.vat!);
          // var sum_whtx = double.parse(_TransReBillHistoryModel.wht!);
          // var sum_amtx = double.parse(_TransReBillHistoryModel.total!);
          // // var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          // // var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          // var numinvoiceent = _TransReBillHistoryModel.docno;
          setState(() {
            _TransReBillHistoryModels.add(_TransReBillHistoryModel);
          });
        }
      }
      // setState(() {
      //   red_Invoice();
      // });
      // print('${_TransReBillHistoryModels.length}');
      // print('${_TransReBillHistoryModels.length}');
      // print('${_TransReBillHistoryModels.length}');
    } catch (e) {}
    // print('${_TransReBillHistoryModels.length}');
  }

////////////////////////////////////////////////////////////////////////////////
  Future<Null> read_zoneAll() async {
    if (zoneModels.length != 0) {
      setState(() {
        zoneModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('user');
    var ciddoc = preferences.getString('ciddoc');
    var qutser = preferences.getString('qutser');
    // var ren = preferences.getString('renTalSer');
    //  var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;
    // var qutser = widget.Get_Value_NameShop_index;
    // var ren = '65';

    String url = '${MyConstant().domain}/GC_zoneAll.php?isAdd=true&ren=$ren';
    // 'https://dzentric.com/chaoperty_user/chao_api_user/GC_zoneAll.php?isAdd=true&ren=65';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          ZoneModel zoneModel = ZoneModel.fromJson(map);
          setState(() {
            zoneModels.add(zoneModel);
          });
        }
      }
    } catch (e) {}
  }

///////////////////////////////////////////////////////////////////////////////////
  Future<Null> read_data() async {
    if (teNantModels.length != 0) {
      setState(() {
        teNantModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    // var ren = preferences.getString('renTalSer');
    //  var ciddoc = widget.Get_Value_cid;
    //var qutser = widget.Get_Value_NameShop_index;
    // var qutser = widget.Get_Value_NameShop_index;
    // var ren = '65';
    // var ciddoc = 'LE000063';
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('user');
    var ciddoc = preferences.getString('ciddoc');
    var qutser = preferences.getString('qutser');

    String url =
        '${MyConstant().domain}/GC_tenantlookAS.php?isAdd=true&ren=$ren&ciddoc=$ciddoc';
    // 'https://dzentric.com/chaoperty_user/chao_api_user/GC_tenantlookAS.php?isAdd=true&ren=65&ciddoc=LE000063';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          setState(() {
            teNantModels.add(teNantModel);

            // print('teNantModels${teNantModels.length}');
            // print('zoneModels${zoneModels.length}');
          });
        }
      }
    } catch (e) {}
  }

  final navigatorkey = GlobalKey<NavigatorState>();

  void navigateToMeter() {
    Navigator.pop(context);
    // navigatorkey.currentState?.pushNamed('/metercheck_screen');
  }

  void updateMessage(int newMessage) async {
    if (newMessage == 0) {
      // Navigator.pop(context);
      // Navigator.push(context,
      //     MaterialPageRoute(builder: (BuildContext context) {
      //   return const SelectScreen();
      // }));
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var custno_ = preferences.getString('custno');
      MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => SelectCid(custno_s: custno_),
      );
      Navigator.pushAndRemoveUntil(context, route, (route) => false);
      //
    } else {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
      Navigator.pushAndRemoveUntil(context, route, (route) => false);
    }
  }

  List<Map<String, dynamic>> rowdetail = [];
  Map rows = {};
  int tap = 0;
  int numrow = 0;

  _importFromExcel() async {
    // ByteData data = await rootBundle.load('/myDataBank.xlsx');
    // var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    // var excel = Excel.decodeBytes(bytes);
    // int index = 0;

    // for (var table in excel.tables.keys) {
    //   // print(table); //sheet Name
    //   // print(excel.tables[table]?.maxCols);
    //   // print(excel.tables[table]?.maxRows);
    //   for (var row in excel.tables[table]!.rows) {
    //     if ("${row[3]!.value}" != "price") {
    //       String r0 = ("${row[1]!.value}");
    //       //2023-07-10T00:17:56.000

    //       // String date = r0.substring(0, 10);
    //       String dt = r0.length >= 10 ? r0.substring(0, 10) : "";
    //       // rowdetail.add(
    //       //     {'datex': '${date}', 'timex': '${row[1]!.value}', 'c': '${row[2]!.value}', 'total': '${row[3]!.value}'});
    //       var ser = '${row[0]!.value}';
    //       var date = '${dt}';
    //       var time = '${row[2]!.value}';
    //       var price = '${row[3]!.value}';
    //       var ref1 = '${row[4]!.value}';
    //       var ref2 = '${row[5]!.value}';
    //       var by = '${row[6]!.value}';

    //       // print("$ref1  $date ");
    //       String url =
    //           'http://127.0.0.1/dbtest2.php?isAdd=true&ser=$ser&date=$date&time=$time&price=$price&ref1=$ref1&ref2=$ref2&_by=$by';
    //       // String url = '${MyConstant().domain_}/UP_Test_excell.php?isAdd=true&datex=$datex&timex=$timex&docno=$docno&total=$total';
    //       // String url =
    //       //     '${MyConstant().domain_}/UP_Test_excell.php?isAdd=true&ser=$ser&date=$date&time=$time&price=$price&ref1=$ref1&ref2=$ref2&by=$by';

    //       try {
    //         var response = await http.get(Uri.parse(url));

    //         var result = json.decode(response.body);

    //         if (result.toString() == 'true') {
    //           // print('object');
    //         } else {}
    //       } catch (e) {}
    //       index++;
    //       // print(index);
    //     }
    //   }
    // }
  }

//\\192.168.1.152\xampp\htdocs\chao_api_user\UP_Test_excell.php
  // Future<Null> UPtest(docno) async {
  //   // String url = 'http://192.168.1.152/chao_api_user/UP_Test_excell.php?rowdetail=50';
  //   String url = 'http://127.0.0.1/index.php?&docno=$docno';
  // String url = '${MyConstant().domain_}/UP_Test_excell.php?isAdd=true&rowdetail=$rowdetail';
  //   //&datex=$datex&timex=$timex&docno=$docno&total=$total
  //   // print(url);
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);

  //     if (result.toString() == 'true') {
  //       print('object');
  //     } else {}
  //   } catch (e) {}
  // }

  final List<Widget> bottomBarPages = [
    Payscreen(),
    const HomeScreen(),
    const PersonalInfoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 6,
              child: Row(
                children: [
                  (imgl == null || imgl.toString() == '')
                      ? const SizedBox()
                      : InkWell(
                          child: CircleAvatar(
                            radius: 15.0,
                            backgroundImage: NetworkImage(imglogo_.toString()),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: AutoSizeText(
                      minFontSize: 18,
                      maxFontSize: 20,
                      maxLines: 1,
                      '$ren_name',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          // fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontWeight_.Fonts_T),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: IconButton(
                        onPressed: () async {
                          selectCid(context);
                        },
                        icon: const Icon(
                          Icons.badge_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () async {
                          logOut(context);
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
        backgroundColor:
            const Color(0xFF102456), // Color.fromARGB(255, 184, 198, 133),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
            bottomBarPages.length, (index) => bottomBarPages[index]),
      ),
      // extendBody: true,
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // bottomNavigationBar: AnimatedNotchBottomBar(
      //   notchBottomBarController: _controller,
      //   kIconSize: 20,
      //   kBottomRadius: 20,
      //   color: Colors.white,
      //   showLabel: false,
      //   notchColor: Colors.lime.shade700,
      //   removeMargins: false,
      //   bottomBarWidth: 500,
      //   durationInMilliSeconds: 300,
      //   itemLabelStyle: const TextStyle(fontSize: 10),
      //   bottomBarItems: const [
      //     BottomBarItem(
      //       inActiveItem:
      //           Icon(Icons.currency_exchange_outlined, color: Colors.black),
      //       activeItem:
      //           Icon(Icons.currency_exchange_outlined, color: Colors.white),
      //       itemLabel: 'ชำระ',
      //     ),
      //     BottomBarItem(
      //       inActiveItem: Icon(Icons.home_filled, color: Colors.black),
      //       activeItem: Icon(Icons.home_filled, color: Colors.white),
      //       itemLabel: 'Home',
      //     ),
      //     BottomBarItem(
      //       inActiveItem:
      //           Icon(Icons.account_circle_outlined, color: Colors.black),
      //       activeItem:
      //           Icon(Icons.account_circle_outlined, color: Colors.white),
      //       itemLabel: 'สัญญาเช่า',
      //     ),
      //   ],
      //   onTap: (index) {
      //     _pageController.jumpToPage(index);
      //     setState(() => deall_Trans_select());
      //   },
      // ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: PageStorage(
  //         bucket: bucket,
  //         child: Navigator(
  //           key: navigatorkey,
  //           onGenerateRoute: (settings) {
  //             final name = settings.name;

  //             switch (name) {
  //               case '/':
  //                 return MaterialPageRoute(builder: (ctx) {
  //                   return HomeScreen(
  //                     navigateToMeter: updateMessage,
  //                   );
  //                 });
  //               case '/metercheck_screen':
  //                 return MaterialPageRoute(builder: (ctx) {
  //                   return const MeterCheckScreen();
  //                 });
  //               // case '/pay_screen':
  //               //   return MaterialPageRoute(builder: (ctx) {
  //               //     return const Payscreen();
  //               //   });
  //               case '/payhistory_screen':
  //                 return MaterialPageRoute(builder: (ctx) {
  //                   return const PayHistoryScreen();
  //                 });
  //               case '/personalinfo_screen':
  //                 return MaterialPageRoute(builder: (ctx) {
  //                   return const PersonalInfoScreen();
  //                 });
  //               case '/rentalarea_screen':
  //                 return MaterialPageRoute(builder: (ctx) {
  //                   return const RentalAreaScreen();
  //                 });
  //               case '/login': // Add the login route
  //                 return MaterialPageRoute(builder: (context) {
  //                   return const LoginScreen(); // Replace with your LoginPage widget
  //                 });
  //               default:
  //             }
  //           },
  //         )),
  //     floatingActionButton: SizedBox(
  //       width: 80,
  //       height: 80,
  //       child: FloatingActionButton(
  //         onPressed: () {
  //           setState(() {
  //             navigatorkey.currentState?.pushNamed('/');
  //             tap = 0;
  //             _importFromExcel();
  //           });
  //           // setState(() {
  //           //   CurrentScreen = Screen.home;
  //           // });
  //         },
  //         elevation: 10,
  //         backgroundColor:
  //             Colors.lime.shade700, //const Color.fromRGBO(196, 199, 135, 1),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(
  //               Icons.home_outlined,
  //               size: 35,
  //               color: tap == 0
  //                   ? Colors.white
  //                   : const Color.fromRGBO(100, 108, 108, 1),
  //             ),
  //             // Text(
  //             //   // (rowdetail.length < 1) ? 'bbb' :
  //             //   "HOME",
  //             //   style: TextStyle(
  //             //     fontSize: 15,
  //             //     color: tap == 0
  //             //         ? Colors.white
  //             //         : Color.fromRGBO(100, 108, 108, 1),
  //             //     fontWeight: FontWeight.bold,
  //             //     fontFamily: FontWeight_.Fonts_T,
  //             //   ),
  //             // ),
  //           ],
  //         ),
  //       ),
  //     ),
  //     floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
  //     bottomNavigationBar:

  //     BottomAppBar(
  //       child: SizedBox(
  //         height: 70,
  //         child: Row(
  //           children: <Widget>[
  //             Expanded(
  //               flex: 2,
  //               child: MaterialButton(
  //                 onPressed: () {
  //                   setState(() {
  //                     navigatorkey.currentState
  //                         ?.pushNamed('/personalinfo_screen');
  //                     tap = 1;
  //                   });
  //                 },
  //                 minWidth: 40,
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Icon(Icons.account_circle_outlined,
  //                         size: 40,
  //                         color: tap == 1
  //                             ? const Color.fromARGB(255, 184, 198, 133)
  //                             : const Color.fromRGBO(100, 108, 108, 1)),
  //                     Text(
  //                       "ข้อมูลส่วนตัว",
  //                       style: TextStyle(
  //                           color: tap == 1
  //                               ? const Color.fromARGB(255, 184, 198, 133)
  //                               : Color.fromRGBO(100, 108, 108, 1),
  //                           fontFamily: Font_.Fonts_T,
  //                           fontSize: 15),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             Expanded(flex: 1, child: Container()),
  //             Expanded(
  //               flex: 2,
  //               child: MaterialButton(
  //                 onPressed: () {
  //                   setState(() {
  //                     navigatorkey.currentState
  //                         ?.pushNamed('/payhistory_screen');
  //                     tap = 2;
  //                   });
  //                 },
  //                 minWidth: 40,
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Icon(Icons.article_outlined,
  //                         size: 40,
  //                         color: tap == 2
  //                             ? const Color.fromARGB(255, 184, 198, 133)
  //                             : const Color.fromRGBO(100, 108, 108, 1)),
  //                     Text(
  //                       "ประวัติชำระ",
  //                       style: TextStyle(
  //                           color: tap == 2
  //                               ? Color.fromARGB(255, 184, 198, 133)
  //                               : const Color.fromRGBO(100, 108, 108, 1),
  //                           fontFamily: Font_.Fonts_T,
  //                           fontSize: 15),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
                            // widget.navigateToMeter(1);
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            await preferences.clear();
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
}
