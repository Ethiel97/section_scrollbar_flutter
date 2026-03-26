import 'package:flutter/widgets.dart';

/// Describes a logical scroll section tracked by the scrollbar.
@immutable
class SectionData {
  /// Creates a section descriptor.
  const SectionData({
    required this.id,
    required this.label,
    this.icon,
    this.weight,
  }) : assert(id != '', 'Section ids must not be empty.'),
       assert(label != '', 'Section labels must not be empty.'),
       assert(weight == null || weight > 0, 'Section weights must be > 0.');

  /// Stable identifier used by `SectionAnchor` and the controller.
  final String id;

  /// Human readable label displayed in the floating section badge.
  final String label;

  /// Optional icon displayed before the label.
  final IconData? icon;

  /// Optional weight reserved for future visual weighting strategies.
  final double? weight;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SectionData &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            label == other.label &&
            icon == other.icon &&
            weight == other.weight;
  }

  @override
  int get hashCode => Object.hash(id, label, icon, weight);
}
