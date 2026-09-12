import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chaoperty_user/color.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';

class PaymentSubV4BottomAction extends StatelessWidget {
  const PaymentSubV4BottomAction({
    Key? key,
    required this.summary,
    required this.operation,
    required this.onActionPressed,
    this.label = 'กดเพื่อ "เริ่มการชำระ"',
  }) : super(key: key);

  final PaymentSummary summary;
  final PaymentOperation operation;
  final VoidCallback onActionPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final nFormat = NumberFormat('#,##0.00', 'en_US');
    final isLoading = operation != PaymentOperation.none;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ยอดชำระสุทธิ:',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontFamily: Font_.Fonts_T,
                  ),
                ),
                Text(
                  '${nFormat.format(summary.grandTotal.toDouble())} บาท',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: Font_.Fonts_T,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : onActionPressed,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: Font_.Fonts_T,
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
