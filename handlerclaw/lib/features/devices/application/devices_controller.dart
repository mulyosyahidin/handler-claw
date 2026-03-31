import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/devices/data/repositories/user_device_repository_impl.dart';
import 'package:handlerclaw/features/devices/domain/entities/user_device_entity.dart';
import 'package:handlerclaw/features/devices/domain/repositories/user_device_repository.dart';

class UserDevicesState {
  final List<UserDeviceEntity> items;
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
    List<UserDeviceEntity>? items,
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

  UserDeviceRepository get _repository => ref.read(userDeviceRepositoryProvider);

  @override
  Future<UserDevicesState> build() async {
    return await _fetchPage(page: 1);
  }

  Future<UserDevicesState> _fetchPage({required int page, String? search}) async {
    final result = await _repository.getDevices(page: page, search: search);
    
    return UserDevicesState(
      items: result.items,
      currentPage: result.currentPage,
      totalPages: result.totalPages,
      search: search,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMore) return;

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final result = await _repository.getDevices(
        page: currentState.currentPage + 1,
        search: currentState.search,
      );
      
      state = AsyncData(currentState.copyWith(
        items: [...currentState.items, ...result.items],
        currentPage: result.currentPage,
        totalPages: result.totalPages,
        isLoadingMore: false,
      ));
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'UserDevicesController.loadMore',
      );
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
