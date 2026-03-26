import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/home/domain/entities/home_overview_entity.dart';
import 'package:handlerclaw/features/home/domain/repositories/home_repository.dart';
import 'package:handlerclaw/features/home/data/repositories/home_repository_impl.dart';

class HomeController extends AsyncNotifier<HomeOverviewEntity> {
  HomeRepository get _repository => ref.read(homeRepositoryProvider);

  @override
  Future<HomeOverviewEntity> build() async {
    return _fetchOverview();
  }

  Future<HomeOverviewEntity> _fetchOverview() async {
    return await _repository.getOverview();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchOverview());
  }
}

final homeControllerProvider =
    AsyncNotifierProvider<HomeController, HomeOverviewEntity>(
      HomeController.new,
    );
