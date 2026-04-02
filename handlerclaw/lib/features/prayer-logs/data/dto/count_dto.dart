class CountDto {
  final int subuh;
  final int dzuhur;
  final int ashar;
  final int maghrib;
  final int isya;
  final int jumat;
  final int dhuha;
  final int tahajud;
  final int witir;

  CountDto({
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

  factory CountDto.fromJson(Map<String, dynamic> json) {
    return CountDto(
      subuh: json["SUBUH"] ?? 0,
      dzuhur: json["DZUHUR"] ?? 0,
      ashar: json["ASHAR"] ?? 0,
      maghrib: json["MAGHRIB"] ?? 0,
      isya: json["ISYA"] ?? 0,
      jumat: json["JUMAT"] ?? 0,
      dhuha: json["DHUHA"] ?? 0,
      tahajud: json["TAHAJUD"] ?? 0,
      witir: json["WITIR"] ?? 0,
    );
  }

  factory CountDto.empty() {
    return CountDto(
      subuh: 0,
      dzuhur: 0,
      ashar: 0,
      maghrib: 0,
      isya: 0,
      jumat: 0,
      dhuha: 0,
      tahajud: 0,
      witir: 0,
    );
  }
}
