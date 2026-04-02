import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/features/whatsapp-logs/data/responses/whatsapp_log_list_response_dto.dart';
import 'package:handlerclaw/core/utils/logger.dart';

class WhatsappLogRemoteDataSource {
  final Dio _dio;

  WhatsappLogRemoteDataSource(this._dio);

  Future<WhatsappLogListResponseDto> getLogs({
    int page = 1,
    int limit = 10,
    String? search,
    bool? isGroup,
  }) async {
    const endpoint = ApiEndpoint.whatsappLogList;

    try {
      Logger.api("GET", endpoint);

      final response = await _dio.get(
        endpoint,
        queryParameters: {
          "page": page,
          "per_page": limit,
          if (search != null && search.isNotEmpty) "search": search,
          "is_group": ?isGroup,
        },
      );

      return WhatsappLogListResponseDto.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'WhatsappLogRemoteDataSource.getLogs (DioException)',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'WhatsappLogRemoteDataSource.getLogs (Unexpected)',
      );
      rethrow;
    }
  }
}

final whatsappLogRemoteDataSourceProvider =
    Provider<WhatsappLogRemoteDataSource>((ref) {
      final dio = ref.read(dioProvider);
      return WhatsappLogRemoteDataSource(dio);
    });
