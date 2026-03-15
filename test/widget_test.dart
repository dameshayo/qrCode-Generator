import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const QRGeneratorApp());

    expect(find.byType(QRGeneratorApp), findsOneWidget);
  });
}
