class PrayerLogCreateRequestDto {
  final String prayer;
  final String performedAt;
  final String localDate;
  final String method;
  final String place;

  PrayerLogCreateRequestDto({
    required this.prayer,
    required this.performedAt,
    required this.localDate,
    this.method = 'SENDIRI',
    this.place = 'RUMAH',
  });

  Map<String, dynamic> toJson() {
    return {
      'prayer': prayer,
      'performed_at': performedAt,
      'local_date': localDate,
      'method': method,
      'place': place,
    };
  }
}
