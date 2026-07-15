// ignore_for_file: must_be_immutable

import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Model/GetTeNant_Model.dart';
import '../../../main.dart';
import '../fitness_app_home_screen.dart';
import '../fitness_app_theme.dart';

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
    mealsListData = widget.teNantModel ?? [];
    if (animationController?.status == AnimationStatus.dismissed) {
      animationController?.forward();
    }
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
              // ✅ FIX: เพิ่ม height 205 → 240 ให้ container parent
              // สอดคล้องกับ card height ใหม่ (เดิม 206 → 240)
              height: 240,
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
      // ✅ FIX: width:double.infinity ทำให้ chip ขยายเต็มความกว้างของ Column parent
      // เพื่อจำกัด max width ของ Expanded (AutoSizeText) ป้องกัน
      // "RenderFlex overflowed by N pixels on the right"
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: FitnessAppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: FitnessAppTheme.grey.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon,
                size: 11, color: FitnessAppTheme.grey.withOpacity(0.7)),
          ),
          const SizedBox(width: 4),
          // ✅ FIX: Expanded บังคับ max width ให้ AutoSizeText + maxLines:2
          // อนุญาตให้ wrap ได้ 2 บรรทัด เพื่อให้เห็นข้อความเต็ม
          // (ก่อนหน้านี้ maxLines:1 + ellipsis ทำให้อ่านไม่ออก)
          Expanded(
            child: AutoSizeText(
              label,
              minFontSize: 8,
              maxFontSize: 11,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: FitnessAppTheme.grey.withOpacity(0.85),
              ),
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
              // ✅ FIX: เพิ่ม height 206 → 240 รองรับ chip ที่ wrap 2 lines
              // (ป้องกัน "BOTTOM OVERFLOWED BY 14-15 PIXELS" ที่เกิดจาก
              //  chip _infoChip() มี wrap 2 บรรทัด ทำให้ content height เกิน)
              height: 240,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 8, right: 8, bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16.0)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: const Color(0xff384250).withOpacity(0.06),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                              spreadRadius: 0),
                        ],
                        border: Border.all(
                          color: FitnessAppTheme.grey.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            // 1. Top Section (White) - ID, Zone, Total Pay Label
                            Expanded(
                              child: Container(
                                color: Colors.white,
                                // Decreased top padding as we handle spacing via Column/Stack
                                padding:
                                    const EdgeInsets.fromLTRB(12, 24, 12, 0),
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
                                              fontSize: 15,
                                              color: FitnessAppTheme
                                                  .nearlyDarkBlue,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          // Zone Badge (Grey Pill)
                                          _infoChip(
                                            Icons.map_outlined,
                                            cuslangs == 'EN'
                                                ? 'Zone: ${mealsListData!.zn}'
                                                : 'โซน: ${mealsListData!.zn}',
                                          ),
                                          SizedBox(height: 5),
                                          _infoChip(
                                            Icons.square_foot_outlined,
                                            cuslangs == 'EN'
                                                ? 'Area: ${mealsListData!.ln}'
                                                : 'พื้นที่: ${mealsListData!.ln}',
                                          ),
                                          SizedBox(height: 5),
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

                            // 2. Slim Gradient Footer (Bottom 40px)
                            Container(
                              height: 40,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              padding: const EdgeInsets.fromLTRB(12, 3, 12, 4),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    child: Text(
                                      cuslangs == 'EN'
                                          ? 'Total Pay'
                                          : 'ยอดชำระ',
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: FitnessAppTheme.white,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: AutoSizeText(
                                            sumAll.toString(),
                                            maxLines: 1,
                                            minFontSize: 7,
                                            maxFontSize: 15,
                                            style: TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        if (sumAll != '0.00')
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: gradientColors[0],
                                              size: 10,
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
                      top: 2,
                      left: 2,
                      width: 40,
                      height: 40,
                      child: Opacity(
                        opacity: 0.9,
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
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.build_circle,
                          color: Colors.redAccent.withOpacity(0.85),
                          size: 16,
                        ),
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
