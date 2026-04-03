import 'package:flutter/material.dart';
import 'package:handlerclaw/features/whatsapp-hooks/domain/entities/whatsapp_message_entity.dart';
import 'package:handlerclaw/features/whatsapp-hooks/presentation/widgets/whatsapp_message_body_widget.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class WhatsappMessageItemWidget extends StatelessWidget {
  final WhatsappMessageEntity message;
  final VoidCallback? onTap;

  const WhatsappMessageItemWidget({
    super.key,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: message.isFromMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isFromMe
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isFromMe ? 16 : 4),
                  bottomRight: Radius.circular(message.isFromMe ? 4 : 16),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!message.isFromMe) ...[
                    Text(
                      message.fromName ?? message.from,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Body text
                  WhatsappMessageBodyWidget(
                    message: message,
                    style: AppTextStyles.body(
                      fontSize: 15,
                      color: message.isFromMe
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Footer
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.isForwarded) ...[
                        Icon(
                          Icons.reply_rounded,
                          size: 12,
                          color:
                              (message.isFromMe
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurfaceVariant)
                                  .withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Diteruskan',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color:
                                (message.isFromMe
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurfaceVariant)
                                    .withValues(alpha: 0.6),
                          ),
                        ),
                        const Spacer(),
                      ],
                      Text(
                        DateFormat(
                          'HH:mm',
                        ).format(message.waTimestamp.toLocal()),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color:
                              (message.isFromMe
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurfaceVariant)
                                  .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
