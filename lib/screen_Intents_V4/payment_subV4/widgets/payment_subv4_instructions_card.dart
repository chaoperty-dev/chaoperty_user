import 'package:flutter/material.dart';

import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_theme.dart';

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
              ? 'Copy the account number and verify the transfer amount.'
              : 'คัดลอกเลขที่บัญชี และตรวจสอบยอดเงิน',
          isEn
              ? 'Open your banking application and select “Transfer”.'
              : 'เปิดแอปพลิเคชันธนาคารของคุณแล้วเลือกเมนู “โอนเงิน”',
          isEn
              ? 'Enter the account number and transfer the exact amount.'
              : 'วางเลขที่บัญชีและระบุยอดเงินให้ตรงกับที่ระบบแสดง',
          isEn
              ? 'Attach the transfer slip and confirm below.'
              : 'เมื่อโอนสำเร็จ กดปุ่ม “แนบหลักฐานและยืนยัน” ด้านล่าง',
        ]
      : [
          isEn
              ? 'Save the QR Code or take a screenshot.'
              : 'กดปุ่ม “บันทึก QR Code” ลงในโทรศัพท์ หรือคัดลอกเลขที่บัญชี',
          isEn
              ? 'Open your banking application.'
              : 'เปิดแอปพลิเคชันธนาคารใดก็ได้ (K PLUS, SCB EASY, Krungthai NEXT ฯลฯ)',
          isEn
              ? 'Select “Scan / QR Code” and choose the saved image.'
              : 'เลือกเมนู “สแกน / QR Code” แล้วเลือกดูรูปภาพจากอัลบั้ม',
          isEn
              ? 'Attach the transfer slip and confirm below.'
              : 'เมื่อชำระสำเร็จ กดปุ่ม “แนบหลักฐานและยืนยัน” ด้านล่าง',
        ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 10),
      decoration: PaymentSubV4Theme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: PaymentSubV4Theme.skyAction,
                size: 18,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  isEn
                      ? 'How to pay in 4 easy steps'
                      : 'วิธีชำระเงินง่ายๆ 4 ขั้นตอน',
                  style: PaymentSubV4Theme.text(
                    size: 14,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          for (int i = 0; i < _steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 23,
                    height: 23,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == _steps.length - 1
                          ? const Color(0xFFFFE7D6)
                          : const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: i == _steps.length - 1
                            ? const Color(0xFFFED7AA)
                            : const Color(0xFFDBEAFE),
                      ),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: PaymentSubV4Theme.text(
                        size: 11,
                        weight: FontWeight.w700,
                        color: i == _steps.length - 1
                            ? PaymentSubV4Theme.primaryOrangeDark
                            : PaymentSubV4Theme.skyAction,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _steps[i],
                        style: PaymentSubV4Theme.text(
                          size: 13,
                          color: const Color(0xFF334155),
                          height: 1.45,
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
