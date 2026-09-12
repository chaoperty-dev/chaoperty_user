import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chaoperty_user/Model/GetInvoice_Model.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/payment_subv4_page.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/viewmodels/payment_subv4_view_model.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_instructions_card.dart';

const _params = PaymentSubV4Params(customerLanguage: 'TH', paymentSerial: '1');

InvoiceModel _inv(String docno, String amtall, {String? dis}) {
  final m = InvoiceModel();
  m.docno = docno;
  m.amtall = amtall;
  m.disendbill = dis;
  return m;
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
    testWidgets('loading state shows only a progress indicator', (tester) async {
      await tester.pumpWidget(_wrap(const PaymentSubV4State(
        pageStatus: PageStatus.loading,
      )));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('การชำระ'), findsNothing);
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

      expect(find.text('การชำระ'), findsOneWidget);
      expect(find.text('ที่ต้องชำระ'), findsOneWidget);
      expect(find.text('รอแนบหลักฐาน'), findsOneWidget);
      expect(find.text('รอระบบตรวจสอบ'), findsOneWidget);
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

      // 2 รอแนบหลักฐาน, 1 รอตรวจสอบ
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
      // net = 1000 - 100 = 900
      expect(find.text('฿900.00'), findsOneWidget);
    });

    testWidgets('bottom action is hidden when there are no invoices',
        (tester) async {
      await tester.pumpWidget(_wrap(const PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: 1,
      )));
      await tester.pump();

      expect(find.textContaining('เริ่มการชำระ'), findsNothing);
    });

    testWidgets('bottom action shows start label before a QR exists',
        (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: 1,
        invoices: [_inv('INV-001', '500.00')],
        summary: const PaymentSummary(grandTotal: Money(50000)),
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.textContaining('เริ่มการชำระ'), findsOneWidget);
    });

    testWidgets('bottom action switches label when a QR is active',
        (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: 1,
        invoices: [_inv('INV-001', '500.00')],
        summary: const PaymentSummary(grandTotal: Money(50000)),
        qrState: const PaymentQrState(
          status: QrStatus.active,
          intentUuid: 'uuid-1',
          qrPayload: '00020101021229',
          secondsRemaining: 120,
        ),
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.textContaining('แนบหลักฐานและยืนยัน'), findsOneWidget);
    });

    testWidgets('countdown bar is shown when a QR is active', (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        qrState: const PaymentQrState(
          status: QrStatus.active,
          intentUuid: 'uuid-1',
          secondsRemaining: 65,
        ),
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.textContaining('QR ใช้ได้อีก'), findsOneWidget);
      expect(find.textContaining('00:01:05'), findsOneWidget);
    });

    testWidgets('countdown bar reports expiry when the session ended',
        (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        qrState: const PaymentQrState(
          status: QrStatus.active,
          intentUuid: 'uuid-1',
          secondsRemaining: 0,
          isSessionExpired: true,
        ),
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.text('QR หมดอายุแล้ว'), findsOneWidget);
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
        MaterialApp(home: PaymentSubV4Page(cuslang: 'EN', viewModelOverride: vm)),
      );
      await tester.pump();

      expect(find.text('Payment'), findsOneWidget);
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

      // scope ให้อยู่ใน instructions card เท่านั้น
      // เพราะเลขขั้นตอนชนกับ badge ของแท็บได้ (เช่น "1" ของ "ที่ต้องชำระ")
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
}
