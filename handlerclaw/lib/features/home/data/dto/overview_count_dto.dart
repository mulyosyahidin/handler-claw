class OverviewCountDto {
  final int whatsappLog;
  final int prayerLog;
  final int notificationWebhook;
  final int notification;
  final int device;
  final int apiKey;

  OverviewCountDto({
    required this.whatsappLog,
    required this.prayerLog,
    required this.notificationWebhook,
    required this.notification,
    required this.device,
    required this.apiKey,
  });

  factory OverviewCountDto.fromJson(Map<String, dynamic> json) {
    return OverviewCountDto(
      whatsappLog: json['whatsapp_log'] ?? 0,
      prayerLog: json['prayer_log'] ?? 0,
      notificationWebhook: json['notification_webhook'] ?? 0,
      notification: json['notification'] ?? 0,
      device: json['device'] ?? 0,
      apiKey: json['api_key'] ?? 0,
    );
  }
}

