import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/models/dto/user_device_dto.dart';
import 'package:handlerclaw/features/devices/data/user_device_api.dart';

class UserDevicesState {
  final List<UserDeviceDto> items;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final String? search;

  UserDevicesState({
    required this.items,
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,
    this.search,
  });

  bool get hasMore => currentPage < totalPages;

  UserDevicesState copyWith({
    List<UserDeviceDto>? items,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    String? search,
  }) {
    return UserDevicesState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      search: search ?? this.search,
    );
  }
}

class UserDevicesController extends AsyncNotifier<UserDevicesState> {
  Timer? _searchDebounce;

  @override
  Future<UserDevicesState> build() async {
    return await _fetchPage(page: 1);
  }

  Future<UserDevicesState> _fetchPage({required int page, String? search}) async {
    final api = ref.read(userDeviceApiProvider);
    final response = await api.getDevices(page: page, search: search);
    
    return UserDevicesState(
      items: response.data?.userDevices ?? [],
      currentPage: response.data?.meta.page ?? 1,
      totalPages: response.data?.meta.totalPages ?? 1,
      search: search,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMore) return;

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final api = ref.read(userDeviceApiProvider);
      final response = await api.getDevices(
        page: currentState.currentPage + 1,
        search: currentState.search,
      );
      
      state = AsyncData(currentState.copyWith(
        items: [...currentState.items, ...response.data?.userDevices ?? []],
        currentPage: response.data?.meta.page ?? 1,
        totalPages: response.data?.meta.totalPages ?? 1,
        isLoadingMore: false,
      ));
    } catch (e) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(page: 1, search: state.value?.search));
  }

  void onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() => _fetchPage(page: 1, search: query));
    });
  }
}

final userDevicesControllerProvider =
    AsyncNotifierProvider<UserDevicesController, UserDevicesState>(
  UserDevicesController.new,
);
