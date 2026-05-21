import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constant/Myconstant.dart';
import '../Model/GetContractx_Model.dart';
import '../Model/GetTrans_Model.dart';
import '../color.dart';

class MwterScreen extends StatefulWidget {
  const MwterScreen({super.key});

  @override
  State<MwterScreen> createState() => _MwterScreenState();
}

class _MwterScreenState extends State<MwterScreen> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  List<ContractxModel> _ContractxModels = [];
  List<TransModel> _TransModels = [];
  int? Ser__TapContractx = 0;
  String? _celvat,
      _cname,
      _cnamex,
      _cmeter,
      _cser,
      _cunitser,
      _cqty_vat,
      _cunit;
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
      cus_zn;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    red_exp_wherser();
    checkPreferance();
  }

  Future<Null> checkPreferance() async {
    DateTime currentDate = DateTime.now();

    // Format the date as 'YYYY-MM-DD'
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
 String new_Url = MyConstant().domain_chao;
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
      cus_imglogo_ =
          '$new_Url/files/$cus_foder/contract/$cus_photo';
    }
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

    if (_cser == null) {
      setState(() {
        _celvat = _ContractxModels[0].nvat;
        _cname =
            '${_ContractxModels[0].expname!.trim()}( ${_ContractxModels[0].unit} )\n${_ContractxModels[0].meter}';
        _cmeter = _ContractxModels[0].meter;
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

  Future<Null> red_Trans(_cser) async {
    if (_TransModels.length != 0) {
      setState(() {
        _TransModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = preferences.getString('usercid');
    var qutser = 1;

    String url = _cser == null
        ? '${MyConstant().domain_chao}/GC_quotx_consx.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&_cser=${_ContractxModels[0].ser}}'
        : '${MyConstant().domain_chao}/GC_quotx_consx.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&_cser=$_cser';
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

    if (_cser == null) {
      setState(() {
        _celvat = _ContractxModels[0].nvat;
        _cname =
            '${_ContractxModels[0].expname!.trim()}( ${_ContractxModels[0].unit} )\n${_ContractxModels[0].meter}';
        _cmeter = _ContractxModels[0].meter;
        _cnamex = '${_ContractxModels[0].expname}';
        _cser = _ContractxModels[0].ser;
        _cunitser = _ContractxModels[0].unitser;
        _cunit = _ContractxModels[0].unit;
        _cqty_vat = _ContractxModels[0].qty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      body: SingleChildScrollView(
          child: Column(
        children: [
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.width * 0.25,
                padding: EdgeInsets.all(8),
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
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _celvat = _ContractxModels[index].nvat;
                                  _cname =
                                      '${_ContractxModels[index].expname!.trim()}( ${_ContractxModels[index].unit} )\n${_ContractxModels[index].meter}';
                                  _cmeter = _ContractxModels[index].meter;
                                  _cnamex =
                                      '${_ContractxModels[index].expname}';
                                  _cser = _ContractxModels[index].ser;
                                  _cunitser = _ContractxModels[index].unitser;
                                  _cunit = _ContractxModels[index].unit;
                                  _cqty_vat = _ContractxModels[index].qty;

                                  Ser__TapContractx = index;
                                  red_Trans(_cser);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: (Ser__TapContractx == index)
                                      ? Colors.blue[200]
                                      : Colors.grey.shade300,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15)),
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                ),
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
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T
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
                                          maxFontSize: 18,
                                          maxLines: 1,
                                          '( ${_ContractxModels[index].meter} )',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black,
                                              // (Ser__TapContractx == index)
                                              //     ? Colors.white
                                              //     : Colors.black,
                                              fontFamily: Font_.Fonts_T
                                              //fontSize: 10.0
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _ContractxModels.isEmpty
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0)),
                          border: Border.all(
                              color: Colors.white, style: BorderStyle.solid),
                          color: Colors.blue[200],
                        ),
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  maxLines: 2,
                                  minFontSize: 16,
                                  // maxFontSize: 15,
                                  '$_cnamex | เลขมิเตอร์: $_cmeter',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      // fontWeight: FontWeight.bold,
                                      fontFamily: Font_.Fonts_T

                                      //fontSize: 10.0
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(0),
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15)),
                          border: Border.all(
                              color: Colors.white, style: BorderStyle.solid),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: AutoSizeText(
                                      maxLines: 2,
                                      minFontSize: 16,
                                      // maxFontSize: 15,
                                      'เดือน',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          // fontWeight: FontWeight.bold,
                                          fontFamily: Font_.Fonts_T

                                          //fontSize: 10.0
                                          ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Column(
                                      children: [
                                        AutoSizeText(
                                          maxLines: 2,
                                          minFontSize: 16,
                                          // maxFontSize: 15,
                                          'เลขมิเตอร์',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              // fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T

                                              //fontSize: 10.0
                                              ),
                                        ),
                                        AutoSizeText(
                                          maxLines: 2,
                                          minFontSize: 16,
                                          // maxFontSize: 15,
                                          'ก่อน',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              // fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T

                                              //fontSize: 10.0
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      AutoSizeText(
                                        maxLines: 2,
                                        minFontSize: 16,
                                        // maxFontSize: 15,
                                        'เลขมิเตอร์',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T

                                            //fontSize: 10.0
                                            ),
                                      ),
                                      AutoSizeText(
                                        maxLines: 2,
                                        minFontSize: 16,
                                        // maxFontSize: 15,
                                        'หลัง',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T

                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(),
                                )
                                // Expanded(
                                //   flex: 2,
                                //   child: AutoSizeText(
                                //     maxLines: 2,
                                //     minFontSize: 16,
                                //     // maxFontSize: 15,
                                //     'ใช้ไป',
                                //     textAlign: TextAlign.center,
                                //     style: const TextStyle(
                                //         color: Colors.black,
                                //         // fontWeight: FontWeight.bold,
                                //         fontFamily: Font_.Fonts_T

                                //         //fontSize: 10.0
                                //         ),
                                //   ),
                                // ),
                                // Expanded(
                                //   flex: 2,
                                //   child: AutoSizeText(
                                //     maxLines: 2,
                                //     minFontSize: 16,
                                //     // maxFontSize: 15,
                                //     'ยอด',
                                //     textAlign: TextAlign.center,
                                //     style: const TextStyle(
                                //         color: Colors.black,
                                //         // fontWeight: FontWeight.bold,
                                //         fontFamily: Font_.Fonts_T

                                //         //fontSize: 10.0
                                //         ),
                                //   ),
                                // ),
                              ],
                            ),
                            Divider(),
                            Container(
                              child: ListView.builder(
                                // physics:
                                //     const NeverScrollableScrollPhysics(), // AlwaysScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _TransModels.length,
                                itemBuilder:
                                    (BuildContext context, int indextran) {
                                  // ignore: curly_braces_in_flow_control_structures
                                  return Container(
                                    color: DateFormat('MMyyyy')
                                                .format(DateTime.now()) ==
                                            DateFormat('MMyyyy').format(
                                                DateTime.parse(
                                                    '${_TransModels[indextran].date} 00:00:00'))
                                        ? Colors.lime.shade500
                                        : Colors.transparent,
                                    child: ListTile(
                                      onTap: () {},
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: AutoSizeText(
                                                maxLines: 2,
                                                minFontSize: 16,
                                                // maxFontSize: 15,
                                                '${DateFormat.MMMM('th_TH').format((DateTime.parse('${_TransModels[indextran].date} 00:00:00')))}\n${DateTime.parse('${_TransModels[indextran].date} 00:00:00').year + 543}',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    // fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T

                                                    //fontSize: 10.0
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  AutoSizeText(
                                                    maxLines: 2,
                                                    minFontSize: 16,
                                                    // maxFontSize: 15,
                                                    indextran == 0
                                                        ? _TransModels[indextran]
                                                                    .ovalue ==
                                                                null
                                                            ? '0000'
                                                            : '${_TransModels[indextran].ovalue!.padLeft(4, '0')}'
                                                        : _TransModels[indextran -
                                                                        1]
                                                                    .nvalue ==
                                                                null
                                                            ? ''
                                                            : '${_TransModels[indextran - 1].nvalue!.padLeft(4, '0')}',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        // fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T

                                                        //fontSize: 10.0
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              children: [
                                                AutoSizeText(
                                                  maxLines: 2,
                                                  minFontSize: 16,
                                                  // maxFontSize: 15,
                                                  _TransModels[indextran]
                                                              .nvalue ==
                                                          null
                                                      ? ''
                                                      : '${_TransModels[indextran].nvalue!.padLeft(4, '0')}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T

                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: IconButton(
                                                onPressed: () {
                                                  showdialog_metter(indextran);
                                                },
                                                icon: Icon(
                                                    Icons.more_horiz_outlined),
                                              ))
                                          // Expanded(
                                          //   flex: 2,
                                          //   child: AutoSizeText(
                                          //     maxLines: 2,
                                          //     minFontSize: 16,
                                          //     // maxFontSize: 15,

                                          //     _TransModels[indextran].nvalue ==
                                          //             null
                                          //         ? ''
                                          //         : _TransModels[indextran]
                                          //                     .nvalue!
                                          //                     .padLeft(
                                          //                         4, '0') ==
                                          //                 '0000'
                                          //             ? ''
                                          //             : '${nFormat.format(double.parse(_TransModels[indextran].qty5!))}',

                                          //     textAlign: TextAlign.center,
                                          //     style: const TextStyle(
                                          //         color: Colors.black,
                                          //         // fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T

                                          //         //fontSize: 10.0
                                          //         ),
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   flex: 2,
                                          //   child: AutoSizeText(
                                          //     maxLines: 2,
                                          //     minFontSize: 16,
                                          //     // maxFontSize: 15,
                                          //     _TransModels[indextran].nvalue ==
                                          //             null
                                          //         ? ''
                                          //         : nFormat.format(double.parse(
                                          //                     _TransModels[
                                          //                             indextran]
                                          //                         .amt!)) ==
                                          //                 '0.00'
                                          //             ? ''
                                          //             : '${nFormat.format(double.parse(_TransModels[indextran].amt!))}',

                                          //     textAlign: TextAlign.center,
                                          //     style: const TextStyle(
                                          //         color: Colors.black,
                                          //         // fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T

                                          //         //fontSize: 10.0
                                          //         ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      )),
    );
  }

  showdialog_metter(int indextran) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Column(
              children: [
                Text(
                  textAlign: TextAlign.center,
                  '${DateFormat.MMMM('th_TH').format((DateTime.parse('${_TransModels[indextran].date} 00:00:00')))} | ${DateTime.parse('${_TransModels[indextran].date} 00:00:00').year + 543}',
                  style: TextStyle(
                    fontFamily: FontWeight_.Fonts_T,
                  ),
                ),
                Text(
                  textAlign: TextAlign.center,
                  _TransModels[indextran].docno_in != '' &&
                          _TransModels[indextran].docno_in != 'null' &&
                          _TransModels[indextran].docno_in != null
                      ? 'วางบิล/ชำระแล้ว'
                      : 'ยังไม่ชำระ',
                  // '${_TransModels[indextran].docno_in}',
                  style: TextStyle(
                    color: _TransModels[indextran].docno_in != '' &&
                            _TransModels[indextran].docno_in != 'null' &&
                            _TransModels[indextran].docno_in != null
                        ? Colors.green
                        : Colors.red,
                    fontFamily: Font_.Fonts_T,
                  ),
                ),
              ],
            ),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            'เลขมิเตอร์',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            'ก่อน : ',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            indextran == 0
                                ? _TransModels[indextran].ovalue == null
                                    ? '0000'
                                    : '${_TransModels[indextran].ovalue!.padLeft(4, '0')}'
                                : _TransModels[indextran - 1].nvalue == null
                                    ? ''
                                    : '${_TransModels[indextran - 1].nvalue!.padLeft(4, '0')}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            'หน่วย',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            'หลัง : ',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            _TransModels[indextran].nvalue == null
                                ? ''
                                : '${_TransModels[indextran].nvalue!.padLeft(4, '0')}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T
                                //fontSize: 10.0
                                ),
                          ),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            'หน่วย',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T
                                //fontSize: 10.0
                                ),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            'หน่วยที่ใช่ไป',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            _TransModels[indextran].nvalue == null
                                ? ''
                                : _TransModels[indextran]
                                            .nvalue!
                                            .padLeft(4, '0') ==
                                        '0000'
                                    ? ''
                                    : '${nFormat.format(double.parse(_TransModels[indextran].qty5!))}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            'หน่วย',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            'หน่วยละ',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            '$_cqty_vat',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            'บาท/หน่วย',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            'รวม',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            '${nFormat.format(double.parse(_TransModels[indextran].pvat!))}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            'บาท',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            'VAT %',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            '${_TransModels[indextran].nvat}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            'เปอร์เซนต์',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            '',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            '${nFormat.format(double.parse(_TransModels[indextran].vat!))}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            'บาท',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            'ยอดรวม',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            '',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            '${_TransModels[indextran].amt}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            maxLines: 1,
                            minFontSize: 16,
                            // maxFontSize: 15,
                            'บาท',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T

                                //fontSize: 10.0
                                ),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                            child: _TransModels[indextran].img == null ||
                                    _TransModels[indextran].img.toString() == ''
                                ? SizedBox()
                                : SizedBox(
                                    height: MediaQuery.of(context).size.width *
                                        0.25,
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => Dialog(
                                            child: SizedBox(
                                              // width: MediaQuery.of(context)
                                              //     .size
                                              //     .width,
                                              child: (_TransModels.isEmpty ||
                                                      _TransModels[indextran]
                                                              .img
                                                              .toString() ==
                                                          '' ||
                                                      _TransModels[indextran]
                                                              .img ==
                                                          null)
                                                  ? Center(
                                                      child: Icon(Icons
                                                          .image_not_supported))
                                                  : Image.network(
                                                      // '${MyConstant().domain}/files/kad_taii/logo/${Img_logo_}',
                                                      '${MyConstant().domain_chao}/files/$cus_foder/Meter/${_TransModels[indextran].img}',
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Image.network(
                                        // '${MyConstant().domain}/files/kad_taii/logo/${Img_logo_}',
                                        '${MyConstant().domain_chao}/files/$cus_foder/Meter/${_TransModels[indextran].img}',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 120,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(
                                        width: 1, color: Colors.black),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6))),
                                child: const Text(
                                  "ปิด",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: Font_.Fonts_T,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
