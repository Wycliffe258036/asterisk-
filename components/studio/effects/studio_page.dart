import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '/../models/user.dart';
import '/../theme/app_typography.dart';
import '/../theme/sky_gradient_background.dart';
import '/components/nav/FloatingNavBar.dart';
import '../../nav/nav_navigation.dart';
import 'editor_page.dart';
import 'effects_page.dart';

/// Studio's landing page: two separate creative tools (Effects, a
/// real-time AI camera-effects browser; Editor, a traditional/AI photo
/// and video editor), picked one at a time rather than combined into
/// a single screen — they have genuinely different shapes (camera +
/// tracking vs. timeline + layers).
class StudioPage extends StatefulWidget {
  final User currentUser;
  final ValueChanged<User> onProfileUpdated;

  const StudioPage({
    super.key,
    required this.currentUser,
    required this.onProfileUpdated,
  });

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  bool _navCollapsed = false;

  void _handleNavTabSelected(NavTab tab) {
    handleNavTabSelected(
      context,
      tapped: tab,
      current: NavTab.studio,
      currentUser: widget.currentUser,
      onProfileUpdated: widget.onProfileUpdated,
    );
  }

  void _handleNavExpand() {
    if (!_navCollapsed) return;
    setState(() => _navCollapsed = false);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }

    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse) {
        if (!_navCollapsed) setState(() => _navCollapsed = true);
      } else if (notification.direction == ScrollDirection.forward) {
        if (_navCollapsed) setState(() => _navCollapsed = false);
      }
    }

    return false;
  }

  void _openEffects() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EffectsPage()),
    );
  }

  void _openEditor() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EditorPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return SkyGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    FloatingNavBar.height + FloatingNavBar.bottomMargin + 24,
                  ),
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 6),
                    _buildIntro(context),
                    const SizedBox(height: 22),
                    _StudioEntryCard(
                      icon: Icons.auto_awesome_rounded,
                      iconBackground: const Color(0xFFCB4CFF),
                      title: 'Effects',
                      description: 'Open your camera and try on real-time, face-tracked effects.',
                      badge: 'New',
                      onTap: _openEffects,
                    ),
                    const SizedBox(height: 14),
                    _StudioEntryCard(
                      icon: Icons.movie_creation_rounded,
                      iconBackground: const Color(0xFF287BEA),
                      title: 'Editor',
                      description: 'Trim, color, caption and layer your photos and videos with an AI co-pilot.',
                      onTap: _openEditor,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: FloatingNavBar.bottomMargin + bottomSafeArea,
              child: FloatingNavBar(
                currentTab: NavTab.studio,
                collapsed: _navCollapsed,
                onTabSelected: _handleNavTabSelected,
                onExpand: _handleNavExpand,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final palette = SkyGradientBackground.paletteOf(context);
    final isDarkSurface = palette.contentBrightness == Brightness.dark;
    final contentColor = isDarkSurface ? Colors.white : const Color(0xFF151515);

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        'Studio',
        style: AppTypography.display(fontSize: 28, fontWeight: FontWeight.w700, color: contentColor),
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    final palette = SkyGradientBackground.paletteOf(context);
    final isDarkSurface = palette.contentBrightness == Brightness.dark;
    final contentColor = isDarkSurface ? Colors.white70 : const Color(0xFF444444);

    return Text(
      'Two ways to create — pick one to get started.',
      style: AppTypography.body(fontSize: 14, color: contentColor),
    );
  }
}

class _StudioEntryCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final String title;
  final String description;
  final String? badge;
  final VoidCallback onTap;

  const _StudioEntryCard({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.description,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1F27).withOpacity(0.82) : Colors.white.withOpacity(0.90);
    final primaryText = isDark ? const Color(0xFFF2F2F4) : const Color(0xFF111111);
    final secondaryText = isDark ? const Color(0xFFA6AAB8) : const Color(0xFF777777);

    return Container(
      // clipBehavior only clips the child (the ink response below), not
      // this decoration's own boxShadow — so the card keeps its soft
      // drop shadow while the ripple still respects the rounded corners.
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.40 : 0.08), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: AppTypography.title(fontSize: 17, fontWeight: FontWeight.w700, color: primaryText),
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            _buildBadge(badge!),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(description, style: AppTypography.body(fontSize: 13, color: secondaryText)),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: secondaryText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFF32CD72), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
