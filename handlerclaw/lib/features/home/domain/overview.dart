class Overview {
  final int totalWhatsappLogs;
  final int totalPrayerLogs;
  final int totalReminderHooks;
  final int totalDevices;

  const Overview({
    required this.totalWhatsappLogs,
    required this.totalPrayerLogs,
    required this.totalReminderHooks,
    required this.totalDevices,
  });

  factory Overview.initial() {
    return const Overview(
      totalWhatsappLogs: 0,
      totalPrayerLogs: 0,
      totalReminderHooks: 0,
      totalDevices: 0,
    );
  }
}
