import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/widgets/animated_entry.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../auth/application/auth_controller.dart';
import '../data/pets_repository.dart';
import '../domain/pet.dart';

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

  @override
  void dispose() {
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
      return const SafeArea(
        child: Center(
          child: EmptyState(
            title: 'Perlu masuk',
            message: 'Masuk untuk melihat semua riwayat perawatan.',
            icon: Icons.lock_outline,
          ),
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
                Text(
                  'Riwayat Perawatan',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${meta.total} riwayat tercatat',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {
                    _query = value;
                    _page = 1;
                  }),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Cari riwayat / nama anabul',
                  ),
                ),
                const SizedBox(height: 12),
                _HistoryFilters(
                  petId: _petId,
                  dateRange: _dateRange,
                  petOptionsAsync: petOptionsAsync,
                  onPetChanged: (value) => setState(() {
                    _petId = value;
                    _page = 1;
                  }),
                  onPickDate: _pickDateRange,
                  onClear: _hasFilters
                      ? () => setState(() {
                          _searchController.clear();
                          _query = '';
                          _petId = null;
                          _dateRange = null;
                          _page = 1;
                        })
                      : null,
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
                        child: PressableScale(
                          onTap: () => context.push('/histories/${history.id}'),
                          borderRadius: 16,
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
                                    imageUrl: history.petImage ?? '',
                                    width: 60,
                                    height: 60,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        history.layanan ??
                                            history.kategoriLayanan ??
                                            'Perawatan',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${history.petName ?? '-'} - ${DateFormatters.short(history.tanggal)}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        history.diagnosa ??
                                            history.catatan ??
                                            history.statusPembayaran,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
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
                    );
                  }),
                if (meta.lastPage > 1) ...[
                  const SizedBox(height: 6),
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
}

class _HistoriesLoading extends StatelessWidget {
  const _HistoriesLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: const [
        SkeletonPulse(child: SkeletonBox(width: 230, height: 28, radius: 10)),
        SizedBox(height: 8),
        SkeletonPulse(child: SkeletonBox(width: 150, height: 14, radius: 8)),
        SizedBox(height: 18),
        SkeletonPulse(
          child: SkeletonBox(width: double.infinity, height: 52, radius: 16),
        ),
        SizedBox(height: 12),
        SkeletonPulse(
          child: SkeletonBox(width: double.infinity, height: 48, radius: 16),
        ),
        SizedBox(height: 12),
        SkeletonPulse(
          child: SkeletonBox(width: double.infinity, height: 54, radius: 16),
        ),
        SizedBox(height: 18),
        SkeletonCard(imageSize: 60),
        SizedBox(height: 12),
        SkeletonCard(imageSize: 60),
        SizedBox(height: 12),
        SkeletonCard(imageSize: 60),
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
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
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
    return Column(
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
    return Row(
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
    );
  }
}
