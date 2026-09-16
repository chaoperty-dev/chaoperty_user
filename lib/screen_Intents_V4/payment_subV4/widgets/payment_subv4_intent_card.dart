import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/color.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';

/// การ์ด intent สำหรับแท็บ 2/3
///
/// โครงเดียวกับ `_IntentBox` ของต้นฉบับ (`payment_subV4_InvAll.dart`):
/// - status pill ตามสถานะ (เขียว = รอตรวจ, ส้ม = รอสลิป, ฟ้า = อื่น ๆ)
/// - intent no, ยอดเงิน, แถวหมดอายุ + จำนวนบิล
/// - ปุ่ม action ตามกฎ [PaymentSubV4State.intentCardAction]
/// - กางออกแล้วเห็นบิล (ติ๊กถูก + วันที่ + ค่าปรับ) และ "แนบหลักฐานแล้ว" บนแท็บ 3
class PaymentSubV4IntentCard extends StatelessWidget {
  const PaymentSubV4IntentCard({
    super.key,
    required this.intent,
    required this.isVerifyTab,
    required this.isEn,
    this.onOpenSlip,
  });

  final PaymentIntent intent;
  final bool isVerifyTab;
  final bool isEn;

  /// เรียกเมื่อผู้ใช้กดปุ่ม action
  /// แท็บ 2 = เปิด flow แนบหลักฐาน, แท็บ 3 = เปิดดูหลักฐาน
  final VoidCallback? onOpenSlip;

  @override
  Widget build(BuildContext context) {
    final statusText = (intent.status ?? '').trim();
    final intentNo = (intent.paymentIntentNo ?? '').trim();
    final systemStatus = (intent.systemStatus ?? '').trim();
    final amount = Money.fromDouble(intent.amount ?? intent.requestedAmount);
    final billCount = intent.invoices.length;
    final action = PaymentSubV4State.intentCardAction(intent);

    // สี pill ตรงกับสีแท็บของต้นฉบับ
    final Color pillBg;
    final Color pillFg;
    if (PaymentSubV4State.legacyIsAwaitingVerifyStatus(intent.status)) {
      pillBg = Colors.green.shade100;
      pillFg = Colors.green.shade700;
    } else if (PaymentSubV4State.legacyIsAwaitingSlipStatus(intent.status)) {
      pillBg = Colors.orange.shade100;
      pillFg = Colors.orange.shade700;
    } else {
      pillBg = Colors.cyan.shade100;
      pillFg = Colors.cyan.shade700;
    }

    // ต้นฉบับแสดง systemStatus เมื่อเป็นภาษาอังกฤษ
    final pillText = (isEn ? systemStatus : statusText).isEmpty
        ? '-'
        : (isEn ? systemStatus : statusText);

    return Card(
      elevation: 0.4,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          dense: true,
          visualDensity: const VisualDensity(vertical: -4),
          initiallyExpanded: false,
          tilePadding:
              const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 0),
          childrenPadding:
              const EdgeInsets.only(left: 12, right: 12, bottom: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          trailing: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey,
            size: 20,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: pillFg,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          pillText,
                          style: TextStyle(
                            color: pillFg,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '#${intentNo.isEmpty ? '-' : intentNo}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11.5,
                        fontFamily: Font_.Fonts_T,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '฿${_money(amount)}',
                style: const TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      flex: 3,
                      child: Text(
                        isEn
                            ? 'Expire ${_fmtExpireLocal(intent.softExpireAt)}'
                            : 'หมดอายุ ${_fmtExpireLocal(intent.softExpireAt)}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 11.5,
                          fontFamily: Font_.Fonts_T,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.receipt_long,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      flex: 1,
                      child: Text(
                        isEn ? '$billCount Bill' : '$billCount บิล',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 11.5,
                          fontFamily: Font_.Fonts_T,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_actionButton(action)],
            ),
          ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 8),
            for (final invoice in intent.invoices)
              _invoiceItem(
                docNo: (invoice.billReference ?? '').trim(),
                amount: Money.fromDouble(invoice.total ?? invoice.amount),
                date: invoice.metadata.isNotEmpty
                    ? (invoice.metadata.first.date ?? '')
                    : '',
                lateFee: Money.fromDouble(invoice.lateFee),
                showSlipAttachedText: isVerifyTab,
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isEn
                        ? 'Note: The amount shown does not include any penalties/overdue payments that may occur.'
                        : 'หมายเหตุ:ยอดที่แสดงยังไม่รวมค่าปรับ/ชำระเกินกำหนดที่อาจเกิดขึ้น',
                    style: const TextStyle(
                      color: Colors.red,
                      fontFamily: Font_.Fonts_T,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ปุ่ม action ตามกฎเดียวกับต้นฉบับ
  ///
  /// - `none` → ไม่แสดงปุ่ม (แนบสลิปแล้วและอยู่ระหว่างตรวจ)
  /// - `paymentProof` → "หลักฐานการชำระ" (indigo)
  /// - `attachProof` → "กดเพื่อแนบหลักฐาน" (ส้ม)
  /// - `viewProof` → "กดเพื่อดูหลักฐาน" (เขียว)
  /// - `pressToPay` → "กดเพื่อยืนยัน" (indigo)
  Widget _actionButton(IntentCardAction action) {
    if (action == IntentCardAction.none) return const SizedBox.shrink();

    final IconData icon;
    final Color bg;
    final Color fg;
    final String label;

    switch (action) {
      case IntentCardAction.paymentProof:
        icon = Icons.description_outlined;
        bg = Colors.indigo.shade50;
        fg = Colors.indigo.shade800;
        label = isEn ? 'Payment proof' : 'หลักฐานการชำระ';
      case IntentCardAction.attachProof:
        icon = Icons.attach_file_rounded;
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade800;
        label = isEn ? 'Attach proof' : 'กดเพื่อแนบหลักฐาน';
      case IntentCardAction.viewProof:
        icon = Icons.verified_outlined;
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        label = isEn ? 'View proof' : 'กดเพื่อดูหลักฐาน';
      case IntentCardAction.pressToPay:
        icon = Icons.credit_card;
        bg = Colors.indigo.shade50;
        fg = Colors.indigo.shade800;
        label = isEn ? 'Press to pay' : 'กดเพื่อยืนยัน';
      case IntentCardAction.none:
        return const SizedBox.shrink();
    }

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onOpenSlip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontFamily: Font_.Fonts_T,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (action == IntentCardAction.paymentProof) ...[
              Icon(Icons.chevron_right, color: fg, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  /// บิลย่อยในการ์ด — ติ๊กถูกเสมอ (บิลในแท็บ 2/3 = กำลังดำเนินการอยู่)
  Widget _invoiceItem({
    required String docNo,
    required Money amount,
    required String date,
    required Money lateFee,
    required bool showSlipAttachedText,
  }) {
    final dateText = date.isEmpty
        ? ''
        : DateFormat('dd-MM-yyyy').format(DateTime.tryParse(date) ?? DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12, width: .4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 18,
                  ),
                ),
                Expanded(
                  child: Text(
                    docNo.isEmpty ? '-' : docNo,
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  _money(amount),
                  style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            if (dateText.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  if (lateFee.isPositive) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Text(
                        '${isEn ? 'Fine' : 'ค่าปรับ'}: ${_money(lateFee)}',
                        style: TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (showSlipAttachedText)
              Padding(
                padding: const EdgeInsets.only(left: 2, top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isEn ? 'Slip attached' : 'แนบหลักฐานแล้ว',
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade700,
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

  static String _money(Money value) =>
      NumberFormat('#,##0.00', 'en_US').format(value.toDouble());

  /// ต้นฉบับใช้ `DateFormat('d-MM-yyyy HH:mm')` กับเวลา local
  static String _fmtExpireLocal(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('d-MM-yyyy HH:mm').format(dt.toLocal());
  }
}
