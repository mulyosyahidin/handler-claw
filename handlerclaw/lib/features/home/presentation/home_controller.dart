import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/home/data/home_api.dart';
import 'package:handlerclaw/features/home/domain/overview.dart';

class HomeController extends AsyncNotifier<Overview> {
  @override
  Future<Overview> build() async {
    return _fetchOverview();
  }

  Future<Overview> _fetchOverview() async {
    final api = ref.read(homeApiProvider);
    final response = await api.getOverview();
    return response.data?.count.toEntity() ?? Overview.initial();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchOverview());
  }
}

final homeControllerProvider = AsyncNotifierProvider<HomeController, Overview>(
  HomeController.new,
);
