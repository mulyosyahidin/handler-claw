class SummaryItemDto {
  final String label;
  final int totalWajibPerformed;
  final int totalSunnahPerformed;
  final int totalPerformed;
  final int totalQadha;
  final Map<String, PrayerDetailDto> byPrayer;

  SummaryItemDto({
    required this.label,
    required this.totalWajibPerformed,
    required this.totalSunnahPerformed,
    required this.totalPerformed,
    required this.totalQadha,
    required this.byPrayer,
  });

  factory SummaryItemDto.fromJson(Map<String, dynamic> json) {
    var byPrayerMap = <String, PrayerDetailDto>{};
    if (json["by_prayer"] != null) {
      json["by_prayer"].forEach((key, value) {
        byPrayerMap[key] = PrayerDetailDto.fromJson(value);
      });
    }

    return SummaryItemDto(
      label: json["label"] ?? "",
      totalWajibPerformed: json["total_wajib_performed"] ?? 0,
      totalSunnahPerformed: json["total_sunnah_performed"] ?? 0,
      totalPerformed: json["total_performed"] ?? 0,
      totalQadha: json["total_qadha"] ?? 0,
      byPrayer: byPrayerMap,
    );
  }
}

class PrayerDetailDto {
  final int performed;
  final int qadha;
  final int jamaah;

  PrayerDetailDto({
    required this.performed,
    required this.qadha,
    required this.jamaah,
  });

  factory PrayerDetailDto.fromJson(Map<String, dynamic> json) {
    return PrayerDetailDto(
      performed: json["performed"] ?? 0,
      qadha: json["qadha"] ?? 0,
      jamaah: json["jamaah"] ?? 0,
    );
  }
}
