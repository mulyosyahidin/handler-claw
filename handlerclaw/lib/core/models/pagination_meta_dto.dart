class PaginationMetaDto {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  PaginationMetaDto({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMetaDto.fromJson(Map<String, dynamic> json) {
    return PaginationMetaDto(
      page: json['page'] ?? 0,
      perPage: json['per_page'] ?? 0,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'per_page': perPage,
      'total': total,
      'total_pages': totalPages,
    };
  }
}
