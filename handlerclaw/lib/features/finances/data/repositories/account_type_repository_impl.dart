import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/finances/data/datasources/account_type_remote_data_source.dart';
import 'package:handlerclaw/features/finances/data/mappers/account_type_mapper.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_type_entity.dart';
import 'package:handlerclaw/features/finances/domain/repositories/account_type_repository.dart';

class AccountTypeRepositoryImpl implements IAccountTypeRepository {
  final AccountTypeRemoteDataSource _remoteDataSource;

  AccountTypeRepositoryImpl(this._remoteDataSource);

  @override
  Future<AccountTypesResultEntity> getAccountTypes({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    final response = await _remoteDataSource.getAccountTypes(
      page: page,
      perPage: perPage,
      search: search,
    );

    if (response.success && response.data != null) {
      return AccountTypeMapper.toAccountTypesResultEntity(response.data!);
    } else {
      throw Exception(response.message);
    }
  }

  @override
  Future<void> createAccountType({
    required String name,
    required String category,
  }) async {
    final response = await _remoteDataSource.createAccountType(
      name: name,
      category: category,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  @override
  Future<void> deleteAccountType(String id) async {
    await _remoteDataSource.deleteAccountType(id);
  }

  @override
  Future<void> updateAccountType({
    required String id,
    String? name,
    String? category,
  }) async {
    final response = await _remoteDataSource.updateAccountType(
      id: id,
      name: name,
      category: category,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }
}

final accountTypeRepositoryProvider = Provider<IAccountTypeRepository>((ref) {
  final remoteDataSource = ref.read(accountTypeRemoteDataSourceProvider);
  return AccountTypeRepositoryImpl(remoteDataSource);
});
