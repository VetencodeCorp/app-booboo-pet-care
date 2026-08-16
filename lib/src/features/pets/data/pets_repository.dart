import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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

final petOptionsProvider = FutureProvider<List<Pet>>((ref) {
  return ref.watch(petsRepositoryProvider).pets(perPage: 50);
});

final pagedPetsProvider = FutureProvider.family<PagedResult<Pet>, PetListQuery>(
  (ref, query) => ref.watch(petsRepositoryProvider).pagedPets(query),
);

final petProvider = FutureProvider.family<Pet, int>((ref, id) {
  return ref.watch(petsRepositoryProvider).pet(id);
});

final petHistoriesProvider = FutureProvider.family<List<PetHistory>, int>((
  ref,
  id,
) {
  return ref.watch(petsRepositoryProvider).histories(id);
});

final allHistoriesProvider = FutureProvider<List<PetHistory>>((ref) {
  return ref.watch(petsRepositoryProvider).allHistories();
});

final pagedHistoriesProvider =
    FutureProvider.family<PagedResult<PetHistory>, HistoryListQuery>(
      (ref, query) => ref.watch(petsRepositoryProvider).pagedHistories(query),
    );

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

class PagedResult<T> {
  const PagedResult({required this.items, required this.meta});

  final List<T> items;
  final PaginationMeta meta;
}

class PaginationMeta {
  const PaginationMeta({
    required this.total,
    required this.page,
    required this.perPage,
    required this.lastPage,
  });

  final int total;
  final int page;
  final int perPage;
  final int lastPage;

  factory PaginationMeta.fromJson(Map<String, dynamic>? json) {
    return PaginationMeta(
      total: (json?['total'] as num?)?.toInt() ?? 0,
      page: (json?['page'] as num?)?.toInt() ?? 1,
      perPage: (json?['per_page'] as num?)?.toInt() ?? 10,
      lastPage: (json?['last_page'] as num?)?.toInt() ?? 1,
    );
  }
}

class PetListQuery {
  const PetListQuery({this.page = 1, this.perPage = 10, this.search = ''});

  final int page;
  final int perPage;
  final String search;

  Map<String, dynamic> toQuery() => {
    'page': page,
    'per_page': perPage,
    if (search.trim().isNotEmpty) 'q': search.trim(),
  };

  @override
  bool operator ==(Object other) {
    return other is PetListQuery &&
        other.page == page &&
        other.perPage == perPage &&
        other.search == search;
  }

  @override
  int get hashCode => Object.hash(page, perPage, search);
}

class HistoryListQuery {
  const HistoryListQuery({
    this.page = 1,
    this.perPage = 10,
    this.search = '',
    this.petId,
    this.dateFrom,
    this.dateTo,
  });

  final int page;
  final int perPage;
  final String search;
  final int? petId;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  Map<String, dynamic> toQuery() => {
    'page': page,
    'per_page': perPage,
    if (search.trim().isNotEmpty) 'q': search.trim(),
    if (petId != null) 'pet_id': petId,
    if (dateFrom != null) 'date_from': _dateOnly(dateFrom!),
    if (dateTo != null) 'date_to': _dateOnly(dateTo!),
  };

  @override
  bool operator ==(Object other) {
    return other is HistoryListQuery &&
        other.page == page &&
        other.perPage == perPage &&
        other.search == search &&
        other.petId == petId &&
        other.dateFrom == dateFrom &&
        other.dateTo == dateTo;
  }

  @override
  int get hashCode =>
      Object.hash(page, perPage, search, petId, dateFrom, dateTo);
}

String _dateOnly(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

class PetsRepository {
  PetsRepository(this._client);

  final ApiClient _client;

  Future<List<Pet>> pets({String search = '', int page = 1, int perPage = 10}) {
    return pagedPets(
      PetListQuery(page: page, perPage: perPage, search: search),
    ).then((result) => result.items);
  }

  Future<PagedResult<Pet>> pagedPets(PetListQuery query) async {
    final response = await _client.dio.get(
      '/api/pets',
      queryParameters: query.toQuery(),
    );
    final list = response.data['data'] as List<dynamic>;
    return PagedResult(
      items: list
          .map((item) => Pet.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(
        response.data['meta'] as Map<String, dynamic>?,
      ),
    );
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

  Future<Pet> uploadPhoto({required int id, required XFile file}) async {
    final response = await _client.dio.post(
      '/api/pets/$id/photo',
      data: FormData.fromMap({
        'fileImage': await MultipartFile.fromFile(
          file.path,
          filename: file.name.isEmpty ? 'pet-photo.jpg' : file.name,
        ),
      }),
    );
    return Pet.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Pet> deletePhoto({required int id}) async {
    final response = await _client.dio.delete('/api/pets/$id/photo');
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

  Future<List<PetHistory>> allHistories({
    String search = '',
    int page = 1,
    int perPage = 10,
    int? petId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return pagedHistories(
      HistoryListQuery(
        page: page,
        perPage: perPage,
        search: search,
        petId: petId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ),
    ).then((result) => result.items);
  }

  Future<PagedResult<PetHistory>> pagedHistories(HistoryListQuery query) async {
    final response = await _client.dio.get(
      '/api/histories',
      queryParameters: query.toQuery(),
    );
    final list = response.data['data'] as List<dynamic>;
    return PagedResult(
      items: list
          .map((item) => PetHistory.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(
        response.data['meta'] as Map<String, dynamic>?,
      ),
    );
  }

  Future<HistoryDetail> history(int id) async {
    final response = await _client.dio.get('/api/histories/$id');
    return HistoryDetail.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
