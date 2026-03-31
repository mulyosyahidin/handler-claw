import 'package:handlerclaw/features/finances/domain/entities/account_entity.dart';

class AccountTypeEntity {
  final String id;
  final String name;
  final String category;
  final double currentTotalAmount;
  final int accountCount;
  final List<AccountEntity> accounts;

  AccountTypeEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.currentTotalAmount,
    required this.accountCount,
    required this.accounts,
  });
}

class AccountCategoryEntity {
  final String name;
  final int totalAccountTypes;
  final double totalAmount;

  AccountCategoryEntity({
    required this.name,
    required this.totalAccountTypes,
    required this.totalAmount,
  });
}

class AccountTypesResultEntity {
  final List<AccountCategoryEntity> categories;
  final List<AccountTypeEntity> accountTypes;

  AccountTypesResultEntity({
    required this.categories,
    required this.accountTypes,
  });
}
