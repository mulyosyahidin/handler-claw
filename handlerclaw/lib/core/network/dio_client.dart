import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/env.dart';
import 'package:handlerclaw/core/network/interceptors/auth_interceptor.dart';

class DioClient {
  static Dio create(Ref ref) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        validateStatus: (status) => status != null && status < 500,
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(ref));

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );

    return dio;
  }
}