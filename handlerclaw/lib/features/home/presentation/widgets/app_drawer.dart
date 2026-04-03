import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/core/providers/auth_session_provider.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/theme/app_theme.dart';

class AppDrawer extends ConsumerStatefulWidget {
  final Future<void> Function() onLogout;

  const AppDrawer({super.key, required this.onLogout});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _ringScale = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _ringOpacity = Tween<double>(
      begin: 0.3,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _showLogoutConfirmation() async {
    final colorScheme = Theme.of(context).colorScheme;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Konfirmasi Logout',
          style: AppTextStyles.title(color: colorScheme.onSurface),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun?',
          style: AppTextStyles.body(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      setState(() => _isLoggingOut = true);
      try {
        await widget.onLogout();
      } catch (e, stackTrace) {
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'AppDrawer._showLogoutConfirmation',
        );
        if (mounted) {
          setState(() => _isLoggingOut = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    final user = session.value?.user;
    final name = user?.name ?? 'User';
    final email = user?.email ?? '';

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bg = colorScheme.surface;
    final Color primary = colorScheme.primary;
    final Color textPrimary = colorScheme.onSurface;
    final Color textMuted = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final Color cardBg = isDark
        ? AppColors.surfaceDark
        : AppColors.backgroundLight;
    final Color divider = isDark ? AppColors.borderDark : AppColors.borderLight;

    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join()
        : '?';

    return Drawer(
      backgroundColor: bg,
      width: 290,
      child: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(bottom: BorderSide(color: divider, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: _ringScale.value,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primary.withValues(
                                  alpha: _ringOpacity.value,
                                ),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary.withValues(alpha: 0.08),
                            border: Border.all(
                              color: primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: ClipOval(
                            child:
                                user?.avatarUrl != null &&
                                    user!.avatarUrl!.isNotEmpty
                                ? Image.network(
                                    user.avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          initials.toUpperCase(),
                                          style: AppTextStyles.title(
                                            color: primary,
                                          ),
                                        ),
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          
                                          return Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                  )
                                : Center(
                                    child: Text(
                                      initials.toUpperCase(),
                                      style: AppTextStyles.title(
                                        color: primary,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Name
                Text(
                  name,
                  style: AppTextStyles.title(color: textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Email badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    email.isNotEmpty ? email : 'no email',
                    style: TextStyle(
                      fontSize: 11,
                      color: primary,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ── Nav items ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('MENU', textMuted),
                  const SizedBox(height: 8),
                  _DrawerNavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isActive:
                        GoRouterState.of(context).matchedLocation ==
                        Routes.home,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(Routes.home);
                    },
                  ),
                  _DrawerNavItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Keuangan',
                    isActive:
                        GoRouterState.of(context).matchedLocation ==
                        Routes.finance,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(Routes.finance);
                    },
                  ),
                  _DrawerNavItem(
                    icon: Icons.notifications_rounded,
                    label: 'Notifikasi',
                    isActive:
                        GoRouterState.of(context).matchedLocation ==
                        Routes.notificationList,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(Routes.notificationList);
                    },
                  ),
                  _DrawerNavItem(
                    icon: Icons.chat_rounded,
                    label: 'WhatsApp Messages',
                    isActive:
                        GoRouterState.of(context).matchedLocation ==
                        Routes.whatsappMessages,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(Routes.whatsappMessages);
                    },
                  ),
                  _DrawerNavItem(
                    icon: Icons.history_rounded,
                    label: 'Jurnal Solat',
                    isActive:
                        GoRouterState.of(context).matchedLocation ==
                        Routes.prayerLogs,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(Routes.prayerLogs);
                    },
                  ),
                  _DrawerNavItem(
                    icon: Icons.devices_other_rounded,
                    label: 'Devices',
                    isActive:
                        GoRouterState.of(context).matchedLocation ==
                        Routes.devices,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(Routes.devices);
                    },
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('ACCOUNT', textMuted),
                  const SizedBox(height: 8),
                  _DrawerNavItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                    isActive:
                        GoRouterState.of(context).matchedLocation ==
                        Routes.profile,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(Routes.profile);
                    },
                  ),
                  _DrawerNavItem(
                    icon: Icons.vpn_key_outlined,
                    label: 'API Keys',
                    isActive:
                        GoRouterState.of(context).matchedLocation ==
                        Routes.apiKeys,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(Routes.apiKeys);
                    },
                  ),
                ],
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isLoggingOut
                    ? colorScheme.outline.withValues(alpha: 0.1)
                    : colorScheme.error.withValues(alpha: 0.25),
                width: 1,
              ),
              color: _isLoggingOut
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : colorScheme.error.withValues(alpha: 0.05),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                splashColor: colorScheme.error.withValues(alpha: 0.12),
                highlightColor: colorScheme.error.withValues(alpha: 0.06),
                onTap: _isLoggingOut ? null : _showLogoutConfirmation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      if (_isLoggingOut)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.outline,
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.logout_rounded,
                          color: colorScheme.error,
                          size: 20,
                        ),
                      const SizedBox(width: 12),
                      Text(
                        _isLoggingOut ? 'Logging out...' : 'Logout',
                        style: TextStyle(
                          color: _isLoggingOut
                              ? colorScheme.outline
                              : colorScheme.error,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      if (!_isLoggingOut)
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: colorScheme.error.withValues(alpha: 0.4),
                          size: 12,
                        ),
                    ],
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

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _SectionLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        text,
        style: AppTextStyles.label(color: color.withValues(alpha: 0.5)),
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primary = colorScheme.primary;
    final Color textPrimary = colorScheme.onSurface;
    final Color textMuted = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isActive ? primary.withValues(alpha: 0.08) : Colors.transparent,
        border: isActive
            ? Border.all(color: primary.withValues(alpha: 0.2), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          splashColor: primary.withValues(alpha: 0.08),
          highlightColor: primary.withValues(alpha: 0.04),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: isActive ? primary : textMuted),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive ? textPrimary : textMuted,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
