import 'package:flutter/material.dart';

import 'package:chaoperty_user/color.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_theme.dart';

class PaymentSubV4Header extends StatelessWidget {
  const PaymentSubV4Header({
    super.key,
    required this.title,
    required this.onBack,
    required this.onHelp,
    this.isConnected = true,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onHelp;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    // Page owns top SafeArea. Do not add another inset here: nested SafeArea
    // compresses the 54px header and clips title/icons on Web.
    return Material(
      color: Colors.white,
      child: SizedBox(
        height: 54,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 4,
              child: IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                constraints: const BoxConstraints.tightFor(
                  width: 44,
                  height: 44,
                ),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: PaymentSubV4Theme.textPrimary,
                  size: 20,
                ),
                onPressed: onBack,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: PaymentSubV4Theme.textPrimary,
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    height: 1.35,
                  ),
                ),
                const SizedBox(width: 6),
                Semantics(
                  label: isConnected ? 'ระบบพร้อมใช้งาน' : 'ระบบไม่พร้อมใช้งาน',
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isConnected
                          ? PaymentSubV4Theme.emerald
                          : Colors.red.shade400,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isConnected
                                  ? PaymentSubV4Theme.emerald
                                  : Colors.red)
                              .withValues(alpha: 0.28),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 4,
              child: IconButton(
                tooltip: 'Help / ช่วยเหลือ',
                constraints: const BoxConstraints.tightFor(
                  width: 44,
                  height: 44,
                ),
                icon: const Icon(
                  Icons.help_outline_rounded,
                  color: PaymentSubV4Theme.textSecondary,
                  size: 20,
                ),
                onPressed: onHelp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
