## Demo

![section_scrollbar demo](assets/demo.gif)

```md
[Watch the full demo video](https://pub-327a9256807e43b5ae26f24376d313e1.r2.dev/section_scrollbar_demo.mp4)
```

# section_scrollbar

[![pub package](https://img.shields.io/pub/v/section_scrollbar.svg)](https://pub.dev/packages/section_scrollbar)

`section_scrollbar` is a pure Flutter package for building a section-aware
custom scrollbar that shows a floating badge for the current section while the
user scrolls.

It is not a platform scrollbar skin. The package measures your declared
sections, tracks the active one with a configurable viewport probe, and overlays
its own thumb + current-section chip on top of a normal `SingleChildScrollView`.

## Why this package exists

Long portfolio, documentation, and editorial pages often need more context than
a plain thumb can provide. A normal scrollbar tells the user where they are in
the document, but not *what* they are looking at.

`section_scrollbar` keeps the familiar scrollbar interaction model and adds a
lightweight, rounded badge containing:

- the active section label
- the active section icon, if provided
- a stable section-aware controller API you can use for custom UI

## Features

- Section definitions with ids, labels, and optional icons
- Explicit section anchors for accurate layout measurement
- Active-section detection with configurable probe strategies
- Right-side custom scrollbar overlay for `SingleChildScrollView`
- Floating badge that appears while scrolling
- `scrollTo(id)` and `recompute()` on a `ChangeNotifier` controller
- Immutable public state for custom builders and advanced effects
- Pure Flutter implementation for mobile, web, and desktop





## Installation

```sh
flutter pub add section_scrollbar
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:section_scrollbar/section_scrollbar.dart';

final sectionController = SectionScrollbarController();
final scrollController = ScrollController();

SectionScrollbarLayout(
  controller: sectionController,
  scrollController: scrollController,
  sections: const [
    SectionData(
      id: 'intro',
      label: 'Intro',
      icon: Icons.waving_hand_rounded,
    ),
    SectionData(
      id: 'work',
      label: 'Work',
      icon: Icons.work_outline_rounded,
    ),
    SectionData(
      id: 'metrics',
      label: 'Metrics',
      icon: Icons.query_stats_rounded,
    ),
    SectionData(
      id: 'contact',
      label: 'Contact',
      icon: Icons.mail_outline_rounded,
    ),
  ],
  config: const SectionScrollbarConfig(
    activationStrategy: SectionActivationStrategy.quarterViewport,
  ),
  child: SingleChildScrollView(
    controller: scrollController,
    child: Column(
      children: const [
        SectionAnchor(id: 'intro', child: IntroSection()),
        SectionAnchor(id: 'work', child: WorkSection()),
        SectionAnchor(id: 'metrics', child: MetricsSection()),
        SectionAnchor(id: 'contact', child: ContactSection()),
      ],
    ),
  ),
);
```

## How it works

1. Define your sections with `SectionData`.
2. Wrap each real content section with `SectionAnchor`.
3. Place everything inside `SectionScrollbarLayout`.
4. The controller measures anchors after layout.
5. On scroll, the controller resolves the active section and computes:
   - page progress
   - progress within the active section
   - thumb size
   - thumb offset
   - active badge payload
6. The default scrollbar renders a subtle track, a thumb, and a floating badge
   while scrolling.

## Public API

### `SectionData`
Declares a logical section.

Fields:
- `id`
- `label`
- `icon`
- `weight`

### `SectionAnchor`
Wraps each measured content section and registers it with the nearest
`SectionScrollbarLayout`.

### `SectionScrollbarController`
The main `ChangeNotifier` that owns:

- section registration
- metric recomputation
- active-section detection
- `scrollTo(id)`
- immutable `state`

### `SectionScrollbarConfig`
Controls behavior and default layout values.

Key fields:
- `activationStrategy`
- `scrollAnimationDuration`
- `scrollAnimationCurve`
- `overlayWidth`
- `trackThickness`
- `thumbThickness`
- `minThumbExtent`
- `badgeSpacing`
- `visibilityAnimationDuration`
- `alwaysShowScrollbar`

### `SectionScrollbarState`
Immutable derived state exposed by the controller.

Key fields:
- `activeSectionId`
- `activeSectionLabel`
- `activeSectionIcon`
- `items`
- `scrollProgress`
- `activeSectionProgress`
- `thumbOffsetFraction`
- `thumbExtentFraction`
- `hasMetrics`
- `isScrollActive`

### `SectionScrollbarVisualItem`
Per-section render data for custom overlays and builders.

### `SectionScrollbarLayout`
Wraps your scroll view and places the overlay scrollbar on top of it.

### `SectionScrollbar`
Generic scrollbar shell for custom track/thumb/badge builders.

### `DefaultSectionScrollbar`
Default implementation that renders:

- a subtle vertical track
- a rounded thumb
- a rounded floating badge containing the active section metadata

## Customization

You can customize at two levels:

### 1. Config-only customization
Use `SectionScrollbarConfig` when you only want to tune sizing, animation, or
visibility behavior.

### 2. Full overlay customization
Pass `scrollbarBuilder` to `SectionScrollbarLayout` and render your own overlay
from the controller state.

The `SectionScrollbarState.items` list gives you section-level fractions and
progress values so you can build custom markers, painters, or richer badges.

## Example

The example app in `example/lib/main.dart` demonstrates:

- four tracked sections
- the default floating badge behavior
- controller-driven `scrollTo`
- varying section heights

## Limitations in v1

- Vertical scrolling only
- Designed for one main `ScrollController`
- Supports `SingleChildScrollView`, not slivers or nested scroll views
- The default scrollbar is passive; thumb dragging is not implemented in v1
- Requires explicit `SectionAnchor` widgets for measured sections

## Roadmap

- Interactive thumb dragging
- Sliver support
- Nested scroll coordination
- Horizontal mode
- Accessibility improvements for keyboard and semantics
- More default badge and thumb styles
