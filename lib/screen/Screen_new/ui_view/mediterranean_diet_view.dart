import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../../Model/GetInvoice_Model.dart';
import '../../../Model/GetTeNant_Model.dart';
import '../../../Model/GetTranBill_model.dart';
import '../../../color.dart';
import '../../../main.dart';
import '../fitness_app_theme.dart';

class MediterranesnDietView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final List<TeNantModel>? teNantModel;
  final List<InvoiceModel>? invoiceModels;
  final String? cuslangs;
  final int open_set_date;
  MediterranesnDietView({
    Key? key,
    this.animationController,
    this.animation,
    this.teNantModel,
    this.invoiceModels,
    this.cuslangs,
    this.open_set_date = 30,
  }) : super(key: key);

  var nFormat = NumberFormat("#,##0.00", "en_US");
  DateTime datex = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: FitnessAppTheme.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                      topRight: Radius.circular(16.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: FitnessAppTheme.grey.withOpacity(0.2),
                        offset: Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 4),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        height: 48,
                                        width: 2,
                                        decoration: BoxDecoration(
                                          color: HexColor('#5271ff')
                                              .withOpacity(0.5),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4, bottom: 2),
                                              child: Text(
                                                cuslangs == 'EN'
                                                    ? 'Rental contract'
                                                    : 'สัญญาทั้งหมด',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: Font_.Fonts_T,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                  letterSpacing: -0.1,
                                                  color: FitnessAppTheme.grey
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                SizedBox(
                                                  width: 28,
                                                  height: 28,
                                                  child: Image.asset(
                                                      "assets/fitness_app/eaten.png"),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 4, bottom: 3),
                                                  child: Text(
                                                    '${teNantModel!.length}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: Font_.Fonts_T,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                      color: FitnessAppTheme
                                                          .darkerText,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 4, bottom: 3),
                                                  child: Text(
                                                    cuslangs == 'EN'
                                                        ? 'Rental'
                                                        : 'สัญญา',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: Font_.Fonts_T,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                      letterSpacing: -0.2,
                                                      color: FitnessAppTheme
                                                          .grey
                                                          .withOpacity(0.5),
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
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        height: 48,
                                        width: 2,
                                        decoration: BoxDecoration(
                                          color: HexColor('#ff8385')
                                              .withOpacity(0.5),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4, bottom: 2),
                                              child: Text(
                                                cuslangs == 'EN'
                                                    ? 'Overdue'
                                                    : 'ค้างชำระ',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: Font_.Fonts_T,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                  letterSpacing: -0.1,
                                                  color: FitnessAppTheme.grey
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                SizedBox(
                                                  width: 28,
                                                  height: 28,
                                                  child: Image.asset(
                                                      "assets/fitness_app/burned.png"),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 4, bottom: 3),
                                                  child: Text(
                                                    invoiceModels!.length == 0
                                                        ? '0.00'
                                                        : '${nFormat.format(invoiceModels!.map((e) => (double.parse(e.amtall!) + double.parse(e.vatall!)) == 0 ? 0 : (double.parse(e.amtall!) + double.parse(e.vatall!))).reduce((a, b) => a + b))}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: Font_.Fonts_T,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                      color: FitnessAppTheme
                                                          .darkerText,
                                                    ),
                                                  ),
                                                ),
                                                // Padding(
                                                //   padding:
                                                //       const EdgeInsets.only(
                                                //           left: 8, bottom: 3),
                                                //   child: Text(
                                                //     cuslangs == 'EN'
                                                //         ? 'BHT'
                                                //         : 'บาท',
                                                //     textAlign: TextAlign.center,
                                                //     style: TextStyle(
                                                //       fontFamily: Font_.Fonts_T,
                                                //       fontWeight:
                                                //           FontWeight.w600,
                                                //       fontSize: 12,
                                                //       letterSpacing: -0.2,
                                                //       color: FitnessAppTheme
                                                //           .grey
                                                //           .withOpacity(0.5),
                                                //     ),
                                                //   ),
                                                // ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 0),
                              child: Center(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width: 150,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: FitnessAppTheme.white,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(100.0),
                                          ),
                                          border: new Border.all(
                                              width: 4,
                                              color: FitnessAppTheme
                                                  .nearlyDarkBlue
                                                  .withOpacity(0.2)),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                              height: 10,
                                            ),
                                            AutoSizeText(
                                              minFontSize: 16,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              invoiceModels!.length == 0
                                                  ? '0.00'
                                                  : '${nFormat.format(invoiceModels!.map((e) => (double.parse(e.amtall!) + double.parse(e.vatall!)) == 0 ? 0 : (double.parse(e.amtall!) + double.parse(e.vatall!))).reduce((a, b) => a + b))}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                letterSpacing: 0.0,
                                                color: HexColor('#ff8385'),
                                                fontFamily: Font_.Fonts_T,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              cuslangs == 'EN' ? 'BHT' : 'บาท',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: Font_.Fonts_T,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                letterSpacing: 0.0,
                                                color: FitnessAppTheme.grey
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: CustomPaint(
                                        painter: CurvePainter(
                                            colors: [
                                              nFormat.format(invoiceModels!
                                                                  .length ==
                                                              0
                                                          ? 0
                                                          : invoiceModels!
                                                              .map((e) => double
                                                                          .parse(e
                                                                              .amtall!) ==
                                                                      0
                                                                  ? 0
                                                                  : double.parse(e
                                                                      .amtall!))
                                                              .reduce((a, b) =>
                                                                  a + b)) ==
                                                      '0.00'
                                                  ? HexColor('#5271ff')
                                                  : HexColor('#ff8385'),
                                              HexColor('#5271ff'),
                                              HexColor('#5271ff')
                                            ],
                                            angle: 140 +
                                                (360 - 140) *
                                                    (1.0 - animation!.value)),
                                        child: SizedBox(
                                          width: 158,
                                          height: 158,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  cuslangs == 'EN' ? 'Rented' : 'สัญญาปัจจุบัน',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                    fontWeight: FontWeight.w500,
                                    // fontSize: 16,
                                    letterSpacing: -0.2,
                                    color: FitnessAppTheme.darkText,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    height: 4,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color:
                                          HexColor('#5271ff').withOpacity(0.2),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4.0)),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width:
                                              ((70 / 1.2) * animation!.value),
                                          height: 4,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: [
                                              HexColor('#5271ff'),
                                              HexColor('#5271ff')
                                                  .withOpacity(0.5),
                                            ]),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4.0)),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    cuslangs == 'EN'
                                        ? '${teNantModel!.map((e) {
                                            if (e.quantity == '2' ||
                                                e.quantity == '3') return 1;
                                            if (e.quantity == '1') {
                                              DateTime lDate = e.ldate == null
                                                  ? DateTime.parse(
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(datex))
                                                  : DateTime.parse(
                                                      '${e.ldate} 00:00:00.000');
                                              bool isExpired =
                                                  datex.isAfter(lDate);
                                              bool isAlmost = datex.isAfter(
                                                  lDate.subtract(Duration(
                                                      days: open_set_date)));
                                              if (!isExpired && !isAlmost)
                                                return 1;
                                            }
                                            return 0;
                                          }).reduce((a, b) => a + b)} Rental'
                                        : '${teNantModel!.map((e) {
                                            if (e.quantity == '2' ||
                                                e.quantity == '3') return 1;
                                            if (e.quantity == '1') {
                                              DateTime lDate = e.ldate == null
                                                  ? DateTime.parse(
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(datex))
                                                  : DateTime.parse(
                                                      '${e.ldate} 00:00:00.000');
                                              bool isExpired =
                                                  datex.isAfter(lDate);
                                              bool isAlmost = datex.isAfter(
                                                  lDate.subtract(Duration(
                                                      days: open_set_date)));
                                              if (!isExpired && !isAlmost)
                                                return 1;
                                            }
                                            return 0;
                                          }).reduce((a, b) => a + b)} สัญญา',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      cuslangs == 'EN' ? 'Expired' : 'หมดสัญญา',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: Font_.Fonts_T,
                                        fontWeight: FontWeight.w500,
                                        // fontSize: 16,
                                        letterSpacing: -0.2,
                                        color: FitnessAppTheme.darkText,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Container(
                                        height: 4,
                                        width: 70,
                                        decoration: BoxDecoration(
                                          color: HexColor('#ff8385')
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: ((70 / 2) *
                                                  animationController!.value),
                                              height: 4,
                                              decoration: BoxDecoration(
                                                gradient:
                                                    LinearGradient(colors: [
                                                  HexColor('#ff8385')
                                                      .withOpacity(0.1),
                                                  HexColor('#ff8385'),
                                                ]),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4.0)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        cuslangs == 'EN'
                                            ? '${teNantModel!.map((e) {
                                                if (e.quantity == '1') {
                                                  DateTime lDate = e.ldate ==
                                                          null
                                                      ? DateTime.parse(
                                                          DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(datex))
                                                      : DateTime.parse(
                                                          '${e.ldate} 00:00:00.000');
                                                  if (datex.isAfter(lDate))
                                                    return 1;
                                                }
                                                return 0;
                                              }).reduce((a, b) => a + b)} Rental'
                                            : '${teNantModel!.map((e) {
                                                if (e.quantity == '1') {
                                                  DateTime lDate = e.ldate ==
                                                          null
                                                      ? DateTime.parse(
                                                          DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(datex))
                                                      : DateTime.parse(
                                                          '${e.ldate} 00:00:00.000');
                                                  if (datex.isAfter(lDate))
                                                    return 1;
                                                }
                                                return 0;
                                              }).reduce((a, b) => a + b)} สัญญา',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: Font_.Fonts_T,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      cuslangs == 'EN'
                                          ? 'Almost Expired'
                                          : 'ใกล้หมดสัญญา',
                                      style: TextStyle(
                                        fontFamily: Font_.Fonts_T,
                                        fontWeight: FontWeight.w500,
                                        // fontSize: 16,
                                        letterSpacing: -0.2,
                                        color: FitnessAppTheme.darkText,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 0, top: 4),
                                      child: Container(
                                        height: 4,
                                        width: 70,
                                        decoration: BoxDecoration(
                                          color: HexColor('#F1B440')
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: ((70 / 2.5) *
                                                  animationController!.value),
                                              height: 4,
                                              decoration: BoxDecoration(
                                                gradient:
                                                    LinearGradient(colors: [
                                                  HexColor('#F1B440')
                                                      .withOpacity(0.1),
                                                  HexColor('#F1B440'),
                                                ]),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4.0)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        cuslangs == 'EN'
                                            ? '${teNantModel!.map((e) {
                                                if (e.quantity == '1') {
                                                  DateTime lDate = e.ldate ==
                                                          null
                                                      ? DateTime.parse(
                                                          DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(datex))
                                                      : DateTime.parse(
                                                          '${e.ldate} 00:00:00.000');
                                                  bool isExpired =
                                                      datex.isAfter(lDate);
                                                  bool isAlmost = datex.isAfter(
                                                      lDate.subtract(Duration(
                                                          days:
                                                              open_set_date)));
                                                  if (!isExpired && isAlmost)
                                                    return 1;
                                                }
                                                return 0;
                                              }).reduce((a, b) => a + b)} Rental'
                                            : '${teNantModel!.map((e) {
                                                if (e.quantity == '1') {
                                                  DateTime lDate = e.ldate ==
                                                          null
                                                      ? DateTime.parse(
                                                          DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(datex))
                                                      : DateTime.parse(
                                                          '${e.ldate} 00:00:00.000');
                                                  bool isExpired =
                                                      datex.isAfter(lDate);
                                                  bool isAlmost = datex.isAfter(
                                                      lDate.subtract(Duration(
                                                          days:
                                                              open_set_date)));
                                                  if (!isExpired && isAlmost)
                                                    return 1;
                                                }
                                                return 0;
                                              }).reduce((a, b) => a + b)} สัญญา',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: Font_.Fonts_T,
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

class CurvePainter extends CustomPainter {
  final double? angle;
  final List<Color>? colors;

  CurvePainter({this.colors, this.angle = 140});

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> colorsList = [];
    if (colors != null) {
      colorsList = colors ?? [];
    } else {
      colorsList.addAll([Colors.white, Colors.white]);
    }

    final shdowPaint = new Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final shdowPaintCenter = new Offset(size.width / 2, size.height / 2);
    final shdowPaintRadius =
        math.min(size.width / 2, size.height / 2) - (14 / 2);
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.3);
    shdowPaint.strokeWidth = 16;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.2);
    shdowPaint.strokeWidth = 20;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.1);
    shdowPaint.strokeWidth = 22;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    final rect = new Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final gradient = new SweepGradient(
      startAngle: degreeToRadians(268),
      endAngle: degreeToRadians(270.0 + 360),
      tileMode: TileMode.repeated,
      colors: colorsList,
    );
    final paint = new Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round // StrokeCap.round is not recommended.
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final center = new Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (14 / 2);

    canvas.drawArc(
        new Rect.fromCircle(center: center, radius: radius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        paint);

    final gradient1 = new SweepGradient(
      tileMode: TileMode.repeated,
      colors: [Colors.white, Colors.white],
    );

    var cPaint = new Paint();
    cPaint..shader = gradient1.createShader(rect);
    cPaint..color = Colors.white;
    cPaint..strokeWidth = 14 / 2;
    canvas.save();

    final centerToCircle = size.width / 2;
    canvas.save();

    canvas.translate(centerToCircle, centerToCircle);
    canvas.rotate(degreeToRadians(angle! + 2));

    canvas.save();
    canvas.translate(0.0, -centerToCircle + 14 / 2);
    canvas.drawCircle(new Offset(0, 0), 14 / 5, cPaint);

    canvas.restore();
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadians(double degree) {
    var redian = (math.pi / 180) * degree;
    return redian;
  }
}
