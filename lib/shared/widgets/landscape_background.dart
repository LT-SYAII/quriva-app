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

    // Sky gradient.
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? const [
                Color(0xFF0B0D12),
                Color(0xFF161A22),
                Color(0xFF2A2F39),
                Color(0xFF11141A),
              ]
            : const [
                Color(0xFFF2F3F5),
                Color(0xFFD9DCE1),
                Color(0xFFB7BCC5),
                Color(0xFFEDEEF1),
              ],
        stops: const [0, .45, .72, 1],
      ).createShader(rect);
    canvas.drawRect(rect, sky);

    // Stars (only in roomy dark backgrounds).
    if (isDark && !compact) {
      final stars = Paint()..color = Colors.white.withValues(alpha: .55);
      final rnd = math.Random(7);
      for (var i = 0; i < 46; i++) {
        final x = rnd.nextDouble() * w;
        final y = rnd.nextDouble() * h * .45;
        final r = rnd.nextDouble() * 1.1 + .35;
        canvas.drawCircle(Offset(x, y), r, stars);
      }
    }

    // Moon / soft light source.
    final moonCenter = Offset(w * .78, h * .18);
    final moonRadius = (compact ? 8.0 : 26.0) * (w / 390).clamp(.7, 1.6);
    canvas.drawCircle(
      moonCenter,
      moonRadius * 3.2,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                (isDark ? Colors.white : Colors.white).withValues(alpha: .28),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: moonCenter, radius: moonRadius * 3.2),
            ),
    );
    canvas.drawCircle(
      moonCenter,
      moonRadius,
      Paint()
        ..color = (isDark ? Colors.white : Colors.white).withValues(alpha: .9),
    );

    // Mountain layers.
    void mountain({
      required double baseY,
      required double amplitude,
      required Color color,
      required double phase,
      required int peaks,
    }) {
      final path = Path()..moveTo(0, h);
      path.lineTo(0, baseY);
      for (var i = 0; i <= peaks; i++) {
        final t = i / peaks;
        final x = w * t;
        final y =
            baseY -
            amplitude * (.35 + .65 * math.sin(t * math.pi * 2 + phase).abs());
        path.lineTo(x, y);
      }
      path.lineTo(w, h);
      path.close();
      canvas.drawPath(path, Paint()..color = color);
    }

    mountain(
      baseY: h * .66,
      amplitude: h * .20,
      color: (isDark ? const Color(0xFF1C212B) : const Color(0xFFA9AFB9)),
      phase: .8,
      peaks: 5,
    );
    mountain(
      baseY: h * .74,
      amplitude: h * .16,
      color: (isDark ? const Color(0xFF141820) : const Color(0xFF8F96A1)),
      phase: 2.1,
      peaks: 4,
    );
    mountain(
      baseY: h * .82,
      amplitude: h * .11,
      color: (isDark ? const Color(0xFF0C0F14) : const Color(0xFF7C828D)),
      phase: 4.2,
      peaks: 6,
    );

    // Mist near the bottom.
    final mist = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          (isDark ? Colors.black : Colors.white).withValues(alpha: .55),
        ],
      ).createShader(Rect.fromLTWH(0, h * .68, w, h * .32));
    canvas.drawRect(Rect.fromLTWH(0, h * .68, w, h * .32), mist);

    // Liquid-glass veil for readability.
    final veil = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [
                const Color(0xFF050505).withValues(alpha: .10),
                const Color(0xFF050505).withValues(alpha: .45),
              ]
            : [
                Colors.white.withValues(alpha: .10),
                Colors.white.withValues(alpha: .50),
              ],
      ).createShader(rect);
    canvas.drawRect(rect, veil);
  }

  @override
  bool shouldRepaint(covariant _LandscapePainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.compact != compact;
}
