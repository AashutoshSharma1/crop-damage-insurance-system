import 'package:flutter_test/flutter_test.dart';
import 'package:farmer_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CropInsuranceApp());
    expect(find.byType(CropInsuranceApp), findsOneWidget);
  });
}
