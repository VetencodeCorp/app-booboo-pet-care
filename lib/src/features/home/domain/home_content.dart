import 'package:flutter/material.dart';

class HomeContent {
  const HomeContent({
    required this.banners,
    required this.events,
    required this.services,
  });

  final List<HomeBanner> banners;
  final List<HomeEvent> events;
  final List<HomeService> services;

  factory HomeContent.fromJson(Map<String, dynamic> json) {
    return HomeContent(
      banners: _listOf<Map<String, dynamic>>(
        json['banners'],
      ).map(HomeBanner.fromJson).toList(),
      events: _listOf<Map<String, dynamic>>(
        json['events'],
      ).map(HomeEvent.fromJson).toList(),
      services: _listOf<Map<String, dynamic>>(
        json['services'],
      ).map(HomeService.fromJson).toList(),
    );
  }

  factory HomeContent.fallback() {
    return const HomeContent(
      banners: [],
      events: [
        HomeEvent(
          id: 1,
          name: 'Riwayat Perawatan',
          image: '',
          description:
              'Diagnosa, tindakan, dan catatan dokter tersimpan di aplikasi.',
          category: 'info',
          dateStart: '',
          dateEnd: '',
        ),
      ],
      services: [
        HomeService(
          id: 1,
          name: 'Klinik',
          description: 'Periksa dan konsultasi dokter',
          icon: 'clinic',
        ),
        HomeService(
          id: 2,
          name: 'Grooming',
          description: 'Perawatan dan kebersihan',
          icon: 'grooming',
        ),
        HomeService(
          id: 3,
          name: 'Pet Shop',
          description: 'Kebutuhan anabul harian',
          icon: 'shop',
        ),
        HomeService(
          id: 4,
          name: 'Pet Hotel',
          description: 'Penitipan aman dan nyaman',
          icon: 'hotel',
        ),
      ],
    );
  }
}

class HomeBanner {
  const HomeBanner({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.image,
    required this.position,
  });

  final int id;
  final String name;
  final String description;
  final String category;
  final String image;
  final int position;

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      id: _intValue(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'promo',
      image: json['image']?.toString() ?? '',
      position: _intValue(json['position']),
    );
  }
}

class HomeEvent {
  const HomeEvent({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.category,
    required this.dateStart,
    required this.dateEnd,
  });

  final int id;
  final String name;
  final String image;
  final String description;
  final String category;
  final String dateStart;
  final String dateEnd;

  factory HomeEvent.fromJson(Map<String, dynamic> json) {
    return HomeEvent(
      id: _intValue(json['id']),
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'event',
      dateStart: json['date_start']?.toString() ?? '',
      dateEnd: json['date_end']?.toString() ?? '',
    );
  }
}

class HomeService {
  const HomeService({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final int id;
  final String name;
  final String description;
  final String icon;

  factory HomeService.fromJson(Map<String, dynamic> json) {
    return HomeService(
      id: _intValue(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'service',
    );
  }

  IconData get iconData {
    switch (icon) {
      case 'clinic':
        return Icons.local_hospital_outlined;
      case 'grooming':
        return Icons.content_cut_rounded;
      case 'shop':
        return Icons.shopping_bag_outlined;
      case 'hotel':
        return Icons.night_shelter_outlined;
      default:
        return Icons.pets_outlined;
    }
  }
}

List<T> _listOf<T>(Object? value) {
  if (value is! List) return [];
  return value.whereType<T>().toList();
}

int _intValue(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
