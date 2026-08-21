import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../data/pets_repository.dart';

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
      extendBodyBehindAppBar: true,
      body: petAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (pet) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 310,
              pinned: true,
              stretch: true,
              actions: [
                IconButton.filledTonal(
                  tooltip: 'Ganti foto',
                  onPressed: _isUploading ? null : _showPhotoActions,
                  icon: _isUploading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.edit_outlined),
                ),
                const SizedBox(width: 10),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: pet.image,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.softPurple,
                        child: const Icon(
                          Icons.pets,
                          color: AppColors.primary,
                          size: 72,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.04),
                            Colors.black.withValues(alpha: 0.58),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet.name.trim(),
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: [
                              _HeroChip(label: pet.jenisHewan),
                              _HeroChip(label: pet.gender),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _PetInfoCard(
                    name: pet.name,
                    type: pet.jenisHewan,
                    gender: pet.gender,
                    owner: pet.ownerName ?? '-',
                    historiesCount: pet.totalRiwayat,
                    lastVisit: pet.kunjunganTerakhir,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Riwayat',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  historiesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Text(error.toString()),
                    data: (histories) => Column(
                      children: histories
                          .map(
                            (history) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: ListTile(
                                onTap: () =>
                                    context.push('/histories/${history.id}'),
                                leading: const CircleAvatar(
                                  backgroundColor: AppColors.softPurple,
                                  child: Icon(
                                    Icons.medical_services_outlined,
                                    color: AppColors.primary,
                                  ),
                                ),
                                title: Text(
                                  history.layanan ??
                                      history.kategoriLayanan ??
                                      '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                subtitle: Text(
                                  '${DateFormatters.short(history.tanggal)}\n${history.diagnosa ?? history.catatan ?? '-'}',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ]),
              ),
            ),
          ],
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

class _PetInfoCard extends StatelessWidget {
  const _PetInfoCard({
    required this.name,
    required this.type,
    required this.gender,
    required this.owner,
    required this.historiesCount,
    required this.lastVisit,
  });

  final String name;
  final String type;
  final String gender;
  final String owner;
  final int? historiesCount;
  final String? lastVisit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Detail Anabul',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.favorite_outline, label: 'Nama', value: name),
          // _InfoRow(icon: Icons.category_outlined, label: 'Jenis', value: type),
          // _InfoRow(icon: Icons.wc_outlined, label: 'Kelamin', value: gender),
          _InfoRow(icon: Icons.person_outline, label: 'Owner', value: owner),
          _InfoRow(
            icon: Icons.history_rounded,
            label: 'Total riwayat',
            value: '${historiesCount ?? 0} kunjungan',
          ),
          _InfoRow(
            icon: Icons.calendar_month_outlined,
            label: 'Kunjungan terakhir',
            value: DateFormatters.short(lastVisit),
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
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.softPurple,
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
