import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// "Living Larder" backdrop: soft botanical **aurora glows** drifting on a
/// sine path over a warm wash, finished with a matte **film-grain** texture —
/// replacing the generic SaaS dot-grid. Native Flutter, 60fps, theme-aware,
/// and reduced-motion safe.
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final double intensity; // 0..1 overall strength
  final double grain; // 0..1 grain strength

  const AnimatedBackground({
    super.key,
    required this.child,
    this.intensity = 1,
    this.grain = 1,
    @Deprecated('kept for call-site compatibility; no longer used')
    double dotSpacing = 30,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 22),
  );

  @override
  void initState() {
    super.initState();
    _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [brand.heroStart, brand.heroEnd],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CustomPaint(
                painter: _AuroraPainter(
                  t: reduceMotion ? 0.0 : _c.value,
                  intensity: widget.intensity,
                  grain: widget.grain,
                  isDark: isDark,
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double t;
  final double intensity;
  final double grain;
  final bool isDark;

  _AuroraPainter({
    required this.t,
    required this.intensity,
    required this.grain,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final a = t * 2 * math.pi;
    final s = size.shortestSide;
    final boost = isDark ? 1.6 : 1.0;

    // Four botanical glows drifting on independent sine paths.
    _glow(canvas, Offset(size.width * (0.18 + 0.08 * math.cos(a)),
        size.height * (0.16 + 0.06 * math.sin(a))), s * 0.85,
        AppColors.primaryGreen.withValues(alpha: 0.10 * intensity * boost));
    _glow(canvas, Offset(size.width * (0.88 + 0.06 * math.sin(a * 0.7)),
        size.height * (0.22 + 0.05 * math.cos(a * 0.9))), s * 0.6,
        AppColors.gold.withValues(alpha: 0.09 * intensity * boost));
    _glow(canvas, Offset(size.width * (0.78 + 0.07 * math.cos(a * 0.8)),
        size.height * (0.82 + 0.05 * math.sin(a * 0.6))), s * 0.75,
        AppColors.softGreen.withValues(alpha: 0.12 * intensity * boost));
    _glow(canvas, Offset(size.width * (0.12 + 0.05 * math.sin(a * 1.1)),
        size.height * (0.85 + 0.04 * math.cos(a))), s * 0.55,
        AppColors.midGreen.withValues(alpha: 0.08 * intensity * boost));

    _paintGrain(canvas, size);
  }

  void _glow(Canvas canvas, Offset center, double radius, Color color) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader =
          RadialGradient(colors: [color, color.withValues(alpha: 0)])
              .createShader(rect);
    canvas.drawRect(rect, paint);
  }

  /// Matte paper grain — deterministic (seeded) so it stays static between
  /// frames and never shimmers.
  void _paintGrain(Canvas canvas, Size size) {
    if (grain <= 0) return;
    var seed = 1469598103;
    int rnd() {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed;
    }

    final maxAlpha = (isDark ? 0.05 : 0.035) * grain;
    final count = ((size.width * size.height) / 1400).clamp(0, 2600).toInt();
    final paint = Paint();
    final base = isDark ? Colors.white : AppColors.darkGreen;
    for (var i = 0; i < count; i++) {
      final x = (rnd() % 10000) / 10000 * size.width;
      final y = (rnd() % 10000) / 10000 * size.height;
      final alpha = (rnd() % 100) / 100 * maxAlpha;
      paint.color = base.withValues(alpha: alpha);
      canvas.drawRect(Rect.fromLTWH(x, y, 1.2, 1.2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.t != t || old.isDark != isDark || old.intensity != intensity;
}
