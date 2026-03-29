class FileDto {
  final String id;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String filePath;

  FileDto({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.filePath,
  });

  factory FileDto.fromJson(Map<String, dynamic> json) {
    return FileDto(
      id: json['id'] ?? '',
      fileName: json['file_name'] ?? '',
      fileType: json['file_type'] ?? '',
      fileSize: json['file_size'] ?? 0,
      filePath: json['file_path'] ?? '',
    );
  }
}
