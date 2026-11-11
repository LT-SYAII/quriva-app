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
    final unit = w / 390;

    // Sky gradient ----------------------------------------------------------
    final sky = Paint()
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
      ).createShader(rect);
    canvas.drawRect(rect, sky);

    // Soft aurora ribbons ---------------------------------------------------
    void aurora({
      required double top,
      required double amplitude,
      required double phase,
      required double alpha,
      required double thickness,
    }) {
      final path = Path()..moveTo(-w * .1, top);
      for (var i = 0; i <= 8; i++) {
        final t = i / 8;
        final x = w * t;
        final y = top + math.sin(t * math.pi * 2 + phase) * amplitude;
        path.lineTo(x, y);
      }
      for (var i = 8; i >= 0; i--) {
        final t = i / 8;
        final x = w * t;
        final y =
            top +
            math.sin(t * math.pi * 2 + phase) * amplitude +
            thickness * (1 - t * .2);
        path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            (compact ? 8 : 26) * unit.clamp(.7, 1.8),
          )
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              base.withValues(alpha: alpha),
              base.withValues(alpha: alpha * .35),
              Colors.transparent,
            ],
          ).createShader(Rect.fromLTWH(0, top, w, amplitude + thickness)),
      );
    }

    if (!compact) {
      aurora(
        top: h * .16,
        amplitude: h * .05,
        phase: .3,
        alpha: isDark ? .10 : .22,
        thickness: h * .08,
      );
      aurora(
        top: h * .27,
        amplitude: h * .04,
        phase: 2.2,
        alpha: isDark ? .07 : .16,
        thickness: h * .06,
      );
    }

    // Stars -----------------------------------------------------------------
    if (isDark && !compact) {
      final rnd = math.Random(11);
      for (var i = 0; i < 90; i++) {
        final x = rnd.nextDouble() * w;
        final y = rnd.nextDouble() * h * .48;
        final r = rnd.nextDouble() * 1.2 + .25;
        final alpha = .18 + rnd.nextDouble() * .55;
        canvas.drawCircle(
          Offset(x, y),
          r,
          Paint()..color = Colors.white.withValues(alpha: alpha),
        );
      }
      // A scatter of brighter stars with a subtle halo.
      final bright = math.Random(4);
      for (var i = 0; i < 6; i++) {
        final center = Offset(
          bright.nextDouble() * w,
          bright.nextDouble() * h * .38,
        );
        final r = 1.6 + bright.nextDouble() * .9;
        canvas.drawCircle(
          center,
          r * 3.4,
          Paint()
            ..shader = RadialGradient(
              colors: [Colors.white.withValues(alpha: .22), Colors.transparent],
            ).createShader(Rect.fromCircle(center: center, radius: r * 3.4)),
        );
        canvas.drawCircle(center, r, Paint()..color = Colors.white);
      }
    }

    // Moon with halo ----------------------------------------------------------
    final moonCenter = Offset(w * .78, h * .17);
    final moonRadius = (compact ? 7.0 : 24.0) * unit.clamp(.7, 1.6);
    final moonHalo = moonRadius * 4;
    canvas.drawCircle(
      moonCenter,
      moonHalo,
      Paint()
        ..shader = RadialGradient(
          colors: [
            base.withValues(alpha: isDark ? .26 : .18),
            base.withValues(alpha: isDark ? .05 : .04),
            Colors.transparent,
          ],
          stops: const [0, .45, 1],
        ).createShader(Rect.fromCircle(center: moonCenter, radius: moonHalo)),
    );
    canvas.drawCircle(
      moonCenter,
      moonRadius * 1.22,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8
        ..color = base.withValues(alpha: isDark ? .18 : .12),
    );
    canvas.drawCircle(
      moonCenter,
      moonRadius,
      Paint()..color = base.withValues(alpha: isDark ? .94 : .82),
    );
    // Gentle crescent shading to avoid a flat disc.
    canvas.drawCircle(
      moonCenter.translate(-moonRadius * .18, -moonRadius * .12),
      moonRadius,
      Paint()..color = base.withValues(alpha: isDark ? .16 : .10),
    );

    // Mountains ---------------------------------------------------------------
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
        final wave = .42 + .58 * math.sin(t * math.pi * 2.1 + phase).abs();
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
      required Color rim,
      required double phase,
      required int peaks,
    }) {
      final path = mountainPath(
        baseY: baseY,
        amplitude: amplitude,
        phase: phase,
        peaks: peaks,
      );
      canvas.drawPath(path, Paint()..color = color);

      // Hairline rim light on the ridge.
      final ridge = Path()..moveTo(0, baseY);
      for (var i = 0; i <= peaks; i++) {
        final t = i / peaks;
        final x = w * t;
        final wave = .42 + .58 * math.sin(t * math.pi * 2.1 + phase).abs();
        ridge.lineTo(x, baseY - amplitude * wave);
      }
      canvas.drawPath(
        ridge,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = compact ? .6 : 1
          ..color = rim,
      );
    }

    mountain(
      baseY: h * .63,
      amplitude: h * .19,
      color: isDark ? const Color(0xFF1B2029) : const Color(0xFFAEB4BE),
      rim: base.withValues(alpha: isDark ? .10 : .18),
      phase: .9,
      peaks: 5,
    );
    mountain(
      baseY: h * .72,
      amplitude: h * .15,
      color: isDark ? const Color(0xFF141920) : const Color(0xFF959CA7),
      rim: base.withValues(alpha: isDark ? .08 : .16),
      phase: 2.3,
      peaks: 4,
    );
    mountain(
      baseY: h * .81,
      amplitude: h * .105,
      color: isDark ? const Color(0xFF0D1116) : const Color(0xFF7E8590),
      rim: base.withValues(alpha: isDark ? .06 : .12),
      phase: 4.1,
      peaks: 6,
    );

    // Lake / reflection strip -------------------------------------------------
    final lakeTop = h * .84;
    final lake = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? const [Color(0xFF0A0D11), Color(0xFF05070A)]
            : const [Color(0xFFB3B8C1), Color(0xFFD8DBE0)],
      ).createShader(Rect.fromLTWH(0, lakeTop, w, h - lakeTop));
    canvas.drawRect(Rect.fromLTWH(0, lakeTop, w, h - lakeTop), lake);

    if (!compact) {
      // Moon path on the water.
      final reflection = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            base.withValues(alpha: isDark ? .16 : .22),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, lakeTop, w, h - lakeTop));
      final refRect = Rect.fromCenter(
        center: Offset(w * .78, lakeTop + (h - lakeTop) * .32),
        width: w * .16,
        height: (h - lakeTop) * .52,
      );
      canvas.drawOval(refRect, reflection);

      final rnd = math.Random(19);
      for (var i = 0; i < 22; i++) {
        final t = rnd.nextDouble();
        final y = lakeTop + (h - lakeTop) * (.12 + t * .72);
        final width = w * (.04 + rnd.nextDouble() * .18);
        final x = w * .30 + rnd.nextDouble() * w * .52;
        canvas.drawLine(
          Offset(x, y),
          Offset(x + width, y),
          Paint()
            ..strokeWidth = .8
            ..color = base.withValues(
              alpha: (isDark ? .10 : .16) * (.35 + rnd.nextDouble() * .65),
            ),
        );
      }
    }

    // Mist -------------------------------------------------------------------
    canvas.drawRect(
      Rect.fromLTWH(0, h * .62, w, h * .38),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            (isDark ? Colors.black : Colors.white).withValues(alpha: .30),
            (isDark ? Colors.black : Colors.white).withValues(alpha: .55),
          ],
          stops: const [0, .55, 1],
        ).createShader(Rect.fromLTWH(0, h * .62, w, h * .38)),
    );

    // Liquid-glass veil for readability ----------------------------------------
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF050505).withValues(alpha: .16),
                  const Color(0xFF050505).withValues(alpha: .34),
                  const Color(0xFF050505).withValues(alpha: .58),
                ]
              : [
                  Colors.white.withValues(alpha: .12),
                  Colors.white.withValues(alpha: .28),
                  Colors.white.withValues(alpha: .58),
                ],
          stops: const [0, .55, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _LandscapePainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.compact != compact;
}
