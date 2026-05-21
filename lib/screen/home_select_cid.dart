// ignore_for_file: deprecated_member_use

import 'dart:convert';
// import 'dart:ui' as ui;
// import 'dart:ui_web' as ui_web;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:webview_flutter/webview_flutter.dart';

import '../Constant/Myconstant.dart';
// import '../INSERT_Log/Insert_log.dart';
import '../Model/GetArea_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTranBill_model.dart';
import '../Model/GetZone_Model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

// import '../Responsive/responsive.dart';
import '../color.dart';
import 'buttonnavbar.dart';
import 'loginscreen.dart';

class SelectCid extends StatefulWidget {
  final custno_s;
  const SelectCid({super.key, this.custno_s});

  @override
  State<SelectCid> createState() => _SelectCidState();
}

class _SelectCidState extends State<SelectCid> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  DateTime datex = DateTime.now();
  List<TeNantModel> teNantModels = [];
  List<TransBillModel> _TransBillModels = [];
  List<ZoneModel> zoneModels = [];

  List<AreaModel> areaModels = [];
  String? renTal_user,
      renTal_name,
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
      cus_lintid;

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
      imgbag_;
  List<RenTalModel> renTalModels = [];
  String? Ser_re;
  final _formKey = GlobalKey<FormState>();
  final Form_username = TextEditingController();
  final Form_password = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkPreferance();
    read_GC_rental();
    // read_GC_areaSelect();
    read_GC_tenant();
  }

  Future<Null> checkPreferance() async {
    DateTime currentDate = DateTime.now();
    String new_Url = MyConstant().domain_chao;
    // '${Uri.base.toString().substring(0, Uri.base.toString().length - 8)}/chao_api';

    //print('>>>>>>>>>>>>>$new_Url');
    // Format the date as 'YYYY-MM-DD'
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? DateLogin;
    setState(() {
      Ser_re = preferences.getString('renTalSer');
      renTal_user = preferences.getString('renTalSer');
      renTal_name = preferences.getString('renTalName');
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
    });
    if (cus_photo != null ||
        cus_photo.toString() != '' ||
        cus_photo.toString() != 'null') {
      cus_imglogo_ = '$new_Url/files/$cus_foder/contract/$cus_photo';
    }
    // if (DateLogin.toString().trim() != formattedDate.toString().trim()) {
    //   setState(() {
    //     preferences.setString('Date_Login', formattedDate);
    //   });
    //   Insert_log.Insert_logs('ล็อคอิน', 'เข้าสู่ระบบ $custno_');
    // } else {
    //   // //print('result Date_Login');
    // }

    // showDialog<void>(
    //   context: context,
    //   barrierDismissible: false, // user must tap button!
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text(
    //         '${Uri.base.toString()}',
    //         style: TextStyle(
    //           fontFamily: Font_.Fonts_T,
    //         ),
    //       ),
    //       actions: <Widget>[
    //         TextButton(
    //           child: const Text('ปิด'),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  Future<Null> read_GC_areaSelect() async {
    if (areaModels.length != 0) {
      setState(() {
        areaModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zoneSer');

    String url = zone == null
        ? '${MyConstant().domain_chao}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
        : zone == '0'
            ? '${MyConstant().domain_chao}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
            : '${MyConstant().domain_chao}/GC_area.php?isAdd=true&ren=$ren&zone=$zone';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        for (var map in result) {
          AreaModel areaModel = AreaModel.fromJson(map);
          if (areaModel.quantity == null) {
            setState(() {
              areaModels.add(areaModel);
            });
          }
        }
      } else {
        setState(() {
          if (areaModels.isEmpty) {
            preferences.remove('zoneSer');
            preferences.remove('zonesName');
          }
        });
      }
    } catch (e) {}
  }

  Future<Null> read_GC_rental() async {
    if (renTalModels.isNotEmpty) {
      renTalModels.clear();
    }

    dynamic Url_ = 'https://chaoperties.com/user/#/';
    String new_Url =
        MyConstant().domain_chao; // 'https://chaoperties.com/chao_api';
    String new_Url2 = MyConstant().domain_chao_img; //'https://chaoperties.com';
    // String new_Url =
    //     '${Uri.base.toString().substring(0, Uri.base.toString().length - 8)}/chao_api';
    // String new_Url2 =
    //     '${Uri.base.toString().substring(0, Uri.base.toString().length - 8)}';
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
            imgl = renTalModel.imglogo;
            imglogo_ =
                '$new_Url/files/$foder/logo/${renTalModel.imglogo!.trim()}';
            imgbag_ = '$new_Url2/files/pngegg2.png';
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

  Future<Null> read_GC_tenant() async {
    if (teNantModels.isNotEmpty) {
      setState(() {
        teNantModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    double total = 0.00;
    var ren = preferences.getString('renTalSer');
    var custno_S = preferences.getString('custno');
    String url =
        '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&custno=$custno_S';
    //  '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          if (teNantModel.cid != null ||
              teNantModel.cid.toString() != '' ||
              teNantModel.cid.toString() != 'null') {
            setState(() {
              teNantModels.add(teNantModel);
            });
          }
        }
      }
    } catch (e) {
      // showDialog<void>(
      //   context: context,
      //   barrierDismissible: false, // user must tap button!
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: Text(
      //         '$e',
      //         style: TextStyle(
      //           fontFamily: Font_.Fonts_T,
      //         ),
      //       ),
      //       actions: <Widget>[
      //         TextButton(
      //           child: const Text('ปิด'),
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //         ),
      //       ],
      //     );
      //   },
      // );
    }
    red_Trans_bill();
  }

  /////////////////////////////////////////////////////////////////////
  List<String> total_list = [];
  double All_total = 0.00;

  Future<Null> red_Trans_bill() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String to_tal = '';
    double total = 0.00;

    // var ciddoc = preferences.getString('usercid');
    for (int index = 0; index < teNantModels.length; index++) {
      var ciddoc = teNantModels[index].cid;
      String url =
          '${MyConstant().domain}/GC_tran_pays.php?isAdd=true&ren=$ren&ciddoc=$ciddoc';

      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        //  //print('${teNantModels[index].cid}');
        if (result.toString() != 'null') {
          for (var map in result) {
            TransBillModel _TransBillModel = TransBillModel.fromJson(map);
            var menu = double.parse(_TransBillModel.total.toString())
                .toStringAsFixed(2);
            // //print('${_TransBillModel.date}');
            // //print(_TransBillModel.total!);
            if (_TransBillModel.invoice != null) {
              setState(() {
                // _TransBillModels.add(_TransBillModel);

                if (menu != '0.00') {
                  total = (_TransBillModel.total == null)
                      ? total + 0.00
                      : total + double.parse(_TransBillModel.total!);
                  All_total = (_TransBillModel.total == null)
                      ? All_total + 0.00
                      : All_total + double.parse(_TransBillModel.total!);
                }

                // _TransBillModels.add(_TransBillModel);
              });
            }
          }
        }
        setState(() {
          total_list.add(total.toString());
          total = 0.00;
        });
      } catch (e) {}
    }
  }

  support_agent_Widget() {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.hardEdge,
            title: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                color: const Color.fromARGB(255, 184, 198, 133),
                child: const Center(
                  child: Text(
                    "ข้อมูลผู้ให้เช่า",
                    style: TextStyle(
                      fontFamily: FontWeight_.Fonts_T,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            content: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'ข้อมูลผู้ให้เช่า/บริษัท : $bill_name ',
                        style: const TextStyle(
                          color: Colors.black,
                          // fontWeight: FontWeight.bold,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'ที่อยู่ : $bill_addr',
                        style: const TextStyle(
                          color: Colors.black,
                          // fontWeight: FontWeight.bold,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'TAX ID : $bill_tax',
                        style: const TextStyle(
                          color: Colors.black,
                          // fontWeight: FontWeight.bold,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'เบอร์โทร : $bill_tel',
                        style: const TextStyle(
                          color: Colors.black,
                          // fontWeight: FontWeight.bold,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'อีเมล : $bill_email',
                        style: const TextStyle(
                          color: Colors.black,
                          // fontWeight: FontWeight.bold,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              const SizedBox(height: 1),
              const Divider(),
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          width: 150,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                      bottomLeft: Radius.circular(6),
                                      bottomRight: Radius.circular(6)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                          color: Colors
                                              .white, // fontWeight: FontWeight.bold,
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
                      ],
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // //print(
    //     '${Uri.base.toString().substring(0, Uri.base.toString().length - 18)}/chao_perty/chao_api');
    // //print('domain_chao >> ${MyConstant().domain_chao}');
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        // onPressed: () async {
        //   final bytes = await controller.capture();
        //   setState(() {
        //     this.bytes = bytes;
        //   });
        //   final base64String = base64Encode(bytes!);
        //   //print(base64String);
        //   captureAndConvertToBase64(base64String, 'controller', foder);
        // },
        onPressed: () {
          support_agent_Widget();
        },
        foregroundColor: Colors.black54,
        backgroundColor: Colors.black54,
        child: const Icon(
          IconsaxBold.information,
          // Icons.support_agent,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              flex: 10,
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
                      '$renTal_name ',
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
                    IconButton(
                      onPressed: () async {
                        print('$cus_ser $cus_username $cus_password');
                        setState(() {
                          Form_username.text = cus_username!;
                          Form_password.text = cus_password!;
                        });
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
                            title: const Center(
                                child: Text(
                              'Edit Username And Password',
                              // maxLines: 1,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T),
                            )),
                            content: Container(
                              height: 120,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 2, child: Text('Username :')),
                                      Expanded(
                                        flex: 4,
                                        child: TextFormField(
                                          // keyboardType: TextInputType.number,
                                          // showCursor: false, //add this line
                                          // readOnly: true,
                                          controller: Form_username,

                                          cursorColor: Colors.green,
                                          decoration: InputDecoration(
                                              fillColor:
                                                  Colors.white.withOpacity(0.3),
                                              filled: true,
                                              // prefixIcon:
                                              //     const Icon(Icons.person, color: Colors.black),
                                              // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(15),
                                                  topLeft: Radius.circular(15),
                                                  bottomRight:
                                                      Radius.circular(15),
                                                  bottomLeft:
                                                      Radius.circular(15),
                                                ),
                                                borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(15),
                                                  topLeft: Radius.circular(15),
                                                  bottomRight:
                                                      Radius.circular(15),
                                                  bottomLeft:
                                                      Radius.circular(15),
                                                ),
                                                borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              // labelText: 'ระบุชื่อร้านค้า',
                                              labelStyle: const TextStyle(
                                                  color: Colors.black54,

                                                  // fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T
                                                  //fontSize: 10.0
                                                  )),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 2, child: Text('Password :')),
                                      Expanded(
                                        flex: 4,
                                        child: TextFormField(
                                          // keyboardType: TextInputType.number,
                                          // showCursor: false, //add this line
                                          // readOnly: true,
                                          obscureText: true,
                                          controller: Form_password,

                                          cursorColor: Colors.green,
                                          decoration: InputDecoration(
                                              fillColor:
                                                  Colors.white.withOpacity(0.3),
                                              filled: true,
                                              // prefixIcon:
                                              //     const Icon(Icons.person, color: Colors.black),
                                              // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(15),
                                                  topLeft: Radius.circular(15),
                                                  bottomRight:
                                                      Radius.circular(15),
                                                  bottomLeft:
                                                      Radius.circular(15),
                                                ),
                                                borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(15),
                                                  topLeft: Radius.circular(15),
                                                  bottomRight:
                                                      Radius.circular(15),
                                                  bottomLeft:
                                                      Radius.circular(15),
                                                ),
                                                borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              // labelText: 'ระบุชื่อร้านค้า',
                                              labelStyle: const TextStyle(
                                                  color: Colors.black54,

                                                  // fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T
                                                  //fontSize: 10.0
                                                  )),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              Column(
                                children: [
                                  // const SizedBox(
                                  //   height: 5.0,
                                  // ),
                                  // const Divider(
                                  //   color: Colors.grey,
                                  //   height: 4.0,
                                  // ),
                                  // const SizedBox(
                                  //   height: 5.0,
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Text('หากยืนยันจะออกระบบ'),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: 100,
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10)),
                                            ),
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextButton(
                                              onPressed: () async {
                                                print(
                                                    '$cus_ser ${Form_username.text} ${Form_password.text}');
                                                var editser = cus_ser;
                                                var edituser =
                                                    Form_username.text;
                                                var editpass =
                                                    Form_password.text;

                                                String url =
                                                    '${MyConstant().domain_chao}/U_user_Edit.php?isAdd=true&editser=$editser&edituser=$edituser&editpass=$editpass';

                                                try {
                                                  var response = await http
                                                      .get(Uri.parse(url));

                                                  var result = json
                                                      .decode(response.body);
                                                  print(result);
                                                  if (result.toString() ==
                                                      'true') {
                                                    SharedPreferences
                                                        preferences =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    await preferences.clear();
                                                    MaterialPageRoute route =
                                                        MaterialPageRoute(
                                                      builder: (context) =>
                                                          const LoginScreen(),
                                                    );
                                                    Navigator
                                                        .pushAndRemoveUntil(
                                                            context,
                                                            route,
                                                            (route) => false);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content:
                                                              Text('ผิดพลาด')),
                                                    );
                                                  }
                                                } catch (e) {}
                                                // SharedPreferences preferences =
                                                //     await SharedPreferences
                                                //         .getInstance();
                                                // await preferences.clear();
                                                // MaterialPageRoute route =
                                                //     MaterialPageRoute(
                                                //   builder: (context) =>
                                                //       const LoginScreen(),
                                                // );
                                                // Navigator.pushAndRemoveUntil(
                                                //     context,
                                                //     route,
                                                //     (route) => false);
                                              },
                                              child: const Text(
                                                'ยืนยัน',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 100,
                                                decoration: const BoxDecoration(
                                                  color: Colors.redAccent,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft: Radius
                                                              .circular(10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10)),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, 'OK'),
                                                  child: const Text(
                                                    'ยกเลิก',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: FontWeight_
                                                            .Fonts_T),
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
                      },
                      icon: const Icon(
                        Icons.manage_accounts,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )),
            Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // IconButton(
                    //   onPressed: () async {
                    //     String uri =
                    //         'https://dzentric.com/chaoperty_user/#/userWeb=1,username=$cus_username,passwd=$cus_password,serrental=$renTal_user,userid=$cus_lintid';

                    //     final Uri url = Uri.parse(uri);
                    //     if (!await launchUrl(
                    //       url,
                    //       mode: LaunchMode.externalApplication,
                    //     )) {
                    //       throw Exception('Could not launch $url');
                    //     }
                    //   },
                    //   icon: Icon(
                    //     Icons.language,
                    //     color: Colors.black,
                    //   ),
                    // ),
                    IconButton(
                      onPressed: () async {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10)),
                                            ),
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextButton(
                                              onPressed: () async {
                                                SharedPreferences preferences =
                                                    await SharedPreferences
                                                        .getInstance();
                                                await preferences.clear();
                                                MaterialPageRoute route =
                                                    MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoginScreen(),
                                                );
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    route,
                                                    (route) => false);
                                              },
                                              child: const Text(
                                                'ยืนยัน',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 100,
                                                decoration: const BoxDecoration(
                                                  color: Colors.redAccent,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft: Radius
                                                              .circular(10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10)),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, 'OK'),
                                                  child: const Text(
                                                    'ยกเลิก',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: FontWeight_
                                                            .Fonts_T),
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
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )),
          ],
        ),
        backgroundColor:
            const Color(0xFF102456), // Color.fromARGB(255, 184, 198, 133),
      ),
      body: Container(
        color: bgcolor,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Row(
              children: [
                Expanded(
                    flex: 3,
                    child: (cus_photo == null ||
                            cus_photo.toString() == '' ||
                            cus_photo.toString() == 'null')
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: MediaQuery.of(context).size.width * 0.3,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(cus_imglogo_.toString()),
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                          )),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            flex: 2,
                            child: AutoSizeText(
                              minFontSize: 9,
                              maxFontSize: 18,
                              maxLines: 1,
                              'รหัสสมาชิก',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  // fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: AutoSizeText(
                              minFontSize: 9,
                              maxFontSize: 18,
                              maxLines: 1,
                              ' $custno_',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  // fontSize: 20,
                                  color: Colors.black,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 2,
                            child: AutoSizeText(
                              minFontSize: 9,
                              maxFontSize: 18,
                              maxLines: 1,
                              'ชื่อ - สกุล',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  // fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: AutoSizeText(
                              minFontSize: 9,
                              maxFontSize: 18,
                              maxLines: 1,
                              ' $cus_cname',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  // fontSize: 20,
                                  color: Colors.black,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 2,
                            child: AutoSizeText(
                              minFontSize: 9,
                              maxFontSize: 18,
                              maxLines: 1,
                              'Gmail',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  // fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: AutoSizeText(
                              minFontSize: 9,
                              maxFontSize: 18,
                              maxLines: 1,
                              ' $cus_email',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  // fontSize: 20,
                                  color: Colors.black,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 2,
                            child: AutoSizeText(
                              minFontSize: 9,
                              maxFontSize: 18,
                              maxLines: 1,
                              'เบอร์โทร',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  // fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: AutoSizeText(
                              minFontSize: 9,
                              maxFontSize: 18,
                              maxLines: 1,
                              ' $cus_tel',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  // fontSize: 20,
                                  color: Colors.black,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 2,
                            child: AutoSizeText(
                              minFontSize: 9,
                              maxFontSize: 18,
                              maxLines: 1,
                              'Username',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  // fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: AutoSizeText(
                              minFontSize: 9,
                              maxFontSize: 18,
                              maxLines: 1,
                              ' $cus_username',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  // fontSize: 20,
                                  color: Colors.black,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
            //   child: InkWell(
            //     onTap: () {
            //       // RE_ChoArea_Widget();
            //     },
            //     child: const Align(
            //       alignment: Alignment.centerLeft,
            //       child: Text(
            //         "แก้ไขข้อมูลผู้ใช้",
            //         style: TextStyle(
            //           color: Colors.blueGrey,
            //           fontSize: 15,
            //           decoration: TextDecoration.underline,
            //           fontFamily: Font_.Fonts_T,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            Container(
              color: const Color.fromARGB(255, 184, 198, 133),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        minFontSize: 9,
                        maxFontSize: 18,
                        maxLines: 1,
                        'สัญญาทั้งหมด : ${teNantModels.length}',
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            // fontSize: 20,
                            color: Colors.black,
                            fontFamily: FontWeight_.Fonts_T),
                      ),
                    ),
                    Expanded(
                      child: AutoSizeText(
                        minFontSize: 9,
                        maxFontSize: 18,
                        maxLines: 1,
                        'ยอดรวม : ${nFormat.format(double.parse(All_total.toString()))} บาท',
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            // fontSize: 20,
                            color: Colors.black,
                            fontFamily: FontWeight_.Fonts_T),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.orange[50],
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        minFontSize: 18,
                        maxFontSize: 20,
                        maxLines: 1,
                        'เลือกสัญญา',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            // fontSize: 20,
                            color: Colors.black,
                            fontFamily: FontWeight_.Fonts_T),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.center,
                clipBehavior: Clip.hardEdge,
                constraints: const BoxConstraints(minHeight: 150),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height / 1.7,
                  width: MediaQuery.of(context).size.width,
                  child: Data_Widget(),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<Null> on_Tap(index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ser_teNant = teNantModels[index].quantity;
    setState(() {
      Value_cid = teNantModels[index].docno == null
          ? teNantModels[index].cid == null
              ? ''
              : '${teNantModels[index].cid}'
          : '${teNantModels[index].docno}';

      preferences.setString('usercid', Value_cid!);

      preferences.setString('qutser', ser_teNant!);
      preferences.setString('lncode', teNantModels[index].lncode.toString());
      preferences.setString('zn', teNantModels[index].zn.toString());

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const ButtonNavBar();
      }));
    });
  }

  ScrollController _scrollController1 = ScrollController();
  Data_Widget() {
    return ListView.builder(
        controller: _scrollController1,
        // itemExtent: 50,
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: teNantModels.length,
        itemBuilder: (BuildContext context, int index) {
          // ignore: curly_braces_in_flow_control_structures
          return Column(
            children: [
              // for (int index = 0; index < teNantModels.length; index++)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () async {
                    on_Tap(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          const BoxShadow(
                              color: Colors.black38,
                              blurRadius: 1,
                              spreadRadius: 0,
                              offset: Offset(0, 1))
                        ]),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: [
                        Container(
                          color: const Color.fromARGB(255, 201, 196, 186),
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Text(
                                    teNantModels[index].sname == null
                                        ? teNantModels[index].sname_q == null
                                            ? ''
                                            : '${index + 1}. ชื่อร้านค้า : ${teNantModels[index].sname_q}'
                                        : '${index + 1}. ชื่อร้านค้า : ${teNantModels[index].sname}',
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T,
                                    ),
                                  )),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: teNantModels[index].quantity == '1'
                                        ? datex.isAfter(DateTime.parse(
                                                        '${teNantModels[index].ldate} 00:00:00.000')
                                                    .subtract(const Duration(
                                                        days: 0))) ==
                                                true
                                            ? const Color.fromARGB(
                                                255, 254, 0, 0)
                                            : datex.isAfter(DateTime.parse(
                                                            '${teNantModels[index].ldate} 00:00:00.000')
                                                        .subtract(
                                                            const Duration(
                                                                days: 30))) ==
                                                    true
                                                ? Colors.amber
                                                : Colors.green
                                        : teNantModels[index].quantity == '2'
                                            ? Colors.blue
                                            : teNantModels[index].quantity ==
                                                    '3'
                                                ? Colors.blue.shade100
                                                : Colors.blueGrey.shade50,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                    // border: Border.all(
                                    //     color: Colors.grey, width: 1),
                                  ),
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    teNantModels[index].quantity == '1'
                                        ? datex.isAfter(DateTime.parse(
                                                        '${teNantModels[index].ldate} 00:00:00.000')
                                                    .subtract(const Duration(
                                                        days: 0))) ==
                                                true
                                            ? 'สถานะ : หมดสัญญา'
                                            : datex.isAfter(DateTime.parse(
                                                            '${teNantModels[index].ldate} 00:00:00.000')
                                                        .subtract(
                                                            const Duration(
                                                                days: 30))) ==
                                                    true
                                                ? 'สถานะ : ใกล้หมดสัญญา'
                                                : 'สถานะ : เช่าอยู่'
                                        : teNantModels[index].quantity == '2'
                                            ? 'สถานะ : เสนอราคา'
                                            : teNantModels[index].quantity ==
                                                    '3'
                                                ? 'สถานะ : เสนอราคา(มัดจำ)'
                                                : 'สถานะ : ว่าง',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          // height: 135,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("pngegg2.png"),
                              // NetworkImage(imgbag_
                              //     .toString()), //AssetImage("image/pngegg2.png"),.
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Container(
                                      color: Colors.white,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Center(
                                              child: Container(
                                            height: 100,
                                            width: 100,
                                            child: SfBarcodeGenerator(
                                              value: teNantModels[index]
                                                          .docno ==
                                                      null
                                                  ? teNantModels[index].cid ==
                                                          null
                                                      ? ''
                                                      : '${teNantModels[index].cid}'
                                                  : '${teNantModels[index].docno}',
                                              symbology: QRCode(),
                                              showValue: false,
                                            ),
                                          )), // ),
                                          Text(
                                            teNantModels[index].docno == null
                                                ? teNantModels[index].cid ==
                                                        null
                                                    ? ''
                                                    : '${teNantModels[index].cid}'
                                                : '${teNantModels[index].docno}',
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(4, 8, 0, 8),
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'ชื่อผู้ติดต่อ',
                                            maxLines: 1,
                                            style: TextStyle(
                                              // fontSize: 9.0,
                                              color: Colors.black,
                                              //fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T,
                                            ),
                                          ),
                                          Text(
                                            teNantModels[index].cname == null
                                                ? teNantModels[index].cname_q ==
                                                        null
                                                    ? ''
                                                    : '${teNantModels[index].cname_q}'
                                                : '${teNantModels[index].cname}',
                                            maxLines: 1,
                                            style: const TextStyle(
                                              // fontSize: 11.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T,
                                            ),
                                          ),
                                          const Text(
                                            'ชื่อร้านค้า',
                                            maxLines: 1,
                                            style: TextStyle(
                                              // fontSize: 9.0,
                                              color: Colors.black,
                                              // fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T,
                                            ),
                                          ),
                                          Text(
                                            teNantModels[index].docno == null
                                                ? teNantModels[index].cid ==
                                                        null
                                                    ? ''
                                                    : '${teNantModels[index].stype}'
                                                : '${teNantModels[index].stype_q}',
                                            maxLines: 1,
                                            style: const TextStyle(
                                              // fontSize: 11.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T,
                                            ),
                                          ),
                                          Text(
                                            'พื้นที่ : ${teNantModels[index].lncode}',
                                            maxLines: 1,
                                            style: const TextStyle(
                                              // fontSize: 9.0,
                                              color: Colors.black,
                                              // fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T,
                                            ),
                                          ),
                                          // Text(
                                          //   'โซน : ${teNantModels[index].zn}',
                                          //   maxLines: 1,
                                          //   style: const TextStyle(
                                          //     color: Colors.black,
                                          //     // fontWeight: FontWeight.bold,
                                          //     fontFamily: Font_.Fonts_T,
                                          //   ),
                                          // ),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'โซน : ${teNantModels[index].zn}',
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    // fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: total_list.length !=
                                                        teNantModels.length
                                                    ? const SizedBox()
                                                    : RichText(
                                                        textAlign:
                                                            TextAlign.end,
                                                        text: TextSpan(
                                                          text:
                                                              "${nFormat.format(double.parse(total_list[index].toString()))}",
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.red,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T,
                                                          ),
                                                          children: <TextSpan>[
                                                            const TextSpan(
                                                              text: ' บาท',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                // fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Positioned(
                                  //     bottom: 5,
                                  //     right: 5,
                                  //     child: Container(
                                  //       decoration: BoxDecoration(
                                  //         color: Colors.black.withOpacity(0.5),
                                  //         shape: BoxShape.circle,
                                  //       ),
                                  //       child: RichText(
                                  //         text: TextSpan(
                                  //           text: total_list.length !=
                                  //                   teNantModels.length
                                  //               ? ''
                                  //               : "${nFormat.format(double.parse(total_list[index].toString()))}",
                                  //           style: TextStyle(
                                  //             color: Colors.red,
                                  //             fontFamily: Font_.Fonts_T,
                                  //           ),
                                  //           children: <TextSpan>[
                                  //             TextSpan(
                                  //               text: ' บาท',
                                  //               style: const TextStyle(
                                  //                 color: Colors.black,
                                  //                 // fontWeight: FontWeight.bold,
                                  //                 fontFamily: Font_.Fonts_T,
                                  //               ),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //     )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Row(
                        //         children: [
                        //           Text("ชื่อผู้ติดต่อ : ",
                        //               style: TextStyle(
                        //                 fontWeight: FontWeight.bold,
                        //                 fontFamily: FontWeight_.Fonts_T,
                        //               )),
                        //           Text(
                        //             teNantModels[index].cname == null
                        //                 ? teNantModels[index].cname_q == null
                        //                     ? ''
                        //                     : '${teNantModels[index].cname_q}'
                        //                 : '${teNantModels[index].cname}',
                        //             style: const TextStyle(
                        //               color: Colors.black,
                        //               fontFamily: Font_.Fonts_T,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       // Row(
                        //       //   mainAxisAlignment: MainAxisAlignment.start,
                        //       //   children: [
                        //       //     Text("รหัสพื้นที่ : ",
                        //       //         style: TextStyle(
                        //       //           fontWeight: FontWeight.bold,
                        //       //           fontFamily: FontWeight_.Fonts_T,
                        //       //         )),
                        //       //     Text(
                        //       //       teNantModels[index].ln_c == null
                        //       //           ? teNantModels[index].ln_q == null
                        //       //               ? ''
                        //       //               : '${teNantModels[index].ln_q}'
                        //       //           : '${teNantModels[index].ln_c}',
                        //       //       style: const TextStyle(
                        //       //         color: Colors.black,
                        //       //         fontFamily: Font_.Fonts_T,
                        //       //       ),
                        //       //     ),
                        //       //   ],
                        //       // ),
                        //       // Row(
                        //       //   mainAxisAlignment: MainAxisAlignment.start,
                        //       //   children: [
                        //       //     Container(
                        //       //       margin: EdgeInsets.only(right: 8.0),
                        //       //       child:
                        //       Row(
                        //         children: [
                        //           Text("เลขสัญญา : ",
                        //               style: TextStyle(
                        //                 fontWeight: FontWeight.bold,
                        //                 fontFamily: FontWeight_.Fonts_T,
                        //               )),
                        //           Text(
                        //             teNantModels[index].docno == null
                        //                 ? teNantModels[index].cid == null
                        //                     ? ''
                        //                     : '${teNantModels[index].cid}'
                        //                 : '${teNantModels[index].docno}',
                        //             style: const TextStyle(
                        //               color: Colors.black,
                        //               fontFamily: Font_.Fonts_T,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       //     ),
                        //       //     Container(
                        //       //       child: Row(
                        //       //         children: [
                        //       //           Text("โซน : ",
                        //       //               style: TextStyle(
                        //       //                 fontWeight: FontWeight.bold,
                        //       //                 fontFamily: FontWeight_.Fonts_T,
                        //       //               )),
                        //       //           Text(
                        //       //             '${teNantModels[index].zn}',
                        //       //             style: TextStyle(
                        //       //               color: Colors.black,
                        //       //               fontFamily: Font_.Fonts_T,
                        //       //             ),
                        //       //           ),
                        //       //         ],
                        //       //       ),
                        //       //     ),
                        //       //   ],
                        //       // ),
                        //       // Row(
                        //       //   children: [
                        //       //     Text("โซน : ",
                        //       //         style: TextStyle(
                        //       //           fontWeight: FontWeight.bold,
                        //       //           fontFamily: FontWeight_.Fonts_T,
                        //       //         )),
                        //       //     Text(
                        //       //       '${teNantModels[index].zn}',
                        //       //       style: TextStyle(
                        //       //         color: Colors.black,
                        //       //         fontFamily: Font_.Fonts_T,
                        //       //       ),
                        //       //     ),
                        //       //   ],
                        //       // ),
                        //       Row(
                        //         children: [
                        //           Text(
                        //             (total_list.length != teNantModels.length)
                        //                 ? 'ยอด :'
                        //                 : "ยอด : ",
                        //             style: TextStyle(
                        //               fontWeight: FontWeight.bold,
                        //               fontFamily: FontWeight_.Fonts_T,
                        //             ),
                        //           ),
                        //           Text(
                        //             (total_list.length != teNantModels.length)
                        //                 ? '0.00 บาท'
                        //                 : "${nFormat.format(double.parse(total_list[index].toString()))} บาท",
                        //             style: TextStyle(
                        //               color: Colors.red,
                        //               fontFamily: Font_.Fonts_T,
                        //             ),
                        //           ),
                        //         ],
                        //       )
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }

  // RE_ChoArea_Widget() {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: const RoundedRectangleBorder(
  //             borderRadius: BorderRadius.all(Radius.circular(20.0))),
  //         title: const Column(
  //           children: [
  //             Center(
  //                 child: Text(
  //               'ข้อมูลพื้นที่เช่า',
  //               style: TextStyle(
  //                 color: Colors.black,
  //                 fontWeight: FontWeight.bold,
  //                 fontFamily: FontWeight_.Fonts_T,
  //               ),
  //             )),
  //             SizedBox(height: 1),
  //             Divider(),
  //             SizedBox(height: 1),
  //           ],
  //         ),
  //         content: StreamBuilder(
  //             stream: Stream.periodic(const Duration(seconds: 0)),
  //             builder: (context, snapshot) {
  //               return ScrollConfiguration(
  //                 behavior:
  //                     ScrollConfiguration.of(context).copyWith(dragDevices: {
  //                   PointerDeviceKind.touch,
  //                   PointerDeviceKind.mouse,
  //                 }),
  //                 child: SingleChildScrollView(
  //                   scrollDirection: Axis.horizontal,
  //                   child: Row(
  //                     children: [
  //                       Container(
  //                         // color: Colors.grey[50],
  //                         width: (Responsive.isDesktop(context))
  //                             ? MediaQuery.of(context).size.width * 0.9
  //                             : (areaModels.length == 0)
  //                                 ? MediaQuery.of(context).size.width
  //                                 : 1200,
  //                         // height:
  //                         //     MediaQuery.of(context)
  //                         //             .size
  //                         //             .height *
  //                         //         0.3,
  //                         child: (areaModels.length == 0)
  //                             ? const Column(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   Center(
  //                                     child: Text(
  //                                       'ไม่พบข้อมูล',
  //                                       style: TextStyle(
  //                                         fontWeight: FontWeight.bold,
  //                                         fontFamily: FontWeight_.Fonts_T,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               )
  //                             : Column(
  //                                 children: <Widget>[
  //                                   Container(
  //                                     // width: 1050,
  //                                     decoration: const BoxDecoration(
  //                                       color:
  //                                           Color.fromARGB(255, 201, 196, 186),
  //                                       borderRadius: BorderRadius.only(
  //                                           topLeft: Radius.circular(10),
  //                                           topRight: Radius.circular(10),
  //                                           bottomLeft: Radius.circular(0),
  //                                           bottomRight: Radius.circular(0)),
  //                                     ),
  //                                     padding: const EdgeInsets.all(8.0),
  //                                     child: const Row(
  //                                       children: [
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: Padding(
  //                                             padding: EdgeInsets.all(8.0),
  //                                             child: Text(
  //                                               'โซนพื้นที่',
  //                                               textAlign: TextAlign.start,
  //                                               style: TextStyle(
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ),
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: Padding(
  //                                             padding: EdgeInsets.all(8.0),
  //                                             child: Text(
  //                                               'ชื้อพื้นที่',
  //                                               textAlign: TextAlign.start,
  //                                               style: TextStyle(
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ),
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: Padding(
  //                                             padding: EdgeInsets.all(8.0),
  //                                             child: Text(
  //                                               'ขนาดพื้นที่(ต.ร.ม.)',
  //                                               textAlign: TextAlign.end,
  //                                               style: TextStyle(
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,

  //                                                 //fontSize: 10.0
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ),
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: Padding(
  //                                             padding: EdgeInsets.all(8.0),
  //                                             child: Text(
  //                                               'ค่าเช่าต่องวด',
  //                                               textAlign: TextAlign.end,
  //                                               style: TextStyle(
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,

  //                                                 //fontSize: 10.0
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ),
  //                                         // Expanded(
  //                                         //   flex: 1,
  //                                         //   child: Padding(
  //                                         //     padding: EdgeInsets.all(8.0),
  //                                         //     child: Text(
  //                                         //       'เลขที่ใบสัญญา',
  //                                         //       textAlign: TextAlign.end,
  //                                         //       style: TextStyle(
  //                                         //         fontWeight: FontWeight.bold,

  //                                         //         //fontSize: 10.0
  //                                         //       ),
  //                                         //     ),
  //                                         //   ),
  //                                         // ),
  //                                         // Expanded(
  //                                         //   flex: 1,
  //                                         //   child: Padding(
  //                                         //     padding: EdgeInsets.all(8.0),
  //                                         //     child: Text(
  //                                         //       'เลขที่ใบเสนอราคา',
  //                                         //       textAlign: TextAlign.end,
  //                                         //       style: TextStyle(
  //                                         //         fontWeight: FontWeight.bold,

  //                                         //         //fontSize: 10.0
  //                                         //       ),
  //                                         //     ),
  //                                         //   ),
  //                                         // ),
  //                                         // Expanded(
  //                                         //   flex: 1,
  //                                         //   child: Padding(
  //                                         //     padding: EdgeInsets.all(8.0),
  //                                         //     child: Text(
  //                                         //       'วันสิ้นสุดสัญญา',
  //                                         //       textAlign: TextAlign.end,
  //                                         //       style: TextStyle(
  //                                         //         fontWeight: FontWeight.bold,
  //                                         //       ),
  //                                         //     ),
  //                                         //   ),
  //                                         // ),
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: Padding(
  //                                             padding: EdgeInsets.all(8.0),
  //                                             child: Text(
  //                                               'สถานะ',
  //                                               textAlign: TextAlign.end,
  //                                               style: TextStyle(
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,

  //                                                 //fontSize: 10.0
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                       // height: (Responsive.isDesktop(context))
  //                                       //     ? MediaQuery.of(context).size.width * 0.255
  //                                       //     : MediaQuery.of(context).size.height * 0.45,
  //                                       child: ListView.builder(
  //                                     itemCount: areaModels.length,
  //                                     itemBuilder:
  //                                         (BuildContext context, int index) {
  //                                       return Material(
  //                                         child: ListTile(
  //                                           onTap: () {},
  //                                           title: Container(
  //                                             decoration: const BoxDecoration(
  //                                               // color: Colors.green[100]!
  //                                               //     .withOpacity(0.5),
  //                                               border: Border(
  //                                                 bottom: BorderSide(
  //                                                   color: Colors.black12,
  //                                                   width: 1,
  //                                                 ),
  //                                               ),
  //                                             ),
  //                                             child: Row(children: [
  //                                               Expanded(
  //                                                 flex: 1,
  //                                                 child: Padding(
  //                                                   padding:
  //                                                       const EdgeInsets.all(
  //                                                           8.0),
  //                                                   child: Text(
  //                                                     '${areaModels[index].zn}',
  //                                                     textAlign:
  //                                                         TextAlign.start,
  //                                                     style: const TextStyle(
  //                                                       fontFamily:
  //                                                           Font_.Fonts_T,
  //                                                       //fontSize: 10.0
  //                                                     ),
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                               Expanded(
  //                                                 flex: 1,
  //                                                 child: Padding(
  //                                                   padding:
  //                                                       const EdgeInsets.all(
  //                                                           8.0),
  //                                                   child: Text(
  //                                                     areaModels[index].ln_c ==
  //                                                             null
  //                                                         ? areaModels[index]
  //                                                                     .ln_q ==
  //                                                                 null
  //                                                             ? '${areaModels[index].lncode}'
  //                                                             : '${areaModels[index].ln_q}'
  //                                                         : '${areaModels[index].ln_c}',
  //                                                     textAlign:
  //                                                         TextAlign.start,
  //                                                     style: const TextStyle(
  //                                                       fontFamily:
  //                                                           Font_.Fonts_T,
  //                                                     ),
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                               Expanded(
  //                                                 flex: 1,
  //                                                 child: Text(
  //                                                   areaModels[index].area_c ==
  //                                                           null
  //                                                       ? areaModels[index]
  //                                                                   .ln_q ==
  //                                                               null
  //                                                           ? nFormat.format(
  //                                                               double.parse(
  //                                                                   areaModels[index]
  //                                                                       .area!))
  //                                                           : nFormat.format(
  //                                                               double.parse(
  //                                                                   areaModels[index]
  //                                                                       .area_q!))
  //                                                       : nFormat.format(
  //                                                           double.parse(
  //                                                               areaModels[index]
  //                                                                   .area_c!)),
  //                                                   textAlign: TextAlign.end,
  //                                                   style: const TextStyle(
  //                                                     fontFamily: Font_.Fonts_T,
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                               Expanded(
  //                                                 flex: 1,
  //                                                 child: Text(
  //                                                   areaModels[index].total ==
  //                                                           null
  //                                                       ? areaModels[index]
  //                                                                   .total_q ==
  //                                                               null
  //                                                           ? nFormat.format(
  //                                                               double.parse(
  //                                                                   areaModels[index]
  //                                                                       .rent!))
  //                                                           : nFormat.format(
  //                                                               double.parse(
  //                                                                   areaModels[index]
  //                                                                       .total_q!))
  //                                                       : nFormat.format(
  //                                                           double.parse(
  //                                                               areaModels[index]
  //                                                                   .total!)),
  //                                                   textAlign: TextAlign.end,
  //                                                   style: const TextStyle(
  //                                                     fontFamily: Font_.Fonts_T,
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                               // Expanded(
  //                                               //   flex: 1,
  //                                               //   child: Padding(
  //                                               //       padding:
  //                                               //           const EdgeInsets.all(
  //                                               //               8.0),
  //                                               //       child: Text(
  //                                               //         areaModels[index].cid ==
  //                                               //                 null
  //                                               //             ? ''
  //                                               //             : '${areaModels[index].cid}',
  //                                               //         maxLines: 1,
  //                                               //         textAlign:
  //                                               //             TextAlign.end,
  //                                               //         overflow: TextOverflow
  //                                               //             .ellipsis,
  //                                               //         style:
  //                                               //             const TextStyle(),
  //                                               //       )),
  //                                               // ),
  //                                               // Expanded(
  //                                               //   flex: 1,
  //                                               //   child: Padding(
  //                                               //       padding:
  //                                               //           const EdgeInsets.all(
  //                                               //               8.0),
  //                                               //       child: Text(
  //                                               //         areaModels[index]
  //                                               //                     .docno ==
  //                                               //                 null
  //                                               //             ? ''
  //                                               //             : '${areaModels[index].docno}',
  //                                               //         maxLines: 1,
  //                                               //         textAlign:
  //                                               //             TextAlign.end,
  //                                               //         overflow: TextOverflow
  //                                               //             .ellipsis,
  //                                               //         style: TextStyle(),
  //                                               //       )),
  //                                               // ),
  //                                               // Expanded(
  //                                               //   flex: 1,
  //                                               //   child: Padding(
  //                                               //     padding:
  //                                               //         const EdgeInsets.all(
  //                                               //             8.0),
  //                                               //     child: Text(
  //                                               //       areaModels[index].ldate ==
  //                                               //               null
  //                                               //           ? areaModels[index]
  //                                               //                       .ldate_q ==
  //                                               //                   null
  //                                               //               ? ''
  //                                               //               : DateFormat(
  //                                               //                       'dd-MM-yyyy')
  //                                               //                   .format(DateTime
  //                                               //                       .parse(
  //                                               //                           '${areaModels[index].ldate_q} 00:00:00'))
  //                                               //                   .toString()
  //                                               //           : DateFormat(
  //                                               //                   'dd-MM-yyyy')
  //                                               //               .format(DateTime
  //                                               //                   .parse(
  //                                               //                       '${areaModels[index].ldate} 00:00:00'))
  //                                               //               .toString(),
  //                                               //       maxLines: 1,
  //                                               //       textAlign: TextAlign.end,
  //                                               //       overflow:
  //                                               //           TextOverflow.ellipsis,
  //                                               //       style: TextStyle(
  //                                               //         color: areaModels[index]
  //                                               //                     .quantity ==
  //                                               //                 '1'
  //                                               //             ? datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(
  //                                               //                         const Duration(
  //                                               //                             days:
  //                                               //                                 0))) ==
  //                                               //                     true
  //                                               //                 ? Colors.red
  //                                               //                 : datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(const Duration(days: 30))) ==
  //                                               //                         true
  //                                               //                     ? Colors
  //                                               //                         .orange
  //                                               //                         .shade900
  //                                               //                     : Colors
  //                                               //                         .black
  //                                               //             : areaModels[index]
  //                                               //                         .quantity ==
  //                                               //                     '2'
  //                                               //                 ? Colors.blue
  //                                               //                 : areaModels[index]
  //                                               //                             .quantity ==
  //                                               //                         '3'
  //                                               //                     ? Colors
  //                                               //                         .blue
  //                                               //                     : Colors.green,
  //                                               //       ),
  //                                               //     ),
  //                                               //   ),
  //                                               // ),
  //                                               Expanded(
  //                                                 flex: 1,
  //                                                 child: Text(
  //                                                   areaModels[index].quantity ==
  //                                                           '1'
  //                                                       ? datex.isAfter(DateTime.parse(
  //                                                                       '${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000')
  //                                                                   .subtract(const Duration(
  //                                                                       days:
  //                                                                           0))) ==
  //                                                               true
  //                                                           ? 'หมดสัญญา'
  //                                                           : datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(
  //                                                                       const Duration(
  //                                                                           days:
  //                                                                               30))) ==
  //                                                                   true
  //                                                               ? 'ใกล้หมดสัญญา'
  //                                                               : 'เช่าอยู่'
  //                                                       : areaModels[index]
  //                                                                   .quantity ==
  //                                                               '2'
  //                                                           ? 'เสนอราคา'
  //                                                           : areaModels[index]
  //                                                                       .quantity ==
  //                                                                   '3'
  //                                                               ? 'เสนอราคา(มัดจำ)'
  //                                                               : 'ว่าง',
  //                                                   textAlign: TextAlign.end,
  //                                                   style: TextStyle(
  //                                                     color: areaModels[index]
  //                                                                 .quantity ==
  //                                                             '1'
  //                                                         ? datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(
  //                                                                     const Duration(
  //                                                                         days:
  //                                                                             0))) ==
  //                                                                 true
  //                                                             ? Colors.red
  //                                                             : datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(const Duration(days: 30))) ==
  //                                                                     true
  //                                                                 ? Colors
  //                                                                     .orange
  //                                                                     .shade900
  //                                                                 : Colors.black
  //                                                         : areaModels[index]
  //                                                                     .quantity ==
  //                                                                 '2'
  //                                                             ? Colors.blue
  //                                                             : areaModels[index]
  //                                                                         .quantity ==
  //                                                                     '3'
  //                                                                 ? Colors.blue
  //                                                                 : Colors
  //                                                                     .green,
  //                                                     fontFamily: Font_.Fonts_T,
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                             ]),
  //                                           ),
  //                                         ),
  //                                       );
  //                                     },
  //                                   )),
  //                                 ],
  //                               ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             }),
  //         actions: <Widget>[
  //           const SizedBox(height: 1),
  //           const Divider(),
  //           const SizedBox(height: 1),
  //           Padding(
  //             padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
  //             child: SingleChildScrollView(
  //               scrollDirection: Axis.horizontal,
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Container(
  //                           padding: const EdgeInsets.all(8.0),
  //                           width: 150,
  //                           child: InkWell(
  //                             onTap: () {
  //                               Navigator.pop(context);
  //                             },
  //                             child: Container(
  //                                 decoration: const BoxDecoration(
  //                                   color: Colors.black,
  //                                   borderRadius: BorderRadius.only(
  //                                       topLeft: Radius.circular(6),
  //                                       topRight: Radius.circular(6),
  //                                       bottomLeft: Radius.circular(6),
  //                                       bottomRight: Radius.circular(6)),
  //                                 ),
  //                                 child: const Row(
  //                                   mainAxisAlignment: MainAxisAlignment.center,
  //                                   children: [
  //                                     Padding(
  //                                       padding: EdgeInsets.all(4.0),
  //                                       child: Icon(
  //                                         Icons.highlight_off,
  //                                         color: Colors.white,
  //                                         size: 16,
  //                                       ),
  //                                     ),
  //                                     Padding(
  //                                       padding: EdgeInsets.all(4.0),
  //                                       child: Text(
  //                                         'ปิด',
  //                                         style: TextStyle(
  //                                           fontSize: 14,
  //                                           color: Colors.white,
  //                                           fontFamily: Font_.Fonts_T,
  //                                           // fontWeight:
  //                                           //     FontWeight.bold,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 )),
  //                           ),
  //                         ),
  //                         // Container(
  //                         //   width: 100,
  //                         //   decoration: const BoxDecoration(
  //                         //     color: Colors.redAccent,
  //                         //     borderRadius: BorderRadius.only(
  //                         //         topLeft: Radius.circular(10),
  //                         //         topRight: Radius.circular(10),
  //                         //         bottomLeft: Radius.circular(10),
  //                         //         bottomRight: Radius.circular(10)),
  //                         //   ),
  //                         //   padding: const EdgeInsets.all(8.0),
  //                         //   child: TextButton(
  //                         //     onPressed: () => Navigator.pop(context, 'OK'),
  //                         //     child: const Text(
  //                         //       'ปิด',
  //                         //       style: TextStyle(
  //                         //         color: Colors.white,
  //                         //         fontWeight: FontWeight.bold,
  //                         //       ),
  //                         //     ),
  //                         //   ),
  //                         // ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
