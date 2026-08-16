import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../application/auth_controller.dart';
import '../data/auth_repository.dart';
import 'setup_password_page.dart';

enum OtpFlow { login, activation, forgot }

class OtpPageArgs {
  const OtpPageArgs(this.result, {this.flow = OtpFlow.login});

  final LoginOtpResult result;
  final OtpFlow flow;
}

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({required this.args, super.key});

  final OtpPageArgs args;

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final _otp = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .verifyOtp(widget.args.result.otpToken, _otp.text.trim());
      if (!mounted) return;

      if (widget.args.flow == OtpFlow.forgot) {
        context.go(
          '/setup-password',
          extra: const SetupPasswordPageArgs(
            title: 'Password Baru',
            subtitle:
                'Buat password baru untuk akun member. Password ini dipakai saat login berikutnya.',
            showSkip: false,
          ),
        );
        return;
      }

      if (widget.args.flow == OtpFlow.activation) {
        await _showWelcomeDialog(result.member.fullname);
        if (!mounted) return;
        context.go('/pets');
        return;
      }

      context.go('/pets');
    } on DioException catch (e) {
      setState(
        () => _error =
            e.response?.data?['message']?.toString() ??
            'OTP gagal diverifikasi',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showWelcomeDialog(String name) {
    final displayName = name.trim().isEmpty ? 'Member Booboo' : name.trim();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.7, end: 1),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.softPurple,
                child: Icon(
                  Icons.verified_rounded,
                  color: AppColors.primary,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Selamat datang'),
          ],
        ),
        content: Text(
          'Halo $displayName, akun member kamu berhasil diaktifkan. Sekarang kamu bisa melihat data anabul dan riwayat perawatan.',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mulai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final debugOtp = widget.args.result.debugOtp;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 32),
            Text(
              'Verifikasi OTP',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan kode OTP yang dikirim ke ${widget.args.result.phone}.',
            ),
            if (debugOtp != null) ...[
              const SizedBox(height: 12),
              Chip(
                avatar: const Icon(Icons.code_rounded, size: 18),
                label: Text('Dev OTP: $debugOtp'),
              ),
            ],
            const SizedBox(height: 28),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _otp,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.password),
                labelText: 'Kode OTP',
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _loading ? null : _verify,
              child: _loading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verifikasi'),
            ),
          ],
        ),
      ),
    );
  }
}
