import 'package:flutter/material.dart';

import 'package:chaoperty_user/color.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_theme.dart';

class PaymentSubV4CountdownBar extends StatelessWidget {
  const PaymentSubV4CountdownBar({
    super.key,
    required this.qrState,
    required this.totalSeconds,
    required this.isEn,
  });

  final PaymentQrState qrState;
  final int totalSeconds;
  final bool isEn;

  static String hhmmss(int secs) {
    final safe = secs < 0 ? 0 : secs;
    final h = (safe ~/ 3600).toString().padLeft(2, '0');
    final m = ((safe % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (safe % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final secs = qrState.secondsRemaining;
    final expired = qrState.isSessionExpired || secs <= 0;
    final foreground =
        expired ? Colors.red.shade700 : PaymentSubV4Theme.amberForeground;
    final background =
        expired ? Colors.red.shade50 : const Color(0xFFFFFBEB);
    final border = expired ? Colors.red.shade200 : PaymentSubV4Theme.amberBorder;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.fromLTRB(12, 7, 8, 7),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: expired ? Colors.red.shade500 : const Color(0xFFF59E0B),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: foreground.withValues(alpha: 0.25),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                expired
                    ? (isEn ? 'Payment session expired' : 'QR หมดอายุแล้ว')
                    : (isEn ? 'QR valid for' : 'QR ใช้ได้อีกภายใน'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontSize: 13,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                  color: PaymentSubV4Theme.amberForeground,
                ),
              ),
            ),
            Container(
              height: 26,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: expired
                    ? Colors.red.shade100
                    : PaymentSubV4Theme.amberBackground,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    expired ? Icons.timer_off_outlined : Icons.schedule_rounded,
                    size: 13,
                    color: foreground,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    expired ? '--:--' : PaymentSubV4Theme.countdown(secs),
                    style: TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                      fontFeatures: PaymentSubV4Theme.tabularFigures,
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
