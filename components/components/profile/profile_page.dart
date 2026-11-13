import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../models/media.dart';
import '../../../../models/post.dart';
import '../../../../models/user.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/sky_gradient_background.dart';
import '../../../../components/POST/post_options_sheet.dart';
import '../../../../components/common/Avatar.dart';
import '../explore/explore_post_feed_page.dart';
import '../explore/post_preview_overlay.dart';
import '../nav/FloatingNavBar.dart';
import '../nav/nav_navigation.dart';
import '../settings/settings_page.dart';
import 'edit_profile_sheet.dart';

class ProfilePage extends StatefulWidget {
  final User currentUser;
  final ValueChanged<User> onProfileUpdated;

  const ProfilePage({
    super.key,
    required this.currentUser,
    required this.onProfileUpdated,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User _user;
  List<FeedItem> _posts = const [];
  bool _isLoading = true;
  bool _navCollapsed = false;

  double get _bottomReserve => FloatingNavBar.height + FloatingNavBar.bottomMargin + 24;

  @override
  void initState() {
    super.initState();
    _user = widget.currentUser;
    _loadPosts();
  }

  // ================================================================
  // DATA
  // ================================================================

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    setState(() {
      _posts = _createDevelopmentMyPosts();
      _isLoading = false;
    });
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _posts = _createDevelopmentMyPosts();
    });
  }

  List<FeedItem> _createDevelopmentMyPosts() {
    final now = DateTime.now();
    final author = _user;

    final posts = <Post>[
      Post(
        id: 'me_001',
        author: author,
        type: PostType.image,
        text: 'New setup, who dis 🖥️ #desksetup',
        hashtags: const ['desksetup'],
        media: const [Media(id: 'me_media_001', type: MediaType.image, url: 'https://picsum.photos/600/750?random=201', aspectRatio: 0.8)],
        likeCount: 342,
        commentCount: 28,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Post(
        id: 'me_002',
        author: author,
        type: PostType.carousel,
        text: 'Weekend recap 📸',
        media: const [
          Media(id: 'me_media_002a', type: MediaType.image, url: 'https://picsum.photos/600/800?random=202', aspectRatio: 0.75),
          Media(id: 'me_media_002b', type: MediaType.image, url: 'https://picsum.photos/600/800?random=203', aspectRatio: 0.75),
        ],
        likeCount: 198,
        commentCount: 14,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Post(
        id: 'me_003',
        author: author,
        type: PostType.text,
        text: 'Three features shipped this week. Feeling good about where this is headed.',
        likeCount: 87,
        commentCount: 9,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Post(
        id: 'me_004',
        author: author,
        type: PostType.image,
        text: 'Coffee first ☕',
        media: const [Media(id: 'me_media_004', type: MediaType.image, url: 'https://picsum.photos/600/660?random=204', aspectRatio: 0.9)],
        likeCount: 256,
        commentCount: 11,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Post(
        id: 'me_005',
        author: author,
        type: PostType.video,
        text: 'Quick demo of the new build 🎬',
        media: const [Media(id: 'me_media_005', type: MediaType.video, url: 'https://example.com/video-demo.mp4', thumbnailUrl: 'https://picsum.photos/600/750?random=205', durationMs: 20000)],
        likeCount: 410,
        commentCount: 33,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Post(
        id: 'me_006',
        author: author,
        type: PostType.image,
        text: 'Golden hour from the balcony 🌇',
        media: const [Media(id: 'me_media_006', type: MediaType.image, url: 'https://picsum.photos/600/780?random=206', aspectRatio: 0.77)],
        likeCount: 301,
        commentCount: 19,
        createdAt: now.subtract(const Duration(days: 6)),
      ),
    ];

    return posts.map((post) => FeedItem(id: post.id, type: FeedItemType.post, post: post)).toList();
  }

  // ================================================================
  // ACTIONS
  // ================================================================

  void _handleEditProfile() {
    showEditProfileSheet(
      context,
      user: _user,
      onSave: (updated) {
        setState(() {
          _user = updated;
          // Regenerate so existing posts' embedded author reflects the
          // edit immediately, instead of showing the old name until
          // the next pull-to-refresh.
          _posts = _createDevelopmentMyPosts();
        });
        widget.onProfileUpdated(updated);
      },
    );
  }

  void _handleSharePlaceholder() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text("Sharing your profile isn't available yet."),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }

  void _handleSettingsTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          user: _user,
          onUserUpdated: (updated) {
            setState(() {
              _user = updated;
              _posts = _createDevelopmentMyPosts();
            });
            widget.onProfileUpdated(updated);
          },
        ),
      ),
    );
  }

  void _handleNavTabSelected(NavTab tab) {
    handleNavTabSelected(
      context,
      tapped: tab,
      current: NavTab.profile,
      currentUser: _user,
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

  void _handleTileTap(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExplorePostFeedPage(items: _posts, initialIndex: index),
      ),
    );
  }

  void _handleTileLongPress(FeedItem item) {
    showPostPreview(context, item: item);
  }

  // ================================================================
  // BUILD
  // ================================================================

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
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader(context)),
                      SliverToBoxAdapter(child: _buildProfileSummary(context)),
                      SliverToBoxAdapter(child: _buildPostsGrid()),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: FloatingNavBar.bottomMargin + bottomSafeArea,
              child: FloatingNavBar(
                currentTab: NavTab.profile,
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
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '@${_user.username}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title(fontSize: 20, fontWeight: FontWeight.w700, color: contentColor),
            ),
          ),
          Semantics(
            button: true,
            label: 'Settings',
            child: InkWell(
              onTap: _handleSettingsTap,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.settings_outlined, size: 24, color: contentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1F27).withOpacity(0.82) : Colors.white.withOpacity(0.90);
    final primaryText = isDark ? const Color(0xFFF2F2F4) : const Color(0xFF111111);
    final secondaryText = isDark ? const Color(0xFFA6AAB8) : const Color(0xFF777777);
    final borderColor = isDark ? const Color(0xFF33384A) : const Color(0xFFE0E0E0);

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.40 : 0.08), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(user: _user, size: 76, showVerificationBadge: false),
              const SizedBox(width: 18),
              Expanded(
                child: Row(
                  children: [
                    _buildStat('Posts', _posts.length, primaryText, secondaryText),
                    _buildStat('Followers', _user.followerCount, primaryText, secondaryText),
                    _buildStat('Following', _user.followingCount, primaryText, secondaryText),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Flexible(
                child: Text(
                  _user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(fontSize: 17, fontWeight: FontWeight.w700, color: primaryText),
                ),
              ),
              if (_user.isVerified) ...[
                const SizedBox(width: 5),
                const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF287BEA)),
              ],
            ],
          ),
          if (_user.bio != null && _user.bio!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(_user.bio!, style: AppTypography.body(fontSize: 13.5, color: primaryText)),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: _handleEditProfile,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Edit Profile', style: AppTypography.body(fontSize: 13, fontWeight: FontWeight.w600, color: primaryText)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 36,
                width: 44,
                child: OutlinedButton(
                  onPressed: _handleSharePlaceholder,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Icon(Icons.ios_share_rounded, size: 16, color: primaryText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int count, Color primary, Color secondary) {
    return Expanded(
      child: Column(
        children: [
          Text(_formatCount(count), style: AppTypography.title(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption(fontSize: 12, color: secondary)),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  // ================================================================
  // POSTS GRID
  //
  // Same staggered two-column card treatment as the Explore grid
  // (border + shadow + dots/options footer), reimplemented here rather
  // than shared — this page only ever shows posts (no ads), and the
  // rest of the app keeps these small per-page tile widgets separate
  // rather than factored into a shared component.
  // ================================================================

  Widget _buildPostsGrid() {
    if (_isLoading) {
      return _buildGridSkeleton();
    }

    if (_posts.isEmpty) {
      return _buildEmptyPosts();
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, _bottomReserve),
      child: _buildMasonry(),
    );
  }

  Widget _buildMasonry() {
    final left = <Widget>[];
    final right = <Widget>[];
    double leftHeight = 0;
    double rightHeight = 0;

    for (var i = 0; i < _posts.length; i++) {
      final item = _posts[i];
      final aspectRatio = _aspectRatioFor(item);

      final tile = Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _ProfileTile(
          item: item,
          aspectRatio: aspectRatio,
          onTap: () => _handleTileTap(i),
          onLongPress: () => _handleTileLongPress(item),
        ),
      );

      if (leftHeight <= rightHeight) {
        left.add(tile);
        leftHeight += 1 / aspectRatio;
      } else {
        right.add(tile);
        rightHeight += 1 / aspectRatio;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Column(children: left)),
        const SizedBox(width: 10),
        Expanded(child: Column(children: right)),
      ],
    );
  }

  double _aspectRatioFor(FeedItem item) {
    final post = item.post;
    if (post == null) return 0.8;
    if (!post.hasMedia) return 1;
    return post.media.first.aspectRatio ?? 0.8;
  }

  Widget _buildGridSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final block = isDark ? const Color(0xFF2B2F3A) : const Color(0xFFE8E8E8);

    Widget skeletonTile(double aspectRatio) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(aspectRatio: aspectRatio, child: Container(color: block)),
        ),
      );
    }

    const leftAspects = [0.8, 1.0];
    const rightAspects = [1.0, 0.8];

    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, _bottomReserve),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: [for (final a in leftAspects) skeletonTile(a)])),
          const SizedBox(width: 10),
          Expanded(child: Column(children: [for (final a in rightAspects) skeletonTile(a)])),
        ],
      ),
    );
  }

  Widget _buildEmptyPosts() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? const Color(0xFFA6AAB8) : const Color(0xFF888888);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grid_view_rounded, size: 34, color: secondaryText),
            const SizedBox(height: 10),
            Text("You haven't posted anything yet.", style: AppTypography.body(fontSize: 14, color: secondaryText)),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final FeedItem item;
  final double aspectRatio;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ProfileTile({
    required this.item,
    required this.aspectRatio,
    required this.onTap,
    required this.onLongPress,
  });

  int get _mediaCount {
    final post = item.post;
    if (post != null && post.isCarousel) return post.media.length;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF33384A) : const Color(0xFFEDEDED);
    final shadowColor = Colors.black.withOpacity(isDark ? 0.35 : 0.08);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [BoxShadow(color: shadowColor, blurRadius: 12, offset: const Offset(0, 6))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: AspectRatio(aspectRatio: aspectRatio, child: _buildContent()),
            ),
          ),
        ),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildContent() {
    final post = item.post;
    if (post == null) return Container(color: const Color(0xFFECECEC));
    if (!post.hasMedia) return _ProfileTextTile(post: post);

    final media = post.media.first;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          media.thumbnailUrl ?? media.optimizedUrl ?? media.url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFECECEC)),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(color: const Color(0xFFEFEFEF));
          },
        ),
        if (post.isVideo)
          const Positioned(
            top: 6,
            right: 6,
            child: Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
          ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final palette = SkyGradientBackground.paletteOf(context);
    final isDarkSurface = palette.contentBrightness == Brightness.dark;
    final iconColor = isDarkSurface ? Colors.white : const Color(0xFF151515);
    final dotMutedColor = isDarkSurface ? Colors.white30 : Colors.black26;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          if (_mediaCount > 1) _buildDots(_mediaCount, iconColor, dotMutedColor),
          const Spacer(),
          Semantics(
            button: true,
            label: 'More options',
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                final post = item.post;
                if (post != null) showPostOptionsSheet(context, post: post);
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.more_horiz_rounded, size: 18, color: iconColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots(int count, Color activeColor, Color mutedColor) {
    final shown = count > 6 ? 6 : count;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(shown, (index) {
        return Container(
          margin: const EdgeInsets.only(right: 4),
          width: 5,
          height: 5,
          decoration: BoxDecoration(shape: BoxShape.circle, color: index == 0 ? activeColor : mutedColor),
        );
      }),
    );
  }
}

class _ProfileTextTile extends StatelessWidget {
  final Post post;

  const _ProfileTextTile({required this.post});

  static const _palette = [
    Color(0xFF6C5CE7),
    Color(0xFFE17055),
    Color(0xFF00B894),
    Color(0xFF0984E3),
    Color(0xFFE84393),
    Color(0xFFD63031),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _palette[post.id.hashCode.abs() % _palette.length];

    return Container(
      color: color,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.format_quote_rounded, color: Colors.white70, size: 18),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              post.text ?? '',
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
