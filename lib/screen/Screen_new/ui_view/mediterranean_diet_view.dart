import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../../Model/GetInvoice_Model.dart';
import '../../../Model/GetTeNant_Model.dart';
import '../../../color.dart';

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

  int _countByStatus(String status) {
    if (teNantModel == null) return 0;
    return teNantModel!.fold(0, (sum, e) {
      if (e.quantity == '2' || e.quantity == '3') {
        return status == 'active' ? sum + 1 : sum;
      }
      if (e.quantity != '1') return sum;

      final lDate = e.ldate == null
          ? DateTime(datex.year, datex.month, datex.day)
          : DateTime.tryParse(e.ldate.toString()) ?? datex;
      final isExpired = datex.isAfter(lDate);
      final isAlmost =
          datex.isAfter(lDate.subtract(Duration(days: open_set_date)));

      if (status == 'active') return (!isExpired && !isAlmost) ? sum + 1 : sum;
      if (status == 'expired') return isExpired ? sum + 1 : sum;
      if (status == 'almost') return (!isExpired && isAlmost) ? sum + 1 : sum;
      return sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEN = cuslangs == 'EN';
    final total = _totalOutstanding;
    final activeCount = _countByStatus('active');
    final expiredCount = _countByStatus('expired');
    final almostCount = _countByStatus('almost');

    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        right: -40,
                        top: -40,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: -30,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isEN
                                          ? 'Total Outstanding'
                                          : 'ยอดค้างชำระทั้งหมด',
                                      style: TextStyle(
                                        fontFamily: Font_.Fonts_T,
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        AutoSizeText(
                                          nFormat.format(total),
                                          minFontSize: 22,
                                          maxFontSize: 32,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontFamily: 'LINESeed2',
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            isEN ? 'BHT' : 'บาท',
                                            style: TextStyle(
                                              fontFamily: Font_.Fonts_T,
                                              fontSize: 14,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Stats grid
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _statColumn(
                                    isEN ? 'Contracts' : 'สัญญา',
                                    '${teNantModel?.length ?? 0}',
                                    Icons.description_outlined,
                                  ),
                                  _statColumn(
                                    isEN ? 'Active' : 'ปัจจุบัน',
                                    '$activeCount',
                                    Icons.check_circle_outline,
                                  ),
                                  _statColumn(
                                    isEN ? 'Expired' : 'หมดสัญญา',
                                    '$expiredCount',
                                    Icons.cancel_outlined,
                                  ),
                                  _statColumn(
                                    isEN ? 'Almost' : 'ใกล้หมด',
                                    '$almostCount',
                                    Icons.access_time,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Mini progress bars
                            _miniBar(
                              isEN ? 'Active' : 'สัญญาปัจจุบัน',
                              activeCount,
                              teNantModel?.length ?? 0,
                              const Color(0xFF34D399),
                            ),
                            const SizedBox(height: 8),
                            _miniBar(
                              isEN ? 'Expired' : 'หมดสัญญา',
                              expiredCount,
                              teNantModel?.length ?? 0,
                              const Color(0xFFF87171),
                            ),
                            const SizedBox(height: 8),
                            _miniBar(
                              isEN ? 'Almost expired' : 'ใกล้หมดสัญญา',
                              almostCount,
                              teNantModel?.length ?? 0,
                              const Color(0xFFFBBF24),
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

  Widget _statColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'LINESeed2',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: Font_.Fonts_T,
            fontSize: 11,
            color: Colors.white.withOpacity(0.75),
          ),
        ),
      ],
    );
  }

  Widget _miniBar(String label, int value, int total, Color color) {
    final ratio = total == 0 ? 0.0 : value / total;
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: Font_.Fonts_T,
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'LINESeed2',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
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

    final shdowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final shdowPaintCenter = Offset(size.width / 2, size.height / 2);
    final shdowPaintRadius =
        math.min(size.width / 2, size.height / 2) - (14 / 2);
    canvas.drawArc(
        Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.3);
    shdowPaint.strokeWidth = 16;
    canvas.drawArc(
        Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.2);
    shdowPaint.strokeWidth = 20;
    canvas.drawArc(
        Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.1);
    shdowPaint.strokeWidth = 22;
    canvas.drawArc(
        Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final gradient = SweepGradient(
      startAngle: degreeToRadians(268),
      endAngle: degreeToRadians(270.0 + 360),
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

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        paint);

    final gradient1 = SweepGradient(
      tileMode: TileMode.repeated,
      colors: [Colors.white, Colors.white],
    );

    var cPaint = Paint();
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
    canvas.drawCircle(const Offset(0, 0), 14 / 5, cPaint);

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
