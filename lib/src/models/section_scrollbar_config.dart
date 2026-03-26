import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Controls where the viewport probe line sits when resolving the active
/// section.
enum SectionActivationStrategy {
  /// Uses the top edge of the viewport.
  leadingEdge,

  /// Uses a probe line at 25% of the viewport height.
  quarterViewport,

  /// Uses the center line of the viewport.
  center,
}

/// Shared behavior and visual defaults for the section scrollbar.
@immutable
class SectionScrollbarConfig {
  /// Creates a scrollbar configuration.
  const SectionScrollbarConfig({
    this.activationStrategy = SectionActivationStrategy.center,
    this.scrollAnimationDuration = const Duration(milliseconds: 420),
    this.scrollAnimationCurve = Curves.easeInOutCubic,
    this.overlayWidth = 144,
    this.trackThickness = 4,
    this.thumbThickness = 6,
    this.minThumbExtent = 40,
    this.badgeSpacing = 12,
    this.visibilityAnimationDuration = const Duration(milliseconds: 180),
    this.alwaysShowScrollbar = false,
  }) : assert(overlayWidth > 0, 'overlayWidth must be > 0.'),
       assert(trackThickness > 0, 'trackThickness must be > 0.'),
       assert(thumbThickness > 0, 'thumbThickness must be > 0.'),
       assert(minThumbExtent > 0, 'minThumbExtent must be > 0.'),
       assert(badgeSpacing >= 0, 'badgeSpacing must be >= 0.');

  /// Strategy used to resolve the active section.
  final SectionActivationStrategy activationStrategy;

  /// Duration used by `SectionScrollbarController.scrollTo`.
  final Duration scrollAnimationDuration;

  /// Curve used by `SectionScrollbarController.scrollTo`.
  final Curve scrollAnimationCurve;

  /// Total overlay width reserved for the scrollbar and floating badge.
  final double overlayWidth;

  /// Width of the track behind the thumb.
  final double trackThickness;

  /// Width of the thumb.
  final double thumbThickness;

  /// Minimum thumb height in logical pixels.
  final double minThumbExtent;

  /// Gap between the thumb and the floating badge.
  final double badgeSpacing;

  /// Duration used by the default scrollbar visibility animations.
  final Duration visibilityAnimationDuration;

  /// Whether the scrollbar should stay visible while idle.
  final bool alwaysShowScrollbar;

  /// Returns a copy with selected fields replaced.
  SectionScrollbarConfig copyWith({
    SectionActivationStrategy? activationStrategy,
    Duration? scrollAnimationDuration,
    Curve? scrollAnimationCurve,
    double? overlayWidth,
    double? trackThickness,
    double? thumbThickness,
    double? minThumbExtent,
    double? badgeSpacing,
    Duration? visibilityAnimationDuration,
    bool? alwaysShowScrollbar,
  }) {
    return SectionScrollbarConfig(
      activationStrategy: activationStrategy ?? this.activationStrategy,
      scrollAnimationDuration:
          scrollAnimationDuration ?? this.scrollAnimationDuration,
      scrollAnimationCurve: scrollAnimationCurve ?? this.scrollAnimationCurve,
      overlayWidth: overlayWidth ?? this.overlayWidth,
      trackThickness: trackThickness ?? this.trackThickness,
      thumbThickness: thumbThickness ?? this.thumbThickness,
      minThumbExtent: minThumbExtent ?? this.minThumbExtent,
      badgeSpacing: badgeSpacing ?? this.badgeSpacing,
      visibilityAnimationDuration:
          visibilityAnimationDuration ?? this.visibilityAnimationDuration,
      alwaysShowScrollbar: alwaysShowScrollbar ?? this.alwaysShowScrollbar,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SectionScrollbarConfig &&
            runtimeType == other.runtimeType &&
            activationStrategy == other.activationStrategy &&
            scrollAnimationDuration == other.scrollAnimationDuration &&
            scrollAnimationCurve == other.scrollAnimationCurve &&
            overlayWidth == other.overlayWidth &&
            trackThickness == other.trackThickness &&
            thumbThickness == other.thumbThickness &&
            minThumbExtent == other.minThumbExtent &&
            badgeSpacing == other.badgeSpacing &&
            visibilityAnimationDuration == other.visibilityAnimationDuration &&
            alwaysShowScrollbar == other.alwaysShowScrollbar;
  }

  @override
  int get hashCode => Object.hash(
    activationStrategy,
    scrollAnimationDuration,
    scrollAnimationCurve,
    overlayWidth,
    trackThickness,
    thumbThickness,
    minThumbExtent,
    badgeSpacing,
    visibilityAnimationDuration,
    alwaysShowScrollbar,
  );
}
