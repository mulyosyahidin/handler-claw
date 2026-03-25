import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/errors/api_exception.dart';
import 'package:handlerclaw/core/providers/auth_session_provider.dart';
import 'package:handlerclaw/features/auth/data/auth_api.dart';
import 'package:handlerclaw/features/auth/data/device_api.dart';

class LoginController {
  final Ref ref;

  LoginController(this.ref);

  Future<String> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final authApi = ref.read(authApiProvider);
    final deviceApi = ref.read(deviceApiProvider);

    final loginResponse = await authApi.login(email, password);

    if (!loginResponse.success) {
      throw ApiException(loginResponse.message);
    }

    final loginData = loginResponse.data;

    final accessToken = loginData!.accessToken;
    final user = loginData.user;

    await ref.read(authSessionProvider.notifier).setSession(accessToken, user);
    await deviceApi.registerDevice();

    return loginResponse.message;
  }

  Future<void> logout() async {
    final deviceApi = ref.read(deviceApiProvider);

    try {
      await deviceApi.markAsLogout();
    } catch (e) {
      // Silent fail - tetap logout meskipun gagal
    }

    ref.read(authSessionProvider.notifier).logout();
  }
}

final loginControllerProvider = Provider<LoginController>((ref) {
  return LoginController(ref);
});