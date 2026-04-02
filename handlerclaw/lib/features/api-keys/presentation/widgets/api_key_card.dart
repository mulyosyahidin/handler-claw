import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/features/home/application/home_controller.dart';
import 'package:handlerclaw/features/api-keys/application/api_keys_controller.dart';
import 'package:handlerclaw/features/api-keys/domain/entities/api_key_entity.dart';
import 'package:handlerclaw/app/navigation_keys.dart';
import 'package:handlerclaw/features/api-keys/presentation/widgets/api_key_success_dialog.dart';
import 'package:intl/intl.dart';

class ApiKeyCard extends ConsumerWidget {
  final ApiKeyEntity apiKey;

  const ApiKeyCard({super.key, required this.apiKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRevoked = apiKey.isRevoked;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    apiKey.name,
                    style: AppTextStyles.title(fontSize: 16),
                  ),
                ),
                _StatusBadge(status: apiKey.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Key Preview: ${apiKey.keyPreview}',
              style: AppTextStyles.label(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Dibuat pada: ${DateFormat('dd MMM yyyy HH:mm').format(apiKey.createdAt)}',
              style: AppTextStyles.label(color: Colors.grey),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isRevoked) ...[
                  _ActionIconButton(
                    icon: Icons.refresh,
                    label: 'Rotate',
                    onPressed: () => _confirmAction(
                      context,
                      ref,
                      'Rotate',
                      () => ref
                          .read(apiKeyListControllerProvider.notifier)
                          .rotateKey(apiKey.id),
                    ),
                  ),
                  _ActionIconButton(
                    icon: Icons.block,
                    label: 'Revoke',
                    color: colorScheme.error,
                    onPressed: () => _confirmAction(
                      context,
                      ref,
                      'Revoke',
                      () => ref
                          .read(apiKeyListControllerProvider.notifier)
                          .revokeKey(apiKey.id),
                    ),
                  ),
                ],
                _ActionIconButton(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  color: colorScheme.error,
                  onPressed: () => _confirmAction(
                    context,
                    ref,
                    'Delete',
                    () => ref
                        .read(apiKeyListControllerProvider.notifier)
                        .deleteKey(apiKey.id),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Future<dynamic> Function() onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Konfirmasi $action'),
        content: Text(
          'Apakah Anda yakin ingin melakukan $action pada API Key "${apiKey.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final result = await onConfirm();
                if (action == 'Rotate' && result is ApiKeyEntity) {
                  final navContext = rootNavigatorKey.currentContext;
                  if (navContext != null && navContext.mounted) {
                    showDialog(
                      context: navContext,
                      barrierDismissible: false,
                      builder: (context) => ApiKeySuccessDialog(
                        apiKey: result,
                        title: 'API Key Berhasil Di-rotate',
                      ),
                    );
                  }
                }
                ref.read(homeControllerProvider.notifier).refresh();
              } catch (e, stackTrace) {
                FirebaseCrashlytics.instance.recordError(
                  e,
                  stackTrace,
                  reason: 'ApiKeyCard._confirmAction ($action)',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal melakukan $action: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'Rotate'
                  ? null
                  : Theme.of(context).colorScheme.error,
              foregroundColor: action == 'Rotate'
                  ? null
                  : Theme.of(context).colorScheme.onError,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _ActionIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(foregroundColor: color),
      onPressed: onPressed,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ApiKeyStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == ApiKeyStatus.active ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: AppTextStyles.label(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
