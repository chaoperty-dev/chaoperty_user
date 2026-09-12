import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/color.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';

class PaymentSubV4IntentCard extends StatelessWidget {
  const PaymentSubV4IntentCard({
    super.key,
    required this.intent,
    required this.isVerifyTab,
    this.onAttachSlip,
    this.onViewDetail,
  });

  final PaymentIntent intent;
  final bool isVerifyTab;
  final VoidCallback? onAttachSlip;
  final VoidCallback? onViewDetail;

  @override
  Widget build(BuildContext context) {
    final nFormat = NumberFormat('#,##0.00', 'en_US');
    final normStatus = PaymentSubV4State.classifyIntentStatus(intent);
    final statusText = intent.status ?? '-';
    final intentNo = intent.paymentIntentNo ?? '-';
    final amount = intent.amount ?? intent.requestedAmount ?? 0.0;
    final invoices = intent.invoices;

    Color stBgColor = Colors.cyan.shade100;
    Color stTextColor = Colors.cyan.shade700;

    if (normStatus == NormalizedIntentStatus.awaitingVerification) {
      stBgColor = Colors.green.shade100;
      stTextColor = Colors.green.shade700;
    } else if (normStatus == NormalizedIntentStatus.awaitingSlip) {
      stBgColor = Colors.orange.shade100;
      stTextColor = Colors.orange.shade700;
    }

    return Card(
      elevation: 0.5,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          childrenPadding: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: stBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: stTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '#$intentNo',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontFamily: Font_.Fonts_T,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '฿${nFormat.format(amount)}',
                style: const TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${invoices.length} บิล',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: Font_.Fonts_T,
                  ),
                ),
                if (!isVerifyTab && onAttachSlip != null)
                  InkWell(
                    onTap: onAttachSlip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.attach_file,
                              size: 14, color: Colors.orange.shade800),
                          const SizedBox(width: 4),
                          Text(
                            'แนบสลิป',
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
                  ),
              ],
            ),
          ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...invoices.map((inv) {
              final invRef = inv.billReference ?? '-';
              final invAmt = inv.total ?? inv.amount ?? 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      invRef,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                    Text(
                      '฿${nFormat.format(invAmt)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
