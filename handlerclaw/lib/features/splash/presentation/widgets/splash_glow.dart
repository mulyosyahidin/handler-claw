import 'package:flutter/material.dart';

class SplashGlow extends StatelessWidget {
  final Animation<double> opacity;
  final Color glowColor;

  const SplashGlow({
    super.key,
    required this.opacity,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.18),
      child: FadeTransition(
        opacity: opacity,
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
    );
  }
}
