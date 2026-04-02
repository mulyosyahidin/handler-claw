import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/app/navigation_keys.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/utils/toast_utils.dart';
import 'package:handlerclaw/features/home/application/home_controller.dart';
import 'package:handlerclaw/core/widgets/shimmer_box.dart';
import 'package:handlerclaw/features/finances/application/account_snapshot_controller.dart';
import 'package:handlerclaw/features/finances/application/accounts_controller.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_entity.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_snapshot_entity.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/snapshots/account_snapshot_header.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/snapshots/snapshot_tile.dart';

class AccountSnapshotsPage extends ConsumerStatefulWidget {
  final String accountId;

  const AccountSnapshotsPage({super.key, required this.accountId});

  @override
  ConsumerState<AccountSnapshotsPage> createState() =>
      _AccountSnapshotsPageState();
}

class _AccountSnapshotsPageState extends ConsumerState<AccountSnapshotsPage> {
  // Optimistic removal: langsung hilangkan dari tree saat swipe,
  // sebelum API response kembali — menghindari FlutterError Dismissible.
  final Set<String> _dismissedIds = {};

  @override
  Widget build(BuildContext context) {
    final snapshotsAsync = ref.watch(
      accountSnapshotsProvider(widget.accountId),
    );
    final accountAsync = ref.watch(accountDetailProvider(widget.accountId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Riwayat Saldo', style: AppTextStyles.label(fontSize: 12)),
            accountAsync.when(
              data: (account) =>
                  Text(account.name, style: AppTextStyles.title(fontSize: 18)),
              loading: () => const ShimmerBox(width: 120, height: 20),
              error: (_, _) =>
                  Text('Akun', style: AppTextStyles.title(fontSize: 18)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          Routes.financeCreateSnapshot,
          extra: {
            'accountId': widget.accountId,
            'accountName': accountAsync.maybeWhen(
              data: (a) => a.name,
              orElse: () => '',
            ),
          },
        ),
        tooltip: 'Tambah Snapshot',
        child: const Icon(Icons.add_rounded),
      ),
      body: (snapshotsAsync.isLoading || accountAsync.isLoading)
          ? _buildBody(context, null, [], isLoading: true)
          : snapshotsAsync.when(
              data: (snapshots) => _buildBody(
                context,
                accountAsync.asData?.value,
                snapshots,
                isLoading: false,
              ),
              loading: () => _buildBody(context, null, [], isLoading: true),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AccountEntity? account,
    List<AccountSnapshotEntity> snapshots, {
    required bool isLoading,
  }) {
    if (isLoading) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: const ShimmerBox(
                width: double.infinity,
                height: 160,
                borderRadius: 24,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: ShimmerBox(width: double.infinity, height: 80),
                ),
                childCount: 5,
              ),
            ),
          ),
        ],
      );
    }

    // Sort snapshots by date descending
    final visible =
        snapshots.where((s) => !_dismissedIds.contains(s.id)).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _dismissedIds.clear());
        ref.invalidate(accountSnapshotsProvider(widget.accountId));
        ref.invalidate(accountDetailProvider(widget.accountId));

        await ref.read(accountSnapshotsProvider(widget.accountId).future);
        await ref.read(accountDetailProvider(widget.accountId).future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Account Summary Header ──
          if (account != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: AccountSnapshotHeader(
                  account: account,
                  snapshotCount: snapshots.length,
                ),
              ),
            ),

          // ── Snapshots List ──
          if (visible.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada riwayat saldo',
                      style: AppTextStyles.body(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Catatan perubahan saldo akan muncul di sini.',
                      style: AppTextStyles.label(),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final snapshot = visible[index];
                  double? diff;
                  if (index < visible.length - 1) {
                    diff = snapshot.amount - visible[index + 1].amount;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SnapshotTile(
                      key: ValueKey(snapshot.id),
                      snapshot: snapshot,
                      difference: diff,
                      onDismissed: () async {
                        setState(() => _dismissedIds.add(snapshot.id));
                        try {
                          await ref
                              .read(deleteSnapshotControllerProvider.notifier)
                              .deleteSnapshot(
                                id: snapshot.id,
                                accountId: widget.accountId,
                              );

                          // Use root context since this tile is being unmounted
                          final stableContext =
                              rootNavigatorKey.currentContext ?? context;
                          if (stableContext.mounted) {
                            ToastUtils.showSuccess(
                              stableContext,
                              title: 'Berhasil',
                              description: 'Snapshot berhasil dihapus',
                            );
                            ref.read(homeControllerProvider.notifier).refresh();
                          }
                        } catch (e, stackTrace) {
                          FirebaseCrashlytics.instance.recordError(
                            e,
                            stackTrace,
                            reason: 'AccountSnapshotsPage.onDismissed',
                          );
                          setState(() => _dismissedIds.remove(snapshot.id));
                          final stableContext =
                              rootNavigatorKey.currentContext ?? context;
                          if (stableContext.mounted) {
                            ToastUtils.showError(
                              stableContext,
                              title: 'Gagal',
                              description: 'Gagal menghapus snapshot',
                            );
                          }
                        }
                      },
                    ),
                  );
                }, childCount: visible.length),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
