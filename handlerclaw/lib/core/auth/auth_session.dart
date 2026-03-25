import 'package:handlerclaw/core/data/dto/user_dto.dart';

class AuthSession {
  final String? token;
  final UserDto? userDto;

  const AuthSession({this.token, this.userDto});

  factory AuthSession.unauthenticated() {
    return const AuthSession();
  }

  factory AuthSession.authenticated(String token, UserDto userDto) {
    
    return AuthSession(token: token, userDto: userDto);
  }

  bool get isAuthenticated => token != null && userDto != null;
  bool get isUserDataReady => token != null && userDto != null;
}
