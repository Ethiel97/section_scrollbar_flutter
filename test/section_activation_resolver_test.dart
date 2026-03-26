import 'package:flutter_test/flutter_test.dart';
import 'package:section_scrollbar/src/models/section_metrics.dart';
import 'package:section_scrollbar/src/models/section_scrollbar_config.dart';
import 'package:section_scrollbar/src/utils/section_activation_resolver.dart';

void main() {
  const metrics = <SectionMetrics>[
    SectionMetrics(
      id: 'intro',
      label: 'Intro',
      icon: null,
      weight: null,
      startOffset: 0,
      extent: 300,
    ),
    SectionMetrics(
      id: 'work',
      label: 'Work',
      icon: null,
      weight: null,
      startOffset: 300,
      extent: 500,
    ),
    SectionMetrics(
      id: 'contact',
      label: 'Contact',
      icon: null,
      weight: null,
      startOffset: 800,
      extent: 400,
    ),
  ];

  group('probeFractionForStrategy', () {
    test('returns expected fractions', () {
      expect(
        probeFractionForStrategy(SectionActivationStrategy.leadingEdge),
        0,
      );
      expect(
        probeFractionForStrategy(SectionActivationStrategy.quarterViewport),
        0.25,
      );
      expect(
        probeFractionForStrategy(SectionActivationStrategy.center),
        0.5,
      );
    });
  });

  group('resolveActiveMetric', () {
    test('uses the leading edge when requested', () {
      final active = resolveActiveMetric(
        metrics: metrics,
        scrollOffset: 320,
        viewportDimension: 400,
        strategy: SectionActivationStrategy.leadingEdge,
      );

      expect(active?.id, 'work');
    });

    test('uses the quarter viewport probe by default', () {
      final active = resolveActiveMetric(
        metrics: metrics,
        scrollOffset: 220,
        viewportDimension: 400,
        strategy: SectionActivationStrategy.quarterViewport,
      );

      expect(active?.id, 'work');
    });

    test('uses the center probe when requested', () {
      final active = resolveActiveMetric(
        metrics: metrics,
        scrollOffset: 140,
        viewportDimension: 400,
        strategy: SectionActivationStrategy.center,
      );

      expect(active?.id, 'work');
    });

    test('returns the last section when the viewport reaches content end', () {
      final active = resolveActiveMetric(
        metrics: metrics,
        scrollOffset: 700,
        viewportDimension: 500,
        strategy: SectionActivationStrategy.center,
      );

      expect(active?.id, 'contact');
    });

    test('clamps to the last section after the content end', () {
      final active = resolveActiveMetricForProbe(
        metrics: metrics,
        probeOffset: 2000,
      );

      expect(active?.id, 'contact');
    });
  });

  group('resolveSectionProgress', () {
    test('computes clamped progress inside the target section', () {
      final progress = resolveSectionProgress(
        metrics: metrics,
        sectionId: 'work',
        probeOffset: 550,
      );

      expect(progress, closeTo(0.5, 0.001));
    });

    test('returns 0 before the section starts and 1 after it ends', () {
      expect(
        resolveSectionProgress(
          metrics: metrics,
          sectionId: 'work',
          probeOffset: 200,
        ),
        0,
      );
      expect(
        resolveSectionProgress(
          metrics: metrics,
          sectionId: 'work',
          probeOffset: 900,
        ),
        1,
      );
    });
  });
}
