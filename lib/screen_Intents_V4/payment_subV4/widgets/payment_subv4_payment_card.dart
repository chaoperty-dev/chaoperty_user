import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import 'package:chaoperty_user/Model/GetPayMent_Model.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_theme.dart';

class PaymentSubV4PaymentCard extends StatelessWidget {
  const PaymentSubV4PaymentCard({
    super.key,
    required this.paymentModel,
    required this.summary,
    required this.qrState,
    required this.isEn,
    required this.merchantName,
    required this.onCopy,
    this.onSaveQr,
    this.onRenewQr,
    this.qrBoundaryKey,
  });

  final PayMentModel? paymentModel;
  final PaymentSummary summary;
  final PaymentQrState qrState;
  final bool isEn;
  final String merchantName;
  final ValueChanged<String> onCopy;
  final VoidCallback? onSaveQr;
  final VoidCallback? onRenewQr;
  final GlobalKey? qrBoundaryKey;

  @override
  Widget build(BuildContext context) {
    final payment = paymentModel;
    if (payment == null) return const SizedBox.shrink();

    final mode = payment.channelMode;
    if (mode == PaymentChannelMode.unsupported) {
      return _unsupported(payment);
    }

    return Container(
      key: ValueKey<String>('payment-channel-${mode.name}'),
      decoration: PaymentSubV4Theme.cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _bankHeader(payment),
          if (payment.safeRemark.isNotEmpty) _remark(payment.safeRemark),
          if (mode == PaymentChannelMode.bankTransfer)
            _bankTransferBody(payment)
          else
            _qrBody(payment),
          _referenceFooter(),
        ],
      ),
    );
  }

  Widget _bankHeader(PayMentModel payment) {
    final name = payment.bankDisplayName(isEn: isEn);
    final code = payment.bankShortCode;
    final logo = payment.bankLogoAsset;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 10),
      decoration: const BoxDecoration(
        color: PaymentSubV4Theme.slateSoft,
        border: Border(
          bottom: BorderSide(color: PaymentSubV4Theme.border),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: PaymentSubV4Theme.border),
            ),
            child: logo == null
                ? const Icon(
                    Icons.account_balance_rounded,
                    color: PaymentSubV4Theme.textSecondary,
                    size: 22,
                  )
                : Image.asset(
                    logo,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.account_balance_rounded,
                      color: PaymentSubV4Theme.textSecondary,
                      size: 22,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'Destination bank' : 'ธนาคารปลายทาง',
                  style: PaymentSubV4Theme.text(
                    size: 11,
                    color: PaymentSubV4Theme.textSecondary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  code.isEmpty ? name : '$name ($code)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PaymentSubV4Theme.text(
                    size: 14,
                    weight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _remark(String remark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 38),
        padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: PaymentSubV4Theme.amberBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 17,
              color: PaymentSubV4Theme.amberForeground,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                '${isEn ? 'Remark' : 'หมายเหตุ'}: $remark',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: PaymentSubV4Theme.text(
                  size: 13,
                  weight: FontWeight.w500,
                  color: const Color(0xFF92400E),
                  height: 1.35,
                ),
              ),
            ),
            IconButton(
              tooltip: isEn ? 'Copy remark' : 'คัดลอกหมายเหตุ',
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              icon: const Icon(
                Icons.content_copy_outlined,
                size: 16,
                color: PaymentSubV4Theme.amberForeground,
              ),
              onPressed: () => onCopy(remark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrBody(PayMentModel payment) {
    final payload = (qrState.qrPayload ?? '').trim();
    final expired = qrState.isSessionExpired;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: RepaintBoundary(
        key: qrBoundaryKey,
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 214,
                    height: 214,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: PaymentSubV4Theme.border),
                    ),
                    child: payload.isEmpty
                        ? const Center(
                            child: Icon(
                              Icons.qr_code_2_rounded,
                              size: 82,
                              color: Color(0xFFCBD5E1),
                            ),
                          )
                        : PrettyQrView.data(
                            data: payload,
                            errorCorrectLevel: QrErrorCorrectLevel.M,
                          ),
                  ),
                  ..._qrCorners(),
                  if (expired)
                    Container(
                      width: 214,
                      height: 214,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.timer_off_rounded,
                            size: 32,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 7),
                          Text(
                            isEn ? 'QR expired' : 'QR หมดอายุแล้ว',
                            style: PaymentSubV4Theme.text(
                              size: 13,
                              weight: FontWeight.w700,
                            ),
                          ),
                          if (onRenewQr != null) ...[
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: onRenewQr,
                              icon: const Icon(Icons.refresh_rounded, size: 17),
                              label: Text(isEn ? 'New QR' : 'ขอ QR ใหม่'),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isEn ? 'Amount to pay' : 'ยอดเงินที่ต้องชำระ',
                style: PaymentSubV4Theme.text(
                  size: 12,
                  color: PaymentSubV4Theme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '฿',
                      style: PaymentSubV4Theme.text(
                        size: 22,
                        weight: FontWeight.w800,
                        color: PaymentSubV4Theme.primaryOrangeDark,
                        tabular: true,
                      ),
                    ),
                    TextSpan(
                      text: PaymentSubV4Theme.money(summary.grandTotal),
                      style: PaymentSubV4Theme.text(
                        size: 30,
                        weight: FontWeight.w800,
                        color: PaymentSubV4Theme.textPrimary,
                        tabular: true,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: PaymentSubV4Theme.slateSoft,
                    foregroundColor: PaymentSubV4Theme.textPrimary,
                    side: const BorderSide(color: PaymentSubV4Theme.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed:
                      payload.isEmpty || expired ? null : onSaveQr,
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: Text(
                    isEn ? 'Save QR Code' : 'บันทึกภาพ QR Code ลงเครื่อง',
                    style: PaymentSubV4Theme.text(
                      size: 12,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: PaymentSubV4Theme.border),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: PaymentSubV4Theme.slateSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        size: 17,
                        color: PaymentSubV4Theme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? 'Merchant / Payee' : 'ผู้รับเงิน / Merchant',
                            style: PaymentSubV4Theme.text(
                              size: 11,
                              color: PaymentSubV4Theme.textSecondary,
                            ),
                          ),
                          Text(
                            merchantName.isEmpty ? '-' : merchantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PaymentSubV4Theme.text(
                              size: 15,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bankTransferBody(PayMentModel payment) {
    final owner = payment.accountOwner(isEn: isEn);
    final coOwner = payment.safeCoOwner;
    final account = payment.safeAccountNumber;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PaymentSubV4Theme.slateSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PaymentSubV4Theme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'Account holder' : 'ชื่อบัญชีผู้รับเงิน',
                  style: PaymentSubV4Theme.text(
                    size: 11,
                    color: PaymentSubV4Theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  owner.isEmpty ? '-' : owner,
                  style: PaymentSubV4Theme.text(
                    size: 14,
                    weight: FontWeight.w600,
                  ),
                ),
                if (coOwner.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    coOwner,
                    style: PaymentSubV4Theme.text(
                      size: 12,
                      color: PaymentSubV4Theme.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            decoration: BoxDecoration(
              color: PaymentSubV4Theme.skySoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'ACCOUNT NO.' : 'เลขที่บัญชี / ACCOUNT NO.',
                        style: PaymentSubV4Theme.text(
                          size: 11,
                          weight: FontWeight.w500,
                          color: PaymentSubV4Theme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          account.isEmpty ? '-' : account,
                          style: PaymentSubV4Theme.text(
                            size: 24,
                            weight: FontWeight.w700,
                            tabular: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _copyButton(
                  label: isEn ? 'Copy' : 'คัดลอก',
                  value: account,
                  color: PaymentSubV4Theme.skyAction,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PaymentSubV4Theme.amberBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'Amount to transfer' : 'ยอดเงินที่ต้องโอนชำระ',
                        style: PaymentSubV4Theme.text(
                          size: 11,
                          color: PaymentSubV4Theme.amberForeground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '฿${PaymentSubV4Theme.money(summary.grandTotal)}',
                        style: PaymentSubV4Theme.text(
                          size: 26,
                          weight: FontWeight.w800,
                          color: PaymentSubV4Theme.primaryOrangeDark,
                          tabular: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _copyButton(
                  label: isEn ? 'Copy amount' : 'คัดลอกยอดเงิน',
                  value: summary.grandTotal.toFixed2(),
                  color: PaymentSubV4Theme.amberForeground,
                  light: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _copyButton({
    required String label,
    required String value,
    required Color color,
    bool light = false,
  }) {
    return SizedBox(
      height: 36,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          backgroundColor: light ? const Color(0xFFFFF7D6) : color,
          foregroundColor: light ? color : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        onPressed: value.isEmpty ? null : () => onCopy(value),
        icon: const Icon(Icons.content_copy_rounded, size: 14),
        label: Text(
          label,
          style: PaymentSubV4Theme.text(
            size: 12,
            weight: FontWeight.w600,
            color: light ? color : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _referenceFooter() {
    final ref = (qrState.ref3 ?? '').trim().isNotEmpty
        ? qrState.ref3!.trim()
        : (qrState.ref1 ?? '').trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: PaymentSubV4Theme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${isEn ? 'Ref' : 'Ref'}: '),
                TextSpan(
                  text: ref.isEmpty ? '-' : ref,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PaymentSubV4Theme.text(
              size: 12,
              color: PaymentSubV4Theme.textSecondary,
              tabular: true,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${isEn ? 'Expires' : 'หมดอายุ'}: ${PaymentSubV4Theme.expiry(qrState.softExpireAt, isEn: isEn)}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: PaymentSubV4Theme.text(
              size: 12,
              color: PaymentSubV4Theme.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _qrCorners() {
    const color = PaymentSubV4Theme.skyAction;
    const length = 15.0;
    const thickness = 2.0;
    const inset = 4.0;

    Widget corner({required Alignment alignment}) {
      final top = alignment.y < 0;
      final left = alignment.x < 0;
      return Positioned(
        top: top ? inset : null,
        bottom: top ? null : inset,
        left: left ? inset : null,
        right: left ? null : inset,
        child: SizedBox(
          width: length,
          height: length,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: top
                    ? const BorderSide(color: color, width: thickness)
                    : BorderSide.none,
                bottom: top
                    ? BorderSide.none
                    : const BorderSide(color: color, width: thickness),
                left: left
                    ? const BorderSide(color: color, width: thickness)
                    : BorderSide.none,
                right: left
                    ? BorderSide.none
                    : const BorderSide(color: color, width: thickness),
              ),
            ),
          ),
        ),
      );
    }

    return const [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomLeft,
      Alignment.bottomRight,
    ].map((a) => corner(alignment: a)).toList();
  }

  Widget _unsupported(PayMentModel payment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: PaymentSubV4Theme.cardDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: PaymentSubV4Theme.amberForeground,
          ),
          const SizedBox(height: 8),
          Text(
            isEn
                ? 'This payment channel is not supported.'
                : 'ยังไม่รองรับช่องทางชำระเงินนี้',
            textAlign: TextAlign.center,
            style: PaymentSubV4Theme.text(size: 13),
          ),
        ],
      ),
    );
  }
}
