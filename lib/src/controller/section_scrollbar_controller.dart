import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:section_scrollbar/src/models/section_data.dart';
import 'package:section_scrollbar/src/models/section_metrics.dart';
import 'package:section_scrollbar/src/models/section_scrollbar_config.dart';
import 'package:section_scrollbar/src/models/section_scrollbar_state.dart';
import 'package:section_scrollbar/src/models/section_scrollbar_visual_item.dart';
import 'package:section_scrollbar/src/utils/section_activation_resolver.dart';
import 'package:section_scrollbar/src/utils/section_measurement.dart';

/// Coordinates scroll position, section measurements, and derived scrollbar
/// state.
class SectionScrollbarController extends ChangeNotifier {
  /// Creates a controller for the section scrollbar.
  SectionScrollbarController();

  ScrollController? _scrollController;
  ScrollPosition? _scrollPosition;
  List<SectionData> _sections = const [];
  SectionScrollbarConfig _config = const SectionScrollbarConfig();
  final Map<String, BuildContext> _anchorContexts = <String, BuildContext>{};
  BuildContext? _viewportContext;
  List<SectionMetrics> _metrics = const [];
  SectionScrollbarState _state = SectionScrollbarState(items: const []);
  bool _recomputeScheduled = false;
  bool _isScrollActive = false;

  /// Immutable state describing the current scrollbar snapshot.
  SectionScrollbarState get state => _state;

  /// Attaches the controller to a `ScrollController` and section definitions.
  void attach({
    required ScrollController scrollController,
    required List<SectionData> sections,
    required SectionScrollbarConfig config,
  }) {
    _validateSections(sections);

    if (!identical(_scrollController, scrollController)) {
      _scrollController?.removeListener(_handleScroll);
      _removeScrollPositionListener();
      _scrollController = scrollController;
      _scrollController!.addListener(_handleScroll);
    }

    final sectionsChanged = !listEquals(_sections, sections);
    final configChanged = _config != config;
    _sections = List<SectionData>.unmodifiable(sections);
    _config = config;

    for (final id in _anchorContexts.keys.toList()) {
      if (!_sections.any((section) => section.id == id)) {
        _anchorContexts.remove(id);
      }
    }

    if (sectionsChanged || configChanged || _state.items.isEmpty) {
      _publishState(_buildState());
    }

    recompute();
  }

  /// Detaches the controller from the current scroll controller.
  void detach() {
    _scrollController?.removeListener(_handleScroll);
    _scrollController = null;
    _removeScrollPositionListener();
    _viewportContext = null;
    _anchorContexts.clear();
    _metrics = const [];
    _isScrollActive = false;
    _publishState(_buildState());
  }

  /// Registers a section anchor.
  void registerAnchor({
    required String id,
    required BuildContext anchorContext,
    required BuildContext viewportContext,
  }) {
    if (!_sections.any((section) => section.id == id)) {
      throw FlutterError(
        'SectionAnchor id "$id" was registered but not declared in '
        'SectionScrollbarLayout.sections.',
      );
    }

    final existingContext = _anchorContexts[id];
    if (existingContext != null &&
        existingContext != anchorContext &&
        existingContext.mounted) {
      throw FlutterError(
        'Duplicate SectionAnchor id "$id" detected. '
        'Section ids must be unique.',
      );
    }

    if (_viewportContext != null &&
        _viewportContext != viewportContext &&
        _viewportContext!.mounted) {
      throw FlutterError(
        'All SectionAnchor widgets must belong to the same Scrollable in v1.',
      );
    }

    _anchorContexts[id] = anchorContext;
    _viewportContext = viewportContext;
    recompute();
  }

  /// Unregisters a section anchor.
  void unregisterAnchor({
    required String id,
    required BuildContext anchorContext,
  }) {
    final existingContext = _anchorContexts[id];
    if (existingContext == anchorContext) {
      _anchorContexts.remove(id);
      if (_anchorContexts.isEmpty) {
        _viewportContext = null;
      }
      recompute();
    }
  }

  /// Schedules a metric recomputation after the current frame.
  void recompute() {
    if (_recomputeScheduled) {
      return;
    }

    _recomputeScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recomputeScheduled = false;
      _performMeasurement();
    });
  }

  /// Smoothly scrolls to the section with [id].
  Future<void> scrollTo(String id) async {
    final scrollController = _scrollController;
    if (scrollController == null || !scrollController.hasClients) {
      throw StateError(
        'SectionScrollbarController.scrollTo called before a '
        'ScrollController was attached.',
      );
    }

    if (_metrics.length != _sections.length) {
      throw StateError(
        'SectionScrollbarController.scrollTo called before section metrics '
        'were available. Ensure all SectionAnchor widgets are laid out and '
        'call recompute() if the layout changed.',
      );
    }

    SectionMetrics? metric;
    for (final entry in _metrics) {
      if (entry.id == id) {
        metric = entry;
        break;
      }
    }
    if (metric == null) {
      throw ArgumentError.value(id, 'id', 'Unknown section id.');
    }

    final position = scrollController.position;
    final probeOffset =
        probeFractionForStrategy(_config.activationStrategy) *
        position.viewportDimension;
    final target = (metric.startOffset - probeOffset).clamp(
      0.0,
      position.maxScrollExtent,
    );

    await scrollController.animateTo(
      target,
      duration: _config.scrollAnimationDuration,
      curve: _config.scrollAnimationCurve,
    );
  }

  @override
  void dispose() {
    detach();
    super.dispose();
  }

  void _performMeasurement() {
    _syncScrollPositionBinding();

    final scrollController = _scrollController;
    final viewportContext = _viewportContext;

    if (scrollController == null ||
        !scrollController.hasClients ||
        viewportContext == null ||
        !viewportContext.mounted) {
      _metrics = const [];
      _publishState(_buildState());
      return;
    }

    _metrics = measureSections(
      sections: _sections,
      anchorContexts: _anchorContexts,
      viewportContext: viewportContext,
      scrollController: scrollController,
    );
    _publishState(_buildState());
  }

  void _handleScroll() {
    _syncScrollPositionBinding();
    _publishState(_buildState());
  }

  void _handleScrollActivityChanged() {
    final nextValue = _scrollPosition?.isScrollingNotifier.value ?? false;
    if (_isScrollActive == nextValue) {
      return;
    }

    _isScrollActive = nextValue;
    _publishState(_buildState());
  }

  void _syncScrollPositionBinding() {
    final scrollController = _scrollController;
    if (scrollController == null || !scrollController.hasClients) {
      _removeScrollPositionListener();
      _isScrollActive = false;
      return;
    }

    final position = scrollController.position;
    if (_scrollPosition == position) {
      return;
    }

    _removeScrollPositionListener();
    _scrollPosition = position;
    _isScrollActive = position.isScrollingNotifier.value;
    position.isScrollingNotifier.addListener(_handleScrollActivityChanged);
  }

  void _removeScrollPositionListener() {
    _scrollPosition?.isScrollingNotifier.removeListener(
      _handleScrollActivityChanged,
    );
    _scrollPosition = null;
  }

  SectionScrollbarState _buildState() {
    final scrollController = _scrollController;
    final hasScrollMetrics =
        scrollController != null && scrollController.hasClients;
    final hasCompleteMetrics =
        _metrics.length == _sections.length && hasScrollMetrics;
    final position = hasScrollMetrics ? scrollController.position : null;
    final viewportDimension = position?.viewportDimension ?? 0.0;
    final scrollOffset = position?.pixels ?? 0.0;
    final maxScrollExtent = position?.maxScrollExtent ?? 0.0;
    final contentExtent = math.max(
      viewportDimension,
      viewportDimension + maxScrollExtent,
    );
    final probeOffset =
        scrollOffset +
        viewportDimension *
            probeFractionForStrategy(_config.activationStrategy);

    final activeMetric = hasCompleteMetrics
        ? resolveActiveMetric(
            metrics: _metrics,
            scrollOffset: scrollOffset,
            viewportDimension: viewportDimension,
            strategy: _config.activationStrategy,
          )
        : null;

    final thumbExtentFraction = contentExtent <= 0
        ? 1.0
        : (viewportDimension / contentExtent).clamp(0.0, 1.0);
    final thumbOffsetFraction = maxScrollExtent <= 0
        ? 0.0
        : (scrollOffset / maxScrollExtent).clamp(0.0, 1.0);

    final metricsById = <String, SectionMetrics>{
      for (final metric in _metrics) metric.id: metric,
    };
    final items = <SectionScrollbarVisualItem>[];

    for (final section in _sections) {
      final metric = metricsById[section.id];
      final progress = hasCompleteMetrics
          ? resolveSectionProgress(
              metrics: _metrics,
              sectionId: section.id,
              probeOffset: probeOffset,
            )
          : 0.0;
      final startFraction = contentExtent <= 0
          ? 0.0
          : ((metric?.startOffset ?? 0.0) / contentExtent).clamp(0.0, 1.0);
      final extentFraction = contentExtent <= 0
          ? 0.0
          : ((metric?.extent ?? 0.0) / contentExtent).clamp(0.0, 1.0);

      items.add(
        SectionScrollbarVisualItem(
          id: section.id,
          label: section.label,
          icon: section.icon,
          isActive: activeMetric?.id == section.id,
          startFraction: startFraction,
          extentFraction: extentFraction,
          progressWithinSection: progress,
        ),
      );
    }

    return SectionScrollbarState(
      activeSectionId: activeMetric?.id,
      items: items,
      scrollProgress: _scrollProgress(),
      activeSectionProgress: activeMetric == null
          ? 0
          : resolveSectionProgress(
              metrics: _metrics,
              sectionId: activeMetric.id,
              probeOffset: probeOffset,
            ),
      thumbOffsetFraction: thumbOffsetFraction,
      thumbExtentFraction: thumbExtentFraction,
      hasMetrics: hasCompleteMetrics,
      isScrollActive: _isScrollActive,
    );
  }

  double _scrollProgress() {
    final scrollController = _scrollController;
    if (scrollController == null || !scrollController.hasClients) {
      return 0;
    }

    final maxExtent = scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) {
      return 1;
    }

    return (scrollController.position.pixels / maxExtent).clamp(0.0, 1.0);
  }

  void _publishState(SectionScrollbarState nextState) {
    if (_state == nextState) {
      return;
    }

    _state = nextState;
    notifyListeners();
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
