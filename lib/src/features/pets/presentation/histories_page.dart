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
import '../domain/pet_history.dart';

class HistoriesPage extends ConsumerStatefulWidget {
  const HistoriesPage({super.key});

  @override
  ConsumerState<HistoriesPage> createState() => _HistoriesPageState();
}

class _HistoriesPageState extends ConsumerState<HistoriesPage> {
  final _searchController = TextEditingController();
  String _query = '';
  int _page = 1;
  int? _petId;
  DateTimeRange? _dateRange;
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
        child: _HistoriesGuestState(
          onLogin: () => context.push('/login'),
          onWhatsapp: () => _openWhatsapp(context),
          onPrivacy: () => context.push('/privacy-policy'),
        ),
      );
    }

    final listQuery = HistoryListQuery(
      page: _page,
      search: _query,
      petId: _petId,
      dateFrom: _dateRange?.start,
      dateTo: _dateRange?.end,
    );
    final historiesAsync = ref.watch(pagedHistoriesProvider(listQuery));
    final petOptionsAsync = ref.watch(petOptionsProvider);

    return SafeArea(
      child: historiesAsync.when(
        loading: () => const _HistoriesLoading(),
        error: (error, stack) => _RetryState(
          title: 'Riwayat belum bisa dimuat',
          message: 'Koneksi atau server sedang lambat. Coba muat ulang.',
          icon: Icons.history_toggle_off_outlined,
          onRetry: () {
            ref.invalidate(pagedHistoriesProvider(listQuery));
            ref.invalidate(petOptionsProvider);
          },
        ),
        data: (result) {
          final histories = result.items;
          final meta = result.meta;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(pagedHistoriesProvider(listQuery));
              await ref.read(pagedHistoriesProvider(listQuery).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              children: [
                AnimatedEntry(
                  delay: const Duration(milliseconds: 60),
                  child: _HistoriesHero(total: meta.total),
                ),
                const SizedBox(height: 18),
                AnimatedEntry(
                  delay: const Duration(milliseconds: 120),
                  child: _SearchBox(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedEntry(
                  delay: const Duration(milliseconds: 150),
                  child: _HistoryFilters(
                    petId: _petId,
                    dateRange: _dateRange,
                    petOptionsAsync: petOptionsAsync,
                    onPetChanged: (value) => setState(() {
                      _petId = value;
                      _page = 1;
                    }),
                    onPickDate: _pickDateRange,
                    onClear: _hasFilters ? _clearFilters : null,
                  ),
                ),
                const SizedBox(height: 18),
                if (histories.isEmpty)
                  const EmptyState(
                    title: 'Belum ada riwayat',
                    message: 'Riwayat perawatan akan tampil setelah kunjungan.',
                  )
                else
                  ...histories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final history = entry.value;
                    return AnimatedEntry(
                      delay: Duration(milliseconds: 45 * index.clamp(0, 6)),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HistoryCard(
                          history: history,
                          onTap: () => context.push('/histories/${history.id}'),
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

  bool get _hasFilters =>
      _query.trim().isNotEmpty || _petId != null || _dateRange != null;

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

  void _clearFilters() {
    _searchDebounce?.cancel();
    setState(() {
      _searchController.clear();
      _query = '';
      _petId = null;
      _dateRange = null;
      _page = 1;
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: _dateRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      _dateRange = picked;
      _page = 1;
    });
  }

  Future<void> _openWhatsapp(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await openBoobooWhatsapp(
      'Halo Booboo Pet Care, saya butuh bantuan untuk melihat riwayat perawatan.',
    );
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('WhatsApp tidak bisa dibuka')),
      );
    }
  }
}

class _HistoriesHero extends StatelessWidget {
  const _HistoriesHero({required this.total});

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
              Icons.history_rounded,
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
                  'Riwayat Perawatan',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                '$total riwayat tercatat',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w900,
                  height: 1.14,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Pantau diagnosa, tindakan, dan catatan perawatan anabul.',
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
        hintText: 'Cari riwayat / nama anabul',
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

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.history, required this.onTap});

  final PetHistory history;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = history.layanan ?? history.kategoriLayanan ?? 'Perawatan';
    final note = history.diagnosa ?? history.tindakan ?? history.catatan ?? '-';

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
                imageUrl: history.petImage ?? '',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const ColoredBox(
                  color: AppColors.softPurple,
                  child: SizedBox(
                    width: 70,
                    height: 70,
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
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${history.petName ?? '-'} - ${DateFormatters.short(history.tanggal)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
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

class _HistoriesGuestState extends StatelessWidget {
  const _HistoriesGuestState({
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
                    Icons.history_rounded,
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
                      'Riwayat belum terbuka.',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w900,
                            height: 1.14,
                          ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Masuk untuk melihat semua riwayat perawatan anabul.',
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
          child: _GuestMenu(
            onLogin: onLogin,
            onWhatsapp: onWhatsapp,
            onPrivacy: onPrivacy,
          ),
        ),
      ],
    );
  }
}

class _GuestMenu extends StatelessWidget {
  const _GuestMenu({
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
            subtitle: 'Akses riwayat perawatan anabul',
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

class _HistoriesLoading extends StatelessWidget {
  const _HistoriesLoading();

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
        SizedBox(height: 12),
        SkeletonPulse(
          child: SkeletonBox(width: double.infinity, height: 104, radius: 22),
        ),
        SizedBox(height: 18),
        SkeletonCard(imageSize: 70),
        SizedBox(height: 12),
        SkeletonCard(imageSize: 70),
        SizedBox(height: 12),
        SkeletonCard(imageSize: 70),
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

class _HistoryFilters extends StatelessWidget {
  const _HistoryFilters({
    required this.petId,
    required this.dateRange,
    required this.petOptionsAsync,
    required this.onPetChanged,
    required this.onPickDate,
    required this.onClear,
  });

  final int? petId;
  final DateTimeRange? dateRange;
  final AsyncValue<List<Pet>> petOptionsAsync;
  final ValueChanged<int?> onPetChanged;
  final VoidCallback onPickDate;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickDate,
                  icon: const Icon(Icons.date_range_outlined),
                  label: Text(_dateLabel),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: 'Reset filter',
                onPressed: onClear,
                icon: const Icon(Icons.filter_alt_off_outlined),
              ),
            ],
          ),
          const SizedBox(height: 10),
          petOptionsAsync.when(
            loading: () => const LinearProgressIndicator(minHeight: 2),
            error: (error, stack) => const SizedBox.shrink(),
            data: (pets) => DropdownButtonFormField<int?>(
              initialValue: petId,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.pets_outlined),
                hintText: 'Semua anabul',
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Semua anabul'),
                ),
                ...pets.map(
                  (pet) => DropdownMenuItem<int?>(
                    value: pet.id,
                    child: Text(
                      pet.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: onPetChanged,
            ),
          ),
        ],
      ),
    );
  }

  String get _dateLabel {
    if (dateRange == null) return 'Rentang tanggal';
    return '${DateFormatters.short(dateRange!.start.toIso8601String())} - ${DateFormatters.short(dateRange!.end.toIso8601String())}';
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
