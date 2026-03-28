import 'package:flutter/material.dart';
import 'package:handlerclaw/features/whatsapp-logs/domain/entities/whatsapp_log_entity.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final WhatsappLogEntity log;

  const ChatBubble({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender Info
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: log.isGroup
                            ? colorScheme.primaryContainer
                            : colorScheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        log.isGroup
                            ? Icons.group_rounded
                            : Icons.person_rounded,
                        size: 12,
                        color: log.isGroup
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${log.senderName ?? 'N/A'} - ${log.isGroup ? log.memberPhone : log.sender}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Message
                Text(
                  log.messageText ??
                      (log.messageType != 'text'
                          ? '[${log.messageType.toUpperCase()}]'
                          : '(Pesan Kosong)'),
                  style: AppTextStyles.body(
                    fontSize: 15,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                // Time and Date (Bottom)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '${log.isGroup && log.groupId != null ? '${log.groupId} • ' : ''}${DateFormat('dd/MM/yy').format(log.receivedAt.toLocal())} ${DateFormat('HH:mm').format(log.receivedAt.toLocal())}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
