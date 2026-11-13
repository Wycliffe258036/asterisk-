import 'dart:math' as math;

import 'package:flutter/material.dart';

enum NavTab {
  home,
  explore,
  studio,
  profile,
}

extension NavTabX on NavTab {
  String get label {
    switch (this) {
      case NavTab.home:
        return 'Home';
      case NavTab.explore:
        return 'Explore';
      case NavTab.studio:
        return 'Studio';
      case NavTab.profile:
        return 'Profile';
    }
  }

  IconData get icon {
    switch (this) {
      case NavTab.home:
        return Icons.home_outlined;
      case NavTab.explore:
        return Icons.explore_outlined;
      case NavTab.studio:
        return Icons.movie_creation_outlined;
      case NavTab.profile:
        return Icons.person_outline_rounded;
    }
  }

  IconData get activeIcon {
    switch (this) {
      case NavTab.home:
        return Icons.home_rounded;
      case NavTab.explore:
        return Icons.explore_rounded;
      case NavTab.studio:
        return Icons.movie_creation_rounded;
      case NavTab.profile:
        return Icons.person_rounded;
    }
  }
}

/// A floating, pill-shaped navigation bar (home / explore / studio /
/// profile) that shares PostCard's surface styling — same translucent
/// card color, shadow, and light/dark tokens — so it reads as part of
/// the same family floating over the sky background.
///
/// When [collapsed] is true, the pill shrinks into a round ball on the
/// left edge showing a right-pointing arrow; tapping it calls
/// [onExpand]. The bar is fully controlled: the parent decides *when*
/// to collapse (e.g. on scroll) and this widget just animates between
/// the two states.
///
/// Place it in a Stack with left/right padding equal to the feed's
/// card margin (14) so the ball lines up with the cards' left edge.
class FloatingNavBar extends StatelessWidget {
  /// Height of the expanded pill.
  static const double height = 64;

  /// Diameter of the collapsed ball.
  static const double collapsedSize = 56;

  /// Suggested gap between the bar and the bottom safe area. Exposed
  /// so callers can reserve matching space at the end of the feed.
  static const double bottomMargin = 16;

  // 4 items x 64 + 8px padding on each side.
  static const double _idealWidth = 272;

  static const Duration _duration = Duration(milliseconds: 320);
  static const Duration _fadeDuration = Duration(milliseconds: 180);
  static const Curve _curve = Curves.easeInOutCubic;

  final NavTab currentTab;
  final bool collapsed;
  final ValueChanged<NavTab>? onTabSelected;

  /// Fired when the collapsed ball is tapped.
  final VoidCallback? onExpand;

  const FloatingNavBar({
    super.key,
    this.currentTab = NavTab.home,
    this.collapsed = false,
    this.onTabSelected,
    this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _NavColors.of(isDark);

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final expandedWidth = math.min(constraints.maxWidth, _idealWidth);

          // AnimatedAlign moves the shape between center and left edge
          // while AnimatedContainer morphs its size, on the same
          // duration/curve, so the pill visibly "folds" into the ball.
          return AnimatedAlign(
            duration: _duration,
            curve: _curve,
            alignment: collapsed ? Alignment.centerLeft : Alignment.center,
            child: AnimatedContainer(
              duration: _duration,
              curve: _curve,
              width: collapsed ? collapsedSize : expandedWidth,
              height: collapsed ? collapsedSize : height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    // Same plain BoxShadow as PostCard — no BackdropFilter.
                    color: Colors.black.withOpacity(isDark ? 0.40 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildExpandedLayer(colors, expandedWidth),
                    _buildCollapsedLayer(colors),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandedLayer(_NavColors colors, double expandedWidth) {
    return ExcludeSemantics(
      excluding: collapsed,
      child: IgnorePointer(
        ignoring: collapsed,
        child: AnimatedOpacity(
          duration: _fadeDuration,
          opacity: collapsed ? 0 : 1,
          // The row always lays out at full width and is simply
          // clipped by the shrinking container, so the icons never
          // squash or overflow mid-animation.
          child: OverflowBox(
            minWidth: expandedWidth,
            maxWidth: expandedWidth,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  for (final tab in NavTab.values)
                    Expanded(
                      child: _NavItem(
                        tab: tab,
                        selected: tab == currentTab,
                        colors: colors,
                        onTap: () => onTabSelected?.call(tab),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedLayer(_NavColors colors) {
    return ExcludeSemantics(
      excluding: !collapsed,
      child: IgnorePointer(
        ignoring: !collapsed,
        child: AnimatedOpacity(
          duration: _fadeDuration,
          opacity: collapsed ? 1 : 0,
          child: Semantics(
            button: true,
            label: 'Show navigation',
            child: InkWell(
              onTap: onExpand,
              customBorder: const CircleBorder(),
              child: Center(
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: colors.primaryText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final NavTab tab;
  final bool selected;
  final _NavColors colors;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      child: Center(
        // The Material *is* the highlight capsule, so the ink splash
        // paints on top of it instead of being hidden underneath. Its
        // color change animates implicitly.
        child: Material(
          color: selected ? colors.selectedFill : Colors.transparent,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 52,
              height: 40,
              child: Center(
                child: Icon(
                  selected ? tab.activeIcon : tab.icon,
                  size: 24,
                  color: selected ? colors.primaryText : colors.mutedIcon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// COLOR TOKENS
//
// Deliberately the same values as PostCard's private palette
// (card opacity 0.90 light / 0.82 dark, same text/icon colors) so the
// bar and the cards stay visually in sync.
// ================================================================

class _NavColors {
  final Color card;
  final Color primaryText;
  final Color mutedIcon;
  final Color selectedFill;

  const _NavColors({
    required this.card,
    required this.primaryText,
    required this.mutedIcon,
    required this.selectedFill,
  });

  static _NavColors of(bool isDark) {
    if (isDark) {
      return _NavColors(
        card: const Color(0xFF1C1F27).withOpacity(0.82),
        primaryText: const Color(0xFFF2F2F4),
        mutedIcon: const Color(0xFFC7CAD6),
        selectedFill: Colors.white.withOpacity(0.10),
      );
    }

    return _NavColors(
      card: Colors.white.withOpacity(0.90),
      primaryText: const Color(0xFF111111),
      mutedIcon: const Color(0xFF555555),
      selectedFill: const Color(0xFF111111).withOpacity(0.07),
    );
  }
}
