import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/auth/auth_session.dart';
import 'package:handlerclaw/core/auth/session_storage_provider.dart';
import 'package:handlerclaw/core/data/dto/user_dto.dart';
import 'package:handlerclaw/core/utils/logger.dart';
import 'package:handlerclaw/features/login/data/auth_api.dart';

class AuthSessionController extends AsyncNotifier<AuthSession> {
  @override
  Future<AuthSession> build() async {
    final sessionStorage = ref.read(sessionStorageProvider);
    final token = await sessionStorage.getToken();

    if (token == null) {
      Logger.debug("AuthSession: No token found. Unauthenticated.");
      return AuthSession.unauthenticated();
    }

    final cachedUser = await sessionStorage.getUser();
    if (cachedUser != null) {
      Logger.debug("AuthSession: Loading user from CACHE.");
      Future.microtask(() async {
        try {
          final authApi = ref.read(authApiProvider);
          final apiResponse = await authApi.getMe();

          if (apiResponse.data == null) {
            Logger.warning(
              "AuthSession: Invalid token from NETWORK background refresh. Clearing session.",
            );
            await sessionStorage.clear();
            state = AsyncData(AuthSession.unauthenticated());

            return;
          }

          Logger.debug("AuthSession: User refreshed from NETWORK.");
          state = AsyncData(
            AuthSession.authenticated(token, apiResponse.data!),
          );
        } catch (_) {
          Logger.error(
            "AuthSession: Error refreshing user from NETWORK background refresh. Clearing session.",
          );
          await sessionStorage.clear();
          state = AsyncData(AuthSession.unauthenticated());
        }
      });

      return AuthSession.authenticated(token, cachedUser);
    }

    try {
      Logger.debug("AuthSession: No cached user found. Fetching from NETWORK.");

      final authApi = ref.read(authApiProvider);
      final apiResponse = await authApi.getMe();

      if (apiResponse.data == null) {
        Logger.warning(
          "AuthSession: Invalid token from NETWORK. Clearing session.",
        );
        await sessionStorage.clear();
        return AuthSession.unauthenticated();
      }

      Logger.debug("AuthSession: User loaded from NETWORK.");
      return AuthSession.authenticated(token, apiResponse.data!);
    } catch (_) {
      Logger.error(
        "AuthSession: Error fetching user from NETWORK. Clearing session.",
      );
      await sessionStorage.clear();
      return AuthSession.unauthenticated();
    }
  }

  Future<void> setSession(String token, UserDto user) async {
    final sessionStorage = ref.read(sessionStorageProvider);

    await sessionStorage.saveToken(token);
    await sessionStorage.saveUser(user);

    state = AsyncData(AuthSession.authenticated(token, user));
  }

  Future<void> logout() async {
    final sessionStorage = ref.read(sessionStorageProvider);

    await sessionStorage.clear();

    state = AsyncData(AuthSession.unauthenticated());
  }
}
