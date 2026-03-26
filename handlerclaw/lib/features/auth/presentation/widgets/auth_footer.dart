import 'package:flutter/material.dart';

class AuthFooter extends StatelessWidget {
  final Color textMuted;

  const AuthFooter({
    super.key,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          'Dengan masuk, kamu menyetujui\nKetentuan Layanan dan Kebijakan Privasi kami.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: textMuted.withValues(alpha: 0.6),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
