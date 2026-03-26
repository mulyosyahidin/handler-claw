import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/features/prayer-logs/data/responses/prayer_log_list_response_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/responses/prayer_log_summary_response_dto.dart';
import 'package:handlerclaw/shared/utils/logger.dart';

class PrayerLogApi {
  final Dio dio;

  PrayerLogApi(this.dio);

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

      final response = await dio.get(
        endpoint,
        queryParameters: {
          "page": page,
          "per_page": perPage,
          "date_type": ?dateType,
          "start": ?start,
          "end": ?end,
        },
      );

      return PrayerLogListResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint");

      if (e.response != null) {
        Logger.error("Status code: ${e.response?.statusCode}");
        Logger.error("Response body: ${e.response?.data}");
      } else {
        Logger.error("Network error: ${e.message}");
      }

      rethrow;
    } catch (e) {
      Logger.error("Unexpected error: $e");
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

      final response = await dio.get(
        endpoint,
        queryParameters: {
          "date_type": ?dateType,
          "start": ?start,
          "end": ?end,
        },
      );

      return PrayerLogSummaryResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint");

      if (e.response != null) {
        Logger.error("Status code: ${e.response?.statusCode}");
        Logger.error("Response body: ${e.response?.data}");
      } else {
        Logger.error("Network error: ${e.message}");
      }

      rethrow;
    } catch (e) {
      Logger.error("Unexpected error: $e");
      rethrow;
    }
  }
}

final prayerLogApiProvider = Provider<PrayerLogApi>((ref) {
  final dio = ref.read(dioProvider);
  return PrayerLogApi(dio);
});
