import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/whatsapp_launcher.dart';
import '../../auth/application/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return SafeArea(
      child: auth.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            _LoggedOut(onLogin: () => context.push('/login')),
        data: (member) {
          if (member == null) {
            return _LoggedOut(onLogin: () => context.push('/login'));
          }
          final initials = member.fullname
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((part) => part.characters.first.toUpperCase())
              .join();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.24),
                      blurRadius: 30,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      member.fullname,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      member.phone,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              member.address.isEmpty
                                  ? 'Alamat belum diisi'
                                  : member.address,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Edit Profil'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/profile/edit'),
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.lock_reset_outlined),
                      title: const Text('Ganti Password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/profile/password'),
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.support_agent),
                      title: const Text('Bantuan WhatsApp'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openWhatsapp(context),
                    ),
                    const Divider(height: 0),
                    const ListTile(
                      leading: Icon(Icons.shield_outlined),
                      title: Text('Kebijakan Privasi'),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: AppColors.danger,
                      ),
                      title: const Text(
                        'Keluar',
                        style: TextStyle(color: AppColors.danger),
                      ),
                      onTap: () =>
                          ref.read(authControllerProvider.notifier).logout(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openWhatsapp(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await openBoobooWhatsapp(
      'Halo Booboo Pet Care, saya butuh bantuan untuk aplikasi member.',
    );
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('WhatsApp tidak bisa dibuka')),
      );
    }
  }
}

class _LoggedOut extends StatelessWidget {
  const _LoggedOut({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.softPurple,
              child: Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Masuk untuk melihat profil',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Data anabul dan riwayat perawatan tersedia setelah login.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            FilledButton(onPressed: onLogin, child: const Text('Masuk')),
          ],
        ),
      ),
    );
  }
}
