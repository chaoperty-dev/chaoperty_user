import 'package:flutter_test/flutter_test.dart';

import 'package:chaoperty_user/CRC_16_Prompay/generate_Ewallet_qrcode.dart';
import 'package:chaoperty_user/CRC_16_Prompay/generate_qrcode.dart';
import 'package:chaoperty_user/Model/GetPayMent_Model.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_qr_payload.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/viewmodels/payment_subv4_view_model.dart';

PayMentModel _payment({
  required String ptser,
  String? ser,
  String? bno,
  String? bname,
}) {
  final m = PayMentModel();
  m.ser = ser ?? '1';
  m.ptser = ptser;
  m.bno = bno;
  m.bname = bname;
  return m;
}

void main() {
  group('PaymentQrPayload.build', () {
    test('ptser 7 returns the server payload untouched', () {
      expect(
        PaymentQrPayload.build(
          ptser: '7',
          bno: '0843631897',
          amount: 100,
          serverPayload: 'SERVER-PAYLOAD',
        ),
        'SERVER-PAYLOAD',
      );
    });

    test('ptser 7 with no server payload stays empty', () {
      expect(
        PaymentQrPayload.build(ptser: '7', bno: '0843631897', amount: 100),
        isEmpty,
      );
    });

    test('ptser 6 builds the bill payment string', () {
      final payload = PaymentQrPayload.build(
        ptser: '6',
        bno: '0843631897',
        amount: 1234.50,
        ref1: 'REF1',
        ref2: 'REF2',
      );

      // ต้นฉบับ: '|$bno\r$ref1\r$ref2\r${amtRaw.replaceAll('.', '')}'
      expect(payload, '|0843631897\rREF1\rREF2\r123450');
    });

    test('ptser 6 strips the decimal point from the amount', () {
      final payload = PaymentQrPayload.build(
        ptser: '6',
        bno: 'B',
        amount: 100,
        ref1: 'a',
        ref2: 'b',
      );
      // 100.00 → '10000'
      expect(payload.split('\r').last, '10000');
    });

    test('ptser 6 with missing refs still renders empty segments', () {
      final payload = PaymentQrPayload.build(
        ptser: '6',
        bno: 'B',
        amount: 1,
      );
      expect(payload, '|B\r\r\r100');
    });

    test('ptser 5 delegates to generateQRCode', () {
      const bno = '0843631897';
      expect(
        PaymentQrPayload.build(ptser: '5', bno: bno, amount: 250),
        generateQRCode(promptPayID: bno, amount: 250),
      );
    });

    test('ptser 5 ignores a server payload — generates its own', () {
      // ต้นฉบับสร้าง payload เองสำหรับ 5/6/11 แม้ server จะส่ง payload มา
      const bno = '0843631897';
      expect(
        PaymentQrPayload.build(
          ptser: '5',
          bno: bno,
          amount: 250,
          serverPayload: 'SERVER-PAYLOAD',
        ),
        generateQRCode(promptPayID: bno, amount: 250),
      );
    });

    test('ptser 6 ignores a server payload', () {
      expect(
        PaymentQrPayload.build(
          ptser: '6',
          bno: 'B',
          amount: 1,
          ref1: 'a',
          ref2: 'b',
          serverPayload: 'SERVER-PAYLOAD',
        ),
        '|B\ra\rb\r100',
      );
    });

    test('ptser 11 delegates to generateEwalletQRCode', () {
      const bno = '0843631897';
      expect(
        PaymentQrPayload.build(ptser: '11', bno: bno, amount: 250),
        generateEwalletQRCode(promptPayID: bno, amount: 250),
      );
    });

    test('ptser 5 output is a valid EMVCo payload with CRC', () {
      final payload = PaymentQrPayload.build(
        ptser: '5',
        bno: '0843631897',
        amount: 250,
      );
      expect(payload.startsWith('000201'), isTrue);
      expect(payload.contains('A000000677010111'), isTrue);
      expect(payload.length, greaterThan(60));
      // ลงท้ายด้วย tag 63 + length 04 + CRC 4 หลัก
      expect(payload.substring(payload.length - 8, payload.length - 4), '6304');
    });

    test('ptser 5 rejects an unsupported PromptPay ID length', () {
      // generateQRCode คืน '' เมื่อความยาวไม่ใช่ 10/13/15
      expect(
        PaymentQrPayload.build(ptser: '5', bno: '123', amount: 100),
        isEmpty,
      );
    });

    test('ptser 2 (bank transfer) has no generated payload', () {
      expect(
        PaymentQrPayload.build(ptser: '2', bno: '051-5-53800033-3', amount: 100),
        isEmpty,
      );
    });

    test('unknown ptser has no payload', () {
      expect(
        PaymentQrPayload.build(ptser: '99', bno: 'B', amount: 100),
        isEmpty,
      );
    });

    test('ptser is trimmed before matching', () {
      expect(
        PaymentQrPayload.build(
          ptser: ' 7 ',
          bno: 'B',
          amount: 1,
          serverPayload: 'P',
        ),
        'P',
      );
    });
  });

  group('PaymentQrPayload.resolveRef1', () {
    Invoice invoiceWithCid(String? cid) => Invoice(
          billReference: 'INV-1',
          metadata: [Metadata(docno: 'INV-1', cid: cid)],
        );

    test('session value wins', () {
      expect(
        PaymentQrPayload.resolveRef1(
          fromSession: 'FROM-SESSION',
          invoices: [invoiceWithCid('CID-1')],
          customerNo: 'CUST-1',
        ),
        'FROM-SESSION',
      );
    });

    test('falls back to the first invoice metadata cid', () {
      expect(
        PaymentQrPayload.resolveRef1(
          fromSession: '',
          invoices: [invoiceWithCid('CID-1'), invoiceWithCid('CID-2')],
          customerNo: 'CUST-1',
        ),
        'CID-1',
      );
    });

    test('falls back to customerNo when metadata has no cid', () {
      expect(
        PaymentQrPayload.resolveRef1(
          fromSession: '',
          invoices: [invoiceWithCid(null)],
          customerNo: 'CUST-1',
        ),
        'CUST-1',
      );
    });

    test('falls back to customerNo when there are no invoices', () {
      expect(
        PaymentQrPayload.resolveRef1(
          fromSession: '',
          invoices: const [],
          customerNo: 'CUST-1',
        ),
        'CUST-1',
      );
    });

    test('uses the legacy placeholder when nothing is available', () {
      expect(
        PaymentQrPayload.resolveRef1(
          fromSession: '',
          invoices: const [],
          customerNo: null,
        ),
        '-',
      );
    });

    test('blank session value is ignored', () {
      expect(
        PaymentQrPayload.resolveRef1(
          fromSession: '   ',
          invoices: const [],
          customerNo: 'CUST-1',
        ),
        'CUST-1',
      );
    });
  });

  group('PaymentQrPayload.resolveRef2', () {
    test('session value wins', () {
      expect(
        PaymentQrPayload.resolveRef2(
          fromSession: 'FROM-SESSION',
          paymentIntentNo: 'PI-1',
        ),
        'FROM-SESSION',
      );
    });

    test('falls back to paymentIntentNo', () {
      expect(
        PaymentQrPayload.resolveRef2(
          fromSession: '',
          paymentIntentNo: 'PI-1',
        ),
        'PI-1',
      );
    });

    test('uses the legacy placeholder when nothing is available', () {
      expect(
        PaymentQrPayload.resolveRef2(fromSession: '', paymentIntentNo: null),
        '-',
      );
    });
  });

  group('PaymentQrPayload.resolveRef3', () {
    test('has no intent fallback — session only', () {
      expect(PaymentQrPayload.resolveRef3(fromSession: 'R3'), 'R3');
      expect(PaymentQrPayload.resolveRef3(fromSession: ''), '-');
    });
  });

  group('PaymentQrPayload.resolveBno', () {
    test('selected channel bno wins over the intent bno', () {
      expect(
        PaymentQrPayload.resolveBno(
          selectedBno: '0843631897',
          intentBno: '010554605728801',
        ),
        '0843631897',
      );
    });

    test('falls back to the intent bno', () {
      expect(
        PaymentQrPayload.resolveBno(
          selectedBno: null,
          intentBno: '010554605728801',
        ),
        '010554605728801',
      );
    });

    test('uses the legacy placeholder when both are missing', () {
      expect(PaymentQrPayload.resolveBno(selectedBno: '', intentBno: null), '-');
    });
  });

  group('PaymentQrPayload.resolveAmount', () {
    test('prefers the intent requested amount', () {
      expect(
        PaymentQrPayload.resolveAmount(
          intentRequestedAmount: 1040.0,
          fallback: 1100.0,
        ),
        1040.0,
      );
    });

    test('falls back when the intent has no amount', () {
      expect(
        PaymentQrPayload.resolveAmount(
          intentRequestedAmount: null,
          fallback: 1100.0,
        ),
        1100.0,
      );
    });

    test('falls back when the intent amount is zero', () {
      expect(
        PaymentQrPayload.resolveAmount(
          intentRequestedAmount: 0,
          fallback: 1100.0,
        ),
        1100.0,
      );
    });

    test('never returns a negative amount', () {
      expect(
        PaymentQrPayload.resolveAmount(
          intentRequestedAmount: null,
          fallback: -50,
        ),
        0,
      );
    });
  });

  group('PaymentQrPayload.needsPayload', () {
    test('true for channels that render a QR', () {
      for (final ptser in const ['5', '6', '7', '11']) {
        expect(PaymentQrPayload.needsPayload(ptser), isTrue, reason: ptser);
      }
    });

    test('false for bank transfer and unknown channels', () {
      expect(PaymentQrPayload.needsPayload('2'), isFalse);
      expect(PaymentQrPayload.needsPayload('99'), isFalse);
    });
  });

  group('openIntent builds a QR payload for a reopened intent', () {
    PaymentSubV4ViewModel buildVm({required List<PayMentModel> payments}) {
      return PaymentSubV4ViewModel.withState(
        params: const PaymentSubV4Params(
          customerLanguage: 'TH',
          paymentSerial: '1',
        ),
        initialState: PaymentSubV4State(
          pageStatus: PageStatus.ready,
          paymentModels: payments,
          selectedPaymentModel: payments.isEmpty ? null : payments.first,
        ),
      );
    }

    test('promptpay intent gets a real payload instead of a placeholder', () {
      final vm = buildVm(
        payments: [_payment(ptser: '5', ser: '1', bno: '0843631897')],
      );

      vm.openIntent(PaymentIntent(
        intentUuid: 'uuid-1',
        bankmerchantid: 1,
        status: 'รอชำระเงิน',
        requestedAmount: 250,
        ref1: 'R1',
        ref2: 'R2',
      ));

      final qr = vm.state.qrState;
      expect(qr.qrPayload, isNotNull);
      expect(qr.qrPayload, isNotEmpty);
      expect(qr.status, QrStatus.active);
      expect(qr.amount, 250);
      vm.dispose();
    });

    test('amount comes from the intent, not the locally computed summary', () {
      final vm = buildVm(
        payments: [_payment(ptser: '5', ser: '1', bno: '0843631897')],
      );

      vm.openIntent(PaymentIntent(
        intentUuid: 'uuid-1',
        bankmerchantid: 1,
        requestedAmount: 1040,
      ));

      expect(vm.state.qrState.amount, 1040);
      expect(vm.state.summary.grandTotal.toDouble(), 1040);
      vm.dispose();
    });

    test('picks the bank of the intent, not the currently selected one', () {
      final vm = buildVm(payments: [
        _payment(ptser: '5', ser: '1', bno: '0000000001'),
        _payment(ptser: '5', ser: '2', bno: '0843631897'),
      ]);

      vm.openIntent(PaymentIntent(
        intentUuid: 'uuid-2',
        bankmerchantid: 2,
        requestedAmount: 100,
      ));

      // payload ต้องถูกสร้างจากบัญชีของ intent (ser 2)
      expect(
        vm.state.qrState.qrPayload,
        PaymentQrPayload.build(
          ptser: '5',
          bno: '0843631897',
          amount: 100,
        ),
      );
      vm.dispose();
    });

    test('bill payment intent gets refs from the intent, not blanks', () {
      final vm = buildVm(
        payments: [_payment(ptser: '6', ser: '1', bno: '0843631897')],
      );

      vm.openIntent(PaymentIntent(
        intentUuid: 'uuid-6',
        bankmerchantid: 1,
        paymentIntentNo: 'PI-6',
        requestedAmount: 1000,
        status: 'รอชำระเงิน',
        invoices: [
          Invoice(
            billReference: 'INV-6',
            total: 1000,
            metadata: [Metadata(docno: 'INV-6', cid: 'CID-6')],
          ),
        ],
      ));

      final payload = vm.state.qrState.qrPayload!;
      // ref1 จาก metadata.cid, ref2 จาก paymentIntentNo, ยอดตัดจุดทศนิยม
      expect(payload, '|0843631897\rCID-6\rPI-6\r100000');
      expect(vm.state.qrState.ref1, 'CID-6');
      expect(vm.state.qrState.ref2, 'PI-6');
      vm.dispose();
    });

    test('bill payment falls back to customerNo and the placeholder', () {
      final vm = buildVm(
        payments: [_payment(ptser: '6', ser: '1', bno: '0843631897')],
      );

      vm.openIntent(PaymentIntent(
        intentUuid: 'uuid-7',
        bankmerchantid: 1,
        requestedAmount: 100,
        customerNo: 'CUST-7',
      ));

      final payload = vm.state.qrState.qrPayload!;
      // ref1 = customerNo, ref2/ref3 ไม่มี → '-'
      expect(payload, '|0843631897\rCUST-7\r-\r10000');
      expect(vm.state.qrState.ref3, '-');
      vm.dispose();
    });

    test('openIntent without session still shows the ref from the intent', () {
      final vm = buildVm(
        payments: [_payment(ptser: '6', ser: '1', bno: '0843631897')],
      );

      // list response ส่ง ref3 มาตรง ๆ (กรณีที่ไม่มี active_qr_session)
      vm.openIntent(PaymentIntent(
        intentUuid: 'uuid-ref3',
        bankmerchantid: 1,
        requestedAmount: 100,
        ref3: 'REF-FROM-INTENT',
      ));

      expect(vm.state.qrState.ref3, 'REF-FROM-INTENT');
      vm.dispose();
    });

    test('openIntent marks ref3 with the legacy placeholder when absent', () {
      final vm = buildVm(
        payments: [_payment(ptser: '6', ser: '1', bno: '0843631897')],
      );

      vm.openIntent(PaymentIntent(
        intentUuid: 'uuid-no-ref3',
        bankmerchantid: 1,
        requestedAmount: 100,
      ));

      // ไม่มี ref3 ที่ไหนเลย → '-'
      expect(vm.state.qrState.ref3, '-');
      vm.dispose();
    });

    test('bank transfer intent stays without a QR payload', () {
      final vm = buildVm(
        payments: [_payment(ptser: '2', ser: '1', bno: '051-5-53800033-3')],
      );

      vm.openIntent(PaymentIntent(
        intentUuid: 'uuid-3',
        bankmerchantid: 1,
        requestedAmount: 100,
      ));

      expect(vm.state.qrState.qrPayload, isNull);
      expect(vm.state.qrState.status, QrStatus.unavailable);
      vm.dispose();
    });

    test('keeps uuid and expiry so upload still targets the right intent', () {
      final expiry = DateTime.now().add(const Duration(minutes: 5));
      final vm = buildVm(
        payments: [_payment(ptser: '5', ser: '1', bno: '0843631897')],
      );

      vm.openIntent(PaymentIntent(
        intentUuid: 'uuid-4',
        bankmerchantid: 1,
        paymentIntentNo: 'PI-4',
        requestedAmount: 100,
        softExpireAt: expiry,
      ));

      expect(vm.state.uploadTargetUuid, 'uuid-4');
      expect(vm.state.qrState.intentUuid, 'uuid-4');
      expect(vm.state.qrState.paymentIntentNo, 'PI-4');
      expect(vm.state.qrState.billExpireAt, expiry.toIso8601String());
      expect(vm.sessionTotalSecs, greaterThan(0));
      vm.dispose();
    });

    test('unknown bank merchant still hydrates the upload target', () {
      final vm = buildVm(
        payments: [_payment(ptser: '5', ser: '1', bno: '0843631897')],
      );

      vm.openIntent(PaymentIntent(
        intentUuid: 'uuid-5',
        bankmerchantid: 999,
        requestedAmount: 100,
      ));

      expect(vm.state.uploadTargetUuid, 'uuid-5');
      expect(vm.state.qrState.intentUuid, 'uuid-5');
      vm.dispose();
    });
  });
}
