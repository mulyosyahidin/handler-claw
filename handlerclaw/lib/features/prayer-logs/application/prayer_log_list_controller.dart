import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/prayer-logs/domain/entities/prayer_log_entity.dart';
import 'package:handlerclaw/features/prayer-logs/domain/repositories/prayer_log_repository.dart';
import 'package:handlerclaw/features/prayer-logs/data/repositories/prayer_log_repository_impl.dart';
import 'package:handlerclaw/features/prayer-logs/data/mappers/prayer_log_mapper.dart';
import 'package:intl/intl.dart';

class PrayerLogListState {
  final List<PrayerLogEntity> items;
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
    List<PrayerLogEntity>? items,
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
  PrayerLogRepository get _repository => ref.read(prayerLogRepositoryProvider);

  @override
  Future<PrayerLogListState> build() async {
    return await _fetchPage(1);
  }

  Future<PrayerLogListState> _fetchPage(int page) async {
    final currentState = state.asData?.value;

    final dateType = currentState?.dateType ?? '7_days';
    final start = currentState?.startDate != null
        ? DateFormat('yyyy-MM-dd').format(currentState!.startDate!)
        : null;
    final end = currentState?.endDate != null
        ? DateFormat('yyyy-MM-dd').format(currentState!.endDate!)
        : null;

    final response = await _repository.getLogs(
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
      items: PrayerLogMapper.fromDtos(data.prayerLogs),
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
      final nextPage = currentState.currentPage + 1;

      final start = currentState.startDate != null
          ? DateFormat('yyyy-MM-dd').format(currentState.startDate!)
          : null;
      final end = currentState.endDate != null
          ? DateFormat('yyyy-MM-dd').format(currentState.endDate!)
          : null;

      final response = await _repository.getLogs(
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
          items: [
            ...currentState.items,
            ...PrayerLogMapper.fromDtos(data.prayerLogs)
          ],
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
    state = const AsyncLoading();
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
