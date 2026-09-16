import 'package:flutter_test/flutter_test.dart';

import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/services/payment_subv4_service.dart';

/// เทสต์กติกาปุ่มบนการ์ด intent (แท็บ 2/3) เทียบกับต้นฉบับ `_IntentBox`
///
/// ต้นฉบับตัดสินด้วย:
/// ```
/// isWaitingCheck = status == 'รอตรวจสอบ' || status == 'รอการตรวจสอบ'   // ตรงตัว
/// isSlipUploaded = system_status == 'slip_uploaded'
/// showSlipAction = latestSlip != null || isSlipUploaded || isWaitingCheck
/// ```
/// - `showSlipAction && !_isAwaitingVerifyStatus` → ปุ่ม "หลักฐานการชำระ"
/// - `showSlipAction && _isAwaitingVerifyStatus` → ไม่มีปุ่ม
/// - `!_showSlipAction` → ปุ่มตามประเภทสถานะ
void main() {
  group('intent card action', () {
    test('awaiting slip shows attach proof', () {
      final action = PaymentSubV4State.intentCardAction(
        PaymentIntent(status: 'รอชำระเงิน', systemStatus: 'pending'),
      );
      expect(action, IntentCardAction.attachProof);
    });

    test('exact waiting-check status has no action at all', () {
      for (final status in const ['รอตรวจสอบ', 'รอการตรวจสอบ']) {
        final action = PaymentSubV4State.intentCardAction(
          PaymentIntent(status: status),
        );
        expect(
          action,
          IntentCardAction.none,
          reason: 'status "$status" ต้องไม่แสดงปุ่มตามต้นฉบับ',
        );
      }
    });

    test('verification wording that is not an exact match shows view proof', () {
      final action = PaymentSubV4State.intentCardAction(
        PaymentIntent(status: 'อยู่ระหว่างการตรวจสอบเอกสาร'),
      );
      expect(action, IntentCardAction.viewProof);
    });

    test('slip_uploaded with a waiting-check status hides the action', () {
      final action = PaymentSubV4State.intentCardAction(
        PaymentIntent(status: 'รอการตรวจสอบ', systemStatus: 'slip_uploaded'),
      );
      expect(action, IntentCardAction.none);
    });

    test('slip_uploaded with a plain awaiting status shows payment proof', () {
      final action = PaymentSubV4State.intentCardAction(
        PaymentIntent(status: 'รอชำระเงิน', systemStatus: 'slip_uploaded'),
      );
      expect(action, IntentCardAction.paymentProof);
    });

    test('latest slip implies payment proof on a non-verify status', () {
      final action = PaymentSubV4State.intentCardAction(
        PaymentIntent(status: 'รอชำระเงิน', latestSlip: {'slip_no': 'S1'}),
      );
      expect(action, IntentCardAction.paymentProof);
    });

    test('latest slip on a verify status hides the action', () {
      final action = PaymentSubV4State.intentCardAction(
        PaymentIntent(status: 'รอการตรวจสอบ', latestSlip: {'slip_no': 'S1'}),
      );
      expect(action, IntentCardAction.none);
    });

    test('unknown status falls back to press to pay', () {
      final action = PaymentSubV4State.intentCardAction(
        PaymentIntent(status: 'กำลังสร้าง', systemStatus: 'draft'),
      );
      expect(action, IntentCardAction.pressToPay);
    });

    test('null status does not throw', () {
      expect(
        PaymentSubV4State.intentCardAction(PaymentIntent()),
        IntentCardAction.pressToPay,
      );
    });
  });

  group('slip presence', () {
    test('detects uploaded slip from system status', () {
      expect(
        PaymentSubV4State.intentSlipPresence(
          PaymentIntent(systemStatus: 'slip_uploaded'),
        ),
        IntentSlipPresence.uploaded,
      );
    });

    test('detects uploaded slip from latest slip payload', () {
      expect(
        PaymentSubV4State.intentSlipPresence(
          PaymentIntent(latestSlip: {'slip_no': 'S1'}),
        ),
        IntentSlipPresence.uploaded,
      );
    });

    test('exact waiting-check status counts as awaiting check', () {
      expect(
        PaymentSubV4State.intentSlipPresence(
          PaymentIntent(status: 'รอการตรวจสอบ'),
        ),
        IntentSlipPresence.awaitingCheck,
      );
    });

    test('plain awaiting status has no slip presence', () {
      expect(
        PaymentSubV4State.intentSlipPresence(PaymentIntent(status: 'รอชำระเงิน')),
        IntentSlipPresence.none,
      );
    });
  });

  group('tab counts follow the legacy status wording', () {
    test('slip_uploaded on an awaiting status still counts as awaiting slip', () {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        paymentIntents: [
          PaymentIntent(status: 'รอชำระเงิน', systemStatus: 'slip_uploaded'),
        ],
      );

      // ต้นฉบับนับจากข้อความ status เท่านั้น จึงยังอยู่แท็บรอแนบหลักฐาน
      expect(state.countAwaitingSlip, 1);
      expect(state.countAwaitingVerify, 0);
    });

    test('exact waiting-check status counts as awaiting verify', () {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        paymentIntents: [
          PaymentIntent(status: 'รอการตรวจสอบ', systemStatus: 'verification'),
        ],
      );

      expect(state.countAwaitingSlip, 0);
      expect(state.countAwaitingVerify, 1);
    });

    test('draft intent is counted in neither tab', () {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        paymentIntents: [
          PaymentIntent(status: 'กำลังสร้าง', systemStatus: 'draft'),
        ],
      );

      expect(state.countAwaitingSlip, 0);
      expect(state.countAwaitingVerify, 0);
    });

    test('tab lists match their counts', () {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        paymentIntents: [
          PaymentIntent(status: 'รอชำระเงิน', paymentIntentNo: 'A'),
          PaymentIntent(status: 'รอการตรวจสอบ', paymentIntentNo: 'B'),
          PaymentIntent(status: 'กำลังสร้าง', paymentIntentNo: 'C'),
        ],
      );

      expect(state.awaitingSlipIntents.map((e) => e.paymentIntentNo), ['A']);
      expect(state.awaitingVerifyIntents.map((e) => e.paymentIntentNo), ['B']);
    });
  });

  group('slip info parsing', () {
    test('maps every field shown by the legacy slip sheet', () {
      final info = PaymentSlipInfo.fromJson({
        'slip_no': 'SLIP-1',
        'original_filename': 'slip.jpg',
        'amount': '1,250.00',
        'currency': 'THB',
        'transfer_date': '2026-01-15',
        'transfer_ref_no': 'REF-9',
        'status': 'PENDING',
      });

      expect(info, isNotNull);
      expect(info!.isValid, isTrue);
      expect(info.slipNo, 'SLIP-1');
      expect(info.originalFilename, 'slip.jpg');
      expect(info.amountWithCurrency, '1,250.00 THB');
      expect(info.transferDate, '2026-01-15');
      expect(info.transferRefNo, 'REF-9');
      expect(info.statusLabel, 'รอตรวจสอบ');
    });

    test('maps server status codes to Thai wording', () {
      expect(
        PaymentSlipInfo.fromJson({'status': 'APPROVED'})!.statusLabel,
        'อนุมัติแล้ว',
      );
      expect(
        PaymentSlipInfo.fromJson({'status': 'REJECTED'})!.statusLabel,
        'ไม่อนุมัติ',
      );
      expect(
        PaymentSlipInfo.fromJson({'status': 'SOMETHING'})!.statusLabel,
        'SOMETHING',
      );
      expect(PaymentSlipInfo.fromJson({})!.statusLabel, '-');
    });

    test('amount without currency renders the number alone', () {
      final info = PaymentSlipInfo.fromJson({'amount': '100.00'});
      expect(info!.amountWithCurrency, '100.00');
    });

    test('non-map payload yields null', () {
      expect(PaymentSlipInfo.fromJson(null), isNull);
      expect(PaymentSlipInfo.fromJson('nope'), isNull);
    });

    test('slip without slip_no is not usable for preview', () {
      final info = PaymentSlipInfo.fromJson({'original_filename': 'a.jpg'});
      expect(info!.isValid, isFalse);
    });

    test('blank strings become null', () {
      final info = PaymentSlipInfo.fromJson({
        'slip_no': '  ',
        'currency': '',
      });
      expect(info!.slipNo, isNull);
      expect(info.currency, isNull);
    });
  });

  group('upload response parsing', () {
    test('reads slip_no from a flat response body', () {
      expect(
        PaymentSubV4Service.parseSlipNo('{"slip_no":"SLIP-1"}'),
        'SLIP-1',
      );
    });

    test('reads slip_no from a nested data response body', () {
      expect(
        PaymentSubV4Service.parseSlipNo('{"data":{"slip_no":"SLIP-2"}}'),
        'SLIP-2',
      );
    });

    test('falls back to uuid when slip_no is absent', () {
      expect(
        PaymentSubV4Service.parseSlipNo('{"uuid":"UUID-3"}'),
        'UUID-3',
      );
    });

    test('returns null for empty, non-json and missing keys', () {
      expect(PaymentSubV4Service.parseSlipNo(''), isNull);
      expect(PaymentSubV4Service.parseSlipNo('OK'), isNull);
      expect(PaymentSubV4Service.parseSlipNo('{"other":"x"}'), isNull);
    });

    test('ignores blank values', () {
      expect(PaymentSubV4Service.parseSlipNo('{"slip_no":"  "}'), isNull);
    });
  });
}
