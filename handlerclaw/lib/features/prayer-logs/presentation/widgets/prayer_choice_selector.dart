import 'package:flutter/material.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';

class PrayerChoiceSelector extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onSelected;

  const PrayerChoiceSelector({
    super.key,
    required this.label,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label()),
        const SizedBox(height: 12),
        Row(
          children: options.map((option) {
            final isSelected = selectedOption == option;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: option != options.last ? 12.0 : 0.0,
                ),
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      option,
                      style: AppTextStyles.label(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) onSelected(option);
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
