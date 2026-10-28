import 'package:flutter_test/flutter_test.dart';
import 'package:rentkz/main.dart';

void main() {
  testWidgets('RentKZ app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RentKZApp());
    expect(find.text('RentKZ'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
