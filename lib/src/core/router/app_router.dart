import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/otp_page.dart';
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
            path: '/profile',
            builder: (context, state) => const HomePage(initialTab: 2),
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/otp',
        builder: (context, state) => OtpPage(args: state.extra as OtpPageArgs),
      ),
      GoRoute(
        path: '/pets/:id',
        builder: (context, state) =>
            PetDetailPage(petId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/pets/:id/edit',
        builder: (context, state) =>
            EditPetPage(petId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/profile/password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/histories/:id',
        builder: (context, state) => HistoryDetailPage(
          historyId: int.parse(state.pathParameters['id']!),
        ),
      ),
    ],
  );
});
