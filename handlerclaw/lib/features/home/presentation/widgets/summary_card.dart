import 'package:flutter/material.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(value, style: AppTextStyles.heading(color: color)),
          Text(title, style: AppTextStyles.body(fontWeight: FontWeight.bold)),
          Text(
            subtitle,
            style: AppTextStyles.label(fontSize: 8, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class SummaryCardSkeleton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const SummaryCardSkeleton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withValues(alpha: 0.5), size: 28),
          const Spacer(),
          Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Text(
            title,
            style: AppTextStyles.body(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.label(
              fontSize: 8,
              letterSpacing: 0.5,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
