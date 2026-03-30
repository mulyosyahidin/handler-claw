import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/models/pagination_meta_dto.dart';
import 'package:handlerclaw/features/api-keys/domain/entities/api_key_entity.dart';
import 'package:handlerclaw/features/api-keys/domain/repositories/api_key_repository.dart';
import 'package:handlerclaw/features/api-keys/data/repositories/api_key_repository_impl.dart';

class ApiKeyListState {
  final List<ApiKeyEntity> items;
  final PaginationMetaDto? meta;
  final bool isLoadingMore;
  final String? search;

  ApiKeyListState({
    required this.items,
    this.meta,
    this.isLoadingMore = false,
    this.search,
  });

  ApiKeyListState copyWith({
    List<ApiKeyEntity>? items,
    PaginationMetaDto? meta,
    bool? isLoadingMore,
    String? search,
    bool clearMeta = false,
  }) {
    return ApiKeyListState(
      items: items ?? this.items,
      meta: clearMeta ? null : (meta ?? this.meta),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      search: search ?? this.search,
    );
  }
}

class ApiKeyListController extends AsyncNotifier<ApiKeyListState> {
  Timer? _searchDebounce;

  ApiKeyRepository get _repository => ref.read(apiKeyRepositoryProvider);

  @override
  Future<ApiKeyListState> build() async {
    return await _fetchPage();
  }

  Future<ApiKeyListState> _fetchPage({int page = 1, String? search}) async {
    final response = await _repository.getKeys(page: page, search: search);
    
    return ApiKeyListState(
      items: response.keys,
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
      final response = await _repository.getKeys(
        page: meta.page + 1,
        search: currentState.search,
      );
      
      state = AsyncData(currentState.copyWith(
        items: [...currentState.items, ...response.keys],
        meta: response.meta,
        isLoadingMore: false,
      ));
    } catch (e) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(
      search: state.value?.search,
    ));
  }

  void onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() => _fetchPage(
        search: query,
      ));
    });
  }

  Future<ApiKeyEntity> createKey(String name) async {
    final newKey = await _repository.createKey(name);
    await refresh(); // Refresh list after creation
    return newKey;
  }

  Future<void> updateKey(String id, String name) async {
    await _repository.updateKey(id, name);
    await refresh();
  }

  Future<void> deleteKey(String id) async {
    await _repository.deleteKey(id);
    await refresh();
  }

  Future<void> revokeKey(String id) async {
    await _repository.revokeKey(id);
    await refresh();
  }

  Future<ApiKeyEntity> rotateKey(String id) async {
    final updatedKey = await _repository.rotateKey(id);
    await refresh();
    return updatedKey;
  }
}

final apiKeyListControllerProvider =
    AsyncNotifierProvider<ApiKeyListController, ApiKeyListState>(
  ApiKeyListController.new,
);
