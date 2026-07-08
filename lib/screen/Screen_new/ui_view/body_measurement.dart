import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Model/GetInvoice_Model.dart';
import '../fitness_app_home_screen.dart';
import '../fitness_app_theme.dart';

class BodyMeasurementView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final List<InvoiceModel>? invoiceModels;
  final double? totaltodays;
  final String? cuslangs;
  final List<String>? totallist;
  final List<String>? totallistPaid;

  BodyMeasurementView({
    Key? key,
    this.animationController,
    this.animation,
    this.totaltodays,
    this.invoiceModels,
    this.cuslangs,
    this.totallist,
    this.totallistPaid,
  }) : super(key: key);

  final List<String> month = [
    "",
    "มกราคม",
    "กุมภาพันธ์",
    "มีนาคม",
    "เมษายน",
    "พฤษภาคม",
    "มิถุนายน",
    "กรกฎาคม",
    "สิงหาคม",
    "กันยายน",
    "ตุลาคม",
    "พฤศจิกายน",
    "ธันวาคม"
  ];
  final nFormat = NumberFormat("#,##0.00", "en_US");
  final DateTime _DateTimeNew = DateTime.now();
  @override
  Widget build(BuildContext context) {
    // print('invoiceModels >> ${invoiceModels!.length}');
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: FitnessAppTheme.white,
                  borderRadius: BorderRadius.circular(18.0),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: FitnessAppTheme.grey.withOpacity(0.12),
                        offset: const Offset(0, 5),
                        blurRadius: 14,
                        spreadRadius: 1),
                  ],
                  border: Border.all(
                    color: FitnessAppTheme.grey.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 16, right: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 4, bottom: 8, top: 16),
                            child: Text(
                              cuslangs == 'EN'
                                  ? 'Total amount to be paid'
                                  : 'ยอดที่ต้องชำระ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  letterSpacing: -0.1,
                                  color: FitnessAppTheme.darkText),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4, bottom: 3),
                                        child: Text(
                                          invoiceModels!.length == 0
                                              ? '0.00'
                                              : '${nFormat.format(invoiceModels!.map((e) => (double.parse(e.amtall!) + double.parse(e.vatall!)) == 0 ? 0 : (double.parse(e.amtall!) + double.parse(e.vatall!))).reduce((a, b) => a + b))}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily:
                                                FitnessAppTheme.fontName,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 25,
                                            color: nFormat.format(invoiceModels!
                                                                .length ==
                                                            0
                                                        ? 0
                                                        : invoiceModels!
                                                            .map((e) => (double.parse(e.amtall!) +
                                                                        double.parse(e
                                                                            .vatall!)) ==
                                                                    0
                                                                ? 0
                                                                : (double.parse(e.amtall!) +
                                                                    double.parse(
                                                                        e.vatall!)))
                                                            .reduce((a, b) => a + b)) ==
                                                    '0.00'
                                                ? FitnessAppTheme.nearlyDarkBlue
                                                : FitnessAppTheme.nearlyDarkRed,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, bottom: 8),
                                        child: Text(
                                          cuslangs == 'EN' ? 'BHT' : 'บาท',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily:
                                                FitnessAppTheme.fontName,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            letterSpacing: -0.2,
                                            color: nFormat.format(invoiceModels!
                                                                .length ==
                                                            0
                                                        ? 0
                                                        : invoiceModels!
                                                            .map((e) => (double.parse(e.amtall!) +
                                                                        double.parse(e
                                                                            .vatall!)) ==
                                                                    0
                                                                ? 0
                                                                : (double.parse(e.amtall!) +
                                                                    double.parse(
                                                                        e.vatall!)))
                                                            .reduce((a, b) => a + b)) ==
                                                    '0.00'
                                                ? FitnessAppTheme.nearlyDarkBlue
                                                : FitnessAppTheme.nearlyDarkRed,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.access_time,
                                        color: FitnessAppTheme.grey
                                            .withOpacity(0.5),
                                        size: 16,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 4.0),
                                        child: Text(
                                          cuslangs == 'EN'
                                              ? 'Today ${DateFormat('HH:mm').format(_DateTimeNew)}'
                                              : 'วันนี้ ${DateFormat('HH:mm').format(_DateTimeNew)}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily:
                                                FitnessAppTheme.fontName,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            letterSpacing: 0.0,
                                            color: FitnessAppTheme.grey
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4, bottom: 14),
                                    child: Text(
                                      cuslangs == 'EN'
                                          ? '${DateFormat.yMMMMd().format(_DateTimeNew)}'
                                          : '${DateFormat('dd').format(_DateTimeNew)} ${month[int.parse(DateFormat('MM').format(_DateTimeNew))]} ${int.parse(DateFormat('yyyy').format(_DateTimeNew)) + 543}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        letterSpacing: 0.0,
                                        color: FitnessAppTheme.nearlyDarkBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8, bottom: 8),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: FitnessAppTheme.background,
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8, bottom: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    cuslangs == 'EN'
                                        ? 'Pending/Verification'
                                        : 'รอยืนยัน/ตรวจสอบ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color:
                                          FitnessAppTheme.grey.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${nFormat.format(totallistPaid!)}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    letterSpacing: -0.2,
                                    color: FitnessAppTheme.nearlyDarkBlue,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    '${nFormat.format(totallist!.fold<double>(0.0, (sum, s) => sum + (double.tryParse(s) ?? 0)))} BHT',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color:
                                          FitnessAppTheme.grey.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        cuslangs == 'EN'
                                            ? 'Invoice'
                                            : 'ทั้งหมด',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: FitnessAppTheme.grey
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${invoiceModels!.length}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        letterSpacing: -0.2,
                                        color: FitnessAppTheme.darkText,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        cuslangs == 'EN'
                                            ? 'Billing slip'
                                            : 'บิล',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: FitnessAppTheme.grey
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      // Text(
                                      //   '20%',
                                      //   style: TextStyle(
                                      //     fontFamily: FitnessAppTheme.fontName,
                                      //     fontWeight: FontWeight.w500,
                                      //     fontSize: 16,
                                      //     letterSpacing: -0.2,
                                      //     color: FitnessAppTheme.darkText,
                                      //   ),
                                      // ),
                                      IconButton(
                                        onPressed: () async {
                                          SharedPreferences preferences =
                                              await SharedPreferences
                                                  .getInstance();
                                          preferences.setString('payby', 'PAY');
                                          MaterialPageRoute route =
                                              MaterialPageRoute(
                                            builder: (context) =>
                                                FitnessAppHomeScreen(
                                                    pageroot: 'PAY'),
                                          );
                                          Navigator.pushAndRemoveUntil(
                                              context, route, (route) => false);
                                        },
                                        icon: Icon(
                                          Icons.play_arrow,
                                          color: FitnessAppTheme.nearlyDarkRed,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          cuslangs == 'EN'
                                              ? 'Pay now'
                                              : 'ชำระค่าบริการ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily:
                                                FitnessAppTheme.fontName,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: FitnessAppTheme.nearlyDarkRed
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
