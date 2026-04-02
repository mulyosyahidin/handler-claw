import 'package:flutter/material.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';

class AccountSectionHeader extends StatelessWidget {
  final String title;
  final String total;

  const AccountSectionHeader({
    super.key,
    required this.title,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title(fontSize: 16)),
          const SizedBox(height: 4),
          Text('Total: $total', style: AppTextStyles.label(fontSize: 12)),
        ],
      ),
    );
  }
}
