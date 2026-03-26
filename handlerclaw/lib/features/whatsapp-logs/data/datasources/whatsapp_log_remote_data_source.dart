import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/features/whatsapp-logs/data/responses/whatsapp_log_list_response_dto.dart';
import 'package:handlerclaw/core/utils/logger.dart';

class WhatsappLogRemoteDataSource {
  final Dio _dio;

  WhatsappLogRemoteDataSource(this._dio);

  Future<WhatsappLogListResponseDto> getLogs({
    int? cursor,
    int limit = 10,
    String? search,
  }) async {
    const endpoint = ApiEndpoint.whatsappLogList;

    try {
      Logger.api("GET", endpoint);

      final response = await _dio.get(
        endpoint,
        queryParameters: {
          "cursor": ?cursor,
          "take": limit,
          if (search != null && search.isNotEmpty) "search": search,
        },
      );

      return WhatsappLogListResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      rethrow;
    }
  }
}

final whatsappLogRemoteDataSourceProvider =
    Provider<WhatsappLogRemoteDataSource>((ref) {
      final dio = ref.read(dioProvider);
      return WhatsappLogRemoteDataSource(dio);
    });
