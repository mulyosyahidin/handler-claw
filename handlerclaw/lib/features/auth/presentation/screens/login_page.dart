import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/auth/application/login_controller.dart';
import 'package:handlerclaw/features/auth/presentation/widgets/auth_footer.dart';
import 'package:handlerclaw/features/auth/presentation/widgets/auth_header.dart';
import 'package:handlerclaw/features/auth/presentation/widgets/email_login_form.dart';
import 'package:handlerclaw/core/theme/app_theme.dart';
import 'package:handlerclaw/core/utils/toast_utils.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;

  late final AnimationController _controller;
  late final Animation<double> _fadeIcon;
  late final Animation<double> _fadeTitle;
  late final Animation<Offset> _slideTitle;
  late final Animation<double> _fadeWelcome;
  late final Animation<double> _fadeButton;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _fadeIcon = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _fadeTitle = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
    );
    _slideTitle = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
          ),
        );
    _fadeWelcome = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.72, curve: Curves.easeOut),
    );
    _fadeButton = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() => _isLoading = true);
    try {
      final successMessage = await ref
          .read(loginControllerProvider)
          .loginWithEmailAndPassword(email, password);

      if (mounted) {
        ToastUtils.showSuccess(
          context,
          title: 'Berhasil',
          description: successMessage,
        );
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(
          context,
          title: 'Ooops..',
          description: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final googleAuthService = ref.read(googleAuthServiceProvider);
      final idToken = await googleAuthService.signInWithGoogle();

      if (idToken == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final successMessage = await ref
          .read(loginControllerProvider)
          .loginWithGoogle(idToken);

      if (mounted) {
        ToastUtils.showSuccess(
          context,
          title: 'Berhasil',
          description: successMessage,
        );
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(
          context,
          title: 'Ooops..',
          description: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor = theme.scaffoldBackgroundColor;
    final Color accentColor = AppColors.primary;
    final Color textPrimary = theme.colorScheme.onSurface;
    final Color textMuted = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final Color glowColor = accentColor.withValues(alpha: 0.06);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Glows
            Positioned(
              top: -60,
              right: -60,
              child: _GlowCircle(color: glowColor, size: 220),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: _GlowCircle(color: glowColor, size: 160),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Header section
                      Expanded(
                        child: AuthHeader(
                          fadeIcon: _fadeIcon,
                          slideTitle: _slideTitle,
                          fadeTitle: _fadeTitle,
                          fadeWelcome: _fadeWelcome,
                          accentColor: accentColor,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                        ),
                      ),

                      // Form & Footer section
                      FadeTransition(
                        opacity: _fadeButton,
                        child: Column(
                          children: [
                            EmailLoginForm(
                              isLoading: _isLoading,
                              onPressed: _handleLogin,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: textMuted.withValues(alpha: 0.2),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'Atau masuk dengan',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: textMuted,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: textMuted.withValues(alpha: 0.2),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _isLoading
                                    ? null
                                    : _handleGoogleLogin,
                                icon: Image.network(
                                  'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.g_mobiledata, size: 24),
                                ),
                                label: const Text('Google'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(
                                    color: textMuted.withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                            ),
                            AuthFooter(textMuted: textMuted),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
