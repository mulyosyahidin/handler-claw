import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/env.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/features/debug/presentation/providers/debug_providers.dart';

class DebugPage extends ConsumerWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageData = ref.watch(debugStorageDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Menu', style: AppTextStyles.title()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(debugStorageDataProvider),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          _buildSectionHeader(context, 'Environment Variables'),
          SliverToBoxAdapter(
            child: _buildDebugItem(
              context,
              'API Base URL',
              Env.apiBaseUrl,
              isMonospaced: true,
            ),
          ),
          _buildSectionHeader(context, 'Secure Storage'),
          storageData.when(
            data: (data) {
              if (data.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No data in secure storage'),
                  ),
                );
              }
              final keys = data.keys.toList()..sort();
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final key = keys[index];
                    final value = data[key] ?? '';
                    return _buildDebugItem(context, key, value, isMonospaced: true);
                  },
                  childCount: keys.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: Text(
          title.toUpperCase(),
          style: AppTextStyles.body(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildDebugItem(
    BuildContext context,
    String label,
    String value, {
    bool isMonospaced = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copied $label to clipboard')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.body(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: isMonospaced
                  ? AppTextStyles.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ).copyWith(fontFamily: 'monospace')
                  : AppTextStyles.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
