import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/utils/logger.dart';
import 'package:handlerclaw/core/utils/currency_utils.dart';
import 'package:handlerclaw/core/widgets/shimmer_box.dart';
import 'package:handlerclaw/features/finances/application/account_type_controller.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_type_entity.dart';
import 'package:handlerclaw/features/finances/presentation/widgets/account_types/account_type_tile.dart';

class AccountTypesPage extends ConsumerStatefulWidget {
  const AccountTypesPage({super.key});

  @override
  ConsumerState<AccountTypesPage> createState() => _AccountTypesPageState();
}

class _AccountTypesPageState extends ConsumerState<AccountTypesPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(accountTypeControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    Logger.info("AccountTypesPage: build() called");
    final typesAsync = ref.watch(accountTypeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Tipe Akun', style: AppTextStyles.title())),
      body: typesAsync.when(
        data: (result) => _buildBody(context, ref, result, isLoading: false),
        loading: () => _buildBody(context, ref, null, isLoading: true),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.financeCreateAccountType),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AccountTypesResultEntity? result, {
    required bool isLoading,
  }) {
    final categories = result?.categories ?? [];
    final types = result?.accountTypes ?? [];

    // Group account types by category
    final Map<String, List<AccountTypeEntity>> groupedTypes = {};
    if (categories.isNotEmpty) {
      for (var category in categories) {
        groupedTypes[category.name] = types
            .where((t) => t.category == category.name)
            .toList();
      }
    } else if (types.isNotEmpty) {
      // Fallback if categories are not yet loaded but types are
      for (var type in types) {
        groupedTypes.putIfAbsent(type.category, () => []).add(type);
      }
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(accountTypeControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Categories Grid
          if (isLoading)
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const ShimmerBox(width: 80, height: 100),
                  childCount: 3,
                ),
              ),
            )
          else if (categories.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = categories[index];
                  return _CategoryCard(category: category);
                }, childCount: categories.length),
              ),
            ),

          if (categories.isNotEmpty && types.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(),
              ),
            ),

          // Grouped Account Types
          if (isLoading)
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: const ShimmerBox(width: double.infinity, height: 80),
                  ),
                  childCount: 8,
                ),
              ),
            )
          else if (types.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada tipe akun',
                      style: AppTextStyles.body(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ketuk ikon + untuk menambah tipe akun baru',
                      style: AppTextStyles.label(),
                    ),
                  ],
                ),
              ),
            )
          else
            ...groupedTypes.entries
                .where((e) => e.value.isNotEmpty)
                .expand(
                  (entry) => [
                    // Category Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: AppTextStyles.title(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Items for this Category
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final type = entry.value[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AccountTypeTile(type: type),
                          );
                        }, childCount: entry.value.length),
                      ),
                    ),
                  ],
                ),

          // Bottom padding for scrolling
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final AccountCategoryEntity category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.name,
              style: AppTextStyles.label(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${category.totalAccountTypes} Tipe',
              style: AppTextStyles.body(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                CurrencyUtils.formatCompactIdr(category.totalAmount),
                style: AppTextStyles.body(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
