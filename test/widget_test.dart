import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophthal_vivaedge/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: OphthalVivaEdgeApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(OphthalVivaEdgeApp), findsOneWidget);
  });
}
