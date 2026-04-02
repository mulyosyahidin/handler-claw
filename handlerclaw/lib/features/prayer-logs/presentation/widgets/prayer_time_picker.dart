import 'package:flutter/material.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';

class PrayerTimePicker extends StatelessWidget {
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const PrayerTimePicker({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Waktu Pelaksanaan:', style: AppTextStyles.label()),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: selectedTime,
            );
            if (time != null) {
              onTimeSelected(time);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 12),
                Text(
                  selectedTime.format(context),
                  style: AppTextStyles.body(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Icon(Icons.edit, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
