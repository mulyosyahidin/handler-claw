import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/finances/data/datasources/finance_snapshot_remote_data_source.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_snapshot_entity.dart';
import 'package:handlerclaw/features/finances/domain/repositories/finance_snapshot_repository.dart';

class AccountSnapshotRepositoryImpl implements IAccountSnapshotRepository {
  final FinanceSnapshotRemoteDataSource _remoteDataSource;

  AccountSnapshotRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AccountSnapshotEntity>> getSnapshots(String accountId) async {
    final response = await _remoteDataSource.getSnapshots(accountId);

    if (response.success && response.snapshots != null) {
      return response.snapshots!.map((e) => e.toEntity()).toList();
    } else {
      throw Exception(response.message);
    }
  }

  @override
  Future<AccountSnapshotEntity> createSnapshot({
    required String accountId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final dto = await _remoteDataSource.createSnapshot(
      accountId: accountId,
      amount: amount,
      date: date,
      note: note,
    );
    return dto.toEntity();
  }

  @override
  Future<void> deleteSnapshot(String id) async {
    await _remoteDataSource.deleteSnapshot(id);
  }
}

final accountSnapshotRepositoryProvider =
    Provider<IAccountSnapshotRepository>((ref) {
  final remoteDataSource = ref.read(financeSnapshotRemoteDataSourceProvider);
  return AccountSnapshotRepositoryImpl(remoteDataSource);
});
