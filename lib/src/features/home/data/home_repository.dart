import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/home_content.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(apiClientProvider));
});

final homeContentProvider = FutureProvider<HomeContent>((ref) {
  return ref.watch(homeRepositoryProvider).fetch();
});

class HomeRepository {
  const HomeRepository(this._client);

  final ApiClient _client;

  Future<HomeContent> fetch() async {
    try {
      final response = await _client.dio.get('/api/home');
      final data = response.data['data'];
      if (data is! Map<String, dynamic>) {
        return HomeContent.fallback();
      }
      return HomeContent.fromJson(data);
    } catch (_) {
      return HomeContent.fallback();
    }
  }
}
