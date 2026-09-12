import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chaoperty_user/color.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_slide_to_confirm.dart';

class PaymentSubV4Dialogs {
  /// Dialog เตือนให้แนบหลักฐานหลังชำระ (แสดงครั้งแรกที่เข้าหน้า)
  static Future<void> showAttachSlipNotice(
    BuildContext context, {
    required bool isEn,
  }) {
    double dx = 0.0;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setSS) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        color: Colors.red,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isEn ? 'Important Notice' : 'ประกาศสำคัญสำหรับผู้เช่า',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isEn
                          ? 'After making a payment, tenants must attach payment evidence via the tenant app every time.'
                          : 'หลังจากทำการชำระเงินแล้ว\nผู้เช่าจะต้องแนบหลักฐานการชำระเงิน\nผ่านแอปผู้เช่าทุกครั้ง',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        isEn
                            ? 'If no evidence is attached,\nthe system will treat it as\n"No Payment Made" in all cases'
                            : 'หากไม่แนบหลักฐานในแอปผู้เช่า\nระบบจะถือว่า\n"ยังไม่มีการชำระเงิน" ทุกกรณี',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          height: 1.65,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (_, constraints) {
                        const double handleSize = 46.0;
                        const double trackHeight = 52.0;
                        const double pad = 4.0;
                        final double maxDrag =
                            constraints.maxWidth - handleSize - pad * 2;
                        final double pct = (dx / maxDrag).clamp(0.0, 1.0);

                        return Container(
                          height: trackHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.lerp(Colors.grey, Colors.grey.shade800, pct)!,
                                Colors.grey.shade800,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius:
                                BorderRadius.circular(trackHeight / 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Center(
                                child: Opacity(
                                  opacity: (1.0 - pct * 2).clamp(0.0, 1.0),
                                  child: Text(
                                    isEn ? 'Slide to close' : 'เลื่อนเพื่อปิด',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedPositioned(
                                duration: dx == 0
                                    ? const Duration(milliseconds: 300)
                                    : Duration.zero,
                                curve: Curves.elasticOut,
                                left: pad + dx,
                                child: GestureDetector(
                                  onHorizontalDragUpdate: (d) {
                                    setSS(() {
                                      dx = (dx + d.delta.dx)
                                          .clamp(0.0, maxDrag);
                                    });
                                  },
                                  onHorizontalDragEnd: (_) {
                                    if (dx >= maxDrag * 0.72) {
                                      Navigator.of(ctx, rootNavigator: true)
                                          .pop();
                                    } else {
                                      setSS(() => dx = 0.0);
                                    }
                                  },
                                  child: Container(
                                    width: handleSize,
                                    height: handleSize,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.grey.shade700,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Dialog ยืนยันการชำระเงิน (Preview สลิป + Slide to confirm)
  static Future<void> showPaymentConfirmation(
    BuildContext context, {
    required bool isEn,
    required PaymentSummary summary,
    required PaymentSlipState slip,
    required Future<void> Function() onConfirm,
  }) {
    final nFormat = NumberFormat('#,##0.00', 'en_US');

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 22,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      isEn ? 'Confirm Payment' : 'ยืนยันการชำระเงิน',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 14),
            if (slip.slipBytes != null)
              Container(
                height: 240,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.1,
                    maxScale: 4.0,
                    child: Image.memory(slip.slipBytes!, fit: BoxFit.contain),
                  ),
                ),
              )
            else
              Container(
                height: 120,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  isEn ? 'No slip attached yet' : 'ยังไม่ได้แนบหลักฐาน',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isEn ? 'Slip attached' : 'หลักฐานแนบแล้ว',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green.shade700,
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        isEn
                            ? '${nFormat.format(summary.grandTotal.toDouble())} THB'
                            : '${nFormat.format(summary.grandTotal.toDouble())} บาท',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: PaymentSubV4SlideToConfirm(
                label: isEn ? 'Slide to Confirm' : 'เลื่อนเพื่อยืนยัน',
                enabled: true,
                onConfirmation: () async {
                  Navigator.of(ctx).pop();
                  await onConfirm();
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Dialog ยกเลิกการชำระเงิน
  static Future<void> showCancelPayment(
    BuildContext context, {
    required bool isEn,
    required bool hasSlip,
    required Future<void> Function() onConfirmCancel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 2.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isEn ? 'Cancel Payment' : 'ยกเลิกการชำระเงิน',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12, width: .5),
                ),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn
                          ? 'Please follow the steps below to restart the payment.'
                          : 'กรุณาทำตามขั้นตอนด้านล่างเพื่อเริ่มการชำระเงินใหม่',
                      style: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _cancelStep(
                      isEn
                          ? 'If you have already made the payment, please attach the proof of transfer and press "Confirm Payment" below.'
                          : 'หากชำระแล้วกรุณาแนบหลักฐานการโอนเงิน และกด "ยืนยันการชำระเงิน" ด้านล่าง',
                      1,
                    ),
                    _cancelStep(
                      isEn
                          ? 'If you have not made the payment and the payment reference number has expired, please cancel and start a new payment.'
                          : 'หากยังไม่ชำระ และเลขที่ชำระเงินหมดอายุ ให้กดยกเลิกเลขที่รายการชำระเงิน แล้วกดเริ่มต้นการชำระเงินใหม่',
                      2,
                    ),
                    _cancelStep(
                      isEn
                          ? 'Once you have attached the proof of transfer, you will not be able to cancel the payment.'
                          : 'หากแนบหลักฐานการโอนเงินแล้ว จะไม่สามารถยกเลิกการชำระเงินได้',
                      3,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Center(
                    child: PaymentSubV4SlideToConfirm(
                      color: Colors.red,
                      label: isEn
                          ? 'Confirm Cancellation and Restart'
                          : 'ยืนยันการยกเลิกและเริ่มต้นใหม่',
                      enabled: !hasSlip,
                      onConfirmation: () async {
                        Navigator.of(dialogCtx).pop();
                        await onConfirmCancel();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _cancelStep(String text, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.orange.withValues(alpha: .25),
                width: .7,
              ),
            ),
            child: Text(
              '$index',
              style: TextStyle(
                fontFamily: Font_.Fonts_T,
                fontWeight: FontWeight.w900,
                color: Colors.orange.shade700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: Font_.Fonts_T,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog แจ้งไม่มีรายการค้างชำระ
  static Future<void> showNoPaymentWarning(
    BuildContext context, {
    required bool isEn,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange.shade200, width: 2),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Oops',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                  fontFamily: Font_.Fonts_T,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isEn ? 'No payment amount!!!' : 'ไม่มียอดชำระ !!!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontFamily: Font_.Fonts_T,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () =>
                      Navigator.of(ctx, rootNavigator: true).pop(),
                  child: Text(
                    isEn ? 'acknowledge' : 'รับทราบ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: Font_.Fonts_T,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
