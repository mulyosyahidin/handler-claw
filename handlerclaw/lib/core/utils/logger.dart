import 'package:flutter/foundation.dart';

class Logger {
  static const _reset = '\x1B[0m';

  static const _red = '\x1B[31m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _blue = '\x1B[34m';
  static const _cyan = '\x1B[36m';
  static const _magenta = '\x1B[35m';

  static void info(String message) {
    if (kDebugMode) {
      print('$_blue[INFO]$_reset $message');
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      print('$_green[SUCCESS]$_reset $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('$_yellow[WARNING]$_reset $message');
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      print('$_red[ERROR]$_reset $message');
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      print('$_cyan[DEBUG]$_reset $message');
    }
  }

  static void api(String method, String path) {
    if (kDebugMode) {
      print('$_magenta[API]$_reset $method $path');
    }
  }
}
