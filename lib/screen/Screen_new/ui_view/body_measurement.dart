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

  /// รวมยอด "ยอดค้างชำระ" (totallist) — ปลอดภัยเมื่อ list เป็น null/ว่าง
  double _sumOutstanding() {
    final list = totallist;
    if (list == null || list.isEmpty) return 0.0;
    return list.fold<double>(0.0, (sum, s) => sum + (double.tryParse(s) ?? 0));
  }

  /// รวมยอด "รอยืนยัน/ตรวจสอบ" (totallistPaid) — ปลอดภัยเมื่อ list เป็น null/ว่าง
  double _sumPaid() {
    final list = totallistPaid;
    if (list == null || list.isEmpty) return 0.0;
    return list.fold<double>(0.0, (sum, s) => sum + (double.tryParse(s) ?? 0));
  }

  /// รวมยอดบิลทั้งหมด (amtall + vatall) — ปลอดภัยเมื่อ list เป็น null/ว่าง/รายการผิดพลาด
  double _sumInvoices() {
    final list = invoiceModels;
    if (list == null || list.isEmpty) return 0.0;
    double total = 0.0;
    for (final e in list) {
      final amt = double.tryParse(e.amtall ?? '') ?? 0.0;
      final vat = double.tryParse(e.vatall ?? '') ?? 0.0;
      total += (amt + vat);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    // คำนวณค่าทั้งหมดครั้งเดียวก่อนส่งเข้า _BodyContent
    final body = _BodyContent(
      cuslangs: cuslangs,
      sumInvoices: _sumInvoices(),
      sumOutstanding: _sumOutstanding(),
      sumPaid: _sumPaid(),
      invoiceCount: invoiceModels?.length ?? 0,
    );

    // ถ้าไม่มี animation ให้แสดงเลย ไม่ subscribe controller (ป้องกัน loop)
    if (animationController == null || animation == null) {
      return body;
    }
    return AnimatedBuilder(
      animation: animationController!,
      builder: (context, _) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: body,
          ),
        );
      },
    );
  }
}

/// เนื้อหาจริงของ BodyMeasurementView — ไม่ subscribe animation ใดๆ
/// ป้องกัน window.dart:99 infinite rebuild loop ที่เกิดจาก
/// AnimatedBuilder ภายในที่ rebuild ตัวเองตลอดเวลา
class _BodyContent extends StatelessWidget {
  final String? cuslangs;
  final double sumInvoices;
  final double sumOutstanding;
  final double sumPaid;
  final int invoiceCount;

  const _BodyContent({
    Key? key,
    this.cuslangs,
    required this.sumInvoices,
    required this.sumOutstanding,
    required this.sumPaid,
    required this.invoiceCount,
  }) : super(key: key);

  static final _nFormat = NumberFormat("#,##0.00", "en_US");
  static const _month = [
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
    "ธันวาคม",
  ];
  static final _now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isPaidPositive = sumPaid > 0.00;
    final isInvoiceZero = sumInvoices == 0.0;

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 18),
      child: Container(
        decoration: BoxDecoration(
          color: FitnessAppTheme.white,
          borderRadius: BorderRadius.circular(18.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: FitnessAppTheme.grey.withOpacity(0.12),
              offset: const Offset(0, 5),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: FitnessAppTheme.grey.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Column(
          children: <Widget>[
            // ─── Top: label + total + date ───
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
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
                        color: FitnessAppTheme.darkText,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // ─── Left: amount(s) ───
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, bottom: 3),
                                child: Text(
                                  _nFormat.format(sumInvoices),
                                  textAlign: isPaidPositive
                                      ? TextAlign.start
                                      : TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isPaidPositive ? 14 : 25,
                                    color: isPaidPositive
                                        ? Colors.grey
                                        : isInvoiceZero
                                            ? FitnessAppTheme.nearlyDarkBlue
                                            : FitnessAppTheme.nearlyDarkRed,
                                    decoration: isPaidPositive
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationColor: Colors.grey,
                                    decorationThickness: 2,
                                  ),
                                ),
                              ),
                              if (!isPaidPositive) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, bottom: 8),
                                  child: Text(
                                    cuslangs == 'EN' ? 'BHT' : 'บาท',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                      letterSpacing: -0.2,
                                      color: isInvoiceZero
                                          ? FitnessAppTheme.nearlyDarkBlue
                                          : FitnessAppTheme.nearlyDarkRed,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (isPaidPositive) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, bottom: 3),
                                  child: Text(
                                    _nFormat.format(sumOutstanding),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: isInvoiceZero
                                          ? FitnessAppTheme.nearlyDarkBlue
                                          : FitnessAppTheme.nearlyDarkRed,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, bottom: 3),
                                  child: Text(
                                    cuslangs == 'EN' ? 'BHT' : 'บาท',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                      letterSpacing: -0.2,
                                      color: isInvoiceZero
                                          ? FitnessAppTheme.nearlyDarkBlue
                                          : FitnessAppTheme.nearlyDarkRed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      // ─── Right: Today + date ───
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.access_time,
                                color: FitnessAppTheme.grey.withOpacity(0.5),
                                size: 16,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  cuslangs == 'EN'
                                      ? 'Today ${DateFormat('HH:mm').format(_now)}'
                                      : 'วันนี้ ${DateFormat('HH:mm').format(_now)}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    letterSpacing: 0.0,
                                    color:
                                        FitnessAppTheme.grey.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 14),
                            child: Text(
                              cuslangs == 'EN'
                                  ? '${DateFormat.yMMMMd().format(_now)}'
                                  : '${DateFormat('dd').format(_now)} ${_month[int.parse(DateFormat('MM').format(_now))]} ${int.parse(DateFormat('yyyy').format(_now)) + 543}',
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ─── Divider ───
            Padding(
              padding:
                  const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: FitnessAppTheme.background,
                  borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                ),
              ),
            ),
            // ─── Bottom: 3 columns (Pending / Invoice / Pay) ───
            Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 8, bottom: 16),
              child: Row(
                children: <Widget>[
                  // ─ Pending/Verification ─
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
                              color: FitnessAppTheme.grey.withOpacity(0.5),
                            ),
                          ),
                        ),
                        Text(
                          _nFormat.format(sumPaid),
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
                            cuslangs == 'EN' ? 'THB' : 'บาท',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: FitnessAppTheme.grey.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ─ Invoice count ─
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            cuslangs == 'EN' ? 'Invoice' : 'ทั้งหมด',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: FitnessAppTheme.grey.withOpacity(0.5),
                            ),
                          ),
                        ),
                        Text(
                          '$invoiceCount',
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
                            cuslangs == 'EN' ? 'Billing slip' : 'บิล',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: FitnessAppTheme.grey.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ─ Pay now ─
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          onPressed: () async {
                            final preferences =
                                await SharedPreferences.getInstance();
                            preferences.setString('payby', 'PAY');
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FitnessAppHomeScreen(
                                  pageroot: 'PAY',
                                ),
                              ),
                              (route) => false,
                            );
                          },
                          icon: Icon(
                            Icons.play_arrow,
                            color: FitnessAppTheme.nearlyDarkRed,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            cuslangs == 'EN' ? 'Pay now' : 'ชำระค่าบริการ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
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
            ),
          ],
        ),
      ),
    );
  }
}
