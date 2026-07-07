// ignore_for_file: must_be_immutable

import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import '../../../Model/GetTeNant_Model.dart';
import '../../../Model/GetTranBill_model.dart';
import '../../../main.dart';
import '../fitness_app_home_screen.dart';
import '../fitness_app_theme.dart';
import '../models/meals_list_data.dart';

class MealsListView extends StatefulWidget {
  const MealsListView({
    Key? key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
    this.teNantModel,
    this.totallist,
    this.totallistPaid,
    this.cuslangs,
    this.open_set_date = 30,
  }) : super(key: key);

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<String>? totallist;
  final List<String>? totallistPaid;
  final List<TeNantModel>? teNantModel;
  final String? cuslangs;
  final int open_set_date;
  @override
  _MealsListViewState createState() => _MealsListViewState();
}

class _MealsListViewState extends State<MealsListView>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  List<TeNantModel> mealsListData = [];
  var nFormat = NumberFormat("#,##0.00", "en_US");
  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
    mealsListData = widget.teNantModel!;
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
            child: Container(
              height: 250,
              width: double.infinity,
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                }),
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                      top: 0, bottom: 0, right: 16, left: 16),
                  itemCount: mealsListData.length,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    final int count = mealsListData.length;
                    final Animation<double> animation =
                        Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                                parent: animationController!,
                                curve: Interval((1 / count) * index, 1.0,
                                    curve: Curves.fastOutSlowIn)));
                    animationController?.forward();

                    return MealsView(
                      mealsListData: mealsListData[index],
                      animation: animation,
                      animationController: animationController!,
                      codecolor: (256 + (index * 10)).toString(),
                      sumAll: nFormat
                          .format(double.parse(widget.totallist![index])),
                      sumPaid: nFormat.format(double.parse(
                          (widget.totallistPaid?.length != null &&
                                  widget.totallistPaid!.length > index)
                              ? widget.totallistPaid![index]
                              : '0.00')),
                      cuslangs: widget.cuslangs,
                      open_set_date: widget.open_set_date,
                    ); //mealsListData[index].total
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MealsView extends StatelessWidget {
  MealsView(
      {Key? key,
      this.mealsListData,
      this.animationController,
      this.animation,
      this.codecolor,
      this.sumAll,
      this.sumPaid,
      this.cuslangs,
      this.open_set_date = 30})
      : super(key: key);

  final TeNantModel? mealsListData;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final String? codecolor;
  final String? sumAll;
  final String? sumPaid;
  final String? cuslangs;
  final int open_set_date;
  DateTime datex = DateTime.now();

  // แบดจ์ข้อมูล (โซน/พื้นที่/ประเภท) แบบมีไอคอน ดูเรียบร้อยขึ้น
  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: FitnessAppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: FitnessAppTheme.grey.withOpacity(0.7)),
          const SizedBox(width: 4),
          AutoSizeText(
            label,
            minFontSize: 6,
            maxFontSize: 12,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontWeight: FontWeight.w600,
              color: FitnessAppTheme.grey.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  // แบดจ์แสดงยอดที่มี payment intent อยู่แล้ว/ชำระไปแล้ว
  Widget _paidChip() {
    return Container(
      margin: const EdgeInsets.only(left: 6, top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 10, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            '${cuslangs == 'EN' ? 'Paid' : 'รอตรวจสอบ'} $sumPaid',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors() {
    if (mealsListData!.quantity == '1') {
      DateTime lDate;
      if (mealsListData!.ldate == null) {
        lDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(datex));
      } else {
        lDate = DateTime.parse('${mealsListData!.ldate} 00:00:00.000');
      }

      // Check if Datex is After LDate (Expired) -> Red Gradient
      if (datex.isAfter(lDate.subtract(const Duration(days: 0)))) {
        return [HexColor('#ff8385'), HexColor('#ff4f52')];
      }
      // Check if Datex is After Start Date (Open for Payment) -> Yellow/Orange Gradient
      else if (datex.isAfter(lDate.subtract(Duration(days: open_set_date)))) {
        return [HexColor('#F1B440'), HexColor('#FF8C00')];
      }
      // Else (Not yet in window?) -> Blue Gradient
      else {
        return [HexColor('#5271ff'), HexColor('#3a50b5')];
      }
    } else if (mealsListData!.quantity == '2') {
      return [HexColor('#5271ff'), HexColor('#3a50b5')];
    } else if (mealsListData!.quantity == '3') {
      return [HexColor('#5271ff'), HexColor('#3a50b5')];
    } else {
      return [Colors.greenAccent, Colors.green[700]!];
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = _getGradientColors();

    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation!.value), 0.0, 0.0),
            child: SizedBox(
              width: 140,
              height: 230,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 16, left: 8, right: 8, bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(18.0)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: const Color(0xff384250).withOpacity(0.12),
                              offset: const Offset(0, 8),
                              blurRadius: 16,
                              spreadRadius: 2),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Column(
                          children: [
                            // 1. Top Section (White) - ID, Zone, Total Pay Label
                            Expanded(
                              child: Container(
                                color: Colors.white,
                                // Decreased top padding as we handle spacing via Column/Stack
                                padding:
                                    const EdgeInsets.fromLTRB(12, 36, 12, 0),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0.0), // Space for GIF
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // ID (Dark Blue)
                                          AutoSizeText(
                                            mealsListData!.cid!,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              color: FitnessAppTheme
                                                  .nearlyDarkBlue,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          // Zone Badge (Grey Pill)
                                          _infoChip(
                                            Icons.map_outlined,
                                            cuslangs == 'EN'
                                                ? 'Zone: ${mealsListData!.zn}'
                                                : 'โซน: ${mealsListData!.zn}',
                                          ),
                                          SizedBox(height: 6),
                                          _infoChip(
                                            Icons.square_foot_outlined,
                                            cuslangs == 'EN'
                                                ? 'Area: ${mealsListData!.ln}'
                                                : 'พื้นที่: ${mealsListData!.ln}',
                                          ),
                                          SizedBox(height: 6),
                                          _infoChip(
                                            Icons.category_outlined,
                                            cuslangs == 'EN'
                                                ? 'Type: ${mealsListData!.stype}'
                                                : 'ประเภท: ${mealsListData!.stype}',
                                          ),
                                        ],
                                      ),

                                      // "Total Pay" Label
                                      // Padding(
                                      //   padding:
                                      //       const EdgeInsets.only(bottom: 6.0),
                                      //   child: Text(
                                      //     cuslangs == 'EN'
                                      //         ? 'Total Pay'
                                      //         : 'ยอดชำระ',
                                      //     style: TextStyle(
                                      //       fontFamily:
                                      //           FitnessAppTheme.fontName,
                                      //       fontSize: 14,
                                      //       fontWeight: FontWeight.w700,
                                      //       color: FitnessAppTheme.grey,
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // 2. Slim Gradient Footer (Bottom 52px)
                            Stack(
                              children: [
                                Container(
                                  height: 55,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradientColors,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Padding(
                                    // padding: const EdgeInsets.symmetric(
                                    //     horizontal: 12.0),
                                    padding:
                                        const EdgeInsets.fromLTRB(4, 4, 4, 4),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: AutoSizeText(
                                            sumAll.toString(),
                                            maxLines: 1,
                                            // User Custom Fonts
                                            minFontSize: 7,
                                            maxFontSize: 16,
                                            style: TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        if (sumAll != '0.00')
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: gradientColors[0],
                                              size: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),

                                // if ((sumPaid ?? '0.00') == '0.00')
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  // right: 0,
                                  // bottom: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 6.0, left: 8),
                                    child: Text(
                                      cuslangs == 'EN'
                                          ? 'Total Pay'
                                          : 'ยอดชำระ',
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: FitnessAppTheme.white,
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
                  ),

                  // 3. Full Tap Interaction
                  Positioned.fill(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16.0), // Match container padding
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: sumAll == '0.00'
                              ? null
                              : () async {
                                  SharedPreferences preferences =
                                      await SharedPreferences.getInstance();
                                  preferences.setString(
                                      'usercid', mealsListData!.cid.toString());
                                  preferences.setString('payby', 'PAY');
                                  MaterialPageRoute route = MaterialPageRoute(
                                    builder: (context) => FitnessAppHomeScreen(
                                      pageroot: 'PAY',
                                      initialCid: mealsListData!.cid.toString(),
                                    ),
                                  );
                                  Navigator.push(context, route);
                                },
                        ),
                      ),
                    ),
                  ),
                  // GIF: Positioned Top-Left (Inside Clipping)
                  if (sumAll != '0.00')
                    Positioned(
                      top: 0,
                      left: 0,
                      width: 60,
                      height: 60,
                      child: Opacity(
                        opacity: 1.0,
                        child: Image.asset(
                          'assets/fitness_app/giphy7.gif',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  // if ((sumPaid ?? '0.00') != '0.00')
                  //   Positioned(
                  //     bottom: 0,
                  //     left: 0, width: 135,
                  //     // width: ((sumPaid ?? '0.00') != '0.00') ? null : 60,
                  //     // height: ((sumPaid ?? '0.00') != '0.00') ? null : 60,
                  //     child: _paidChip(),
                  //   ),
                  // Maintenance Icon (Grey/Red)
                  if (mealsListData!.mainten.toString() == '1' ||
                      mealsListData!.mainten.toString() == '2')
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Icon(
                        Icons.build,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
