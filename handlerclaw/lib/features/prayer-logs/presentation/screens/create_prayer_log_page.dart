import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/prayer-logs/application/prayer_log_list_controller.dart';
import 'package:handlerclaw/features/prayer-logs/application/prayer_log_summary_controller.dart';
import 'package:handlerclaw/features/prayer-logs/application/today_prayer_controller.dart';
import 'package:handlerclaw/features/home/application/home_controller.dart';
import 'package:handlerclaw/features/prayer-logs/data/repositories/prayer_log_repository_impl.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/utils/toast_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/shared/widgets/app_submit_button.dart';
import 'package:intl/intl.dart';

class CreatePrayerLogPage extends ConsumerStatefulWidget {
  const CreatePrayerLogPage({super.key});

  @override
  ConsumerState<CreatePrayerLogPage> createState() =>
      _CreatePrayerLogPageState();
}

class _CreatePrayerLogPageState extends ConsumerState<CreatePrayerLogPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? selectedPrayer;
  String method = 'SENDIRI';
  String place = 'RUMAH';
  bool isLoading = false;

  final prayers = [
    'SUBUH',
    'DZUHUR',
    'ASHAR',
    'MAGHRIB',
    'ISYA',
    'JUMAT',
    'DHUHA',
    'TAHAJUD',
    'WITIR',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catat Solat Manual', style: AppTextStyles.title()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jenis Solat',
              style: AppTextStyles.body(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedPrayer,
              hint: const Text('Pilih Solat'),
              items: prayers
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) => setState(() => selectedPrayer = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            Text(
              'Tanggal & Waktu',
              style: AppTextStyles.body(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        DateFormat('dd MMM yyyy').format(selectedDate),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Waktu',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(selectedTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Metode',
              style: AppTextStyles.body(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                RadioGroup<String>(
                  groupValue: method,
                  onChanged: (val) => setState(() => method = val!),
                  child: Row(
                    children: [
                      Radio<String>(value: 'SENDIRI'),
                      const Text('Sendiri'),
                      const SizedBox(width: 16),
                      Radio<String>(value: 'JAMAAH'),
                      const Text('Jamaah'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Tempat',
              style: AppTextStyles.body(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            RadioGroup<String>(
              groupValue: place,
              onChanged: (val) => setState(() => place = val!),
              child: Row(
                children: [
                  Radio<String>(value: 'RUMAH'),
                  const Text('Rumah'),
                  const SizedBox(width: 16),
                  Radio<String>(value: 'MASJID'),
                  const Text('Masjid'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            AppSubmitButton(
              onPressed: _save,
              text: 'SIMPAN',
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  void _save() async {
    if (selectedPrayer == null) {
      ToastUtils.showWarning(
        context,
        title: 'Pilih Solat',
        description: 'Silakan pilih jenis solat terlebih dahulu.',
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final performedAt = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      await ref
          .read(prayerLogRepositoryProvider)
          .create(
            prayer: selectedPrayer!,
            performedAt: performedAt,
            method: method,
            place: place,
          );

      if (mounted) {
        ToastUtils.showSuccess(
          context,
          title: 'Berhasil',
          description: 'Solat berhasil dicatat.',
        );

        // Refresh controllers
        ref.read(prayerLogListControllerProvider.notifier).refresh();
        ref.read(prayerLogSummaryControllerProvider.notifier).refresh();
        ref.read(homeControllerProvider.notifier).refresh();
        ref.read(todayPrayerControllerProvider.notifier).refresh();

        context.pop();
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'CreatePrayerLogPage._save',
      );
      if (mounted) {
        ToastUtils.showError(
          context,
          title: 'Gagal',
          description: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
