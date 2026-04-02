import 'package:flutter/material.dart';

class FinanceWidgetHelpers {
  static IconData getIconForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'LIQUID':
        return Icons.account_balance_wallet_rounded;
      case 'DEBT':
        return Icons.credit_card_rounded;
      case 'INVESTMENT':
        return Icons.trending_up_rounded;
      default:
        return Icons.money_rounded;
    }
  }

  static Color getColorForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'LIQUID':
        return Colors.blue;
      case 'DEBT':
        return Colors.red;
      case 'INVESTMENT':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static String getCategoryLabel(String category) {
    switch (category.toUpperCase()) {
      case 'LIQUID':
        return 'Kas & Bank';
      case 'INVESTMENT':
        return 'Investasi';
      case 'DEBT':
        return 'Hutang / Cicilan';
      default:
        return category;
    }
  }
}
