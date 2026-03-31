import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/utils/logger.dart';
import 'package:handlerclaw/features/finances/data/repositories/account_type_repository_impl.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_type_entity.dart';

class AccountTypeController extends AsyncNotifier<AccountTypesResultEntity> {
  int _currentPage = 1;
  bool _hasMore = true;
  final int _perPage = 20;

  @override
  Future<AccountTypesResultEntity> build() async {
    Logger.info("AccountTypeController: build() called");
    _currentPage = 1;
    _hasMore = true;
    return _fetch();
  }

  Future<AccountTypesResultEntity> _fetch() async {
    Logger.info("AccountTypeController: _fetch() called, page: $_currentPage");
    final repository = ref.read(accountTypeRepositoryProvider);
    final result = await repository.getAccountTypes(
      page: _currentPage,
      perPage: _perPage,
    );

    if (result.accountTypes.length < _perPage) {
      _hasMore = false;
    }

    return result;
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    _currentPage++;
    final nextResult = await _fetch();

    final currentResult = state.value;
    if (currentResult != null) {
      state = AsyncValue.data(
        AccountTypesResultEntity(
          categories: nextResult.categories,
          accountTypes: [
            ...currentResult.accountTypes,
            ...nextResult.accountTypes,
          ],
        ),
      );
    } else {
      state = AsyncValue.data(nextResult);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> createAccountType({
    required String name,
    required String category,
  }) async {
    final repository = ref.read(accountTypeRepositoryProvider);
    await repository.createAccountType(name: name, category: category);
    await refresh();
  }

  Future<void> deleteAccountType(String id) async {
    final repository = ref.read(accountTypeRepositoryProvider);
    await repository.deleteAccountType(id);
    await refresh();
  }

  Future<void> updateAccountType({
    required String id,
    String? name,
    String? category,
  }) async {
    final repository = ref.read(accountTypeRepositoryProvider);
    await repository.updateAccountType(
      id: id,
      name: name,
      category: category,
    );
    await refresh();
  }
}

final accountTypeControllerProvider =
    AsyncNotifierProvider<AccountTypeController, AccountTypesResultEntity>(() {
  return AccountTypeController();
});
