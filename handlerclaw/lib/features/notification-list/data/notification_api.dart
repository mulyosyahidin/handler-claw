import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/shared/utils/logger.dart';
import 'package:handlerclaw/features/notification-list/data/responses/notification_list_response_dto.dart';

class NotificationApi {
  final Dio dio;

  NotificationApi(this.dio);

  Future<NotificationListResponseDto> getNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    const endpoint = ApiEndpoint.notificationList;

    try {
      Logger.api("GET", endpoint);

      final response = await dio.get(
        endpoint,
        queryParameters: {"page": page, "limit": limit},
      );

      return NotificationListResponseDto.fromJson(response.data);
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

final notificationApiProvider = Provider<NotificationApi>((ref) {
  final dio = ref.read(dioProvider);

  return NotificationApi(dio);
});
