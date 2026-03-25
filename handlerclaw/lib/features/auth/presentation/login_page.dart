import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/auth/presentation/login_controller.dart';
import 'package:handlerclaw/features/auth/presentation/widgets/email_login_form.dart';
import 'package:handlerclaw/shared/themes/app_theme.dart';
import 'package:handlerclaw/shared/themes/app_text_styles.dart';
import 'package:handlerclaw/shared/utils/toast_utils.dart';



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
    if (email.isEmpty || password.isEmpty) {
      ToastUtils.showWarning(
        context,
        title: 'Perhatian',
        description: 'Email dan password tidak boleh kosong.',
      );
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color accentColor = AppColors.primary;
    final Color textPrimary = Theme.of(context).colorScheme.onSurface;
    final Color textMuted = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final Color glowColor = accentColor.withValues(alpha: 0.06);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [glowColor, Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [glowColor, Colors.transparent],
                  ),
                ),
              ),
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
                      // ── Center section ──
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FadeTransition(
                              opacity: _fadeIcon,
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
                              position: _slideTitle,
                              child: FadeTransition(
                                opacity: _fadeTitle,
                                child: Text(
                                  'HandlerClaw',
                                  style: AppTextStyles.hero(color: textPrimary),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),
                            FadeTransition(
                              opacity: _fadeTitle,
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
                              opacity: _fadeWelcome,
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
                        ),
                      ),

                      // ── Footer section ──
                      FadeTransition(
                        opacity: _fadeButton,
                        child: Column(
                          children: [
                            EmailLoginForm(
                              isLoading: _isLoading,
                              onPressed: _handleLogin,
                            ),
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
