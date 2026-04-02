class HomeOverviewEntity {
  final int totalWhatsappLogs;
  final int totalPrayerLogs;
  final int totalReminderHooks;
  final int totalNotifications;
  final int totalDevices;
  final int totalApiKeys;

  final Map<String, bool> prayerStatus;
 
  const HomeOverviewEntity({
    required this.totalWhatsappLogs,
    required this.totalPrayerLogs,
    required this.totalReminderHooks,
    required this.totalNotifications,
    required this.totalDevices,
    required this.totalApiKeys,
    required this.prayerStatus,
  });

  factory HomeOverviewEntity.initial() {
    return const HomeOverviewEntity(
      totalWhatsappLogs: 0,
      totalPrayerLogs: 0,
      totalReminderHooks: 0,
      totalNotifications: 0,
      totalDevices: 0,
      totalApiKeys: 0,
      prayerStatus: {},
    );
  }
}

