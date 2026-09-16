import 'package:flutter_test/flutter_test.dart';
import 'package:chaoperty_user/Model/GetInvoice_Model.dart';
import 'package:chaoperty_user/Model/GetPayMent_Model.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/services/payment_subv4_service.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/viewmodels/payment_subv4_view_model.dart';

InvoiceModel _inv({String? amtall, String? disendbill, String? totalBill}) {
  final m = InvoiceModel();
  m.amtall = amtall;
  m.disendbill = disendbill;
  m.total_bill = totalBill;
  return m;
}

PayMentModel _pay({String? fine, String? fineA, String? fineC}) {
  final m = PayMentModel();
  m.fine = fine;
  m.fine_a = fineA;
  m.fine_c = fineC;
  return m;
}

void main() {
  group('PaymentSummary calculation', () {
    test('sums invoices with no discount and no fine', () {
      final s = PaymentSubV4ViewModel.calculateSummary(
        [_inv(amtall: '100.00'), _inv(amtall: '250.50')],
        null,
      );
      expect(s.subTotal.toDouble(), 350.50);
      expect(s.discountTotal.toDouble(), 0.0);
      expect(s.fineTotal.toDouble(), 0.0);
      expect(s.grandTotal.toDouble(), 350.50);
    });

    test('subtracts discount from total', () {
      final s = PaymentSubV4ViewModel.calculateSummary(
        [_inv(amtall: '1000.00', disendbill: '150.00')],
        null,
      );
      expect(s.subTotal.toDouble(), 1000.0);
      expect(s.discountTotal.toDouble(), 150.0);
      expect(s.grandTotal.toDouble(), 850.0);
    });

    test('uses fixed fine amount when fine_c is 0.00', () {
      final s = PaymentSubV4ViewModel.calculateSummary(
        [_inv(amtall: '1000.00')],
        _pay(fine: '1', fineA: '75.00', fineC: '0.00'),
      );
      expect(s.fineTotal.toDouble(), 75.0);
      expect(s.grandTotal.toDouble(), 1075.0);
    });

    test('uses fixed fine amount when fine_c is null', () {
      final s = PaymentSubV4ViewModel.calculateSummary(
        [_inv(amtall: '1000.00')],
        _pay(fine: '1', fineA: '75.00'),
      );
      expect(s.fineTotal.toDouble(), 75.0);
    });

    test('computes percentage fine on discounted base', () {
      // base = 1000 - 200 = 800; 5% = 40
      final s = PaymentSubV4ViewModel.calculateSummary(
        [_inv(amtall: '1000.00', disendbill: '200.00')],
        _pay(fine: '1', fineA: '0.00', fineC: '5'),
      );
      expect(s.fineTotal.toDouble(), 40.0);
      expect(s.grandTotal.toDouble(), 840.0);
    });

    test('ignores fine when fine flag is not 1', () {
      final s = PaymentSubV4ViewModel.calculateSummary(
        [_inv(amtall: '1000.00')],
        _pay(fine: '0', fineA: '75.00', fineC: '5'),
      );
      expect(s.fineTotal.toDouble(), 0.0);
      expect(s.grandTotal.toDouble(), 1000.0);
    });

    test('percentage fine yields zero when base is not positive', () {
      final s = PaymentSubV4ViewModel.calculateSummary(
        [_inv(amtall: '100.00', disendbill: '100.00')],
        _pay(fine: '1', fineA: '0.00', fineC: '5'),
      );
      expect(s.fineTotal.toDouble(), 0.0);
      expect(s.grandTotal.toDouble(), 0.0);
    });

    test('clamps negative grand total to zero', () {
      final s = PaymentSubV4ViewModel.calculateSummary(
        [_inv(amtall: '100.00', disendbill: '300.00')],
        null,
      );
      expect(s.grandTotal.satang, 0);
      expect(s.grandTotal.isNegative, isFalse);
    });

    test('handles null and comma-formatted amounts without throwing', () {
      final s = PaymentSubV4ViewModel.calculateSummary(
        [_inv(amtall: null, disendbill: null), _inv(amtall: '1,234.56')],
        null,
      );
      expect(s.subTotal.toDouble(), 1234.56);
    });

    test('handles empty invoice list', () {
      final s = PaymentSubV4ViewModel.calculateSummary([], null);
      expect(s.subTotal.satang, 0);
      expect(s.grandTotal.satang, 0);
      expect(s.grandTotal.isZero, isTrue);
    });
  });

  group('displayed amount uses total_bill, not amtall', () {
    test('prefers total_bill when both are present', () {
      // amtall คือยอดก่อน VAT ที่ใช้ส่ง API (205.61) ส่วน total_bill คือยอดที่แสดง (220)
      // ต้นฉบับแสดง total_bill ทุกหน้าจอ (payment_subV4_InvAll.dart:5210)
      final s = PaymentSubV4ViewModel.calculateSummary(
        [_inv(amtall: '205.61', totalBill: '220.00')],
        null,
      );

      expect(s.subTotal.toDouble(), 220.0);
      expect(s.grandTotal.toDouble(), 220.0);
    });

    test('falls back to amtall when total_bill is missing', () {
      final s = PaymentSubV4ViewModel.calculateSummary(
        [_inv(amtall: '205.61')],
        null,
      );

      expect(s.subTotal.toDouble(), 205.61);
    });

    test('falls back to amtall when total_bill is zero', () {
      final s = PaymentSubV4ViewModel.calculateSummary(
        [_inv(amtall: '100.00', totalBill: '0.00')],
        null,
      );

      expect(s.subTotal.toDouble(), 100.0);
    });

    test('subtracts the discount from total_bill', () {
      final s = PaymentSubV4ViewModel.calculateSummary(
        [_inv(amtall: '205.61', totalBill: '220.00', disendbill: '20.00')],
        null,
      );

      expect(s.subTotal.toDouble(), 220.0);
      expect(s.grandTotal.toDouble(), 200.0);
    });

    test('sums total_bill across multiple invoices', () {
      final s = PaymentSubV4ViewModel.calculateSummary(
        [
          _inv(amtall: '93.46', totalBill: '100.00'),
          _inv(amtall: '112.15', totalBill: '120.00'),
        ],
        null,
      );

      expect(s.subTotal.toDouble(), 220.0);
    });

    test('percentage fine is computed from the displayed base', () {
      final s = PaymentSubV4ViewModel.calculateSummary(
        [_inv(amtall: '205.61', totalBill: '220.00')],
        _pay(fine: '1', fineA: '0.00', fineC: '10'),
      );

      // 10% ของ 220 = 22 (ไม่ใช่ 10% ของ 205.61)
      expect(s.fineTotal.toDouble(), 22.0);
      expect(s.grandTotal.toDouble(), 242.0);
    });
  });

  group('Upload response body validation', () {
    test('accepts empty body', () {
      expect(PaymentSubV4Service.bodyIndicatesSuccess(''), isTrue);
      expect(PaymentSubV4Service.bodyIndicatesSuccess('   '), isTrue);
    });

    test('accepts plain success JSON', () {
      expect(
        PaymentSubV4Service.bodyIndicatesSuccess('{"success":true}'),
        isTrue,
      );
      expect(
        PaymentSubV4Service.bodyIndicatesSuccess('{"slip_no":"abc123"}'),
        isTrue,
      );
      expect(PaymentSubV4Service.bodyIndicatesSuccess('{"ok":true}'), isTrue);
    });

    test('rejects explicit failure flags', () {
      expect(
        PaymentSubV4Service.bodyIndicatesSuccess('{"success":false}'),
        isFalse,
      );
      expect(
        PaymentSubV4Service.bodyIndicatesSuccess('{"ok":false}'),
        isFalse,
      );
    });

    test('rejects failure status regardless of case', () {
      expect(
        PaymentSubV4Service.bodyIndicatesSuccess('{"status":"FAILED"}'),
        isFalse,
      );
      expect(
        PaymentSubV4Service.bodyIndicatesSuccess('{"status":"error"}'),
        isFalse,
      );
      expect(
        PaymentSubV4Service.bodyIndicatesSuccess('{"status":"rejected"}'),
        isFalse,
      );
      expect(
        PaymentSubV4Service.bodyIndicatesSuccess('{"status":"success"}'),
        isTrue,
      );
    });

    test('rejects failure wording in message', () {
      expect(
        PaymentSubV4Service.bodyIndicatesSuccess('{"message":"upload failed"}'),
        isFalse,
      );
      expect(
        PaymentSubV4Service.bodyIndicatesSuccess('{"message":"uploadError"}'),
        isFalse,
      );
      expect(
        PaymentSubV4Service.bodyIndicatesSuccess('{"message":"ไม่สำเร็จ"}'),
        isFalse,
      );
    });

    test('rejects html error page returned with 200', () {
      expect(
        PaymentSubV4Service.bodyIndicatesSuccess('<html><body>Oops</body></html>'),
        isFalse,
      );
      expect(
        PaymentSubV4Service.bodyIndicatesSuccess('Not Found'),
        isFalse,
      );
    });
  });
}
