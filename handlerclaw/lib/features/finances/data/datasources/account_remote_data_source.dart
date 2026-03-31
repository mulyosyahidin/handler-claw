import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
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
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'search': search,
        },
      );

      return AccountsResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      if (e.response != null) {
        return AccountsResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      rethrow;
    }
  }

  Future<void> createAccount({
    required String name,
    required String accountTypeId,
  }) async {
    const endpoint = ApiEndpoint.financeAccounts;

    try {
      Logger.api("POST", endpoint);

      await _dio.post(
        endpoint,
        data: {
          'name': name,
          'account_type_id': accountTypeId,
        },
      );
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      rethrow;
    }
  }

  Future<AccountResponseDto> getAccount(String id) async {
    final endpoint = "${ApiEndpoint.financeAccounts}/$id";

    try {
      Logger.api("GET", endpoint);

      final response = await _dio.get(endpoint);

      return AccountResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      if (e.response != null) {
        return AccountResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    }
  }

  Future<void> updateAccount({
    required String id,
    String? name,
    String? accountTypeId,
  }) async {
    final endpoint = "${ApiEndpoint.financeAccounts}/$id";

    try {
      Logger.api("PATCH", endpoint);

      await _dio.patch(
        endpoint,
        data: {
          'name': ?name,
          'account_type_id': ?accountTypeId,
        },
      );
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      rethrow;
    }
  }

  Future<void> deleteAccount(String id) async {
    final endpoint = "${ApiEndpoint.financeAccounts}/$id";

    try {
      Logger.api("DELETE", endpoint);

      await _dio.delete(endpoint);
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      rethrow;
    }
  }
}

final accountRemoteDataSourceProvider = Provider<AccountRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return AccountRemoteDataSource(dio);
});
