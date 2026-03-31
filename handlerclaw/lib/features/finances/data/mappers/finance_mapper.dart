import 'package:handlerclaw/features/finances/data/dto/account_dto.dart';
import 'package:handlerclaw/features/finances/data/dto/finance_overview_dto.dart';
import 'package:handlerclaw/features/finances/data/mappers/account_type_mapper.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_entity.dart';
import 'package:handlerclaw/features/finances/domain/entities/finance_overview_entity.dart';

class FinanceMapper {
  static FinanceOverviewEntity toEntity(FinanceOverviewDto dto) {
    return FinanceOverviewEntity(
      totalNetWorth: dto.totalNetWorth,
      liquidAmount: dto.liquidAmount,
      debtAmount: dto.debtAmount,
      investmentAmount: dto.investmentAmount,
      liquidPct: dto.liquidPct,
      debtPct: dto.debtPct,
      investmentPct: dto.investmentPct,
      debtToAssetRatio: dto.debtToAssetRatio,
      accountTypes: dto.accountTypes.map((e) => AccountTypeMapper.toAccountTypeEntity(e)).toList(),
      accounts: dto.accounts.map((e) => AccountTypeMapper.toAccountEntity(e)).toList(),
      topMovers: dto.topMovers
          .map((e) => FinanceTopMoverEntity(
                id: e.id,
                name: e.name,
                amountChange: e.amountChange,
                percentChange: e.percentageChange,
                direction: _mapDirection(e.direction),
              ))
          .toList(),
    );
  }

  // Helper method if needed to map a list of AccountDto to AccountEntity
  static List<AccountEntity> toAccountEntityList(List<AccountDto> dtos) {
    return dtos.map((e) => AccountTypeMapper.toAccountEntity(e)).toList();
  }

  static FinanceTopMoverDirection _mapDirection(String direction) {
    switch (direction) {
      case 'UP':
        return FinanceTopMoverDirection.up;
      case 'DOWN':
        return FinanceTopMoverDirection.down;
      default:
        return FinanceTopMoverDirection.stable;
    }
  }
}
