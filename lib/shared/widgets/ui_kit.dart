import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated "now playing" equalizer bars. When [active] is false the bars rest
/// at a low, static profile so they still read as an audio indicator.
class EqualizerBars extends StatefulWidget {
  const EqualizerBars({
    this.active = true,
    this.barCount = 4,
    this.height = 14,
    this.barWidth = 2.4,
    this.color,
    super.key,
  });

  final bool active;
  final int barCount;
  final double height;
  final double barWidth;
  final Color? color;

  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant EqualizerBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active ||
        oldWidget.barCount != widget.barCount) {
      _sync();
    }
  }

  void _sync() {
    if (!widget.active || !mounted) {
      _controller.stop();
      return;
    }
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final color = widget.color ?? Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = reduceMotion ? .35 : _controller.value;
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < widget.barCount; i++) ...[
                if (i > 0) const SizedBox(width: 2),
                _bar(i, t, color, widget.active && !reduceMotion ? 1 : .42),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _bar(int index, double t, Color color, double motion) {
    final phase = index * math.pi / 3.4;
    final wave = .35 + .65 * (0.5 + 0.5 * math.sin(t * math.pi * 2 + phase));
    final height = (widget.height * (0.28 + 0.72 * wave * motion)).clamp(
      2.0,
      widget.height,
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      width: widget.barWidth,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(widget.barWidth),
      ),
    );
  }
}

/// Compact pill used for metadata and filters. Monochrome by design.
class GlassChip extends StatelessWidget {
  const GlassChip({
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.dense = false,
    super.key,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.white : Colors.black;
    final foreground = selected ? scheme.onPrimary : scheme.onSurfaceVariant;
    final background = selected
        ? scheme.primary
        : base.withValues(alpha: isDark ? .07 : .045);
    final border = selected
        ? scheme.primary
        : base.withValues(alpha: isDark ? .14 : .10);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 9 : 12,
            vertical: dense ? 5 : 7,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: dense ? 12 : 14, color: foreground),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: dense ? 11 : 12.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: .1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small uppercase section label with an optional trailing widget.
class SectionLabel extends StatelessWidget {
  const SectionLabel({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}

/// Frosted circular icon button that matches the liquid-glass surfaces.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 42,
    this.iconSize = 20,
    this.selected = false,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.white : Colors.black;
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected
                ? scheme.primary
                : base.withValues(alpha: isDark ? .08 : .05),
            border: Border.all(
              color: selected
                  ? scheme.primary
                  : base.withValues(alpha: isDark ? .16 : .10),
            ),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: selected ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Tiny icon + text metadata pair.
class MetaLabel extends StatelessWidget {
  const MetaLabel({required this.icon, required this.label, super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Thin rounded progress line with an optional buffer layer behind it.
class GlassProgressLine extends StatelessWidget {
  const GlassProgressLine({
    required this.value,
    this.bufferValue,
    this.height = 3,
    this.active = false,
    super.key,
  });

  final double value;
  final double? bufferValue;
  final double height;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final track = (isDark ? Colors.white : Colors.black).withValues(alpha: .12);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: track),
            if (bufferValue != null && bufferValue! > value)
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: bufferValue!.clamp(0.0, 1.0),
                child: ColoredBox(
                  color: scheme.onSurface.withValues(alpha: .18),
                ),
              ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: ColoredBox(
                color: active
                    ? scheme.onSurface
                    : scheme.onSurface.withValues(alpha: .55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
