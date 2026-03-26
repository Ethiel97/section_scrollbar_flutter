import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:section_scrollbar/src/models/section_data.dart';
import 'package:section_scrollbar/src/models/section_metrics.dart';

/// Measures registered section anchors against the active scroll viewport.
List<SectionMetrics> measureSections({
  required List<SectionData> sections,
  required Map<String, BuildContext> anchorContexts,
  required BuildContext viewportContext,
  required ScrollController scrollController,
}) {
  if (!scrollController.hasClients) {
    return const [];
  }

  final viewportObject = viewportContext.findRenderObject();
  if (viewportObject is! RenderBox || !viewportObject.attached) {
    return const [];
  }

  final viewportTop = viewportObject.localToGlobal(Offset.zero).dy;
  final scrollOffset = scrollController.position.pixels;
  final metrics = <SectionMetrics>[];

  for (final section in sections) {
    final anchorContext = anchorContexts[section.id];
    if (anchorContext == null || !anchorContext.mounted) {
      continue;
    }

    final anchorObject = anchorContext.findRenderObject();
    if (anchorObject is! RenderBox || !anchorObject.attached) {
      continue;
    }

    final top = anchorObject.localToGlobal(Offset.zero).dy;
    final startOffset = scrollOffset + (top - viewportTop);

    metrics.add(
      SectionMetrics(
        id: section.id,
        label: section.label,
        icon: section.icon,
        weight: section.weight,
        startOffset: startOffset,
        extent: math.max(anchorObject.size.height, 0),
      ),
    );
  }

  return metrics;
}
