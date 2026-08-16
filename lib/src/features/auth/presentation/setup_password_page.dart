import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../application/auth_controller.dart';

class SetupPasswordPage extends ConsumerStatefulWidget {
  const SetupPasswordPage({
    this.args = const SetupPasswordPageArgs(),
    super.key,
  });

  final SetupPasswordPageArgs args;

  @override
  ConsumerState<SetupPasswordPage> createState() => _SetupPasswordPageState();
}

class SetupPasswordPageArgs {
  const SetupPasswordPageArgs({
    this.title = 'Buat Password',
    this.subtitle =
        'Password dipakai untuk login berikutnya. Bisa dilewati sekarang.',
    this.showSkip = true,
  });

  final String title;
  final String subtitle;
  final bool showSkip;
}

class _SetupPasswordPageState extends ConsumerState<SetupPasswordPage> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_password.text.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter');
      return;
    }
    if (_password.text != _confirmation.text) {
      setState(() => _error = 'Konfirmasi password tidak sesuai');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .setupPassword(
            newPassword: _password.text,
            confirmation: _confirmation.text,
          );
      if (!mounted) return;
      context.go('/pets');
    } on DioException catch (error) {
      setState(
        () => _error =
            error.response?.data?['message']?.toString() ??
            error.message ??
            'Password gagal dibuat',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 32),
            Text(
              widget.args.title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.args.subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _password,
              obscureText: _obscure,
              decoration: _decoration('Password baru'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _confirmation,
              obscureText: _obscure,
              decoration: _decoration('Konfirmasi password'),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _loading ? null : _save,
              icon: _loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock_reset_rounded),
              label: const Text('Simpan Password'),
            ),
            if (widget.args.showSkip) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loading ? null : () => context.go('/pets'),
                child: const Text('Lewati dulu'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      prefixIcon: const Icon(Icons.lock_outline),
      labelText: label,
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off),
      ),
    );
  }
}
