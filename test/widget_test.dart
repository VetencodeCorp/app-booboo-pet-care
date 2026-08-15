import 'package:app_client_booboo/src/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Booboo app smoke test', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BoobooApp()));

    expect(find.text('Booboo Pet Care'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
