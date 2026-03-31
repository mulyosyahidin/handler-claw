import 'package:intl/intl.dart';

class CurrencyUtils {
  static String formatIdr(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatCompactIdr(double amount) {
    final formatter = NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 1,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount) {
    final formatter = NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 1,
    );
    return formatter.format(amount).trim();
  }
}
