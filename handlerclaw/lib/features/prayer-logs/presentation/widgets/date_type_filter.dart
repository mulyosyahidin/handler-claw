import 'package:flutter/material.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

const Map<String, String> dateTypeFilters = {
    'all': 'Semua',
    'today': 'Hari Ini',
    'this_week': 'Minggu Ini',
    'this_month': 'Bulan Ini',
    'this_year': 'Tahun Ini',
    '7_days': '7 Hari Terakhir',
    '30_days': '30 Hari Terakhir',
    '1_year': '1 Tahun Terakhir',
  };

class DateTypeFilter extends StatelessWidget {
  final String selectedType;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(String) onTypeChanged;

  const DateTypeFilter({super.key, 
    required this.selectedType,
    required this.onTypeChanged,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedType,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down_rounded),
                borderRadius: BorderRadius.circular(12),
                style: AppTextStyles.body(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                items: dateTypeFilters.entries.map((e) {
                  return DropdownMenuItem<String>(
                    value: e.key,
                    child: Text(e.value),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) onTypeChanged(val);
                },
              ),
            ),
          ),
        ),
        if (selectedType == 'custom' && startDate != null && endDate != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormat('d MMM yyyy', 'id_ID').format(startDate!)} - ${DateFormat('d MMM yyyy', 'id_ID').format(endDate!)}',
                    style: AppTextStyles.label(
                      color: colorScheme.onSecondaryContainer,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => onTypeChanged('custom'),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
