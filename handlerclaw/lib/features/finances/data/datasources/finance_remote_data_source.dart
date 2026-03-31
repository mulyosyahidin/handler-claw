import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/features/finances/data/responses/finance_overview_response.dart';
import 'package:handlerclaw/core/utils/logger.dart';

class FinanceRemoteDataSource {
  final Dio _dio;

  FinanceRemoteDataSource(this._dio);

  Future<FinanceOverviewResponseDto> getOverview() async {
    const endpoint = ApiEndpoint.financeOverview;

    try {
      Logger.api("GET", endpoint);

      final response = await _dio.get(endpoint);

      return FinanceOverviewResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      if (e.response != null) {
        return FinanceOverviewResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      rethrow;
    }
  }
}

final financeRemoteDataSourceProvider = Provider<FinanceRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return FinanceRemoteDataSource(dio);
});
