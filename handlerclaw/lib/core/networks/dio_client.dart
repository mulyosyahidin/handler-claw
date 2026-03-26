import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/env.dart';
import 'package:handlerclaw/core/networks/auth_interceptor.dart';

class DioClient {
  static Dio create(String baseUrl, Ref ref) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) => status != null && status < 500,
        headers: {"Content-Type": "application/json"},
      ),
    );

    dio.interceptors.add(AuthInterceptor(ref));
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    return dio;
  }
}

final dioProvider = Provider<Dio>((ref) {
  return DioClient.create(Env.apiBaseUrl, ref);
});
