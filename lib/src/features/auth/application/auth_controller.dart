import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/member.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, Member?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<Member?> {
  @override
  Future<Member?> build() {
    return ref.watch(authRepositoryProvider).me();
  }

  Future<LoginOtpResult> login(String phone, String password) {
    return ref.read(authRepositoryProvider).login(phone, password);
  }

  Future<void> verifyOtp(String token, String code) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).verifyOtp(token, code),
    );
  }

  Future<void> updateProfile({
    required String fullname,
    required String address,
  }) async {
    final updated = await ref
        .read(authRepositoryProvider)
        .updateProfile(fullname: fullname, address: address);
    state = AsyncData(updated);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  }) {
    return ref
        .read(authRepositoryProvider)
        .changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
          confirmation: confirmation,
        );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
