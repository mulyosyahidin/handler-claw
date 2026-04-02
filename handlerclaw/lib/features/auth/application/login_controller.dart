import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:handlerclaw/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/auth/application/google_auth_service.dart';
import 'package:handlerclaw/core/errors/api_exception.dart';
import 'package:handlerclaw/core/providers/auth_session_provider.dart';
import 'package:handlerclaw/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:handlerclaw/features/auth/data/repositories/device_repository_impl.dart';
import 'package:handlerclaw/features/auth/domain/repositories/auth_repository.dart';
import 'package:handlerclaw/features/auth/domain/repositories/device_repository.dart';
import 'dart:io';
import 'package:handlerclaw/core/providers/firebase_messaging_provider.dart';
import 'package:handlerclaw/core/services/device_id_service.dart';
import 'package:handlerclaw/core/services/device_info_plus_service.dart';

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
  Future<String> loginWithGoogle(String idToken) async {
    Logger.info(
      'Proceeding to login with Google ID Token: ${idToken.substring(0, 10)}...',
    );

    // Collect device info for registration during login
    Map<String, dynamic>? deviceInfoMap;
    try {
      final fcmToken = await _ref.read(firebaseMessagingProvider).getToken();
      final deviceInfo = await _ref.read(deviceInfoPlusServiceProvider).getDeviceInfo();
      final deviceId = await _ref.read(deviceIdServiceProvider).getDeviceId();

      deviceInfoMap = {
        "device_id": deviceId,
        "fcm_token": fcmToken,
        "platform": Platform.isAndroid ? "ANDROID" : (Platform.isIOS ? "IOS" : "WEB"),
        "device_brand": deviceInfo["device_brand"],
        "device_model": deviceInfo["device_model"],
        "os_version": deviceInfo["os_version"],
        "os_build_id": deviceInfo["os_build_id"],
      };
    } catch (e, stackTrace) {
      Logger.error("Error collecting device info for Google Login: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'LoginController.loginWithGoogle (Device Info)',
      );
      // Continue without device info if collection fails
    }

    final result = await _authRepository.loginWithGoogle(
      idToken,
      deviceInfo: deviceInfoMap,
    );

    if (!result.success) {
      Logger.error('Google Login failed: ${result.message}');

      throw ApiException(result.message);
    }

    final accessToken = result.accessToken!;
    final user = result.user!;

    await _ref.read(authSessionProvider.notifier).setSession(accessToken, user);

    return result.message;
  }

  Future<void> logout() async {
    try {
      // 1. Mark device as logged out in the backend
      await _deviceRepository.markAsLogout();
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'LoginController.logout',
      );
      // Silent fail - continue logout anyway
    }

    // 2. Clear local storage (token and user data) via repository
    await _authRepository.logout();

    // 3. Reset the session state in UI
    await _ref.read(authSessionProvider.notifier).logout();
  }
}

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});

final loginControllerProvider = Provider<LoginController>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  final deviceRepository = ref.read(deviceRepositoryProvider);

  return LoginController(authRepository, deviceRepository, ref);
});
