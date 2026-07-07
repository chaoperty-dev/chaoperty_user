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
/// สไตล์ใหม่: เรียบ สะอาด เน้นขาว มีจุดเด่นที่ยอดค้างชำระและปุ่มชำระ
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
                      // ── Header: total outstanding ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        color: FitnessAppTheme.white,
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
                                  style: TextStyle(
                                    fontFamily: 'LINESeed2',
                                    fontSize: 13,
                                    color: FitnessAppTheme.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    AutoSizeText(
                                      nFormat.format(total),
                                      minFontSize: 22,
                                      maxFontSize: 30,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontFamily: 'LINESeed2',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color: isDue
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
                                          fontFamily: 'LINESeed2',
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
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: isDue
                                    ? HexColor('#ff8385').withOpacity(0.08)
                                    : HexColor('#5271ff').withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isDue
                                    ? Icons.warning_amber_rounded
                                    : Icons.account_balance_wallet_outlined,
                                color: isDue
                                    ? HexColor('#ff8385')
                                    : HexColor('#5271ff'),
                                size: 22,
                              ),
                            ),
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
                      // ── Bottom section: today + invoices + contracts + pay ──
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
              fontFamily: 'LINESeed2',
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
