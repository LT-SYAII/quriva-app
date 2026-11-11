import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Procedural monochrome "night landscape" backdrop (no network, no bundled
/// photos) with a soft liquid-glass veil so content stays readable.
class LandscapeBackground extends StatelessWidget {
  const LandscapeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _LandscapePainter(isDark: isDark),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Album-art tile: a rounded landscape painting used by mini/full players.
class LandscapeArtwork extends StatelessWidget {
  const LandscapeArtwork({this.size = 56, this.radius = 14, super.key});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox.square(
        dimension: size,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _LandscapePainter(isDark: isDark, compact: true),
          ),
        ),
      ),
    );
  }
}

class _LandscapePainter extends CustomPainter {
  const _LandscapePainter({required this.isDark, this.compact = false});

  final bool isDark;
  final bool compact;

  static const List<Offset> _starsFull = [
    Offset(0.06, 0.04),
    Offset(0.14, 0.12),
    Offset(0.22, 0.07),
    Offset(0.31, 0.18),
    Offset(0.38, 0.05),
    Offset(0.45, 0.14),
    Offset(0.52, 0.09),
    Offset(0.58, 0.20),
    Offset(0.63, 0.03),
    Offset(0.69, 0.16),
    Offset(0.74, 0.08),
    Offset(0.81, 0.13),
    Offset(0.88, 0.06),
    Offset(0.93, 0.19),
    Offset(0.10, 0.28),
    Offset(0.18, 0.34),
    Offset(0.27, 0.24),
    Offset(0.41, 0.31),
    Offset(0.49, 0.26),
    Offset(0.57, 0.36),
    Offset(0.66, 0.28),
    Offset(0.76, 0.33),
    Offset(0.84, 0.25),
    Offset(0.91, 0.30),
  ];
  static const List<Offset> _starsCompact = [
    Offset(0.08, 0.06),
    Offset(0.22, 0.14),
    Offset(0.36, 0.08),
    Offset(0.48, 0.18),
    Offset(0.62, 0.10),
    Offset(0.74, 0.16),
    Offset(0.86, 0.07),
    Offset(0.92, 0.22),
  ];
  static const List<double> _starSizes = [
    0.45,
    0.7,
    0.35,
    0.8,
    0.5,
    0.65,
    0.4,
    0.75,
    0.55,
    0.7,
    0.38,
    0.6,
    0.5,
    0.8,
    0.42,
    0.68,
    0.36,
    0.72,
    0.48,
    0.64,
    0.4,
    0.78,
    0.52,
    0.66,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final w = size.width;
    final h = size.height;
    final base = isDark ? Colors.white : Colors.black;
    final unit = (w / 390).clamp(.7, 1.6);

    // Sky gradient ----------------------------------------------------------
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  Color(0xFF080A0F),
                  Color(0xFF11151D),
                  Color(0xFF232833),
                  Color(0xFF0C1015),
                ]
              : const [
                  Color(0xFFF7F8FA),
                  Color(0xFFDFE2E7),
                  Color(0xFFB9BEC7),
                  Color(0xFFE9EAEE),
                ],
          stops: const [0, .42, .70, 1],
        ).createShader(rect),
    );

    // Subtle glow (no expensive mask blur) ----------------------------------
    if (!compact) {
      final glow = Path()
        ..moveTo(0, h * .22)
        ..quadraticBezierTo(w * .35, h * .12, w * .72, h * .22)
        ..quadraticBezierTo(w * .96, h * .28, w, h * .24)
        ..lineTo(w, h * .36)
        ..quadraticBezierTo(w * .58, h * .30, w * .18, h * .36)
        ..lineTo(0, h * .32)
        ..close();
      canvas.drawPath(
        glow,
        Paint()..color = base.withValues(alpha: isDark ? .05 : .10),
      );
    }

    // Stars (kept intentionally light, precomputed positions) ---------------
    if (isDark) {
      final stars = compact ? _starsCompact : _starsFull;
      final maxYFactor = compact ? .40 : .46;
      final paint = Paint();
      for (var i = 0; i < stars.length; i++) {
        final p = stars[i];
        final r = _starSizes[i % _starSizes.length];
        final a = 0.22 + (r * 0.45);
        paint.color = Colors.white.withValues(alpha: a.clamp(0.2, 0.55));
        canvas.drawCircle(
          Offset(p.dx * w, (p.dy / 0.36) * h * maxYFactor),
          r,
          paint,
        );
      }
    }

    // Moon with soft halo ---------------------------------------------------
    final moonCenter = Offset(w * .78, h * .17);
    final moonRadius = (compact ? 7.0 : 23.0) * unit;
    canvas.drawCircle(
      moonCenter,
      moonRadius * 3.1,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                base.withValues(alpha: isDark ? .20 : .15),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: moonCenter, radius: moonRadius * 3.1),
            ),
    );
    canvas.drawCircle(
      moonCenter,
      moonRadius,
      Paint()..color = base.withValues(alpha: isDark ? .94 : .86),
    );

    // Mountains -------------------------------------------------------------
    Path mountainPath({
      required double baseY,
      required double amplitude,
      required double phase,
      required int peaks,
    }) {
      final path = Path()..moveTo(0, h);
      path.lineTo(0, baseY);
      for (var i = 0; i <= peaks; i++) {
        final t = i / peaks;
        final x = w * t;
        final wave = .45 + .55 * math.sin(t * math.pi * 2.1 + phase).abs();
        path.lineTo(x, baseY - amplitude * wave);
      }
      path.lineTo(w, h);
      path.close();
      return path;
    }

    void mountain({
      required double baseY,
      required double amplitude,
      required Color color,
      required double phase,
      required int peaks,
    }) {
      canvas.drawPath(
        mountainPath(
          baseY: baseY,
          amplitude: amplitude,
          phase: phase,
          peaks: peaks,
        ),
        Paint()..color = color,
      );
    }

    mountain(
      baseY: h * .70,
      amplitude: h * (compact ? .14 : .17),
      color: isDark ? const Color(0xFF171C24) : const Color(0xFFA2A9B4),
      phase: 1.4,
      peaks: compact ? 3 : 4,
    );
    mountain(
      baseY: h * .82,
      amplitude: h * (compact ? .10 : .12),
      color: isDark ? const Color(0xFF0D1116) : const Color(0xFF7E8590),
      phase: 3.6,
      peaks: compact ? 4 : 5,
    );

    if (!compact) {
      final lakeTop = h * .84;
      canvas.drawRect(
        Rect.fromLTWH(0, lakeTop, w, h - lakeTop),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF0A0D11), Color(0xFF05070A)]
                : const [Color(0xFFB3B8C1), Color(0xFFD8DBE0)],
          ).createShader(Rect.fromLTWH(0, lakeTop, w, h - lakeTop)),
      );

      canvas.drawRect(
        Rect.fromLTWH(0, h * .64, w, h * .36),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              (isDark ? Colors.black : Colors.white).withValues(alpha: .26),
              (isDark ? Colors.black : Colors.white).withValues(alpha: .48),
            ],
            stops: const [0, .55, 1],
          ).createShader(Rect.fromLTWH(0, h * .64, w, h * .36)),
      );
    }

    // Liquid-glass veil for readability --------------------------------------
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF050505)
                      .withValues(alpha: compact ? .16 : .14),
                  const Color(0xFF050505)
                      .withValues(alpha: compact ? .34 : .30),
                  const Color(0xFF050505)
                      .withValues(alpha: compact ? .50 : .52),
                ]
              : [
                  Colors.white.withValues(alpha: compact ? .12 : .10),
                  Colors.white.withValues(alpha: compact ? .30 : .24),
                  Colors.white.withValues(alpha: compact ? .48 : .50),
                ],
          stops: const [0, .55, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _LandscapePainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.compact != compact;
}
