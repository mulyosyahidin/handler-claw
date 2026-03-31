import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/prayer-logs/application/home_widget_service.dart';
import 'package:handlerclaw/features/prayer-logs/domain/entities/prayer_log_summary_entity.dart';
import 'package:handlerclaw/features/prayer-logs/domain/repositories/prayer_log_repository.dart';
import 'package:handlerclaw/features/prayer-logs/data/repositories/prayer_log_repository_impl.dart';

class TodayPrayerController extends AsyncNotifier<SummaryItemEntity?> {
  PrayerLogRepository get _repository => ref.read(prayerLogRepositoryProvider);

  @override
  Future<SummaryItemEntity?> build() async {
    return _fetchTodaySummary();
  }

  Future<SummaryItemEntity?> _fetchTodaySummary() async {
    try {
      final todaySummary = await _repository.getTodaySummary();
      
      HomeWidgetService.updateWidget(todaySummary);
      return todaySummary;
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'TodayPrayerController._fetchTodaySummary',
      );
      HomeWidgetService.updateWidget(null);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchTodaySummary());
  }
}

final todayPrayerControllerProvider =
    AsyncNotifierProvider<TodayPrayerController, SummaryItemEntity?>(
  TodayPrayerController.new,
);
