import 'package:handlerclaw/features/finances/data/dto/account_dto.dart';
import 'package:handlerclaw/features/finances/data/dto/account_type_dto.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_entity.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_type_entity.dart';

class AccountTypeMapper {
  static AccountTypeEntity toAccountTypeEntity(AccountTypeDto dto) {
    return AccountTypeEntity(
      id: dto.id,
      name: dto.name,
      category: dto.category,
      currentTotalAmount: dto.currentTotalAmount,
      accountCount: dto.accountCount,
      accounts: dto.accounts.map((e) => toAccountEntity(e)).toList(),
    );
  }

  static AccountEntity toAccountEntity(AccountDto dto) {
    return AccountEntity(
      id: dto.id,
      name: dto.name,
      category: dto.category,
      currentAmount: dto.currentAmount,
      accountTypeId: dto.accountTypeId,
    );
  }

  static AccountCategoryEntity toAccountCategoryEntity(AccountCategoryDto dto) {
    return AccountCategoryEntity(
      name: dto.name,
      totalAccountTypes: dto.totalAccountTypes,
      totalAmount: dto.totalAmount,
    );
  }

  static AccountTypesResultEntity toAccountTypesResultEntity(AccountTypesPaginatedDto dto) {
    return AccountTypesResultEntity(
      categories: dto.categories.map((e) => toAccountCategoryEntity(e)).toList(),
      accountTypes: dto.accountTypes.map((e) => toAccountTypeEntity(e)).toList(),
    );
  }
}
