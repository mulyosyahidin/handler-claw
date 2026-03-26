import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/whatsapp-logs/domain/entities/whatsapp_log_entity.dart';
import 'package:handlerclaw/features/whatsapp-logs/domain/repositories/whatsapp_log_repository.dart';
import 'package:handlerclaw/features/whatsapp-logs/data/repositories/whatsapp_log_repository_impl.dart';

class WhatsappLogListState {
  final List<WhatsappLogEntity> items;
  final int? nextCursor;
  final bool isLoadingMore;
  final String? search;

  WhatsappLogListState({
    required this.items,
    this.nextCursor,
    this.isLoadingMore = false,
    this.search,
  });

  WhatsappLogListState copyWith({
    List<WhatsappLogEntity>? items,
    int? nextCursor,
    bool? isLoadingMore,
    String? search,
    bool clearNextCursor = false,
  }) {
    return WhatsappLogListState(
      items: items ?? this.items,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      search: search ?? this.search,
    );
  }
}

class WhatsappLogListController extends AsyncNotifier<WhatsappLogListState> {
  Timer? _searchDebounce;

  WhatsappLogRepository get _repository => ref.read(whatsappLogRepositoryProvider);

  @override
  Future<WhatsappLogListState> build() async {
    return await _fetchPage();
  }

  Future<WhatsappLogListState> _fetchPage({int? cursor, String? search}) async {
    final response = await _repository.getLogs(cursor: cursor, search: search);
    
    return WhatsappLogListState(
      items: response.logs,
      nextCursor: response.nextCursor,
      search: search,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore || currentState.nextCursor == null) return;

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final response = await _repository.getLogs(
        cursor: currentState.nextCursor,
        search: currentState.search,
      );
      
      state = AsyncData(currentState.copyWith(
        items: [...currentState.items, ...response.logs],
        nextCursor: response.nextCursor,
        clearNextCursor: response.nextCursor == null,
        isLoadingMore: false,
      ));
    } catch (e) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(search: state.value?.search));
  }

  void onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() => _fetchPage(search: query));
    });
  }
}

final whatsappLogListControllerProvider =
    AsyncNotifierProvider<WhatsappLogListController, WhatsappLogListState>(
  WhatsappLogListController.new,
);
