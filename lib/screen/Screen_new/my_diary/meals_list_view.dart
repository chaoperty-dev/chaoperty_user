// ignore_for_file: must_be_immutable

import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Model/GetTeNant_Model.dart';
import '../fitness_app_home_screen.dart';

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
  final nFormat = NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
    super.initState();
    mealsListData = widget.teNantModel ?? [];
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
              height: 220,
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

                    final outstanding = double.tryParse(
                            widget.totallist?.length != null &&
                                    widget.totallist!.length > index
                                ? widget.totallist![index]
                                : '0.00') ??
                        0.0;
                    final pending = double.tryParse(
                            widget.totallistPaid?.length != null &&
                                    widget.totallistPaid!.length > index
                                ? widget.totallistPaid![index]
                                : '0.00') ??
                        0.0;

                    return MealsView(
                      mealsListData: mealsListData[index],
                      animation: animation,
                      animationController: animationController!,
                      sumAll: nFormat.format(outstanding),
                      sumPaid: nFormat.format(pending),
                      cuslangs: widget.cuslangs,
                      open_set_date: widget.open_set_date,
                    );
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
  MealsView({
    Key? key,
    this.mealsListData,
    this.animationController,
    this.animation,
    this.sumAll,
    this.sumPaid,
    this.cuslangs,
    this.open_set_date = 30,
  }) : super(key: key);

  final TeNantModel? mealsListData;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final String? sumAll;
  final String? sumPaid;
  final String? cuslangs;
  final int open_set_date;
  final DateTime datex = DateTime.now();

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: const Color(0xFF6B7280)),
          const SizedBox(width: 4),
          AutoSizeText(
            label,
            minFontSize: 6,
            maxFontSize: 11,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'LINESeed2',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors() {
    final q = mealsListData?.quantity;
    if (q == '2' || q == '3') {
      return const [Color(0xFF4F46E5), Color(0xFF7C3AED)];
    }
    if (q == '1') {
      final lDate = mealsListData?.ldate == null
          ? DateTime(datex.year, datex.month, datex.day)
          : DateTime.tryParse(mealsListData!.ldate.toString()) ?? datex;
      if (datex.isAfter(lDate)) {
        return const [Color(0xFFF87171), Color(0xFFDC2626)];
      } else if (datex.isAfter(lDate.subtract(Duration(days: open_set_date)))) {
        return const [Color(0xFFFBBF24), Color(0xFFF59E0B)];
      }
    }
    return const [Color(0xFF4F46E5), Color(0xFF7C3AED)];
  }

  String _statusLabel() {
    final q = mealsListData?.quantity;
    if (q == '2' || q == '3') {
      return cuslangs == 'EN' ? 'Active' : 'ปัจจุบัน';
    }
    if (q == '1') {
      final lDate = mealsListData?.ldate == null
          ? DateTime(datex.year, datex.month, datex.day)
          : DateTime.tryParse(mealsListData!.ldate.toString()) ?? datex;
      if (datex.isAfter(lDate)) {
        return cuslangs == 'EN' ? 'Expired' : 'หมดสัญญา';
      } else if (datex.isAfter(lDate.subtract(Duration(days: open_set_date)))) {
        return cuslangs == 'EN' ? 'Almost' : 'ใกล้หมด';
      }
    }
    return cuslangs == 'EN' ? 'Active' : 'ปัจจุบัน';
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getGradientColors();
    final isEN = cuslangs == 'EN';
    final hasOutstanding = (sumAll ?? '0.00') != '0.00';
    final hasPending = (sumPaid ?? '0.00') != '0.00';

    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                80 * (1.0 - animation!.value), 0.0, 0.0),
            child: SizedBox(
              width: 170,
              height: 200,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 12, left: 8, right: 8, bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff384250).withOpacity(0.08),
                        offset: const Offset(0, 6),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: hasOutstanding
                            ? () async {
                                final preferences =
                                    await SharedPreferences.getInstance();
                                await preferences.setString(
                                    'usercid', mealsListData!.cid.toString());
                                await preferences.setString('payby', 'PAY');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FitnessAppHomeScreen(
                                      pageroot: 'PAY',
                                      initialCid: mealsListData!.cid.toString(),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header gradient
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.fromLTRB(14, 10, 14, 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: AutoSizeText(
                                      mealsListData?.cid ?? '-',
                                      maxLines: 1,
                                      minFontSize: 10,
                                      maxFontSize: 15,
                                      style: const TextStyle(
                                        fontFamily: 'LINESeed2',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _statusLabel(),
                                      style: const TextStyle(
                                        fontFamily: 'LINESeed2',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Body
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(14, 12, 14, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _infoChip(
                                      Icons.map_outlined,
                                      isEN
                                          ? 'Zone ${mealsListData?.zn ?? '-'}'
                                          : 'โซน ${mealsListData?.zn ?? '-'}',
                                    ),
                                    const SizedBox(height: 6),
                                    _infoChip(
                                      Icons.square_foot_outlined,
                                      isEN
                                          ? 'Area ${mealsListData?.ln ?? '-'}'
                                          : 'พื้นที่ ${mealsListData?.ln ?? '-'}',
                                    ),
                                    const SizedBox(height: 6),
                                    _infoChip(
                                      Icons.category_outlined,
                                      isEN
                                          ? '${mealsListData?.stype ?? '-'}'
                                          : '${mealsListData?.stype ?? '-'}',
                                    ),
                                    const Spacer(),
                                    // Outstanding
                                    Text(
                                      isEN ? 'Outstanding' : 'ยอดค้าง',
                                      style: const TextStyle(
                                        fontFamily: 'LINESeed2',
                                        fontSize: 10,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    AutoSizeText(
                                      sumAll ?? '0.00',
                                      maxLines: 1,
                                      minFontSize: 10,
                                      maxFontSize: 18,
                                      style: TextStyle(
                                        fontFamily: 'LINESeed2',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: hasOutstanding
                                            ? const Color(0xFFDC2626)
                                            : const Color(0xFF6B7280),
                                      ),
                                    ),
                                    // Pending
                                    if (hasPending) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.pending_outlined,
                                              size: 10,
                                              color: Color(0xFFD97706),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isEN
                                                  ? 'Pending $sumPaid'
                                                  : 'รอตรวจ $sumPaid',
                                              style: const TextStyle(
                                                fontFamily: 'LINESeed2',
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFFD97706),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            // Maintenance indicator
                            if (mealsListData?.mainten.toString() == '1' ||
                                mealsListData?.mainten.toString() == '2')
                              Container(
                                width: double.infinity,
                                color: const Color(0xFFFEF2F2),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.build,
                                      size: 12,
                                      color: Color(0xFFEF4444),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isEN ? 'Maintenance' : 'ซ่อมบำรุง',
                                      style: const TextStyle(
                                        fontFamily: 'LINESeed2',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFEF4444),
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
