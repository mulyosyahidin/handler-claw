import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/core/utils/logger.dart';
import 'package:handlerclaw/features/finances/data/responses/accounts_response.dart';

class AccountRemoteDataSource {
  final Dio _dio;

  AccountRemoteDataSource(this._dio);

  Future<AccountsResponseDto> getAccounts({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    const endpoint = ApiEndpoint.financeAccounts;

    try {
      Logger.api("GET", endpoint);

      final response = await _dio.get(
        endpoint,
        queryParameters: {'page': page, 'per_page': perPage, 'search': search},
      );

      return AccountsResponseDto.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountRemoteDataSource.getAccounts (DioException)',
      );
      if (e.response != null) {
        return AccountsResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountRemoteDataSource.getAccounts (Unexpected)',
      );
      rethrow;
    }
  }

  Future<ApiResponseDto<dynamic>> createAccount({
    required String name,
    required String accountTypeId,
  }) async {
    const endpoint = ApiEndpoint.financeAccounts;

    try {
      Logger.api("POST", endpoint);

      final response = await _dio.post(
        endpoint,
        data: {'name': name, 'account_type_id': accountTypeId},
      );

      return ApiResponseDto<dynamic>.fromJson(response.data, (json) => json);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountRemoteDataSource.createAccount (DioException)',
      );
      if (e.response != null) {
        return ApiResponseDto<dynamic>.fromJson(
          e.response!.data,
          (json) => json,
        );
      }
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountRemoteDataSource.createAccount (Unexpected)',
      );
      rethrow;
    }
  }

  Future<AccountResponseDto> getAccount(String id) async {
    final endpoint = "${ApiEndpoint.financeAccounts}/$id";

    try {
      Logger.api("GET", endpoint);

      final response = await _dio.get(endpoint);

      return AccountResponseDto.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountRemoteDataSource.getAccount (DioException)',
      );
      if (e.response != null) {
        return AccountResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    }
  }

  Future<ApiResponseDto<dynamic>> updateAccount({
    required String id,
    String? name,
    String? accountTypeId,
  }) async {
    final endpoint = "${ApiEndpoint.financeAccounts}/$id";

    try {
      Logger.api("PATCH", endpoint);

      final response = await _dio.patch(
        endpoint,
        data: {'name': name, 'account_type_id': accountTypeId},
      );

      return ApiResponseDto<dynamic>.fromJson(response.data, (json) => json);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountRemoteDataSource.updateAccount (DioException)',
      );
      if (e.response != null) {
        return ApiResponseDto<dynamic>.fromJson(
          e.response!.data,
          (json) => json,
        );
      }
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountRemoteDataSource.updateAccount (Unexpected)',
      );
      rethrow;
    }
  }

  Future<ApiResponseDto<dynamic>> deleteAccount(String id) async {
    final endpoint = "${ApiEndpoint.financeAccounts}/$id";

    try {
      Logger.api("DELETE", endpoint);

      final response = await _dio.delete(endpoint);

      return ApiResponseDto<dynamic>.fromJson(response.data, (json) => json);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountRemoteDataSource.deleteAccount (DioException)',
      );
      if (e.response != null) {
        return ApiResponseDto<dynamic>.fromJson(
          e.response!.data,
          (json) => json,
        );
      }
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountRemoteDataSource.deleteAccount (Unexpected)',
      );
      rethrow;
    }
  }
}

final accountRemoteDataSourceProvider = Provider<AccountRemoteDataSource>((
  ref,
) {
  final dio = ref.read(dioProvider);
  return AccountRemoteDataSource(dio);
});
