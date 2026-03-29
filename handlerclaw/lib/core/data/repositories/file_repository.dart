import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/core/data/responses/file_upload_response_dto.dart';

class FileRepository {
  final Dio _dio;

  FileRepository(this._dio);

  Future<FileUploadResponseDto> uploadFile(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        '/files',
        data: formData,
      );

      return FileUploadResponseDto.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

final fileRepositoryProvider = Provider<FileRepository>((ref) {
  return FileRepository(ref.read(dioProvider));
});
