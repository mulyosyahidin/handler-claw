import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/auth/token_storage.dart';
import 'package:handlerclaw/core/utils/logger.dart';
import 'package:handlerclaw/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:handlerclaw/core/domain/entities/user_entity.dart';
import 'package:handlerclaw/core/data/mappers/user_mapper.dart';

class AuthSession {
  final String? token;
  final UserEntity? user;

  const AuthSession({this.token, this.user});

  factory AuthSession.unauthenticated() {
    return const AuthSession();
  }

  factory AuthSession.authenticated(String token, UserEntity user) {
    return AuthSession(token: token, user: user);
  }

  bool get isAuthenticated => token != null && user != null;
  bool get isUserDataReady => token != null && user != null;
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

    try {
      Logger.debug("AuthSession: Verifying token with NETWORK.");

      final authRemoteDataSource = ref.read(authRemoteDataSourceProvider);
      final apiResponse = await authRemoteDataSource.getMe();

      if (apiResponse.data == null) {
        Logger.warning(
          "AuthSession: Invalid token (null data). Clearing session.",
        );

        await tokenStorage.clear();
        return AuthSession.unauthenticated();
      }

      Logger.debug("AuthSession: User verified from NETWORK.");
      final userEntity = UserMapper.fromDto(apiResponse.data!.user);

      await tokenStorage.saveUser(userEntity);

      return AuthSession.authenticated(token, userEntity);
    } on DioException catch (e, stackTrace) {
      final statusCode = e.response?.statusCode;

      if (statusCode != 401) {
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'AuthSessionController.build (DioException)',
        );
      }

      if (statusCode == 401) {
        Logger.warning("AuthSession: Session expired (401). Clearing session.");
        await tokenStorage.clear();
        return AuthSession.unauthenticated();
      }

      if (cachedUser != null) {
        Logger.warning(
          "AuthSession: Network error (Code: $statusCode). Using CACHED user for offline support.",
        );
        return AuthSession.authenticated(token, cachedUser);
      }

      Logger.error(
        "AuthSession: Network error and no cached user. Returning unauthenticated.",
      );
      return AuthSession.unauthenticated();
    } catch (e, stackTrace) {
      Logger.error("AuthSession: Unexpected error: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AuthSessionController.build (Unexpected)',
      );
      if (cachedUser != null) {
        Logger.warning("AuthSession: Falling back to CACHED user.");
        return AuthSession.authenticated(token, cachedUser);
      }

      return AuthSession.unauthenticated();
    }
  }

  Future<void> setSession(String token, UserEntity user) async {
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
