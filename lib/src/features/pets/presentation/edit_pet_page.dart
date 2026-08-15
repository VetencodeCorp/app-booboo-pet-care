import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/pets_repository.dart';

class EditPetPage extends ConsumerStatefulWidget {
  const EditPetPage({required this.petId, super.key});

  final int petId;

  @override
  ConsumerState<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends ConsumerState<EditPetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int? _jenisId;
  String _genderCode = 'M';
  var _isSaving = false;
  var _filledPetId = -1;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petAsync = ref.watch(petProvider(widget.petId));
    final typesAsync = ref.watch(petTypesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Anabul')),
      body: petAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (pet) {
          if (_filledPetId != pet.id) {
            _nameController.text = pet.name;
            _jenisId = pet.jenisId;
            _genderCode = pet.genderCode == 'F' ? 'F' : 'M';
            _filledPetId = pet.id;
          }

          return typesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text(error.toString())),
            data: (types) => ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.lavender,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.softPurple,
                        child: Icon(Icons.pets, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          pet.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Nama anabul',
                          prefixIcon: Icon(Icons.favorite_border_rounded),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Nama anabul wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        initialValue: _jenisId,
                        decoration: const InputDecoration(
                          labelText: 'Jenis hewan',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: types
                            .map(
                              (type) => DropdownMenuItem(
                                value: type.id,
                                child: Text(type.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _jenisId = value),
                        validator: (value) =>
                            value == null ? 'Jenis hewan wajib dipilih' : null,
                      ),
                      const SizedBox(height: 14),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'M',
                            icon: Icon(Icons.male_rounded),
                            label: Text('Jantan'),
                          ),
                          ButtonSegment(
                            value: 'F',
                            icon: Icon(Icons.female_rounded),
                            label: Text('Betina'),
                          ),
                        ],
                        selected: {_genderCode},
                        onSelectionChanged: (value) =>
                            setState(() => _genderCode = value.first),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _save,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_rounded),
                        label: const Text('Simpan Anabul'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await ref
          .read(petsRepositoryProvider)
          .updatePet(
            id: widget.petId,
            name: _nameController.text.trim(),
            jenisId: _jenisId!,
            genderCode: _genderCode,
          );
      ref.invalidate(petsProvider);
      ref.invalidate(petProvider(widget.petId));
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anabul berhasil diperbarui')),
      );
    } on DioException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.response?.data['message']?.toString() ??
                error.message ??
                'Gagal menyimpan anabul',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
