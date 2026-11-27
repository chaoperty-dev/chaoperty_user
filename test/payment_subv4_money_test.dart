import 'package:flutter_test/flutter_test.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';

void main() {
  group('PaymentSubV4 Money Calculation Tests', () {
    test('Money basic operations and precision', () {
      final m1 = Money.fromDouble(100.50);
      final m2 = Money.fromDouble(50.25);

      expect((m1 + m2).satang, 15075);
      expect((m1 + m2).toDouble(), 150.75);
      expect((m1 - m2).toDouble(), 50.25);
    });

    test('Money parsing handles commas and null values', () {
      expect(Money.parse('1,234.56').toDouble(), 1234.56);
      expect(Money.parse(null).satang, 0);
      expect(Money.parse('').satang, 0);
    });

    test('Money multiplication handles rate percentage correctly', () {
      final base = Money.fromDouble(1000.0);
      final fine = base * 0.05; // 5%
      expect(fine.toDouble(), 50.0);
    });
  });
}
