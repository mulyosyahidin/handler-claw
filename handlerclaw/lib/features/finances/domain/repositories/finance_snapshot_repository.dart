import 'package:handlerclaw/features/finances/domain/entities/account_snapshot_entity.dart';

abstract class IAccountSnapshotRepository {
  Future<List<AccountSnapshotEntity>> getSnapshots(String accountId);
  Future<AccountSnapshotEntity> createSnapshot({
    required String accountId,
    required double amount,
    required DateTime date,
    String? note,
  });
  Future<void> deleteSnapshot(String id);
}
