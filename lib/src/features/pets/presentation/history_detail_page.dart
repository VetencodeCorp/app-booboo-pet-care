import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../data/pets_repository.dart';

class HistoryDetailPage extends ConsumerWidget {
  const HistoryDetailPage({required this.historyId, super.key});

  final int historyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(historyDetailProvider(historyId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text(error.toString())),
          data: (detail) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HistoryHeader(
                  title: detail.layananName ?? detail.kategori ?? 'Layanan',
                  date: DateFormatters.short(detail.tanggal),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _PetSummaryCard(
                      imageUrl: detail.pet.image,
                      name: detail.pet.name,
                      type: detail.pet.jenisHewan,
                      gender: detail.pet.gender,
                    ),
                    const SizedBox(height: 26),
                    const _SectionTitle('Ringkasan Medis'),
                    const SizedBox(height: 12),
                    _MedicalSummaryCard(
                      weight: _withUnit(detail.bb, 'kg'),
                      temperature: _withUnit(detail.suhu, 'C'),
                      diagnosis: detail.diagnosa ?? '-',
                      // treatment: detail.tindakan ?? '-',
                      note: detail.catatan ?? '-',
                      doctor: detail.dokter ?? '-',
                    ),
                    const SizedBox(height: 112),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0),
                AppColors.background,
              ],
            ),
          ),
          child: SizedBox(
            height: 58,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur hubungi klinik menyusul'),
                  ),
                );
              },
              icon: const Icon(Icons.phone_outlined),
              label: const Text('Hubungi Klinik'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _withUnit(String? value, String unit) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '-';
    final lower = text.toLowerCase();
    if (lower.contains(unit.toLowerCase())) return text;
    return '$text $unit';
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.title, required this.date});

  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 8,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PetSummaryCard extends StatelessWidget {
  const _PetSummaryCard({
    required this.imageUrl,
    required this.name,
    required this.type,
    required this.gender,
  });

  final String imageUrl;
  final String name;
  final String type;
  final String gender;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const ColoredBox(
                color: AppColors.softPurple,
                child: SizedBox(
                  width: 72,
                  height: 72,
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
                  name.trim().isEmpty ? '-' : name.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _Pill(text: type.isEmpty ? '-' : type),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Text(
                        gender.isEmpty ? '-' : gender,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicalSummaryCard extends StatelessWidget {
  const _MedicalSummaryCard({
    required this.weight,
    required this.temperature,
    required this.diagnosis,
    // required this.treatment,
    required this.note,
    required this.doctor,
  });

  final String weight;
  final String temperature;
  final String diagnosis;
  // final String treatment;
  final String note;
  final String doctor;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _VitalItem(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Berat Badan',
                    value: weight,
                  ),
                ),
                Container(width: 1, height: 64, color: AppColors.border),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: _VitalItem(
                      icon: Icons.thermostat_outlined,
                      label: 'Suhu',
                      value: temperature,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _TextBlock(label: 'Diagnosa', value: diagnosis),
          const Divider(height: 1, color: AppColors.border),
          // _TextBlock(label: 'Tindakan', value: treatment),
          const Divider(height: 1, color: AppColors.border),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.lavender,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 21,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Catatan Penting',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  note,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 5,
                  child: Text(
                    'Dokter Pemeriksa',
                    maxLines: 2,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ),
                const Icon(
                  Icons.medical_services_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: Text(
                    doctor,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalItem extends StatelessWidget {
  const _VitalItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF047765),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
