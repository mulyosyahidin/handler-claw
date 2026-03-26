import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';

class EmptyStatePage extends StatefulWidget {
  const EmptyStatePage({super.key});

  @override
  State<EmptyStatePage> createState() => _EmptyStatePageState();
}

class _EmptyStatePageState extends State<EmptyStatePage>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _pulseController;
  late final AnimationController _fadeController;

  late final Animation<double> _floatAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              AnimatedBuilder(
                animation: Listenable.merge([_floatAnimation, _pulseAnimation]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: _MoonAndStarsIllustration(
                  primaryColor: colorScheme.primary,
                  secondaryColor: colorScheme.secondary,
                  surfaceColor: isDark
                      ? colorScheme.surfaceContainerHigh
                      : colorScheme.surfaceContainerLowest,
                  outlineColor: colorScheme.outline,
                ),
              ),

              const SizedBox(height: 28),

              // Title
              Text(
                'Belum ada catatan',
                style: AppTextStyles.title(
                  color: colorScheme.onSurface,
                ).copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Mulai catat solatmu hari ini.\nSetiap rakaat yang tercatat adalah jejak perjalananmu. 🌙',
                style: AppTextStyles.body(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the moon + stars + open book illustration
class _MoonAndStarsIllustration extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;
  final Color outlineColor;

  const _MoonAndStarsIllustration({
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.outlineColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: _IllustrationPainter(
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          surfaceColor: surfaceColor,
          outlineColor: outlineColor,
        ),
      ),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;
  final Color outlineColor;

  _IllustrationPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.outlineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // --- Background circle (soft glow) ---
    final bgPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 88, bgPaint);

    // --- Open book (bottom) ---
    _drawBook(canvas, size, cx, cy + 28);

    // --- Moon (center-top) ---
    _drawMoon(canvas, cx, cy - 18, 34);

    // --- Stars ---
    _drawStar(canvas, Offset(cx - 58, cy - 52), 6, primaryColor.withValues(alpha: 0.9));
    _drawStar(canvas, Offset(cx + 62, cy - 44), 5, secondaryColor.withValues(alpha: 0.85));
    _drawStar(canvas, Offset(cx + 40, cy - 72), 4, primaryColor.withValues(alpha: 0.6));
    _drawStar(canvas, Offset(cx - 36, cy - 78), 3.5, secondaryColor.withValues(alpha: 0.5));
    _drawStar(canvas, Offset(cx - 72, cy + 10), 3, primaryColor.withValues(alpha: 0.4));
    _drawStar(canvas, Offset(cx + 74, cy + 8), 3, secondaryColor.withValues(alpha: 0.4));
  }

  void _drawMoon(Canvas canvas, double cx, double cy, double r) {
    // Full moon circle
    final moonPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r, moonPaint);

    // Crescent "bite" — offset circle to carve crescent
    final cutPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + r * 0.55, cy - r * 0.15), r * 0.78, cutPaint);

    // Moon glow ring
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r + 6, glowPaint);
  }

  void _drawBook(Canvas canvas, Size size, double cx, double cy) {
    // Book body
    final bookPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Left page
    final leftPage = Path()
      ..moveTo(cx - 52, cy - 22)
      ..cubicTo(cx - 52, cy - 24, cx - 2, cy - 28, cx - 2, cy - 26)
      ..lineTo(cx - 2, cy + 28)
      ..cubicTo(cx - 2, cy + 26, cx - 52, cy + 22, cx - 52, cy + 20)
      ..close();

    // Right page
    final rightPage = Path()
      ..moveTo(cx + 52, cy - 22)
      ..cubicTo(cx + 52, cy - 24, cx + 2, cy - 28, cx + 2, cy - 26)
      ..lineTo(cx + 2, cy + 28)
      ..cubicTo(cx + 2, cy + 26, cx + 52, cy + 22, cx + 52, cy + 20)
      ..close();

    canvas.drawPath(leftPage, bookPaint);
    canvas.drawPath(leftPage, borderPaint);
    canvas.drawPath(rightPage, bookPaint);
    canvas.drawPath(rightPage, borderPaint);

    // Spine
    final spinePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - 26), Offset(cx, cy + 28), spinePaint);

    // Lines on left page (dotted/dashed feel)
    final linePaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final y = cy - 10 + i * 10.0;
      final xStart = cx - 42 + i * 2;
      final xEnd = cx - 10 + i;
      canvas.drawLine(Offset(xStart, y), Offset(xEnd, y), linePaint);
    }

    final qTextPainter = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: primaryColor.withValues(alpha: 0.45),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    qTextPainter.paint(canvas, Offset(cx + 14, cy - 12));
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = (math.pi / 2) + (2 * math.pi / 5) * i;
      final innerAngle = outerAngle + math.pi / 5;
      final outer = Offset(
        center.dx + size * math.cos(outerAngle),
        center.dy - size * math.sin(outerAngle),
      );
      final inner = Offset(
        center.dx + (size * 0.4) * math.cos(innerAngle),
        center.dy - (size * 0.4) * math.sin(innerAngle),
      );
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IllustrationPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.surfaceColor != surfaceColor;
}
