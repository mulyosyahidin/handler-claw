import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/summary_item_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/prayer_log_api.dart';

class TodayPrayerController extends AsyncNotifier<SummaryItemDto?> {
  @override
  Future<SummaryItemDto?> build() async {
    return _fetchTodaySummary();
  }

  Future<SummaryItemDto?> _fetchTodaySummary() async {
    final api = ref.read(prayerLogApiProvider);
    final response = await api.getSummary(dateType: 'today');
    final summary = response.data?.summary;
    if (summary != null && summary.isNotEmpty) {
      return summary.first;
    }
    return null;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchTodaySummary());
  }
}

final todayPrayerControllerProvider =
    AsyncNotifierProvider<TodayPrayerController, SummaryItemDto?>(
      TodayPrayerController.new,
    );
