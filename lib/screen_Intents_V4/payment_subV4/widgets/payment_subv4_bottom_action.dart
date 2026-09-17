import 'package:flutter/material.dart';

import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_theme.dart';

class PaymentSubV4BottomAction extends StatelessWidget {
  const PaymentSubV4BottomAction({
    super.key,
    required this.summary,
    required this.operation,
    required this.onActionPressed,
    required this.isEn,
    required this.label,
    this.statusText,
    this.enabled = true,
    this.amountOverride,
  });

  final PaymentSummary summary;
  final PaymentOperation operation;
  final VoidCallback onActionPressed;
  final bool isEn;
  final String label;
  final String? statusText;
  final bool enabled;

  /// ยอดที่ต้องแสดง/ใช้ตัดสินการกดปุ่ม
  ///
  /// หลังสร้าง intent แล้ว ต้องเป็นยอดที่ server ถือ (`qrState.amount`)
  /// ไม่ใช่ `summary.grandTotal` ที่ฝั่งแอปรวมเอง — สองค่าไม่เท่ากันเมื่อมีส่วนลด
  /// ปล่อย null = ยังไม่มี intent ใช้ยอดจาก summary
  final Money? amountOverride;

  @override
  Widget build(BuildContext context) {
    final loading = operation != PaymentOperation.none;
    final amount = amountOverride ?? summary.grandTotal;
    final canPress = enabled && !loading && amount.isPositive;

    return Container(
      // Bottom action must reach screen edges; only inner content has spacing.
      padding: EdgeInsets.zero,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: PaymentSubV4Theme.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        // CTA ต้องเต็มความกว้าง — ห้าม SafeArea ใส่ inset ซ้าย/ขวาเพิ่ม
        left: false,
        right: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'Total to transfer' : 'ยอดรวมที่ต้องโอน',
                        style: PaymentSubV4Theme.text(
                          size: 11,
                          color: PaymentSubV4Theme.textSecondary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '฿${PaymentSubV4Theme.money(amount)}',
                        style: PaymentSubV4Theme.text(
                          size: 20,
                          weight: FontWeight.w700,
                          tabular: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: PaymentSubV4Theme.amberBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: PaymentSubV4Theme.amberForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText ?? (isEn ? 'Awaiting slip' : 'รอสลิปยืนยัน'),
                        style: PaymentSubV4Theme.text(
                          size: 11,
                          weight: FontWeight.w600,
                          color: PaymentSubV4Theme.amberForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: canPress
                      ? const LinearGradient(
                          colors: [
                            PaymentSubV4Theme.primaryOrange,
                            PaymentSubV4Theme.primaryOrangeDark,
                          ],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
                        ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: canPress
                      ? const [
                          BoxShadow(
                            color: Color(0x3DF97316),
                            blurRadius: 12,
                            offset: Offset(0, 5),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: canPress ? onActionPressed : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (loading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.3,
                                color: Colors.white,
                              ),
                            )
                          else ...[
                            const Icon(
                              Icons.attach_file_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: PaymentSubV4Theme.text(
                                  size: 15,
                                  weight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 21,
                              color: Colors.white,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
