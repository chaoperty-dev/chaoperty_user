import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Model/GetInvoice_Model.dart';
import '../fitness_app_home_screen.dart';

class BodyMeasurementView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final List<InvoiceModel>? invoiceModels;
  final double? totaltodays;
  final String? cuslangs;

  BodyMeasurementView({
    Key? key,
    this.animationController,
    this.animation,
    this.totaltodays,
    this.invoiceModels,
    this.cuslangs,
  }) : super(key: key);

  final List<String> _months = [
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
  final DateTime _dateTimeNew = DateTime.now();

  double get _totalAmount {
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
    final total = _totalAmount;
    final today = totaltodays ?? 0.0;
    final count = invoiceModels?.length ?? 0;
    final hasDue = total > 0;

    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF384250).withOpacity(0.06),
                      offset: const Offset(0, 8),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      // Header with accent
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: hasDue
                                ? [
                                    const Color(0xFFDC2626),
                                    const Color(0xFFEF4444)
                                  ]
                                : [
                                    const Color(0xFF10B981),
                                    const Color(0xFF34D399)
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEN ? 'Payment Due' : 'เกินกำหนดชำระ',
                                  style: const TextStyle(
                                    fontFamily: 'LINESeed2',
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      nFormat.format(total),
                                      style: const TextStyle(
                                        fontFamily: 'LINESeed2',
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
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
                                hasDue
                                    ? Icons.warning_amber_rounded
                                    : Icons.check_circle_outline,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Date/time row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isEN
                                      ? 'Today ${DateFormat('HH:mm').format(_dateTimeNew)}'
                                      : 'วันนี้ ${DateFormat('HH:mm').format(_dateTimeNew)}',
                                  style: const TextStyle(
                                    fontFamily: 'LINESeed2',
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              isEN
                                  ? DateFormat.yMMMMd().format(_dateTimeNew)
                                  : '${DateFormat('dd').format(_dateTimeNew)} ${_months[int.parse(DateFormat('MM').format(_dateTimeNew))]} ${int.parse(DateFormat('yyyy').format(_dateTimeNew)) + 543}',
                              style: const TextStyle(
                                fontFamily: 'LINESeed2',
                                fontSize: 12,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Stats grid
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                isEN ? 'Today' : 'วันนี้',
                                nFormat.format(today),
                                const Color(0xFFDBEAFE),
                                const Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _statCard(
                                isEN ? 'Invoices' : 'บิลทั้งหมด',
                                '$count',
                                const Color(0xFFF3E8FF),
                                const Color(0xFF7C3AED),
                              ),
                            ),
                            const SizedBox(width: 10),
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

  Widget _statCard(String label, String value, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'LINESeed2',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'LINESeed2',
              fontSize: 10,
              color: fg.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _payButton(BuildContext context, bool isEN) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.25),
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
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(height: 2),
                Text(
                  'Pay',
                  style: TextStyle(
                    fontFamily: 'LINESeed2',
                    fontSize: 11,
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
