import 'package:handlerclaw/features/finances/data/dto/account_dto.dart';
import 'package:handlerclaw/features/finances/data/dto/account_type_dto.dart';

class FinanceTopMoverDto {
  final String id;
  final String name;
  final double amountChange;
  final double percentageChange;
  final String direction;

  FinanceTopMoverDto({
    required this.id,
    required this.name,
    required this.amountChange,
    required this.percentageChange,
    required this.direction,
  });

  factory FinanceTopMoverDto.fromJson(Map<String, dynamic> json) {
    return FinanceTopMoverDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      amountChange: (json['amount_change'] ?? 0).toDouble(),
      percentageChange: (json['percentage_change'] ?? 0).toDouble(),
      direction: json['direction'] ?? 'STABLE',
    );
  }
}

class FinanceOverviewDto {
  final double totalNetWorth;
  final double liquidAmount;
  final double debtAmount;
  final double investmentAmount;
  final double liquidPct;
  final double debtPct;
  final double investmentPct;
  final double debtToAssetRatio;

  final List<AccountTypeDto> accountTypes;
  final List<AccountDto> accounts;
  final List<FinanceTopMoverDto> topMovers;

  FinanceOverviewDto({
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

  factory FinanceOverviewDto.fromJson(Map<String, dynamic> json) {
    final categories = json['categories'] as Map<String, dynamic>? ?? {};
    final allocation = (json['allocation'] ?? json['allocations']) as Map<String, dynamic>? ?? {};
    final ratios = json['ratios'] as Map<String, dynamic>? ?? {};

    return FinanceOverviewDto(
      totalNetWorth: (json['total_net_worth'] ?? 0).toDouble(),
      liquidAmount: (categories['liquid'] ?? 0).toDouble(),
      debtAmount: (categories['debt'] ?? 0).toDouble(),
      investmentAmount: (categories['investment'] ?? 0).toDouble(),
      liquidPct: (allocation['liquid_pct'] ?? 0).toDouble(),
      debtPct: (allocation['debt_pct'] ?? 0).toDouble(),
      investmentPct: (allocation['investment_pct'] ?? 0).toDouble(),
      debtToAssetRatio: (ratios['debt_to_asset_ratio'] ?? 0).toDouble(),
      accountTypes: (json['account_types'] as List?)
              ?.map((e) => AccountTypeDto.fromJson(e))
              .toList() ??
          [],
      accounts: (json['accounts'] as List?)
              ?.map((e) => AccountDto.fromJson(e))
              .toList() ??
          [],
      topMovers: (json['top_movers'] as List?)
              ?.map((e) => FinanceTopMoverDto.fromJson(e))
              .toList() ??
          [],
    );
  }
}
