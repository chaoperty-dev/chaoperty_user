import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:chaoperty_user/color.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';

class PaymentSubV4QrBox extends StatelessWidget {
  const PaymentSubV4QrBox({
    super.key,
    required this.qrState,
    required this.summary,
    this.onSaveQr,
    this.onRenewQr,
  });

  final PaymentQrState qrState;
  final PaymentSummary summary;
  final VoidCallback? onSaveQr;
  final VoidCallback? onRenewQr;

  @override
  Widget build(BuildContext context) {
    final nFormat = NumberFormat('#,##0.00', 'en_US');
    final payload = qrState.qrPayload ?? '';
    final isExpired = qrState.isSessionExpired;

    if (payload.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'สแกน QR Code เพื่อชำระเงิน',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: Font_.Fonts_T,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: PrettyQrView.data(
                    data: payload,
                    errorCorrectLevel: QrErrorCorrectLevel.M,
                  ),
                ),
              ),
              if (isExpired)
                Container(
                  width: 204,
                  height: 204,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_off, color: Colors.red, size: 36),
                      const SizedBox(height: 8),
                      const Text(
                        'QR Code หมดอายุแล้ว',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (onRenewQr != null)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: onRenewQr,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('ขอ QR ใหม่'),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'ยอดชำระ: ฿${nFormat.format(summary.grandTotal.toDouble())}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B00),
              fontFamily: Font_.Fonts_T,
            ),
          ),
          if (qrState.ref1 != null && qrState.ref1!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Ref 1: ${qrState.ref1}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontFamily: Font_.Fonts_T,
              ),
            ),
          ],
          if (qrState.ref2 != null && qrState.ref2!.isNotEmpty) ...[
            Text(
              'Ref 2: ${qrState.ref2}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontFamily: Font_.Fonts_T,
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (onSaveQr != null && !isExpired)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onSaveQr,
              icon: const Icon(Icons.download, size: 18),
              label: const Text(
                'บันทึกภาพ QR Code ลงเครื่อง',
                style: TextStyle(fontFamily: Font_.Fonts_T),
              ),
            ),
        ],
      ),
    );
  }
}
