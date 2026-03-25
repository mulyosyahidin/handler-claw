import 'package:dio/dio.dart';
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
              "AuthSession: Invalid token from NETWORK background refresh (null data). Clearing session.",
            );
            await tokenStorage.clear();
            state = AsyncData(AuthSession.unauthenticated());
            return;
          }

          Logger.debug("AuthSession: User refreshed from NETWORK.");
          state = AsyncData(
            AuthSession.authenticated(token, apiResponse.data!.user),
          );
        } on DioException catch (e) {
          final statusCode = e.response?.statusCode;
          if (statusCode == 401) {
            Logger.warning(
              "AuthSession: Session expired (401). Clearing session.",
            );
            await tokenStorage.clear();
            state = AsyncData(AuthSession.unauthenticated());
          } else {
            Logger.warning(
              "AuthSession: Network error during background refresh (Code: $statusCode). Keeping existing session.",
            );
          }
        } catch (e) {
          Logger.error(
            "AuthSession: Unexpected error during background refresh. Keeping existing session.",
          );
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
          "AuthSession: Invalid token from NETWORK (null data). Clearing session.",
        );
        await tokenStorage.clear();
        return AuthSession.unauthenticated();
      }

      Logger.debug("AuthSession: User loaded from NETWORK.");
      return AuthSession.authenticated(token, apiResponse.data!.user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        Logger.warning(
          "AuthSession: Invalid token (401). Clearing session.",
        );
        await tokenStorage.clear();
      } else {
        Logger.error(
          "AuthSession: Network error fetching user. Keeping token in storage for retry.",
        );
      }
      return AuthSession.unauthenticated();
    } catch (e) {
      Logger.error(
        "AuthSession: Unexpected error fetching user. Keeping token in storage for retry.",
      );
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