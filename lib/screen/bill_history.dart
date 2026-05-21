// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart' as grb;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../Beam/webviewPay_beamcheckout.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Man_PDF/Man_Pay_Receipt_PDF.dart';
import '../Model/GetFinnancetrans_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/trans_re_bill_history_model.dart';
import '../Model/trans_re_bill_model.dart';
import '../Responsive/responsive.dart';
import '../color.dart';
import 'package:pdf/widgets.dart' as pw;

class BillHistory extends StatefulWidget {
  const BillHistory({super.key, this.animationController});
  final AnimationController? animationController;
  @override
  State<BillHistory> createState() => _BillHistoryState();
}

class _BillHistoryState extends State<BillHistory> {
  List<TransReBillModel> limitedList_TransReBillModels_ = [];
  List<RenTalModel> renTalModels = [];
  ScrollController _scrollController2 = ScrollController();
  var nFormat = NumberFormat("#,##0.00", "en_US");
  final Formbecause_ = TextEditingController();
  int sucsess = 0;
  String? renTal_user,
      renTal_name,
      zone_ser,
      zone_name,
      Value_cid,
      fname_,
      tem_page_ser,
      pdate;
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
      zone_Subser,
      zone_Subname,
      newValuePDFimg_QR;
  String _ReportValue_type = "ไม่ระบุ";
  List<FinnancetransModel> finnancetransModels = [];

  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_disamt = 0.00,
      sum_disp = 0,
      dis_sum_Matjum = 0.00,
      sum_duesbill = 0.00;
  String? numinvoice, numdoctax, Slip_history;
  List<TransReBillHistoryModel> _TransReBillHistoryModels = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    red_Trans_bill();
    read_GC_rental();
  }

  Future<Null> read_GC_rental() async {
    if (renTalModels.isNotEmpty) {
      renTalModels.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain_chao}/GC_rental_setring.php?isAdd=true&ren=$ren';
    renTal_name = preferences.getString('renTalName');
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
          var billNamex = renTalModel.bill_name!.trim();
          var billAddrx = renTalModel.bill_addr!.trim();
          var billTaxx = renTalModel.bill_tax!.trim();
          var billTelx = renTalModel.bill_tel!.trim();
          var billEmailx = renTalModel.bill_email!.trim();
          var billDefaultx = renTalModel.bill_default;
          var billTserx = renTalModel.tser;
          var name = renTalModel.pn!.trim();
          var foderx = renTalModel.dbn;
          setState(() {
            _ReportValue_type = (renTalModel.receipt_title! == '0')
                ? 'ไม่ระบุ'
                : (renTalModel.receipt_title! == '1')
                    ? 'ต้นฉบับ'
                    : 'สำเนา';
            foder = foderx;
            rtname = rtnamex;
            type = typexs;
            typex = typexx;
            renname = name;
            bill_name = billNamex;
            bill_addr = billAddrx;
            bill_tax = billTaxx;
            bill_tel = billTelx;
            bill_email = billEmailx;
            bill_default = billDefaultx;
            bill_tser = billTserx;
            tem_page_ser = renTalModel.tem_page!.trim();
            renTalModels.add(renTalModel);
            if (billDefaultx == 'P') {
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

  Future<Null> red_Trans_bill() async {
    if (limitedList_TransReBillModels_.length != 0) {
      setState(() {
        limitedList_TransReBillModels_.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc_ = preferences.getString('usercid');
    // var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain_chao}/GC_bill_pay_BC_Verifi_cid.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);
          var sess = int.parse(transReBillModel.pos!);
          if (sess != 1) {
            setState(() {
              sucsess = sucsess + sess;
              limitedList_TransReBillModels_.add(transReBillModel);
            });
          }
        }
      }
    } catch (e) {}
  }

  Future<Null> red_Trans_select(index) async {
    if (_TransReBillHistoryModels.length != 0) {
      setState(() {
        _TransReBillHistoryModels.clear();
        sum_pvat = 0;
        sum_vat = 0;
        sum_wht = 0;
        sum_amt = 0;
        // sum_disamt = 0;
        // sum_disp = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = limitedList_TransReBillModels_[index].ser;
    var qutser = limitedList_TransReBillModels_[index].ser_in;
    var docnoin = limitedList_TransReBillModels_[index].docno;
    String url =
        '${MyConstant().domain_chao}/GC_bill_pay_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      print('1230>>>> $result');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillHistoryModel _TransReBillHistoryModel =
              TransReBillHistoryModel.fromJson(map);
          var dtypeinvoiceent = _TransReBillHistoryModel.dtype;
          var numinvoiceent = _TransReBillHistoryModel.docno;
          // var sumPvatx = double.parse(_TransReBillHistoryModel.pvat!);
          // var sumVatx = double.parse(_TransReBillHistoryModel.vat!);
          // var sumWhtx = double.parse(_TransReBillHistoryModel.wht!);
          // var sumAmtx = double.parse(_TransReBillHistoryModel.total!);

          var sum_pvatx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.pvat!)
              : 0.0;
          var sum_vatx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.vat!)
              : 0.0;
          var sum_whtx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.wht!)
              : 0.0;
          var sum_amtx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.total!)
              : 0.0;
          // var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          // var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          // var numinvoiceent = _TransReBillHistoryModel.docno;
          // setState(() {
          //   sum_pvat = sum_pvat + sumPvatx;
          //   sum_vat = sum_vat + sumVatx;
          //   sum_wht = sum_wht + sumWhtx;
          //   sum_amt = sum_amt + sumAmtx;
          //   // sum_disamt = sum_disamtx;
          //   // sum_disp = sum_dispx;
          //   numinvoice = _TransReBillHistoryModel.docno;
          //   numdoctax = _TransReBillHistoryModel.doctax;
          //   _TransReBillHistoryModels.add(_TransReBillHistoryModel);
          // });

          setState(() {
            if (dtypeinvoiceent == 'KP') {
              sum_pvat = sum_pvat + sum_pvatx;
              sum_vat = sum_vat + sum_vatx;
              sum_wht = sum_wht + sum_whtx;
              sum_amt = sum_amt + sum_amtx;
              // sum_disamt = sum_disamtx;
              // sum_disp = sum_dispx;
              numinvoice = _TransReBillHistoryModel.docno;
              numdoctax = _TransReBillHistoryModel.doctax;
              _TransReBillHistoryModels.add(_TransReBillHistoryModel);
            } else if (dtypeinvoiceent == '!Z') {
              sum_pvat = sum_pvat + sum_pvatx;
              sum_vat = sum_vat + sum_vatx;
              sum_wht = sum_wht + sum_whtx;
              sum_amt = sum_amt + sum_amtx;
              // sum_disamt = sum_disamtx;
              // sum_disp = sum_dispx;
              numinvoice = _TransReBillHistoryModel.docno;
              numdoctax = _TransReBillHistoryModel.doctax;
              _TransReBillHistoryModels.add(_TransReBillHistoryModel);
            } else {
              // total_amt = total_amt + total_amtx;
              _TransReBillHistoryModels.add(_TransReBillHistoryModel);
            }
          });
        }
      }
      // setState(() {
      //   red_Invoice(index);
      // });
    } catch (e) {}
  }

  Future<Null> red_Invoice(index) async {
    if (finnancetransModels.length != 0) {
      setState(() {
        finnancetransModels.clear();
        sum_disamt = 0;
        sum_disp = 0;
        dis_sum_Matjum = 0.00;
        sum_duesbill = 0.00;
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = limitedList_TransReBillModels_[index].cid;
    var qutser = limitedList_TransReBillModels_[index].ser_in;
    var docnoin =
        limitedList_TransReBillModels_[index].docno; //.toString().trim()
    print('>>>>>>>>>>>dd>>> in d  $docnoin');

    String url =
        '${MyConstant().domain_chao}/GC_bill_pay_amt.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      print('BBBBBBBBBBBBBBBB>>>> $result');
      if (result.toString() != 'null') {
        for (var map in result) {
          FinnancetransModel finnancetransModel =
              FinnancetransModel.fromJson(map);

          var sidamt = double.parse(finnancetransModel.amt!);
          var siddisper = double.parse(finnancetransModel.disper!);
          var pdatex = finnancetransModel.pdate;

          setState(() {
            Slip_history = finnancetransModel.slip.toString();
            pdate = pdatex;
            if (int.parse(finnancetransModel.receiptSer!) != 0) {
              finnancetransModels.add(finnancetransModel);
            } else {
              if (finnancetransModel.type!.trim() == 'DISCOUNT') {
                sum_disamt = sidamt;
                sum_disp = siddisper;
              }
            }
          });
          print('>>pdate>>> $pdate');
          if (finnancetransModel.dtype! == 'MM') {
            setState(() {
              dis_sum_Matjum =
                  dis_sum_Matjum + double.parse(finnancetransModel.amt!);
            });
          }

          if (finnancetransModel.dtype! == 'FTA') {
            setState(() {
              sum_duesbill = double.parse(finnancetransModel.amt!);
            });
          }
          print(
              '>>>>> ${finnancetransModel.slip}>>>>>>dd>>> in $sidamt $siddisper  ');
        }
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                top: 8.0,
                right: 8.0,
                bottom: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: grey, style: BorderStyle.solid),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'บิลใบเสร็จรับเงิน',
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
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: Padding(
                    //         padding: EdgeInsets.only(
                    //             right: 8.0, left: 8.0, bottom: 8.0),
                    //         child: Text(
                    //           'รอดำเนินการ',
                    //           style: TextStyle(
                    //             fontSize: 16,
                    //             color: Color.fromRGBO(100, 108, 110, 1),
                    //             fontFamily: Font_.Fonts_T,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     Expanded(
                    //       child: Padding(
                    //         padding: EdgeInsets.only(
                    //             top: 8.0, right: 8.0, left: 8.0, bottom: 8.0),
                    //         child: Text(
                    //           '$sucsess บิล',
                    //           textAlign: TextAlign.end,
                    //           style: TextStyle(
                    //             fontSize: 14,
                    //             color: Color.fromRGBO(100, 108, 110, 1),
                    //             fontFamily: Font_.Fonts_T,
                    //           ),
                    //         ),
                    //       ),
                    //     )
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                top: 5.0,
                right: 8.0,
                bottom: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: grey, style: BorderStyle.solid),
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
                            ),
                            child: Text(
                              'เลขที่บิล',
                              textAlign: TextAlign.start,
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
                            padding: EdgeInsets.only(
                                top: 8.0, right: 8.0, left: 8.0),
                            child: Text(
                              'จำนวนเงิน',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: FontWeight_.Fonts_T,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Divider(),
                    Padding(
                        padding: EdgeInsets.all(0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                for (int index = 0;
                                    index <
                                        limitedList_TransReBillModels_.length;
                                    index++)
                                  Container(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    right: 8.0, left: 8.0),
                                                child: Text(
                                                  '${index + 1}.${limitedList_TransReBillModels_[index].docno}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  right: 8.0,
                                                  left: 8.0,
                                                ),
                                                child: Text(
                                                  '${nFormat.format(double.parse(limitedList_TransReBillModels_[index].total_bill!))}',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
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
                                              flex: 4,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    right: 8.0, left: 8.0),
                                                child: Text(
                                                  '${DateFormat.MMMEd('th_TH').format((DateTime.parse('${limitedList_TransReBillModels_[index].dateacc} 00:00:00')))} ${DateTime.parse('${limitedList_TransReBillModels_[index].dateacc} 00:00:00').year + 543}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color.fromRGBO(
                                                        100, 108, 110, 1),
                                                    fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    right: 8.0, left: 8.0),
                                                child: Text(
                                                  '',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        Colors.green.shade900,
                                                    fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                  padding: EdgeInsets.only(
                                                    right: 8.0,
                                                    left: 8.0,
                                                  ),
                                                  child: IconButton(
                                                      onPressed: () {
                                                        // showdialog_Coming();
                                                        //  tappedIndex_ =
                                                        //                 index
                                                        //                     .toString();
                                                        var ciddoc =
                                                            limitedList_TransReBillModels_[
                                                                    index]
                                                                .ser;
                                                        var qutser =
                                                            limitedList_TransReBillModels_[
                                                                    index]
                                                                .ser_in;
                                                        var docnoin =
                                                            limitedList_TransReBillModels_[
                                                                    index]
                                                                .docno;
                                                        print(
                                                            'object>> $ciddoc $qutser $docnoin ');

                                                        setState(() {
                                                          red_Trans_select(
                                                              index);
                                                          red_Invoice(index);
                                                        });
                                                        checkshowDialog(index);
                                                      },
                                                      icon: Icon(
                                                        Icons.download,
                                                        color: Colors
                                                            .grey.shade800,
                                                      ))),
                                            )
                                          ],
                                        ),
                                        // Row(
                                        //   children: [
                                        //     Expanded(
                                        //       child: Padding(
                                        //         padding: EdgeInsets.only(
                                        //             right: 8.0,
                                        //             left: 8.0,
                                        //             bottom: 8.0),
                                        //         child: Text(
                                        //           limitedList_TransReBillModels_[
                                        //                           index]
                                        //                       .shopno ==
                                        //                   '1'
                                        //               ? 'ออนไลน์'
                                        //               : 'เจ้าหน้าที่',
                                        //           textAlign: TextAlign.end,
                                        //           style: TextStyle(
                                        //             fontSize: 12,
                                        //             color: Color.fromRGBO(
                                        //                 100, 108, 110, 1),
                                        //             fontFamily: Font_.Fonts_T,
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                        Divider(),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> checkshowDialog(index) async {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.white,
                titlePadding: const EdgeInsets.all(0.0),
                contentPadding: const EdgeInsets.all(10.0),
                actionsPadding: const EdgeInsets.all(6.0),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.highlight_off,
                            size: 30, color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
                content: Padding(
                  padding: const EdgeInsets.all(0.0),
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
                          Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: Column(children: [
                                Row(
                                  children: [
                                    // Expanded(
                                    //   flex: 2,
                                    //   child: Container(
                                    //     height: 30,
                                    //     decoration: BoxDecoration(
                                    //       color: Colors.orange[100],
                                    //       borderRadius: const BorderRadius.only(
                                    //         topLeft: Radius.circular(10),
                                    //         topRight: Radius.circular(0),
                                    //         bottomLeft: Radius.circular(0),
                                    //         bottomRight: Radius.circular(0),
                                    //       ),
                                    //       // border: Border.all(
                                    //       //     color: Colors.grey, width: 1),
                                    //     ),
                                    //     // padding: const EdgeInsets.all(8.0),
                                    //     child: const Center(
                                    //       child: AutoSizeText(
                                    //         minFontSize: 8,
                                    //         maxFontSize: 14,
                                    //         'รายละเอียดบิล', //numinvoice
                                    //         textAlign: TextAlign.center,
                                    //         style: TextStyle(
                                    //             color: PeopleChaoScreen_Color
                                    //                 .Colors_Text1_,
                                    //             fontWeight: FontWeight.bold,
                                    //             fontFamily: FontWeight_.Fonts_T
                                    //             //fontSize: 10.0
                                    //             //fontSize: 10.0
                                    //             ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.orange[100],
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0),
                                          ),
                                          // border: Border.all(
                                          //     color: Colors.grey, width: 1),
                                        ),
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                            // border: Border.all(
                                            //     color: Colors.grey, width: 1),
                                          ),
                                          child: Center(
                                            child: AutoSizeText(
                                              minFontSize: 8,
                                              maxFontSize: 12,
                                              limitedList_TransReBillModels_[
                                                              index]
                                                          .doctax ==
                                                      ''
                                                  ? 'บิลเลขที่ ${limitedList_TransReBillModels_[index].docno}'
                                                  : 'บิลเลขที่ ${limitedList_TransReBillModels_[index].doctax}',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T
                                                  //fontSize: 10.0
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
                                  color: Colors.brown[200],
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    children: [
                                      // Expanded(
                                      //   flex: 1,
                                      //   child: AutoSizeText(
                                      //     minFontSize: 8,
                                      //     maxFontSize: 14,
                                      //     maxLines: 1,
                                      //     'ลำดับ',
                                      //     textAlign: TextAlign.start,
                                      //     style: TextStyle(
                                      //         color: PeopleChaoScreen_Color
                                      //             .Colors_Text1_,
                                      //         fontWeight: FontWeight.bold,
                                      //         fontFamily: FontWeight_.Fonts_T
                                      //         //fontSize: 10.0
                                      //         //fontSize: 10.0
                                      //         ),
                                      //   ),
                                      // ),
                                      // Expanded(
                                      //   flex: 1,
                                      //   child: AutoSizeText(
                                      //     minFontSize: 8,
                                      //     maxFontSize: 14,
                                      //     maxLines: 1,
                                      //     'วันที่ชำระ',
                                      //     textAlign: TextAlign.start,
                                      //     style: TextStyle(
                                      //         color: PeopleChaoScreen_Color
                                      //             .Colors_Text1_,
                                      //         fontWeight: FontWeight.bold,
                                      //         fontFamily: FontWeight_.Fonts_T
                                      //         //fontSize: 10.0
                                      //         //fontSize: 10.0
                                      //         ),
                                      //   ),
                                      // ),
                                      // Expanded(
                                      //   flex: 1,
                                      //   child: AutoSizeText(
                                      //     minFontSize: 8,
                                      //     maxFontSize: 14,
                                      //     maxLines: 1,
                                      //     'กำหนดชำระ',
                                      //     textAlign: TextAlign.start,
                                      //     style: TextStyle(
                                      //         color: PeopleChaoScreen_Color
                                      //             .Colors_Text1_,
                                      //         fontWeight: FontWeight.bold,
                                      //         fontFamily: FontWeight_.Fonts_T
                                      //         //fontSize: 10.0
                                      //         //fontSize: 10.0
                                      //         ),
                                      //   ),
                                      // ),
                                      Expanded(
                                        flex: 2,
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 14,
                                          maxLines: 1,
                                          'เลขตั้งหนี้',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text1_,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T
                                              //fontSize: 10.0
                                              //fontSize: 10.0
                                              ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 14,
                                          maxLines: 1,
                                          'รายการ',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text1_,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T
                                              //fontSize: 10.0
                                              //fontSize: 10.0
                                              ),
                                        ),
                                      ),
                                      // Expanded(
                                      //   flex: 1,
                                      //   child: AutoSizeText(
                                      //     minFontSize: 8,
                                      //     maxFontSize: 14,
                                      //     maxLines: 1,
                                      //     'VAT(฿)',
                                      //     textAlign: TextAlign.end,
                                      //     style: TextStyle(
                                      //         color: PeopleChaoScreen_Color
                                      //             .Colors_Text1_,
                                      //         fontWeight: FontWeight.bold,
                                      //         fontFamily: FontWeight_.Fonts_T
                                      //         //fontSize: 10.0
                                      //         //fontSize: 10.0
                                      //         ),
                                      //   ),
                                      // ),
                                      // Expanded(
                                      //   flex: 1,
                                      //   child: AutoSizeText(
                                      //     minFontSize: 8,
                                      //     maxFontSize: 14,
                                      //     maxLines: 1,
                                      //     'WHT(฿)',
                                      //     textAlign: TextAlign.end,
                                      //     style: TextStyle(
                                      //         color: PeopleChaoScreen_Color
                                      //             .Colors_Text1_,
                                      //         fontWeight: FontWeight.bold,
                                      //         fontFamily: FontWeight_.Fonts_T
                                      //         //fontSize: 10.0
                                      //         //fontSize: 10.0
                                      //         ),
                                      //   ),
                                      // ),
                                      Expanded(
                                        flex: 1,
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 14,
                                          maxLines: 1,
                                          'ยอดสุทธิ',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text1_,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T
                                              //fontSize: 10.0
                                              //fontSize: 10.0
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    // height:
                                    //     MediaQuery.of(context).size.height / 4.8,
                                    decoration: const BoxDecoration(
                                      color: AppbackgroundColor.Sub_Abg_Colors,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(0),
                                        topRight: Radius.circular(0),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(0),
                                      ),
                                      // border: Border.all(
                                      //     color: Colors.grey, width: 1),
                                    ),
                                    child: StreamBuilder(
                                      stream: Stream.periodic(
                                          const Duration(seconds: 0)),
                                      builder: (context, snapshot) {
                                        return ListView.builder(
                                          controller: _scrollController2,
                                          // itemExtent: 50,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:
                                              _TransReBillHistoryModels.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Container(
                                                child: Row(
                                                  children: [
                                                    // Expanded(
                                                    //   flex: 1,
                                                    //   child: AutoSizeText(
                                                    //     minFontSize: 8,
                                                    //     maxFontSize: 14,
                                                    //     maxLines: 1,
                                                    //     '${index + 1}',
                                                    //     textAlign:
                                                    //         TextAlign.start,
                                                    //     style: const TextStyle(
                                                    //         color: PeopleChaoScreen_Color
                                                    //             .Colors_Text2_,
                                                    //         //fontWeight: FontWeight.bold,
                                                    //         fontFamily:
                                                    //             Font_.Fonts_T),
                                                    //   ),
                                                    // ),
                                                    // Expanded(
                                                    //   flex: 1,
                                                    //   child: AutoSizeText(
                                                    //     minFontSize: 8,
                                                    //     maxFontSize: 14,
                                                    //     maxLines: 1,
                                                    //     '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${_TransReBillHistoryModels[index].dateacc} 00:00:00'))}',
                                                    //     textAlign:
                                                    //         TextAlign.start,
                                                    //     style: const TextStyle(
                                                    //         color: PeopleChaoScreen_Color
                                                    //             .Colors_Text2_,
                                                    //         //fontWeight: FontWeight.bold,
                                                    //         fontFamily:
                                                    //             Font_.Fonts_T),
                                                    //   ),
                                                    // ),
                                                    // Expanded(
                                                    //   flex: 1,
                                                    //   child: AutoSizeText(
                                                    //     minFontSize: 8,
                                                    //     maxFontSize: 14,
                                                    //     maxLines: 1,
                                                    //     // '${_TransReBillHistoryModels[index].duedate}',
                                                    //     '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${_TransReBillHistoryModels[index].date} 00:00:00'))}',
                                                    //     textAlign:
                                                    //         TextAlign.start,
                                                    //     style: const TextStyle(
                                                    //         color: PeopleChaoScreen_Color
                                                    //             .Colors_Text2_,
                                                    //         //fontWeight: FontWeight.bold,
                                                    //         fontFamily:
                                                    //             Font_.Fonts_T),
                                                    //   ),
                                                    // ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .refno ==
                                                                null)
                                                            ? '-'
                                                            : '${index + 1}. ${_TransReBillHistoryModels[index].refno}',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        (_TransReBillHistoryModels[
                                                                            index]
                                                                        .fine
                                                                        .toString() ==
                                                                    '1.00' &&
                                                                _TransReBillHistoryModels[
                                                                            index]
                                                                        .expname
                                                                        .toString()
                                                                        .trim() ==
                                                                    'null')
                                                            ? 'ค่าปรับ [${_TransReBillHistoryModels[index].inv}]'
                                                            : '${_TransReBillHistoryModels[index].expname}',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            color: (_TransReBillHistoryModels[index]
                                                                            .fine
                                                                            .toString() ==
                                                                        '1.00' &&
                                                                    _TransReBillHistoryModels[index]
                                                                            .expname
                                                                            .toString()
                                                                            .trim() ==
                                                                        'null')
                                                                ? Colors.red
                                                                : PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    // Expanded(
                                                    //   flex: 1,
                                                    //   child: AutoSizeText(
                                                    //     minFontSize: 8,
                                                    //     maxFontSize: 14,
                                                    //     maxLines: 1,
                                                    //     '${_TransReBillHistoryModels[index].vat}',
                                                    //     textAlign:
                                                    //         TextAlign.end,
                                                    //     style: const TextStyle(
                                                    //         color: PeopleChaoScreen_Color
                                                    //             .Colors_Text2_,
                                                    //         //fontWeight: FontWeight.bold,
                                                    //         fontFamily:
                                                    //             Font_.Fonts_T),
                                                    //   ),
                                                    // ),
                                                    // Expanded(
                                                    //   flex: 1,
                                                    //   child: AutoSizeText(
                                                    //     minFontSize: 8,
                                                    //     maxFontSize: 14,
                                                    //     maxLines: 1,
                                                    //     '${_TransReBillHistoryModels[index].wht}',
                                                    //     textAlign:
                                                    //         TextAlign.end,
                                                    //     style: const TextStyle(
                                                    //         color: PeopleChaoScreen_Color
                                                    //             .Colors_Text2_,
                                                    //         //fontWeight: FontWeight.bold,
                                                    //         fontFamily:
                                                    //             Font_.Fonts_T),
                                                    //   ),
                                                    // ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Container(
                                  // width: 300,
                                  decoration: BoxDecoration(
                                    color: AppbackgroundColor.Sub_Abg_Colors,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  padding: const EdgeInsets.all(4.0),
                                  child: StreamBuilder(
                                      stream: Stream.periodic(
                                          const Duration(seconds: 0)),
                                      builder: (context, snapshot) {
                                        return Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: AutoSizeText(
                                                minFontSize: 8,
                                                (pdate == null)
                                                    ? 'วันที่ชำระ : $pdate'
                                                    : 'วันที่ชำระ : ${DateFormat('dd-MM').format(DateTime.parse('$pdate 00:00:00'))}-${DateTime.parse('$pdate 00:00:00').year + 543}',
                                                textAlign: TextAlign.end,
                                                style: const TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    // fontWeight:
                                                    //     FontWeight
                                                    //         .bold,
                                                    fontFamily: Font_.Fonts_T
                                                    //fontSize: 10.0
                                                    ),
                                              ),
                                            ),
                                            const Align(
                                              alignment: Alignment.topLeft,
                                              child: const AutoSizeText(
                                                minFontSize: 8,
                                                maxFontSize: 13,
                                                'รูปแบบการชำระ',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    // fontWeight:
                                                    //     FontWeight
                                                    //         .bold,
                                                    fontFamily: Font_.Fonts_T
                                                    //fontSize: 10.0
                                                    ),
                                              ),
                                            ),
                                            for (var i = 0;
                                                i < finnancetransModels.length;
                                                i++)
                                              if (finnancetransModels[i]
                                                      .dtype
                                                      .toString() !=
                                                  'FTA')
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 13,
                                                        '${i + 1}. จำนวน ${nFormat.format(double.parse(finnancetransModels[i].amt!))} บาท (${finnancetransModels[i].ptname})',
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                      if (finnancetransModels[i]
                                                              .type
                                                              .toString() !=
                                                          'CASH')
                                                        AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          '  ** ${i + 1}.1. ธนาคาร : ${finnancetransModels[i].bank} , เลขบช. : ${finnancetransModels[i].bno}',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[800],
                                                              //fontWeight: FontWeight.bold,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                            // (finnancetransModels[i]
                                            //             .dtype
                                            //             .toString() ==
                                            //         'KP')
                                            //     ? Align(
                                            //         alignment:
                                            //             Alignment
                                            //                 .topLeft,
                                            //         child:
                                            //             AutoSizeText(
                                            //           minFontSize:
                                            //               8,
                                            //           maxFontSize:
                                            //               13,
                                            //           (finnancetransModels[i]
                                            //                       .type
                                            //                       .toString() ==
                                            //                   'CASH')
                                            //               ? '${i + 1}.เงินสด : ${nFormat.format(double.parse(finnancetransModels[i].amt!))} บาท'
                                            //               : '${i + 1}.เงินโอน : ${nFormat.format(double.parse(finnancetransModels[i].amt!))} บาท',
                                            //           style: const TextStyle(
                                            //               color: PeopleChaoScreen_Color.Colors_Text2_,
                                            //               //fontWeight: FontWeight.bold,
                                            //               fontFamily: Font_.Fonts_T),
                                            //         ),
                                            //       )
                                            //     : Align(
                                            //         alignment:
                                            //             Alignment
                                            //                 .topLeft,
                                            //         child:
                                            //             AutoSizeText(
                                            //           minFontSize:
                                            //               8,
                                            //           maxFontSize:
                                            //               13,
                                            //           '${i + 1}.${finnancetransModels[i].remark} : ${nFormat.format(double.parse(finnancetransModels[i].amt!))} บาท',
                                            //           style: const TextStyle(
                                            //               color: PeopleChaoScreen_Color.Colors_Text2_,
                                            //               //fontWeight: FontWeight.bold,
                                            //               fontFamily: Font_.Fonts_T),
                                            //         ),
                                            //       ),
                                          ],
                                        );
                                      }),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 350,
                                          // height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft: Radius.circular(0),
                                                    topRight:
                                                        Radius.circular(0),
                                                    bottomLeft:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(0)),
                                          ),
                                          child: StreamBuilder(
                                            stream: Stream.periodic(
                                                const Duration(seconds: 0)),
                                            builder: (context, snapshot) {
                                              return Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child:
                                                            const AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          'รวมราคาสินค้า/Sub Total',
                                                          style: TextStyle(
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                              //fontWeight: FontWeight.bold,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        // flex: 1,
                                                        child: AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          textAlign:
                                                              TextAlign.end,

                                                          // '${sum_pvat} // $dis_sum_Matjum',

                                                          '${nFormat.format(sum_pvat)}',
                                                          style:
                                                              const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  //fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child:
                                                            const AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          'ภาษีมูลค่าเพิ่ม/Vat',
                                                          style: TextStyle(
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                              //fontWeight: FontWeight.bold,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        // flex: 1,
                                                        child: AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          textAlign:
                                                              TextAlign.end,
                                                          '${nFormat.format(sum_vat)}',
                                                          style:
                                                              const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  //fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child:
                                                            const AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          'หัก ณ ที่จ่าย',
                                                          style: TextStyle(
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                              //fontWeight: FontWeight.bold,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        // flex: 1,
                                                        child: AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          textAlign:
                                                              TextAlign.end,
                                                          '${nFormat.format(sum_wht)}',
                                                          style:
                                                              const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  //fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child:
                                                            const AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          'ค่าทำเนียม',
                                                          style: TextStyle(
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                              //fontWeight: FontWeight.bold,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        // flex: 1,
                                                        child: AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          textAlign:
                                                              TextAlign.end,
                                                          '${nFormat.format(sum_duesbill)}',
                                                          style:
                                                              const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  //fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child:
                                                            const AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          'ยอดรวม',
                                                          style: TextStyle(
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                              //fontWeight: FontWeight.bold,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          textAlign:
                                                              TextAlign.end,
                                                          // '${sum_amt} // $dis_sum_Matjum ',

                                                          '${nFormat.format(sum_amt + sum_duesbill)}',
                                                          style:
                                                              const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  //fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child: AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          'ส่วนลด/Discount $sum_disp %',
                                                          style:
                                                              const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  //fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        // flex: 1,
                                                        child: AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          '${nFormat.format(sum_disamt)}',
                                                          textAlign:
                                                              TextAlign.end,
                                                          style:
                                                              const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  //fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (nFormat
                                                          .format(
                                                              dis_sum_Matjum)
                                                          .toString() !=
                                                      '0.00')
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 120,
                                                          child: AutoSizeText(
                                                            minFontSize: 8,
                                                            maxFontSize: 11,
                                                            'เงินมัดจำ(ตัดมัดจำ)',
                                                            style:
                                                                const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          // flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 8,
                                                            maxFontSize: 11,
                                                            '${nFormat.format(dis_sum_Matjum)}',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style:
                                                                const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child:
                                                            const AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          'ยอดชำระ',
                                                          style: TextStyle(
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                              //fontWeight: FontWeight.bold,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        // flex: 1,
                                                        child: AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          textAlign:
                                                              TextAlign.end,
                                                          //  '${sum_amt - sum_disamt} // $dis_sum_Matjum',

                                                          '${nFormat.format(((sum_amt - sum_disamt) - dis_sum_Matjum) + sum_duesbill)}',
                                                          style:
                                                              const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  //fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child:
                                                            const AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          'ยอดสุทธิ',
                                                          style: TextStyle(
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                              //fontWeight: FontWeight.bold,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        // flex: 1,
                                                        child: AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          textAlign:
                                                              TextAlign.end,
                                                          //  '${sum_amt - sum_disamt} // $dis_sum_Matjum',

                                                          '${nFormat.format((sum_amt - sum_disamt) + sum_duesbill)}',
                                                          style:
                                                              const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  //fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ])),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 2.0,
                      ),
                      const Divider(
                        color: Colors.grey,
                        height: 2.0,
                      ),
                      const SizedBox(
                        height: 2.0,
                      ),
                      StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 0)),
                          builder: (context, snapshot) {
                            return ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                              }),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      (Slip_history.toString() == null ||
                                              Slip_history == null ||
                                              Slip_history.toString() == 'null')
                                          ? const SizedBox()
                                          : Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              width: 150,
                                              child: InkWell(
                                                onTap: () async {
                                                  bool hasNonCashTransaction =
                                                      finnancetransModels
                                                          .any((transaction) {
                                                    return transaction.ptser
                                                            .toString()
                                                            .trim() ==
                                                        '7';
                                                  });

                                                  ///finnancetransModels
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      20.0))),
                                                      backgroundColor:
                                                          AppbackgroundColor
                                                              .Sub_Abg_Colors,
                                                      titlePadding:
                                                          const EdgeInsets.all(
                                                              0.0),
                                                      contentPadding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      actionsPadding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      title: Center(
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            4.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .highlight_off,
                                                                        size:
                                                                            30,
                                                                        color: Colors
                                                                            .red[700]),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              '${limitedList_TransReBillModels_[index].docno} ',
                                                              maxLines: 1,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      FontWeight_
                                                                          .Fonts_T,
                                                                  fontSize:
                                                                      12.0),
                                                            ),
                                                            (hasNonCashTransaction ==
                                                                    true)
                                                                ? Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(2.0),
                                                                          child:
                                                                              Text(
                                                                            '${Slip_history}',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: const TextStyle(
                                                                                color: Colors.grey,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontFamily: FontWeight_.Fonts_T,
                                                                                fontSize: 12.0),
                                                                          ),
                                                                        ),
                                                                        InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            final String
                                                                                url =
                                                                                '${Slip_history}';
                                                                            if (await canLaunch(url)) {
                                                                              await launch(url);
                                                                            } else {
                                                                              throw 'Could not launch $url';
                                                                            }
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            Icons.open_in_browser,
                                                                            color:
                                                                                Colors.blue,
                                                                            size:
                                                                                20,
                                                                          ),
                                                                        ),
                                                                      ])
                                                                : Text(
                                                                    '${Slip_history}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            FontWeight_
                                                                                .Fonts_T,
                                                                        fontSize:
                                                                            12.0),
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                      content: (hasNonCashTransaction ==
                                                              true)
                                                          ? StreamBuilder(
                                                              stream: Stream.periodic(
                                                                  const Duration(
                                                                      seconds:
                                                                          0)),
                                                              builder: (context,
                                                                  snapshot) {
                                                                return SingleChildScrollView(
                                                                  child:
                                                                      ListBody(
                                                                    children: <Widget>[
                                                                      Container(
                                                                        // height: 600,
                                                                        width: MediaQuery.of(context)
                                                                            .size
                                                                            .width,
                                                                        child: WebViewX2Pagebeamcheck(
                                                                            id_ser:
                                                                                Slip_history),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              })
                                                          : Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: <Widget>[
                                                                Image.network(
                                                                    '${MyConstant().domain_chao}/files/$foder/slip/${Slip_history}')
                                                              ],
                                                            ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue[200],
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .only(
                                                              topLeft: Radius
                                                                  .circular(6),
                                                              topRight: Radius
                                                                  .circular(6),
                                                              bottomLeft: Radius
                                                                  .circular(6),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          6)),
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1),
                                                    ),
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: Icon(
                                                              Icons.image,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: Text(
                                                            'หลักฐาน',
                                                            style: TextStyle(
                                                              color: AccountScreen_Color
                                                                  .Colors_Text2_,
                                                              // fontWeight:
                                                              //     FontWeight.bold,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                              ),
                                            ),
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        width: 150,
                                        child: InkWell(
                                          onTap: () {
                                            List newValuePDFimg = [];
                                            for (int index = 0;
                                                index < 1;
                                                index++) {
                                              if (renTalModels[0]
                                                      .imglogo!
                                                      .trim() ==
                                                  '') {
                                                // newValuePDFimg.add(
                                                //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
                                              } else {
                                                newValuePDFimg.add(
                                                    '${MyConstant().domain_chao}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                                              }
                                            }
                                            final tableData00 = [
                                              for (int index = 0;
                                                  index <
                                                      _TransReBillHistoryModels
                                                          .length;
                                                  index++)
                                                [
                                                  '${index + 1}',
                                                  '${_TransReBillHistoryModels[index].date}',
                                                  '${_TransReBillHistoryModels[index].expname}',
                                                  '${nFormat.format(double.parse(_TransReBillHistoryModels[index].nvat!))}',
                                                  '${nFormat.format(double.parse(_TransReBillHistoryModels[index].wht!))}',
                                                  '${nFormat.format(double.parse(_TransReBillHistoryModels[index].amt!))}',
                                                  '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
                                                ],
                                            ];

                                            String sname =
                                                limitedList_TransReBillModels_[
                                                                index]
                                                            .sname ==
                                                        null
                                                    ? '${limitedList_TransReBillModels_[index].remark}'
                                                    : '${limitedList_TransReBillModels_[index].sname}';
                                            String cname =
                                                '${limitedList_TransReBillModels_[index].cname}';
                                            String addr =
                                                '${limitedList_TransReBillModels_[index].addr}';
                                            String tax =
                                                '${limitedList_TransReBillModels_[index].tax}';
                                            String room_number_BillHistory =
                                                '${limitedList_TransReBillModels_[index].room_number}';
                                            print(
                                                'room_number ------> ${limitedList_TransReBillModels_[index].room_number}');

                                            // _showMyDialog_SAVE(
                                            //     tableData00,
                                            //     newValuePDFimg,
                                            //     sname,
                                            //     cname,
                                            //     addr,
                                            //     tax,
                                            //     room_number_BillHistory);
                                            var TitleType_Default_Receipt_Name =
                                                null;
                                            Receipt_his_statusbill(
                                                tableData00,
                                                newValuePDFimg,
                                                sname,
                                                cname,
                                                addr,
                                                tax,
                                                room_number_BillHistory,
                                                TitleType_Default_Receipt_Name);
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(6),
                                                        topRight:
                                                            Radius.circular(6),
                                                        bottomLeft:
                                                            Radius.circular(6),
                                                        bottomRight:
                                                            Radius.circular(6)),
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(4.0),
                                                    child: Icon(Icons.print,
                                                        color: Colors.white),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(4.0),
                                                    child: Text(
                                                      'พิมพ์',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        // fontWeight:
                                                        //     FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T,
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
                              ),
                            );
                          }),
                    ],
                  ),
                ],
              ),
            ));
  }

  Future<Null> pPC_finantIbillREbill(tableData00, sname, cname, addr, tax,
      newValuePDFimg, finnancetransModels) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;

    var numin = numinvoice;
    var doctax;
    String room_number_BillHistory = '';
    // print(
    //     'finnancetransModels>>>zzzz${finnancetransModels.length}>>>>>> $numin');

    String url =
        '${MyConstant().domain_chao}/UPC_finant_billREbill.php?isAdd=true&ren=$ren&user=$user&numin=$numin';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'No') {
        for (var map in result) {
          TransReBillModel cFinnancetransModel = TransReBillModel.fromJson(map);
          setState(() {
            doctax = cFinnancetransModel.doctax;
            numdoctax = cFinnancetransModel.doctax;
          });
          if (cFinnancetransModel.room_number != '' ||
              cFinnancetransModel.room_number != null) {
            setState(() {
              room_number_BillHistory =
                  cFinnancetransModel.room_number.toString();
            });
          }
          // print('zzzzasaaa123454>>>>  $cFinn');
          // print(
          //     'bnobnobnobno123454>>>>  ${cFinnancetransModel.docno}  ////  ${cFinnancetransModel.doctax} ');
        }
        Insert_log.Insert_logs('บัญชี',
            'ประวัติบิล>>เปลี่ยนสถานะบิล(ร้าน:$sname,${numinvoice}-->$doctax)');
        // Receipt_his_statusbill(tableData00, newValuePDFimg, sname, cname, addr,
        //         tax, room_number_BillHistory, 'TitleType_Default_Receipt_Name');

        //  _showMyDialog_SAVE(tableData00, newValuePDFimg, sname, cname, addr, tax,
        //           room_number_BillHistory);
        // Pdfgen_his_statusbill.exportPDF_statusbill(
        // tableData00,
        // context,
        // _TransReBillHistoryModels,
        // 'Num_cid',
        // 'Namenew',
        // sum_pvat,
        // sum_vat,
        // sum_wht,
        // sum_amt,
        // sum_disp,
        // sum_disamt,
        // '${sum_amt - sum_disamt}',
        // renTal_name,
        // sname,
        // cname,
        // addr,
        // tax,
        // bill_addr,
        // bill_email,
        // bill_tel,
        // bill_tax,
        // bill_name,
        // newValuePDFimg,
        // doctax,
        // cFinn,
        // finnancetransModels,
        // '',
        // '${DateFormat('dd-MM').format(DateTime.parse('$pdate 00:00:00'))}-${DateTime.parse('$pdate 00:00:00').year + 543}');
        setState(() async {
          _TransReBillHistoryModels.clear();

          sum_pvat = 0.00;
          sum_vat = 0.00;
          sum_wht = 0.00;
          sum_amt = 0.00;
          sum_dis = 0.00;
          sum_disamt = 0.00;
          sum_disp = 0;

          red_Trans_bill();
          // finnancetransModels.clear();
          Navigator.pop(context);
          Navigator.pop(context);
        });

        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  Future<void> _showMyDialog_SAVE(tableData00, newValuePDFimg, sname, cname,
      addr, tax, room_number_BillHistory) async {
    String _verticalGroupValue_NameFile = "จากระบบ";
    String Value_Report = ' ';
    String NameFile_ = '';
    String Pre_and_Dow = '';
    String? TitleType_Default_Receipt_Name =
        _ReportValue_type == 'ไม่ระบุ' ? null : _ReportValue_type;
    final _formKey = GlobalKey<FormState>();
    final FormNameFile_text = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 0)),
          builder: (context, snapshot) {
            return Form(
              key: _formKey,
              child: AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      const Text(
                        'หัวบิล :',
                        style: TextStyle(
                          color: ReportScreen_Color.Colors_Text2_,
                          // fontWeight: FontWeight.bold,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: grb.RadioGroup<String>.builder(
                          direction: Axis.horizontal,
                          groupValue: _ReportValue_type,
                          onChanged: (value) {
                            // setState(() {
                            //   FormNameFile_text.clear();
                            // });
                            setState(() {
                              _ReportValue_type = value ?? '';
                            });

                            if (value == 'ไม่ระบุ') {
                              setState(() {
                                TitleType_Default_Receipt_Name = null;
                              });
                            } else {
                              setState(() {
                                TitleType_Default_Receipt_Name = value;
                              });
                            }
                          },
                          items: const <String>[
                            'ไม่ระบุ',
                            'ต้นฉบับ',
                            'สำเนา',
                          ],
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: ReportScreen_Color.Colors_Text2_,
                            // fontWeight: FontWeight.bold,
                            fontFamily: Font_.Fonts_T,
                          ),
                          itemBuilder: (item) => grb.RadioButtonBuilder(
                            item,
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
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () {
                            Receipt_his_statusbill(
                                tableData00,
                                newValuePDFimg,
                                sname,
                                cname,
                                addr,
                                tax,
                                room_number_BillHistory,
                                TitleType_Default_Receipt_Name);
                          },
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
                            child: Center(
                              child: Text(
                                'พิมพ์',
                                style: TextStyle(
                                  color: Colors.white,
                                  //fontWeight: FontWeight.bold, color:

                                  // fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () => Navigator.pop(context, 'OK'),
                          child: Container(
                            width: 100,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                'ปิด',
                                style: TextStyle(
                                  color: Colors.white,
                                  //fontWeight: FontWeight.bold, color:

                                  // fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T,
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
            );
          },
        );
      },
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
                      padding: EdgeInsets.all(8),
                      child: Text(
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

  Future<Null> pPC_finantIbill(Formbecause) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;

    var numin = numinvoice;

    String url =
        '${MyConstant().domain_chao}/UPC_finant_bill.php?isAdd=true&ren=$ren&user=$user&numin=$numin&because=$Formbecause';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
        Insert_log.Insert_logs('บัญชี',
            'ประวัติบิล>>ยกเลิกการรับชำระ($numin,เหตุผล:${Formbecause})');
        setState(() {
          // _InvoiceModels.clear();
          // _InvoiceHistoryModels.clear();
          _TransReBillHistoryModels.clear();
          // numinvoice = null;
          // sum_disamtx.text = '0.00';
          // sum_dispx.text = '0.00';
          sum_pvat = 0.00;
          sum_vat = 0.00;
          sum_wht = 0.00;
          sum_amt = 0.00;
          sum_dis = 0.00;
          sum_disamt = 0.00;
          sum_disp = 0;
          // select_page = 0;
          red_Trans_bill();
          finnancetransModels.clear();
          Navigator.pop(context);
        });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  Future<Null> Receipt_his_statusbill(
      tableData00,
      newValuePDFimg,
      sname,
      cname,
      addr,
      tax,
      room_number_BillHistory,
      TitleType_Default_Receipt_Name) async {
    ManPay_Receipt_PDF.ManPayReceipt_PDF(
        numinvoice,
        context,
        foder,
        renTal_name,
        // sname,
        // cname,
        // addr,
        // tax,
        bill_addr,
        bill_email,
        bill_tel,
        bill_tax,
        bill_name,
        newValuePDFimg,
        TitleType_Default_Receipt_Name,
        tem_page_ser,
        bills_name_,
        '0');
    // ManPay_Receipt_PDF.ManPayReceipt_PDF(
    //     numinvoice,
    //     context,
    //     foder,
    //     renTal_name,
    //     // sname,
    //     // cname,
    //     // addr,
    //     // tax,
    //     bill_addr,
    //     bill_email,
    //     bill_tel,
    //     bill_tax,
    //     bill_name,
    //     newValuePDFimg,
    //     TitleType_Default_Receipt_Name,
    //     tem_page_ser,
    //     bills_name_);
  }
}
