import 'package:flutter/material.dart';
import 'package:handlerclaw/features/splash/presentation/widgets/splash_content.dart';
import 'package:handlerclaw/features/splash/presentation/widgets/splash_footer.dart';
import 'package:handlerclaw/features/splash/presentation/widgets/splash_glow.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIcon;
  late final Animation<double> _fadeTitle;
  late final Animation<Offset> _slideTitle;
  late final Animation<double> _fadeTagline;
  late final Animation<double> _fadeLoader;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    _fadeIcon = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _fadeTitle = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
    );

    _slideTitle = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
          ),
        );

    _fadeTagline = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.78, curve: Curves.easeOut),
    );

    _fadeLoader = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isDark
        ? const Color(0xFF0D0D0F)
        : const Color(0xFFFAF8F5);
    final Color accentColor = isDark
        ? const Color(0xFFEF5350)
        : const Color(0xFFD32F2F);
    final Color textPrimary = isDark
        ? const Color(0xFFF5F0E8)
        : const Color(0xFF1A1814);
    final Color glowColor = isDark
        ? const Color(0xFFEF5350).withValues(alpha: 0.07)
        : const Color(0xFFD32F2F).withValues(alpha: 0.06);
    final Color loaderColor = isDark
        ? const Color(0xFF6B6660)
        : const Color(0xFFB0A898);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Subtle radial glow behind icon
          SplashGlow(
            opacity: _fadeIcon,
            glowColor: glowColor,
          ),

          // Center content (Icon, Title, Divider)
          SplashContent(
            fadeIcon: _fadeIcon,
            fadeTitle: _fadeTitle,
            slideTitle: _slideTitle,
            fadeTagline: _fadeTagline,
            accentColor: accentColor,
            textPrimary: textPrimary,
          ),

          // Footer loader
          SplashFooter(
            opacity: _fadeLoader,
            loaderColor: loaderColor,
          ),
        ],
      ),
    );
  }
}
