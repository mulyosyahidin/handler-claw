class HomeOverviewEntity {
  final int totalWhatsappLogs;
  final int totalPrayerLogs;
  final int totalReminderHooks;
  final int totalDevices;

  const HomeOverviewEntity({
    required this.totalWhatsappLogs,
    required this.totalPrayerLogs,
    required this.totalReminderHooks,
    required this.totalDevices,
  });

  factory HomeOverviewEntity.initial() {
    return const HomeOverviewEntity(
      totalWhatsappLogs: 0,
      totalPrayerLogs: 0,
      totalReminderHooks: 0,
      totalDevices: 0,
    );
  }
}
