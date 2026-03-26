import 'package:flutter/material.dart';
import 'package:section_scrollbar/src/models/section_scrollbar_config.dart';
import 'package:section_scrollbar/src/models/section_scrollbar_state.dart';
import 'package:section_scrollbar/src/widgets/section_scrollbar.dart';

/// A polished default implementation for `SectionScrollbar`.
class DefaultSectionScrollbar extends StatelessWidget {
  /// Creates the default section scrollbar.
  const DefaultSectionScrollbar({
    required this.state,
    this.config = const SectionScrollbarConfig(),
    this.badgeColor,
    this.thumbColor,
    this.trackColor,
    super.key,
  });

  /// Current scrollbar state.
  final SectionScrollbarState state;

  /// Shared behavior and layout defaults.
  final SectionScrollbarConfig config;

  /// Optional surface color for the floating badge.
  final Color? badgeColor;

  /// Optional thumb color.
  final Color? thumbColor;

  /// Optional track color.
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedBadgeColor = badgeColor ?? Colors.white;
    final resolvedThumbColor =
        thumbColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.52);
    final resolvedTrackColor =
        trackColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.14);

    return SectionScrollbar(
      state: state,
      config: config,
      trackBuilder: (context, state, {required visible}) {
        return AnimatedOpacity(
          duration: config.visibilityAnimationDuration,
          opacity: visible ? 1 : 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: resolvedTrackColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: SizedBox(
              width: config.trackThickness,
              height: double.infinity,
            ),
          ),
        );
      },
      thumbBuilder: (context, state, thumbExtent, {required visible}) {
        return AnimatedOpacity(
          duration: config.visibilityAnimationDuration,
          opacity: visible ? 1 : 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: resolvedThumbColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: SizedBox(
              width: config.thumbThickness,
              height: thumbExtent,
            ),
          ),
        );
      },
      badgeBuilder: (context, state, {required visible}) {
        final activeItem = state.activeItem;
        if (activeItem == null) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final labelStyle = theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        );

        return AnimatedOpacity(
          duration: config.visibilityAnimationDuration,
          opacity: visible ? 1 : 0,
          child: AnimatedSlide(
            duration: config.visibilityAnimationDuration,
            curve: Curves.easeOutCubic,
            offset: visible ? Offset.zero : const Offset(0.08, 0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: resolvedBadgeColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (activeItem.icon != null) ...[
                      Icon(
                        activeItem.icon,
                        size: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(activeItem.label, style: labelStyle),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
