class GrandTotalDto {
  int totalWajibPerformed;
  int totalSunnahPerformed;
  int totalPerformed;
  int totalQadha;

  GrandTotalDto({
    required this.totalWajibPerformed,
    required this.totalSunnahPerformed,
    required this.totalPerformed,
    required this.totalQadha,
  });

  factory GrandTotalDto.fromJson(Map<String, dynamic> json) {
    return GrandTotalDto(
      totalWajibPerformed: json["total_wajib_performed"] ?? 0,
      totalSunnahPerformed: json["total_sunnah_performed"] ?? 0,
      totalPerformed: json["total_performed"] ?? 0,
      totalQadha: json["total_qadha"] ?? 0,
    );
  }

  factory GrandTotalDto.empty() {
    return GrandTotalDto(
      totalWajibPerformed: 0,
      totalSunnahPerformed: 0,
      totalPerformed: 0,
      totalQadha: 0,
    );
  }
}
