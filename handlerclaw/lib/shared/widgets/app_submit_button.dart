import 'package:flutter/material.dart';
import 'package:handlerclaw/shared/themes/app_text_styles.dart';

class AppSubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final String? loadingText;

  const AppSubmitButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    loadingText ?? 'Tunggu sebentar...',
                    style: AppTextStyles.body(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: AppTextStyles.body(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
