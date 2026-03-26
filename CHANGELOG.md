# Changelog

## 0.1.1

- Added an optimized demo GIF for pub.dev package screenshots and README preview.
- Improved package presentation metadata for pub.dev.

## 0.1.0+1

- Initial public release of `section_scrollbar`.
- Added a section-aware custom scrollbar with a floating current-section badge.
- Included `SectionScrollbarController`, `SectionScrollbarLayout`,
  `SectionAnchor`, and the default scrollbar implementation.
- Added a configurable activation strategy and immutable scrollbar state model.
- Added an example app demonstrating multiple sections, shorter stacked
  sections, and controller-driven scrolling.
- Fixed active-section resolution so the last section becomes active when the
  viewport reaches the bottom of the content.
- Renamed the public package surface from the earlier rail-oriented API to the
  scrollbar-focused `section_scrollbar` package API.
- Expanded the README with installation, usage, feature overview, demo, and
  customization documentation.
- Added package metadata for the repository and screenshot preview on pub.dev.
- Added tests for activation logic and controller behavior.
