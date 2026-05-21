import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:widgets_to_image/widgets_to_image.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Model/GetArea_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTranBill_model.dart';
import '../Model/GetZone_Model.dart';
import '../Responsive/responsive.dart';
import '../color.dart';
import '../downloadImage.dart';
import 'buttonnavbar.dart';
import 'loginscreen.dart';

class SelectScreen extends StatefulWidget {
  const SelectScreen({super.key});

  @override
  State<SelectScreen> createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  DateTime datex = DateTime.now();
  List<TeNantModel> teNantModels = [];
  List<TransBillModel> _TransBillModels = [];
  List<ZoneModel> zoneModels = [];

  List<AreaModel> areaModels = [];
  String? renTal_user, renTal_name, Value_cid, custno_;

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
      imgl;
  List<RenTalModel> renTalModels = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPreferance();
    read_GC_tenant();
    read_GC_rental();
    read_GC_areaSelect();
  }

  Future<Null> checkPreferance() async {
    DateTime currentDate = DateTime.now();

    // Format the date as 'YYYY-MM-DD'
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? DateLogin;
    setState(() {
      renTal_user = preferences.getString('renTalSer');
      renTal_name = preferences.getString('renTalName');
      custno_ = preferences.getString('custno');
      DateLogin = preferences.getString('Date_Login');
    });
    if (DateLogin.toString().trim() != formattedDate.toString().trim()) {
      setState(() {
        preferences.setString('Date_Login', formattedDate!);
      });
      Insert_log.Insert_logs('ล็อคอิน', 'เข้าสู่ระบบ $custno_');
    } else {
      // print('result Date_Login');
    }
  }

  Future<Null> read_GC_areaSelect() async {
    if (areaModels.length != 0) {
      areaModels.clear();
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
      // print(result);
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

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
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
                'https://chaoperties.com/chao_api/files/$foder/logo/${renTalModel.imglogo!.trim()}';
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

    // print('name>>>>>  $renname');
  }

  Future<Null> read_GC_tenant() async {
    if (teNantModels.isNotEmpty) {
      teNantModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var custno_S = preferences.getString('custno');
    String url =
        '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&custno=$custno_S';
    //  '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          if (teNantModel.cid == null ||
              teNantModel.cid.toString() == '' ||
              teNantModel.cid.toString() == 'null') {
          } else {
            setState(() {
              teNantModels.add(teNantModel);
            });
          }
        }
      } else {}
      red_Trans_bill();
    } catch (e) {}
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
      String url =
          '${MyConstant().domain}/GC_tran_pays.php?isAdd=true&ren=$ren&ciddoc=${teNantModels[index].cid}';

      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        //  print('${teNantModels[index].cid}');
        if (result.toString() != 'null') {
          for (var map in result) {
            TransBillModel _TransBillModel = TransBillModel.fromJson(map);
            var menu = double.parse(_TransBillModel.total.toString())
                .toStringAsFixed(2);
            // print('${_TransBillModel.date}');
            // print(_TransBillModel.total!);

            setState(() {
              // _TransBillModels.add(_TransBillModel);
              if (_TransBillModel.invoice == null) {
                if (menu != '0.00') {
                  total = (_TransBillModel.total == null)
                      ? total + 0.00
                      : total + double.parse(_TransBillModel.total!);
                  All_total = (_TransBillModel.total == null)
                      ? All_total + 0.00
                      : All_total + double.parse(_TransBillModel.total!);
                }
              }
              // _TransBillModels.add(_TransBillModel);
            });
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
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                color: Color.fromARGB(255, 184, 198, 133),
                child: Center(
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
                      padding: EdgeInsets.all(8.0),
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
                      padding: EdgeInsets.all(8.0),
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
                      padding: EdgeInsets.all(8.0),
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
                      padding: EdgeInsets.all(8.0),
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
                      padding: EdgeInsets.all(8.0),
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
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: const BorderRadius.only(
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

  // WidgetsToImageController to access widget
  WidgetsToImageController controller = WidgetsToImageController();
  // to save image bytes of widget
  Uint8List? bytes;
  Widget build(BuildContext context) {
    ////////////----------------------------->
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        // onPressed: () async {
        //   final bytes = await controller.capture();
        //   setState(() {
        //     this.bytes = bytes;
        //   });
        //   final base64String = base64Encode(bytes!);
        //   print(base64String);
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            WidgetsToImage(
              controller: controller,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 83, 87, 95),
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () async {
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      await preferences.clear();
                      MaterialPageRoute route = MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      );
                      Navigator.pushAndRemoveUntil(
                          context, route, (route) => false);

                      // Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "ออกจากระบบ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T,
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        backgroundColor: bgcolor,
      ),
      body: Container(
        color: bgcolor,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            (imgl == null || imgl.toString() == '')
                ? SizedBox()
                : InkWell(
                    child: CircleAvatar(
                      radius: 35.0,
                      backgroundImage: NetworkImage('${imglogo_}'),
                      backgroundColor: Colors.transparent,
                    ),
                    // onTap: () {
                    //   if (imglogo_ == null || imglogo_.toString() == '') {
                    //   } else {
                    //     String url = '${imglogo_}';
                    //     // _showMyDialogImg(
                    //     //     url, renTal_name == null ? ' ' : ' $renTal_name');
                    //   }
                    // },
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$renTal_name",
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: Font_.Fonts_T,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
              child: InkWell(
                onTap: () {
                  RE_ChoArea_Widget();
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "🔎เลือกดูพื้นที่ว่าง",
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                      fontFamily: Font_.Fonts_T,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.center,
                clipBehavior: Clip.hardEdge,
                constraints: BoxConstraints(minHeight: 150),
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
                child: Column(children: [
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 184, 198, 133),

                      // color: green,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                "เลือกสัญญา ",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: FontWeight_.Fonts_T,
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  // border: Border.all(color: Colors.orange, width: 2),
                                ),
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "สัญญาทั้งหมด : ${teNantModels.length}",
                                  style: TextStyle(
                                    // decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: FontWeight_.Fonts_T,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                ),
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "ยอดรวม : ${nFormat.format(double.parse(All_total.toString()))} บาท  ",
                                  style: TextStyle(
                                    // decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: FontWeight_.Fonts_T,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Data_Widget()),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Data_Widget() {
    //////////////////////////////////////////////////////////////////////
    // List<Widget> data = [];
    // for (int index = 0; index < teNantModels.length; index++) {

    // }

    return Column(
      children: [
        for (int index = 0; index < teNantModels.length; index++)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                var ser_teNant = teNantModels[index].quantity;
                setState(() {
                  // preferences.setString('serteNant', ser_teNant!);

                  Value_cid = teNantModels[index].docno == null
                      ? teNantModels[index].cid == null
                          ? ''
                          : '${teNantModels[index].cid}'
                      : '${teNantModels[index].docno}';
                  preferences.setString('usercid', Value_cid!);
                  // print('-----------------------------');
                  // print('รหัสตลาด : $renTal_user');
//print('ตลาด : $renTal_name');
                  //  print('เลขสัญญา : $Value_cid');
                  preferences.setString('qutser', ser_teNant!);
                  //    print('-----------------------------');

                  // var provider_WH =
                  //     Provider.of<WaitPayListProvider>(context, listen: false);
                  // provider_WH.marketname(renTal_name);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return ButtonNavBar();
                  }));
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black38,
                          blurRadius: 1,
                          spreadRadius: 0,
                          offset: Offset(0, 1))
                    ]),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: [
                    Container(
                      color: Color.fromARGB(255, 201, 196, 186),
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text("${index + 1}. ชื่อร้านค้า  : ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontWeight_.Fonts_T,
                                  )),
                              Text(
                                teNantModels[index].sname == null
                                    ? teNantModels[index].sname_q == null
                                        ? ''
                                        : '${teNantModels[index].sname_q}'
                                    : '${teNantModels[index].sname}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: teNantModels[index].quantity == '1'
                                  ? datex.isAfter(DateTime.parse(
                                                  '${teNantModels[index].ldate} 00:00:00.000')
                                              .subtract(
                                                  const Duration(days: 0))) ==
                                          true
                                      ? Color.fromARGB(255, 254, 0, 0)
                                      : datex.isAfter(DateTime.parse(
                                                      '${teNantModels[index].ldate} 00:00:00.000')
                                                  .subtract(const Duration(
                                                      days: 30))) ==
                                              true
                                          ? Colors.amber
                                          : Colors.green
                                  : teNantModels[index].quantity == '2'
                                      ? Colors.blue
                                      : teNantModels[index].quantity == '3'
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
                            child: Row(
                              children: [
                                Text(
                                  "สถานะ : ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontWeight_.Fonts_T,
                                  ),
                                ),
                                Text(
                                  teNantModels[index].quantity == '1'
                                      ? datex.isAfter(DateTime.parse(
                                                      '${teNantModels[index].ldate} 00:00:00.000')
                                                  .subtract(const Duration(
                                                      days: 0))) ==
                                              true
                                          ? 'หมดสัญญา'
                                          : datex.isAfter(DateTime.parse(
                                                          '${teNantModels[index].ldate} 00:00:00.000')
                                                      .subtract(const Duration(
                                                          days: 30))) ==
                                                  true
                                              ? 'ใกล้หมดสัญญา'
                                              : 'เช่าอยู่'
                                      : teNantModels[index].quantity == '2'
                                          ? 'เสนอราคา'
                                          : teNantModels[index].quantity == '3'
                                              ? 'เสนอราคา(มัดจำ)'
                                              : 'ว่าง',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("ชื่อผู้ติดต่อ : ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontWeight_.Fonts_T,
                                  )),
                              Text(
                                teNantModels[index].cname == null
                                    ? teNantModels[index].cname_q == null
                                        ? ''
                                        : '${teNantModels[index].cname_q}'
                                    : '${teNantModels[index].cname}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("รหัสพื้นที่ : ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontWeight_.Fonts_T,
                                  )),
                              Text(
                                teNantModels[index].ln_c == null
                                    ? teNantModels[index].ln_q == null
                                        ? ''
                                        : '${teNantModels[index].ln_q}'
                                    : '${teNantModels[index].ln_c}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8.0),
                                child: Row(
                                  children: [
                                    Text("เลขสัญญา : ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T,
                                        )),
                                    Text(
                                      teNantModels[index].docno == null
                                          ? teNantModels[index].cid == null
                                              ? ''
                                              : '${teNantModels[index].cid}'
                                          : '${teNantModels[index].docno}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Text("โซน : ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T,
                                      )),
                                  Text(
                                    '${teNantModels[index].zn}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                (total_list.length != teNantModels.length)
                                    ? 'ยอด :'
                                    : "ยอด : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T,
                                ),
                              ),
                              Text(
                                (total_list.length != teNantModels.length)
                                    ? '0.00 บาท'
                                    : "${nFormat.format(double.parse(total_list[index].toString()))} บาท",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [],
                    )
                  ],
                ),
              ),
            ),
          )
      ],
    );
  }

  RE_ChoArea_Widget() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Column(
            children: [
              Center(
                  child: Text(
                'ข้อมูลพื้นที่เช่า',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontWeight_.Fonts_T,
                ),
              )),
              const SizedBox(height: 1),
              const Divider(),
              const SizedBox(height: 1),
            ],
          ),
          content: StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 0)),
              builder: (context, snapshot) {
                return ScrollConfiguration(
                  behavior:
                      ScrollConfiguration.of(context).copyWith(dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  }),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          // color: Colors.grey[50],
                          width: (Responsive.isDesktop(context))
                              ? MediaQuery.of(context).size.width * 0.9
                              : (areaModels.length == 0)
                                  ? MediaQuery.of(context).size.width
                                  : 1200,
                          // height:
                          //     MediaQuery.of(context)
                          //             .size
                          //             .height *
                          //         0.3,
                          child: (areaModels.length == 0)
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        'ไม่พบข้อมูล',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: <Widget>[
                                    Container(
                                      // width: 1050,
                                      decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 201, 196, 186),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0)),
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'โซนพื้นที่',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'ชื้อพื้นที่',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'ขนาดพื้นที่(ต.ร.ม.)',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,

                                                  //fontSize: 10.0
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'ค่าเช่าต่องวด',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,

                                                  //fontSize: 10.0
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: Padding(
                                          //     padding: EdgeInsets.all(8.0),
                                          //     child: Text(
                                          //       'เลขที่ใบสัญญา',
                                          //       textAlign: TextAlign.end,
                                          //       style: TextStyle(
                                          //         fontWeight: FontWeight.bold,

                                          //         //fontSize: 10.0
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: Padding(
                                          //     padding: EdgeInsets.all(8.0),
                                          //     child: Text(
                                          //       'เลขที่ใบเสนอราคา',
                                          //       textAlign: TextAlign.end,
                                          //       style: TextStyle(
                                          //         fontWeight: FontWeight.bold,

                                          //         //fontSize: 10.0
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: Padding(
                                          //     padding: EdgeInsets.all(8.0),
                                          //     child: Text(
                                          //       'วันสิ้นสุดสัญญา',
                                          //       textAlign: TextAlign.end,
                                          //       style: TextStyle(
                                          //         fontWeight: FontWeight.bold,
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'สถานะ',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,

                                                  //fontSize: 10.0
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                        // height: (Responsive.isDesktop(context))
                                        //     ? MediaQuery.of(context).size.width * 0.255
                                        //     : MediaQuery.of(context).size.height * 0.45,
                                        child: ListView.builder(
                                      itemCount: areaModels.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Material(
                                          child: ListTile(
                                            onTap: () {},
                                            title: Container(
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
                                              child: Row(children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      '${areaModels[index].zn}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                        //fontSize: 10.0
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      areaModels[index].ln_c ==
                                                              null
                                                          ? areaModels[index]
                                                                      .ln_q ==
                                                                  null
                                                              ? '${areaModels[index].lncode}'
                                                              : '${areaModels[index].ln_q}'
                                                          : '${areaModels[index].ln_c}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    areaModels[index].area_c ==
                                                            null
                                                        ? areaModels[index]
                                                                    .ln_q ==
                                                                null
                                                            ? nFormat.format(
                                                                double.parse(
                                                                    areaModels[index]
                                                                        .area!))
                                                            : nFormat.format(
                                                                double.parse(
                                                                    areaModels[index]
                                                                        .area_q!))
                                                        : nFormat.format(
                                                            double.parse(
                                                                areaModels[index]
                                                                    .area_c!)),
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    areaModels[index].total ==
                                                            null
                                                        ? areaModels[index]
                                                                    .total_q ==
                                                                null
                                                            ? nFormat.format(
                                                                double.parse(
                                                                    areaModels[index]
                                                                        .rent!))
                                                            : nFormat.format(
                                                                double.parse(
                                                                    areaModels[index]
                                                                        .total_q!))
                                                        : nFormat.format(
                                                            double.parse(
                                                                areaModels[index]
                                                                    .total!)),
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Padding(
                                                //       padding:
                                                //           const EdgeInsets.all(
                                                //               8.0),
                                                //       child: Text(
                                                //         areaModels[index].cid ==
                                                //                 null
                                                //             ? ''
                                                //             : '${areaModels[index].cid}',
                                                //         maxLines: 1,
                                                //         textAlign:
                                                //             TextAlign.end,
                                                //         overflow: TextOverflow
                                                //             .ellipsis,
                                                //         style:
                                                //             const TextStyle(),
                                                //       )),
                                                // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Padding(
                                                //       padding:
                                                //           const EdgeInsets.all(
                                                //               8.0),
                                                //       child: Text(
                                                //         areaModels[index]
                                                //                     .docno ==
                                                //                 null
                                                //             ? ''
                                                //             : '${areaModels[index].docno}',
                                                //         maxLines: 1,
                                                //         textAlign:
                                                //             TextAlign.end,
                                                //         overflow: TextOverflow
                                                //             .ellipsis,
                                                //         style: TextStyle(),
                                                //       )),
                                                // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Padding(
                                                //     padding:
                                                //         const EdgeInsets.all(
                                                //             8.0),
                                                //     child: Text(
                                                //       areaModels[index].ldate ==
                                                //               null
                                                //           ? areaModels[index]
                                                //                       .ldate_q ==
                                                //                   null
                                                //               ? ''
                                                //               : DateFormat(
                                                //                       'dd-MM-yyyy')
                                                //                   .format(DateTime
                                                //                       .parse(
                                                //                           '${areaModels[index].ldate_q} 00:00:00'))
                                                //                   .toString()
                                                //           : DateFormat(
                                                //                   'dd-MM-yyyy')
                                                //               .format(DateTime
                                                //                   .parse(
                                                //                       '${areaModels[index].ldate} 00:00:00'))
                                                //               .toString(),
                                                //       maxLines: 1,
                                                //       textAlign: TextAlign.end,
                                                //       overflow:
                                                //           TextOverflow.ellipsis,
                                                //       style: TextStyle(
                                                //         color: areaModels[index]
                                                //                     .quantity ==
                                                //                 '1'
                                                //             ? datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(
                                                //                         const Duration(
                                                //                             days:
                                                //                                 0))) ==
                                                //                     true
                                                //                 ? Colors.red
                                                //                 : datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(const Duration(days: 30))) ==
                                                //                         true
                                                //                     ? Colors
                                                //                         .orange
                                                //                         .shade900
                                                //                     : Colors
                                                //                         .black
                                                //             : areaModels[index]
                                                //                         .quantity ==
                                                //                     '2'
                                                //                 ? Colors.blue
                                                //                 : areaModels[index]
                                                //                             .quantity ==
                                                //                         '3'
                                                //                     ? Colors
                                                //                         .blue
                                                //                     : Colors.green,
                                                //       ),
                                                //     ),
                                                //   ),
                                                // ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    areaModels[index].quantity ==
                                                            '1'
                                                        ? datex.isAfter(DateTime.parse(
                                                                        '${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000')
                                                                    .subtract(const Duration(
                                                                        days:
                                                                            0))) ==
                                                                true
                                                            ? 'หมดสัญญา'
                                                            : datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(
                                                                        const Duration(
                                                                            days:
                                                                                30))) ==
                                                                    true
                                                                ? 'ใกล้หมดสัญญา'
                                                                : 'เช่าอยู่'
                                                        : areaModels[index]
                                                                    .quantity ==
                                                                '2'
                                                            ? 'เสนอราคา'
                                                            : areaModels[index]
                                                                        .quantity ==
                                                                    '3'
                                                                ? 'เสนอราคา(มัดจำ)'
                                                                : 'ว่าง',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color: areaModels[index]
                                                                  .quantity ==
                                                              '1'
                                                          ? datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(
                                                                      const Duration(
                                                                          days:
                                                                              0))) ==
                                                                  true
                                                              ? Colors.red
                                                              : datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(const Duration(days: 30))) ==
                                                                      true
                                                                  ? Colors
                                                                      .orange
                                                                      .shade900
                                                                  : Colors.black
                                                          : areaModels[index]
                                                                      .quantity ==
                                                                  '2'
                                                              ? Colors.blue
                                                              : areaModels[index]
                                                                          .quantity ==
                                                                      '3'
                                                                  ? Colors.blue
                                                                  : Colors
                                                                      .green,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                            ),
                                          ),
                                        );
                                      },
                                    )),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          actions: <Widget>[
            const SizedBox(height: 1),
            const Divider(),
            const SizedBox(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
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
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: const BorderRadius.only(
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
                          //     onPressed: () => Navigator.pop(context, 'OK'),
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
