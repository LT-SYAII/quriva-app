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

    // Stars (kept intentionally light) --------------------------------------
    if (isDark) {
      final count = compact ? 8 : 24;
      final rnd = math.Random(11);
      final maxY = h * (compact ? .40 : .46);
      for (var i = 0; i < count; i++) {
        canvas.drawCircle(
          Offset(rnd.nextDouble() * w, rnd.nextDouble() * maxY),
          rnd.nextDouble() * 0.8 + 0.3,
          Paint()
            ..color = Colors.white.withValues(
              alpha: .20 + rnd.nextDouble() * .40,
            ),
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
