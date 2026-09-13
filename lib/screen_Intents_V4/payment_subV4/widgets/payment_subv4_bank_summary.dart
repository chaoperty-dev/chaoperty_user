import 'package:flutter/material.dart';

import 'package:chaoperty_user/Model/GetPayMent_Model.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_theme.dart';

/// การ์ดธนาคารย่อสำหรับหัวแท็บ 2/3
///
/// ต้นฉบับเรียก `_groupTile2()` — แสดงตลอดแม้ยังไม่มี QR session
/// เพื่อให้ผู้ใช้ที่ออกจากแอปแล้วกลับเข้ามาใหม่ยังเห็นว่ากำลังชำระกับธนาคารใด
class PaymentSubV4BankSummary extends StatelessWidget {
  const PaymentSubV4BankSummary({
    super.key,
    required this.paymentModel,
    required this.isEn,
  });

  final PayMentModel? paymentModel;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final payment = paymentModel;
    if (payment == null) return const SizedBox.shrink();

    final name = payment.bankDisplayName(isEn: isEn);
    final code = payment.bankShortCode;
    final logo = payment.bankLogoAsset;
    final account = payment.safeAccountNumber;

    return Container(
      decoration: PaymentSubV4Theme.cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: PaymentSubV4Theme.border),
                  ),
                  child: logo == null
                      ? const Icon(
                          Icons.account_balance_rounded,
                          size: 20,
                          color: PaymentSubV4Theme.textSecondary,
                        )
                      : Image.asset(
                          logo,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.account_balance_rounded,
                            size: 20,
                            color: PaymentSubV4Theme.textSecondary,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    code.isEmpty ? name : '$name ($code)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PaymentSubV4Theme.text(
                      size: 14,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (account.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 9),
              decoration: const BoxDecoration(
                color: PaymentSubV4Theme.slateSoft,
                border: Border(
                  top: BorderSide(color: PaymentSubV4Theme.border),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_outlined,
                    size: 15,
                    color: PaymentSubV4Theme.textSecondary,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      account,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PaymentSubV4Theme.text(
                        size: 13,
                        weight: FontWeight.w600,
                        tabular: true,
                      ),
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
