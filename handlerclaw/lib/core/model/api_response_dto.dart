class ApiResponseDto<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponseDto({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponseDto.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,
      ) {
    return ApiResponseDto<T>(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null ? fromJsonT(json["data"]) : null,
      errors: json["errors"] != null
          ? Map<String, dynamic>.from(json["errors"])
          : null,
    );
  }
}