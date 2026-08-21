import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/premium_action_button.dart';
import '../application/auth_controller.dart';
import 'otp_page.dart';
import 'widgets/auth_shell.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .login(_phone.text.trim(), _password.text);
      if (!mounted) return;
      context.push('/otp', extra: OtpPageArgs(result));
    } on DioException catch (e) {
      setState(() => _error = _dioMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _dioMessage(DioException e) {
    final responseMessage = e.response?.data?['message']?.toString();
    if (responseMessage != null && responseMessage.isNotEmpty) {
      return responseMessage;
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Koneksi ke server timeout. Pastikan API backend sedang berjalan.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak bisa terhubung ke server. Cek alamat API dan jaringan device.';
    }

    return e.message ?? 'Login gagal';
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Masuk',
      subtitle: 'Gunakan nomor HP yang terdaftar di Booboo Pet Care.',
      children: [
        if (_error != null) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDAD6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.danger),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.danger),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.phone_iphone),
            labelText: 'Nomor Handphone',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _password,
          obscureText: _obscure,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline),
            labelText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push('/forgot-password'),
            child: const Text('Lupa password?'),
          ),
        ),
        const SizedBox(height: 18),
        PremiumActionButton(
          label: 'Masuk',
          icon: Icons.login_rounded,
          loading: _loading,
          onPressed: _loading ? null : _submit,
        ),
        const SizedBox(height: 14),
        PremiumActionButton(
          label: 'Aktivasi member lama',
          icon: Icons.verified_user_outlined,
          secondary: true,
          onPressed: _loading ? null : () => context.push('/activate-member'),
        ),
        const SizedBox(height: 14),
        Text(
          'Belum punya password? Pakai aktivasi member lama untuk masuk lewat OTP.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        const Divider(),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 8),
            Flexible(child: Text('Member lama tidak perlu daftar ulang.')),
          ],
        ),
      ],
    );
  }
}
