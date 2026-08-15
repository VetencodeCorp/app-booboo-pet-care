import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/pets_repository.dart';

class PetsPage extends ConsumerStatefulWidget {
  const PetsPage({super.key});

  @override
  ConsumerState<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends ConsumerState<PetsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petsProvider);
    return SafeArea(
      child: petsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => EmptyState(
          title: 'Perlu masuk',
          message: 'Masuk untuk melihat data anabul dan riwayat perawatan.',
          icon: Icons.lock_outline,
        ),
        data: (pets) {
          final filtered = pets
              .where(
                (pet) => pet.name.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              Text(
                'Anabul Saya',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${pets.length} anabul terdaftar',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Cari anabul',
                ),
              ),
              const SizedBox(height: 18),
              if (filtered.isEmpty)
                const EmptyState(
                  title: 'Belum ada data anabul',
                  message: 'Hubungi admin jika kamu sudah pernah berkunjung.',
                )
              else
                ...filtered.map(
                  (pet) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => context.push('/pets/${pet.id}'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: CachedNetworkImage(
                                imageUrl: pet.image,
                                width: 76,
                                height: 76,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const ColoredBox(
                                      color: AppColors.softPurple,
                                      child: Icon(Icons.pets),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pet.name.trim(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${pet.jenisHewan} - ${pet.gender}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${pet.totalRiwayat ?? 0} kunjungan - Terakhir: ${DateFormatters.short(pet.kunjunganTerakhir)}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
