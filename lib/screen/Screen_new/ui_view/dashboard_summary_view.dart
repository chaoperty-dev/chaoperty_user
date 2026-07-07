import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Model/GetInvoice_Model.dart';
import '../../../Model/GetTeNant_Model.dart';
import '../../../color.dart';
import '../../../main.dart';
import '../fitness_app_home_screen.dart';
import '../fitness_app_theme.dart';

/// การ์ดสรุป Dashboard รวมข้อมูลจาก MediterranesnDietView + BodyMeasurementView
/// สไตล์เดิม: พื้นหลังขาว, แถบสีซ้าย, ตัวเลขใหญ่, สีน้ำเงิน/แดงตามสถานะ
class DashboardSummaryView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final List<TeNantModel>? teNantModel;
  final List<InvoiceModel>? invoiceModels;
  final double? totaltodays;
  final String? cuslangs;
  final int open_set_date;

  DashboardSummaryView({
    Key? key,
    this.animationController,
    this.animation,
    this.teNantModel,
    this.invoiceModels,
    this.totaltodays,
    this.cuslangs,
    this.open_set_date = 30,
  }) : super(key: key);

  final nFormat = NumberFormat("#,##0.00", "en_US");
  final DateTime datex = DateTime.now();

  double get _totalOutstanding {
    if (invoiceModels == null || invoiceModels!.isEmpty) return 0.0;
    return invoiceModels!.fold(0.0, (sum, e) {
      final amt = double.tryParse(e.amtall ?? '') ?? 0.0;
      final vat = double.tryParse(e.vatall ?? '') ?? 0.0;
      return sum + amt + vat;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEN = cuslangs == 'EN';
    final total = _totalOutstanding;
    final today = totaltodays ?? 0.0;
    final invoiceCount = invoiceModels?.length ?? 0;
    final contractCount = teNantModel?.length ?? 0;
    final isDue = total > 0;

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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  child: Column(
                    children: <Widget>[
                      // ── Top section: total outstanding + contract stats ──
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20, left: 20, right: 20, bottom: 16),
                        child: Row(
                          children: <Widget>[
                            // Left: stat rows
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 4, right: 12, top: 4),
                                child: Column(
                                  children: <Widget>[
                                    _statRow(
                                      isEN ? 'Rental contract' : 'สัญญาทั้งหมด',
                                      '$contractCount',
                                      isEN ? 'Rental' : 'สัญญา',
                                      HexColor('#5271ff'),
                                      'assets/fitness_app/eaten.png',
                                    ),
                                    const SizedBox(height: 12),
                                    _statRow(
                                      isEN ? 'Overdue' : 'ค้างชำระ',
                                      nFormat.format(total),
                                      '',
                                      HexColor('#ff8385'),
                                      'assets/fitness_app/burned.png',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Circular total display
                            Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: FitnessAppTheme.white,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(100.0),
                                        ),
                                        border: Border.all(
                                            width: 4,
                                            color: FitnessAppTheme
                                                .nearlyDarkBlue
                                                .withOpacity(0.15)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          const SizedBox(height: 8),
                                          AutoSizeText(
                                            nFormat.format(total),
                                            minFontSize: 14,
                                            maxFontSize: 20,
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              letterSpacing: 0.0,
                                              color: isDue
                                                  ? HexColor('#ff8385')
                                                  : HexColor('#5271ff'),
                                              fontFamily: Font_.Fonts_T,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            isEN ? 'BHT' : 'บาท',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: Font_.Fonts_T,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
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
                                            isDue
                                                ? HexColor('#ff8385')
                                                : HexColor('#5271ff'),
                                            HexColor('#5271ff'),
                                            HexColor('#5271ff')
                                          ],
                                          angle: 140 +
                                              (360 - 140) *
                                                  (1.0 - animation!.value)),
                                      child: const SizedBox(
                                        width: 128,
                                        height: 128,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      // ── Divider ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 1,
                          color: FitnessAppTheme.background,
                        ),
                      ),
                      // ── Bottom section: today + invoices + pay ──
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 16, bottom: 16),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: _miniStat(
                                isEN ? 'Today' : 'วันนี้',
                                nFormat.format(today),
                                FitnessAppTheme.nearlyDarkBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _miniStat(
                                isEN ? 'Invoices' : 'บิล',
                                '$invoiceCount',
                                FitnessAppTheme.darkText,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _payButton(context, isEN),
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
        );
      },
    );
  }

  Widget _statRow(String label, String value, String unit, Color accent,
      String imageAsset) {
    return Row(
      children: <Widget>[
        Container(
          height: 44,
          width: 3,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: FitnessAppTheme.grey.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Image.asset(imageAsset),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: FitnessAppTheme.darkerText,
                    ),
                  ),
                  if (unit.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 2),
                      child: Text(
                        unit,
                        style: TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: FitnessAppTheme.grey.withOpacity(0.5),
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _miniStat(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FitnessAppTheme.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: Font_.Fonts_T,
              fontSize: 11,
              color: FitnessAppTheme.grey.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _payButton(BuildContext context, bool isEN) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: HexColor('#ff8385'),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: HexColor('#ff8385').withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final preferences = await SharedPreferences.getInstance();
            await preferences.setString('payby', 'PAY');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => FitnessAppHomeScreen(pageroot: 'PAY'),
              ),
              (route) => false,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 2),
                Text(
                  isEN ? 'Pay' : 'ชำระ',
                  style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// CurvePainter จาก MediterranesnDietView เดิม
class CurvePainter extends CustomPainter {
  final double? angle;
  final List<Color>? colors;

  CurvePainter({this.colors, this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> colorsList = [];
    if (colors != null) {
      colorsList = colors ?? [];
    } else {
      colorsList.addAll([Colors.white, Colors.white]);
    }

    final shdowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final shdowPaintCenter = Offset(size.width / 2, size.height / 2);
    final shdowPaintRadius =
        math.min(size.width / 2, size.height / 2) - (14 / 2);
    canvas.drawCircle(shdowPaintCenter, shdowPaintRadius, shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.3);
    shdowPaint.strokeWidth = 16;
    canvas.drawCircle(shdowPaintCenter, shdowPaintRadius, shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.2);
    shdowPaint.strokeWidth = 20;
    canvas.drawCircle(shdowPaintCenter, shdowPaintRadius, shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.1);
    shdowPaint.strokeWidth = 24;
    canvas.drawCircle(shdowPaintCenter, shdowPaintRadius, shdowPaint);

    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final gradient = SweepGradient(
      startAngle: degreeToRadian(270),
      endAngle: degreeToRadian(270 + 360),
      tileMode: TileMode.repeated,
      colors: colorsList,
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (14 / 2);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        degreeToRadian(140), degreeToRadian(angle ?? 360), false, paint);

    final gradient1 = LinearGradient(
      colors: [
        Color(0xffb4bee0),
        Colors.white,
      ],
    );

    final paint1 = Paint()
      ..shader = gradient1.createShader(rect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    final center1 = Offset(size.width / 2, size.height / 2);
    final radius1 = math.min(size.width / 2, size.height / 2) - (14 / 2);

    canvas.drawArc(
        Rect.fromCircle(center: center1, radius: radius1),
        degreeToRadian(140),
        degreeToRadian(360 - (angle ?? 360)),
        false,
        paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadian(double degree) {
    var radian = (math.pi / 180) * degree;
    return radian;
  }
}
