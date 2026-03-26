import 'package:flutter/material.dart';
import 'package:section_scrollbar/src/controller/section_scrollbar_controller.dart';
import 'package:section_scrollbar/src/widgets/section_scrollbar_layout.dart';

/// Wraps a content section and registers its layout information with the
/// scrollbar controller.
class SectionAnchor extends StatefulWidget {
  /// Creates a section anchor.
  const SectionAnchor({
    required this.id,
    required this.child,
    super.key,
  });

  /// Section id matching a `SectionData.id`.
  final String id;

  /// Section content.
  final Widget child;

  @override
  State<SectionAnchor> createState() => _SectionAnchorState();
}

class _SectionAnchorState extends State<SectionAnchor> {
  SectionScrollbarController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _registerWithLayout();
  }

  @override
  void didUpdateWidget(covariant SectionAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _controller?.unregisterAnchor(
        id: oldWidget.id,
        anchorContext: context,
      );
      _registerWithLayout();
    }
  }

  @override
  void dispose() {
    _controller?.unregisterAnchor(
      id: widget.id,
      anchorContext: context,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        _controller?.recompute();
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: widget.child,
      ),
    );
  }

  void _registerWithLayout() {
    final controller = SectionScrollbarLayout.maybeControllerOf(context);
    if (controller == null) {
      throw FlutterError(
        'SectionAnchor must be placed inside a SectionScrollbarLayout.',
      );
    }

    final sectionIds = SectionScrollbarLayout.maybeSectionIdsOf(context);
    if (sectionIds != null && !sectionIds.contains(widget.id)) {
      throw FlutterError(
        'SectionAnchor id "${widget.id}" does not exist in '
        'SectionScrollbarLayout.sections.',
      );
    }

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) {
      throw FlutterError(
        'SectionAnchor must be placed inside a vertical Scrollable.',
      );
    }

    final viewportContext =
        scrollable.position.context.notificationContext ?? scrollable.context;

    _controller = controller;
    controller.registerAnchor(
      id: widget.id,
      anchorContext: context,
      viewportContext: viewportContext,
    );
  }
}
