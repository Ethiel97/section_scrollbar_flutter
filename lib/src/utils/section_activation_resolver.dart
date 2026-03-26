import 'dart:math' as math;

import 'package:section_scrollbar/src/models/section_metrics.dart';
import 'package:section_scrollbar/src/models/section_scrollbar_config.dart';

/// Returns the viewport probe fraction for the given activation strategy.
double probeFractionForStrategy(SectionActivationStrategy strategy) =>
    switch (strategy) {
      SectionActivationStrategy.leadingEdge => 0,
      SectionActivationStrategy.quarterViewport => 0.25,
      SectionActivationStrategy.center => 0.5,
    };

/// Resolves the active metric for a scroll probe.
SectionMetrics? resolveActiveMetricForProbe({
  required List<SectionMetrics> metrics,
  required double probeOffset,
}) {
  if (metrics.isEmpty) {
    return null;
  }

  final ordered = List<SectionMetrics>.of(metrics)
    ..sort((left, right) => left.startOffset.compareTo(right.startOffset));

  if (probeOffset <= ordered.first.startOffset) {
    return ordered.first;
  }

  for (var index = 0; index < ordered.length; index++) {
    final current = ordered[index];
    final nextStart = index + 1 < ordered.length
        ? ordered[index + 1].startOffset
        : double.infinity;

    if (probeOffset < nextStart) {
      return current;
    }
  }

  return ordered.last;
}

/// Resolves the active metric using a viewport strategy.
SectionMetrics? resolveActiveMetric({
  required List<SectionMetrics> metrics,
  required double scrollOffset,
  required double viewportDimension,
  required SectionActivationStrategy strategy,
}) {
  if (metrics.isEmpty) {
    return null;
  }

  final ordered = List<SectionMetrics>.of(metrics)
    ..sort((left, right) => left.startOffset.compareTo(right.startOffset));
  final viewportEndOffset = scrollOffset + viewportDimension;

  // When the viewport has reached the end of the content, the last section
  // should become active even if the configured probe line never enters it.
  if (viewportEndOffset >= ordered.last.endOffset) {
    return ordered.last;
  }

  final probeOffset =
      scrollOffset + viewportDimension * probeFractionForStrategy(strategy);
  return resolveActiveMetricForProbe(
    metrics: ordered,
    probeOffset: probeOffset,
  );
}

/// Computes progress for [sectionId] at [probeOffset].
double resolveSectionProgress({
  required List<SectionMetrics> metrics,
  required String sectionId,
  required double probeOffset,
}) {
  if (metrics.isEmpty) {
    return 0;
  }

  final ordered = List<SectionMetrics>.of(metrics)
    ..sort((left, right) => left.startOffset.compareTo(right.startOffset));

  final index = ordered.indexWhere((metric) => metric.id == sectionId);
  if (index == -1) {
    return 0;
  }

  final current = ordered[index];
  final nextStart = index + 1 < ordered.length
      ? ordered[index + 1].startOffset
      : current.endOffset;
  final effectiveExtent = math.max(
    current.extent,
    nextStart - current.startOffset,
  );

  if (effectiveExtent <= 0) {
    return 1;
  }

  return ((probeOffset - current.startOffset) / effectiveExtent).clamp(
    0.0,
    1.0,
  );
}
