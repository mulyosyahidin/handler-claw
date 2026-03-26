class PerformanceItemDto {
  final int count;
  final double percentage;

  PerformanceItemDto({
    required this.count,
    required this.percentage,
  });

  factory PerformanceItemDto.fromJson(Map<String, dynamic> json) {
    return PerformanceItemDto(
      count: json["count"] ?? 0,
      percentage: (json["percentage"] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory PerformanceItemDto.empty() {
    return PerformanceItemDto(
      count: 0,
      percentage: 0.0,
    );
  }
}

class PerformancesDto {
  final PerformanceItemDto subuh;
  final PerformanceItemDto dzuhur;
  final PerformanceItemDto ashar;
  final PerformanceItemDto maghrib;
  final PerformanceItemDto isya;
  final PerformanceItemDto jumat;
  final PerformanceItemDto dhuha;
  final PerformanceItemDto tahajud;
  final PerformanceItemDto witir;

  PerformancesDto({
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    required this.jumat,
    required this.dhuha,
    required this.tahajud,
    required this.witir,
  });

  factory PerformancesDto.fromJson(Map<String, dynamic> json) {
    return PerformancesDto(
      subuh: PerformanceItemDto.fromJson(json["SUBUH"] ?? {}),
      dzuhur: PerformanceItemDto.fromJson(json["DZUHUR"] ?? {}),
      ashar: PerformanceItemDto.fromJson(json["ASHAR"] ?? {}),
      maghrib: PerformanceItemDto.fromJson(json["MAGHRIB"] ?? {}),
      isya: PerformanceItemDto.fromJson(json["ISYA"] ?? {}),
      jumat: PerformanceItemDto.fromJson(json["JUMAT"] ?? {}),
      dhuha: PerformanceItemDto.fromJson(json["DHUHA"] ?? {}),
      tahajud: PerformanceItemDto.fromJson(json["TAHAJUD"] ?? {}),
      witir: PerformanceItemDto.fromJson(json["WITIR"] ?? {}),
    );
  }

  factory PerformancesDto.empty() {
    return PerformancesDto(
      subuh: PerformanceItemDto.empty(),
      dzuhur: PerformanceItemDto.empty(),
      ashar: PerformanceItemDto.empty(),
      maghrib: PerformanceItemDto.empty(),
      isya: PerformanceItemDto.empty(),
      jumat: PerformanceItemDto.empty(),
      dhuha: PerformanceItemDto.empty(),
      tahajud: PerformanceItemDto.empty(),
      witir: PerformanceItemDto.empty(),
    );
  }
}
