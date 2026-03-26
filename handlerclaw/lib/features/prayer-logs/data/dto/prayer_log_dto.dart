class PrayerLogDto {
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

  PrayerLogDto({
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

  factory PrayerLogDto.fromJson(Map<String, dynamic> json) {
    return PrayerLogDto(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      prayer: json['prayer'] ?? '',
      category: json['category'] ?? '',
      performed: json['performed'] ?? false,
      performedAt: DateTime.parse(
        json['performedAt'] ?? DateTime.now().toIso8601String(),
      ),
      isQadha: json['isQadha'] ?? false,
      method: json['method'] ?? 'SENDIRI',
      place: json['place'] ?? 'RUMAH',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'prayer': prayer,
      'category': category,
      'performed': performed,
      'performedAt': performedAt.toIso8601String(),
      'isQadha': isQadha,
      'method': method,
      'place': place,
      'notes': notes,
    };
  }
}
