class FilterDto {
  final String? dateType;
  final Map<String, dynamic> filtered;

  FilterDto({this.dateType, required this.filtered});

  factory FilterDto.fromJson(Map<String, dynamic> json) {
    return FilterDto(
      dateType: json["date_type"],
      filtered: json["filtered"] ?? {},
    );
  }

  factory FilterDto.empty() {
    return FilterDto(dateType: null, filtered: {});
  }
}
