import 'package:handlerclaw/core/data/dto/user_dto.dart';
import 'package:handlerclaw/core/model/api_response.dart';

class MeResponseDto extends ApiResponse<UserDto> {
  MeResponseDto({
    required super.success,
    required super.message,
    super.data,
    super.errors,
  });

  factory MeResponseDto.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>?;

    return MeResponseDto(
      success: json['success'],
      message: json['message'],
      data: dataMap != null && dataMap['user'] != null
          ? UserDto.fromJson(dataMap['user'])
          : null,
      errors: json['errors'],
    );
  }
}