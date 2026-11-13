import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../models/ad.dart';
import '../../models/media.dart';
import '../../models/post.dart';
import '../../models/user.dart';
import '../../theme/app_typography.dart';
import '../../theme/sky_gradient_background.dart';
import '../POST/post_options_sheet.dart';
import '/components/ADVERTISING/ad_options_sheet.dart';
import '../nav/FloatingNavBar.dart';
import '../nav/nav_navigation4.dart';
import 'explore_post_feed_page.dart';
import 'post_preview_overlay.dart';

class ExplorePage extends StatefulWidget {
  final User currentUser;
  final ValueChanged<User> onProfileUpdated;

  const ExplorePage({
    super.key,
    required this.currentUser,
    required this.onProfileUpdated,
  });

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<FeedItem> _items = const [];
  bool _isLoading = true;

  // The query actually applied to the grid — separate from whatever is
  // currently typed, so the grid only re-filters once the person
  // submits or picks a suggestion, not on every keystroke.
  String _submittedQuery = '';

  final List<String> _recentSearches = [
    'sunset photography',
    'travel vlog',
    'minimalist design',
  ];

  static const _trendingTags = [
    '#travel', '#foodie', '#fitness', '#photography',
    '#music', '#art', '#nature', '#fashion',
  ];

  bool _navCollapsed = false;

  double get _bottomReserve => FloatingNavBar.height + FloatingNavBar.bottomMargin + 24;

  @override
  void initState() {
    super.initState();

    _searchFocusNode.addListener(_handleSearchStateChanged);
    _searchController.addListener(_handleSearchStateChanged);

    _loadExplore();
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_handleSearchStateChanged);
    _searchController.removeListener(_handleSearchStateChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleSearchStateChanged() => setState(() {});

  // ================================================================
  // DATA
  // ================================================================

  Future<void> _loadExplore() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    setState(() {
      _items = _createDevelopmentExploreData();
      _isLoading = false;
    });
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _items = _createDevelopmentExploreData();
    });
  }

  List<FeedItem> _createDevelopmentExploreData() {
    final now = DateTime.now();

    const maya = User(id: 'exp_maya', username: 'maya.frames', displayName: 'Maya', avatarUrl: 'https://i.pravatar.cc/150?img=45');
    const leo = User(id: 'exp_leo', username: 'leo.codes', displayName: 'Leo', avatarUrl: 'https://i.pravatar.cc/150?img=14');
    const zara = User(id: 'exp_zara', username: 'zara.k', displayName: 'Zara');
    const femi = User(id: 'exp_femi', username: 'femi.visuals', displayName: 'Femi', avatarUrl: 'https://i.pravatar.cc/150?img=52');
    const ola = User(id: 'exp_ola', username: 'ola.b', displayName: 'Ola', avatarUrl: 'https://i.pravatar.cc/150?img=29');

    final posts = <Post>[
      Post(
        id: 'exp_001',
        author: maya,
        type: PostType.image,
        text: 'Golden hour in the hills 🌄 #travel #nature',
        hashtags: const ['travel', 'nature'],
        media: const [Media(id: 'exp_media_001', type: MediaType.image, url: 'https://picsum.photos/600/750?random=101', aspectRatio: 0.8)],
        likeCount: 820,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Post(
        id: 'exp_002',
        author: leo,
        type: PostType.video,
        text: 'Studio session highlights 🎬',
        hashtags: const ['music'],
        media: const [Media(id: 'exp_media_002', type: MediaType.video, url: 'https://example.com/video-studio.mp4', thumbnailUrl: 'https://picsum.photos/600/600?random=102', durationMs: 24000)],
        likeCount: 1540,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      Post(
        id: 'exp_003',
        author: zara,
        type: PostType.text,
        text: "Minimalist design isn't about having less — it's about making room for what matters.",
        likeCount: 212,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      Post(
        id: 'exp_004',
        author: femi,
        type: PostType.carousel,
        text: 'Street photography walk 📸 #photography',
        hashtags: const ['photography'],
        media: const [
          Media(id: 'exp_media_004a', type: MediaType.image, url: 'https://picsum.photos/600/800?random=104', aspectRatio: 0.75),
          Media(id: 'exp_media_004b', type: MediaType.image, url: 'https://picsum.photos/600/800?random=105', aspectRatio: 0.75),
          Media(id: 'exp_media_004c', type: MediaType.image, url: 'https://picsum.photos/600/800?random=106', aspectRatio: 0.75),
        ],
        likeCount: 634,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      Post(
        id: 'exp_005',
        author: ola,
        type: PostType.image,
        text: 'Morning run 🏃 #fitness',
        hashtags: const ['fitness'],
        media: const [Media(id: 'exp_media_005', type: MediaType.image, url: 'https://picsum.photos/600/660?random=107', aspectRatio: 0.9)],
        likeCount: 391,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      Post(
        id: 'exp_006',
        author: maya,
        type: PostType.image,
        text: 'Plated this one myself 🍜 #foodie',
        hashtags: const ['foodie'],
        media: const [Media(id: 'exp_media_006', type: MediaType.image, url: 'https://picsum.photos/600/720?random=108', aspectRatio: 0.83)],
        likeCount: 275,
        createdAt: now.subtract(const Duration(hours: 7)),
      ),
      Post(
        id: 'exp_007',
        author: leo,
        type: PostType.image,
        text: 'New sneakers just dropped 👟 #fashion',
        hashtags: const ['fashion'],
        media: const [Media(id: 'exp_media_007', type: MediaType.image, url: 'https://picsum.photos/600/500?random=109', aspectRatio: 1.2)],
        likeCount: 503,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      Post(
        id: 'exp_008',
        author: zara,
        type: PostType.video,
        text: 'Quick sketch timelapse ✏️ #art',
        hashtags: const ['art'],
        media: const [Media(id: 'exp_media_008', type: MediaType.video, url: 'https://example.com/video-sketch.mp4', durationMs: 15000)],
        likeCount: 890,
        createdAt: now.subtract(const Duration(hours: 9)),
      ),
      Post(
        id: 'exp_009',
        author: femi,
        type: PostType.text,
        text: 'Three months into learning the piano and it finally sounds like music instead of noise. 🎹',
        likeCount: 156,
        createdAt: now.subtract(const Duration(hours: 10)),
      ),
      Post(
        id: 'exp_010',
        author: ola,
        type: PostType.image,
        text: 'City lights 🌃',
        media: const [Media(id: 'exp_media_010', type: MediaType.image, url: 'https://picsum.photos/600/780?random=110', aspectRatio: 0.77)],
        likeCount: 712,
        createdAt: now.subtract(const Duration(hours: 11)),
      ),
    ];

    final adOne = Ad(
      id: 'exp_ad_001',
      advertiserName: 'Lumen Audio',
      advertiserLogoUrl: 'https://i.pravatar.cc/150?img=60',
      source: AdSource.internal,
      type: AdType.image,
      media: const [Media(id: 'exp_ad_media_001', type: MediaType.image, url: 'https://picsum.photos/600/750?random=111', aspectRatio: 0.8)],
      headline: 'Sound that moves with you',
      destinationUrl: 'https://example.com/lumen-audio',
      action: AdAction.openStore,
    );

    final adTwo = Ad(
      id: 'exp_ad_002',
      advertiserName: 'Trailhead Gear',
      source: AdSource.externalApi,
      type: AdType.image,
      media: const [Media(id: 'exp_ad_media_002', type: MediaType.image, url: 'https://picsum.photos/600/600?random=112', aspectRatio: 1)],
      headline: 'Built for the long way round',
      destinationUrl: 'https://example.com/trailhead-gear',
      action: AdAction.openWebsite,
    );

    final items = <FeedItem>[];

    for (var i = 0; i < posts.length; i++) {
      items.add(FeedItem(id: posts[i].id, type: FeedItemType.post, post: posts[i]));

      if (i == 3) {
        items.add(FeedItem(id: adOne.id, type: FeedItemType.advertisement, ad: adOne));
      }
      if (i == 7) {
        items.add(FeedItem(id: adTwo.id, type: FeedItemType.advertisement, ad: adTwo));
      }
    }

    return items;
  }

  // ================================================================
  // SEARCH
  // ================================================================

  List<FeedItem> get _filteredItems {
    final query = _submittedQuery.trim().toLowerCase();
    if (query.isEmpty) return _items;
    return _items.where((item) => _matches(item, query)).toList();
  }

  bool _matches(FeedItem item, String query) {
    if (item.type == FeedItemType.post && item.post != null) {
      final post = item.post!;
      final haystack = [
        post.text ?? '',
        post.author.displayName,
        post.author.username,
        post.hashtags.join(' '),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }

    if (item.type == FeedItemType.advertisement && item.ad != null) {
      final ad = item.ad!;
      final haystack = [ad.advertiserName, ad.headline ?? '', ad.body ?? ''].join(' ').toLowerCase();
      return haystack.contains(query);
    }

    return false;
  }

  List<String> _suggestionsFor(String query) {
    final pool = <String>{
      ..._recentSearches,
      ..._trendingTags,
      for (final item in _items)
        if (item.post != null) item.post!.author.displayName,
      for (final item in _items)
        if (item.post != null) '@${item.post!.author.username}',
    };

    final matches = pool.where((term) => term.toLowerCase().contains(query)).toList()
      ..sort();

    return matches.take(8).toList();
  }

  void _handleSubmitSearch(String query) {
    final trimmed = query.trim();
    _searchFocusNode.unfocus();
    setState(() => _submittedQuery = trimmed);

    if (trimmed.isEmpty) return;

    _recentSearches.remove(trimmed);
    _recentSearches.insert(0, trimmed);
    if (_recentSearches.length > 5) {
      _recentSearches.removeRange(5, _recentSearches.length);
    }
  }

  void _handleSelectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _searchController.selection = TextSelection.collapsed(offset: suggestion.length);
    _handleSubmitSearch(suggestion);
  }

  void _handleClearSearch() {
    _searchController.clear();
    setState(() => _submittedQuery = '');
  }

  void _handleRemoveRecentSearch(String term) {
    setState(() => _recentSearches.remove(term));
  }

  // ================================================================
  // GRID / SCROLL / NAV BAR
  // ================================================================

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

  void _handleTileTap(List<FeedItem> items, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExplorePostFeedPage(items: items, initialIndex: index),
      ),
    );
  }

  void _handleTileLongPress(FeedItem item) {
    showPostPreview(context, item: item);
  }

  void _handleNavTabSelected(NavTab tab) {
    handleNavTabSelected(
      context,
      tapped: tab,
      current: NavTab.explore,
      currentUser: widget.currentUser,
      onProfileUpdated: widget.onProfileUpdated,
    );
  }

  void _handleNavExpand() {
    if (!_navCollapsed) return;
    setState(() => _navCollapsed = false);
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final showSuggestions = _searchFocusNode.hasFocus;

    return SkyGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildSearchBar(context),
                  Expanded(
                    child: showSuggestions ? _buildSuggestions() : _buildGrid(),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: FloatingNavBar.bottomMargin + bottomSafeArea,
              child: FloatingNavBar(
                currentTab: NavTab.explore,
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Explore',
          style: AppTypography.display(fontSize: 28, fontWeight: FontWeight.w700, color: contentColor),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? const Color(0xFF23262F) : Colors.white.withOpacity(0.92);
    final textColor = isDark ? const Color(0xFFF2F2F4) : const Color(0xFF111111);
    final hintColor = isDark ? const Color(0xFFA6AAB8) : const Color(0xFF888888);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: fieldColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.30 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 20, color: hintColor),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: _handleSubmitSearch,
                style: AppTypography.body(fontSize: 14, color: textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Search posts, people, tags',
                  hintStyle: AppTypography.body(fontSize: 14, color: hintColor),
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              InkWell(
                onTap: _handleClearSearch,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded, size: 18, color: hintColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? const Color(0xFFF2F2F4) : const Color(0xFF111111);
    final secondaryText = isDark ? const Color(0xFFA6AAB8) : const Color(0xFF888888);
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 4, 16, _bottomReserve),
        children: [
          if (_recentSearches.isNotEmpty) ...[
            _buildSuggestionsSectionTitle('Recent', primaryText),
            for (final term in _recentSearches)
              _buildSuggestionRow(
                icon: Icons.history_rounded,
                label: term,
                color: primaryText,
                secondaryColor: secondaryText,
                onTap: () => _handleSelectSuggestion(term),
                trailing: InkWell(
                  onTap: () => _handleRemoveRecentSearch(term),
                  borderRadius: BorderRadius.circular(12),
                  child: Icon(Icons.close_rounded, size: 16, color: secondaryText),
                ),
              ),
            const SizedBox(height: 10),
          ],
          _buildSuggestionsSectionTitle('Trending', primaryText),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in _trendingTags) _buildTagChip(tag, isDark),
            ],
          ),
        ],
      );
    }

    final matches = _suggestionsFor(query);

    if (matches.isEmpty) {
      return Center(
        child: Text(
          'No matches for "$query"',
          style: AppTypography.body(fontSize: 13, color: secondaryText),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 4, 16, _bottomReserve),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return _buildSuggestionRow(
          icon: Icons.search_rounded,
          label: matches[index],
          color: primaryText,
          secondaryColor: secondaryText,
          onTap: () => _handleSelectSuggestion(matches[index]),
        );
      },
    );
  }

  Widget _buildSuggestionsSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: AppTypography.title(fontSize: 14, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _buildSuggestionRow({
    required IconData icon,
    required String label,
    required Color color,
    required Color secondaryColor,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: secondaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body(fontSize: 14, color: color),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag, bool isDark) {
    return InkWell(
      onTap: () => _handleSelectSuggestion(tag),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF23262F) : const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tag,
          style: AppTypography.caption(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFC7CAD6) : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    if (_isLoading) {
      return _buildGridSkeleton();
    }

    final items = _filteredItems;

    if (items.isEmpty) {
      return _buildEmptyResults();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.fromLTRB(10, 8, 10, _bottomReserve),
          child: _buildMasonry(items),
        ),
      ),
    );
  }

  // Two-column staggered layout: each card keeps its own media's
  // natural aspect ratio rather than being cropped to a uniform
  // square, with a thin footer (carousel dots + "...") under each
  // image — matching the reference rather than a dense square grid.
  // Built manually (greedy shortest-column placement) instead of
  // pulling in a masonry-grid package, since the explore list here is
  // a small, fully-loaded set rather than something needing lazy
  // building.
  Widget _buildMasonry(List<FeedItem> items) {
    final left = <Widget>[];
    final right = <Widget>[];
    double leftHeight = 0;
    double rightHeight = 0;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final aspectRatio = _aspectRatioFor(item);

      final tile = Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _ExploreTile(
          item: item,
          aspectRatio: aspectRatio,
          onTap: () => _handleTileTap(items, i),
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
    if (item.type == FeedItemType.advertisement && item.ad != null) {
      final media = item.ad!.media.isNotEmpty ? item.ad!.media.first : null;
      return media?.aspectRatio ?? 0.8;
    }

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

    const leftAspects = [0.8, 1.0, 0.75];
    const rightAspects = [1.0, 0.8, 0.9];

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(10, 8, 10, _bottomReserve),
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

  Widget _buildEmptyResults() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? const Color(0xFFA6AAB8) : const Color(0xFF888888);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 38, color: secondaryText),
            const SizedBox(height: 10),
            Text(
              'No results for "$_submittedQuery"',
              textAlign: TextAlign.center,
              style: AppTypography.body(fontSize: 14, color: secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// GRID TILE
// ================================================================

class _ExploreTile extends StatelessWidget {
  final FeedItem item;
  final double aspectRatio;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ExploreTile({
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
    // Same border/shadow tokens PostCard and AdPostCard use, just
    // scaled down for a grid tile instead of a full-width card.
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
              boxShadow: [
                BoxShadow(color: shadowColor, blurRadius: 12, offset: const Offset(0, 6)),
              ],
            ),
            child: ClipRRect(
              // 1px smaller than the Container's radius so the clip
              // sits just inside the border stroke instead of over it.
              borderRadius: BorderRadius.circular(15),
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: _buildContent(),
              ),
            ),
          ),
        ),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildContent() {
    if (item.type == FeedItemType.advertisement && item.ad != null) {
      return _AdTile(ad: item.ad!);
    }

    final post = item.post;
    if (post == null) return Container(color: const Color(0xFFECECEC));

    if (!post.hasMedia) {
      return _TextTile(post: post);
    }

    final media = post.media.first;

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildMediaImage(media),
        if (post.isVideo) _buildCornerBadge(Icons.play_arrow_rounded),
      ],
    );
  }

  Widget _buildMediaImage(Media media) {
    final url = media.thumbnailUrl ?? media.optimizedUrl ?? media.url;

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFECECEC)),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(color: const Color(0xFFEFEFEF));
      },
    );
  }

  Widget _buildCornerBadge(IconData icon, {double size = 16}) {
    return Positioned(
      top: 6,
      right: 6,
      child: Icon(
        icon,
        size: size,
        color: Colors.white,
        shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
      ),
    );
  }

  // Thin strip under the card: carousel position dots on the left
  // (when there's more than one image) and the "..." overflow menu on
  // the right — reusing the same options sheets the home feed uses,
  // rather than building a separate explore-specific one. Colors
  // follow the sky background's current phase, same as the page
  // header, since this footer sits directly on the gradient rather
  // than on a card surface of its own.
  Widget _buildFooter(BuildContext context) {
    final palette = SkyGradientBackground.paletteOf(context);
    final isDarkSurface = palette.contentBrightness == Brightness.dark;
    final iconColor = isDarkSurface ? Colors.white : const Color(0xFF151515);
    final dotColor = isDarkSurface ? Colors.white : const Color(0xFF151515);
    final dotMutedColor = isDarkSurface ? Colors.white30 : Colors.black26;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          if (_mediaCount > 1) _buildDots(_mediaCount, dotColor, dotMutedColor),
          const Spacer(),
          _buildOptionsButton(context, iconColor),
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == 0 ? activeColor : mutedColor,
          ),
        );
      }),
    );
  }

  Widget _buildOptionsButton(BuildContext context, Color color) {
    return Semantics(
      button: true,
      label: 'More options',
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _handleOptionsTap(context),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(Icons.more_horiz_rounded, size: 18, color: color),
        ),
      ),
    );
  }

  void _handleOptionsTap(BuildContext context) {
    if (item.type == FeedItemType.advertisement && item.ad != null) {
      showAdOptionsSheet(context, ad: item.ad!);
      return;
    }

    final post = item.post;
    if (post != null) {
      showPostOptionsSheet(context, post: post);
    }
  }
}

class _TextTile extends StatelessWidget {
  final Post post;

  const _TextTile({required this.post});

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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdTile extends StatelessWidget {
  final Ad ad;

  const _AdTile({required this.ad});

  @override
  Widget build(BuildContext context) {
    final media = ad.media.isNotEmpty ? ad.media.first : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        media != null
            ? Image.network(
                media.thumbnailUrl ?? media.optimizedUrl ?? media.url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFECECEC)),
              )
            : Container(color: const Color(0xFFECECEC)),
        Positioned(
          left: 6,
          top: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Ad',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
