import 'package:flutter_test/flutter_test.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';

void main() {
  group('PaymentSubV4 Intent Status Classification Tests', () {
    test('Classify awaitingVerification status correctly', () {
      final intent1 = PaymentIntent(status: 'รอการตรวจสอบ');
      expect(
        PaymentSubV4State.classifyIntentStatus(intent1),
        NormalizedIntentStatus.awaitingVerification,
      );

      final intent2 = PaymentIntent(status: 'review_pending');
      expect(
        PaymentSubV4State.classifyIntentStatus(intent2),
        NormalizedIntentStatus.awaitingVerification,
      );

      final intent3 = PaymentIntent(
        status: 'any_status',
        systemStatus: 'slip_uploaded',
      );
      expect(
        PaymentSubV4State.classifyIntentStatus(intent3),
        NormalizedIntentStatus.awaitingVerification,
      );
    });

    test('Classify awaitingSlip status correctly', () {
      final intent1 = PaymentIntent(status: 'รอชำระเงิน');
      expect(
        PaymentSubV4State.classifyIntentStatus(intent1),
        NormalizedIntentStatus.awaitingSlip,
      );

      final intent2 = PaymentIntent(status: 'awaiting_payment');
      expect(
        PaymentSubV4State.classifyIntentStatus(intent2),
        NormalizedIntentStatus.awaitingSlip,
      );
    });

    test('Classify completed and expired correctly', () {
      final intentSuccess = PaymentIntent(status: 'success');
      expect(
        PaymentSubV4State.classifyIntentStatus(intentSuccess),
        NormalizedIntentStatus.completed,
      );

      final intentExpired = PaymentIntent(status: 'expired');
      expect(
        PaymentSubV4State.classifyIntentStatus(intentExpired),
        NormalizedIntentStatus.expired,
      );
    });
  });
}
