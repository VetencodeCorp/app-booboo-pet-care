import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/whatsapp_launcher.dart';
import '../../../shared/widgets/animated_entry.dart';
import '../../../shared/widgets/premium_action_button.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/member.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return SafeArea(
      child: auth.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _LoggedOut(
          onLogin: () => context.push('/login'),
          onWhatsapp: () => _openWhatsapp(context),
          onPrivacy: () => context.push('/privacy-policy'),
        ),
        data: (member) {
          if (member == null) {
            return _LoggedOut(
              onLogin: () => context.push('/login'),
              onWhatsapp: () => _openWhatsapp(context),
              onPrivacy: () => context.push('/privacy-policy'),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              AnimatedEntry(
                delay: const Duration(milliseconds: 60),
                child: _ProfileHero(member: member),
              ),
              const SizedBox(height: 18),
              AnimatedEntry(
                delay: const Duration(milliseconds: 120),
                child: _ProfileMenu(
                  onEdit: () => context.push('/profile/edit'),
                  onPassword: () => context.push('/profile/password'),
                  onWhatsapp: () => _openWhatsapp(context),
                  onPrivacy: () => context.push('/privacy-policy'),
                  onLogout: () =>
                      ref.read(authControllerProvider.notifier).logout(),
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(member.fullname);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), AppColors.lavender],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(
              Icons.person_rounded,
              size: 132,
              color: AppColors.primary.withValues(alpha: 0.07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.softPurple,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Member Booboo',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          member.fullname,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          member.phone,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _InfoPill(
                icon: Icons.location_on_outlined,
                text: member.address.isEmpty
                    ? 'Alamat belum diisi'
                    : member.address,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    final value = parts
        .take(2)
        .map((part) => part.characters.first.toUpperCase())
        .join();
    return value.isEmpty ? 'B' : value;
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({
    required this.onEdit,
    required this.onPassword,
    required this.onWhatsapp,
    required this.onPrivacy,
    required this.onLogout,
  });

  final VoidCallback onEdit;
  final VoidCallback onPassword;
  final VoidCallback onWhatsapp;
  final VoidCallback onPrivacy;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProfileTile(
            icon: Icons.edit_outlined,
            title: 'Edit Profil',
            subtitle: 'Ubah nama dan alamat',
            onTap: onEdit,
          ),
          const _SoftDivider(),
          _ProfileTile(
            icon: Icons.lock_reset_outlined,
            title: 'Ganti Password',
            subtitle: 'Perbarui keamanan akun',
            onTap: onPassword,
          ),
          const _SoftDivider(),
          _ProfileTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Bantuan WhatsApp',
            subtitle: 'Hubungi admin Booboo',
            onTap: onWhatsapp,
          ),
          const _SoftDivider(),
          _ProfileTile(
            icon: Icons.shield_outlined,
            title: 'Kebijakan Privasi',
            subtitle: 'Cara Booboo menjaga data member',
            onTap: onPrivacy,
          ),
          const _SoftDivider(),
          _ProfileTile(
            icon: Icons.logout_rounded,
            title: 'Keluar',
            subtitle: 'Hapus sesi dari perangkat ini',
            danger: true,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: danger
                            ? AppColors.danger
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: danger
                    ? AppColors.danger.withValues(alpha: 0.7)
                    : AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 70,
      endIndent: 16,
      color: AppColors.border.withValues(alpha: 0.8),
    );
  }
}

class _LoggedOut extends StatelessWidget {
  const _LoggedOut({
    required this.onLogin,
    required this.onWhatsapp,
    required this.onPrivacy,
  });

  final VoidCallback onLogin;
  final VoidCallback onWhatsapp;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        AnimatedEntry(
          delay: const Duration(milliseconds: 60),
          child: _GuestHero(onLogin: onLogin),
        ),
        const SizedBox(height: 18),
        AnimatedEntry(
          delay: const Duration(milliseconds: 120),
          child: _GuestMenu(
            onLogin: onLogin,
            onWhatsapp: onWhatsapp,
            onPrivacy: onPrivacy,
          ),
        ),
      ],
    );
  }
}

class _GuestHero extends StatelessWidget {
  const _GuestHero({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), AppColors.lavender],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(
              Icons.person_rounded,
              size: 132,
              color: AppColors.primary.withValues(alpha: 0.07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.softPurple,
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.softPurple,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Belum Login',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Pengguna Booboo',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Masuk untuk melihat profil member.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const _InfoPill(
                icon: Icons.info_outline_rounded,
                text:
                    'Login dibutuhkan untuk membuka data anabul, riwayat perawatan, edit profil, dan ganti password.',
              ),
              const SizedBox(height: 18),
              PremiumActionButton(
                label: 'Masuk Sekarang',
                icon: Icons.login_rounded,
                onPressed: onLogin,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuestMenu extends StatelessWidget {
  const _GuestMenu({
    required this.onLogin,
    required this.onWhatsapp,
    required this.onPrivacy,
  });

  final VoidCallback onLogin;
  final VoidCallback onWhatsapp;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProfileTile(
            icon: Icons.login_rounded,
            title: 'Masuk Member',
            subtitle: 'Akses profil dan riwayat anabul',
            onTap: onLogin,
          ),
          const _SoftDivider(),
          _ProfileTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Bantuan WhatsApp',
            subtitle: 'Hubungi admin Booboo',
            onTap: onWhatsapp,
          ),
          const _SoftDivider(),
          _ProfileTile(
            icon: Icons.shield_outlined,
            title: 'Kebijakan Privasi',
            subtitle: 'Cara Booboo menjaga data member',
            onTap: onPrivacy,
          ),
        ],
      ),
    );
  }
}
