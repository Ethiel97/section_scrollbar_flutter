import 'package:flutter/widgets.dart';

/// Immutable visual data for a tracked section.
@immutable
class SectionScrollbarVisualItem {
  /// Creates a visual scrollbar item.
  const SectionScrollbarVisualItem({
    required this.id,
    required this.label,
    required this.isActive,
    required this.startFraction,
    required this.extentFraction,
    required this.progressWithinSection,
    this.icon,
  });

  /// Stable section identifier.
  final String id;

  /// Section label.
  final String label;

  /// Optional section icon.
  final IconData? icon;

  /// Whether this item is currently active.
  final bool isActive;

  /// Start position within the full scrollable content, from 0 to 1.
  final double startFraction;

  /// Extent within the full scrollable content, from 0 to 1.
  final double extentFraction;

  /// Progress of the viewport probe within the section, clamped to 0..1.
  final double progressWithinSection;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SectionScrollbarVisualItem &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            label == other.label &&
            icon == other.icon &&
            isActive == other.isActive &&
            startFraction == other.startFraction &&
            extentFraction == other.extentFraction &&
            progressWithinSection == other.progressWithinSection;
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    icon,
    isActive,
    startFraction,
    extentFraction,
    progressWithinSection,
  );
}
