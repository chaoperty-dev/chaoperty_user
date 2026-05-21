import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import '../Constant/Myconstant.dart';
import '../Model/trans_re_bill_model.dart';
import '../color.dart';

class StatusScreen2 extends StatefulWidget {
  const StatusScreen2({Key? key, this.animationController}) : super(key: key);
  final AnimationController? animationController;
  @override
  State<StatusScreen2> createState() => _StatusScreen2State();
}

class _StatusScreen2State extends State<StatusScreen2> {
  AnimationController? animationController;
  List<TransReBillModel> limitedList_TransReBillModels_ = [];
  var nFormat = NumberFormat("#,##0.00", "en_US");
  int sucsess = 0;
  @override
  void initState() {
    super.initState();
    red_Trans_bill();
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
          setState(() {
            sucsess = sucsess + sess;
            limitedList_TransReBillModels_.add(transReBillModel);
          });
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
                            padding: EdgeInsets.only(
                                top: 8.0, right: 8.0, left: 8.0),
                            child: Text(
                              'สถานะการชำระ',
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
                                right: 8.0, left: 8.0, bottom: 8.0),
                            child: Text(
                              'รอดำเนินการ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(100, 108, 110, 1),
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 8.0, right: 8.0, left: 8.0, bottom: 8.0),
                            child: Text(
                              '$sucsess บิล',
                              textAlign: TextAlign.end,
                              style: TextStyle(
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
                                top: 8.0, right: 8.0, left: 8.0),
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
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                for (int index = 0;
                                    index <
                                        limitedList_TransReBillModels_.length;
                                    index++)
                                  Container(
                                    color: limitedList_TransReBillModels_[index]
                                                .pos ==
                                            '1'
                                        ? Colors.orange.shade50
                                        : Colors.green.shade50,
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
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    right: 8.0, left: 8.0),
                                                child: Text(
                                                  limitedList_TransReBillModels_[
                                                                  index]
                                                              .pos ==
                                                          '1'
                                                      ? 'กำลังดำเนิดการ'
                                                      : 'ชำระเสร็จสิ้น',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        limitedList_TransReBillModels_[
                                                                        index]
                                                                    .pos ==
                                                                '1'
                                                            ? Colors
                                                                .orange.shade900
                                                            : Colors
                                                                .green.shade900,
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
                                                    right: 8.0,
                                                    left: 8.0,
                                                    bottom: 8.0),
                                                child: Text(
                                                  limitedList_TransReBillModels_[
                                                                  index]
                                                              .shopno ==
                                                          '1'
                                                      ? 'ออนไลน์'
                                                      : 'เจ้าหน้าที่',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color.fromRGBO(
                                                        100, 108, 110, 1),
                                                    fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
}
