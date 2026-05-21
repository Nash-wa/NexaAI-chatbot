import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_ai/app.dart';

void main() {
  testWidgets('MyApp widget smoke test', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify the initial loading structure or app container
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
