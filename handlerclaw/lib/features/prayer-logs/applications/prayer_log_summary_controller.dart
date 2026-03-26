import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/count_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/filter_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/grand_total_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/performance_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/summary_item_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/prayer_log_api.dart';
import 'package:intl/intl.dart';

class PrayerLogSummaryState {
  final FilterDto? filter;
  final List<SummaryItemDto> summary;
  final List<Map<String, dynamic>> summaryData;
  final CountDto count;
  final GrandTotalDto grandTotal;
  final String dateType;
  final DateTime? startDate;
  final DateTime? endDate;
  final PerformancesDto performance;

  PrayerLogSummaryState({
    this.filter,
    required this.summary,
    required this.summaryData,
    required this.count,
    required this.grandTotal,
    this.dateType = '7_days',
    this.startDate,
    this.endDate,
    required this.performance,
  });

  PrayerLogSummaryState copyWith({
    FilterDto? filter,
    List<SummaryItemDto>? summary,
    List<Map<String, dynamic>>? summaryData,
    CountDto? count,
    GrandTotalDto? grandTotal,
    String? dateType,
    DateTime? startDate,
    DateTime? endDate,
    PerformancesDto? performance,
  }) {
    return PrayerLogSummaryState(
      filter: filter ?? this.filter,
      summary: summary ?? this.summary,
      summaryData: summaryData ?? this.summaryData,
      count: count ?? this.count,
      grandTotal: grandTotal ?? this.grandTotal,
      dateType: dateType ?? this.dateType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      performance: performance ?? this.performance,
    );
  }
}

class PrayerLogSummaryController extends AsyncNotifier<PrayerLogSummaryState> {
  @override
  Future<PrayerLogSummaryState> build() async {
    return await _fetchSummary();
  }

  Future<PrayerLogSummaryState> _fetchSummary() async {
    final api = ref.read(prayerLogApiProvider);
    final currentState = state.asData?.value;

    final dateType = currentState?.dateType ?? '7_days';
    final start = currentState?.startDate != null
        ? DateFormat('yyyy-MM-dd').format(currentState!.startDate!)
        : null;
    final end = currentState?.endDate != null
        ? DateFormat('yyyy-MM-dd').format(currentState!.endDate!)
        : null;

    final response = await api.getSummary(
      dateType: dateType,
      start: start,
      end: end,
    );

    final data = response.data;
    if (data == null) {
      return PrayerLogSummaryState(
        summary: [],
        summaryData: [],
        count: CountDto.empty(),
        grandTotal: GrandTotalDto.empty(),
        dateType: dateType,
        performance: PerformancesDto.empty(),
      );
    }

    // Convert the summary data to a format suitable for display
    List<Map<String, dynamic>> summaryData = [];
    for (var entry in data.summary) {
      // Extract prayer-specific data for each prayer type
      entry.byPrayer.forEach((prayerName, prayerData) {
        summaryData.add({
          'name': prayerName,
          'performed': prayerData.performed,
          'qadha': prayerData.qadha,
          'jamaah': prayerData.jamaah,
          'label': entry.label,
        });
      });
    }

    return PrayerLogSummaryState(
      filter: data.filter,
      summary: data.summary,
      summaryData: summaryData,
      count: data.count,
      grandTotal: data.grandTotal,
      dateType: dateType,
      performance: data.performances,
      startDate: currentState?.startDate,
      endDate: currentState?.endDate,
    );
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

  Future<void> refresh() async {
    final currentState = state.asData?.value;

    if (currentState != null) {
      // Keep current state to preserve filters
    }

    final newState = await AsyncValue.guard(() => _fetchSummary());
    state = newState;
  }
}

final prayerLogSummaryControllerProvider =
    AsyncNotifierProvider<PrayerLogSummaryController, PrayerLogSummaryState>(
      PrayerLogSummaryController.new,
    );
