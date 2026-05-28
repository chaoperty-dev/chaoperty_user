import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Constant/Myconstant.dart';
import '../../../Model/GetCustomer_Model.dart';
import '../../../Model/GetInvoice_Model.dart';
import '../../../Model/GetTeNant_Model.dart';
import '../../../main.dart';
import '../../../screen_Intents_V3/payment_mainV3_InvAll.dart';
import '../../pay_bill_Mainscreen.dart';
import '../../pay_bill_Mainscreen_Choice.dart';
import '../../pay_bill_screen.dart';
import '../../pay_bill_screen_Choice.dart';
import '../fitness_app_theme.dart';
import '../ui_view/area_list_view.dart';
import '../ui_view/running_view.dart';
import '../ui_view/running_view_pay.dart';
import '../ui_view/title_view.dart';
import '../ui_view/workout_view.dart';
import 'package:http/http.dart' as http;

class TrainingPayCidSelectScreen extends StatefulWidget {
  const TrainingPayCidSelectScreen({Key? key, this.animationController})
      : super(key: key);

  final AnimationController? animationController;
  @override
  _TrainingPayCidSelectScreenState createState() =>
      _TrainingPayCidSelectScreenState();
}

class _TrainingPayCidSelectScreenState extends State<TrainingPayCidSelectScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  List<Widget> listViews = <Widget>[];
  List<CustomerModel> customerModels = [];
  List<TeNantModel> teNantModels = [];
  List<InvoiceModel> _InvoiceModels = [];
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
      cus_lang,
      ciddoc_select;
  @override
  void initState() {
    super.initState();
    checkPreferance()
        .then((value) => read_GC_tenant())
        .then((value) => red_Trans_bill().then((value) {
              topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                      parent: widget.animationController!,
                      curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
              addAllListData();
              setState(() {});

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

  Future<Null> checkPreferance() async {
    DateTime currentDate = DateTime.now();
    String new_Url = MyConstant().domain_chao;

    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? DateLogin;
    setState(() {
      ciddoc_select = preferences.getString('usercid');
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
    var ciddoc_ = preferences.getString('usercid');
    String url =
        '${MyConstant().domain}/GC_tenant_cid.php?isAdd=true&ren=$ren&custno=$custno_S&ciddoc=$ciddoc_';
    //  '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone';
    print('read_GC_tenant');
    print(url);
    print('read_GC_tenant');
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
    var ciddoc_ = preferences.getString('usercid');
    var qutser_ = '1';
    // print('object>>> $ciddoc_');
    ////////////////------------------------------------------------------>
    double total = 0.00;
    // for (int index = 0; index < teNantModels.length; index++) {
    //   var ciddoc_ = teNantModels[index].cid;
    String url =
        '${MyConstant().domain_chao}/GC_bill_invoice.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_';
    print('training_pay_cid_screen');
    print(url);
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
    // }
  }

  void addAllListData() {
    const int count = 5;

    // listViews.add(
    //   TitleView(
    //     titleTxt: cus_lang == 'EN' ? 'Infomatiom User' : 'ข้อมูลผู้ใช้',
    //     subTxt: 'X',
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );
    if (renTal_user.toString() == '106' || renTal_user.toString() == '50') {
    } else {
      listViews.add(
        RunningViewPay(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController!,
                  curve: Interval((1 / count) * 3, 1.0,
                      curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController!,
          cuslang: cus_lang,
          customerModel: customerModels,
        ),
      );
    }

    // listViews.add(
    //   WorkoutView(
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //     customerModel: customerModels,
    //     cuslang: cus_lang,
    //     teNantModel: teNantModels,
    //     invoiceModels: _InvoiceModels,
    //   ),
    // );

    // listViews.add(
    //   TitleView(
    //     titleTxt: 'Area of focus',
    //     subTxt: 'more',
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 4, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );

    listViews.add(
        (renTal_user.toString() == '106' || renTal_user.toString() == '50')
            ? PaybillMainScreenChoice(
                mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0)
                    .animate(CurvedAnimation(
                        parent: widget.animationController!,
                        curve: Interval((1 / count) * 5, 1.0,
                            curve: Curves.fastOutSlowIn))),
                mainScreenAnimationController: widget.animationController!,
                teNantModel: teNantModels,
                cuslang: cus_lang,
              )

            //  PayBillscreenChoice(
            //     mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
            //         CurvedAnimation(
            //             parent: widget.animationController!,
            //             curve: Interval((1 / count) * 5, 1.0,
            //                 curve: Curves.fastOutSlowIn))),
            //     mainScreenAnimationController: widget.animationController!,
            //     teNantModel: teNantModels,
            //     cuslang: cus_lang,
            //   )
            : paymentMainV3InvAll(
                mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0)
                    .animate(CurvedAnimation(
                        parent: widget.animationController!,
                        curve: Interval((1 / count) * 5, 1.0,
                            curve: Curves.fastOutSlowIn))),
                mainScreenAnimationController: widget.animationController!,
                teNantModel: teNantModels,
                customerModel: customerModels,
                cuslang: cus_lang,
                isMainScreen: false, // [NEW] Fix nested scroll error
              )

        // PaybillMainScreen(
        //     mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0)
        //         .animate(CurvedAnimation(
        //             parent: widget.animationController!,
        //             curve: Interval((1 / count) * 5, 1.0,
        //                 curve: Curves.fastOutSlowIn))),
        //     mainScreenAnimationController: widget.animationController!,
        //     teNantModel: teNantModels,
        //     customerModel: customerModels,
        //     cuslang: cus_lang,
        //   )

        // PayBillscreen(
        //     mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
        //         CurvedAnimation(
        //             parent: widget.animationController!,
        //             curve: Interval((1 / count) * 5, 1.0,
        //                 curve: Curves.fastOutSlowIn))),
        //     mainScreenAnimationController: widget.animationController!,
        //     teNantModel: teNantModels,
        //     cuslang: cus_lang,
        //   ),
        // AreaListView(
        //   mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
        //       CurvedAnimation(
        //           parent: widget.animationController!,
        //           curve: Interval((1 / count) * 5, 1.0,
        //               curve: Curves.fastOutSlowIn))),
        //   mainScreenAnimationController: widget.animationController!,
        //   cuslang: cus_lang,
        //    customerModel: customerModels,
        // ),
        );
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
        body: listViews.isEmpty
            ? Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 30,
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
            : CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  getAppBarUI(),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        widget.animationController?.forward();
                        return listViews[index];
                      },
                      childCount: listViews.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 62 + MediaQuery.of(context).padding.bottom,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget getAppBarUI() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderBar(
        opacity: topBarOpacity,
        title: cus_lang == 'EN' ? 'Payment' : 'การชำระ',
      ),
    );
  }
  // Widget getAppBarUI() {
  //   return Column(
  //     children: <Widget>[
  //       AnimatedBuilder(
  //         animation: widget.animationController!,
  //         builder: (BuildContext context, Widget? child) {
  //           return FadeTransition(
  //             opacity: topBarAnimation!,
  //             child: Transform(
  //               transform: Matrix4.translationValues(
  //                   0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   color: FitnessAppTheme.white.withOpacity(topBarOpacity),
  //                   borderRadius: const BorderRadius.only(
  //                     bottomLeft: Radius.circular(32.0),
  //                   ),
  //                   boxShadow: <BoxShadow>[
  //                     BoxShadow(
  //                         color: FitnessAppTheme.grey
  //                             .withOpacity(0.4 * topBarOpacity),
  //                         offset: const Offset(1.1, 1.1),
  //                         blurRadius: 10.0),
  //                   ],
  //                 ),
  //                 child: Column(
  //                   children: <Widget>[
  //                     SizedBox(
  //                       height: MediaQuery.of(context).padding.top,
  //                     ),
  //                     Padding(
  //                       padding: EdgeInsets.only(
  //                           left: 16,
  //                           right: 16,
  //                           top: 16 - 8.0 * topBarOpacity,
  //                           bottom: 12 - 8.0 * topBarOpacity),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: <Widget>[
  //                           Expanded(
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(8.0),
  //                               child: Text(
  //                                 cus_lang == 'EN' ? 'Payment' : 'การชำระ',
  //                                 textAlign: TextAlign.left,
  //                                 style: TextStyle(
  //                                   fontFamily: FitnessAppTheme.fontName,
  //                                   fontWeight: FontWeight.w700,
  //                                   fontSize: 22 + 6 - 6 * topBarOpacity,
  //                                   letterSpacing: 1.2,
  //                                   color: FitnessAppTheme.darkerText,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           // SizedBox(
  //                           //   height: 38,
  //                           //   width: 38,
  //                           //   child: InkWell(
  //                           //     highlightColor: Colors.transparent,
  //                           //     borderRadius: const BorderRadius.all(
  //                           //         Radius.circular(32.0)),
  //                           //     onTap: () {},
  //                           //     child: Center(
  //                           //       child: Icon(
  //                           //         Icons.keyboard_arrow_left,
  //                           //         color: FitnessAppTheme.grey,
  //                           //       ),
  //                           //     ),
  //                           //   ),
  //                           // ),
  //                           // Padding(
  //                           //   padding: const EdgeInsets.only(
  //                           //     left: 8,
  //                           //     right: 8,
  //                           //   ),
  //                           //   child: Row(
  //                           //     children: <Widget>[
  //                           //       Padding(
  //                           //         padding: const EdgeInsets.only(right: 8),
  //                           //         child: Icon(
  //                           //           Icons.calendar_today,
  //                           //           color: FitnessAppTheme.grey,
  //                           //           size: 18,
  //                           //         ),
  //                           //       ),
  //                           //       Text(
  //                           //         '15 May',
  //                           //         textAlign: TextAlign.left,
  //                           //         style: TextStyle(
  //                           //           fontFamily: FitnessAppTheme.fontName,
  //                           //           fontWeight: FontWeight.normal,
  //                           //           fontSize: 18,
  //                           //           letterSpacing: -0.2,
  //                           //           color: FitnessAppTheme.darkerText,
  //                           //         ),
  //                           //       ),
  //                           //     ],
  //                           //   ),
  //                           // ),
  //                           // SizedBox(
  //                           //   height: 38,
  //                           //   width: 38,
  //                           //   child: InkWell(
  //                           //     highlightColor: Colors.transparent,
  //                           //     borderRadius: const BorderRadius.all(
  //                           //         Radius.circular(32.0)),
  //                           //     onTap: () {},
  //                           //     child: Center(
  //                           //       child: Icon(
  //                           //         Icons.keyboard_arrow_right,
  //                           //         color: FitnessAppTheme.grey,
  //                           //       ),
  //                           //     ),
  //                           //   ),
  //                           // ),
  //                         ],
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       )
  //     ],
  //   );
  // }
}
// ================== WIDGETS ==================

class _HeaderBar extends SliverPersistentHeaderDelegate {
  _HeaderBar({required this.opacity, required this.title});
  final double opacity;
  final String title;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: FitnessAppTheme.white.withOpacity(opacity),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: FitnessAppTheme.grey.withOpacity(0.4 * opacity),
              offset: const Offset(1.1, 1.1),
              blurRadius: 10.0),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).padding.top,
      ),
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/Icon-chao.png'),
              radius: 16,
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: FitnessAppTheme.darkerText,
                letterSpacing: 0.4,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent =>
      kToolbarHeight +
      16 +
      MediaQueryData.fromView(
              WidgetsBinding.instance.platformDispatcher.views.first)
          .padding
          .top;
  @override
  double get minExtent =>
      kToolbarHeight +
      16 +
      MediaQueryData.fromView(
              WidgetsBinding.instance.platformDispatcher.views.first)
          .padding
          .top;
  @override
  bool shouldRebuild(covariant _HeaderBar oldDelegate) =>
      oldDelegate.opacity != opacity || oldDelegate.title != title;
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        decoration: BoxDecoration(
          color: HexColor('#F8FAFC'),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HexColor('#E2E8F0')),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Row(
          children: [
            Icon(icon, color: HexColor('#64748B')),
            const SizedBox(width: 12),
            Expanded(
                child: Text(text,
                    style: TextStyle(
                        color: HexColor('#475569'),
                        fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}
