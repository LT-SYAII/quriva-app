import 'dart:ui';

import 'package:flutter/material.dart';

/// A frosted "liquid glass" panel: background blur, translucent gradient
/// fill and a hairline border. Adapts to light/dark monochrome themes.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    this.onTap,
    this.radius = 22,
    this.padding = const EdgeInsets.all(14),
    this.margin = EdgeInsets.zero,
    this.blur = 26,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double radius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.white : Colors.black;

    final fill = BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          base.withValues(alpha: isDark ? .10 : .055),
          base.withValues(alpha: isDark ? .035 : .02),
        ],
      ),
      border: Border.all(
        color: base.withValues(alpha: isDark ? .14 : .10),
        width: 1,
      ),
    );

    final content = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(padding: padding, child: child),
      ),
    );

    // BackdropFilter blur is expensive; skip it for list items (blur <= 0)
    // and use a plain translucent surface to keep scrolling smooth.
    final Widget panel;
    if (blur > 0) {
      panel = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(decoration: fill, child: content),
        ),
      );
    } else {
      panel = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: DecoratedBox(decoration: fill, child: content),
      );
    }

    return Padding(padding: margin, child: panel);
  }
}

/// Minimal frosted circle used for verse numbers and badges.
class GlassBadge extends StatelessWidget {
  const GlassBadge({required this.child, this.size = 36, super.key});

  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.white : Colors.black;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: base.withValues(alpha: isDark ? .08 : .04),
        border: Border.all(
          color: base.withValues(alpha: isDark ? .16 : .10),
        ),
      ),
      child: child,
    );
  }
}
