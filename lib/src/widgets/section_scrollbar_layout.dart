import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:section_scrollbar/src/controller/section_scrollbar_controller.dart';
import 'package:section_scrollbar/src/models/section_data.dart';
import 'package:section_scrollbar/src/models/section_scrollbar_config.dart';
import 'package:section_scrollbar/src/models/section_scrollbar_state.dart';
import 'package:section_scrollbar/src/widgets/default_section_scrollbar.dart';

/// Builds the overlay scrollbar for a `SectionScrollbarLayout`.
typedef SectionScrollbarOverlayBuilder =
    Widget Function(
      BuildContext context,
      SectionScrollbarState state,
    );

/// Coordinates a scrollable content area with a right-side custom scrollbar
/// overlay.
class SectionScrollbarLayout extends StatefulWidget {
  /// Creates a section-aware scrollbar layout.
  const SectionScrollbarLayout({
    required this.controller,
    required this.scrollController,
    required this.sections,
    required this.child,
    this.config = const SectionScrollbarConfig(),
    this.scrollbarBuilder,
    this.scrollbarAlignment = Alignment.centerRight,
    this.scrollbarPadding = const EdgeInsets.symmetric(
      vertical: 24,
      horizontal: 16,
    ),
    super.key,
  });

  /// Controller that owns measurement and active-section state.
  final SectionScrollbarController controller;

  /// Scroll controller for the main vertical scrollable.
  final ScrollController scrollController;

  /// Ordered logical sections shown in the scrollbar state.
  final List<SectionData> sections;

  /// Scrollbar behavior and default visual configuration.
  final SectionScrollbarConfig config;

  /// Optional custom overlay builder.
  final SectionScrollbarOverlayBuilder? scrollbarBuilder;

  /// Alignment for the overlay scrollbar.
  final AlignmentGeometry scrollbarAlignment;

  /// Padding applied around the overlay scrollbar.
  final EdgeInsetsGeometry scrollbarPadding;

  /// Scrollable child, typically a `SingleChildScrollView`.
  final Widget child;

  /// Returns the nearest attached `SectionScrollbarController`.
  static SectionScrollbarController? maybeControllerOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_SectionScrollbarScope>()
        ?.controller;
  }

  /// Returns the declared section ids from the nearest layout.
  static Set<String>? maybeSectionIdsOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_SectionScrollbarScope>()
        ?.sectionIds;
  }

  @override
  State<SectionScrollbarLayout> createState() => _SectionScrollbarLayoutState();
}

class _SectionScrollbarLayoutState extends State<SectionScrollbarLayout> {
  @override
  void initState() {
    super.initState();
    _attachController();
  }

  @override
  void didUpdateWidget(covariant SectionScrollbarLayout oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detach();
    }

    _attachController();
  }

  @override
  void dispose() {
    widget.controller.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sectionIds = widget.sections.map((section) => section.id).toSet();

    return _SectionScrollbarScope(
      controller: widget.controller,
      sectionIds: sectionIds,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          Align(
            alignment: widget.scrollbarAlignment,
            child: Padding(
              padding: widget.scrollbarPadding,
              child: AnimatedBuilder(
                animation: widget.controller,
                builder: (context, _) {
                  final state = widget.controller.state;
                  return widget.scrollbarBuilder?.call(context, state) ??
                      DefaultSectionScrollbar(
                        state: state,
                        config: widget.config,
                      );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _attachController() {
    _validateSections(widget.sections);
    widget.controller.attach(
      scrollController: widget.scrollController,
      sections: widget.sections,
      config: widget.config,
    );
  }

  void _validateSections(List<SectionData> sections) {
    final ids = <String>{};
    for (final section in sections) {
      if (!ids.add(section.id)) {
        throw FlutterError(
          'Duplicate section id "${section.id}" detected in '
          'SectionScrollbarLayout.sections.',
        );
      }
    }
  }
}

class _SectionScrollbarScope extends InheritedWidget {
  const _SectionScrollbarScope({
    required this.controller,
    required this.sectionIds,
    required super.child,
  });

  final SectionScrollbarController controller;
  final Set<String> sectionIds;

  @override
  bool updateShouldNotify(_SectionScrollbarScope oldWidget) {
    return controller != oldWidget.controller ||
        !setEquals(sectionIds, oldWidget.sectionIds);
  }
}
