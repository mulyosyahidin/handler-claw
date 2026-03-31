import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/features/api-keys/application/api_keys_controller.dart';
import 'package:handlerclaw/features/api-keys/presentation/widgets/api_key_card.dart';
import 'package:handlerclaw/features/api-keys/presentation/widgets/create_api_key_dialog.dart';

class ApiKeyListScreen extends ConsumerWidget {
  const ApiKeyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(apiKeyListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text('API Keys', style: AppTextStyles.title())),
      body: state.when(
        data: (data) => _buildList(context, ref, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    ApiKeyListState state,
  ) {
    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.vpn_key_outlined,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada API Key',
              style: AppTextStyles.body(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(apiKeyListControllerProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final key = state.items[index];
          return ApiKeyCard(apiKey: key);
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreateApiKeyDialog(),
    );
  }
}
