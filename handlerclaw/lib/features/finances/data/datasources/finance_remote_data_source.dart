import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'FinanceRemoteDataSource.getOverview (DioException)',
      );
      if (e.response != null) {
        return FinanceOverviewResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'FinanceRemoteDataSource.getOverview (Unexpected)',
      );
      rethrow;
    }
  }
}

final financeRemoteDataSourceProvider = Provider<FinanceRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return FinanceRemoteDataSource(dio);
});
