import 'package:handlerclaw/features/home/data/responses/overview_response_dto.dart';
import 'package:handlerclaw/features/home/domain/entities/home_overview_entity.dart';

class HomeMapper {
  static HomeOverviewEntity fromData(OverviewData data) {
    final dto = data.count;
    return HomeOverviewEntity(
      totalWhatsappLogs: dto.whatsappMessage,
      totalPrayerLogs: dto.prayerLog,
      totalReminderHooks: dto.notificationWebhook,
      totalNotifications: dto.notification,
      totalDevices: dto.device,
      totalApiKeys: dto.apiKey,
      prayerStatus: data.prayerStatus,
    );
  }
}

