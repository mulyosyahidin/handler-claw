import 'package:handlerclaw/core/data/dto/file_dto.dart';

class FileUploadResponseDto {
  final bool success;
  final String message;
  final FileUploadData? data;

  FileUploadResponseDto({
    required this.success,
    required this.message,
    this.data,
  });

  factory FileUploadResponseDto.fromJson(Map<String, dynamic> json) {
    return FileUploadResponseDto(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? FileUploadData.fromJson(json['data']) : null,
    );
  }
}

class FileUploadData {
  final FileDto file;

  FileUploadData({required this.file});

  factory FileUploadData.fromJson(Map<String, dynamic> json) {
    return FileUploadData(
      file: FileDto.fromJson(json['file']),
    );
  }
}
