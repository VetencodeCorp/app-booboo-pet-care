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

class ActivateMemberPage extends ConsumerStatefulWidget {
  const ActivateMemberPage({super.key});

  @override
  ConsumerState<ActivateMemberPage> createState() => _ActivateMemberPageState();
}

class _ActivateMemberPageState extends ConsumerState<ActivateMemberPage> {
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
          .activateMember(_phone.text.trim());
      if (!mounted) return;
      context.push(
        '/otp',
        extra: OtpPageArgs(result, flow: OtpFlow.activation),
      );
    } on DioException catch (error) {
      setState(
        () => _error =
            error.response?.data?['message']?.toString() ??
            error.message ??
            'Aktivasi member gagal',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Aktivasi Member Lama',
      subtitle:
          'Masukkan nomor HP yang sudah terdaftar. Kami kirim OTP untuk masuk pertama kali.',
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
          'Akun member lama tidak perlu daftar ulang. Cukup verifikasi nomor HP.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
