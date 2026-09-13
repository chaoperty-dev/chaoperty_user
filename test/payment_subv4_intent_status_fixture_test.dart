import 'package:flutter_test/flutter_test.dart';

import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';

/// ค่าที่ดึงจาก response จริงของ
/// POST https://pay-api.chaoperties.com/api/v1/payment/intents/state
/// (property 146, customer 00008)
///
/// เทสต์ชุดนี้ล็อกพฤติกรรม classifier กับค่าที่ server ส่งจริง
/// ไม่ใช่ค่าที่เดา — ถ้า server เพิ่มสถานะใหม่ เทสต์จะเตือนว่าต้องอัปเดต
PaymentIntent _intent({
  required String status,
  required String systemStatus,
  String? uuid,
  String? intentNo,
  String? amount,
  bool attacheExists = false,
  List<Invoice> invoices = const [],
}) {
  return PaymentIntent.fromJson({
    'uuid': uuid,
    'payment_intent_no': intentNo,
    'status': status,
    'system_status': systemStatus,
    'amount': amount,
    'attache_exists': attacheExists,
    'invoices': invoices
        .map(
          (i) => {
            'bill_reference': i.billReference,
            'total': i.total?.toStringAsFixed(2),
          },
        )
        .toList(),
  });
}

void main() {
  group('real server status values', () {
    test('กำลังสร้าง / draft is not an awaiting tab', () {
      final intent = _intent(
        status: 'กำลังสร้าง',
        systemStatus: 'draft',
        uuid: '14fef166-4e60-4078-bca0-3a0ebe6fd8f8',
        intentNo: 'PI-y131hikzcdj5',
        amount: '220.00',
      );

      final result = PaymentSubV4State.classifyIntentStatus(intent);

      expect(result, isNot(NormalizedIntentStatus.awaitingSlip));
      expect(result, isNot(NormalizedIntentStatus.awaitingVerification));
    });

    test('รอชำระเงิน / pending goes to the awaiting-slip tab', () {
      final intent = _intent(
        status: 'รอชำระเงิน',
        systemStatus: 'pending',
        uuid: 'e5b7f378-19ea-48a9-8c09-7094650ed733',
        intentNo: 'PI-ovxfqhhq2kk9',
        amount: '1000.00',
      );

      expect(
        PaymentSubV4State.classifyIntentStatus(intent),
        NormalizedIntentStatus.awaitingSlip,
      );
    });

    test('รอการตรวจสอบ / verification goes to the verification tab', () {
      final intent = _intent(
        status: 'รอการตรวจสอบ',
        systemStatus: 'verification',
        uuid: '308b042b-f2ba-438f-bc64-bb0e2cfee7d5',
        intentNo: 'PI-b104pm6x1wvp',
        amount: '1000.00',
        attacheExists: true,
      );

      expect(
        PaymentSubV4State.classifyIntentStatus(intent),
        NormalizedIntentStatus.awaitingVerification,
      );
    });

    test('รอการตรวจสอบ wins even when system_status is only verification', () {
      // 'รอการตรวจสอบ' มี substring 'รอการ' ซึ่งต้องเข้าเงื่อนไข verify ก่อน
      expect(
        PaymentSubV4State.classifyIntentStatus(
          _intent(status: 'รอการตรวจสอบ', systemStatus: 'verification'),
        ),
        NormalizedIntentStatus.awaitingVerification,
      );
      // และต้องไม่ถูกจับเป็น awaitingSlip แม้บางระบบส่งคำว่า pay มาด้วย
      expect(
        PaymentSubV4State.classifyIntentStatus(
          _intent(status: 'รอการตรวจสอบ', systemStatus: 'slip_uploaded'),
        ),
        NormalizedIntentStatus.awaitingVerification,
      );
    });

    test('tab counts match the real four-intent payload', () {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        paymentIntents: [
          _intent(status: 'กำลังสร้าง', systemStatus: 'draft'),
          _intent(status: 'รอชำระเงิน', systemStatus: 'pending'),
          _intent(status: 'รอชำระเงิน', systemStatus: 'pending'),
          _intent(status: 'รอการตรวจสอบ', systemStatus: 'verification'),
        ],
      );

      // ต้นฉบับนับ badge จาก intent เท่านั้น: draft ไม่เข้าแท็บใด
      expect(state.countAwaitingSlip, 2);
      expect(state.countAwaitingVerify, 1);
    });

    test('invoice payload keeps bill reference and total', () {
      final intent = _intent(
        status: 'รอชำระเงิน',
        systemStatus: 'pending',
        invoices: [Invoice(billReference: 'INV69-09-001985', total: 1000)],
      );

      expect(intent.invoices, hasLength(1));
      expect(intent.invoices.first.billReference, 'INV69-09-001985');
      expect(intent.invoices.first.total, 1000);
    });

    test('server is_expired flag parses into status extended', () {
      final intent = PaymentIntent.fromJson({
        'status': 'รอชำระเงิน',
        'system_status': 'pending',
        'is_expired': true,
        'soft_expire_at': '2026-09-08T16:49:59.000000Z',
      });

      expect(intent.softExpireAt, isNotNull);
      expect(
        intent.softExpireAt!.isBefore(DateTime.now()),
        isTrue,
        reason: 'fixture expiry 2026-09-08 must be in the past',
      );
    });

    test('unknown future status does not silently become awaiting', () {
      final intent = _intent(
        status: 'สถานะใหม่ที่ยังไม่รู้จัก',
        systemStatus: 'brand_new',
      );

      final result = PaymentSubV4State.classifyIntentStatus(intent);

      expect(result, isNot(NormalizedIntentStatus.awaitingSlip));
      expect(result, isNot(NormalizedIntentStatus.awaitingVerification));
    });
  });
}
