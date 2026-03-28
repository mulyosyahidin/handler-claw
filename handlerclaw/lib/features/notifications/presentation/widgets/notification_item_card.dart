import 'package:flutter/material.dart';
import 'package:handlerclaw/features/notifications/domain/entities/notification_entity.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class NotificationItemCard extends StatelessWidget {
  final NotificationEntity item;
  final VoidCallback? onTap;

  const NotificationItemCard({super.key, required this.item, this.onTap});

  Color _statusColor(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;
    return switch (status.toUpperCase()) {
      'SENT' => Colors.green.shade700,
      'PENDING' => const Color(0xFFB8860B),
      'FAILED' => cs.error,
      _ => cs.onSurfaceVariant,
    };
  }

  Color _statusBg(BuildContext context, String status) {
    return switch (status.toUpperCase()) {
      'SENT' => Colors.green.withValues(alpha: 0.15),
      'PENDING' => const Color(0xFFB8860B).withValues(alpha: 0.15),
      'FAILED' => Theme.of(context).colorScheme.errorContainer,
      _ => Theme.of(context).colorScheme.surfaceContainerHighest,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: AppTextStyles.body(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.body.length > 40
                    ? '${item.body.substring(0, 40)}...'
                    : item.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBg(context, item.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _statusColor(context, item.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat(
                      'dd MMM yyyy, HH:mm',
                    ).format(item.createdAt.toLocal()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
