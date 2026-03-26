import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/prayer_log_create_request_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/responses/prayer_log_list_response_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/responses/prayer_log_summary_response_dto.dart';
import 'package:handlerclaw/core/utils/logger.dart';

class PrayerLogRemoteDataSource {
  final Dio _dio;

  PrayerLogRemoteDataSource(this._dio);

  Future<PrayerLogListResponseDto> getLogs({
    int page = 1,
    int perPage = 10,
    String? dateType,
    String? start,
    String? end,
  }) async {
    const endpoint = ApiEndpoint.prayerLogList;

    try {
      Logger.api("GET", endpoint);

      final response = await _dio.get(
        endpoint,
        queryParameters: {
          "page": page,
          "per_page": perPage,
          "date_type": ?dateType,
          if (start != null && start.isNotEmpty) "start": start,
          if (end != null && end.isNotEmpty) "end": end,
        },
      );

      return PrayerLogListResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      if (e.response != null) {
        return PrayerLogListResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      rethrow;
    }
  }

  Future<PrayerLogSummaryResponseDto> getSummary({
    String? dateType,
    String? start,
    String? end,
  }) async {
    const endpoint = ApiEndpoint.prayerLogSummary;

    try {
      Logger.api("GET", endpoint);

      final response = await _dio.get(
        endpoint,
        queryParameters: {
          "date_type": ?dateType,
          if (start != null && start.isNotEmpty) "start": start,
          if (end != null && end.isNotEmpty) "end": end,
        },
      );

      return PrayerLogSummaryResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      if (e.response != null) {
        return PrayerLogSummaryResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      rethrow;
    }
  }

  Future<void> create(PrayerLogCreateRequestDto data) async {
    const endpoint = ApiEndpoint.prayerLogList;

    try {
      Logger.api("POST", endpoint);

      await _dio.post(endpoint, data: data.toJson());
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      rethrow;
    }
  }
}

final prayerLogRemoteDataSourceProvider = Provider<PrayerLogRemoteDataSource>((
  ref,
) {
  final dio = ref.read(dioProvider);
  return PrayerLogRemoteDataSource(dio);
});
