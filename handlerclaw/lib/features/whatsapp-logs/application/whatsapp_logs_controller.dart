import 'package:handlerclaw/core/models/pagination_meta_dto.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/whatsapp-logs/domain/entities/whatsapp_log_entity.dart';
import 'package:handlerclaw/features/whatsapp-logs/domain/repositories/whatsapp_log_repository.dart';
import 'package:handlerclaw/features/whatsapp-logs/data/repositories/whatsapp_log_repository_impl.dart';

class WhatsappLogListState {
  final List<WhatsappLogEntity> items;
  final PaginationMetaDto? meta;
  final bool isLoadingMore;
  final String? search;

  WhatsappLogListState({
    required this.items,
    this.meta,
    this.isLoadingMore = false,
    this.search,
  });

  WhatsappLogListState copyWith({
    List<WhatsappLogEntity>? items,
    PaginationMetaDto? meta,
    bool? isLoadingMore,
    String? search,
    bool clearMeta = false,
  }) {
    return WhatsappLogListState(
      items: items ?? this.items,
      meta: clearMeta ? null : (meta ?? this.meta),
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

  Future<WhatsappLogListState> _fetchPage({int page = 1, String? search}) async {
    final response = await _repository.getLogs(page: page, search: search);
    
    return WhatsappLogListState(
      items: response.logs,
      meta: response.meta,
      search: search,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore) return;
    
    final meta = currentState.meta;
    if (meta == null || meta.page >= meta.totalPages) return;

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final response = await _repository.getLogs(
        page: meta.page + 1,
        search: currentState.search,
      );
      
      state = AsyncData(currentState.copyWith(
        items: [...currentState.items, ...response.logs],
        meta: response.meta,
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
