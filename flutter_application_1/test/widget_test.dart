import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/services/sangini_controller.dart';

void main() {
  testWidgets('Sangini AI smoke test', (WidgetTester tester) async {
    final controller = SanginiController();
    controller.stopPolling();

    await tester.pumpWidget(const SanginiApp());
    expect(find.text('Sangini AI'), findsOneWidget);

    // Cancel any active timers
    controller.stopPolling();
  });
}
