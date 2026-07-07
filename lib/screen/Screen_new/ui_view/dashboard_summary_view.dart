import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Model/GetInvoice_Model.dart';
import '../../../Model/GetTeNant_Model.dart';
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
                      // ── Header with total outstanding ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: total > 0
                                ? [HexColor('#ff8385'), HexColor('#ff4f52')]
                                : [HexColor('#5271ff'), HexColor('#3a50b5')],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  isEN
                                      ? 'Total Outstanding'
                                      : 'ยอดค้างชำระทั้งหมด',
                                  style: const TextStyle(
                                    fontFamily: 'LINESeed2',
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    AutoSizeText(
                                      nFormat.format(total),
                                      minFontSize: 22,
                                      maxFontSize: 30,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontFamily: 'LINESeed2',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 6, bottom: 4),
                                      child: Text(
                                        isEN ? 'BHT' : 'บาท',
                                        style: const TextStyle(
                                          fontFamily: 'LINESeed2',
                                          fontSize: 14,
                                          color: Colors.white,
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
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                total > 0
                                    ? Icons.warning_amber_rounded
                                    : Icons.account_balance_wallet_outlined,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── Status chips ──
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 16, bottom: 12),
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
                      // ── Bottom section: today + invoices + contracts ──
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 12),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: _miniStat(
                                isEN ? 'Today' : 'วันนี้',
                                nFormat.format(today),
                                FitnessAppTheme.nearlyDarkBlue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _miniStat(
                                isEN ? 'Invoices' : 'บิล',
                                '$invoiceCount',
                                FitnessAppTheme.darkText,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _miniStat(
                                isEN ? 'Contracts' : 'สัญญา',
                                '$contractCount',
                                FitnessAppTheme.nearlyDarkBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── Pay button ──
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: _payButton(context, isEN),
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
                fontFamily: 'LINESeed2',
                fontSize: 10,
                color: FitnessAppTheme.grey.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: FitnessAppTheme.background,
        borderRadius: BorderRadius.circular(12),
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
              fontFamily: 'LINESeed2',
              fontSize: 10,
              color: FitnessAppTheme.grey.withOpacity(0.7),
            ),
          ),
        ],
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
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  isEN ? 'Pay Now' : 'ชำระค่าบริการ',
                  style: const TextStyle(
                    fontFamily: 'LINESeed2',
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
