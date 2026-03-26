// Long showcase copy is kept inline so the example stays self-contained.
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:section_scrollbar/section_scrollbar.dart';

void main() {
  runApp(const ExampleApp());
}

/// Example app showcasing a section-aware custom scrollbar with a floating
/// current-section badge.
class ExampleApp extends StatelessWidget {
  /// Creates the example app.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131A25)),
        scaffoldBackgroundColor: const Color(0xFFF4F1EA),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

/// Example home page with seven tracked sections.
class ExampleHomePage extends StatefulWidget {
  /// Creates the example home page.
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  final _sectionController = SectionScrollbarController();
  final _scrollController = ScrollController();

  static const _sections = <SectionData>[
    SectionData(id: 'intro', label: 'Intro', icon: Icons.waving_hand_rounded),
    SectionData(id: 'profile', label: 'Profile', icon: Icons.person_rounded),
    SectionData(id: 'work', label: 'Work', icon: Icons.work_outline_rounded),
    SectionData(id: 'process', label: 'Process', icon: Icons.tune_rounded),
    SectionData(
      id: 'metrics',
      label: 'Metrics',
      icon: Icons.query_stats_rounded,
    ),
    SectionData(id: 'notes', label: 'Notes', icon: Icons.notes_rounded),
    SectionData(
      id: 'contact',
      label: 'Contact',
      icon: Icons.mail_outline_rounded,
    ),
  ];

  @override
  void dispose() {
    _sectionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SectionScrollbarLayout(
          controller: _sectionController,
          scrollController: _scrollController,
          sections: _sections,
          config: const SectionScrollbarConfig(
            overlayWidth: 146,
          ),
          scrollbarPadding: const EdgeInsets.only(
            top: 14,
            right: 16,
            bottom: 28,
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 20, 44, 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(onJumpPressed: _sectionController.scrollTo),
                    const SectionAnchor(
                      id: 'intro',
                      child: _ShowcaseSection(
                        eyebrow: 'INTRO',
                        title:
                            'A custom scrollbar that tells you where you are.',
                        body:
                            'The scrollbar thumb behaves like a scrollbar, while a floating badge tracks the current section label and icon during scroll activity.',
                        height: 340,
                        accent: Color(0xFF1D4E89),
                      ),
                    ),
                    const SectionAnchor(
                      id: 'profile',
                      child: _ShowcaseSection(
                        eyebrow: 'PROFILE',
                        title:
                            'Add more labeled stops without turning the page into a rail.',
                        body:
                            'The example now uses more sections so the badge changes more often and the scrollbar feels closer to the portfolio-style interaction you described.',
                        height: 340,
                        accent: Color(0xFF7E5A3A),
                      ),
                    ),
                    const SectionAnchor(
                      id: 'work',
                      child: _ShowcaseSection(
                        eyebrow: 'WORK',
                        title:
                            'Keep sections and anchors, replace the segmented navigation overlay.',
                        body:
                            'Each SectionAnchor is measured after layout. The controller resolves the active section and exposes scroll progress, thumb position, and the current badge payload.',
                        height: 380,
                        accent: Color(0xFF9B4D2E),
                      ),
                    ),
                    const SectionAnchor(
                      id: 'process',
                      child: _ShowcaseSection(
                        eyebrow: 'PROCESS',
                        title:
                            'The controller stays focused on geometry, not styling.',
                        body:
                            'Anchors register build contexts, measurement utilities calculate offsets, and the widget layer only consumes the immutable state needed to render the thumb and badge.',
                        height: 320,
                        accent: Color(0xFF355C7D),
                      ),
                    ),
                    const SectionAnchor(
                      id: 'metrics',
                      child: _ShowcaseSection(
                        eyebrow: 'METRICS',
                        title:
                            'Use the controller state to drive custom effects.',
                        body:
                            'The default widget shows a rounded label pill, but the package also exposes item fractions, active section progress, and thumb geometry for custom painters and overlays.',
                        height: 300,
                        accent: Color(0xFF235347),
                      ),
                    ),
                    const SectionAnchor(
                      id: 'notes',
                      child: _ShowcaseSection(
                        eyebrow: 'NOTES',
                        title:
                            'Shorter sections make the example feel tighter and more realistic.',
                        body:
                            'With denser content, the scrollbar badge switches more frequently and better demonstrates how the API behaves on long editorial or documentation pages.',
                        height: 320,
                        accent: Color(0xFF8D5B9A),
                      ),
                    ),
                    const SectionAnchor(
                      id: 'contact',
                      child: _ShowcaseSection(
                        eyebrow: 'CONTACT',
                        title:
                            'Built for mobile, web, and desktop with pure Flutter.',
                        body:
                            'No platform channels, no native scrollbar APIs, and no external state management. The default experience is intentionally minimal and documentation-friendly.',
                        height: 360,
                        accent: Color(0xFF5A3E8C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onJumpPressed});

  final ValueChanged<String> onJumpPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'section_scrollbar',
            style: theme.textTheme.labelLarge?.copyWith(
              letterSpacing: 2,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5F6877),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Scroll to reveal the current section chip beside the thumb.',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.05,
              color: const Color(0xFF18211D),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This example keeps sections, anchors, and a controller, but the presentation is now a custom scrollbar instead of a segmented navigation rail.',
            style: theme.textTheme.titleMedium?.copyWith(
              height: 1.5,
              color: const Color(0xFF46515B),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _JumpChip(label: 'Intro', onTap: () => onJumpPressed('intro')),
              _JumpChip(
                label: 'Profile',
                onTap: () => onJumpPressed('profile'),
              ),
              _JumpChip(label: 'Work', onTap: () => onJumpPressed('work')),
              _JumpChip(
                label: 'Process',
                onTap: () => onJumpPressed('process'),
              ),
              _JumpChip(
                label: 'Metrics',
                onTap: () => onJumpPressed('metrics'),
              ),
              _JumpChip(label: 'Notes', onTap: () => onJumpPressed('notes')),
              _JumpChip(
                label: 'Contact',
                onTap: () => onJumpPressed('contact'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JumpChip extends StatelessWidget {
  const _JumpChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF18211D),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShowcaseSection extends StatelessWidget {
  const _ShowcaseSection({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.height,
    required this.accent,
  });

  final String eyebrow;
  final String title;
  final String body;
  final double height;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, accent.withValues(alpha: 0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: theme.textTheme.labelLarge?.copyWith(
              letterSpacing: 2.4,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              height: 1.08,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF18211D),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 560,
            child: Text(
              body,
              style: theme.textTheme.titleMedium?.copyWith(
                height: 1.5,
                color: const Color(0xFF33423D),
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.end,
              runAlignment: WrapAlignment.end,
              children: [
                _MetricChip(label: 'Height ${height.toStringAsFixed(0)}px'),
                const _MetricChip(label: 'Custom scrollbar'),
                const _MetricChip(label: 'Floating section chip'),
                const _MetricChip(label: 'Pure Flutter'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF18211D).withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(label),
      ),
    );
  }
}
