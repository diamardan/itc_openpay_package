// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:itc_openpay_package/itc_openpay_package.dart';
import 'package:itc_openpay_package_example/main.dart';

void main() {
  testWidgets('renders checkout screen with OpenPay scope', (tester) async {
    await tester.pumpWidget(
      const OpenPayScope(
        config: OpenPayConfig(
          merchantId: 'merchant',
          privateKey: 'private',
          publicKey: 'public',
        ),
        child: OpenPayDemoApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pagar con OpenPay'), findsOneWidget);
  });
}
