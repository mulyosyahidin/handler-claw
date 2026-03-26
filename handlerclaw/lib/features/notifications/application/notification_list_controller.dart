import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/notifications/data/mappers/notification_mapper.dart';
import 'package:handlerclaw/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:handlerclaw/features/notifications/domain/repositories/notification_repository.dart';
import 'package:handlerclaw/features/notifications/application/notification_list_state.dart';

class NotificationListController extends AsyncNotifier<NotificationListState> {
  NotificationRepository get _repository => ref.read(notificationRepositoryProvider);

  @override
  Future<NotificationListState> build() async {
    return await _fetchPage(1);
  }

  Future<NotificationListState> _fetchPage(int page) async {
    final response = await _repository.getNotifications(page: page);
    
    final dtoItems = response.data?.notifications ?? [];
    final items = NotificationMapper.fromDtos(dtoItems);

    return NotificationListState(
      items: items,
      meta: response.data?.meta,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore) return;
    
    final meta = currentState.meta;
    if (meta == null || meta.page >= meta.totalPages) return;

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final response = await _repository.getNotifications(page: meta.page + 1);
      
      final newDtoItems = response.data?.notifications ?? [];
      final newItems = NotificationMapper.fromDtos(newDtoItems);

      state = AsyncData(currentState.copyWith(
        items: [...currentState.items, ...newItems],
        meta: response.data?.meta,
        isLoadingMore: false,
      ));
    } catch (e) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(1));
  }
}

final notificationListControllerProvider =
    AsyncNotifierProvider<NotificationListController, NotificationListState>(
  NotificationListController.new,
);
