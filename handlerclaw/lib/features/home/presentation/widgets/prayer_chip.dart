import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/core/utils/toast_utils.dart';

class PrayerChip extends ConsumerWidget {
  final String prayerName;
  final bool isPerformed;

  const PrayerChip({super.key, required this.prayerName, required this.isPerformed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    IconData icon;
    switch (prayerName) {
      case 'SUBUH':
        icon = Icons.wb_twilight;
        break;
      case 'DZUHUR':
      case 'JUMAT':
        icon = Icons.wb_sunny;
        break;
      case 'ASHAR':
        icon = Icons.wb_sunny_outlined;
        break;
      case 'MAGHRIB':
        icon = Icons.dark_mode_outlined;
        break;
      case 'ISYA':
        icon = Icons.dark_mode;
        break;
      default:
        icon = Icons.mosque_outlined;
    }

    final label = prayerName[0] + prayerName.substring(1).toLowerCase();

    return ActionChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isPerformed ? Colors.white : theme.colorScheme.onSurface,
      ),
      label: Text(
        label,
        style: AppTextStyles.label(
          color: isPerformed ? Colors.white : theme.colorScheme.onSurface,
        ),
      ),
      backgroundColor: isPerformed
          ? Colors.green.withValues(alpha: 0.8)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      side: BorderSide(
        color: isPerformed
            ? Colors.green
            : theme.colorScheme.outline.withValues(alpha: 0.2),
      ),
      onPressed: () {
        if (isPerformed) {
          ToastUtils.showSuccess(
            context,
            title: 'Alhamdulillah!',
            description: 'Kamu keren sudah solat $label! Berkahi harimu! 🌟',
          );
        } else {
          context.push(Routes.addLog, extra: prayerName);
        }
      },
    );
  }
}

class PrayerChipSkeleton extends StatelessWidget {
  const PrayerChipSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 80,
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}
