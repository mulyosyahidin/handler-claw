import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/provider/dio_provider.dart';
import 'package:handlerclaw/core/utils/logger.dart';
import 'package:handlerclaw/features/login/data/response/login_response_dto.dart';
import 'package:handlerclaw/features/login/data/response/me_response_dto.dart';

class AuthApi {
  final Dio dio;

  AuthApi(this.dio);

  Future<LoginResponseDto> login(String email, String password) async {
    const endpoint = ApiEndpoint.authLogin;

    try {
      Logger.api("POST", endpoint);

      final response = await dio.post(
        endpoint,
        data: {"email": email, "password": password},
      );

      return LoginResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint");

      if (e.response != null) {
        Logger.error("Status code: ${e.response?.statusCode}");
        Logger.error("Response body: ${e.response?.data}");
      } else {
        Logger.error("Network error: ${e.message}");
      }

      rethrow;
    } catch (e) {
      Logger.error("Unexpected error: $e");
      rethrow;
    }
  }

  Future<MeResponseDto> getMe() async {
    const endpoint = ApiEndpoint.authMe;

    try {
      Logger.api("GET", endpoint);

      final response = await dio.get(endpoint);

      return MeResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint");

      if (e.response != null) {
        Logger.error("Status code: ${e.response?.statusCode}");
        Logger.error("Response body: ${e.response?.data}");
      } else {
        Logger.error("Network error: ${e.message}");
      }

      rethrow;
    } catch (e) {
      Logger.error("Unexpected error: $e");
      rethrow;
    }
  }
}

final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.read(dioProvider);

  return AuthApi(dio);
});
