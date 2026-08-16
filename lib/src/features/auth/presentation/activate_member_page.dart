import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../application/auth_controller.dart';
import 'otp_page.dart';

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
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 32),
            Text(
              'Aktivasi Member Lama',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan nomor HP yang sudah terdaftar di Booboo Pet Care. Kami kirim OTP untuk masuk pertama kali.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
              const SizedBox(height: 12),
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
            FilledButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sms_outlined),
              label: const Text('Kirim OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
