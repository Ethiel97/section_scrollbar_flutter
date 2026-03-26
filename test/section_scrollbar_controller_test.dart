import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:section_scrollbar/section_scrollbar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SectionScrollbarController', () {
    testWidgets('tracks the active section while scrolling', (tester) async {
      final controller = SectionScrollbarController();
      final scrollController = ScrollController();

      await tester.pumpWidget(
        _TestHarness(
          controller: controller,
          scrollController: scrollController,
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.state.hasMetrics, isTrue);
      expect(controller.state.activeSectionId, 'intro');
      expect(controller.state.activeSectionLabel, 'Intro');
      expect(controller.state.items, hasLength(4));
      expect(controller.state.thumbExtentFraction, lessThan(1.0));

      scrollController.jumpTo(520);
      await tester.pumpAndSettle();

      expect(controller.state.activeSectionId, 'work');
      expect(controller.state.scrollProgress, greaterThan(0));
      expect(controller.state.thumbOffsetFraction, greaterThan(0));
    });

    testWidgets('scrollTo animates to the requested section', (tester) async {
      final controller = SectionScrollbarController();
      final scrollController = ScrollController();

      await tester.pumpWidget(
        _TestHarness(
          controller: controller,
          scrollController: scrollController,
        ),
      );
      await tester.pumpAndSettle();

      await controller.scrollTo('metrics');
      await tester.pumpAndSettle();

      expect(controller.state.activeSectionId, 'metrics');
      expect(
        controller.state.activeSectionProgress,
        inInclusiveRange(0.0, 1.0),
      );
    });

    testWidgets('activates the last section at the bottom of the scroll view', (
      tester,
    ) async {
      final controller = SectionScrollbarController();
      final scrollController = ScrollController();

      await tester.pumpWidget(
        _TestHarness(
          controller: controller,
          scrollController: scrollController,
        ),
      );
      await tester.pumpAndSettle();

      scrollController.jumpTo(scrollController.position.maxScrollExtent);
      await tester.pumpAndSettle();

      expect(controller.state.activeSectionId, 'contact');
      expect(controller.state.activeSectionLabel, 'Contact');
    });

    test('scrollTo fails clearly before metrics are available', () {
      final controller = SectionScrollbarController();
      final scrollController = ScrollController();

      controller.attach(
        scrollController: scrollController,
        sections: const [
          SectionData(id: 'intro', label: 'Intro'),
        ],
        config: const SectionScrollbarConfig(),
      );

      expect(
        () => controller.scrollTo('intro'),
        throwsA(isA<StateError>()),
      );
    });
  });
}

class _TestHarness extends StatefulWidget {
  const _TestHarness({
    required this.controller,
    required this.scrollController,
  });

  final SectionScrollbarController controller;
  final ScrollController scrollController;

  @override
  State<_TestHarness> createState() => _TestHarnessState();
}

class _TestHarnessState extends State<_TestHarness> {
  static const sections = <SectionData>[
    SectionData(id: 'intro', label: 'Intro'),
    SectionData(id: 'work', label: 'Work'),
    SectionData(id: 'metrics', label: 'Metrics'),
    SectionData(id: 'contact', label: 'Contact'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox.expand(
          child: SectionScrollbarLayout(
            controller: widget.controller,
            scrollController: widget.scrollController,
            sections: sections,
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: const Column(
                children: [
                  SectionAnchor(
                    id: 'intro',
                    child: SizedBox(height: 420, width: double.infinity),
                  ),
                  SectionAnchor(
                    id: 'work',
                    child: SizedBox(height: 560, width: double.infinity),
                  ),
                  SectionAnchor(
                    id: 'metrics',
                    child: SizedBox(height: 480, width: double.infinity),
                  ),
                  SectionAnchor(
                    id: 'contact',
                    child: SizedBox(height: 360, width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
