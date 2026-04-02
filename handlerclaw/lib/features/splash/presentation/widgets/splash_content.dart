import 'package:flutter/material.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';

class SplashContent extends StatelessWidget {
  final Animation<double> fadeIcon;
  final Animation<double> fadeTitle;
  final Animation<Offset> slideTitle;
  final Animation<double> fadeTagline;
  final Color accentColor;
  final Color textPrimary;

  const SplashContent({
    super.key,
    required this.fadeIcon,
    required this.fadeTitle,
    required this.slideTitle,
    required this.fadeTagline,
    required this.accentColor,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          FadeTransition(
            opacity: fadeIcon,
            child: Image.asset(
              'assets/icons/openclaw.png',
              width: 88,
              height: 88,
              color: accentColor,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),

          const SizedBox(height: 28),

          // App name
          SlideTransition(
            position: slideTitle,
            child: FadeTransition(
              opacity: fadeTitle,
              child: Text(
                'HandlerClaw',
                style: AppTextStyles.hero(color: textPrimary),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Divider line accent
          FadeTransition(
            opacity: fadeTagline,
            child: Container(
              width: 36,
              height: 1.5,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
