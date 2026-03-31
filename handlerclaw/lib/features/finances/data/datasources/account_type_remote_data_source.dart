import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/core/utils/logger.dart';
import 'package:handlerclaw/features/finances/data/responses/account_types_response.dart';

class AccountTypeRemoteDataSource {
  final Dio _dio;

  AccountTypeRemoteDataSource(this._dio);

  Future<AccountTypesResponseDto> getAccountTypes({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    const endpoint = ApiEndpoint.financeAccountTypes;

    try {
      Logger.api("GET", endpoint);

      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'search': search,
        },
      );

      return AccountTypesResponseDto.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountTypeRemoteDataSource.getAccountTypes (DioException)',
      );
      if (e.response != null) {
        return AccountTypesResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountTypeRemoteDataSource.getAccountTypes (Unexpected)',
      );
      rethrow;
    }
  }

  Future<AccountTypesResponseDto> createAccountType({
    required String name,
    required String category,
  }) async {
    const endpoint = ApiEndpoint.financeAccountTypes;

    try {
      Logger.api("POST", endpoint);

      final response = await _dio.post(
        endpoint,
        data: {
          'name': name,
          'category': category,
        },
      );

      return AccountTypesResponseDto.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountTypeRemoteDataSource.createAccountType (DioException)',
      );
      if (e.response != null) {
        return AccountTypesResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountTypeRemoteDataSource.createAccountType (Unexpected)',
      );
      rethrow;
    }
  }

  Future<AccountTypesResponseDto> updateAccountType({
    required String id,
    String? name,
    String? category,
  }) async {
    final endpoint = "${ApiEndpoint.financeAccountTypes}/$id";

    try {
      Logger.api("PATCH", endpoint);

      final response = await _dio.patch(
        endpoint,
        data: {
          'name': ?name,
          'category': ?category,
        },
      );

      return AccountTypesResponseDto.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountTypeRemoteDataSource.updateAccountType (DioException)',
      );
      if (e.response != null) {
        return AccountTypesResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountTypeRemoteDataSource.updateAccountType (Unexpected)',
      );
      rethrow;
    }
  }

  Future<void> deleteAccountType(String id) async {
    final endpoint = "${ApiEndpoint.financeAccountTypes}/$id";

    try {
      Logger.api("DELETE", endpoint);

      await _dio.delete(endpoint);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountTypeRemoteDataSource.deleteAccountType (DioException)',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AccountTypeRemoteDataSource.deleteAccountType (Unexpected)',
      );
      rethrow;
    }
  }
}

final accountTypeRemoteDataSourceProvider = Provider<AccountTypeRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return AccountTypeRemoteDataSource(dio);
});
