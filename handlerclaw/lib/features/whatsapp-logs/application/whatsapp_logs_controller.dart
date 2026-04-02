import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
  final bool? isGroup;

  WhatsappLogListState({
    required this.items,
    this.meta,
    this.isLoadingMore = false,
    this.search,
    this.isGroup,
  });

  WhatsappLogListState copyWith({
    List<WhatsappLogEntity>? items,
    PaginationMetaDto? meta,
    bool? isLoadingMore,
    String? search,
    bool? isGroup,
    bool clearMeta = false,
    bool clearIsGroup = false,
  }) {
    return WhatsappLogListState(
      items: items ?? this.items,
      meta: clearMeta ? null : (meta ?? this.meta),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      search: search ?? this.search,
      isGroup: clearIsGroup ? null : (isGroup ?? this.isGroup),
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

  Future<WhatsappLogListState> _fetchPage({int page = 1, String? search, bool? isGroup}) async {
    final response = await _repository.getLogs(page: page, search: search, isGroup: isGroup);
    
    return WhatsappLogListState(
      items: response.logs,
      meta: response.meta,
      search: search,
      isGroup: isGroup,
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
        isGroup: currentState.isGroup,
      );
      
      state = AsyncData(currentState.copyWith(
        items: [...currentState.items, ...response.logs],
        meta: response.meta,
        isLoadingMore: false,
      ));
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'WhatsappLogListController.loadMore',
      );
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(
      search: state.value?.search,
      isGroup: state.value?.isGroup,
    ));
  }

  void onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() => _fetchPage(
        search: query,
        isGroup: state.value?.isGroup,
      ));
    });
  }
 
  void onFilterChanged(bool? isGroup) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(
      search: state.value?.search,
      isGroup: isGroup,
    ));
  }
}

final whatsappLogListControllerProvider =
    AsyncNotifierProvider<WhatsappLogListController, WhatsappLogListState>(
  WhatsappLogListController.new,
);
