import 'package:flutter/material.dart';

import 'package:chaoperty_user/Model/GetPayMent_Model.dart';
import 'package:chaoperty_user/color.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';

/// การ์ดธนาคารย่อสำหรับหัวแท็บ 2/3
///
/// ต้นฉบับเรียก `_groupTile2()` — แสดงตลอดแม้ยังไม่มี QR session
/// เพื่อให้ผู้ใช้ที่ออกจากแอปแล้วกลับเข้ามาใหม่ยังเห็นว่ากำลังชำระกับธนาคารใด
///
/// โครงเดียวกับต้นฉบับ: การ์ดหัวธนาคารแบบไม่กางออก (trailing ว่าง)
/// มีโลโก้ + ชื่อธนาคาร + เลขบัญชี + ชื่อบัญชี
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
    final owner = payment.accountOwner(isEn: isEn);

    return Card(
      elevation: 0.4,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          childrenPadding: const EdgeInsets.only(left: 6, right: 6, bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onExpansionChanged: null,
          initiallyExpanded: false,
          // ต้นฉบับซ่อนลูกศรกางออก
          trailing: const SizedBox(),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: logo == null
                    ? const Icon(
                        Icons.account_balance,
                        size: 20,
                        color: Colors.grey,
                      )
                    : Image.asset(
                        logo,
                        height: 26,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.account_balance,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  code.isEmpty ? name : '$name ($code)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (account.isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(
                      Icons.account_balance,
                      size: 15,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      account,
                      style: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 12.5,
                      ),
                    ),
                  ]),
                if (owner.isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.note, size: 15, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      owner,
                      style: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 12.5,
                      ),
                    ),
                  ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
