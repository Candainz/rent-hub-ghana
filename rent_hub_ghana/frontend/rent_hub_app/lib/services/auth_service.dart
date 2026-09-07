import 'api_service.dart';
import '../models/user.dart';
import 'package:local_auth/local_auth.dart';

final authService = AuthService();

class AuthService {
  AuthService({ApiService? api}) : api = api ?? ApiService();
  final ApiService api;
  String? token;
  AppUser? user;
  final LocalAuthentication biometric = LocalAuthentication();

  bool get isSignedIn => token != null && user != null;

  Future<bool> canUseBiometric() async {
    try {
      return await biometric.isDeviceSupported() &&
          await biometric.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateBiometric() async {
    try {
      if (!await canUseBiometric()) {
        return false;
      }
      return await biometric
          .authenticate(
            localizedReason: 'Verify your identity to open Rent Hub Ghana',
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true,
            ),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      return false;
    }
  }

  void signOut() {
    token = null;
    user = null;
  }

  Future<AppUser> login(String username, String password) async {
    final data = await api.login(username, password);
    token = data['token'] as String;
    user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    return user!;
  }

  Future<AppUser> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String phone = '',
    String organizationName = '',
    String confirmationCode = '',
    String recoveryQuestion = '',
    String recoveryAnswer = '',
  }) async {
    final data = await api.register({
      'username': username,
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'phone': phone,
      'organization_name': organizationName,
      if (confirmationCode.trim().isNotEmpty) 'confirmation_code': confirmationCode.trim(),
      'recovery_question': recoveryQuestion.trim(),
      'recovery_answer': recoveryAnswer.trim(),
    });
    token = data['token'] as String;
    user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    return user!;
  }

  Future<AppUser> updateProfile({
    String? email,
    String? phone,
    String? password,
    String? firstName,
    String? lastName,
  }) async {
    final payload = <String, dynamic>{};
    if (email != null) payload['email'] = email.trim();
    if (phone != null) payload['phone'] = phone.trim();
    if (password != null && password.trim().isNotEmpty) {
      payload['password'] = password.trim();
    }
    if (firstName != null) payload['first_name'] = firstName.trim();
    if (lastName != null) payload['last_name'] = lastName.trim();

    if (payload.isEmpty) {
      return user!;
    }

    final response = await ApiService(token: token).updateCurrentUser(payload);
    user = AppUser.fromJson(response);
    return user!;
  }
}
