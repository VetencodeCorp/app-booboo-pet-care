import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/activate_member_page.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/otp_page.dart';
import '../../features/auth/presentation/setup_password_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/pets/presentation/edit_pet_page.dart';
import '../../features/pets/presentation/history_detail_page.dart';
import '../../features/pets/presentation/pet_detail_page.dart';
import '../../features/profile/presentation/change_password_page.dart';
import '../../features/profile/presentation/edit_profile_page.dart';
import '../../features/shell/presentation/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/pets',
            builder: (context, state) => const HomePage(initialTab: 1),
          ),
          GoRoute(
            path: '/histories',
            builder: (context, state) => const HomePage(initialTab: 2),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const HomePage(initialTab: 3),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const LoginPage()),
      ),
      GoRoute(
        path: '/activate-member',
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const ActivateMemberPage()),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const ForgotPasswordPage()),
      ),
      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: OtpPage(args: state.extra as OtpPageArgs),
        ),
      ),
      GoRoute(
        path: '/setup-password',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: SetupPasswordPage(
            args:
                state.extra as SetupPasswordPageArgs? ??
                const SetupPasswordPageArgs(),
          ),
        ),
      ),
      GoRoute(
        path: '/pets/:id',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: PetDetailPage(petId: int.parse(state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: '/pets/:id/edit',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: EditPetPage(petId: int.parse(state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const EditProfilePage()),
      ),
      GoRoute(
        path: '/profile/password',
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const ChangePasswordPage()),
      ),
      GoRoute(
        path: '/histories/:id',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: HistoryDetailPage(
            historyId: int.parse(state.pathParameters['id']!),
          ),
        ),
      ),
    ],
  );
});

CustomTransitionPage<void> _slidePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.06, 0.02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
