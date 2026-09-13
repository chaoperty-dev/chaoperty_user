import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import 'package:chaoperty_user/Model/GetInvoice_Model.dart';
import 'package:chaoperty_user/Model/GetPayMent_Model.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/payment_subv4_page.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/viewmodels/payment_subv4_view_model.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_bank_summary.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_bottom_action.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_instructions_card.dart';

const _params = PaymentSubV4Params(customerLanguage: 'TH', paymentSerial: '1');

InvoiceModel _inv(String docno, String amtall, {String? dis}) {
  final m = InvoiceModel();
  m.docno = docno;
  m.amtall = amtall;
  m.disendbill = dis;
  return m;
}

PayMentModel _payment({
  required String ptser,
  String? bno,
  String? bname,
  String? co,
  String? remark,
  String? bank,
}) {
  final m = PayMentModel();
  m.ser = '1';
  m.ptser = ptser;
  m.bno = bno;
  m.bname = bname;
  m.co = co;
  m.remark = remark;
  m.bank = bank;
  return m;
}

PaymentQrState _activeQr({String? payload, String? ref3, String? expireAt}) {
  return PaymentQrState(
    status: QrStatus.active,
    intentUuid: 'uuid-1',
    ref1: 'REF-ONE',
    ref3: ref3,
    qrPayload: payload ?? '00020101021229370016A000000677010111',
    softExpireAt: expireAt,
    secondsRemaining: 120,
  );
}

Widget _wrap(PaymentSubV4State state) {
  final vm = PaymentSubV4ViewModel.withState(
    params: _params,
    initialState: state,
  );
  return MaterialApp(
    home: PaymentSubV4Page(
      cuslang: 'TH',
      serPayment: '1',
      viewModelOverride: vm,
    ),
  );
}

void main() {
  group('PaymentSubV4Page rendering by state', () {
    testWidgets('loading state shows only a progress indicator',
        (tester) async {
      await tester.pumpWidget(_wrap(const PaymentSubV4State(
        pageStatus: PageStatus.loading,
      )));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('การชำระเงิน'), findsNothing);
    });

    testWidgets('error state shows the error message', (tester) async {
      await tester.pumpWidget(_wrap(const PaymentSubV4State(
        pageStatus: PageStatus.error,
        errorMessage: 'โหลดไม่สำเร็จ',
      )));
      await tester.pump();

      expect(find.text('โหลดไม่สำเร็จ'), findsOneWidget);
    });

    testWidgets('ready state shows header and all three tabs', (tester) async {
      await tester.pumpWidget(_wrap(const PaymentSubV4State(
        pageStatus: PageStatus.ready,
      )));
      await tester.pump();

      expect(find.text('การชำระเงิน'), findsOneWidget);
      expect(find.text('ที่ต้องชำระ'), findsOneWidget);
      expect(find.text('รอแนบสลิป'), findsOneWidget);
      expect(find.text('รอระบบตรวจสอบ'), findsOneWidget);
    });

    testWidgets('header exposes help and status affordances', (tester) async {
      await tester.pumpWidget(_wrap(const PaymentSubV4State(
        pageStatus: PageStatus.ready,
      )));
      await tester.pump();

      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('tab badges show the intent counts', (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        paymentIntents: [
          PaymentIntent(status: 'รอชำระเงิน'),
          PaymentIntent(status: 'รอชำระเงิน'),
          PaymentIntent(status: 'รอการตรวจสอบ'),
        ],
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('empty payable tab shows the empty message', (tester) async {
      await tester.pumpWidget(_wrap(const PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: 1,
      )));
      await tester.pump();

      expect(find.text('ไม่มีรายการที่ต้องชำระ'), findsOneWidget);
    });

    testWidgets('invoice row shows docno and net amount', (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: 1,
        invoices: [_inv('INV-001', '1000.00', dis: '100.00')],
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.text('INV-001'), findsOneWidget);
      expect(find.text('฿900.00'), findsOneWidget);
    });

    testWidgets('bottom action hidden when there are no invoices',
        (tester) async {
      await tester.pumpWidget(_wrap(const PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: 1,
      )));
      await tester.pump();

      expect(find.textContaining('เริ่มการชำระ'), findsNothing);
    });

    testWidgets('bottom action shows start label before a payment exists',
        (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: 1,
        selectedPaymentModel: _payment(ptser: '5', bno: '0843631897'),
        invoices: [_inv('INV-001', '500.00')],
        summary: const PaymentSummary(grandTotal: Money(50000)),
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.textContaining('เริ่มการชำระ'), findsOneWidget);
      expect(find.text('ยอดรวมที่ต้องโอน'), findsOneWidget);
      expect(find.text('รอสลิปยืนยัน'), findsOneWidget);
    });

    testWidgets('bottom action switches label when payment is active',
        (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: 1,
        selectedPaymentModel: _payment(ptser: '5', bno: '0843631897'),
        invoices: [_inv('INV-001', '500.00')],
        summary: const PaymentSummary(grandTotal: Money(50000)),
        qrState: _activeQr(),
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      // scope ที่ CTA เพราะข้อความเดียวกันปรากฏใน instructions card ด้วย
      expect(
        find.descendant(
          of: find.byType(PaymentSubV4BottomAction),
          matching: find.textContaining('แนบหลักฐานและยืนยัน'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('countdown alert renders remaining time', (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedPaymentModel: _payment(ptser: '5', bno: '0843631897'),
        qrState: _activeQr().copyWith(secondsRemaining: 65),
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.text('QR ใช้ได้อีกภายใน'), findsOneWidget);
      expect(find.text('01:05'), findsOneWidget);
    });

    testWidgets('countdown alert reports expiry', (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedPaymentModel: _payment(ptser: '5', bno: '0843631897'),
        qrState: _activeQr().copyWith(
          secondsRemaining: 0,
          isSessionExpired: true,
        ),
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      // "QR หมดอายุแล้ว" ปรากฏทั้งใน countdown alert และ overlay บน QR
      expect(find.text('QR หมดอายุแล้ว'), findsNWidgets(2));
      expect(find.byIcon(Icons.timer_off_rounded), findsWidgets);
      expect(find.text('--:--'), findsOneWidget);
    });

    testWidgets('section errors show a retry banner', (tester) async {
      await tester.pumpWidget(_wrap(const PaymentSubV4State(
        pageStatus: PageStatus.ready,
        sectionErrors: ['โหลดใบแจ้งหนี้ไม่สำเร็จ'],
      )));
      await tester.pump();

      expect(find.text('โหลดใบแจ้งหนี้ไม่สำเร็จ'), findsOneWidget);
      expect(find.text('ลองใหม่'), findsOneWidget);
    });

    testWidgets('no error banner when there are no section errors',
        (tester) async {
      await tester.pumpWidget(_wrap(const PaymentSubV4State(
        pageStatus: PageStatus.ready,
      )));
      await tester.pump();

      expect(find.text('ลองใหม่'), findsNothing);
    });

    testWidgets('English locale renders English labels', (tester) async {
      final vm = PaymentSubV4ViewModel.withState(
        params: const PaymentSubV4Params(customerLanguage: 'EN'),
        initialState: const PaymentSubV4State(pageStatus: PageStatus.ready),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PaymentSubV4Page(cuslang: 'EN', viewModelOverride: vm),
        ),
      );
      await tester.pump();

      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('To pay'), findsOneWidget);
    });

    testWidgets('tab 2 lists awaiting-slip intents', (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: 2,
        paymentIntents: [
          PaymentIntent(
            status: 'รอชำระเงิน',
            paymentIntentNo: 'PI-777',
            amount: 250.0,
          ),
        ],
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.text('#PI-777'), findsOneWidget);
    });

    testWidgets('tab 3 empty message when nothing awaits verification',
        (tester) async {
      await tester.pumpWidget(_wrap(const PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: 3,
      )));
      await tester.pump();

      expect(find.text('ไม่มีรายการรอระบบตรวจสอบ'), findsOneWidget);
    });

    testWidgets('instructions card renders four numbered steps',
        (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: 1,
        invoices: [_inv('INV-001', '500.00')],
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.text('วิธีชำระเงินง่ายๆ 4 ขั้นตอน'), findsOneWidget);

      final card = find.byType(PaymentSubV4InstructionsCard);
      expect(card, findsOneWidget);

      for (final n in ['1', '2', '3', '4']) {
        expect(
          find.descendant(of: card, matching: find.text(n)),
          findsOneWidget,
          reason: 'step $n should appear exactly once inside the card',
        );
      }
    });
  });

  group('channel variants', () {
    testWidgets('bank transfer channel renders no QR widget', (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedPaymentModel: _payment(
          ptser: '2',
          bno: '051-5-53800033-3',
          bname: 'บริษัท ทดสอบ จำกัด',
          co: 'น.ส. กิตติธร ทดสอบ',
          remark: 'โอนแล้วแนบสลิป',
          bank: 'ธนาคารออมสิน',
        ),
        summary: const PaymentSummary(grandTotal: Money(100000)),
        qrState: const PaymentQrState(
          status: QrStatus.unavailable,
          intentUuid: 'uuid-bank',
          ref3: 'REF-BANK',
          softExpireAt: '2026-09-08T08:45:00Z',
        ),
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.byType(PrettyQrView), findsNothing);
      expect(find.text('บันทึกภาพ QR Code ลงเครื่อง'), findsNothing);
      expect(find.text('051-5-53800033-3'), findsOneWidget);
      expect(find.text('บริษัท ทดสอบ จำกัด'), findsOneWidget);
      expect(find.text('น.ส. กิตติธร ทดสอบ'), findsOneWidget);
      expect(find.text('คัดลอก'), findsOneWidget);
      expect(find.text('คัดลอกยอดเงิน'), findsOneWidget);
      expect(find.textContaining('โอนแล้วแนบสลิป'), findsOneWidget);
    });

    testWidgets('bank transfer channel shows bank header and ref/expiry',
        (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedPaymentModel: _payment(
          ptser: '2',
          bno: '051-5-53800033-3',
          bname: 'บริษัท ทดสอบ จำกัด',
          bank: 'ธนาคารออมสิน',
        ),
        summary: const PaymentSummary(grandTotal: Money(100000)),
        qrState: const PaymentQrState(
          status: QrStatus.unavailable,
          intentUuid: 'uuid-bank',
          ref3: 'REF-BANK',
          softExpireAt: '2026-09-08T08:45:00Z',
        ),
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.text('ธนาคารปลายทาง'), findsOneWidget);
      expect(find.textContaining('ออมสิน'), findsOneWidget);
      expect(find.textContaining('REF-BANK'), findsOneWidget);
      expect(
        find.textContaining('หมดอายุ: '),
        findsOneWidget,
        reason: 'ref/expiry footer must render an explicit expiry line',
      );
    });

    testWidgets('QR channel renders QR widget and save action', (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedPaymentModel: _payment(
          ptser: '5',
          bno: '0843631897',
          bname: 'ร้านค้าทดสอบ',
          bank: 'ธนาคารกสิกรไทย',
        ),
        summary: const PaymentSummary(grandTotal: Money(100000)),
        qrState: _activeQr(ref3: 'REF-QR'),
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.byType(PrettyQrView), findsOneWidget);
      expect(find.text('บันทึกภาพ QR Code ลงเครื่อง'), findsOneWidget);
      expect(find.text('ยอดเงินที่ต้องชำระ'), findsOneWidget);
      expect(find.text('ผู้รับเงิน / Merchant'), findsOneWidget);
      expect(find.text('คัดลอกยอดเงิน'), findsNothing);
    });

    testWidgets('tab 2 keeps bank summary so a reopened page still shows data',
        (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: 2,
        selectedPaymentModel: _payment(
          ptser: '5',
          bno: '0843631897',
          bname: 'ร้านค้าทดสอบ',
          bank: 'ธนาคารกสิกรไทย',
        ),
        paymentIntents: [PaymentIntent(status: 'รอชำระเงิน', amount: 250.0)],
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.byType(PaymentSubV4BankSummary), findsOneWidget);
      expect(find.text('0843631897'), findsOneWidget);
      expect(find.textContaining('กสิกรไทย'), findsWidgets);
    });

    testWidgets('tab 3 keeps bank summary too', (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: 3,
        selectedPaymentModel: _payment(
          ptser: '2',
          bno: '051-5-53800033-3',
          bname: 'บริษัท ทดสอบ จำกัด',
          bank: 'ธนาคารออมสิน',
        ),
        paymentIntents: [PaymentIntent(status: 'รอการตรวจสอบ')],
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.byType(PaymentSubV4BankSummary), findsOneWidget);
      expect(find.text('051-5-53800033-3'), findsOneWidget);
    });

    testWidgets('countdown alert only renders on tab 1', (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: 2,
        selectedPaymentModel: _payment(ptser: '5', bno: '0843631897'),
        paymentIntents: [PaymentIntent(status: 'รอชำระเงิน')],
        qrState: _activeQr().copyWith(secondsRemaining: 90),
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.text('QR ใช้ได้อีกภายใน'), findsNothing);
    });
  });

  group('intent card actions', () {
    Future<void> pumpTab(
      WidgetTester tester, {
      required int tab,
      required List<PaymentIntent> intents,
    }) async {
      await tester.pumpWidget(_wrap(PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: tab,
        selectedPaymentModel: _payment(ptser: '5', bno: '0843631897'),
        paymentIntents: intents,
      )));
      await tester.pump();
    }

    testWidgets('awaiting slip intent shows the attach-proof button',
        (tester) async {
      await pumpTab(
        tester,
        tab: 2,
        intents: [PaymentIntent(status: 'รอชำระเงิน', amount: 500)],
      );

      expect(find.text('กดเพื่อแนบหลักฐาน'), findsOneWidget);
    });

    testWidgets('awaiting verification without slip shows view-proof button',
        (tester) async {
      await pumpTab(
        tester,
        tab: 3,
        intents: [PaymentIntent(status: 'รอการตรวจสอบ', amount: 500)],
      );

      expect(find.text('กดเพื่อดูหลักฐาน'), findsOneWidget);
    });

    testWidgets('verified intent that already has a slip hides the button',
        (tester) async {
      await pumpTab(
        tester,
        tab: 3,
        intents: [
          PaymentIntent(
            status: 'รอการตรวจสอบ',
            systemStatus: 'slip_uploaded',
            amount: 500,
          ),
        ],
      );

      expect(find.text('กดเพื่อดูหลักฐาน'), findsNothing);
      expect(find.text('กดเพื่อแนบหลักฐาน'), findsNothing);
    });

    testWidgets('tab 3 marks invoices as slip attached', (tester) async {
      await pumpTab(
        tester,
        tab: 3,
        intents: [
          PaymentIntent(
            status: 'รอการตรวจสอบ',
            amount: 500,
            invoices: [Invoice(billReference: 'INV-9', total: 500)],
          ),
        ],
      );

      await tester.tap(find.text('#-'));
      await tester.pumpAndSettle();

      expect(find.text('แนบหลักฐานแล้ว'), findsOneWidget);
      expect(find.text('INV-9'), findsOneWidget);
      expect(find.textContaining('หมายเหตุ:'), findsOneWidget);
    });

    testWidgets('tab 2 does not mark invoices as slip attached',
        (tester) async {
      await pumpTab(
        tester,
        tab: 2,
        intents: [
          PaymentIntent(
            status: 'รอชำระเงิน',
            amount: 500,
            invoices: [Invoice(billReference: 'INV-9', total: 500)],
          ),
        ],
      );

      await tester.tap(find.text('#-'));
      await tester.pumpAndSettle();

      expect(find.text('แนบหลักฐานแล้ว'), findsNothing);
      expect(find.text('INV-9'), findsOneWidget);
    });
  });

  group('openIntent restore', () {
    test('hydrates refs, expiry and amount from the intent', () {
      final vm = PaymentSubV4ViewModel.withState(
        params: _params,
        initialState: const PaymentSubV4State(pageStatus: PageStatus.ready),
      );

      final intent = PaymentIntent(
        status: 'รอชำระเงิน',
        intentUuid: 'uuid-restored',
        paymentIntentNo: 'PI-RESTORE',
        amount: 1234.5,
        ref1: 'REF-1',
        ref2: 'REF-2',
        ref3: 'REF-3',
        softExpireAt: DateTime.now().add(const Duration(minutes: 5)),
      );

      vm.openIntent(intent);
      final state = vm.state;

      expect(state.uploadTargetUuid, 'uuid-restored');
      expect(state.uploadTargetAmount?.toDouble(), 1234.5);
      expect(state.qrState.intentUuid, 'uuid-restored');
      expect(state.qrState.paymentIntentNo, 'PI-RESTORE');
      expect(state.qrState.ref1, 'REF-1');
      expect(state.qrState.ref2, 'REF-2');
      expect(state.qrState.ref3, 'REF-3');
      expect(state.qrState.softExpireAt, isNotNull);
      expect(state.summary.grandTotal.toDouble(), 1234.5);
      expect(vm.sessionTotalSecs, greaterThan(0));
      vm.dispose();
    });

    test('ignores an intent without uuid', () {
      final vm = PaymentSubV4ViewModel.withState(
        params: _params,
        initialState: const PaymentSubV4State(pageStatus: PageStatus.ready),
      );

      vm.openIntent(PaymentIntent(status: 'รอชำระเงิน'));

      expect(vm.state.uploadTargetUuid, isNull);
      expect(vm.state.qrState.intentUuid, isNull);
      vm.dispose();
    });
  });
}
