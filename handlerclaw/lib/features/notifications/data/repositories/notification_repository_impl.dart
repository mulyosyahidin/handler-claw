import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:handlerclaw/features/notifications/data/responses/notification_list_response_dto.dart';
import 'package:handlerclaw/features/notifications/domain/repositories/notification_repository.dart';
import 'package:handlerclaw/features/notifications/data/responses/notification_detail_response_dto.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<NotificationListResponseDto> getNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    return await _remoteDataSource.getNotifications(
      page: page,
      limit: limit,
    );
  }

  @override
  Future<NotificationDetailResponseDto> getNotificationDetail(String id) async {
    return await _remoteDataSource.getNotificationDetail(id);
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remoteDataSource = ref.read(notificationRemoteDataSourceProvider);
  return NotificationRepositoryImpl(remoteDataSource);
});
