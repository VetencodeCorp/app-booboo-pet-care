import 'package:app_client_booboo/src/app.dart';
import 'package:app_client_booboo/src/features/app_update/data/app_update_repository.dart';
import 'package:app_client_booboo/src/features/home/data/home_repository.dart';
import 'package:app_client_booboo/src/features/home/domain/home_content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Booboo app smoke test', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appUpdateStatusProvider.overrideWithValue(
            const AsyncData(
              AppUpdateStatus(
                currentBuild: 1,
                currentVersion: '1.0.0',
                minimumBuild: 1,
                latestBuild: 1,
                forceUpdate: false,
                playStoreUrl: '',
              ),
            ),
          ),
          homeContentProvider.overrideWithValue(
            AsyncData(HomeContent.fallback()),
          ),
        ],
        child: const BoobooApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Booboo Pet Care'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
