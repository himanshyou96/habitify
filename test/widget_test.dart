import 'package:flutter_test/flutter_test.dart';
import 'package:mindful_pulse/main.dart'; // ✅ FIXED NAME

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MindfulPulseApp());

    expect(find.byType(MindfulPulseApp), findsOneWidget);
  });
}