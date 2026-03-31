import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/features/profile/data/responses/password_update_response_dto.dart';
import 'package:handlerclaw/features/profile/data/responses/profile_update_response_dto.dart';
import 'package:handlerclaw/core/utils/logger.dart';

class ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSource(this._dio);

  Future<ProfileUpdateResponseDto> updateProfile({
    required String name,
    required String email,
  }) async {
    const endpoint = ApiEndpoint.profileUpdate;

    try {
      Logger.api("PATCH", endpoint);

      final response = await _dio.patch(
        endpoint,
        data: {
          'name': name,
          'email': email,
        },
      );

      return ProfileUpdateResponseDto.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'ProfileRemoteDataSource.updateProfile (DioException)',
      );
      if (e.response != null) {
        return ProfileUpdateResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'ProfileRemoteDataSource.updateProfile (Unexpected)',
      );
      rethrow;
    }
  }

  Future<PasswordUpdateResponseDto> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    const endpoint = ApiEndpoint.profilePassword;

    try {
      Logger.api("PATCH", endpoint);

      final response = await _dio.patch(
        endpoint,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_new_password': confirmNewPassword,
        },
      );

      return PasswordUpdateResponseDto.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'ProfileRemoteDataSource.updatePassword (DioException)',
      );
      if (e.response != null) {
        return PasswordUpdateResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'ProfileRemoteDataSource.updatePassword (Unexpected)',
      );
      rethrow;
    }
  }

  Future<ProfileUpdateResponseDto> updateAvatar({
    required String avatarUrl,
  }) async {
    const endpoint = ApiEndpoint.profileAvatar;

    try {
      Logger.api("PATCH", endpoint);

      final response = await _dio.patch(
        endpoint,
        data: {
          'avatar_url': avatarUrl,
        },
      );

      return ProfileUpdateResponseDto.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'ProfileRemoteDataSource.updateAvatar (DioException)',
      );
      if (e.response != null) {
        return ProfileUpdateResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'ProfileRemoteDataSource.updateAvatar (Unexpected)',
      );
      rethrow;
    }
  }
}

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return ProfileRemoteDataSource(dio);
});
