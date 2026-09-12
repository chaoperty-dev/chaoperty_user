import 'package:flutter/material.dart';
import 'package:chaoperty_user/color.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';

/// แถบแจ้งเวลาหมดอายุของ QR Code (amber)
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
    final s = secs < 0 ? 0 : secs;
    final h = (s ~/ 3600).toString().padLeft(2, '0');
    final m = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$h:$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final secs = qrState.secondsRemaining;
    final isExpired = qrState.isSessionExpired || secs <= 0;
    final prog = totalSeconds > 0
        ? (secs.clamp(0, totalSeconds) / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    final barColor =
        isExpired ? Colors.red.shade600 : const Color(0xFFB45309);
    final bgColor =
        isExpired ? Colors.red.shade50 : const Color(0xFFFEF3C7);

    return Container(
      height: 28,
      width: double.infinity,
      color: bgColor,
      child: Stack(
        children: [
          if (!isExpired)
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: prog,
              child: Container(color: barColor.withValues(alpha: 0.18)),
            ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isExpired ? Icons.timer_off_rounded : Icons.timer_rounded,
                  size: 13,
                  color: barColor,
                ),
                const SizedBox(width: 5),
                Text(
                  isExpired
                      ? (isEn ? 'QR expired' : 'QR หมดอายุแล้ว')
                      : (isEn
                          ? 'QR valid for ${hhmmss(secs)}'
                          : 'QR ใช้ได้อีก ${hhmmss(secs)}'),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    fontFamily: Font_.Fonts_T,
                    color: barColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
