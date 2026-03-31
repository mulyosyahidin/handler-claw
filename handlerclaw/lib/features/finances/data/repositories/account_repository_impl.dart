import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/finances/data/datasources/account_remote_data_source.dart';
import 'package:handlerclaw/features/finances/data/mappers/account_type_mapper.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_entity.dart';
import 'package:handlerclaw/features/finances/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements IAccountRepository {
  final AccountRemoteDataSource _remoteDataSource;

  AccountRepositoryImpl(this._remoteDataSource);

  @override
  Future<AccountsResultEntity> getAccounts({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    final response = await _remoteDataSource.getAccounts(
      page: page,
      perPage: perPage,
      search: search,
    );

    if (response.success && response.data != null) {
      final dto = response.data!;
      return AccountsResultEntity(
        accounts: dto.accounts.map((e) => AccountTypeMapper.toAccountEntity(e)).toList(),
        total: dto.meta.total,
        page: dto.meta.page,
        perPage: dto.meta.perPage,
      );
    } else {
      throw Exception(response.message);
    }
  }

  @override
  Future<void> createAccount({
    required String name,
    required String accountTypeId,
  }) async {
    final response = await _remoteDataSource.createAccount(
      name: name,
      accountTypeId: accountTypeId,
    );
    if (!response.success) {
      throw Exception(response.message);
    }
  }

  @override
  Future<AccountEntity> getAccount(String id) async {
    final response = await _remoteDataSource.getAccount(id);

    if (response.success && response.data != null) {
      return AccountTypeMapper.toAccountEntity(response.data!);
    } else {
      throw Exception(response.message);
    }
  }

  @override
  Future<void> updateAccount({
    required String id,
    String? name,
    String? accountTypeId,
  }) async {
    final response = await _remoteDataSource.updateAccount(
      id: id,
      name: name,
      accountTypeId: accountTypeId,
    );
    if (!response.success) {
      throw Exception(response.message);
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    final response = await _remoteDataSource.deleteAccount(id);
    if (!response.success) {
      throw Exception(response.message);
    }
  }
}

final accountRepositoryProvider = Provider<IAccountRepository>((ref) {
  final remoteDataSource = ref.read(accountRemoteDataSourceProvider);
  return AccountRepositoryImpl(remoteDataSource);
});
