import 'dart:ui';
import 'package:chaoperty_user/screen/Screen_new/training/repae_book_screen.dart';
import 'package:chaoperty_user/screen/Screen_new/training/training_pay_screen.dart';
import 'package:chaoperty_user/screen/Screen_new/training/training_screen_profile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constant/Myconstant.dart';
import '../bill_history.dart';
import '../home_select_cid.dart';
import '../loginscreen.dart';
import '../pay_bill_screen.dart';
import '../pay_bill_screen_Choice.dart';
import '../pay_screen.dart';
import '../personalinfo_screen.dart';
import '../status_screen.dart';
// import 'bottom_navigation_view/bottom_bar_view.dart';
import 'fitness_app_theme.dart';
import 'invoice/home_Invoice_screen.dart';
import 'mitter/mitter_screen.dart';
// import 'models/tabIcon_data.dart';
import 'my_diary/my_diary_screen.dart';
import 'paystatus/home_status_screen.dart';
import 'paystatus/home_status_screenTem.dart';
import 'rental_contact/rental_screen.dart';
import 'training/training_pay_cid_screen.dart';
import 'training/training_screen.dart';

import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';

class FitnessAppHomeScreen extends StatefulWidget {
  final String? pageroot;
  final String? custno_s;
  final String? initialCid;
  const FitnessAppHomeScreen(
      {super.key, this.pageroot, this.custno_s, this.initialCid});

  @override
  State<FitnessAppHomeScreen> createState() => _FitnessAppHomeScreenState();
}

class _FitnessAppHomeScreenState extends State<FitnessAppHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  // List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  Widget tabBody = Container(color: FitnessAppTheme.background);
  int _currentIndex = 0;

  // ตัวแปรข้อมูลลูกค้า
  String? cus_photo, cus_foder, cus_imglogo_, cus_lang;

  @override
  void initState() {
    super.initState();

    if (widget.pageroot == 'INFO') {
      _currentIndex = 2;
    } else if (widget.pageroot == 'PAY' || widget.pageroot == 'PAYCONTACT') {
      _currentIndex = 1;
    } else {
      _currentIndex = 0;
    }

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    // หน้าเริ่มต้นตาม pageroot
    tabBody = switch (widget.pageroot) {
      'PAY' => TrainingPayScreen(
          animationController: animationController,
          initialCid: widget.initialCid,
        ),
      'INFO' => TrainingScreen(animationController: animationController),
      'MITER' => MitterScreen(animationController: animationController),
      'PAYMENT' => ReceiptPayScreen(animationController: animationController),
      // 'PAYMENT' => StatusScreen(animationController: animationController),
      'PAY_CHOICE' => PayBillscreenChoice(),
      'LOAD' => StatusScreen(animationController: animationController),
      'REPAE' => RepaeScreen(animationController: animationController),
      'CONTACT' => RentalScreen(animationController: animationController),
      'PAYCONTACT' =>
        TrainingPayCidSelectScreen(animationController: animationController),
      'INVOICE' => InvioceScreen(animationController: animationController),
      _ => MyDiaryScreen(animationController: animationController),
    };

    _loadPreference();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final base = MyConstant().domain_chao;
    cus_photo = prefs.getString('photo');
    cus_foder = prefs.getString('foder');
    setState(() {
      cus_lang = prefs.getString('lang');
    });

    if (cus_photo != null &&
        cus_photo!.isNotEmpty &&
        cus_photo!.toLowerCase() != 'null' &&
        (cus_foder ?? '').isNotEmpty) {
      cus_imglogo_ = '$base/files/$cus_foder/contract/$cus_photo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        }),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: FutureBuilder<bool>(
            future: getData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return Stack(
                children: [
                  tabBody,
                  // bottomBar(),
                ],
              );
            },
          ),
          extendBody: true,
          bottomNavigationBar: bottomBar(),
        ),
      ),
    );
  }

  Future<bool> getData() async {
    return true;
  }

  Widget bottomBar() {
    // Removed BackdropFilter(ImageFilter.blur) on 2026-07-08:
    // its web fallback forces an offscreen render of the full bottom bar
    // on every frame, which dominates scroll FPS. The translucent color
    // below gives a near-identical look without the blur cost.
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), // Opaque-ish instead of blur
        border: Border(
            top: BorderSide(
                color: Colors.grey.withOpacity(0.3), width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
                padding: EdgeInsets.only(
                    top: 10,
                    bottom: 10 + MediaQuery.of(context).padding.bottom),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomBarItem(
                      0,
                      _currentIndex == 0
                          ? 'assets/fitness_app/tab_1s.png'
                          : 'assets/fitness_app/tab_1.png',
                      cus_lang == 'EN' ? 'Home' : 'หน้าหลัก',
                    ),
                    _buildBottomBarItem(
                      1,
                      _currentIndex == 1
                          ? 'assets/fitness_app/tab_2s.png'
                          : 'assets/fitness_app/tab_2.png',
                      cus_lang == 'EN' ? 'Payment' : 'การชำระ',
                    ),
                    _buildBottomBarItem(
                      2,
                      _currentIndex == 2
                          ? 'assets/fitness_app/tab_1sx.png'
                          : 'assets/fitness_app/tab_1x.png',
                      cus_lang == 'EN' ? 'Other' : 'อื่นๆ',
                    ),
                    _buildBottomBarItem(
                      3,
                      _currentIndex == 3
                          ? 'assets/fitness_app/tab_3s.png'
                          : 'assets/fitness_app/tab_3.png',
                      cus_lang == 'EN' ? 'Settings' : 'ตั้งค่า',
                    ),
                  ],
                ),
              ),
            ],
          ),
      );
  }

  Widget _buildBottomBarItem(int index, String iconPath, String label) {
    return InkWell(
      onTap: () {
        setState(() => _currentIndex = index);
        _handleTabChange(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
            color: _currentIndex == index
                ? FitnessAppTheme.nearlyDarkBlue.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              width: 22,
              height: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w600,
                fontSize: 10,
                color: _currentIndex == index
                    ? FitnessAppTheme.nearlyDarkBlue
                    : FitnessAppTheme.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTabChange(int index) {
    animationController?.reverse().then((_) async {
      if (!mounted) return;

      switch (index) {
        case 0:
          setState(() {
            tabBody = MyDiaryScreen(animationController: animationController);
          });
          break;
        case 1:
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('payby', 'PAY');
          setState(() {
            tabBody =
                TrainingPayScreen(animationController: animationController);
          });
          break;
        case 2:
          setState(() {
            tabBody = TrainingScreen(animationController: animationController);
          });
          break;
        case 3:
          setState(() {
            tabBody =
                TrainingProfileScreen(animationController: animationController);
          });
          break;
      }
    });
  }
}
