import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Model/GetInvoice_Model.dart';
import '../../../Model/GetTeNant_Model.dart';
import '../../../main.dart';
import '../fitness_app_home_screen.dart';
import '../fitness_app_theme.dart';

/// การ์ดสรุป Dashboard รวม (สไตล์ screenshot ล่าสุด)
/// - badge เกินกำหนดชำระ + ไอคอนเงินบาท
/// - ยอดค้างชำระรวม
/// - ปุ่มชำระค่าบริการเต็มความกว้าง
/// - 2 การ์ดย่อย: วันนี้ + บิล
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
                  left: 24, right: 24, top: 16, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: FitnessAppTheme.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: FitnessAppTheme.grey.withOpacity(0.10),
                        offset: const Offset(0, 6),
                        blurRadius: 16,
                        spreadRadius: 0),
                  ],
                  border: Border.all(
                    color: FitnessAppTheme.grey.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // ── Header row: badge + baht icon ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDue
                                  ? FitnessAppTheme.nearlyDarkRed
                                      .withOpacity(0.08)
                                  : FitnessAppTheme.nearlyDarkBlue
                                      .withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isDue
                                        ? FitnessAppTheme.nearlyDarkRed
                                        : FitnessAppTheme.nearlyDarkBlue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isEN ? 'Payment due' : 'เกินกำหนดชำระ',
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: isDue
                                        ? FitnessAppTheme.nearlyDarkRed
                                        : FitnessAppTheme.nearlyDarkBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: FitnessAppTheme.nearlyDarkBlue
                                  .withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.payments_outlined,
                              size: 18,
                              color: FitnessAppTheme.nearlyDarkBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // ── Total amount ──
                      Text(
                        isEN ? 'Total outstanding' : 'ยอดค้างชำระรวม',
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: FitnessAppTheme.grey.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            nFormat.format(total),
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w800,
                              fontSize: 36,
                              color: isDue
                                  ? FitnessAppTheme.nearlyDarkRed
                                  : FitnessAppTheme.nearlyDarkBlue,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 6),
                            child: Text(
                              isEN ? 'BHT' : 'บาท',
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: isDue
                                    ? FitnessAppTheme.nearlyDarkRed
                                        .withOpacity(0.7)
                                    : FitnessAppTheme.nearlyDarkBlue
                                        .withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // ── Pay button ──
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                FitnessAppTheme.nearlyDarkBlue,
                                HexColor('#5271ff'),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: FitnessAppTheme.nearlyDarkBlue
                                    .withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () async {
                                final preferences =
                                    await SharedPreferences.getInstance();
                                await preferences.setString('payby', 'PAY');
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FitnessAppHomeScreen(
                                      pageroot: 'PAY',
                                    ),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isEN ? 'Pay service' : 'ชำระค่าบริการ',
                                      style: const TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ── Divider ──
                      Container(
                        height: 1,
                        color: FitnessAppTheme.background,
                      ),
                      const SizedBox(height: 16),
                      // ── 2 sub-cards: Today + Bills ──
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _subCard(
                              icon: Icons.calendar_today_outlined,
                              iconBgColor: FitnessAppTheme.nearlyDarkBlue
                                  .withOpacity(0.08),
                              iconColor: FitnessAppTheme.nearlyDarkBlue,
                              label: isEN ? 'Today' : 'วันนี้',
                              value: nFormat.format(today),
                              subValue: isEN
                                  ? '${nFormat.format(total)} BHT'
                                  : '${nFormat.format(total)} บาท',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _subCard(
                              icon: Icons.receipt_outlined,
                              iconBgColor:
                                  FitnessAppTheme.orange.withOpacity(0.12),
                              iconColor: FitnessAppTheme.orange,
                              label: isEN ? 'Bill' : 'บิล',
                              value: '$invoiceCount',
                              subValue:
                                  isEN ? 'Billing slip' : 'รายการค้างชำระ',
                            ),
                          ),
                        ],
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

  Widget _subCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
    required String subValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FitnessAppTheme.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: FitnessAppTheme.grey.withOpacity(0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: FitnessAppTheme.darkerText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subValue,
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: FitnessAppTheme.grey.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
