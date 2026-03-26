import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/prayer-logs/domain/entities/prayer_log_summary_entity.dart';
import 'package:handlerclaw/features/prayer-logs/domain/repositories/prayer_log_repository.dart';
import 'package:handlerclaw/features/prayer-logs/data/repositories/prayer_log_repository_impl.dart';
import 'package:intl/intl.dart';

class PrayerLogSummaryState {
  final PrayerLogSummaryEntity? entity;
  final List<Map<String, dynamic>> summaryData;
  final String dateType;
  final DateTime? startDate;
  final DateTime? endDate;

  PrayerLogSummaryState({
    this.entity,
    required this.summaryData,
    this.dateType = '7_days',
    this.startDate,
    this.endDate,
  });

  PrayerLogSummaryState copyWith({
    PrayerLogSummaryEntity? entity,
    List<Map<String, dynamic>>? summaryData,
    String? dateType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return PrayerLogSummaryState(
      entity: entity ?? this.entity,
      summaryData: summaryData ?? this.summaryData,
      dateType: dateType ?? this.dateType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class PrayerLogSummaryController extends AsyncNotifier<PrayerLogSummaryState> {
  PrayerLogRepository get _repository => ref.read(prayerLogRepositoryProvider);

  @override
  Future<PrayerLogSummaryState> build() async {
    return await _fetchSummary();
  }

  Future<PrayerLogSummaryState> _fetchSummary() async {
    final currentState = state.asData?.value;

    final dateType = currentState?.dateType ?? '7_days';
    final start = currentState?.startDate != null
        ? DateFormat('yyyy-MM-dd').format(currentState!.startDate!)
        : null;
    final end = currentState?.endDate != null
        ? DateFormat('yyyy-MM-dd').format(currentState!.endDate!)
        : null;

    final entity = await _repository.getSummary(
      dateType: dateType,
      start: start,
      end: end,
    );

    // Convert the summary data to a format suitable for display (used in table)
    List<Map<String, dynamic>> summaryData = [];
    for (var entry in entity.summaryList) {
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
      entity: entity,
      summaryData: summaryData,
      dateType: dateType,
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
    state = const AsyncLoading();
    final newState = await AsyncValue.guard(() => _fetchSummary());
    state = newState;
  }
}

final prayerLogSummaryControllerProvider =
    AsyncNotifierProvider<PrayerLogSummaryController, PrayerLogSummaryState>(
  PrayerLogSummaryController.new,
);
