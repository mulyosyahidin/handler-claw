import 'package:flutter/material.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';

class PrayerSelector extends StatelessWidget {
  final String? initialPrayer;
  final String? selectedPrayer;
  final List<String> prayers;
  final ValueChanged<String?> onChanged;

  const PrayerSelector({
    super.key,
    this.initialPrayer,
    this.selectedPrayer,
    required this.prayers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (initialPrayer != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Sudah selesai solat $initialPrayer? Ayo catat jurnalnya agar tidak lupa!',
          style: AppTextStyles.body(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pilih Sholat:', style: AppTextStyles.label()),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: selectedPrayer,
          items: prayers
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }
}
