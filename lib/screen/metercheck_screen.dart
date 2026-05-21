import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constant/Myconstant.dart';
import '../Model/GetContractx_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTrans_Model.dart';
import '../Responsive/responsive.dart';
import '../color.dart';
import 'package:http/http.dart' as http;

class MeterCheckScreen extends StatefulWidget {
  const MeterCheckScreen({super.key});

  @override
  State<MeterCheckScreen> createState() => MeterCheckScreenState();
}

class MeterCheckScreenState extends State<MeterCheckScreen> {
  String? _celvat, _cname, _cnamex, _cser, _cunitser, _cqty_vat, _cunit;
  var nFormat = NumberFormat("#,##0.00", "en_US");
  List<TransModel> _TransModels = [];
  List<ContractxModel> _ContractxModels = [];
  List<RenTalModel> renTalModels = [];
  int Ser__TapContractx = 0;
  String tappedIndex_1 = '';
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
      foder;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    red_exp_wherser();
    read_GC_rental();
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
  Future<Null> read_GC_rental() async {
    if (renTalModels.isNotEmpty) {
      renTalModels.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain_chao}/GC_rental_setring.php?isAdd=true&ren=$ren';

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
            renTalModels.add(renTalModel);
          });
        }
      } else {}
    } catch (e) {}
    print('name>>>>>  $renname');
  }

  Future<Null> red_Trans(_cser) async {
    if (_TransModels.length != 0) {
      setState(() {
        _TransModels.clear();
      });
    }
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc_ = preferences.getString('usercid');
    var qutser_ = preferences.getString('qutser');
    ////////////////------------------------------------------------------>

    if (qutser_ == '1') {
      String url = _cser == null
          ? '${MyConstant().domain_chao}/GC_quotx_consx.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_&_cser=${_ContractxModels[0].ser}}'
          : '${MyConstant().domain_chao}/GC_quotx_consx.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_&_cser=$_cser';
      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        print(result);
        if (result.toString() != 'null') {
          for (var map in result) {
            TransModel _TransModel = TransModel.fromJson(map);
            setState(() {
              _TransModels.add(_TransModel);
            });
          }
        } else {
          setState(() {
            _TransModels.clear();
          });
        }
      } catch (e) {}
    }

    if (_cser == null) {
      setState(() {
        _celvat = _ContractxModels[0].nvat;
        _cname =
            '${_ContractxModels[0].expname}( ${_ContractxModels[0].unit} )\n${_ContractxModels[0].meter}';
        _cnamex = '${_ContractxModels[0].expname}';
        _cser = _ContractxModels[0].ser;
        _cunitser = _ContractxModels[0].unitser;
        _cunit = _ContractxModels[0].unit;
        _cqty_vat = _ContractxModels[0].qty;
      });
    }
  }

  Future<Null> red_exp_wherser() async {
    if (_ContractxModels.length != 0) {
      setState(() {
        _ContractxModels.clear();
      });
    }
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc_ = preferences.getString('usercid');
    var qutser_ = preferences.getString('qutser');
    ////////////////------------------------------------------------------>

    if (qutser_ == '1') {
      String url =
          '${MyConstant().domain_chao}/GC_exp_wherser.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_';
      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        print(result);
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

    if (_cser == null) {
      setState(() {
        _celvat = _ContractxModels[0].nvat;
        _cname =
            '${_ContractxModels[0].expname}( ${_ContractxModels[0].unit} )\n${_ContractxModels[0].meter}';
        _cnamex = '${_ContractxModels[0].expname}';
        _cser = _ContractxModels[0].ser;
        _cunitser = _ContractxModels[0].unitser;
        _cunit = _ContractxModels[0].unit;
        _cqty_vat = _ContractxModels[0].qty;
      });
    }

    setState(() {
      red_Trans(_cser);
    });
  }

  ////-----------------------------------------------------
  Widget build(BuildContext context) {
    // List<Widget> data = [];
    // for (var i = 0; i < 50; i++) {
    //   data.add(
    //     Padding(
    //       padding: const EdgeInsets.all(4.0),
    //       child: Row(
    //         children: [
    //           Expanded(
    //             child: Container(
    //               alignment: Alignment.center,
    //               width: 100,
    //               child: const Text(
    //                 "ธันวาคม",
    //                 style: TextStyle(fontSize: 13),
    //               ),
    //             ),
    //           ),
    //           Expanded(
    //             child: Container(
    //               alignment: Alignment.center,
    //               child: const Text(
    //                 "553",
    //                 style: TextStyle(fontSize: 13),
    //               ),
    //             ),
    //           ),
    //           Expanded(
    //             child: Container(
    //               alignment: Alignment.center,
    //               width: 65,
    //               child: const Text(
    //                 "33",
    //                 style: TextStyle(fontSize: 13),
    //               ),
    //             ),
    //           ),
    //           Expanded(
    //             child: Container(
    //               alignment: Alignment.center,
    //               width: 60,
    //               child: const Text(
    //                 "198.00",
    //                 style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }
    return Scaffold(
        backgroundColor: bgcolor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ตรวจสอบมิเตอร์ ',
                style: const TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontFamily: FontWeight_.Fonts_T,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Color.fromARGB(255, 184, 198, 133),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: ScrollConfiguration(
                  behavior:
                      ScrollConfiguration.of(context).copyWith(dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  }),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    dragStartBehavior: DragStartBehavior.start,
                    child: Row(
                      children: [
                        for (int index = 0;
                            index < _ContractxModels.length;
                            index++)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _celvat = _ContractxModels[index].nvat;
                                  _cname =
                                      '${_ContractxModels[index].expname}( ${_ContractxModels[index].unit} )\n${_ContractxModels[index].meter}';
                                  _cnamex =
                                      '${_ContractxModels[index].expname}';
                                  _cser = _ContractxModels[index].ser;
                                  _cunitser = _ContractxModels[index].unitser;
                                  _cunit = _ContractxModels[index].unit;
                                  _cqty_vat = _ContractxModels[index].qty;

                                  red_Trans(_cser);
                                  Ser__TapContractx = index;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: (Ser__TapContractx == index)
                                      ? Color.fromARGB(255, 130, 165, 155)
                                      : Color.fromARGB(255, 166, 159, 130),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(0)),
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AutoSizeText(
                                          minFontSize: 10,
                                          maxFontSize: 25,
                                          maxLines: 1,
                                          '${_ContractxModels[index].expname}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: (Ser__TapContractx == index)
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,

                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AutoSizeText(
                                          minFontSize: 10,
                                          maxFontSize: 25,
                                          maxLines: 1,
                                          '( ${_ContractxModels[index].unit} )',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: (Ser__TapContractx == index)
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,

                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AutoSizeText(
                                          minFontSize: 10,
                                          maxFontSize: 25,
                                          maxLines: 1,
                                          '${_ContractxModels[index].meter}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: (Ser__TapContractx == index)
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,

                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Text(
                                //   '${_ContractxModels[index].expname}( ${_ContractxModels[index].unit} )\n${_ContractxModels[index].meter}',
                                //   textAlign: TextAlign.center,
                                //   style: const TextStyle(
                                //       color: Colors.black,
                                //       fontWeight: FontWeight.bold,
                                //       fontSize: 15.0),
                                // ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: ScrollConfiguration(
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
                              width: (Responsive.isDesktop(context))
                                  ? MediaQuery.of(context).size.width * 0.98
                                  : 900,
                              alignment: Alignment.center,
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
                              child: Column(children: [
                                Container(
                                  height: 60,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 201, 196, 186),
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(0)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                            alignment: Alignment.center,
                                            width: 90,
                                            child: const Text("เดือน",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ))),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                            width: 50,
                                            alignment: Alignment.center,
                                            child: Column(
                                              children: [
                                                const Text("ก่อน",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const Text("เลขมิเตอร์(หน่วย)",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            FontWeight_.Fonts_T,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            )),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                            alignment: Alignment.center,
                                            width: 65,
                                            child: Column(
                                              children: [
                                                const Text("หลัง",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const Text("เลขมิเตอร์(หน่วย)",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            FontWeight_.Fonts_T,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            )),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                            alignment: Alignment.center,
                                            width: 65,
                                            child: Column(
                                              children: [
                                                Text('ราคาต่อหน่วย $_cqty_vat',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            FontWeight_.Fonts_T,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text('ใช้ไป(หน่วย)',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            FontWeight_.Fonts_T,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            )),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                            alignment: Alignment.center,
                                            width: 65,
                                            child: Column(
                                              children: [
                                                Text('ยอดเงิน',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            FontWeight_.Fonts_T,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text('(รวม vat $_celvat %)',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            FontWeight_.Fonts_T,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            )),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                            alignment: Alignment.center,
                                            width: 60,
                                            child: const Text(
                                              "หลักฐาน",
                                              style: TextStyle(
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: _TransModels.isEmpty
                                        ? SizedBox(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 50,
                                                  width: 50,
                                                  child: LoadingIndicator(
                                                    indicatorType:
                                                        Indicator.values[30],
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
                                                          milliseconds: 25),
                                                      (i) => i),
                                                  builder: (context, snapshot) {
                                                    if (!snapshot.hasData)
                                                      return const Text('');
                                                    double elapsed =
                                                        double.parse(snapshot
                                                                .data
                                                                .toString()) *
                                                            0.05;
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
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
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily: Font_
                                                                    .Fonts_T,
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
                                            // controller: _scrollController1,
                                            // itemExtent: 50,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: _TransModels.length,
                                            itemBuilder: (BuildContext context,
                                                int indextran) {
                                              // ignore: curly_braces_in_flow_control_structures
                                              return Material(
                                                  // color: tappedIndex_1 ==
                                                  //         indextran.toString()
                                                  //     ? tappedIndex_Color.tappedIndex_Colors
                                                  //     : AppbackgroundColor.Sub_Abg_Colors,
                                                  child: Container(
                                                      // color: tappedIndex_1 ==
                                                      //         indextran.toString()
                                                      //     ? tappedIndex_Color
                                                      //         .tappedIndex_Colors
                                                      //         .withOpacity(0.5)
                                                      //     : null,
                                                      child: ListTile(
                                                          onTap: () {
                                                            setState(() {
                                                              tappedIndex_1 =
                                                                  indextran
                                                                      .toString();
                                                            });
                                                          },
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
                                                                    child: Text(
                                                                      // ignore: unnecessary_string_interpolations
                                                                      '${DateFormat.MMMM('th_TH').format((DateTime.parse('${_TransModels[indextran].date} 00:00:00')))}\n${DateTime.parse('${_TransModels[indextran].date} 00:00:00').year + 543}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontFamily:
                                                                            Font_.Fonts_T,
                                                                        //fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: _cunitser !=
                                                                            '6'
                                                                        ? Text(
                                                                            '$_cunit',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.black,
                                                                              fontFamily: Font_.Fonts_T,
                                                                              //fontWeight: FontWeight.bold,
                                                                            ),
                                                                          )
                                                                        : Container(
                                                                            child: indextran == 0
                                                                                ? _TransModels[indextran].ovalue != null
                                                                                    ? Text(
                                                                                        indextran == 0
                                                                                            ? '${_TransModels[indextran].ovalue!.padLeft(4, '0')}' // '${nFormat.format(double.parse(_TransModels[indextran].ovalue!))}'
                                                                                            //'${_TransModels[indextran].ovalue}'
                                                                                            : '${_TransModels[indextran - 1].nvalue!.padLeft(4, '0')}', //'${nFormat.format(double.parse(_TransModels[indextran - 1].nvalue!))}',
                                                                                        // '${_TransModels[indextran - 1].nvalue}',
                                                                                        textAlign: TextAlign.right,
                                                                                        style: const TextStyle(
                                                                                          color: Colors.black, fontFamily: Font_.Fonts_T,
                                                                                          //fontWeight: FontWeight.bold,
                                                                                        ),
                                                                                      )
                                                                                    : Text(
                                                                                        indextran == 0 ? "${_TransModels[indextran].ovalue}" : "${_TransModels[indextran - 1].nvalue}",
                                                                                        textAlign: TextAlign.right,
                                                                                        style: const TextStyle(
                                                                                          color: Colors.black, fontFamily: Font_.Fonts_T,
                                                                                          //fontWeight: FontWeight.bold,
                                                                                        ),
                                                                                      )
                                                                                : Text(
                                                                                    indextran == 0
                                                                                        ? '${_TransModels[indextran].ovalue!.padLeft(4, '0')}' //'${nFormat.format(double.parse(_TransModels[indextran].ovalue!))}'
                                                                                        // '${_TransModels[indextran].ovalue}'
                                                                                        : _TransModels[indextran - 1].nvalue == null
                                                                                            ? ''
                                                                                            : '${_TransModels[indextran - 1].nvalue!.padLeft(4, '0')}', // '${nFormat.format(double.parse(_TransModels[indextran - 1].nvalue!))}',
                                                                                    //'${_TransModels[indextran - 1].nvalue}',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: const TextStyle(
                                                                                      color: Colors.black, fontFamily: Font_.Fonts_T,
                                                                                      //fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  ),
                                                                          ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: _cunitser !=
                                                                            '6'
                                                                        ? Text(
                                                                            '$_cunit',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.black,
                                                                              fontFamily: Font_.Fonts_T,
                                                                              //fontWeight: FontWeight.bold,
                                                                            ),
                                                                          )
                                                                        : _TransModels[indextran].docno_in == null ||
                                                                                _TransModels[indextran].docno_in == ''
                                                                            ? Text(
                                                                                '${_TransModels[indextran].nvalue}', // '${nFormat.format(double.parse(_TransModels[indextran].nvalue!))}',
                                                                                // '${_TransModels[indextran].nvalue}',
                                                                                textAlign: TextAlign.right,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: const TextStyle(
                                                                                  color: Colors.black, fontFamily: Font_.Fonts_T,
                                                                                  //fontWeight: FontWeight.bold,
                                                                                ),
                                                                              )
                                                                            : Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: Text(
                                                                                  '${_TransModels[indextran].nvalue!.padLeft(4, '0')}', // '${nFormat.format(double.parse(_TransModels[indextran].nvalue!))}',
                                                                                  // '${_TransModels[indextran].nvalue}',
                                                                                  textAlign: TextAlign.right,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: const TextStyle(
                                                                                    color: Colors.black, fontFamily: Font_.Fonts_T,
                                                                                    //fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                      '${nFormat.format(double.parse(_TransModels[indextran].qty5!))}',
                                                                      // '${_TransModels[indextran].qty5}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontFamily:
                                                                            Font_.Fonts_T,
                                                                        //fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                      '${nFormat.format(double.parse(_TransModels[indextran].amt!))}',
                                                                      //  '${_TransModels[indextran].amt}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontFamily:
                                                                            Font_.Fonts_T,
                                                                        //fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets
                                                                          .fromLTRB(
                                                                              15,
                                                                              8,
                                                                              15,
                                                                              8),
                                                                      child: Container(
                                                                          decoration: BoxDecoration(
                                                                            color: (_TransModels[indextran].img == null || _TransModels[indextran].img.toString() == '')
                                                                                ? Colors.grey
                                                                                : Colors.green[300],
                                                                            borderRadius:
                                                                                const BorderRadius.only(
                                                                              topLeft: Radius.circular(15),
                                                                              topRight: Radius.circular(15),
                                                                              bottomLeft: Radius.circular(15),
                                                                              bottomRight: Radius.circular(15),
                                                                            ),
                                                                            border:
                                                                                Border.all(color: Colors.grey, width: 1),
                                                                          ),
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child:
                                                                              // (_TransModels[
                                                                              //                 indextran]
                                                                              //             .docno_in !=
                                                                              //         '')
                                                                              //     ?
                                                                              InkWell(
                                                                            onTap: (_TransModels[indextran].img == null || _TransModels[indextran].img.toString() == '')
                                                                                ? null
                                                                                : () {
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder: (_) => Dialog(
                                                                                        child: SizedBox(
                                                                                          // width: MediaQuery.of(context)
                                                                                          //     .size
                                                                                          //     .width,
                                                                                          child: (_TransModels.isEmpty || _TransModels[indextran].img.toString() == '' || _TransModels[indextran].img == null)
                                                                                              ? Center(child: Icon(Icons.image_not_supported))
                                                                                              : Image.network(
                                                                                                  // '${MyConstant().domain}/files/kad_taii/logo/${Img_logo_}',
                                                                                                  '${MyConstant().domain_chao}/files/$foder/Meter/${_TransModels[indextran].img}',
                                                                                                  fit: BoxFit.cover,
                                                                                                ),
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                            child:
                                                                                Text(
                                                                              (_TransModels[indextran].img == null || _TransModels[indextran].img.toString() == '') ? 'ไม่พบหลักฐาน' : 'พบหลักฐาน',
                                                                              maxLines: 1,
                                                                              textAlign: TextAlign.center,
                                                                              style: const TextStyle(
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontFamily: FontWeight_.Fonts_T,
                                                                              ),
                                                                            ),
                                                                          )),
                                                                    ),
                                                                  ),
                                                                ]),
                                                          ))));
                                            })),
                              ])),
                        ],
                      ),
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
                            fontFamily: FontWeight_.Fonts_T,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
