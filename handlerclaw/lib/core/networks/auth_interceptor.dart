import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/auth/token_storage.dart';
import 'package:handlerclaw/core/utils/logger.dart';
import 'package:handlerclaw/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;

  // Flag untuk mencegah multiple refresh secara bersamaan
  bool _isRefreshing = false;

  AuthInterceptor(this.ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await ref.read(tokenStorageProvider).getToken();

    if (token != null) {
      options.headers["Authorization"] = "Bearer $token";
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final requestPath = err.requestOptions.path;

    // Jika bukan 401, atau sedang di endpoint refresh (hindari infinite loop),
    // langsung teruskan error
    final isRefreshEndpoint = requestPath.contains('refresh-access-token');
    if (statusCode != 401 || isRefreshEndpoint) {
      return handler.next(err);
    }

    // Jika sudah sedang refresh, jangan ulangi
    if (_isRefreshing) {
      Logger.warning('AuthInterceptor: Refresh sudah berjalan, skip retry.');
      return handler.next(err);
    }

    _isRefreshing = true;
    Logger.warning('AuthInterceptor: 401 terdeteksi, mencoba refresh token...');

    try {
      final tokenStorage = ref.read(tokenStorageProvider);
      final oldToken = await tokenStorage.getToken();

      if (oldToken == null) {
        Logger.error('AuthInterceptor: Tidak ada token untuk di-refresh.');
        _isRefreshing = false;
        return handler.next(err);
      }

      // Panggil endpoint refresh
      final authRemoteDataSource = ref.read(authRemoteDataSourceProvider);
      final newToken = await authRemoteDataSource.refreshToken(oldToken);

      // Simpan token baru
      await tokenStorage.saveToken(newToken);
      Logger.debug('AuthInterceptor: Token berhasil di-refresh, retry request.');

      // Retry request asli dengan token baru
      final retryOptions = err.requestOptions;
      retryOptions.headers["Authorization"] = "Bearer $newToken";

      final dio = Dio(
        BaseOptions(
          baseUrl: retryOptions.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final retryResponse = await dio.fetch(retryOptions);
      _isRefreshing = false;
      return handler.resolve(retryResponse);
    } catch (e) {
      Logger.error('AuthInterceptor: Gagal refresh token: $e');
      _isRefreshing = false;

      // Refresh gagal → clear session dan teruskan error 401 asli
      // AuthService akan menangkap 401 ini dan melakukan logout
      await ref.read(tokenStorageProvider).clear();
      return handler.next(err);
    }
  }
}
