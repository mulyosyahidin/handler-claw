import 'package:flutter/material.dart';
import 'package:handlerclaw/shared/theme/app_theme.dart';

class HandlerClawDrawer extends StatefulWidget {
  final String name;
  final String email;
  final VoidCallback onLogout;

  const HandlerClawDrawer({
    super.key,
    required this.name,
    required this.email,
    required this.onLogout,
  });

  @override
  State<HandlerClawDrawer> createState() => _HandlerClawDrawerState();
}

class _HandlerClawDrawerState extends State<HandlerClawDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

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

  @override
  Widget build(BuildContext context) {
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

    final initials = widget.name.isNotEmpty
        ? widget.name.trim().split(' ').map((w) => w[0]).take(2).join()
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
                // Avatar with pulsing ring
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
                          child: Center(
                            child: Text(
                              initials.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                color: primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1,
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
                  widget.name,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.4,
                  ),
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
                    widget.email.isNotEmpty ? widget.email : 'no email',
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
                    isActive: true,
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerNavItem(
                    icon: Icons.notifications_rounded,
                    label: 'Reminders',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerNavItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('ACCOUNT', textMuted),
                  const SizedBox(height: 8),
                  _DrawerNavItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),

          // ── Logout ──
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.error.withValues(alpha: 0.25),
                width: 1,
              ),
              color: colorScheme.error.withValues(alpha: 0.05),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                splashColor: colorScheme.error.withValues(alpha: 0.12),
                highlightColor: colorScheme.error.withValues(alpha: 0.06),
                onTap: () {
                  Navigator.pop(context);
                  widget.onLogout();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
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
        style: TextStyle(
          fontSize: 10,
          color: color.withValues(alpha: 0.5),
          letterSpacing: 2.0,
          fontWeight: FontWeight.w600,
        ),
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
