import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/finances/data/repositories/finance_snapshot_repository_impl.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_snapshot_entity.dart';

final accountSnapshotsProvider =
    FutureProvider.family<List<AccountSnapshotEntity>, String>((ref, accountId) async {
  final repository = ref.read(accountSnapshotRepositoryProvider);
  return await repository.getSnapshots(accountId);
});

class CreateSnapshotController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createSnapshot({
    required String accountId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(accountSnapshotRepositoryProvider);
      await repository.createSnapshot(
        accountId: accountId,
        amount: amount,
        date: date,
        note: note,
      );
      
      ref.invalidate(accountSnapshotsProvider(accountId));
    });
  }
}

final createSnapshotControllerProvider =
    AsyncNotifierProvider<CreateSnapshotController, void>(
  CreateSnapshotController.new,
);

class DeleteSnapshotController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> deleteSnapshot({
    required String id,
    required String accountId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(accountSnapshotRepositoryProvider);
      await repository.deleteSnapshot(id);
      ref.invalidate(accountSnapshotsProvider(accountId));
    });
  }
}

final deleteSnapshotControllerProvider =
    AsyncNotifierProvider<DeleteSnapshotController, void>(
  DeleteSnapshotController.new,
);
