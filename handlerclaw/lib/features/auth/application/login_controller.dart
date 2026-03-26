import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/errors/api_exception.dart';
import 'package:handlerclaw/core/providers/auth_session_provider.dart';
import 'package:handlerclaw/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:handlerclaw/features/auth/data/repositories/device_repository_impl.dart';
import 'package:handlerclaw/features/auth/domain/repositories/auth_repository.dart';
import 'package:handlerclaw/features/auth/domain/repositories/device_repository.dart';

class LoginController {
  final AuthRepository _authRepository;
  final DeviceRepository _deviceRepository;
  final Ref _ref;

  LoginController(this._authRepository, this._deviceRepository, this._ref);

  Future<String> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final result = await _authRepository.login(email, password);

    if (!result.success) {
      throw ApiException(result.message);
    }

    final accessToken = result.accessToken!;
    final user = result.user!;

    await _ref.read(authSessionProvider.notifier).setSession(accessToken, user);
    await _deviceRepository.registerDevice();

    return result.message;
  }

  Future<void> logout() async {
    try {
      // 1. Mark device as logged out in the backend
      await _deviceRepository.markAsLogout();
    } catch (e) {
      // Silent fail - continue logout anyway
    }

    // 2. Clear local storage (token and user data) via repository
    await _authRepository.logout();

    // 3. Reset the session state in UI
    await _ref.read(authSessionProvider.notifier).logout();
  }
}

final loginControllerProvider = Provider<LoginController>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  final deviceRepository = ref.read(deviceRepositoryProvider);

  return LoginController(authRepository, deviceRepository, ref);
});
