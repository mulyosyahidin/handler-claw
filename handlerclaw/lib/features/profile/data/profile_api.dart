import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/shared/utils/logger.dart';
import 'package:handlerclaw/features/profile/data/response/profile_update_response_dto.dart';
import 'package:handlerclaw/features/profile/data/response/password_update_response_dto.dart';

class ProfileApi {
  final Dio dio;

  ProfileApi(this.dio);

  Future<ProfileUpdateResponseDto> updateProfile({
    required String name,
    required String email,
  }) async {
    const endpoint = ApiEndpoint.profileUpdate;

    try {
      Logger.api("PATCH", endpoint);

      final response = await dio.patch(
        endpoint,
        data: {
          'name': name,
          'email': email,
        },
      );

      return ProfileUpdateResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint");
      if (e.response != null) {
        return ProfileUpdateResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error: $e");
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

      final response = await dio.patch(
        endpoint,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_new_password': confirmNewPassword,
        },
      );

      return PasswordUpdateResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint");
      if (e.response != null) {
        return PasswordUpdateResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error: $e");
      rethrow;
    }
  }
}

final profileApiProvider = Provider<ProfileApi>((ref) {
  final dio = ref.read(dioProvider);
  return ProfileApi(dio);
});
