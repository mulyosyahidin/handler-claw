import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/core/utils/logger.dart';
import 'package:handlerclaw/features/notifications/data/responses/notification_list_response_dto.dart';
import 'package:handlerclaw/features/notifications/data/responses/notification_detail_response_dto.dart';

class NotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSource(this._dio);

  Future<NotificationListResponseDto> getNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    const endpoint = ApiEndpoint.notificationList;

    try {
      Logger.api("GET", endpoint);

      final response = await _dio.get(
        endpoint,
        queryParameters: {"page": page, "limit": limit},
      );

      return NotificationListResponseDto.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'NotificationRemoteDataSource.getNotifications (DioException)',
      );
      if (e.response != null) {
        return NotificationListResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'NotificationRemoteDataSource.getNotifications (Unexpected)',
      );
      rethrow;
    }
  }

  Future<NotificationDetailResponseDto> getNotificationDetail(String id) async {
    final endpoint = ApiEndpoint.notificationDetail.replaceAll('{id}', id);

    try {
      Logger.api("GET", endpoint);

      final response = await _dio.get(endpoint);

      return NotificationDetailResponseDto.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'NotificationRemoteDataSource.getNotificationDetail (DioException)',
      );
      if (e.response != null) {
        return NotificationDetailResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'NotificationRemoteDataSource.getNotificationDetail (Unexpected)',
      );
      rethrow;
    }
  }
}

final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return NotificationRemoteDataSource(dio);
});
