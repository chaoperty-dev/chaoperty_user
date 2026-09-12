import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chaoperty_user/Model/GetPayMent_Model.dart';
import 'package:chaoperty_user/color.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';

class PaymentSubV4PaymentCard extends StatelessWidget {
  const PaymentSubV4PaymentCard({
    Key? key,
    required this.paymentModel,
    required this.summary,
    required this.qrState,
    this.onSaveQr,
  }) : super(key: key);

  final PayMentModel? paymentModel;
  final PaymentSummary summary;
  final PaymentQrState qrState;
  final VoidCallback? onSaveQr;

  @override
  Widget build(BuildContext context) {
    final nFormat = NumberFormat('#,##0.00', 'en_US');
    final bname = paymentModel?.bname ?? '-';
    final bno = paymentModel?.bno ?? '-';

    return Card(
      color: Colors.white,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    'images/Icon-chao.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bname,
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'เลขที่บัญชี / Ref:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontFamily: Font_.Fonts_T,
                  ),
                ),
                Text(
                  bno,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: Font_.Fonts_T,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ยอดเงินที่ต้องชำระ:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontFamily: Font_.Fonts_T,
                  ),
                ),
                Text(
                  '฿${nFormat.format(summary.grandTotal.toDouble())}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFFFF6B00),
                    fontFamily: Font_.Fonts_T,
                  ),
                ),
              ],
            ),
            if (qrState.secondsRemaining > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, size: 14, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(
                      'QR หมดอายุใน ${qrState.secondsRemaining} วินาที',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
