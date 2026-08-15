import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/member.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

class LoginOtpResult {
  const LoginOtpResult({
    required this.otpToken,
    required this.phone,
    required this.expiredAt,
    this.debugOtp,
  });

  final String otpToken;
  final String phone;
  final String expiredAt;
  final String? debugOtp;

  factory LoginOtpResult.fromJson(Map<String, dynamic> json) {
    return LoginOtpResult(
      otpToken: json['otp_token']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      expiredAt: json['expired_at']?.toString() ?? '',
      debugOtp: json['debug_otp']?.toString(),
    );
  }
}

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  Future<LoginOtpResult> login(String phone, String password) async {
    final response = await _client.dio.post(
      '/api/auth/login',
      data: {'phone': phone, 'password': password},
    );
    return LoginOtpResult.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<Member> verifyOtp(String otpToken, String otpCode) async {
    final response = await _client.dio.post(
      '/api/auth/verify-otp',
      data: {'otp_token': otpToken, 'otp_code': otpCode},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    await _client.saveToken(data['access_token'].toString());
    return Member.fromJson(data['member'] as Map<String, dynamic>);
  }

  Future<Member?> me() async {
    final token = await _client.token();
    if (token == null) return null;
    try {
      final response = await _client.dio.get('/api/me');
      return Member.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException {
      await _client.clearToken();
      return null;
    }
  }

  Future<Member> updateProfile({
    required String fullname,
    required String address,
  }) async {
    final response = await _client.dio.put(
      '/api/me',
      data: {'fullname': fullname, 'address': address},
    );
    return Member.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  }) async {
    await _client.dio.post(
      '/api/me/password',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmation,
      },
    );
  }

  Future<void> logout() => _client.clearToken();
}
