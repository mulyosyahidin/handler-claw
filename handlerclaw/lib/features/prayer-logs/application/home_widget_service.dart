import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:handlerclaw/features/prayer-logs/domain/entities/prayer_log_summary_entity.dart';

class HomeWidgetService {
  static const String _androidWidgetName = 'PrayerWidgetProvider';

  static Future<void> updateWidget(SummaryItemEntity? summary) async {
    if (summary == null) {
      await HomeWidget.saveWidgetData('widget_count', '0');
      await HomeWidget.saveWidgetData('widget_status', '5 lagi');
      await HomeWidget.saveWidgetData('total_performed', '0 Sholat');
      await HomeWidget.saveWidgetData('subuh_done', false);
      await HomeWidget.saveWidgetData('dzuhur_done', false);
      await HomeWidget.saveWidgetData('ashar_done', false);
      await HomeWidget.saveWidgetData('maghrib_done', false);
      await HomeWidget.saveWidgetData('isya_done', false);
    } else {
      final doneCount = _getDoneCount(summary);
      await HomeWidget.saveWidgetData('widget_count', '$doneCount');
      await HomeWidget.saveWidgetData(
        'widget_status',
        doneCount == 5 ? 'Alhamdulillah! 🎉' : '${5 - doneCount} lagi',
      );
      await HomeWidget.saveWidgetData(
        'total_performed',
        '$doneCount Sholat',
      );

      final isFriday = DateTime.now().weekday == DateTime.friday;

      await HomeWidget.saveWidgetData(
        'subuh_done',
        _isDone(summary, 'SUBUH'),
      );
      await HomeWidget.saveWidgetData(
        'dzuhur_done',
        isFriday ? _isDone(summary, 'JUMAT') : _isDone(summary, 'DZUHUR'),
      );
      await HomeWidget.saveWidgetData(
        'ashar_done',
        _isDone(summary, 'ASHAR'),
      );
      await HomeWidget.saveWidgetData(
        'maghrib_done',
        _isDone(summary, 'MAGHRIB'),
      );
      await HomeWidget.saveWidgetData(
        'isya_done',
        _isDone(summary, 'ISYA'),
      );
    }

    await HomeWidget.saveWidgetData(
      'last_update',
      DateFormat('HH:mm').format(DateTime.now()),
    );

    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
      iOSName: 'PrayerWidget',
    );
  }

  static bool _isDone(SummaryItemEntity summary, String prayerName) {
    return (summary.byPrayer[prayerName]?.performed ?? 0) > 0;
  }

  static int _getDoneCount(SummaryItemEntity summary) {
    final isFriday = DateTime.now().weekday == DateTime.friday;
    final prayers = [
      'SUBUH',
      isFriday ? 'JUMAT' : 'DZUHUR',
      'ASHAR',
      'MAGHRIB',
      'ISYA',
    ];
    return prayers.where((p) => _isDone(summary, p)).length;
  }
}
