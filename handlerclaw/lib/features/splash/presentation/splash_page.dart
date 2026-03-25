import 'package:flutter/material.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          Align(
            alignment: const Alignment(0, -0.18),
            child: FadeTransition(
              opacity: _fadeIcon,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [glowColor, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                FadeTransition(
                  opacity: _fadeIcon,
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
                  position: _slideTitle,
                  child: FadeTransition(
                    opacity: _fadeTitle,
                    child: Text(
                      'HandlerClaw',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                        color: textPrimary,
                        letterSpacing: 1.2,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Divider line accent
                FadeTransition(
                  opacity: _fadeTagline,
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
          ),

          // Footer loader
          Positioned(
            bottom: 52,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeLoader,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.8,
                    valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
