import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/auth/token_storage.dart';
import 'package:handlerclaw/shared/utils/logger.dart';
import 'package:handlerclaw/features/auth/data/auth_api.dart';
import 'package:handlerclaw/features/auth/data/dto/user_dto.dart';

class AuthSession {
  final String? token;
  final UserDto? userDto;

  const AuthSession({this.token, this.userDto});

  factory AuthSession.unauthenticated() {
    return const AuthSession();
  }

  factory AuthSession.authenticated(String token, UserDto userDto) {
    
    return AuthSession(token: token, userDto: userDto);
  }

  bool get isAuthenticated => token != null && userDto != null;
  bool get isUserDataReady => token != null && userDto != null;
}

class AuthSessionController extends AsyncNotifier<AuthSession> {
  @override
  Future<AuthSession> build() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final token = await tokenStorage.getToken();

    if (token == null) {
      Logger.debug("AuthSession: No token found. Unauthenticated.");
      return AuthSession.unauthenticated();
    }

    final cachedUser = await tokenStorage.getUser();
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
            await tokenStorage.clear();
            state = AsyncData(AuthSession.unauthenticated());

            return;
          }

          Logger.debug("AuthSession: User refreshed from NETWORK.");
          state = AsyncData(
            AuthSession.authenticated(token, apiResponse.data!.user),
          );
        } catch (_) {
          Logger.error(
            "AuthSession: Error refreshing user from NETWORK background refresh. Clearing session.",
          );
          await tokenStorage.clear();
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
        await tokenStorage.clear();
        return AuthSession.unauthenticated();
      }

      Logger.debug("AuthSession: User loaded from NETWORK.");
      return AuthSession.authenticated(token, apiResponse.data!.user);
    } catch (_) {
      Logger.error(
        "AuthSession: Error fetching user from NETWORK. Clearing session.",
      );
      await tokenStorage.clear();
      return AuthSession.unauthenticated();
    }
  }

  Future<void> setSession(String token, UserDto user) async {
    final tokenStorage = ref.read(tokenStorageProvider);

    await tokenStorage.saveToken(token);
    await tokenStorage.saveUser(user);

    state = AsyncData(AuthSession.authenticated(token, user));
  }

  Future<void> logout() async {
    final tokenStorage = ref.read(tokenStorageProvider);

    await tokenStorage.clear();

    state = AsyncData(AuthSession.unauthenticated());
  }
}