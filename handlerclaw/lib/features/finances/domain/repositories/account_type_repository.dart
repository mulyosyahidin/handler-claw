import 'package:handlerclaw/features/finances/domain/entities/account_type_entity.dart';

abstract class IAccountTypeRepository {
  Future<AccountTypesResultEntity> getAccountTypes({
    int page = 1,
    int perPage = 20,
    String? search,
  });

  Future<void> createAccountType({
    required String name,
    required String category,
  });

  Future<void> deleteAccountType(String id);

  Future<void> updateAccountType({
    required String id,
    String? name,
    String? category,
  });
}
