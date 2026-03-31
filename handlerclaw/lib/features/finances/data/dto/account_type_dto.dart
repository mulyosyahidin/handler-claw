import 'package:handlerclaw/features/finances/data/dto/account_dto.dart';

class AccountTypeDto {
  final String id;
  final String name;
  final String category;
  final double currentTotalAmount;
  final int accountCount;
  final List<AccountDto> accounts;

  AccountTypeDto({
    required this.id,
    required this.name,
    required this.category,
    required this.currentTotalAmount,
    required this.accountCount,
    required this.accounts,
  });

  factory AccountTypeDto.fromJson(Map<String, dynamic> json) {
    return AccountTypeDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      currentTotalAmount: (json['current_total_amount'] ?? 0).toDouble(),
      accountCount: json['account_count'] ?? 0,
      accounts: (json['accounts'] as List?)
              ?.map((e) => AccountDto.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AccountCategoryDto {
  final String name;
  final int totalAccountTypes;
  final double totalAmount;

  AccountCategoryDto({
    required this.name,
    required this.totalAccountTypes,
    required this.totalAmount,
  });

  factory AccountCategoryDto.fromJson(Map<String, dynamic> json) {
    return AccountCategoryDto(
      name: json['name'] ?? '',
      totalAccountTypes: json['total_account_types'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
    );
  }
}

class AccountTypesPaginatedDto {
  final List<AccountTypeDto> accountTypes;
  final List<AccountCategoryDto> categories;

  AccountTypesPaginatedDto({
    required this.accountTypes,
    required this.categories,
  });

  factory AccountTypesPaginatedDto.fromJson(Map<String, dynamic> json) {
    return AccountTypesPaginatedDto(
      accountTypes: (json['account_types'] as List?)
              ?.map((e) => AccountTypeDto.fromJson(e))
              .toList() ??
          [],
      categories: (json['categories'] as List?)
              ?.map((e) => AccountCategoryDto.fromJson(e))
              .toList() ??
          [],
    );
  }
}
