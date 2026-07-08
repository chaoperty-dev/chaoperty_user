import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

import '../../../Constant/Myconstant.dart';
import '../../../Model/GetContractx_Model.dart';
import '../../../Model/GetCustomer_Model.dart';
import '../../../Model/GetInvoice_Model.dart';
import '../../../Model/GetTeNant_Model.dart';
import '../../../Model/GetTrans_Model.dart';
import '../../../color.dart';
import '../../../main.dart';
import '../../model/electricity_history_model.dart';
import '../fitness_app_theme.dart';
import '../ui_view/area_list_view.dart';
import '../ui_view/running_view.dart';
import '../ui_view/title_view.dart';
import '../ui_view/workout_view.dart';
import 'package:http/http.dart' as http;

class MitterScreen extends StatefulWidget {
  const MitterScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  State<MitterScreen> createState() => _MitterScreenState();
}

class _MitterScreenState extends State<MitterScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  AnimationController? animationController;
  List<Widget> listViews = <Widget>[];
  List<CustomerModel> customerModels = [];
  List<TeNantModel> teNantModels = [];
  List<InvoiceModel> _InvoiceModels = [];
  List<ContractxModel> _ContractxModels = [];
  List<TransModel> _TransModels = [];
  List<ElectricityHistoryModel> electricityHistoryModels = [];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;
  var nFormat = NumberFormat("#,##0.00", "en_US");
  DateTime _DateTimeNew = DateTime.now();
  String? Ser_re,
      renTal_user,
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
      cus_lintid,
      cus_lang;
  String? _celvat,
      _cname,
      _cnamex,
      _cmeter,
      _cser,
      _cunitser,
      _cqty_vat,
      _cunit;

  double unit1 = 0,
      unit2 = 0,
      unit3 = 0,
      unit4 = 0,
      unit5 = 0,
      unit6 = 0,
      sum1 = 0,
      sum2 = 0,
      sum3 = 0,
      sum4 = 0,
      sum5 = 0,
      sum6 = 0,
      unit = 0,
      unit1c = 0,
      unit2c = 0,
      unit3c = 0,
      unit4c = 0,
      unit5c = 0,
      unit6c = 0,
      ele_tf = 0.0000,
      ele_other = 0,
      ele_vat = 0,
      ele_one = 0,
      ele_mit_one = 0,
      ele_gob_one = 0,
      ele_two = 0,
      ele_mit_two = 0,
      ele_gob_two = 0,
      ele_three = 0,
      ele_mit_three = 0,
      ele_gob_three = 0,
      ele_tour = 0,
      ele_mit_tour = 0,
      ele_gob_tour = 0,
      ele_five = 0,
      ele_mit_five = 0,
      ele_gob_five = 0,
      ele_six = 0,
      ele_mit_six = 0,
      ele_gob_six = 0,
      sum = 0,
      sum_n = 0,
      sum_f = 0,
      sum_per = 0,
      sum_all = 0;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
    checkPreferance()
        .then((value) => read_GC_tenant())
        .then((value) => red_Trans_bill().then((value) {
              topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                      parent: widget.animationController!,
                      curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
              addAllListData();
              // forward animation ครั้งเดียว ไม่ใช่ทุก itemBuilder
              if (widget.animationController?.status ==
                  AnimationStatus.dismissed) {
                widget.animationController?.forward();
              }

              scrollController.addListener(() {
                if (scrollController.offset >= 24) {
                  if (topBarOpacity != 1.0) {
                    setState(() {
                      topBarOpacity = 1.0;
                    });
                  }
                } else if (scrollController.offset <= 24 &&
                    scrollController.offset >= 0) {
                  if (topBarOpacity != scrollController.offset / 24) {
                    setState(() {
                      topBarOpacity = scrollController.offset / 24;
                    });
                  }
                } else if (scrollController.offset <= 0) {
                  if (topBarOpacity != 0.0) {
                    setState(() {
                      topBarOpacity = 0.0;
                    });
                  }
                }
              });
            }));
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  Future<Null> checkPreferance() async {
    DateTime currentDate = DateTime.now();
    String new_Url = MyConstant().domain_chao;

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
      cus_lang = preferences.getString('lang');
    });
    if (cus_photo != null ||
        cus_photo.toString() != '' ||
        cus_photo.toString() != 'null') {
      cus_imglogo_ = '$new_Url/files/$cus_foder/contract/$cus_photo';
    }
    String url =
        '${MyConstant().domain}/Gc_customer_user.php?isAdd=true&ren=$Ser_re&cusno=$custno_';

    var response = await http.get(Uri.parse(url));

    var result = json.decode(response.body);
    for (var map in result) {
      CustomerModel customerModel = CustomerModel.fromJson(map);
      setState(() {
        customerModels.add(customerModel);
      });
    }
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
    } catch (e) {}
  }

  /////////////////////////////////////////////////////////////////////
  List<String> total_list = [];
  double All_total = 0.00, totaltoday = 0.00;

  Future<Null> red_Trans_bill() async {
    if (_InvoiceModels.length != 0) {
      setState(() {
        _InvoiceModels.clear();
        totaltoday = 0;
      });
    }
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    // var ciddoc_ = preferences.getString('usercid');
    var qutser_ = preferences.getString('qutser');
    ////////////////------------------------------------------------------>
    double total = 0.00;
    for (int index = 0; index < teNantModels.length; index++) {
      var ciddoc_ = teNantModels[index].cid;
      String url =
          '${MyConstant().domain_chao}/GC_bill_invoice.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_';
      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);

        if (result.toString() != 'null') {
          for (var map in result) {
            InvoiceModel _InvoiceModel = InvoiceModel.fromJson(map);
            var in_amtx = double.parse(_InvoiceModel.amtall!);
            var in_docnox = _InvoiceModel.docno;
            var in_ser = _InvoiceModel.ser;
            var in_amtall = _InvoiceModel.amtall;
            var disendbill = double.parse(_InvoiceModel.disendbill!);

            setState(() {
              if (_InvoiceModel.billdate ==
                  DateFormat('yyy-MM-dd').format(_DateTimeNew)) {
                totaltoday = totaltoday + in_amtx;
              }
              // sum_disamt_in = sum_disamt_in + disendbill;
              total = total + in_amtx;
              // invoicePayModels.add(invoicePayModel);
              _InvoiceModels.add(_InvoiceModel);
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

  void addAllListData() {
    const int count = 5;
    // listViews.add(
    //   TitleView(
    //     titleTxt: cus_lang == 'EN' ? 'Contract' : 'สัญญา',
    //     subTxt: 'X',
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );
    listViews.add(
      TitleView(
        titleTxt: cus_lang == 'EN'
            ? 'Electricity & Water Usage'
            : 'มิเตอร์ไฟฟ้า และ มิเตอร์น้ำ',
        subTxt: 'X',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );
    listViews.add(
      Container(
        height: 105,
        width: double.infinity,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          }),
          child: ListView.builder(
            padding:
                const EdgeInsets.only(top: 0, bottom: 0, right: 16, left: 16),
            itemCount: teNantModels.length,
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              final int count =
                  teNantModels.length > 10 ? 10 : teNantModels.length;
              final Animation<double> animation =
                  Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                      parent: animationController!,
                      curve: Interval((1 / count) * index, 1.0,
                          curve: Curves.fastOutSlowIn)));

              return AnimatedBuilder(
                  animation: animationController!,
                  builder: (BuildContext context, Widget? child) {
                    return FadeTransition(
                      opacity: animation,
                      child: Transform(
                        transform: Matrix4.translationValues(
                            100 * (1.0 - animation.value), 0.0, 0.0),
                        child: SizedBox(
                          width: 135,
                          child: Stack(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 32, left: 8, right: 8, bottom: 16),
                                child: InkWell(
                                  onTap: () async {
                                    _TransModels.clear();
                                    _ContractxModels.clear();
                                    red_exp_wherser(teNantModels[index].cid)
                                        .then((value) {
                                      listViews.clear();
                                      addAllListData();
                                    });
                                    // });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: teNantModels[index]
                                                        .quantity ==
                                                    '1'
                                                ? _DateTimeNew.isAfter(DateTime
                                                                .parse(
                                                                    '${teNantModels[index].ldate} 00:00:00.000')
                                                            .subtract(
                                                                const Duration(
                                                                    days:
                                                                        0))) ==
                                                        true
                                                    ? HexColor('#FA877F')
                                                        .withOpacity(0.6)
                                                    : HexColor('#537188')
                                                        .withOpacity(
                                                            0.6) //AFD198
                                                : HexColor('#FBF3D5')
                                                    .withOpacity(0.6),
                                            offset: const Offset(1.1, 4.0),
                                            blurRadius: 8.0),
                                      ],
                                      gradient: LinearGradient(
                                        colors: <HexColor>[
                                          // หมด : เช่าอยู่ : เสนอ

                                          teNantModels[index].quantity == '1'
                                              ? _DateTimeNew.isAfter(DateTime.parse(
                                                              '${teNantModels[index].ldate} 00:00:00.000')
                                                          .subtract(
                                                              const Duration(
                                                                  days: 0))) ==
                                                      true
                                                  ? HexColor('#FF8080')
                                                  : HexColor('#6B7AA1') //748E63
                                              : HexColor('#FFBE98'),
                                          teNantModels[index].quantity == '1'
                                              ? _DateTimeNew.isAfter(DateTime.parse(
                                                              '${teNantModels[index].ldate} 00:00:00.000')
                                                          .subtract(
                                                              const Duration(
                                                                  days: 0))) ==
                                                      true
                                                  ? HexColor('#EF4B4B')
                                                  : HexColor('#354259') //E8EFCF
                                              : HexColor('#F6995C'),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        bottomRight: Radius.circular(8.0),
                                        bottomLeft: Radius.circular(8.0),
                                        topLeft: Radius.circular(8.0),
                                        topRight: Radius.circular(54.0),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20,
                                          left: 16,
                                          right: 16,
                                          bottom: 8),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            '${teNantModels[index].cid}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              letterSpacing: 0.2,
                                              color: FitnessAppTheme.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: FitnessAppTheme.nearlyWhite
                                        .withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              // Positioned(
                              //   top: 0,
                              //   left: 8,
                              //   child: SizedBox(
                              //     width: 60,
                              //     height: 60,
                              //     child: SfBarcodeGenerator(
                              //       value: teNantModels[index].docno == null
                              //           ? teNantModels[index].cid == null
                              //               ? ''
                              //               : '${teNantModels[index].cid}'
                              //           : '${teNantModels[index].docno}',
                              //       symbology: QRCode(),
                              //       showValue: false,
                              //     ),
                              //     // Image.asset(mealsListData!.imagePath),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            },
          ),
        ),
      ),
    );
    // listViews.add(
    //   TitleView(
    //     titleTxt: cus_lang == 'EN'
    //         ? 'Electricity meter & Water meter'
    //         : 'มิเตอร์ไฟฟ้า และ มิเตอร์น้ำ',
    //     subTxt: 'X',
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );
    listViews.add(
      SizedBox(
        // height: 105,
        width: double.infinity,
        child: _ContractxModels.isEmpty
            ? SizedBox()
            : Container(
                color: HexColor('#F2EDD7'),
                child: TitleView(
                  titleTxt: cus_lang == 'EN'
                      ? 'Contart ${_ContractxModels[0].cid}'
                      : 'สัญญา ${_ContractxModels[0].cid}',
                  subTxt: 'X',
                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController!,
                          curve: Interval((1 / count) * 2, 1.0,
                              curve: Curves.fastOutSlowIn))),
                  animationController: widget.animationController!,
                ),
              ),
      ),
    );
    listViews.add(Container(
      height: 105,
      width: double.infinity,
      child: _ContractxModels.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(
                  top: 20, left: 16, right: 16, bottom: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    cus_lang == 'EN' ? 'Select Contact' : 'เลือกสัญญา',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.2,
                      color: FitnessAppTheme.darkText,
                    ),
                  ),
                ],
              ),
            )
          : ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              }),
              child: ListView.builder(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 0, right: 16, left: 16),
                itemCount: _ContractxModels.length,
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  final int count = _ContractxModels.length > 10
                      ? 10
                      : _ContractxModels.length;
                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                              parent: animationController!,
                              curve: Interval((1 / count) * index, 1.0,
                                  curve: Curves.fastOutSlowIn)));

                  return AnimatedBuilder(
                      animation: animationController!,
                      builder: (BuildContext context, Widget? child) {
                        return FadeTransition(
                          opacity: animation,
                          child: Transform(
                            transform: Matrix4.translationValues(
                                100 * (1.0 - animation.value), 0.0, 0.0),
                            child: SizedBox(
                              width: 135,
                              child: Stack(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 32, left: 8, right: 8, bottom: 16),
                                    child: InkWell(
                                      onTap: () async {
                                        setState(() {
                                          _celvat =
                                              _ContractxModels[index].nvat;
                                          _cname =
                                              '${_ContractxModels[index].expname!.trim()}( ${_ContractxModels[index].unit} )\n${_ContractxModels[index].meter}';
                                          _cmeter =
                                              _ContractxModels[index].meter;
                                          _cnamex =
                                              '${_ContractxModels[index].expname}';
                                          _cser = _ContractxModels[index].ser;
                                          _cunitser =
                                              _ContractxModels[index].unitser;
                                          _cunit = _ContractxModels[index].unit;
                                          _cqty_vat =
                                              _ContractxModels[index].qty;
                                        });
                                        _TransModels.clear();
                                        red_Trans(_ContractxModels[index].ser,
                                                _ContractxModels[index].cid)
                                            .then((value) {
                                          listViews.clear();
                                          addAllListData();
                                        });
                                        // red_exp_wherser(
                                        //     teNantModels[index].cid);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                                color: HexColor('#FCFFE0')
                                                    .withOpacity(0.6),
                                                offset: const Offset(1.1, 4.0),
                                                blurRadius: 8.0),
                                          ],
                                          gradient: LinearGradient(
                                            colors: <HexColor>[
                                              HexColor('#E08F62'),
                                              HexColor('#CC7351'),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            bottomRight: Radius.circular(8.0),
                                            bottomLeft: Radius.circular(8.0),
                                            topLeft: Radius.circular(30.0),
                                            topRight: Radius.circular(30.0),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20,
                                              left: 16,
                                              right: 16,
                                              bottom: 8),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                width: 150,
                                                child: Text(
                                                  '${_ContractxModels[index].expname}',
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontFamily: FitnessAppTheme
                                                        .fontName,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    letterSpacing: 0.2,
                                                    color:
                                                        FitnessAppTheme.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: FitnessAppTheme.nearlyWhite
                                            .withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    child: SizedBox(
                                      width: 65,
                                      height: 65,
                                      child:
                                          Image.asset('fitness_app/solar.gif'),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                },
              ),
            ),
    ));
    listViews.add(Container(
        // height: double.infinity,
        width: double.infinity,
        child: _TransModels.isEmpty
            ? SizedBox()
            : Padding(
                padding: const EdgeInsets.only(
                    top: 0, left: 16, right: 16, bottom: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            // height: 80,
                            decoration: BoxDecoration(
                              color: HexColor('#949CDF'),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(0),
                              ),
                              // border: Border.all(
                              //     color: Colors.grey, width: 1),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '$_cnamex ($_cunit)\n$_cmeter',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text1_,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T
                                  //fontSize: 10.0
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            // height: 80,
                            decoration: BoxDecoration(
                              color: HexColor('#949CDF'),
                              // borderRadius: const BorderRadius.only(
                              //   topLeft: Radius.circular(10),
                              //   topRight: Radius.circular(10),
                              //   bottomLeft: Radius.circular(0),
                              //   bottomRight: Radius.circular(0),
                              // ),
                              // border: Border.all(
                              //     color: Colors.grey, width: 1),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Text(
                                      cus_lang == 'EN' ? 'Month' : 'เดือน',
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text1_,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T
                                          //fontSize: 10.0
                                          ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      cus_lang == 'EN' ? 'Before' : 'ก่อน',
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text1_,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T
                                          //fontSize: 10.0
                                          ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      cus_lang == 'EN' ? 'After' : 'หลัง',
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text1_,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T
                                          //fontSize: 10.0
                                          ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      cus_lang == 'EN'
                                          ? 'Units used'
                                          : 'หน่วยที่ใช้ไป',
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text1_,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T
                                          //fontSize: 10.0
                                          ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Text(
                                      cus_lang == 'EN' ? 'Amount' : 'ยอดเงิน',
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text1_,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T
                                          //fontSize: 10.0
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                              // height: 80,
                              decoration: BoxDecoration(
                                color: HexColor('#FBF9F1'),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                  // controller: _scrollController1,
                                  // itemExtent: 50,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _TransModels.length,
                                  itemBuilder:
                                      (BuildContext context, int indextran) {
                                    // ignore: curly_braces_in_flow_control_structures
                                    return ListTile(
                                      onTap: () {
                                        print(
                                            '${_TransModels[indextran].date}');
                                        setState(() {
                                          electricityHistoryModels.clear();
                                          unit1 = 0;
                                          unit2 = 0;
                                          unit3 = 0;
                                          unit4 = 0;
                                          unit5 = 0;
                                          unit6 = 0;
                                          sum1 = 0;
                                          sum2 = 0;
                                          sum3 = 0;
                                          sum4 = 0;
                                          sum5 = 0;
                                          sum6 = 0;
                                          unit = 0;
                                          unit1c = 0;
                                          unit2c = 0;
                                          unit3c = 0;
                                          unit4c = 0;
                                          unit5c = 0;
                                          unit6c = 0;
                                          ele_tf = 0.0000;
                                          ele_other = 0;
                                          ele_vat = 0;
                                          ele_one = 0;
                                          ele_mit_one = 0;
                                          ele_gob_one = 0;
                                          ele_two = 0;
                                          ele_mit_two = 0;
                                          ele_gob_two = 0;
                                          ele_three = 0;
                                          ele_mit_three = 0;
                                          ele_gob_three = 0;
                                          ele_tour = 0;
                                          ele_mit_tour = 0;
                                          ele_gob_tour = 0;
                                          ele_five = 0;
                                          ele_mit_five = 0;
                                          ele_gob_five = 0;
                                          ele_six = 0;
                                          ele_mit_six = 0;
                                          ele_gob_six = 0;
                                          sum = 0;
                                          sum_n = 0;
                                          sum_f = 0;
                                          sum_per = 0;
                                          sum_all = 0;
                                          showmiter(indextran);
                                        });
                                      },
                                      title: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              cus_lang == 'EN'
                                                  ? '${DateFormat.MMMM().format((DateTime.parse('${_TransModels[indextran].date} 00:00:00')))}\n${DateTime.parse('${_TransModels[indextran].date} 00:00:00').year}'
                                                  : '${DateFormat.MMMM('th_TH').format((DateTime.parse('${_TransModels[indextran].date} 00:00:00')))}\n${DateTime.parse('${_TransModels[indextran].date} 00:00:00').year + 543}',
                                              maxLines: 3,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text1_,
                                                // fontWeight: FontWeight.bold,
                                                // fontFamily:
                                                //     FontWeight_.Fonts_T
                                                //fontSize: 10.0
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: _cunitser != '6'
                                                ? Text(
                                                    '$_cunit',
                                                    maxLines: 1,
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      // fontWeight: FontWeight.bold,
                                                      // fontFamily:
                                                      //     FontWeight_.Fonts_T
                                                      //fontSize: 10.0
                                                    ),
                                                  )
                                                : Text(
                                                    indextran == 0
                                                        ? '${_TransModels[indextran].ovalue!.padLeft(4, '0')}'
                                                        : _TransModels[indextran -
                                                                        1]
                                                                    .nvalue ==
                                                                null
                                                            ? ''
                                                            : '${_TransModels[indextran - 1].nvalue!.padLeft(4, '0')}',
                                                    maxLines: 1,
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      // fontWeight: FontWeight.bold,
                                                      // fontFamily:
                                                      //     FontWeight_.Fonts_T
                                                      //fontSize: 10.0
                                                    ),
                                                  ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: _cunitser != '6'
                                                ? Text(
                                                    '$_cunit',
                                                    maxLines: 1,
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      // fontWeight: FontWeight.bold,
                                                      // fontFamily:
                                                      //     FontWeight_.Fonts_T
                                                      //fontSize: 10.0
                                                    ),
                                                  )
                                                : Text(
                                                    '${_TransModels[indextran].nvalue!.padLeft(4, '0')}',
                                                    maxLines: 1,
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      // fontWeight: FontWeight.bold,
                                                      // fontFamily:
                                                      //     FontWeight_.Fonts_T
                                                      //fontSize: 10.0
                                                    ),
                                                  ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${nFormat.format(double.parse(_TransModels[indextran].qty5!))}',
                                              maxLines: 1,
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text1_,
                                                // fontWeight: FontWeight.bold,
                                                // fontFamily:
                                                //     FontWeight_.Fonts_T
                                                //fontSize: 10.0
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              '${nFormat.format(double.parse(_TransModels[indextran].amt!))}',
                                              maxLines: 1,
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text1_,
                                                // fontWeight: FontWeight.bold,
                                                // fontFamily:
                                                //     FontWeight_.Fonts_T
                                                //fontSize: 10.0
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  })),
                        ),
                      ],
                    ),
                  ],
                ),
              )));
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  Future<Null> red_Trans(_cser, Get_Value_cid) async {
    if (_TransModels.length != 0) {
      setState(() {
        _TransModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = Get_Value_cid;
    var qutser = '1';
    print('qutser>>> $qutser >> $_cser');
    if (qutser == '1') {
      String url =
          '${MyConstant().domain_chao}/GC_quotx_consx.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&_cser=$_cser';
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
        }
      } catch (e) {}
    }
  }

  Future<Null> red_exp_wherser(Get_Value_cid) async {
    if (_ContractxModels.length != 0) {
      setState(() {
        _ContractxModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = Get_Value_cid;
    var qutser = '1';

    if (qutser == '1') {
      String url =
          '${MyConstant().domain_chao}/GC_exp_wherser.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
      print(url);
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: listViews.length == 0
            ? Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 30, // ปรับขนาดของ CircleAvatar
                        backgroundImage:
                            AssetImage('assets/images/Icon-chao.png'),
                      ),
                    ),
                    LoadingAnimationWidget.inkDrop(
                      color: Colors.indigo,
                      size: 70,
                    ),
                  ],
                ),
              )
            : Stack(
                children: <Widget>[
                  getMainListViewUI(),
                  getAppBarUI(),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom,
                  )
                ],
              ),
      ),
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return listViews[index];
            },
          );
        }
      },
    );
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: FitnessAppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  cus_lang == 'EN'
                                      ? 'Electricity & Water '
                                      : 'มิเตอร์ไฟฟ้า และ มิเตอร์น้ำ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: FitnessAppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                            // SizedBox(
                            //   height: 38,
                            //   width: 38,
                            //   child: InkWell(
                            //     highlightColor: Colors.transparent,
                            //     borderRadius: const BorderRadius.all(
                            //         Radius.circular(32.0)),
                            //     onTap: () {},
                            //     child: Center(
                            //       child: Icon(
                            //         Icons.keyboard_arrow_left,
                            //         color: FitnessAppTheme.grey,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.only(
                            //     left: 8,
                            //     right: 8,
                            //   ),
                            //   child: Row(
                            //     children: <Widget>[
                            //       Padding(
                            //         padding: const EdgeInsets.only(right: 8),
                            //         child: Icon(
                            //           Icons.calendar_today,
                            //           color: FitnessAppTheme.grey,
                            //           size: 18,
                            //         ),
                            //       ),
                            //       Text(
                            //         '15 May',
                            //         textAlign: TextAlign.left,
                            //         style: TextStyle(
                            //           fontFamily: FitnessAppTheme.fontName,
                            //           fontWeight: FontWeight.normal,
                            //           fontSize: 18,
                            //           letterSpacing: -0.2,
                            //           color: FitnessAppTheme.darkerText,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 38,
                            //   width: 38,
                            //   child: InkWell(
                            //     highlightColor: Colors.transparent,
                            //     borderRadius: const BorderRadius.all(
                            //         Radius.circular(32.0)),
                            //     onTap: () {},
                            //     child: Center(
                            //       child: Icon(
                            //         Icons.keyboard_arrow_right,
                            //         color: FitnessAppTheme.grey,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Future<dynamic> showmiter(int indextran) async {
    var qser_in = _TransModels[indextran].ser_in;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain_chao}/GC_electricity_history.php?isAdd=true&ren=$ren&qser_in=$qser_in';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(result);
      if (result != null) {
        for (var map in result) {
          ElectricityHistoryModel electricityHistoryModel =
              ElectricityHistoryModel.fromJson(map);
          setState(() {
            electricityHistoryModels.add(electricityHistoryModel);
          });
        }
      } else {}
    } catch (e) {}

    if (electricityHistoryModels.isEmpty) {
      return null;
    } else {
      setState(() {
        unit = double.parse(electricityHistoryModels[0].edit_new!);

        unit1c = double.parse(electricityHistoryModels[0].eleOne!) - 0;
        unit2c = double.parse(electricityHistoryModels[0].eleTwo!) -
            double.parse(electricityHistoryModels[0].eleOne!);
        unit3c = double.parse(electricityHistoryModels[0].eleThree!) -
            double.parse(electricityHistoryModels[0].eleTwo!);
        unit4c = double.parse(electricityHistoryModels[0].eleTour!) -
            double.parse(electricityHistoryModels[0].eleThree!);
        unit5c = double.parse(electricityHistoryModels[0].eleFive!) -
            double.parse(electricityHistoryModels[0].eleTour!);
        unit6c = unit - double.parse(electricityHistoryModels[0].eleSix!);

        ele_tf = double.parse(electricityHistoryModels[0].eleTf!);
        ele_other = double.parse(electricityHistoryModels[0].other!);
        ele_vat = double.parse(electricityHistoryModels[0].vat!);

        ele_one = double.parse(electricityHistoryModels[0].eleOne!);
        ele_mit_one = double.parse(electricityHistoryModels[0].eleMitOne!);
        ele_gob_one = double.parse(electricityHistoryModels[0].eleGobOne!);

        ele_two = double.parse(electricityHistoryModels[0].eleTwo!);
        ele_mit_two = double.parse(electricityHistoryModels[0].eleMitTwo!);
        ele_gob_two = double.parse(electricityHistoryModels[0].eleGobTwo!);

        ele_three = double.parse(electricityHistoryModels[0].eleThree!);
        ele_mit_three = double.parse(electricityHistoryModels[0].eleMitThree!);
        ele_gob_three = double.parse(electricityHistoryModels[0].eleGobThree!);

        ele_tour = double.parse(electricityHistoryModels[0].eleTour!);
        ele_mit_tour = double.parse(electricityHistoryModels[0].eleMitTour!);
        ele_gob_tour = double.parse(electricityHistoryModels[0].eleGobTour!);

        ele_five = double.parse(electricityHistoryModels[0].eleFive!);
        ele_mit_five = double.parse(electricityHistoryModels[0].eleMitFive!);
        ele_gob_five = double.parse(electricityHistoryModels[0].eleGobFive!);

        ele_six = double.parse(electricityHistoryModels[0].eleSix!);
        ele_mit_six = double.parse(electricityHistoryModels[0].eleMitSix!);
        ele_gob_six = double.parse(electricityHistoryModels[0].eleGobSix!);
      });

      if (unit > unit1c) {
        setState(() {
          unit1 = unit - unit1c;
        });

        if (ele_gob_one != 0.00) {
          setState(() {
            sum1 = ele_gob_one;
          });
        } else {
          setState(() {
            sum1 = unit1c * ele_mit_one;
          });
        }
      } else {
        if (ele_gob_one != 0.00) {
          setState(() {
            sum1 = ele_gob_one;
          });
        } else {
          setState(() {
            sum1 = unit * ele_mit_one;
          });
        }
      }

      if (unit1 >= unit2c) {
        setState(() {
          unit2 = unit1 - unit2c;
        });

        if (ele_gob_two != 0.00) {
          setState(() {
            sum2 = ele_gob_two;
          });
        } else {
          setState(() {
            sum2 = unit2c * ele_mit_two;
          });
        }
      } else {
        if (ele_gob_two != 0.00) {
          setState(() {
            sum2 = ele_gob_two;
          });
        } else {
          setState(() {
            sum2 = unit1 * ele_mit_two;
          });
        }
      }

      if (unit2 >= unit3c) {
        setState(() {
          unit3 = unit2 - unit3c;
        });
        if (ele_gob_three != 0.00) {
          setState(() {
            sum3 = ele_gob_three;
          });
        } else {
          setState(() {
            sum3 = unit3c * ele_mit_three;
          });
        }
      } else {
        if (ele_gob_three != 0.00) {
          setState(() {
            sum3 = ele_gob_three;
          });
        } else {
          setState(() {
            sum3 = unit2 * ele_mit_three;
          });
        }
      }

      if (unit3 >= unit4c) {
        setState(() {
          unit4 = unit3 - unit4c;
        });

        if (ele_gob_tour != 0.00) {
          setState(() {
            sum4 = ele_gob_tour;
          });
        } else {
          setState(() {
            sum4 = unit4c * ele_mit_tour;
          });
        }
      } else {
        if (ele_gob_tour != 0.00) {
          setState(() {
            sum4 = ele_gob_tour;
          });
        } else {
          setState(() {
            sum4 = unit3 * ele_mit_tour;
          });
        }
      }

      if (unit4 >= unit5c) {
        setState(() {
          unit5 = unit4 - unit5c;
        });

        if (ele_gob_five != 0.00) {
          setState(() {
            sum5 = ele_gob_five;
          });
        } else {
          setState(() {
            sum5 = unit5c * ele_mit_five;
          });
        }
      } else {
        if (ele_gob_five != 0.00) {
          setState(() {
            sum5 = ele_gob_five;
          });
        } else {
          setState(() {
            sum5 = unit4 * ele_mit_five;
          });
        }
      }

      if (unit5 >= unit6c) {
        setState(() {
          unit6 = unit5 - unit6c;
        });

        if (ele_gob_six != 0.00) {
          setState(() {
            sum6 = ele_gob_six;
          });
        } else {
          setState(() {
            sum6 = unit6c * ele_mit_six;
          });
        }
      } else {
        if (ele_gob_six != 0.00) {
          setState(() {
            sum6 = ele_gob_six;
          });
        } else {
          setState(() {
            sum6 = unit5 * ele_mit_six;
          });
        }
      }

      // if (unit5 >= unit6c) {
      //   if (ele_gob_six != 0.00) {
      //     setState(() {
      //       sum6 = ele_gob_six;
      //     });
      //   } else {
      //     setState(() {
      //       sum6 = unit6c * ele_mit_six;
      //     });
      //   }
      // }
      setState(() {
        if (sum6 < 0) {
          sum = sum1 + sum2 + sum3 + sum4 + sum5;
        } else {
          sum = sum1 + sum2 + sum3 + sum4 + sum5 + sum6;
        }
      });
      setState(() {
        sum_n = sum + ele_other;
      });
      setState(() {
        sum_f = unit * ele_tf;
      });
      setState(() {
        sum_per = (sum_n + sum_f) * ele_vat / 100;
      });
      setState(() {
        sum_all = sum_n + sum_f + sum_per;
      });

      return showDialog(
          context: context,
          builder: (_) {
            return Dialog(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(15.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                cus_lang == 'EN'
                                    ? '${DateFormat.MMMM().format((DateTime.parse('${_TransModels[indextran].date} 00:00:00')))} ${DateTime.parse('${_TransModels[indextran].date} 00:00:00').year}'
                                    : '${DateFormat.MMMM('th_TH').format((DateTime.parse('${_TransModels[indextran].date} 00:00:00')))} ${DateTime.parse('${_TransModels[indextran].date} 00:00:00').year + 543}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                cus_lang == 'EN'
                                    ? 'Units used: '
                                    : 'หน่วยที่ใช้ไป : ',
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                '$unit',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                cus_lang == 'EN' ? 'Unit' : 'หน่วย',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      (unit - unit1) == 0 || sum1 <= 0
                          ? SizedBox()
                          : Row(
                              children: [
                                // Expanded(flex: 1, child: Text('')),
                                Expanded(
                                  flex: 2,
                                  child: RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      text: cus_lang == 'EN'
                                          ? 'Unit at 0-$ele_one'
                                          : 'หน่วยที่ 0-$ele_one',
                                      style: TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          fontFamily: Font_.Fonts_T),
                                      children: <TextSpan>[
                                        cus_lang == 'EN'
                                            ? TextSpan(
                                                text: ele_mit_one == 0
                                                    ? ' (lump sum $ele_gob_one baht)'
                                                    : ' (per unit $ele_mit_one baht)',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontFamily: Font_.Fonts_T),
                                              )
                                            : TextSpan(
                                                text: ele_mit_one == 0
                                                    ? ' (เหมาจ่าย $ele_gob_one บาท)'
                                                    : ' (หน่วยละ $ele_mit_one บาท)',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    cus_lang == 'EN'
                                        ? '${unit - unit1} Unit'
                                        : '${unit - unit1} หน่วย',
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${nFormat.format(sum1)}',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    cus_lang == 'EN' ? 'baht' : 'บาท',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      (unit1 - unit2) == 0 || sum2 <= 0
                          ? SizedBox()
                          : Row(
                              children: [
                                // Expanded(flex: 1, child: Text('')),
                                Expanded(
                                  flex: 2,
                                  child: RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      text: cus_lang == 'EN'
                                          ? 'Unit at ${(ele_one + 1)} - $ele_two'
                                          : 'หน่วยที่ ${(ele_one + 1)} - $ele_two',
                                      style: TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          fontFamily: Font_.Fonts_T),
                                      children: <TextSpan>[
                                        cus_lang == 'EN'
                                            ? TextSpan(
                                                text: ele_mit_two == 0
                                                    ? ' (lump sum $ele_gob_two baht)'
                                                    : ' (per unit $ele_mit_two baht)',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontFamily: Font_.Fonts_T),
                                              )
                                            : TextSpan(
                                                text: ele_mit_two == 0
                                                    ? ' (เหมาจ่าย $ele_gob_two บาท)'
                                                    : ' (หน่วยละ $ele_mit_two บาท)',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    cus_lang == 'EN'
                                        ? '${unit1 - unit2} Unit'
                                        : '${unit1 - unit2} หน่วย',
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${nFormat.format(sum2)}',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    cus_lang == 'EN' ? 'baht' : 'บาท',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      (unit2 - unit3) == 0 || sum3 <= 0
                          ? SizedBox()
                          : Row(
                              children: [
                                // Expanded(flex: 1, child: Text('')),
                                Expanded(
                                  flex: 2,
                                  child: RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      text: cus_lang == 'EN'
                                          ? 'Unit at ${(ele_two + 1)} - $ele_three'
                                          : 'หน่วยที่ ${(ele_two + 1)} - $ele_three',
                                      style: TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          fontFamily: Font_.Fonts_T),
                                      children: <TextSpan>[
                                        cus_lang == 'EN'
                                            ? TextSpan(
                                                text: ele_mit_three == 0
                                                    ? ' (lump sum $ele_gob_three baht)'
                                                    : ' (per unit $ele_mit_three baht)',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontFamily: Font_.Fonts_T),
                                              )
                                            : TextSpan(
                                                text: ele_mit_three == 0
                                                    ? ' (เหมาจ่าย $ele_gob_three บาท)'
                                                    : ' (หน่วยละ $ele_mit_three บาท)',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    cus_lang == 'EN'
                                        ? '${unit2 - unit3} Unit'
                                        : '${unit2 - unit3} หน่วย',
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${nFormat.format(sum3)}',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    cus_lang == 'EN' ? 'baht' : 'บาท',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      (unit3 - unit4) == 0 || sum4 <= 0
                          ? SizedBox()
                          : Row(
                              children: [
                                // Expanded(flex: 1, child: Text('')),
                                Expanded(
                                  flex: 2,
                                  child: RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      text: cus_lang == 'EN'
                                          ? 'Unit at ${(ele_three + 1)} - $ele_tour'
                                          : 'หน่วยที่ ${(ele_three + 1)} - $ele_tour',
                                      style: TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          fontFamily: Font_.Fonts_T),
                                      children: <TextSpan>[
                                        cus_lang == 'EN'
                                            ? TextSpan(
                                                text: ele_mit_tour == 0
                                                    ? ' (lump sum $ele_gob_tour baht)'
                                                    : ' (per unit $ele_mit_tour baht)',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontFamily: Font_.Fonts_T),
                                              )
                                            : TextSpan(
                                                text: ele_mit_tour == 0
                                                    ? ' (เหมาจ่าย $ele_gob_tour บาท)'
                                                    : ' (หน่วยละ $ele_mit_tour บาท)',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    cus_lang == 'EN'
                                        ? '${unit3 - unit4} Unit'
                                        : '${unit3 - unit4} หน่วย',
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${nFormat.format(sum4)}',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    cus_lang == 'EN' ? 'baht' : 'บาท',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      (unit4 - unit5) == 0 || sum5 <= 0
                          ? SizedBox()
                          : Row(
                              children: [
                                // Expanded(flex: 1, child: Text('')),
                                Expanded(
                                  flex: 2,
                                  child: RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      text: cus_lang == 'EN'
                                          ? 'Unit at ${(ele_tour + 1)} - $ele_five'
                                          : 'หน่วยที่ ${(ele_tour + 1)} - $ele_five',
                                      style: TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          fontFamily: Font_.Fonts_T),
                                      children: <TextSpan>[
                                        cus_lang == 'EN'
                                            ? TextSpan(
                                                text: ele_mit_five == 0
                                                    ? ' (lump sum $ele_gob_five baht)'
                                                    : ' (per unit $ele_mit_five baht)',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontFamily: Font_.Fonts_T),
                                              )
                                            : TextSpan(
                                                text: ele_mit_five == 0
                                                    ? ' (เหมาจ่าย $ele_gob_five บาท)'
                                                    : ' (หน่วยละ $ele_mit_five บาท)',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    cus_lang == 'EN'
                                        ? '${unit4 - unit5} Unit'
                                        : '${unit4 - unit5} หน่วย',
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${nFormat.format(sum5)}',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    cus_lang == 'EN' ? 'baht' : 'บาท',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      (unit5 - unit6) == 0 || sum6 <= 0
                          ? SizedBox()
                          : sum6 < 0
                              ? SizedBox()
                              : Row(
                                  children: [
                                    // Expanded(flex: 1, child: Text('')),
                                    Expanded(
                                      flex: 2,
                                      child: RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(
                                          text: cus_lang == 'EN'
                                              ? 'Unit at $ele_six up'
                                              : 'หน่วยที่ $ele_six ขึ้นไป',
                                          style: TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text2_,
                                              fontFamily: Font_.Fonts_T),
                                          children: <TextSpan>[
                                            cus_lang == 'EN'
                                                ? TextSpan(
                                                    text: ele_mit_six == 0
                                                        ? ' (lump sum $ele_gob_six baht)'
                                                        : ' (per unit $ele_mit_six baht)',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  )
                                                : TextSpan(
                                                    text: ele_mit_six == 0
                                                        ? ' (เหมาจ่าย $ele_gob_six บาท)'
                                                        : ' (หน่วยละ $ele_mit_six บาท)',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        cus_lang == 'EN'
                                            ? '${unit5 - unit6} Unit'
                                            : '${unit5 - unit6} หน่วย',
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${nFormat.format(sum6)}',
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        cus_lang == 'EN' ? 'bath' : 'บาท',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                    ),
                                  ],
                                ),
                      Divider(),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              ' ',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              cus_lang == 'EN' ? 'Sum' : 'เงิน$_cnamexฐาน',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${nFormat.format(sum)}',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              cus_lang == 'EN' ? 'baht' : 'บาท',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: RichText(
                              textAlign: TextAlign.end,
                              text: TextSpan(
                                text: cus_lang == 'EN' ? 'Ft value' : 'ค่า Ft',
                                style: TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    fontFamily: Font_.Fonts_T),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: cus_lang == 'EN'
                                        ? ' ( $ele_tf ) baht/unit'
                                        : ' ( $ele_tf ) บาท/หน่วย',
                                    style: TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${nFormat.format(sum_f)}',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              cus_lang == 'EN' ? 'baht' : 'บาท',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              ' ',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              cus_lang == 'EN'
                                  ? 'Monthly service fee'
                                  : 'ค่าบริการรายเดือน',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${nFormat.format(ele_other)}',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              cus_lang == 'EN' ? 'baht' : 'บาท',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              ' ',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          // Expanded(
                          //   flex: 2,
                          //   child: Text(
                          //     '',
                          //     textAlign: TextAlign.end,
                          //     style: const TextStyle(
                          //         color: PeopleChaoScreen_Color.Colors_Text2_,
                          //         fontFamily: Font_.Fonts_T),
                          //   ),
                          // ),
                          Expanded(
                            flex: 3,
                            child: Divider(),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: RichText(
                              textAlign: TextAlign.end,
                              text: TextSpan(
                                text: cus_lang == 'EN'
                                    ? 'Value-added tax'
                                    : 'ภาษีมูลค่าเพิ่ม',
                                style: TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    fontFamily: Font_.Fonts_T),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: ' ${nFormat.format(ele_vat)} % (VAT)',
                                    style: TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${nFormat.format(sum_per)}',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              cus_lang == 'EN' ? 'baht' : 'บาท',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              ' ',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          // Expanded(
                          //   flex: 2,
                          //   child: Text(
                          //     '',
                          //     textAlign: TextAlign.end,
                          //     style: const TextStyle(
                          //         color: PeopleChaoScreen_Color.Colors_Text2_,
                          //         fontFamily: Font_.Fonts_T),
                          //   ),
                          // ),
                          Expanded(
                            flex: 3,
                            child: Divider(),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              cus_lang == 'EN'
                                  ? 'Total money current month'
                                  : 'รวมเงิน$_cnamexเดือนปัจจุบัน',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${nFormat.format(sum_all)}',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              cus_lang == 'EN' ? 'baht' : 'บาท',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              cus_lang == 'EN'
                                  ? 'Total money'
                                  : 'รวมเงินทั้งสิ้น',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                fontFamily: FontWeight_.Fonts_T,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          // Expanded(
                          //   flex: 2,
                          //   child: Text(
                          //     ' ',
                          //     textAlign: TextAlign.center,
                          //     style: const TextStyle(
                          //       color: PeopleChaoScreen_Color.Colors_Text2_,
                          //       fontFamily: FontWeight_.Fonts_T,
                          //       fontSize: 20,
                          //     ),
                          //   ),
                          // ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${nFormat.format(sum_all)}',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                fontFamily: FontWeight_.Fonts_T,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              cus_lang == 'EN' ? 'baht' : 'บาท',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                fontFamily: FontWeight_.Fonts_T,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
              ),
            );
          });
    }
  }
}
