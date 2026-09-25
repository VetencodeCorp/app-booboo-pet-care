import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/app_message.dart';

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepository(ref.watch(apiClientProvider));
});

final messagesProvider = FutureProvider<List<AppMessage>>((ref) {
  return ref.watch(messagesRepositoryProvider).fetch();
});

class MessagesRepository {
  const MessagesRepository(this._client);

  final ApiClient _client;

  Future<List<AppMessage>> fetch() async {
    final response = await _client.dio.get('/api/messages');
    final data = response.data['data'];
    if (data is! List) return [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(AppMessage.fromJson)
        .toList();
  }

  Future<void> markRead(int id) async {
    await _client.dio.post('/api/messages/$id/read');
  }
}
