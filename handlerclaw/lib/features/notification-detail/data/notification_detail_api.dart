import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/shared/utils/logger.dart';
import 'package:handlerclaw/features/notification-detail/data/response/notification_detail_response_dto.dart';

class NotificationDetailApi {
  final Dio dio;

  NotificationDetailApi(this.dio);

  Future<NotificationDetailResponseDto> getNotificationDetail(String id) async {
    final endpoint = ApiEndpoint.notificationDetail.replaceAll('{id}', id);

    try {
      Logger.api("GET", endpoint);

      final response = await dio.get(endpoint);

      return NotificationDetailResponseDto.fromJson(response.data);
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

final notificationDetailApiProvider = Provider<NotificationDetailApi>((ref) {
  final dio = ref.read(dioProvider);

  return NotificationDetailApi(dio);
});
