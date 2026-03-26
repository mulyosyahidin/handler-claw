import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/prayer-logs/applications/today_prayer_controller.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/prayer_log_create_request_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/dto/summary_item_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/prayer_log_api.dart';
import 'package:handlerclaw/shared/themes/app_text_styles.dart';
import 'package:intl/intl.dart';

class PrayerChip extends ConsumerWidget {
  final String prayerName;
  final PrayerDetailDto detail;

  const PrayerChip({super.key, required this.prayerName, required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPerformed = detail.performed > 0;

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Alhamdulillah! Kamu keren sudah solat $label! Berkahi harimu! 🌟',
                style: AppTextStyles.body(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _showPrayerCreationDialog(context, ref, prayerName);
        }
      },
    );
  }

  Future<void> _showPrayerCreationDialog(
    BuildContext context,
    WidgetRef ref,
    String prayer,
  ) async {
    final now = DateTime.now();
    TimeOfDay? selectedTime = TimeOfDay.fromDateTime(now);
    String method = 'SENDIRI';
    String place = 'RUMAH';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Selesaikan Solat $prayer', style: AppTextStyles.title()),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sudah selesai solat $prayer? Pilih jam kamu solat tadi:',
                  style: AppTextStyles.body(),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    selectedTime?.format(context) ?? 'Pilih Jam',
                    style: AppTextStyles.body(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text('Method:', style: AppTextStyles.label()),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text('SENDIRI', style: AppTextStyles.label()),
                      selected: method == 'SENDIRI',
                      onSelected: (val) {
                        if (val) setState(() => method = 'SENDIRI');
                      },
                    ),
                    ChoiceChip(
                      label: Text('JAMAAH', style: AppTextStyles.label()),
                      selected: method == 'JAMAAH',
                      onSelected: (val) {
                        if (val) setState(() => method = 'JAMAAH');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Tempat:', style: AppTextStyles.label()),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text('RUMAH', style: AppTextStyles.label()),
                      selected: place == 'RUMAH',
                      onSelected: (val) {
                        if (val) setState(() => place = 'RUMAH');
                      },
                    ),
                    ChoiceChip(
                      label: Text('MASJID', style: AppTextStyles.label()),
                      selected: place == 'MASJID',
                      onSelected: (val) {
                        if (val) setState(() => place = 'MASJID');
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: AppTextStyles.label()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Simpan', style: AppTextStyles.label()),
          ),
        ],
      ),
    );

    if (result == true && selectedTime != null) {
      try {
        final prayerDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          selectedTime!.hour,
          selectedTime!.minute,
        );

        final offset = prayerDateTime.timeZoneOffset;
        final hours = offset.inHours.abs().toString().padLeft(2, '0');
        final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(
          2,
          '0',
        );
        final sign = offset.isNegative ? '-' : '+';
        final timezone = '$sign$hours:$minutes';

        final performedAt =
            '${DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(prayerDateTime)}$timezone';
        final localDate = DateFormat('yyyy-MM-dd').format(prayerDateTime);

        await ref.read(prayerLogApiProvider).create(
          PrayerLogCreateRequestDto(
            prayer: prayer,
            performedAt: performedAt,
            localDate: localDate,
            method: method,
            place: place,
          ),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Alhamdulillah! Solat $prayer berhasil dicatat.',
                style: AppTextStyles.body(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
          ref.read(todayPrayerControllerProvider.notifier).refresh();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
