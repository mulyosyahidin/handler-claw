import 'package:flutter/material.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  final Animation<double> fadeIcon;
  final Animation<Offset> slideTitle;
  final Animation<double> fadeTitle;
  final Animation<double> fadeWelcome;
  final Color accentColor;
  final Color textPrimary;
  final Color textMuted;

  const AuthHeader({
    super.key,
    required this.fadeIcon,
    required this.slideTitle,
    required this.fadeTitle,
    required this.fadeWelcome,
    required this.accentColor,
    required this.textPrimary,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeTransition(
          opacity: fadeIcon,
          child: Image.asset(
            'assets/icons/openclaw.png',
            width: 72,
            height: 72,
            color: accentColor,
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: 20),
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
        const SizedBox(height: 8),
        FadeTransition(
          opacity: fadeTitle,
          child: Container(
            width: 32,
            height: 1.5,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 28),
        FadeTransition(
          opacity: fadeWelcome,
          child: Column(
            children: [
              Text(
                'Selamat Datang',
                style: AppTextStyles.heading(color: textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Masuk untuk mulai mengelola\npengingat harianmu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: textMuted,
                  height: 1.6,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
