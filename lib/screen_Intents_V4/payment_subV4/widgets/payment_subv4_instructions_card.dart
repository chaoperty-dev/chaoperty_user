import 'package:flutter/material.dart';
import 'package:chaoperty_user/color.dart';

/// การ์ดแนะนำวิธีชำระเงิน 4 ขั้นตอน
class PaymentSubV4InstructionsCard extends StatelessWidget {
  const PaymentSubV4InstructionsCard({
    super.key,
    required this.isEn,
    required this.isBankTransfer,
  });

  final bool isEn;
  final bool isBankTransfer;

  List<String> get _steps => isBankTransfer
      ? [
          isEn
              ? 'Copy the Account Number shown above by pressing the "Copy" button.'
              : 'คัดลอกเลขบัญชีด้านบนโดยกดปุ่ม ‘คัดลอก’',
          isEn
              ? 'Open your banking application to start the transaction.'
              : 'เปิดแอปพลิเคชันธนาคารของคุณ เพื่อเริ่มทำรายการ',
          isEn
              ? 'Go to the "Transfer" menu, then paste the copied number and enter the exact amount.'
              : 'ไปยังเมนู ‘โอนเงิน’ จากนั้นนำเลขบัญชีที่คัดลอกไว้ไปวาง และใส่จำนวนเงินให้ตรง',
          isEn
              ? 'After transferring, attach the slip and confirm the payment.'
              : 'หลังจากโอนเงินแล้ว ให้แนบสลิปและกดยืนยันการชำระเงิน',
        ]
      : [
          isEn
              ? 'Open your banking application and choose the "Scan QR" menu.'
              : 'เปิดแอปพลิเคชันธนาคาร แล้วเลือกเมนู ‘สแกน QR’',
          isEn
              ? 'Scan the QR code shown above.'
              : 'สแกน QR Code ที่แสดงอยู่ด้านบน',
          isEn
              ? 'Verify the amount and confirm the transaction in your bank app.'
              : 'ตรวจสอบจำนวนเงินให้ถูกต้อง แล้วยืนยันรายการในแอปธนาคาร',
          isEn
              ? 'After transferring, attach the slip and confirm the payment.'
              : 'หลังจากโอนเงินแล้ว ให้แนบสลิปและกดยืนยันการชำระเงิน',
        ];

  @override
  Widget build(BuildContext context) {
    final steps = _steps;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF0E5C9E), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEn
                      ? 'How to pay in 4 easy steps'
                      : 'วิธีชำระเงินง่ายๆ 4 ขั้นตอน',
                  style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < steps.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 34,
                    child: Column(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: i == steps.length - 1
                                ? const Color(0xFFFF6B00).withValues(alpha: 0.15)
                                : const Color(0xFF0E5C9E),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: i == steps.length - 1
                                  ? const Color(0xFFE05E00)
                                  : Colors.white,
                              fontFamily: Font_.Fonts_T,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (i < steps.length - 1)
                          Expanded(
                            child: Container(
                              width: 1.5,
                              color: Colors.grey.shade200,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 2, bottom: 12),
                      decoration: i < steps.length - 1
                          ? BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade200),
                              ),
                            )
                          : null,
                      child: Text(
                        steps[i],
                        style: const TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.black87,
                        ),
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
