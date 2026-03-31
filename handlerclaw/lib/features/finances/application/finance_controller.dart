import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/finances/data/repositories/finance_repository_impl.dart';
import 'package:handlerclaw/features/finances/domain/entities/finance_overview_entity.dart';
import 'package:handlerclaw/features/finances/domain/repositories/finance_repository.dart';

class FinanceController extends AsyncNotifier<FinanceOverviewEntity> {
  late final IFinanceRepository _repository;

  @override
  FutureOr<FinanceOverviewEntity> build() {
    _repository = ref.read(financeRepositoryProvider);
    return _fetch();
  }

  Future<FinanceOverviewEntity> _fetch() async {
    return await _repository.getOverview();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }
}

final financeControllerProvider =
    AsyncNotifierProvider<FinanceController, FinanceOverviewEntity>(() {
  return FinanceController();
});
