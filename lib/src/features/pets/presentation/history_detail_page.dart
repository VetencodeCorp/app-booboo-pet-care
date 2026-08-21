import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/whatsapp_launcher.dart';
import '../../../shared/widgets/animated_entry.dart';
import '../../../shared/widgets/premium_action_button.dart';
import '../data/pets_repository.dart';
import '../domain/history_detail.dart';

class HistoryDetailPage extends ConsumerWidget {
  const HistoryDetailPage({required this.historyId, super.key});

  final int historyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(historyDetailProvider(historyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Riwayat')),
      body: SafeArea(
        child: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text(error.toString())),
          data: (detail) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 118),
            children: [
              AnimatedEntry(
                delay: const Duration(milliseconds: 60),
                child: _HistoryHero(detail: detail),
              ),
              const SizedBox(height: 18),
              AnimatedEntry(
                delay: const Duration(milliseconds: 120),
                child: _PetSummaryCard(detail: detail),
              ),
              const SizedBox(height: 18),
              AnimatedEntry(
                delay: const Duration(milliseconds: 160),
                child: _VitalsCard(
                  weight: _withUnit(detail.bb, 'kg'),
                  temperature: _withUnit(detail.suhu, 'C'),
                  doctor: _clean(detail.dokter),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Ringkasan Medis',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              AnimatedEntry(
                delay: const Duration(milliseconds: 200),
                child: _MedicalCard(
                  diagnosis: _clean(detail.diagnosa),
                  note: _clean(detail.catatan),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: PremiumActionButton(
            label: 'Hubungi Klinik',
            icon: Icons.chat_bubble_outline_rounded,
            secondary: true,
            onPressed: () => _openClinicWhatsapp(context, ref),
          ),
        ),
      ),
    );
  }

  Future<void> _openClinicWhatsapp(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final detail = ref.read(historyDetailProvider(historyId)).asData?.value;
    final petName = detail?.pet.name.trim();
    final date = DateFormatters.short(detail?.tanggal);
    final opened = await openBoobooWhatsapp(
      'Halo Booboo Pet Care, saya ingin bertanya tentang riwayat perawatan ${petName?.isNotEmpty == true ? petName : 'anabul'} pada tanggal $date.',
    );
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('WhatsApp tidak bisa dibuka')),
      );
    }
  }

  static String _clean(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? '-' : text;
  }

  static String _withUnit(String? value, String unit) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '-';
    final lower = text.toLowerCase();
    if (lower.contains(unit.toLowerCase())) return text;
    return '$text $unit';
  }
}

class _HistoryHero extends StatelessWidget {
  const _HistoryHero({required this.detail});

  final HistoryDetail detail;

  @override
  Widget build(BuildContext context) {
    final title = detail.layananName ?? detail.kategori ?? 'Perawatan';

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
              Icons.medical_services_outlined,
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
                child: Text(
                  DateFormatters.short(detail.tanggal),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w900,
                  height: 1.14,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                detail.kategori ?? 'Riwayat perawatan anabul',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
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

class _PetSummaryCard extends StatelessWidget {
  const _PetSummaryCard({required this.detail});

  final HistoryDetail detail;

  @override
  Widget build(BuildContext context) {
    final pet = detail.pet;

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: pet.image,
              width: 78,
              height: 78,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const ColoredBox(
                color: AppColors.softPurple,
                child: SizedBox(
                  width: 78,
                  height: 78,
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
                  pet.name.trim().isEmpty ? '-' : pet.name.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SoftChip(text: pet.jenisHewan),
                    _SoftChip(text: pet.gender),
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

class _VitalsCard extends StatelessWidget {
  const _VitalsCard({
    required this.weight,
    required this.temperature,
    required this.doctor,
  });

  final String weight;
  final String temperature;
  final String doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _VitalItem(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Berat Badan',
                  value: weight,
                ),
              ),
              Container(width: 1, height: 56, color: AppColors.border),
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
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.medical_services_outlined,
            label: 'Dokter Pemeriksa',
            value: doctor,
          ),
        ],
      ),
    );
  }
}

class _MedicalCard extends StatelessWidget {
  const _MedicalCard({required this.diagnosis, required this.note});

  final String diagnosis;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _TextBlock(
            icon: Icons.medical_information_outlined,
            label: 'Diagnosa',
            value: diagnosis,
          ),
          const Divider(height: 1, color: AppColors.border),
          _TextBlock(
            icon: Icons.notes_rounded,
            label: 'Catatan',
            value: note,
            tinted: true,
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
            Icon(icon, size: 18, color: AppColors.primary),
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.softPurple,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({
    required this.icon,
    required this.label,
    required this.value,
    this.tinted = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: tinted ? AppColors.lavender : AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 9),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftChip extends StatelessWidget {
  const _SoftChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final label = text.trim().isEmpty ? '-' : text.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.softPurple,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
