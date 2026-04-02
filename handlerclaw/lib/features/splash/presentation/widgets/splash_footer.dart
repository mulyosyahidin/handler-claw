import 'package:flutter/material.dart';

class SplashFooter extends StatelessWidget {
  final Animation<double> opacity;
  final Color loaderColor;

  const SplashFooter({
    super.key,
    required this.opacity,
    required this.loaderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 52,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: opacity,
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
    );
  }
}
