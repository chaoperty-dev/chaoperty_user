import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty_user/screen/Screen_new/my_diary/water_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Constant/Myconstant.dart';
import '../../../Model/GetInvoice_Model.dart';
import '../../../Model/GetTeNant_Model.dart';
import '../../../Model/GetTranBill_model.dart';
import '../../../Model/Get_Image_pro_model.dart';
import '../../../Model/Get_Image_text_model.dart';
import '../../../color.dart';

import '../../../Constant/app_markets.dart';
import '../../loginscreen.dart';
import '../../market_select_screen.dart';
import '../../market_service.dart';
import '../fitness_app_home_screen.dart';
import '../fitness_app_theme.dart';
import '../ui_view/body_measurement.dart';
import '../ui_view/glass_view.dart';
import '../ui_view/mediterranean_diet_view.dart';
import '../ui_view/title_view.dart';
import 'meals_list_view.dart';
import 'package:http/http.dart' as http;

class MyDiaryScreen extends StatefulWidget {
  const MyDiaryScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _MyDiaryScreenState createState() => _MyDiaryScreenState();
}

class _MyDiaryScreenState extends State<MyDiaryScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  List<TeNantModel> teNantModels = [];
  List<Widget> listViews = <Widget>[];
  List<TransBillModel> _TransBillModels = [];
  List<InvoiceModel> _InvoiceModels = [];
  int open_set_date = 30;

  List<ImageTextModel> imgList = [];
  List<String> textList = [];
  List<Widget> imageSliders = [];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;
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
  @override
  void initState() {
    super.initState();
    checkPreferance()
        .then((value) => read_GC_tenant())
        .then((value) => read_GC_customer_user())
        .then((value) => red_Trans_bill().then((value) {
              topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                      parent: widget.animationController!,
                      curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
              addAllListData();

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

    // red_Trans_bill();
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
                          fit: BoxFit.cover, width: 1500.0),
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

  Future<Null> read_GC_imagepro() async {
    if (imageSliders.isNotEmpty) {
      setState(() {
        imageSliders.clear();
        imgList.clear();
      });
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

  Future<Null> read_GC_customer_user() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/Gc_customer_user.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      if (result != null) {
        for (var map in result) {
          setState(() {
            open_set_date = int.parse(map['open_set_date']);
          });
        }
      }
      if (open_set_date == 0) {
        setState(() {
          open_set_date = 30;
        });
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
            var in_amtx = double.parse(_InvoiceModel.amtall!) +
                double.parse(_InvoiceModel.vatall!);
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
    const int count = 9;

    // listViews.add(
    //   TitleView(
    //     titleTxt: cus_lang == 'EN' ? 'Infomation User' : 'ข้อมูลผู้ใช้',
    //     subTxt: cus_lang == 'EN' ? 'Details' : 'รายละเอียด',
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );
    listViews.add(
      MediterranesnDietView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
        teNantModel: teNantModels,
        invoiceModels: _InvoiceModels,
        cuslangs: cus_lang,
        open_set_date: open_set_date,
      ),
    );
    listViews.add(
      TitleView(
        titleTxt: cus_lang == 'EN' ? 'Rental contract' : 'สัญญา',
        subTxt: cus_lang == 'EN' ? 'Rental contract All' : 'สัญญาทั้งหมด',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    listViews.add(
      MealsListView(
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval((1 / count) * 3, 1.0,
                    curve: Curves.fastOutSlowIn))),
        mainScreenAnimationController: widget.animationController,
        teNantModel: teNantModels,
        totallist: total_list,
        cuslangs: cus_lang,
        open_set_date: open_set_date,
      ),
    );

    listViews.add(
      TitleView(
        titleTxt: cus_lang == 'EN' ? 'Overdue Today' : 'เกินกำหนดชำระ',
        subTxt: 'X',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 4, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    listViews.add(
      BodyMeasurementView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
        totaltodays: totaltoday,
        invoiceModels: _InvoiceModels,
        cuslangs: cus_lang,
      ),
    );
    // listViews.add(
    //   TitleView(
    //     titleTxt: cus_lang == 'EN' ? 'News' : 'ข่าว',
    //     subTxt: 'X',
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 6, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );

    // listViews.add(
    //   WaterView(
    //     mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
    //         CurvedAnimation(
    //             parent: widget.animationController!,
    //             curve: Interval((1 / count) * 7, 1.0,
    //                 curve: Curves.fastOutSlowIn))),
    //     mainScreenAnimationController: widget.animationController!,
    //     imgLists: imageSliders,
    //   ),
    // );
    // listViews.add(
    //   GlassView(
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 8, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //     textLists: textList,
    //   ),
    // );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
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
                      color: Colors.green,
                      size: 70,
                    ),
                  ],
                ),
              )
            : ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                }),
                child: Stack(
                  children: <Widget>[
                    getMainListViewUI(),
                    getAppBarUI(),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom,
                    )
                  ],
                ),
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
              bottom: 100 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController?.forward();
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
                      bottomLeft: Radius.circular(0.0),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: FitnessAppTheme.nearlyWhite,
                                        shape: BoxShape.circle,
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color: FitnessAppTheme.grey
                                                  .withOpacity(0.4),
                                              offset: const Offset(2.0, 2.0),
                                              blurRadius: 8.0),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: null,
                                        child: Icon(Icons.person,
                                            color: FitnessAppTheme.grey,
                                            size: 28),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Hello,',
                                          style: TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            fontSize: 12,
                                            color: FitnessAppTheme.grey,
                                          ),
                                        ),
                                        AutoSizeText(
                                          minFontSize: 14,
                                          maxFontSize: 18,
                                          maxLines: 1,
                                          '$cus_cname',
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            fontWeight: FontWeight.w700,
                                            fontSize:
                                                18 + 6 - 6 * topBarOpacity,
                                            letterSpacing: 1.2,
                                            color: FitnessAppTheme.darkerText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    SharedPreferences preferences =
                                        await SharedPreferences.getInstance();
                                    var cuslang =
                                        cus_lang == 'EN' ? 'TH' : 'EN';
                                    String url =
                                        '${MyConstant().domain_chao}/UP_THEN.php?isAdd=true&cus_ser=$cus_ser&cuslang=$cuslang';
                                    try {
                                      var response =
                                          await http.get(Uri.parse(url));

                                      var result = json.decode(response.body);

                                      if (result.toString() != 'false') {
                                        preferences.setString(
                                            'lang', cuslang.toString());
                                        MaterialPageRoute route =
                                            MaterialPageRoute(
                                          builder: (context) =>
                                              FitnessAppHomeScreen(
                                                  pageroot: null),
                                        );
                                        Navigator.push(context, route);
                                      }
                                    } catch (e) {}
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: FitnessAppTheme.nearlyWhite,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: FitnessAppTheme.grey
                                                .withOpacity(0.2),
                                            offset: const Offset(1.1, 1.1),
                                            blurRadius: 8.0),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          cus_lang ?? 'TH',
                                          style: TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.language,
                                            size: 16,
                                            color: FitnessAppTheme.grey),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                if (AppMarkets.markets.length > 1)
                                  InkWell(
                                    borderRadius: BorderRadius.circular(32.0),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MarketSelectScreen(
                                            markets: AppMarkets.markets,
                                            onSelect: (selected) =>
                                                MarketService.applyMarket(
                                                    context, selected),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: FitnessAppTheme.nearlyWhite,
                                        borderRadius:
                                            BorderRadius.circular(18),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color: FitnessAppTheme.grey
                                                  .withValues(alpha: 0.2),
                                              offset: const Offset(1.1, 1.1),
                                              blurRadius: 8.0),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.swap_horiz_rounded,
                                              size: 16,
                                              color: FitnessAppTheme.orange),
                                          SizedBox(width: 4),
                                          Text(
                                            cus_lang == 'EN'
                                                ? 'Switch'
                                                : 'ตลาด',
                                            style: TextStyle(
                                              fontFamily: Font_.Fonts_T,
                                              fontWeight: FontWeight.bold,
                                              color: FitnessAppTheme.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 12),
                                InkWell(
                                  borderRadius: BorderRadius.circular(32.0),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            elevation: 0,
                                            backgroundColor: Colors.transparent,
                                            child: Center(
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 400),
                                                padding:
                                                    const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      blurRadius: 10,
                                                      offset: Offset(0, 10),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                      decoration: BoxDecoration(
                                                        color: FitnessAppTheme
                                                            .nearlyDarkRed
                                                            .withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.logout,
                                                        size: 40,
                                                        color: FitnessAppTheme
                                                            .nearlyDarkRed,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    const Text(
                                                      "Logout",
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      cus_lang == 'EN'
                                                          ? "Are you sure you want to logout?"
                                                          : "คุณต้องการออกจากระบบหรือไม่?",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 25),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            style: TextButton
                                                                .styleFrom(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          12),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              cus_lang == 'EN'
                                                                  ? "Cancel"
                                                                  : "ยกเลิก",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .grey
                                                                    .shade700,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 15),
                                                        Expanded(
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  FitnessAppTheme
                                                                      .nearlyDarkRed,
                                                                  const Color(
                                                                      0xFFFF6B6B),
                                                                ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: FitnessAppTheme
                                                                      .nearlyDarkRed
                                                                      .withOpacity(
                                                                          0.3),
                                                                  blurRadius: 5,
                                                                  offset:
                                                                      const Offset(
                                                                          0, 3),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Material(
                                                              color: Colors
                                                                  .transparent,
                                                              child: InkWell(
                                                                onTap:
                                                                    () async {
                                                                  SharedPreferences
                                                                      preferences =
                                                                      await SharedPreferences
                                                                          .getInstance();
                                                                  await preferences
                                                                      .clear();
                                                                  MaterialPageRoute
                                                                      route =
                                                                      MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const LoginScreen(),
                                                                  );
                                                                  Navigator.pushAndRemoveUntil(
                                                                      context,
                                                                      route,
                                                                      (route) =>
                                                                          false);
                                                                },
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          12),
                                                                  child: Center(
                                                                    child: Text(
                                                                      cus_lang ==
                                                                              'EN'
                                                                          ? "Logout"
                                                                          : "ยืนยัน",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .white,
                                                                        fontFamily:
                                                                            Font_.Fonts_T,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
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
                                            ));
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: FitnessAppTheme.nearlyWhite,
                                      shape: BoxShape.circle,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: FitnessAppTheme.grey
                                                .withOpacity(0.2),
                                            offset: const Offset(1.1, 1.1),
                                            blurRadius: 8.0),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.logout,
                                      color: FitnessAppTheme.grey,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            )
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
}
