import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/premium_action_button.dart';
import '../application/auth_controller.dart';
import 'widgets/auth_error_box.dart';
import 'widgets/auth_shell.dart';

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
    return AuthShell(
      title: widget.args.title,
      subtitle: widget.args.subtitle,
      showLogo: false,
      children: [
        if (_error != null) ...[
          AuthErrorBox(_error!),
          const SizedBox(height: 18),
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
        PremiumActionButton(
          label: 'Simpan Password',
          icon: Icons.lock_reset_rounded,
          loading: _loading,
          onPressed: _loading ? null : _save,
        ),
        if (widget.args.showSkip) ...[
          const SizedBox(height: 10),
          TextButton(
            onPressed: _loading ? null : () => context.go('/pets'),
            child: const Text('Lewati dulu'),
          ),
        ],
      ],
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
