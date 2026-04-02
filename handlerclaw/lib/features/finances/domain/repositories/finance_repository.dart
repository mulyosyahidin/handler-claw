import 'package:handlerclaw/features/finances/domain/entities/finance_overview_entity.dart';

abstract class IFinanceRepository {
  Future<FinanceOverviewEntity> getOverview();
}
