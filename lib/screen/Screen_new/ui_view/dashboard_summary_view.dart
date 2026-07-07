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
/// แสดง: ยอดค้างชำระทั้งหมด, สถานะสัญญา, ยอดวันนี้, จำนวนบิล, ปุ่มชำระ
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
    final today = totaltodays ?? 0.0;
    final invoiceCount = invoiceModels?.length ?? 0;
    final contractCount = teNantModel?.length ?? 0;
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
                            // Left: total outstanding
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Container(
                                        height: 18,
                                        width: 4,
                                        decoration: BoxDecoration(
                                          color: total > 0
                                              ? FitnessAppTheme.nearlyDarkRed
                                              : HexColor('#5271ff'),
                                          borderRadius:
                                              BorderRadius.circular(2.0),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isEN
                                            ? 'Total Outstanding'
                                            : 'ยอดค้างชำระทั้งหมด',
                                        style: TextStyle(
                                          fontFamily: Font_.Fonts_T,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: FitnessAppTheme.grey
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      AutoSizeText(
                                        nFormat.format(total),
                                        minFontSize: 20,
                                        maxFontSize: 30,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                          color: total > 0
                                              ? FitnessAppTheme.nearlyDarkRed
                                              : FitnessAppTheme.nearlyDarkBlue,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 6, bottom: 4),
                                        child: Text(
                                          isEN ? 'BHT' : 'บาท',
                                          style: TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: FitnessAppTheme.grey
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Right: contract count mini stat
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: FitnessAppTheme.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '$contractCount',
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: FitnessAppTheme.nearlyDarkBlue,
                                    ),
                                  ),
                                  Text(
                                    isEN ? 'Contracts' : 'สัญญา',
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                      fontSize: 11,
                                      color:
                                          FitnessAppTheme.grey.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── Status chips ──
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 16),
                        child: Row(
                          children: [
                            _statusChip(
                              isEN ? 'Active' : 'ปัจจุบัน',
                              '$activeCount',
                              HexColor('#5271ff'),
                            ),
                            const SizedBox(width: 8),
                            _statusChip(
                              isEN ? 'Expired' : 'หมดสัญญา',
                              '$expiredCount',
                              HexColor('#ff8385'),
                            ),
                            const SizedBox(width: 8),
                            _statusChip(
                              isEN ? 'Almost' : 'ใกล้หมด',
                              '$almostCount',
                              HexColor('#F1B440'),
                            ),
                          ],
                        ),
                      ),
                      // ── Divider ──
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: FitnessAppTheme.background,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                      // ── Bottom section: today + invoices + pay button ──
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 16, bottom: 16),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    isEN ? 'Today' : 'วันนี้',
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color:
                                          FitnessAppTheme.grey.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    nFormat.format(today),
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: FitnessAppTheme.nearlyDarkBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    isEN ? 'Invoices' : 'บิล',
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color:
                                          FitnessAppTheme.grey.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$invoiceCount',
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: FitnessAppTheme.darkText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _payButton(context, isEN),
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

  Widget _statusChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: Font_.Fonts_T,
                fontSize: 10,
                color: FitnessAppTheme.grey.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _payButton(BuildContext context, bool isEN) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FitnessAppTheme.nearlyDarkRed,
            HexColor('#FF6B6B'),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: FitnessAppTheme.nearlyDarkRed.withOpacity(0.25),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  isEN ? 'Pay' : 'ชำระ',
                  style: TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontSize: 13,
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
