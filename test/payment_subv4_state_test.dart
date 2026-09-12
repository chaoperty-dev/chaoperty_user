import 'package:flutter_test/flutter_test.dart';
import 'package:chaoperty_user/Model/GetPayMent_Model.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';

void main() {
  group('PaymentSubV4State copyWith clear semantics', () {
    test('keeps existing upload target when not clearing', () {
      const s = PaymentSubV4State(
        uploadTargetUuid: 'uuid-a',
        uploadTargetAmount: Money(1000),
      );

      final next = s.copyWith(selectedTab: 2);

      expect(next.uploadTargetUuid, 'uuid-a');
      expect(next.uploadTargetAmount?.satang, 1000);
    });

    test('clears upload target when explicitly requested', () {
      const s = PaymentSubV4State(
        uploadTargetUuid: 'uuid-a',
        uploadTargetAmount: Money(1000),
      );

      final next = s.copyWith(clearUploadTarget: true);

      expect(next.uploadTargetUuid, isNull);
      expect(next.uploadTargetAmount, isNull);
    });

    test('passing null does not clear upload target (regression guard)', () {
      const s = PaymentSubV4State(uploadTargetUuid: 'uuid-a');

      // copyWith ใช้ ?? this.x จึงคงค่าเดิมไว้ — ต้องใช้ clearUploadTarget เท่านั้น
      final next = s.copyWith(uploadTargetUuid: null);

      expect(next.uploadTargetUuid, 'uuid-a');
    });

    test('clears error message with clearError', () {
      const s = PaymentSubV4State(errorMessage: 'boom');

      expect(s.copyWith(clearError: true).errorMessage, isNull);
    });

    test('passing null error does not clear it (regression guard)', () {
      const s = PaymentSubV4State(errorMessage: 'boom');
      expect(s.copyWith(errorMessage: null).errorMessage, 'boom');
    });

    test('clears selected payment model with clearSelectedPayment', () {
      final s = PaymentSubV4State(selectedPaymentModel: PayMentModel());
      expect(s.copyWith(clearSelectedPayment: true).selectedPaymentModel, isNull);
    });

    test('clears rental model with clearRental', () {
      const s = PaymentSubV4State(rentalModel: null);
      final withRental = s.copyWith(rentalModel: null);
      // ไม่มีค่าเดิม → ยังเป็น null
      expect(withRental.rentalModel, isNull);
      expect(s.copyWith(clearRental: true).rentalModel, isNull);
    });

    test('clears section errors with clearSectionErrors', () {
      const s = PaymentSubV4State(sectionErrors: ['a', 'b']);

      expect(s.copyWith(clearSectionErrors: true).sectionErrors, isEmpty);
      expect(s.copyWith(sectionErrors: ['c']).sectionErrors, ['c']);
    });

    test('clears detail loading with clearDetailLoading', () {
      const s = PaymentSubV4State(detailLoadingDocno: 'DOC1');

      expect(s.copyWith(clearDetailLoading: true).detailLoadingDocno, isNull);
      expect(s.copyWith(detailLoadingDocno: 'DOC2').detailLoadingDocno, 'DOC2');
    });

    test('keeps ui event until explicitly cleared', () {
      const s = PaymentSubV4State(
        uiEvent: PaymentUiEvent(id: 'e1', message: 'hi'),
      );

      // state update อื่นต้องไม่ล้าง event ที่ยังไม่ถูกแสดง
      final next = s.copyWith(selectedTab: 3);
      expect(next.uiEvent?.id, 'e1');

      expect(s.copyWith(clearUiEvent: true).uiEvent, isNull);
    });

    test('replaces ui event when a new one is supplied', () {
      const s = PaymentSubV4State(
        uiEvent: PaymentUiEvent(id: 'e1', message: 'old'),
      );

      final next = s.copyWith(
        uiEvent: const PaymentUiEvent(id: 'e2', message: 'new'),
      );

      expect(next.uiEvent?.id, 'e2');
    });
  });

  group('Intent status classification', () {
    test('awaiting verification wins over awaiting slip', () {
      final status = PaymentSubV4State.classifyIntentStatus(
        PaymentIntent(status: 'รอชำระเงิน', systemStatus: 'slip_uploaded'),
      );
      expect(status, NormalizedIntentStatus.awaitingVerification);
    });

    test('slip uploaded system status implies awaiting verification', () {
      final status = PaymentSubV4State.classifyIntentStatus(
        PaymentIntent(status: 'anything', systemStatus: 'slip_uploaded'),
      );
      expect(status, NormalizedIntentStatus.awaitingVerification);
    });

    test('latest slip presence implies awaiting verification', () {
      final status = PaymentSubV4State.classifyIntentStatus(
        PaymentIntent(status: 'anything', latestSlip: {'slip_no': 'S1'}),
      );
      expect(status, NormalizedIntentStatus.awaitingVerification);
    });

    test('awaiting slip detected for thai and english wording', () {
      expect(
        PaymentSubV4State.classifyIntentStatus(
          PaymentIntent(status: 'รอชำระเงิน'),
        ),
        NormalizedIntentStatus.awaitingSlip,
      );
      expect(
        PaymentSubV4State.classifyIntentStatus(
          PaymentIntent(status: 'awaiting_payment'),
        ),
        NormalizedIntentStatus.awaitingSlip,
      );
    });

    test('completed, expired and cancelled detected', () {
      expect(
        PaymentSubV4State.classifyIntentStatus(PaymentIntent(status: 'success')),
        NormalizedIntentStatus.completed,
      );
      expect(
        PaymentSubV4State.classifyIntentStatus(PaymentIntent(status: 'expired')),
        NormalizedIntentStatus.expired,
      );
      expect(
        PaymentSubV4State.classifyIntentStatus(PaymentIntent(status: 'cancelled')),
        NormalizedIntentStatus.cancelled,
      );
    });

    test('null status does not throw', () {
      expect(
        PaymentSubV4State.classifyIntentStatus(PaymentIntent()),
        NormalizedIntentStatus.payable,
      );
    });
  });
}
