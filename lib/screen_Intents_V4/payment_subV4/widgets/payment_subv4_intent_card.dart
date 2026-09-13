import 'package:flutter/material.dart';

import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_theme.dart';

/// การ์ด intent สำหรับแท็บ 2/3
///
/// โครงเดียวกับ `_IntentBox` ของต้นฉบับ:
/// - status pill ตามสถานะ (เขียว = รอตรวจ, ส้ม = รอสลิป, ฟ้า = อื่น ๆ)
/// - ปุ่ม action ตามกฎ showSlipAction
/// - กางออกแล้วเห็นบิล + "แนบหลักฐานแล้ว" (แท็บ 3) + หมายเหตุสีแดง
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

  /// เรียกเมื่อผู้ใช้กดปุ่ม action — ต้นฉบับเรียก QrGenRef แล้วเปิด sheet ยืนยัน
  final VoidCallback? onOpenSlip;

  @override
  Widget build(BuildContext context) {
    final status = PaymentSubV4State.classifyIntentStatus(intent);
    final statusText = (intent.status ?? '').trim();
    final intentNo = (intent.paymentIntentNo ?? '').trim();
    final amount = Money.fromDouble(intent.amount ?? intent.requestedAmount);

    final (pillBg, pillFg) = switch (status) {
      NormalizedIntentStatus.awaitingVerification => (
          Colors.green.shade100,
          Colors.green.shade800,
        ),
      NormalizedIntentStatus.awaitingSlip => (
          Colors.orange.shade100,
          Colors.orange.shade800,
        ),
      _ => (Colors.cyan.shade100, Colors.cyan.shade800),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: PaymentSubV4Theme.cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(13, 6, 13, 2),
          childrenPadding: const EdgeInsets.fromLTRB(13, 0, 13, 10),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
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
                          statusText.isEmpty ? '-' : statusText,
                          style: PaymentSubV4Theme.text(
                            size: 11,
                            weight: FontWeight.w700,
                            color: pillFg,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '#${intentNo.isEmpty ? '-' : intentNo}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PaymentSubV4Theme.text(
                        size: 12,
                        color: PaymentSubV4Theme.textSecondary,
                        tabular: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '฿${PaymentSubV4Theme.money(amount)}',
                style: PaymentSubV4Theme.text(
                  size: 19,
                  weight: FontWeight.w700,
                  tabular: true,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: PaymentSubV4Theme.slateSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 13,
                      color: PaymentSubV4Theme.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isEn
                          ? '${intent.invoices.length} bill(s)'
                          : '${intent.invoices.length} บิล',
                      style: PaymentSubV4Theme.text(
                        size: 11.5,
                        color: PaymentSubV4Theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Align(
              alignment: Alignment.centerRight,
              child: _actionButton(status),
            ),
          ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 8),
            for (final invoice in intent.invoices)
              _invoiceRow(
                docNo: (invoice.billReference ?? '').trim(),
                amount: Money.fromDouble(invoice.total ?? invoice.amount),
                lateFee: Money.fromDouble(invoice.lateFee),
                date: invoice.metadata.isNotEmpty
                    ? (invoice.metadata.first.date ?? '')
                    : '',
                showSlipAttachedText: isVerifyTab,
              ),
            const SizedBox(height: 6),
            Text(
              isEn
                  ? 'Note: the amount shown does not include any penalties or overdue charges that may occur.'
                  : 'หมายเหตุ: ยอดที่แสดงยังไม่รวมค่าปรับ/ชำระเกินกำหนดที่อาจเกิดขึ้น',
              style: PaymentSubV4Theme.text(
                size: 10,
                color: Colors.red.shade600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// กฎปุ่มตามต้นฉบับ: showSlipAction = มีสลิปแล้ว หรือ status เป็นรอตรวจสอบ
  Widget _actionButton(NormalizedIntentStatus status) {
    final hasSlip = intent.latestSlip != null ||
        (intent.systemStatus ?? '').toLowerCase() == 'slip_uploaded' ||
        (intent.status ?? '') == 'รอตรวจสอบ' ||
        (intent.status ?? '') == 'รอการตรวจสอบ';

    // แนบสลิปแล้วและอยู่ระหว่างตรวจ → ต้นฉบับไม่แสดงปุ่มเลย
    if (hasSlip && status == NormalizedIntentStatus.awaitingVerification) {
      return const SizedBox.shrink();
    }

    final (icon, bg, fg, label) = switch (status) {
      NormalizedIntentStatus.awaitingVerification => (
          Icons.verified_outlined,
          Colors.green.shade50,
          Colors.green.shade800,
          isEn ? 'View proof' : 'กดเพื่อดูหลักฐาน',
        ),
      NormalizedIntentStatus.awaitingSlip => (
          Icons.attach_file_rounded,
          Colors.orange.shade50,
          Colors.orange.shade800,
          isEn ? 'Attach proof' : 'กดเพื่อแนบหลักฐาน',
        ),
      _ => (
          Icons.credit_card,
          Colors.indigo.shade50,
          Colors.indigo.shade800,
          isEn ? 'Press to pay' : 'กดเพื่อยืนยัน',
        ),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onOpenSlip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg, size: 17),
            const SizedBox(width: 6),
            Text(
              label,
              style: PaymentSubV4Theme.text(
                size: 12.5,
                weight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoiceRow({
    required String docNo,
    required Money amount,
    required Money lateFee,
    required String date,
    required bool showSlipAttachedText,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: PaymentSubV4Theme.slateSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PaymentSubV4Theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 17,
                color: Colors.green,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  docNo.isEmpty ? '-' : docNo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PaymentSubV4Theme.text(
                    size: 14,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                PaymentSubV4Theme.money(amount),
                style: PaymentSubV4Theme.text(
                  size: 14,
                  weight: FontWeight.w700,
                  tabular: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              if (date.isNotEmpty) ...[
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 11,
                  color: PaymentSubV4Theme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: PaymentSubV4Theme.text(
                    size: 11.5,
                    color: PaymentSubV4Theme.textSecondary,
                  ),
                ),
              ],
              const Spacer(),
              if (lateFee.isPositive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Text(
                    '${isEn ? 'Fine' : 'ค่าปรับ'}: ${PaymentSubV4Theme.money(lateFee)}',
                    style: PaymentSubV4Theme.text(
                      size: 11,
                      weight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
            ],
          ),
          if (showSlipAttachedText) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 13,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  isEn ? 'Slip attached' : 'แนบหลักฐานแล้ว',
                  style: PaymentSubV4Theme.text(
                    size: 12,
                    weight: FontWeight.w700,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
