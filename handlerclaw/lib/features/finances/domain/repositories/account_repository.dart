import 'package:handlerclaw/features/finances/domain/entities/account_entity.dart';

abstract class IAccountRepository {
  Future<AccountsResultEntity> getAccounts({
    int page = 1,
    int perPage = 20,
    String? search,
  });

  Future<void> createAccount({
    required String name,
    required String accountTypeId,
  });

  Future<AccountEntity> getAccount(String id);

  Future<void> updateAccount({
    required String id,
    String? name,
    String? accountTypeId,
  });

  Future<void> deleteAccount(String id);
}
