import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/prayer-logs/application/today_prayer_controller.dart';
import 'package:handlerclaw/features/prayer-logs/data/repositories/prayer_log_repository_impl.dart';
import 'package:handlerclaw/features/prayer-logs/presentation/widgets/prayer_choice_selector.dart';
import 'package:handlerclaw/features/prayer-logs/presentation/widgets/prayer_selector.dart';
import 'package:handlerclaw/features/prayer-logs/presentation/widgets/prayer_time_picker.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/utils/toast_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/shared/widgets/app_submit_button.dart';

class AddPrayerLogPage extends ConsumerStatefulWidget {
  final String? initialPrayer;

  const AddPrayerLogPage({super.key, this.initialPrayer});

  @override
  ConsumerState<AddPrayerLogPage> createState() => _AddPrayerLogPageState();
}

class _AddPrayerLogPageState extends ConsumerState<AddPrayerLogPage> {
  late TimeOfDay selectedTime;
  late String method;
  late String place;
  String? selectedPrayer;
  bool isLoading = false;

  final prayers = ['SUBUH', 'DZUHUR', 'ASHAR', 'MAGHRIB', 'ISYA', 'JUMAT'];

  @override
  void initState() {
    super.initState();
    selectedTime = TimeOfDay.now();
    method = 'SENDIRI';
    place = 'RUMAH';
    selectedPrayer = widget.initialPrayer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: !context.canPop()
            ? IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => context.go(Routes.home),
              )
            : null,
        title: Text(
          selectedPrayer != null
              ? 'Selesaikan Solat $selectedPrayer'
              : 'Catat Solat',
          style: AppTextStyles.title(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrayerSelector(
              initialPrayer: widget.initialPrayer,
              selectedPrayer: selectedPrayer,
              prayers: prayers,
              onChanged: (val) => setState(() => selectedPrayer = val),
            ),
            const SizedBox(height: 24),
            PrayerTimePicker(
              selectedTime: selectedTime,
              onTimeSelected: (time) => setState(() => selectedTime = time),
            ),
            const SizedBox(height: 24),
            PrayerChoiceSelector(
              label: 'Metode:',
              options: const ['SENDIRI', 'JAMAAH'],
              selectedOption: method,
              onSelected: (val) => setState(() => method = val),
            ),
            const SizedBox(height: 24),
            PrayerChoiceSelector(
              label: 'Tempat:',
              options: const ['RUMAH', 'MASJID'],
              selectedOption: place,
              onSelected: (val) => setState(() => place = val),
            ),
            const SizedBox(height: 48),
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

  void _save() async {
    if (selectedPrayer == null) {
      ToastUtils.showWarning(
        context,
        title: 'Oops!',
        description: 'Pilih sholat dulu ya!',
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final now = DateTime.now();
      final prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      await ref
          .read(prayerLogRepositoryProvider)
          .create(
            prayer: selectedPrayer!,
            performedAt: prayerDateTime,
            method: method,
            place: place,
          );

      if (mounted) {
        ToastUtils.showSuccess(
          context,
          title: 'Alhamdulillah!',
          description: 'Solat $selectedPrayer berhasil dicatat.',
        );
        ref.read(todayPrayerControllerProvider.notifier).refresh();

        if (context.canPop()) {
          context.pop();
        } else {
          context.go(Routes.home);
        }
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AddPrayerLogPage._save',
      );
      if (mounted) {
        ToastUtils.showError(
          context,
          title: 'Gagal Menyimpan',
          description: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
