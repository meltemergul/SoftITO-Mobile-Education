import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chronomind/app/app.dart';

void main() {
  testWidgets('Chronomind app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ChronomindApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Chronomind'), findsOneWidget);
  });
}
