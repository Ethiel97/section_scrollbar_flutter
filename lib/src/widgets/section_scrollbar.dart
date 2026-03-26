import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:section_scrollbar/src/models/section_scrollbar_config.dart';
import 'package:section_scrollbar/src/models/section_scrollbar_state.dart';

/// Builds the track behind the thumb.
typedef SectionScrollbarTrackBuilder =
    Widget Function(
      BuildContext context,
      SectionScrollbarState state, {
      required bool visible,
    });

/// Builds the thumb widget.
typedef SectionScrollbarThumbBuilder =
    Widget Function(
      BuildContext context,
      SectionScrollbarState state,
      double thumbExtent, {
      required bool visible,
    });

/// Builds the floating current-section badge.
typedef SectionScrollbarBadgeBuilder =
    Widget Function(
      BuildContext context,
      SectionScrollbarState state, {
      required bool visible,
    });

/// Generic layout widget for a section-aware custom scrollbar.
class SectionScrollbar extends StatelessWidget {
  /// Creates a section scrollbar.
  const SectionScrollbar({
    required this.state,
    required this.thumbBuilder,
    this.config = const SectionScrollbarConfig(),
    this.trackBuilder,
    this.badgeBuilder,
    super.key,
  });

  /// Current scrollbar state.
  final SectionScrollbarState state;

  /// Shared behavior and layout configuration.
  final SectionScrollbarConfig config;

  /// Optional track builder.
  final SectionScrollbarTrackBuilder? trackBuilder;

  /// Thumb builder.
  final SectionScrollbarThumbBuilder thumbBuilder;

  /// Optional badge builder.
  final SectionScrollbarBadgeBuilder? badgeBuilder;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: config.overlayWidth,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final thumbExtent = _resolveThumbExtent(height);
            final thumbTravel = math.max(0, height - thumbExtent);
            final thumbTop = state.thumbOffsetFraction * thumbTravel;
            final thumbCenterFraction = height <= 0
                ? 0.0
                : ((thumbTop + thumbExtent / 2) / height).clamp(0.0, 1.0);
            final alignmentY = thumbCenterFraction * 2 - 1;
            final showScrollbar =
                state.hasMetrics &&
                (config.alwaysShowScrollbar || state.isScrollActive);
            final showBadge = showScrollbar && state.activeItem != null;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child:
                        trackBuilder?.call(
                          context,
                          state,
                          visible: showScrollbar,
                        ) ??
                        const SizedBox.shrink(),
                  ),
                ),
                AnimatedAlign(
                  duration: config.visibilityAnimationDuration,
                  curve: Curves.easeOutCubic,
                  alignment: Alignment(1, alignmentY),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (badgeBuilder != null) ...[
                        badgeBuilder!.call(
                          context,
                          state,
                          visible: showBadge,
                        ),
                        SizedBox(width: config.badgeSpacing),
                      ],
                      thumbBuilder.call(
                        context,
                        state,
                        thumbExtent,
                        visible: showScrollbar,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _resolveThumbExtent(double trackHeight) {
    if (trackHeight <= 0) {
      return config.minThumbExtent;
    }

    final naturalExtent = state.thumbExtentFraction * trackHeight;
    return naturalExtent.clamp(
      config.minThumbExtent,
      trackHeight,
    );
  }
}
