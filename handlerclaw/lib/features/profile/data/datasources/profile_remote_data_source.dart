import 'package:dio/dio.dart';
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
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      if (e.response != null) {
        return ProfileUpdateResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
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
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      if (e.response != null) {
        return PasswordUpdateResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      rethrow;
    }
  }
}

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return ProfileRemoteDataSource(dio);
});
