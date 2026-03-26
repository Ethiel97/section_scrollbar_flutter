import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:section_scrollbar/src/models/section_scrollbar_visual_item.dart';

/// Immutable state exposed by `SectionScrollbarController`.
@immutable
class SectionScrollbarState {
  /// Creates state for the current scrollbar snapshot.
  SectionScrollbarState({
    required List<SectionScrollbarVisualItem> items,
    this.activeSectionId,
    this.scrollProgress = 0,
    this.activeSectionProgress = 0,
    this.thumbOffsetFraction = 0,
    this.thumbExtentFraction = 1,
    this.hasMetrics = false,
    this.isScrollActive = false,
  }) : items = List.unmodifiable(items);

  /// Currently active section id, if available.
  final String? activeSectionId;

  /// Visual item data for each declared section.
  final List<SectionScrollbarVisualItem> items;

  /// Page scroll progress, clamped to 0..1.
  final double scrollProgress;

  /// Probe progress inside the active section, clamped to 0..1.
  final double activeSectionProgress;

  /// Top offset of the thumb within its travel range, from 0 to 1.
  final double thumbOffsetFraction;

  /// Natural thumb extent relative to the full track height, from 0 to 1.
  final double thumbExtentFraction;

  /// Whether section metrics are fully available.
  final bool hasMetrics;

  /// Whether the underlying scrollable is actively scrolling.
  final bool isScrollActive;

  /// Whether the controller has complete section metrics.
  bool get isReady => hasMetrics && items.isNotEmpty;

  /// Index of the active section, or -1 when none is active.
  int get activeIndex => items.indexWhere((item) => item.id == activeSectionId);

  /// Active visual item, if one exists.
  SectionScrollbarVisualItem? get activeItem {
    final index = activeIndex;
    if (index < 0) {
      return null;
    }
    return items[index];
  }

  /// Active section label, if available.
  String? get activeSectionLabel => activeItem?.label;

  /// Active section icon, if available.
  IconData? get activeSectionIcon => activeItem?.icon;

  /// Returns the visual item for [id], if present.
  SectionScrollbarVisualItem? itemById(String id) {
    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SectionScrollbarState &&
            runtimeType == other.runtimeType &&
            activeSectionId == other.activeSectionId &&
            listEquals(items, other.items) &&
            scrollProgress == other.scrollProgress &&
            activeSectionProgress == other.activeSectionProgress &&
            thumbOffsetFraction == other.thumbOffsetFraction &&
            thumbExtentFraction == other.thumbExtentFraction &&
            hasMetrics == other.hasMetrics &&
            isScrollActive == other.isScrollActive;
  }

  @override
  int get hashCode => Object.hash(
    activeSectionId,
    Object.hashAll(items),
    scrollProgress,
    activeSectionProgress,
    thumbOffsetFraction,
    thumbExtentFraction,
    hasMetrics,
    isScrollActive,
  );
}
