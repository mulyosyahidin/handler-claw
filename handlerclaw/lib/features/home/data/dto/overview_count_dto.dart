import 'package:handlerclaw/features/home/domain/overview.dart';

class OverviewCountDto {
  final int totalWhatsappLogs;
  final int totalPrayerLogs;
  final int totalReminderHooks;
  final int totalDevices;

  OverviewCountDto({
    required this.totalWhatsappLogs,
    required this.totalPrayerLogs,
    required this.totalReminderHooks,
    required this.totalDevices,
  });

  factory OverviewCountDto.fromJson(Map<String, dynamic> json) {
    return OverviewCountDto(
      totalWhatsappLogs: json['total_whatsapp_logs'] ?? 0,
      totalPrayerLogs: json['total_prayer_logs'] ?? 0,
      totalReminderHooks: json['total_reminder_hooks'] ?? 0,
      totalDevices: json['total_devices'] ?? 0,
    );
  }

  Overview toEntity() {
    return Overview(
      totalWhatsappLogs: totalWhatsappLogs,
      totalPrayerLogs: totalPrayerLogs,
      totalReminderHooks: totalReminderHooks,
      totalDevices: totalDevices,
    );
  }
}
