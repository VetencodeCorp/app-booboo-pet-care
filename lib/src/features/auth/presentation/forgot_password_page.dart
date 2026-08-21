import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/premium_action_button.dart';
import '../application/auth_controller.dart';
import 'otp_page.dart';
import 'widgets/auth_error_box.dart';
import 'widgets/auth_shell.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _phone = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
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
          .forgotPassword(_phone.text.trim());
      if (!mounted) return;
      context.push('/otp', extra: OtpPageArgs(result, flow: OtpFlow.forgot));
    } on DioException catch (error) {
      setState(
        () => _error =
            error.response?.data?['message']?.toString() ??
            error.message ??
            'Reset password gagal',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Lupa Password',
      subtitle:
          'Masukkan nomor HP member. Kami kirim OTP untuk verifikasi reset password.',
      showLogo: false,
      children: [
        if (_error != null) ...[
          AuthErrorBox(_error!),
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
        const SizedBox(height: 18),
        PremiumActionButton(
          label: 'Kirim OTP',
          icon: Icons.sms_outlined,
          loading: _loading,
          onPressed: _loading ? null : _submit,
        ),
        const SizedBox(height: 14),
        Text(
          'Setelah OTP valid, kamu bisa membuat password baru.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
