import 'package:flutter/material.dart';

import 'package:chaoperty_user/color.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_theme.dart';

class PaymentSubV4Tabs extends StatelessWidget {
  const PaymentSubV4Tabs({
    super.key,
    required this.selectedTab,
    required this.countPayable,
    required this.countAwaitingSlip,
    required this.countAwaitingVerify,
    required this.onTabSelected,
    required this.isEn,
  });

  final int selectedTab;
  final int countPayable;
  final int countAwaitingSlip;
  final int countAwaitingVerify;
  final ValueChanged<int> onTabSelected;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 390 ||
        MediaQuery.textScalerOf(context).scale(13) > 16;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3F7),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            _tab(
              index: 1,
              label: isEn ? 'To pay' : 'ที่ต้องชำระ',
              narrowLabel: isEn ? 'Pay' : 'ต้องชำระ',
              count: countPayable,
              badge: PaymentSubV4Theme.primaryOrange,
              narrow: narrow,
            ),
            _tab(
              index: 2,
              label: isEn ? 'Awaiting slip' : 'รอแนบสลิป',
              narrowLabel: isEn ? 'Slip' : 'รอสลิป',
              count: countAwaitingSlip,
              badge: const Color(0xFFFBBF24),
              narrow: narrow,
            ),
            _tab(
              index: 3,
              label: isEn ? 'Verification' : 'รอระบบตรวจสอบ',
              narrowLabel: isEn ? 'Verify' : 'รอตรวจ',
              count: countAwaitingVerify,
              badge: PaymentSubV4Theme.emerald,
              narrow: narrow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab({
    required int index,
    required String label,
    required String narrowLabel,
    required int count,
    required Color badge,
    required bool narrow,
  }) {
    final active = selectedTab == index;

    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: '$label $count',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onTabSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: active ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: active
                    ? Border.all(color: PaymentSubV4Theme.border)
                    : null,
                boxShadow: active
                    ? const [
                        BoxShadow(
                          color: Color(0x120F172A),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      narrow ? narrowLabel : label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 13,
                        height: 1.25,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.w400,
                        color: active
                            ? PaymentSubV4Theme.textPrimary
                            : PaymentSubV4Theme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: badge,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 11,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
