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
/// สไตล์ Enterprise Dashboard: ขาวเรียบ ตัวเลขชัด แยกส่วนชัดเจน
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
                      // ── Header: total outstanding + datetime ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                        color: FitnessAppTheme.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  isEN ? 'Total Outstanding' : 'เกินกำหนดชำระ',
                                  style: TextStyle(
                                    fontFamily: 'LINESeed2',
                                    fontSize: 14,
                                    color:
                                        FitnessAppTheme.grey.withOpacity(0.7),
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.access_time,
                                      size: 13,
                                      color:
                                          FitnessAppTheme.grey.withOpacity(0.5),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isEN
                                          ? 'Today ${DateFormat('HH:mm').format(datex)}'
                                          : 'วันนี้ ${DateFormat('HH:mm').format(datex)}',
                                      style: TextStyle(
                                        fontFamily: 'LINESeed2',
                                        fontSize: 12,
                                        color: FitnessAppTheme.grey
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                AutoSizeText(
                                  nFormat.format(total),
                                  minFontSize: 24,
                                  maxFontSize: 32,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: 'LINESeed2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                    color: isDue
                                        ? FitnessAppTheme.nearlyDarkRed
                                        : FitnessAppTheme.nearlyDarkBlue,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, bottom: 6),
                                  child: Text(
                                    isEN ? 'BHT' : 'บาท',
                                    style: TextStyle(
                                      fontFamily: 'LINESeed2',
                                      fontSize: 14,
                                      color:
                                          FitnessAppTheme.grey.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEN
                                  ? '${DateFormat.yMMMMd().format(datex)}'
                                  : '${DateFormat('dd').format(datex)} ${month[int.parse(DateFormat('MM').format(datex))]} ${int.parse(DateFormat('yyyy').format(datex)) + 543}',
                              style: TextStyle(
                                fontFamily: 'LINESeed2',
                                fontSize: 12,
                                color: FitnessAppTheme.nearlyDarkBlue,
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
                                isEN ? 'BHT' : 'บาท',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _miniStat(
                                isEN ? 'Invoices' : 'บิล',
                                '$invoiceCount',
                                FitnessAppTheme.darkText,
                                isEN ? 'items' : 'รายการ',
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

  Widget _miniStat(String label, String value, Color valueColor, String unit) {
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
            unit,
            style: TextStyle(
              fontFamily: 'LINESeed2',
              fontSize: 10,
              color: FitnessAppTheme.grey.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
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
      height: 68,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [HexColor('#ff8385'), HexColor('#ff4f52')],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                isEN ? 'Pay Now' : 'ชำระค่าบริการ',
                style: const TextStyle(
                  fontFamily: 'LINESeed2',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
