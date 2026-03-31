import 'package:intl/intl.dart';

class DateUtils {
  static String formatFull(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  static String formatShort(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
