class PrayerLogEntity {
  final String id;
  final String userId;
  final DateTime date;
  final String prayer;
  final String category;
  final bool performed;
  final DateTime performedAt;
  final bool isQadha;
  final String method;
  final String place;
  final String? notes;

  PrayerLogEntity({
    required this.id,
    required this.userId,
    required this.date,
    required this.prayer,
    required this.category,
    required this.performed,
    required this.performedAt,
    required this.isQadha,
    required this.method,
    required this.place,
    this.notes,
  });
}
