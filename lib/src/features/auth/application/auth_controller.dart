import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/member.dart';
import '../../pets/data/pets_repository.dart';

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

  Future<LoginOtpResult> activateMember(String phone) {
    return ref.read(authRepositoryProvider).activateMember(phone);
  }

  Future<LoginOtpResult> forgotPassword(String phone) {
    return ref.read(authRepositoryProvider).forgotPassword(phone);
  }

  Future<VerifyOtpResult> verifyOtp(String token, String code) async {
    state = const AsyncLoading();
    final result = await ref
        .read(authRepositoryProvider)
        .verifyOtp(token, code);
    state = AsyncData(result.member);
    _resetPetCaches();
    return result;
  }

  Future<void> setupPassword({
    required String newPassword,
    required String confirmation,
  }) async {
    await ref
        .read(authRepositoryProvider)
        .setupPassword(newPassword: newPassword, confirmation: confirmation);
    final member = await ref.read(authRepositoryProvider).me();
    state = AsyncData(member);
    _resetPetCaches();
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
    _resetPetCaches();
    state = const AsyncData(null);
  }

  void _resetPetCaches() {
    ref.invalidate(petsProvider);
    ref.invalidate(pagedPetsProvider);
    ref.invalidate(petOptionsProvider);
    ref.invalidate(allHistoriesProvider);
    ref.invalidate(pagedHistoriesProvider);
    ref.invalidate(petProvider);
    ref.invalidate(petHistoriesProvider);
    ref.invalidate(historyDetailProvider);
  }
}
