import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/network/api_client.dart';

final appUpdateRepositoryProvider = Provider<AppUpdateRepository>((ref) {
  return AppUpdateRepository(ref.watch(apiClientProvider));
});

final appUpdateStatusProvider = FutureProvider<AppUpdateStatus>((ref) {
  return ref.watch(appUpdateRepositoryProvider).check();
});

class AppUpdateRepository {
  const AppUpdateRepository(this._client);

  final ApiClient _client;

  Future<AppUpdateStatus> check() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        'api/app-version',
      );
      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      final minimumBuild = (data['minimum_build_number'] as num?)?.toInt() ?? 0;
      final latestBuild = (data['latest_build_number'] as num?)?.toInt() ?? 0;
      final forceUpdate = data['force_update'] == true;
      final playStoreUrl =
          data['playstore_url']?.toString() ??
          'https://play.google.com/store/apps/details?id=com.booboopetcare.member';

      return AppUpdateStatus(
        currentBuild: currentBuild,
        currentVersion: packageInfo.version,
        minimumBuild: minimumBuild,
        latestBuild: latestBuild,
        forceUpdate: forceUpdate && currentBuild < minimumBuild,
        playStoreUrl: playStoreUrl,
      );
    } catch (_) {
      return AppUpdateStatus(
        currentBuild: currentBuild,
        currentVersion: packageInfo.version,
        minimumBuild: currentBuild,
        latestBuild: currentBuild,
        forceUpdate: false,
        playStoreUrl:
            'https://play.google.com/store/apps/details?id=com.booboopetcare.member',
      );
    }
  }
}

class AppUpdateStatus {
  const AppUpdateStatus({
    required this.currentBuild,
    required this.currentVersion,
    required this.minimumBuild,
    required this.latestBuild,
    required this.forceUpdate,
    required this.playStoreUrl,
  });

  final int currentBuild;
  final String currentVersion;
  final int minimumBuild;
  final int latestBuild;
  final bool forceUpdate;
  final String playStoreUrl;
}
