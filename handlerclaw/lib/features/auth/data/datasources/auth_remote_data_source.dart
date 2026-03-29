import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/features/auth/data/responses/login_response_dto.dart';
import 'package:handlerclaw/features/auth/data/responses/me_response_dto.dart';
import 'package:handlerclaw/core/utils/logger.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseDto> login(String email, String password);
  Future<LoginResponseDto> loginWithGoogle(
    String idToken, {
    Map<String, dynamic>? deviceInfo,
  });
  Future<MeResponseDto> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
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
      _handleDioError(e, endpoint);
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error: $e");
      rethrow;
    }
  }

  @override
  Future<LoginResponseDto> loginWithGoogle(
    String idToken, {
    Map<String, dynamic>? deviceInfo,
  }) async {
    const endpoint = ApiEndpoint.authGoogle;
    try {
      Logger.api("POST", endpoint);

      final Map<String, dynamic> data = {"id_token": idToken};
      if (deviceInfo != null) {
        data.addAll(deviceInfo);
      }

      final response = await dio.post(endpoint, data: data);
      return LoginResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioError(e, endpoint);
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error: $e");
      rethrow;
    }
  }

  @override
  Future<MeResponseDto> getMe() async {
    const endpoint = ApiEndpoint.authMe;
    try {
      Logger.api("GET", endpoint);
      final response = await dio.get(endpoint);
      return MeResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioError(e, endpoint);
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error: $e");
      rethrow;
    }
  }

  void _handleDioError(DioException e, String endpoint) {
    Logger.error("Api Error on endpoint $endpoint");
    if (e.response != null) {
      Logger.error("Status code: ${e.response?.statusCode}");
      Logger.error("Response body: ${e.response?.data}");
    } else {
      Logger.error("Network error: ${e.message}");
    }
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return AuthRemoteDataSourceImpl(dio);
});
