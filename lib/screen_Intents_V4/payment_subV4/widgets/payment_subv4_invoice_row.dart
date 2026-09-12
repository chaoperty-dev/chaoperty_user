import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chaoperty_user/Model/GetInvoice_Model.dart';
import 'package:chaoperty_user/color.dart';
import 'package:chaoperty_user/screen_Intents/Model/IntentsInv_history_Model.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';

/// แถวใบแจ้งหนี้ที่กางดูรายละเอียดบิลย่อยและค่าปรับได้
class PaymentSubV4InvoiceRow extends StatelessWidget {
  const PaymentSubV4InvoiceRow({
    super.key,
    required this.invoice,
    required this.isEn,
    required this.onExpand,
    this.history = const [],
    this.fine,
    this.isLoadingDetail = false,
  });

  final InvoiceModel invoice;
  final bool isEn;
  final ValueChanged<String> onExpand;
  final List<IntentsInvoiceHistoryModel> history;
  final Map<String, dynamic>? fine;
  final bool isLoadingDetail;

  @override
  Widget build(BuildContext context) {
    final nFormat = NumberFormat('#,##0.00', 'en_US');
    final docno = (invoice.docno ?? '').trim();
    final amount = Money.parse(invoice.amtall);
    final discount = Money.parse(invoice.disendbill);
    final fineTotal = Money.fromDouble((fine?['total'] as num?)?.toDouble());
    final net = Money(amount.satang - discount.satang + fineTotal.satang);

    return Card(
      elevation: 0.4,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding:
              const EdgeInsets.only(left: 14, right: 14, bottom: 10),
          onExpansionChanged: (open) {
            if (open && docno.isNotEmpty) onExpand(docno);
          },
          title: Row(
            children: [
              Icon(
                Icons.receipt_long,
                size: 18,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  docno.isEmpty ? '-' : docno,
                  style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Text(
                '฿${nFormat.format(net.toDouble())}',
                style: const TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 10,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if ((invoice.date ?? '').isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.calendar_today,
                        size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      _fmtDate(invoice.date),
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 11.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ]),
                if (discount.isPositive)
                  _pill(
                    '${isEn ? 'Discount' : 'ส่วนลด'} ${nFormat.format(discount.toDouble())}',
                    Colors.green,
                  ),
                if (fineTotal.isPositive)
                  _pill(
                    '${isEn ? 'Fine' : 'ค่าปรับ'} ${nFormat.format(fineTotal.toDouble())}',
                    Colors.red,
                  ),
              ],
            ),
          ),
          children: [
            if (isLoadingDetail)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (history.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  isEn ? 'No item detail' : 'ไม่มีรายละเอียดบิลย่อย',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontFamily: Font_.Fonts_T,
                    color: Colors.grey.shade600,
                  ),
                ),
              )
            else ...[
              for (final item in history)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          (item.descr ?? '').isEmpty
                              ? (item.refno ?? '-')
                              : item.descr!,
                          style: const TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '฿${nFormat.format(Money.parse(item.total_t).toDouble())}',
                        style: const TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
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

  Widget _pill(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.shade100),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: Font_.Fonts_T,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color.shade700,
        ),
      ),
    );
  }

  String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return DateFormat('dd-MM-yyyy').format(d);
  }
}
