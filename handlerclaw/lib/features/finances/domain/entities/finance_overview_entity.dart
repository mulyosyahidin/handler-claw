import 'package:handlerclaw/features/finances/domain/entities/account_entity.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_type_entity.dart';

enum FinanceTopMoverDirection { up, down, stable }

class FinanceTopMoverEntity {
  final String id;
  final String name;
  final double amountChange;
  final double percentChange;
  final FinanceTopMoverDirection direction;

  FinanceTopMoverEntity({
    required this.id,
    required this.name,
    required this.amountChange,
    required this.percentChange,
    required this.direction,
  });
}

class FinanceOverviewEntity {
  final double totalNetWorth;
  final double liquidAmount;
  final double debtAmount;
  final double investmentAmount;
  final double liquidPct;
  final double debtPct;
  final double investmentPct;
  final double debtToAssetRatio;

  final List<AccountTypeEntity> accountTypes;
  final List<AccountEntity> accounts;
  final List<FinanceTopMoverEntity> topMovers;

  FinanceOverviewEntity({
    required this.totalNetWorth,
    required this.liquidAmount,
    required this.debtAmount,
    required this.investmentAmount,
    required this.liquidPct,
    required this.debtPct,
    required this.investmentPct,
    required this.debtToAssetRatio,
    required this.accountTypes,
    required this.accounts,
    required this.topMovers,
  });
}
