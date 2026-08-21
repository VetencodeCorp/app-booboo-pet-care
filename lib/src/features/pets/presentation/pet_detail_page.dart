import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/widgets/animated_entry.dart';
import '../data/pets_repository.dart';
import '../domain/pet_history.dart';

class PetDetailPage extends ConsumerStatefulWidget {
  const PetDetailPage({required this.petId, super.key});

  final int petId;

  @override
  ConsumerState<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends ConsumerState<PetDetailPage> {
  final _picker = ImagePicker();
  var _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final petAsync = ref.watch(petProvider(widget.petId));
    final historiesAsync = ref.watch(petHistoriesProvider(widget.petId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Anabul')),
      body: petAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (pet) => SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
            children: [
              AnimatedEntry(
                delay: const Duration(milliseconds: 60),
                child: _PetHeroCard(
                  imageUrl: pet.image,
                  name: pet.name,
                  isUploading: _isUploading,
                  onPhotoTap: _showPhotoActions,
                ),
              ),
              const SizedBox(height: 18),
              AnimatedEntry(
                delay: const Duration(milliseconds: 120),
                child: _PetInfoCard(
                  type: pet.jenisHewan,
                  gender: pet.gender,
                  owner: pet.ownerName ?? '-',
                  historiesCount: pet.totalRiwayat,
                  lastVisit: pet.kunjunganTerakhir,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Riwayat Terbaru',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              historiesAsync.when(
                loading: () => const _HistoryLoading(),
                error: (error, stack) =>
                    _HistoryError(message: error.toString()),
                data: (histories) {
                  if (histories.isEmpty) return const _HistoryEmpty();
                  return Column(
                    children: histories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final history = entry.value;
                      return AnimatedEntry(
                        delay: Duration(milliseconds: 45 * index.clamp(0, 6)),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _HistoryCard(
                            history: history,
                            onTap: () =>
                                context.push('/histories/${history.id}'),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    final oldImage = ref.read(petProvider(widget.petId)).asData?.value.image;
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1200,
    );
    if (photo == null) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: photo.path,
      maxWidth: 1200,
      maxHeight: 1200,
      compressQuality: 86,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Foto Anabul',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.primary,
          initAspectRatio: CropAspectRatioPreset.square,
          aspectRatioPresets: const [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Foto Anabul',
          doneButtonTitle: 'Pakai',
          cancelButtonTitle: 'Batal',
          aspectRatioPresets: const [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
      ],
    );
    if (cropped == null) return;

    setState(() => _isUploading = true);
    try {
      final updated = await ref
          .read(petsRepositoryProvider)
          .uploadPhoto(
            id: widget.petId,
            file: XFile(cropped.path, name: 'pet-photo.jpg'),
          );
      if (oldImage != null && oldImage.isNotEmpty) {
        await CachedNetworkImage.evictFromCache(oldImage);
      }
      if (updated.image.isNotEmpty) {
        await CachedNetworkImage.evictFromCache(updated.image);
      }
      _invalidatePetCaches();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto anabul berhasil diperbarui')),
      );
    } on DioException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.response?.data['message']?.toString() ??
                error.message ??
                'Gagal mengganti foto',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _showPhotoActions() async {
    final pet = ref.read(petProvider(widget.petId)).asData?.value;
    final hasCustomPhoto =
        pet?.image.isNotEmpty == true &&
        pet?.image.contains('no-foto') == false;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.softPurple,
                    child: Icon(Icons.add_photo_alternate_outlined),
                  ),
                  title: const Text('Tambah / ganti foto'),
                  subtitle: const Text('Pilih dari galeri lalu crop foto.'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAndUploadPhoto();
                  },
                ),
                ListTile(
                  enabled: hasCustomPhoto,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFE7E7),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                    ),
                  ),
                  title: const Text('Hapus foto'),
                  subtitle: const Text('Kembalikan ke foto default.'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _deletePhoto();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deletePhoto() async {
    final oldImage = ref.read(petProvider(widget.petId)).asData?.value.image;
    setState(() => _isUploading = true);
    try {
      final updated = await ref
          .read(petsRepositoryProvider)
          .deletePhoto(id: widget.petId);
      if (oldImage != null && oldImage.isNotEmpty) {
        await CachedNetworkImage.evictFromCache(oldImage);
      }
      if (updated.image.isNotEmpty) {
        await CachedNetworkImage.evictFromCache(updated.image);
      }
      _invalidatePetCaches();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto anabul berhasil dihapus')),
      );
    } on DioException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.response?.data['message']?.toString() ??
                error.message ??
                'Gagal menghapus foto',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _invalidatePetCaches() {
    ref.invalidate(petsProvider);
    ref.invalidate(pagedPetsProvider);
    ref.invalidate(petOptionsProvider);
    ref.invalidate(petProvider(widget.petId));
    ref.invalidate(allHistoriesProvider);
    ref.invalidate(pagedHistoriesProvider);
  }
}

class _PetHeroCard extends StatelessWidget {
  const _PetHeroCard({
    required this.imageUrl,
    required this.name,
    required this.isUploading,
    required this.onPhotoTap,
  });

  final String imageUrl;
  final String name;
  final bool isUploading;
  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 1.12,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: AppColors.softPurple,
                  child: const Icon(
                    Icons.pets_rounded,
                    color: AppColors.primary,
                    size: 72,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.58),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Text(
              name.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: IconButton.filled(
              tooltip: 'Atur foto',
              onPressed: isUploading ? null : onPhotoTap,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface.withValues(alpha: 0.9),
                foregroundColor: AppColors.primary,
              ),
              icon: isUploading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.edit_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _PetInfoCard extends StatelessWidget {
  const _PetInfoCard({
    required this.type,
    required this.gender,
    required this.owner,
    required this.historiesCount,
    required this.lastVisit,
  });

  final String type;
  final String gender;
  final String owner;
  final int? historiesCount;
  final String? lastVisit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Anabul',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _InfoRow(icon: Icons.category_outlined, label: 'Jenis', value: type),
          _InfoRow(icon: Icons.wc_outlined, label: 'Kelamin', value: gender),
          _InfoRow(icon: Icons.person_outline, label: 'Pemilik', value: owner),
          _InfoRow(
            icon: Icons.history_rounded,
            label: 'Total riwayat',
            value: '${historiesCount ?? 0} kunjungan',
          ),
          _InfoRow(
            icon: Icons.calendar_month_outlined,
            label: 'Kunjungan terakhir',
            value: DateFormatters.short(lastVisit),
            last: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
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
                fontWeight: FontWeight.w700,
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
    final title = history.layanan ?? history.kategoriLayanan ?? '-';
    final note = history.diagnosa ?? history.tindakan ?? history.catatan ?? '-';

    return PressableScale(
      onTap: onTap,
      borderRadius: 22,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.softPurple,
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    DateFormatters.short(history.tanggal),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
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

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.softPurple,
            child: Icon(Icons.history_rounded, color: AppColors.primary),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Belum ada riwayat perawatan untuk anabul ini.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
