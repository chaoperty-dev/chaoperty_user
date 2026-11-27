import 'dart:async';
import 'dart:typed_data';

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
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_dialogs.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_header.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_intent_card.dart';

const _params = PaymentSubV4Params(customerLanguage: 'TH', paymentSerial: '1');

InvoiceModel _inv(String docno, String amtall, {String? dis, String? totalBill}) {
  final m = InvoiceModel();
  m.docno = docno;
  m.amtall = amtall;
  m.disendbill = dis;
  m.total_bill = totalBill;
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

/// หน้าเพจเด้ง dialog "ประกาศสำคัญสำหรับผู้เช่า" ครั้งแรกที่ state พร้อม
/// (เหมือนต้นฉบับ, barrierDismissible: false) — ปิดก่อนเพื่อให้เทสต์แตะ widget อื่นได้
///
/// dialog นี้ไม่มีปุ่มปิด ต้องลาก handle ที่มีไอคอนลูกศรไปทางขวาจนสุด
Future<void> dismissAttachNotice(WidgetTester tester) async {
  final title = find.text('ประกาศสำคัญสำหรับผู้เช่า');
  if (title.evaluate().isEmpty) return;

  final handle = find.descendant(
    of: find.ancestor(of: title, matching: find.byType(Dialog)),
    matching: find.byIcon(Icons.arrow_forward_rounded),
  );
  if (handle.evaluate().isEmpty) return;

  await tester.drag(handle.first, const Offset(700, 0));
  await tester.pumpAndSettle();
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

    testWidgets('header keeps title inside its bounds with top safe padding',
        (tester) async {
      tester.view.padding = const FakeViewPadding(
        top: 32,
        bottom: 0,
        left: 0,
        right: 0,
      );
      addTearDown(tester.view.resetPadding);

      await tester.pumpWidget(_wrap(const PaymentSubV4State(
        pageStatus: PageStatus.ready,
      )));
      await tester.pump();
      await dismissAttachNotice(tester);

      final header = find.byType(PaymentSubV4Header);
      expect(header, findsOneWidget);
      final headerBox = tester.renderObject<RenderBox>(header);
      final titleBox = tester.renderObject<RenderBox>(find.text('การชำระเงิน'));
      final titleTop = titleBox.localToGlobal(Offset.zero).dy;
      final titleBottom = titleTop + titleBox.size.height;
      final headerTop = headerBox.localToGlobal(Offset.zero).dy;
      final headerBottom = headerTop + headerBox.size.height;

      expect(titleTop, greaterThanOrEqualTo(headerTop));
      expect(titleBottom, lessThanOrEqualTo(headerBottom));
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

    testWidgets('invoice row shows total_bill, not the API-only amtall',
        (tester) async {
      // amtall (205.61) คือยอดก่อน VAT ที่ใช้ส่ง API; total_bill (220.00) คือยอดที่แสดง
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: 1,
        invoices: [_inv('INV-VAT', '205.61', totalBill: '220.00')],
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();
      await dismissAttachNotice(tester);

      expect(find.text('฿220.00'), findsOneWidget);
      expect(find.text('฿205.61'), findsNothing);
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

      expect(find.text('กดเพื่อชำระ'), findsOneWidget);
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

    testWidgets('bottom action shows the server amount when an intent exists',
        (tester) async {
      // summary กับยอดของ intent ต่างกัน (เคสมีส่วนลด) — ต้องแสดงยอดของ intent
      // เพราะเป็นยอดเดียวกับที่ QR สแกนได้
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedTab: 1,
        selectedPaymentModel: _payment(ptser: '5', bno: '0843631897'),
        invoices: [_inv('INV-001', '1100.00', dis: '100.00')],
        summary: const PaymentSummary(grandTotal: Money(110000)),
        qrState: PaymentQrState(
          status: QrStatus.active,
          intentUuid: 'uuid-1',
          qrPayload: 'PAYLOAD',
          amount: 1000,
        ),
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();
      await dismissAttachNotice(tester);

      final cta = find.byType(PaymentSubV4BottomAction);
      expect(cta, findsOneWidget);
      // ยอดของ intent = 1,000.00 ไม่ใช่ summary 1,100.00
      expect(
        find.descendant(of: cta, matching: find.text('฿1,000.00')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: cta, matching: find.text('฿1,100.00')),
        findsNothing,
      );
    });

    testWidgets('bottom action falls back to the summary amount beforehand',
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
      await dismissAttachNotice(tester);

      expect(
        find.descendant(
          of: find.byType(PaymentSubV4BottomAction),
          matching: find.text('฿500.00'),
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
      expect(find.text('คัดลอก'), findsOneWidget);
      expect(find.text('คัดลอกยอดเงิน'), findsOneWidget);
      expect(find.textContaining('โอนแล้วแนบสลิป'), findsOneWidget);
    });

    testWidgets('payee name comes from bname only, never bnameEn or co',
        (tester) async {
      // ต้นฉบับใช้ payment_bname = PayMentModel.bname เท่านั้น
      // bnameEn ใช้ส่ง API และ co ไม่ถูกแสดงผลเลย
      final payment = _payment(
        ptser: '2',
        bno: '051-5-53800033-3',
        bname: 'ชื่อไทยเท่านั้น',
        bank: 'ธนาคารออมสิน',
      );
      payment.bnameEn = 'ENGLISH-NAME-MUST-NOT-SHOW';
      payment.co = 'CO-NAME-MUST-NOT-SHOW';

      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedPaymentModel: payment,
        summary: const PaymentSummary(grandTotal: Money(100000)),
        qrState: const PaymentQrState(
          status: QrStatus.unavailable,
          intentUuid: 'uuid-payee',
          ref3: 'REF-1',
        ),
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();
      await dismissAttachNotice(tester);

      expect(find.text('ชื่อไทยเท่านั้น'), findsWidgets);
      expect(find.textContaining('ENGLISH-NAME-MUST-NOT-SHOW'), findsNothing);
      expect(find.textContaining('CO-NAME-MUST-NOT-SHOW'), findsNothing);
    });

    testWidgets('payee name stays Thai even in the English locale',
        (tester) async {
      final payment = _payment(
        ptser: '2',
        bno: '051-5-53800033-3',
        bname: 'ชื่อไทยเท่านั้น',
        bank: 'ธนาคารออมสิน',
      );
      payment.bnameEn = 'ENGLISH-NAME-MUST-NOT-SHOW';

      final vm = PaymentSubV4ViewModel.withState(
        params: const PaymentSubV4Params(customerLanguage: 'EN'),
        initialState: PaymentSubV4State(
          pageStatus: PageStatus.ready,
          selectedPaymentModel: payment,
          summary: const PaymentSummary(grandTotal: Money(100000)),
          qrState: const PaymentQrState(
            status: QrStatus.unavailable,
            intentUuid: 'uuid-payee-en',
            ref3: 'REF-1',
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PaymentSubV4Page(cuslang: 'EN', viewModelOverride: vm),
        ),
      );
      await tester.pump();
      await dismissAttachNotice(tester);

      expect(find.text('ชื่อไทยเท่านั้น'), findsWidgets);
      expect(find.textContaining('ENGLISH-NAME-MUST-NOT-SHOW'), findsNothing);
    });

    testWidgets('reference footer shows ref3, never falls back to ref1',
        (tester) async {
      // ref1 = cid/customerNo ไม่ใช่เลขอ้างอิงการโอน — ต้นฉบับแสดงแค่ ref3
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedPaymentModel: _payment(ptser: '6', bno: '0843631897'),
        summary: const PaymentSummary(grandTotal: Money(100000)),
        qrState: PaymentQrState(
          status: QrStatus.active,
          intentUuid: 'uuid-ref',
          ref1: 'CID-SHOULD-NOT-SHOW',
          ref2: 'PI-SHOULD-NOT-SHOW',
          ref3: 'REF-THREE',
          qrPayload: 'PAYLOAD',
          softExpireAt: '2026-09-20T08:45:00Z',
        ),
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();
      await dismissAttachNotice(tester);

      expect(find.textContaining('REF-THREE'), findsOneWidget);
      expect(find.textContaining('CID-SHOULD-NOT-SHOW'), findsNothing);
      expect(find.textContaining('PI-SHOULD-NOT-SHOW'), findsNothing);
    });

    testWidgets('reference footer shows the placeholder when ref3 is empty',
        (tester) async {
      final state = PaymentSubV4State(
        pageStatus: PageStatus.ready,
        selectedPaymentModel: _payment(ptser: '6', bno: '0843631897'),
        summary: const PaymentSummary(grandTotal: Money(100000)),
        qrState: const PaymentQrState(
          status: QrStatus.active,
          intentUuid: 'uuid-ref2',
          ref1: 'CID-ONLY',
          ref3: '-',
          qrPayload: 'PAYLOAD',
        ),
      );

      await tester.pumpWidget(_wrap(state));
      await tester.pump();
      await dismissAttachNotice(tester);

      // ref1 มีค่า แต่ต้องไม่ถูกนำมาแสดงแทน ref3
      expect(find.textContaining('CID-ONLY'), findsNothing);
      expect(find.textContaining('Ref: -'), findsOneWidget);
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
      await dismissAttachNotice(tester);
    }

    /// กางการ์ด intent ใบแรกออก
    ///
    /// ต้อง scope ที่ [PaymentSubV4IntentCard] เพราะการ์ดสรุปธนาคาร
    /// ก็ใช้ ExpansionTile เหมือนกัน (โครงเดียวกับต้นฉบับ)
    Future<void> expandFirstCard(WidgetTester tester) async {
      final tile = find
          .descendant(
            of: find.byType(PaymentSubV4IntentCard).first,
            matching: find.byType(ExpansionTile),
          )
          .first;
      await tester.ensureVisible(tile);
      await tester.tap(tile);
      await tester.pumpAndSettle();
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

    testWidgets('exact verification status hides the action button',
        (tester) async {
      // ต้นฉบับ: isWaitingCheck เทียบตรงตัวกับ 'รอตรวจสอบ'/'รอการตรวจสอบ'
      // เมื่อเข้าเงื่อนไขนี้ + เป็นสถานะรอตรวจ → ไม่แสดงปุ่มเลย
      await pumpTab(
        tester,
        tab: 3,
        intents: [PaymentIntent(status: 'รอการตรวจสอบ', amount: 500)],
      );

      expect(find.text('กดเพื่อดูหลักฐาน'), findsNothing);
      expect(find.text('กดเพื่อแนบหลักฐาน'), findsNothing);
      expect(find.text('หลักฐานการชำระ'), findsNothing);
    });

    testWidgets('verification wording without exact match shows view-proof',
        (tester) async {
      // status ที่มีคำว่า ตรวจ แต่ไม่ตรงกับข้อความที่ต้นฉบับเช็คตรงตัว
      // → showSlipAction = false และ _isAwaitingVerifyStatus = true
      await pumpTab(
        tester,
        tab: 3,
        intents: [PaymentIntent(status: 'รอตรวจสอบการชำระ', amount: 500)],
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

    testWidgets('uploaded slip on a non-verify status shows payment proof',
        (tester) async {
      await pumpTab(
        tester,
        tab: 2,
        intents: [
          PaymentIntent(
            status: 'รอชำระเงิน',
            systemStatus: 'slip_uploaded',
            amount: 500,
          ),
        ],
      );

      expect(find.text('หลักฐานการชำระ'), findsOneWidget);
    });

    testWidgets('card shows intent no, amount, expiry and bill count',
        (tester) async {
      await pumpTab(
        tester,
        tab: 2,
        intents: [
          PaymentIntent(
            status: 'รอชำระเงิน',
            paymentIntentNo: 'PI-555',
            amount: 1234.5,
            softExpireAt: DateTime(2026, 9, 20, 15, 30),
            invoices: [Invoice(billReference: 'INV-9', total: 500)],
          ),
        ],
      );

      expect(find.text('#PI-555'), findsOneWidget);
      expect(find.text('฿1,234.50'), findsOneWidget);
      expect(find.textContaining('หมดอายุ '), findsOneWidget);
      expect(find.text('1 บิล'), findsOneWidget);
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

      await expandFirstCard(tester);

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

      await expandFirstCard(tester);

      expect(find.text('แนบหลักฐานแล้ว'), findsNothing);
      expect(find.text('INV-9'), findsOneWidget);
    });

    testWidgets('card shows the per-invoice fine chip when late fee exists',
        (tester) async {
      await pumpTab(
        tester,
        tab: 2,
        intents: [
          PaymentIntent(
            status: 'รอชำระเงิน',
            amount: 500,
            invoices: [
              Invoice(
                billReference: 'INV-9',
                total: 500,
                lateFee: 25,
                metadata: [
                  Metadata(docno: 'INV-9', date: '2026-01-15'),
                ],
              ),
            ],
          ),
        ],
      );

      await expandFirstCard(tester);

      expect(find.text('ค่าปรับ: 25.00'), findsOneWidget);
      expect(find.text('15-01-2026'), findsOneWidget);
    });
  });

  group('legacy slip dialogs', () {
    /// เปิด dialog/sheet แล้วรอให้แสดง
    ///
    /// ห้าม await future ที่ dialog คืนมา เพราะจะค้างจนผู้ใช้ปิด
    /// และห้ามใช้ pumpAndSettle กับ dialog ที่มี CircularProgressIndicator
    /// เพราะอนิเมชันวนไม่จบ → ใช้ [settle] = false แทน
    Future<void> showSheet(
      WidgetTester tester,
      Future<void> Function(BuildContext) open, {
      bool settle = true,
    }) async {
      late BuildContext captured;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (ctx) {
          captured = ctx;
          return const Scaffold(body: SizedBox.shrink());
        }),
      ));

      unawaited(open(captured));
      if (settle) {
        await tester.pumpAndSettle();
      } else {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
      }
    }

    testWidgets('attach sheet shows guidance, amount and disabled slider',
        (tester) async {
      await showSheet(
        tester,
        (ctx) => PaymentSubV4Dialogs.showAttachSlipSheet(
          ctx,
          isEn: false,
          summary: const PaymentSummary(grandTotal: Money(150000)),
          slip: const PaymentSlipState(),
          onPickSlip: () async {},
          onConfirm: () async {},
        ),
      );

      expect(find.text('ยืนยันการชำระเงิน'), findsOneWidget);
      expect(find.text('อัปโหลดสลิป'), findsOneWidget);
      expect(find.text('จำเป็น'), findsOneWidget);
      expect(find.text('กดเพื่ออัปโหลดสลิป'), findsOneWidget);
      expect(find.text('จำนวนที่ต้องชำระ'), findsOneWidget);
      expect(find.text('1,500.00'), findsOneWidget);
      expect(find.text('เลื่อนเพื่อยืนยันการชำระเงิน'), findsOneWidget);
    });

    testWidgets('attach sheet shows the expired-order chip when bill is dead',
        (tester) async {
      await showSheet(
        tester,
        (ctx) => PaymentSubV4Dialogs.showAttachSlipSheet(
          ctx,
          isEn: false,
          summary: const PaymentSummary(grandTotal: Money(100)),
          slip: const PaymentSlipState(),
          billDead: true,
          onCancelPayment: () {},
          onPickSlip: () async {},
          onConfirm: () async {},
        ),
      );

      expect(find.text('รายการ หมดอายุ - ยกเลิกรายการ'), findsOneWidget);
    });

    testWidgets('attach sheet shows the bank-transfer shortcut label',
        (tester) async {
      await showSheet(
        tester,
        (ctx) => PaymentSubV4Dialogs.showAttachSlipSheet(
          ctx,
          isEn: false,
          summary: const PaymentSummary(grandTotal: Money(100)),
          slip: const PaymentSlipState(),
          isBankTransfer: true,
          onShowQr: () {},
          onPickSlip: () async {},
          onConfirm: () async {},
        ),
      );

      expect(find.text('แสดงหมายเลขบัญชี'), findsOneWidget);
    });

    testWidgets('attached slip sheet lists the legacy slip fields',
        (tester) async {
      await showSheet(
        tester,
        (ctx) => PaymentSubV4Dialogs.showAttachedSlipSheet(
          ctx,
          isEn: false,
          slip: const PaymentSlipInfo(
            slipNo: 'SLIP-1',
            originalFilename: 'slip.jpg',
            amount: '1,500.00',
            currency: 'THB',
            transferDate: '2026-01-15',
            transferRefNo: 'REF-9',
            status: 'PENDING',
          ),
          onReattach: () async {},
          onViewSlip: () async {},
        ),
      );

      expect(find.text('อัปโหลดเรียบร้อยแล้ว'), findsOneWidget);
      expect(find.text('ไฟล์:'), findsOneWidget);
      expect(find.text('slip.jpg'), findsOneWidget);
      expect(find.text('1,500.00 THB'), findsOneWidget);
      expect(find.text('2026-01-15'), findsOneWidget);
      expect(find.text('REF-9'), findsOneWidget);
      expect(find.text('รอตรวจสอบ'), findsOneWidget);
      expect(find.text('แนบอีกครั้ง'), findsOneWidget);
      expect(find.text('ดูหลักฐาน'), findsOneWidget);
    });

    testWidgets('preview dialog shows a spinner while the loader is pending',
        (tester) async {
      final completer = Completer<Uint8List?>();

      await showSheet(
        tester,
        (ctx) => PaymentSubV4Dialogs.showSlipPreview(
          ctx,
          isEn: false,
          loader: () => completer.future,
        ),
        settle: false,
      );

      expect(find.text('หลักฐานการโอนเงิน'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // ปล่อย loader ให้จบ เพื่อไม่ให้ timer ค้างตอนจบเทสต์
      completer.complete(null);
      await tester.pumpAndSettle();
    });

    testWidgets('preview dialog falls back to an error state when loader fails',
        (tester) async {
      await showSheet(
        tester,
        (ctx) => PaymentSubV4Dialogs.showSlipPreview(
          ctx,
          isEn: false,
          loader: () async => null,
        ),
      );

      expect(find.text('ไม่สามารถโหลดรูปภาพได้'), findsOneWidget);
    });

    testWidgets('preview dialog renders the loaded image', (tester) async {
      // PNG 1x1 โปร่งใส
      final png = Uint8List.fromList(const [
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
        0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
        0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
      ]);

      await showSheet(
        tester,
        (ctx) => PaymentSubV4Dialogs.showSlipPreview(
          ctx,
          isEn: false,
          loader: () async => png,
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('ไม่สามารถโหลดรูปภาพได้'), findsNothing);
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
