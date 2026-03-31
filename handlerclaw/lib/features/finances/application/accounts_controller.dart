import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/finances/data/repositories/account_repository_impl.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_entity.dart';

class AccountSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final accountSearchQueryProvider =
    NotifierProvider.autoDispose<AccountSearchQuery, String>(
      AccountSearchQuery.new,
    );

class AccountsController extends AsyncNotifier<AccountsResultEntity> {
  @override
  Future<AccountsResultEntity> build() async {
    final search = ref.watch(accountSearchQueryProvider);
    return _fetchAccounts(search: search);
  }

  Future<AccountsResultEntity> _fetchAccounts({
    int page = 1,
    int perPage = 100,
    String? search,
  }) async {
    final repository = ref.read(accountRepositoryProvider);
    return repository.getAccounts(page: page, perPage: perPage, search: search);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final search = ref.read(accountSearchQueryProvider);
    state = await AsyncValue.guard(() => _fetchAccounts(search: search));
  }

  Future<void> createAccount({
    required String name,
    required String accountTypeId,
  }) async {
    final repository = ref.read(accountRepositoryProvider);
    await repository.createAccount(name: name, accountTypeId: accountTypeId);
    await refresh();
  }

  Future<void> updateAccount({
    required String id,
    String? name,
    String? accountTypeId,
  }) async {
    final repository = ref.read(accountRepositoryProvider);
    await repository.updateAccount(
      id: id,
      name: name,
      accountTypeId: accountTypeId,
    );
    await refresh();
    ref.invalidate(accountDetailProvider(id));
  }

  Future<void> deleteAccount(String id) async {
    final repository = ref.read(accountRepositoryProvider);
    await repository.deleteAccount(id);
    await refresh();
  }
}

final accountsControllerProvider =
    AsyncNotifierProvider.autoDispose<AccountsController, AccountsResultEntity>(
      AccountsController.new,
    );

final accountDetailProvider =
    FutureProvider.autoDispose.family<AccountEntity, String>((ref, id) async {
  final repository = ref.read(accountRepositoryProvider);
  return await repository.getAccount(id);
});
