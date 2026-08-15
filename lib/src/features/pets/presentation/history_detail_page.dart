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
      appBar: AppBar(title: const Text('Detail Riwayat')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (detail) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          children: [
            Text(
              detail.layananName ?? detail.kategori ?? 'Layanan',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(
              DateFormatters.short(detail.tanggal),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            _InfoCard(
              children: [
                _Row(label: 'Anabul', value: detail.pet.name),
                _Row(label: 'Berat Badan', value: detail.bb ?? '-'),
                _Row(label: 'Suhu', value: detail.suhu ?? '-'),
                _Row(label: 'Diagnosa', value: detail.diagnosa ?? '-'),
                _Row(label: 'Tindakan', value: detail.tindakan ?? '-'),
                _Row(label: 'Catatan', value: detail.catatan ?? '-'),
                _Row(label: 'Dokter Pemeriksa', value: detail.dokter ?? '-'),
              ],
            ),
            const SizedBox(height: 18),
            _InfoCard(
              children: [
                _Row(label: 'Status Pembayaran', value: detail.status),
                _Row(label: 'Invoice', value: detail.nota ?? '-'),
                _Row(label: 'Total', value: 'Rp ${detail.jumlah}'),
              ],
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.phone_outlined),
              label: const Text('Hubungi Klinik'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
