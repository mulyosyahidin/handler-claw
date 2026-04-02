import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/finances/data/datasources/finance_remote_data_source.dart';
import 'package:handlerclaw/features/finances/data/mappers/finance_mapper.dart';
import 'package:handlerclaw/features/finances/domain/entities/finance_overview_entity.dart';
import 'package:handlerclaw/features/finances/domain/repositories/finance_repository.dart';

class FinanceRepositoryImpl implements IFinanceRepository {
  final FinanceRemoteDataSource _remoteDataSource;

  FinanceRepositoryImpl(this._remoteDataSource);

  @override
  Future<FinanceOverviewEntity> getOverview() async {
    final response = await _remoteDataSource.getOverview();

    if (response.success && response.data != null) {
      return FinanceMapper.toEntity(response.data!);
    } else {
      throw Exception(response.message);
    }
  }
}

final financeRepositoryProvider = Provider<IFinanceRepository>((ref) {
  final remoteDataSource = ref.read(financeRemoteDataSourceProvider);
  return FinanceRepositoryImpl(remoteDataSource);
});
