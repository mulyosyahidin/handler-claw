import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/features/api-keys/data/responses/api_key_list_response_dto.dart';
import 'package:handlerclaw/features/api-keys/data/responses/api_key_response_dto.dart';
import 'package:handlerclaw/core/utils/logger.dart';

class ApiKeyRemoteDataSource {
  final Dio _dio;

  ApiKeyRemoteDataSource(this._dio);

  Future<ApiKeyListResponseDto> getKeys({int page = 1, int perPage = 10, String? search}) async {
    const endpoint = ApiEndpoint.apiKeyList;
    try {
      final response = await _dio.get(endpoint, queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.isNotEmpty) 'search': search,
      });
      return ApiKeyListResponseDto.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'ApiKeyRemoteDataSource.getKeys (DioException)',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'ApiKeyRemoteDataSource.getKeys (Unexpected)',
      );
      rethrow;
    }
  }

  Future<ApiKeyResponseDto> createKey(String name) async {
    const endpoint = ApiEndpoint.apiKeyList;
    try {
      final response = await _dio.post(endpoint, data: {'name': name});
      return ApiKeyResponseDto.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'ApiKeyRemoteDataSource.createKey (DioException)',
      );
      rethrow;
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'ApiKeyRemoteDataSource.createKey (Unexpected)',
      );
      rethrow;
    }
  }

  Future<ApiKeyResponseDto> updateKey(String id, String name) async {
    final endpoint = ApiEndpoint.apiKeyDetail.replaceAll('{id}', id);
    final response = await _dio.patch(endpoint, data: {'name': name});
    return ApiKeyResponseDto.fromJson(response.data);
  }

  Future<void> deleteKey(String id) async {
    final endpoint = ApiEndpoint.apiKeyDetail.replaceAll('{id}', id);
    try {
      await _dio.delete(endpoint);
    } on DioException catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'ApiKeyRemoteDataSource.deleteKey (DioException)',
      );
      rethrow;
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'ApiKeyRemoteDataSource.deleteKey (Unexpected)',
      );
      rethrow;
    }
  }

  Future<ApiKeyResponseDto> revokeKey(String id) async {
    final endpoint = ApiEndpoint.apiKeyRevoke.replaceAll('{id}', id);
    final response = await _dio.patch(endpoint);
    return ApiKeyResponseDto.fromJson(response.data);
  }

  Future<ApiKeyResponseDto> rotateKey(String id) async {
    final endpoint = ApiEndpoint.apiKeyRotate.replaceAll('{id}', id);
    try {
      final response = await _dio.patch(endpoint);
      return ApiKeyResponseDto.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'ApiKeyRemoteDataSource.rotateKey (DioException)',
      );
      rethrow;
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'ApiKeyRemoteDataSource.rotateKey (Unexpected)',
      );
      rethrow;
    }
  }

  Future<ApiKeyResponseDto> getKeyDetail(String id) async {
    final endpoint = ApiEndpoint.apiKeyDetail.replaceAll('{id}', id);
    final response = await _dio.get(endpoint);
    return ApiKeyResponseDto.fromJson(response.data);
  }
}

final apiKeyRemoteDataSourceProvider = Provider<ApiKeyRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return ApiKeyRemoteDataSource(dio);
});
