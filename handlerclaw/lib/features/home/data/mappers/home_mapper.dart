import 'package:handlerclaw/features/home/data/dto/overview_count_dto.dart';
import 'package:handlerclaw/features/home/domain/entities/home_overview_entity.dart';

class HomeMapper {
  static HomeOverviewEntity fromCountDto(OverviewCountDto dto) {
    return HomeOverviewEntity(
      totalWhatsappLogs: dto.totalWhatsappLogs,
      totalPrayerLogs: dto.totalPrayerLogs,
      totalReminderHooks: dto.totalReminderHooks,
      totalDevices: dto.totalDevices,
    );
  }
}
