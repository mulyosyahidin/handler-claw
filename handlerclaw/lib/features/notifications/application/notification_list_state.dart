import 'package:handlerclaw/core/models/pagination_meta_dto.dart';
import 'package:handlerclaw/features/notifications/domain/entities/notification_entity.dart';

class NotificationListState {
  final List<NotificationEntity> items;
  final PaginationMetaDto? meta;
  final bool isLoadingMore;

  NotificationListState({
    required this.items,
    this.meta,
    this.isLoadingMore = false,
  });

  NotificationListState copyWith({
    List<NotificationEntity>? items,
    PaginationMetaDto? meta,
    bool? isLoadingMore,
  }) {
    return NotificationListState(
      items: items ?? this.items,
      meta: meta ?? this.meta,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
