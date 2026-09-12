import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/payment_subv4_page.dart';

void main() {
  group('PaymentSubV4Page Widget Smoke Test', () {
    testWidgets('Renders PaymentSubV4Page without throwing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentSubV4Page(
            cuslang: 'TH',
            serPayment: '1',
          ),
        ),
      );

      // Verify that the initial loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
