import 'package:handlerclaw/features/home/domain/entities/home_overview_entity.dart';

abstract class HomeRepository {
  Future<HomeOverviewEntity> getOverview();
}
