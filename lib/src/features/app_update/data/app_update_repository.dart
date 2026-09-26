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
      final minimumVersion = data['minimum_version']?.toString() ?? '0.0.0';
      final latestVersion =
          data['latest_version']?.toString() ?? minimumVersion;
      final forceUpdate = data['force_update'] == true;
      final playStoreUrl =
          data['playstore_url']?.toString() ??
          'https://play.google.com/store/apps/details?id=com.booboopetcare.member';
      final belowMinimumBuild = currentBuild < minimumBuild;
      final belowMinimumVersion =
          _compareVersions(packageInfo.version, minimumVersion) < 0;
      final belowLatestBuild = currentBuild < latestBuild;
      final belowLatestVersion =
          _compareVersions(packageInfo.version, latestVersion) < 0;

      return AppUpdateStatus(
        currentBuild: currentBuild,
        currentVersion: packageInfo.version,
        minimumBuild: minimumBuild,
        latestBuild: latestBuild,
        minimumVersion: minimumVersion,
        latestVersion: latestVersion,
        forceUpdate:
            belowMinimumBuild ||
            belowMinimumVersion ||
            (forceUpdate && (belowLatestBuild || belowLatestVersion)),
        playStoreUrl: playStoreUrl,
      );
    } catch (_) {
      return AppUpdateStatus(
        currentBuild: currentBuild,
        currentVersion: packageInfo.version,
        minimumBuild: currentBuild,
        latestBuild: currentBuild,
        minimumVersion: packageInfo.version,
        latestVersion: packageInfo.version,
        forceUpdate: false,
        playStoreUrl:
            'https://play.google.com/store/apps/details?id=com.booboopetcare.member',
      );
    }
  }

  static int _compareVersions(String current, String required) {
    final currentParts = _versionParts(current);
    final requiredParts = _versionParts(required);
    final length = currentParts.length > requiredParts.length
        ? currentParts.length
        : requiredParts.length;

    for (var index = 0; index < length; index++) {
      final currentPart = index < currentParts.length ? currentParts[index] : 0;
      final requiredPart = index < requiredParts.length
          ? requiredParts[index]
          : 0;
      if (currentPart != requiredPart) {
        return currentPart.compareTo(requiredPart);
      }
    }
    return 0;
  }

  static List<int> _versionParts(String version) {
    return version
        .split('+')
        .first
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
  }
}

class AppUpdateStatus {
  const AppUpdateStatus({
    required this.currentBuild,
    required this.currentVersion,
    required this.minimumBuild,
    required this.latestBuild,
    this.minimumVersion = '0.0.0',
    this.latestVersion = '0.0.0',
    required this.forceUpdate,
    required this.playStoreUrl,
  });

  final int currentBuild;
  final String currentVersion;
  final int minimumBuild;
  final int latestBuild;
  final String minimumVersion;
  final String latestVersion;
  final bool forceUpdate;
  final String playStoreUrl;
}
