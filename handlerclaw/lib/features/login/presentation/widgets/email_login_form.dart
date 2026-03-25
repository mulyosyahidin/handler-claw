import 'package:flutter/material.dart';
import 'package:handlerclaw/shared/theme/app_theme.dart';

class EmailLoginForm extends StatefulWidget {
  final bool isLoading;
  final Future<void> Function(String email, String password) onPressed;

  const EmailLoginForm({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<EmailLoginForm> createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends State<EmailLoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color accentColor = AppColors.primary;
    final Color textPrimary = theme.colorScheme.onSurface;
    final Color textMuted = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email field
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: textPrimary, fontSize: 14),
          decoration: const InputDecoration().copyWith(
            hintText: 'Email',
            hintStyle: TextStyle(color: textMuted, fontSize: 14),
            prefixIcon: Icon(
              Icons.mail_outline_rounded,
              color: textMuted,
              size: 18,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Password field
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: textPrimary, fontSize: 14),
          decoration: const InputDecoration().copyWith(
            hintText: 'Password',
            hintStyle: TextStyle(color: textMuted, fontSize: 14),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: textMuted,
              size: 18,
            ),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: textMuted,
                size: 18,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Login button
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: widget.isLoading
                ? null
                : () => widget.onPressed(
                    _emailController.text.trim(),
                    _passwordController.text,
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: accentColor.withValues(alpha: 0.4),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Masuk',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.6,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
