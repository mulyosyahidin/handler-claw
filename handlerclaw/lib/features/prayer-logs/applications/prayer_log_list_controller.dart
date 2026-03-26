import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/prayer_log_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/prayer_log_api.dart';
import 'package:intl/intl.dart';

class PrayerLogListState {
  final List<PrayerLogDto> items;
  final bool isLoadingMore;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final String dateType;
  final DateTime? startDate;
  final DateTime? endDate;

  PrayerLogListState({
    required this.items,
    this.isLoadingMore = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.dateType = '7_days',
    this.startDate,
    this.endDate,
  });

  PrayerLogListState copyWith({
    List<PrayerLogDto>? items,
    bool? isLoadingMore,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    String? dateType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return PrayerLogListState(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      dateType: dateType ?? this.dateType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class PrayerLogListController extends AsyncNotifier<PrayerLogListState> {
  @override
  Future<PrayerLogListState> build() async {
    return await _fetchPage(1);
  }

  Future<PrayerLogListState> _fetchPage(int page) async {
    final api = ref.read(prayerLogApiProvider);
    final currentState = state.asData?.value;

    final dateType = currentState?.dateType ?? '7_days';
    final start = currentState?.startDate != null
        ? DateFormat('yyyy-MM-dd').format(currentState!.startDate!)
        : null;
    final end = currentState?.endDate != null
        ? DateFormat('yyyy-MM-dd').format(currentState!.endDate!)
        : null;

    final response = await api.getLogs(
      page: page,
      dateType: dateType,
      start: start,
      end: end,
    );

    final data = response.data;
    if (data == null) {
      return PrayerLogListState(items: [], dateType: dateType);
    }

    return PrayerLogListState(
      items: data.prayerLogs,
      currentPage: data.meta.page,
      totalPages: data.meta.totalPages,
      totalItems: data.meta.total,
      dateType: dateType,
      startDate: currentState?.startDate,
      endDate: currentState?.endDate,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore) return;

    if (currentState.currentPage >= currentState.totalPages) return;

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final api = ref.read(prayerLogApiProvider);
      final nextPage = currentState.currentPage + 1;

      final start = currentState.startDate != null
          ? DateFormat('yyyy-MM-dd').format(currentState.startDate!)
          : null;
      final end = currentState.endDate != null
          ? DateFormat('yyyy-MM-dd').format(currentState.endDate!)
          : null;

      final response = await api.getLogs(
        page: nextPage,
        dateType: currentState.dateType,
        start: start,
        end: end,
      );

      final data = response.data;
      if (data == null) {
        state = AsyncData(currentState.copyWith(isLoadingMore: false));
        return;
      }

      state = AsyncData(
        currentState.copyWith(
          items: [...currentState.items, ...data.prayerLogs],
          currentPage: data.meta.page,
          totalPages: data.meta.totalPages,
          totalItems: data.meta.total,
          isLoadingMore: false,
        ),
      );
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> refresh() async {
    // Keep current state to preserve filters while showing loading if needed
    // However, RefreshIndicator already shows a spinner.
    // If we use AsyncLoading(), state.value becomes null.
    // So we just call _fetchPage and set state to AsyncData if we want to preserve filters.

    final currentState = state.asData?.value;

    if (currentState != null) {
      // If we have state, we can keep it and just fetch
      // But usually we want to show loading.
      // Better way: don't set to AsyncLoading if we want to keep filters in _fetchPage
    }

    final newState = await AsyncValue.guard(() => _fetchPage(1));
    state = newState;
  }

  Future<void> updateFilter({
    String? dateType,
    DateTime? start,
    DateTime? end,
  }) async {
    final currentState = state.asData?.value;
    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(dateType: dateType, startDate: start, endDate: end),
    );

    await refresh();
  }
}

final prayerLogListControllerProvider =
    AsyncNotifierProvider<PrayerLogListController, PrayerLogListState>(
      PrayerLogListController.new,
    );
