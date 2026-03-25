import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/models/pagination_meta_dto.dart';
import 'package:handlerclaw/core/models/dto/notification_dto.dart';
import 'package:handlerclaw/features/notification-list/data/notification_api.dart';

class NotificationListState {
  final List<NotificationDto> items;
  final PaginationMetaDto? meta;
  final bool isLoadingMore;

  NotificationListState({
    required this.items,
    this.meta,
    this.isLoadingMore = false,
  });

  NotificationListState copyWith({
    List<NotificationDto>? items,
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

class NotificationListController extends AsyncNotifier<NotificationListState> {
  @override
  Future<NotificationListState> build() async {
    try {
      return await _fetchPage(1);
    } catch (e) {
      rethrow;
    }
  }

  Future<NotificationListState> _fetchPage(int page) async {
    final api = ref.read(notificationApiProvider);
    final response = await api.getNotifications(page: page);
    
    final items = response.data?.notifications ?? [];

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
      final api = ref.read(notificationApiProvider);
      final response = await api.getNotifications(page: meta.page + 1);
      
      final newItems = response.data?.notifications ?? [];

      state = AsyncData(currentState.copyWith(
        items: [...currentState.items, ...newItems],
        meta: response.data?.meta,
        isLoadingMore: false,
      ));
    } catch (e) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
      // Re-throw or handle error
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
