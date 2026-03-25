import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/error/api_exception.dart';
import 'package:handlerclaw/core/provider/auth_session_provider.dart';
import 'package:handlerclaw/features/login/data/auth_api.dart';

class LoginController {
  final Ref ref;

  LoginController(this.ref);

  Future<String> loginWithEmailAndPassword(String email, String password) async {
    final authApi = ref.read(authApiProvider);

    final loginResponse = await authApi.login(email, password);

    if (!loginResponse.success) {
      throw ApiException(loginResponse.message);
    }

    final loginData = loginResponse.data;

    final accessToken = loginData!.accessToken;
    final user = loginData.user;

    await ref.read(authSessionProvider.notifier).setSession(accessToken, user);

    return loginResponse.message;
  }
}
