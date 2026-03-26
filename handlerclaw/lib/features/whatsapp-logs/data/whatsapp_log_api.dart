import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/shared/utils/logger.dart';
import 'package:handlerclaw/features/whatsapp-logs/data/response/whatsapp_log_list_response_dto.dart';

class WhatsappLogApi {
  final Dio dio;

  WhatsappLogApi(this.dio);

  Future<WhatsappLogListResponseDto> getLogs({
    int? cursor,
    int limit = 10,
    String? search,
  }) async {
    const endpoint = ApiEndpoint.whatsappLogList;

    try {
      Logger.api("GET", endpoint);

      final response = await dio.get(
        endpoint,
        queryParameters: {
          "cursor": ?cursor,
          "take": limit,
          if (search != null && search.isNotEmpty) "search": search,
        },
      );

      return WhatsappLogListResponseDto.fromJson(response.data);
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

final whatsappLogApiProvider = Provider<WhatsappLogApi>((ref) {
  final dio = ref.read(dioProvider);
  return WhatsappLogApi(dio);
});
