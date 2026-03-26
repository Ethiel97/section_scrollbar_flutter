import 'package:flutter/widgets.dart';

/// Internal measured metrics for a section anchor.
@immutable
class SectionMetrics {
  /// Creates section metrics.
  const SectionMetrics({
    required this.id,
    required this.label,
    required this.icon,
    required this.weight,
    required this.startOffset,
    required this.extent,
  });

  /// Stable section identifier.
  final String id;

  /// Section label.
  final String label;

  /// Optional icon.
  final IconData? icon;

  /// Optional proportional weight.
  final double? weight;

  /// Scroll offset where the section starts.
  final double startOffset;

  /// Measured section extent.
  final double extent;

  /// Scroll offset where the section ends.
  double get endOffset => startOffset + extent;
}
