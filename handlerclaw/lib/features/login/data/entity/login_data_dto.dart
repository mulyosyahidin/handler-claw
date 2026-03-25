
import 'package:handlerclaw/core/data/dto/user_dto.dart';

class LoginDataDto {
  final UserDto user;
  final String accessToken;

  LoginDataDto({
    required this.user,
    required this.accessToken,
  });

  factory LoginDataDto.fromJson(Map<String, dynamic> json) {
    return LoginDataDto(
      user: UserDto.fromJson(json["user"]),
      accessToken: json["access_token"],
    );
  }
}