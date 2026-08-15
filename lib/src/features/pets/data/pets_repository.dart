import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/history_detail.dart';
import '../domain/pet.dart';
import '../domain/pet_history.dart';

final petsRepositoryProvider = Provider<PetsRepository>((ref) {
  return PetsRepository(ref.watch(apiClientProvider));
});

final petsProvider = FutureProvider<List<Pet>>((ref) {
  return ref.watch(petsRepositoryProvider).pets();
});

final petProvider = FutureProvider.family<Pet, int>((ref, id) {
  return ref.watch(petsRepositoryProvider).pet(id);
});

final petHistoriesProvider = FutureProvider.family<List<PetHistory>, int>((
  ref,
  id,
) {
  return ref.watch(petsRepositoryProvider).histories(id);
});

final historyDetailProvider = FutureProvider.family<HistoryDetail, int>((
  ref,
  id,
) {
  return ref.watch(petsRepositoryProvider).history(id);
});

final petTypesProvider = FutureProvider<List<PetType>>((ref) {
  return ref.watch(petsRepositoryProvider).petTypes();
});

class PetType {
  const PetType({required this.id, required this.name});

  final int id;
  final String name;

  factory PetType.fromJson(Map<String, dynamic> json) {
    return PetType(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
    );
  }
}

class PetsRepository {
  PetsRepository(this._client);

  final ApiClient _client;

  Future<List<Pet>> pets() async {
    final response = await _client.dio.get('/api/pets');
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((item) => Pet.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Pet> pet(int id) async {
    final response = await _client.dio.get('/api/pets/$id');
    return Pet.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<PetType>> petTypes() async {
    final response = await _client.dio.get('/api/pet-types');
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((item) => PetType.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Pet> updatePet({
    required int id,
    required String name,
    required int jenisId,
    required String genderCode,
  }) async {
    final response = await _client.dio.put(
      '/api/pets/$id',
      data: {'name': name, 'jenis_id': jenisId, 'jk': genderCode},
    );
    return Pet.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<PetHistory>> histories(int id) async {
    final response = await _client.dio.get('/api/pets/$id/histories');
    final data = response.data['data'] as Map<String, dynamic>;
    final list = data['histories'] as List<dynamic>;
    return list
        .map((item) => PetHistory.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<HistoryDetail> history(int id) async {
    final response = await _client.dio.get('/api/histories/$id');
    return HistoryDetail.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
