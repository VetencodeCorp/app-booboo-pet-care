import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/whatsapp_launcher.dart';
import '../../../shared/widgets/animated_entry.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/premium_action_button.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../auth/application/auth_controller.dart';
import '../data/pets_repository.dart';
import '../domain/pet.dart';

class PetsPage extends ConsumerStatefulWidget {
  const PetsPage({super.key});

  @override
  ConsumerState<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends ConsumerState<PetsPage> {
  final _searchController = TextEditingController();
  String _query = '';
  int _page = 1;
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    if (auth.isLoading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    if (auth.asData?.value == null) {
      return SafeArea(
        child: _PetsGuestState(
          onLogin: () => context.push('/login'),
          onWhatsapp: () => _openWhatsapp(context),
          onPrivacy: () => context.push('/privacy-policy'),
        ),
      );
    }

    final listQuery = PetListQuery(page: _page, search: _query);
    final petsAsync = ref.watch(pagedPetsProvider(listQuery));

    return SafeArea(
      child: petsAsync.when(
        loading: () => const _PetsLoading(),
        error: (error, stack) => _RetryState(
          title: 'Anabul belum bisa dimuat',
          message: 'Koneksi atau server sedang lambat. Coba muat ulang.',
          icon: Icons.pets_outlined,
          onRetry: () => ref.invalidate(pagedPetsProvider(listQuery)),
        ),
        data: (result) {
          final pets = result.items;
          final meta = result.meta;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(pagedPetsProvider(listQuery));
              await ref.read(pagedPetsProvider(listQuery).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              children: [
                AnimatedEntry(
                  delay: const Duration(milliseconds: 60),
                  child: _PetsHero(total: meta.total),
                ),
                const SizedBox(height: 18),
                AnimatedEntry(
                  delay: const Duration(milliseconds: 120),
                  child: _SearchBox(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(height: 18),
                if (pets.isEmpty)
                  const EmptyState(
                    title: 'Belum ada data anabul',
                    message: 'Hubungi admin jika kamu sudah pernah berkunjung.',
                  )
                else
                  ...pets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final pet = entry.value;
                    return AnimatedEntry(
                      delay: Duration(milliseconds: 45 * index.clamp(0, 6)),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PetCard(
                          pet: pet,
                          onTap: () => context.push('/pets/${pet.id}'),
                        ),
                      ),
                    );
                  }),
                if (meta.lastPage > 1) ...[
                  const SizedBox(height: 8),
                  _PaginationBar(
                    page: meta.page,
                    lastPage: meta.lastPage,
                    onPrevious: meta.page <= 1
                        ? null
                        : () => setState(() => _page--),
                    onNext: meta.page >= meta.lastPage
                        ? null
                        : () => setState(() => _page++),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 700), () {
      final nextQuery = value.trim();
      if (!mounted || nextQuery == _query) return;
      setState(() {
        _query = nextQuery;
        _page = 1;
      });
    });
  }

  Future<void> _openWhatsapp(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await openBoobooWhatsapp(
      'Halo Booboo Pet Care, saya butuh bantuan untuk melihat data anabul.',
    );
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('WhatsApp tidak bisa dibuka')),
      );
    }
  }
}

class _PetsHero extends StatelessWidget {
  const _PetsHero({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), AppColors.lavender],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -10,
            child: Icon(
              Icons.pets_rounded,
              size: 132,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softPurple.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'Anabul Saya',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                '$total anabul terdaftar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w900,
                  height: 1.14,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Lihat profil anabul, foto, dan ringkasan kunjungan terakhir.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: 'Cari nama anabul',
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet, required this.onTap});

  final Pet pet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visitText = DateFormatters.short(pet.kunjunganTerakhir);

    return PressableScale(
      onTap: onTap,
      borderRadius: 24,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: pet.image,
                width: 82,
                height: 82,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const ColoredBox(
                  color: AppColors.softPurple,
                  child: SizedBox(
                    width: 82,
                    height: 82,
                    child: Icon(Icons.pets, color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pet.name.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softPurple,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${pet.totalRiwayat ?? 0}x',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${pet.jenisHewan} - ${pet.gender}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Terakhir: $visitText',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PetsGuestState extends StatelessWidget {
  const _PetsGuestState({
    required this.onLogin,
    required this.onWhatsapp,
    required this.onPrivacy,
  });

  final VoidCallback onLogin;
  final VoidCallback onWhatsapp;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        AnimatedEntry(
          delay: const Duration(milliseconds: 60),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), AppColors.lavender],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -8,
                  bottom: -10,
                  child: Icon(
                    Icons.pets_rounded,
                    size: 132,
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softPurple.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        'Belum Login',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Data anabul belum terbuka.',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w900,
                            height: 1.14,
                          ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Masuk untuk melihat daftar anabul dan riwayat perawatannya.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    PremiumActionButton(
                      label: 'Masuk Sekarang',
                      icon: Icons.login_rounded,
                      onPressed: onLogin,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        AnimatedEntry(
          delay: const Duration(milliseconds: 120),
          child: _PetsGuestMenu(
            onLogin: onLogin,
            onWhatsapp: onWhatsapp,
            onPrivacy: onPrivacy,
          ),
        ),
      ],
    );
  }
}

class _PetsGuestMenu extends StatelessWidget {
  const _PetsGuestMenu({
    required this.onLogin,
    required this.onWhatsapp,
    required this.onPrivacy,
  });

  final VoidCallback onLogin;
  final VoidCallback onWhatsapp;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _GuestTile(
            icon: Icons.login_rounded,
            title: 'Masuk Member',
            subtitle: 'Akses daftar anabul dan riwayat',
            onTap: onLogin,
          ),
          const _GuestDivider(),
          _GuestTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Bantuan WhatsApp',
            subtitle: 'Hubungi admin Booboo',
            onTap: onWhatsapp,
          ),
          const _GuestDivider(),
          _GuestTile(
            icon: Icons.shield_outlined,
            title: 'Kebijakan Privasi',
            subtitle: 'Cara Booboo menjaga data member',
            onTap: onPrivacy,
          ),
        ],
      ),
    );
  }
}

class _GuestTile extends StatelessWidget {
  const _GuestTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primary, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestDivider extends StatelessWidget {
  const _GuestDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 70,
      endIndent: 16,
      color: AppColors.border.withValues(alpha: 0.8),
    );
  }
}

class _PetsLoading extends StatelessWidget {
  const _PetsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: const [
        SkeletonPulse(
          child: SkeletonBox(width: double.infinity, height: 190, radius: 30),
        ),
        SizedBox(height: 18),
        SkeletonPulse(
          child: SkeletonBox(width: double.infinity, height: 56, radius: 20),
        ),
        SizedBox(height: 18),
        SkeletonCard(),
        SizedBox(height: 12),
        SkeletonCard(),
        SizedBox(height: 12),
        SkeletonCard(),
      ],
    );
  }
}

class _RetryState extends StatelessWidget {
  const _RetryState({
    required this.title,
    required this.message,
    required this.icon,
    required this.onRetry,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmptyState(title: title, message: message, icon: icon),
            const SizedBox(height: 12),
            PremiumActionButton(
              label: 'Coba Lagi',
              icon: Icons.refresh_rounded,
              secondary: true,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.lastPage,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int lastPage;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left_rounded),
              label: const Text('Prev'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$page / $lastPage',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right_rounded),
              label: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
