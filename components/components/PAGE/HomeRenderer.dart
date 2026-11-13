import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../models/ad.dart';
import '../../../../models/home_data.dart';
import '../../../../models/home_state.dart';
import '../../../../models/post.dart';
import '../../../../models/story.dart';
import '../../../../models/user.dart';
import '../../../../theme/app_typography.dart';
import '../ads/AdPostCard.dart';
import '../../../../components/header/home_header.dart';
import '../POST/PostCard.dart';
import '../../../../components/STATES/post_skeleton.dart';
import '../../../../components/stories/stories_row_skeleton.dart';
import '../stories/story_row.dart';
import '../suggestions/SuggestedUserRow.dart';

class HomeRenderer extends StatelessWidget {
  final HomeState state;
  final Future<void> Function()? onRefresh;
  final ValueChanged<Story>? onStoryTap;
  final VoidCallback? onCreateStoryTap;
  final ValueChanged<String>? onPostLike;
  final ValueChanged<String>? onPostSave;
  final ValueChanged<User>? onPostAuthorTap;

  /// Fired when the header's grid/menu button is tapped.
  final VoidCallback? onMenuPressed;

  /// Fired when the header's notification bell is tapped.
  final VoidCallback? onNotificationPressed;

  /// Fired when an ad's media, copy, or CTA button is tapped.
  final ValueChanged<Ad>? onAdTap;

  /// Fired when a card in the "Suggested for you" shelf is tapped.
  final ValueChanged<User>? onSuggestedUserTap;

  /// Fired when a suggested user's Follow/Following button is tapped.
  final ValueChanged<User>? onFollowToggle;

  /// Fired when the "Suggested for you" shelf's close button is tapped.
  final VoidCallback? onDismissSuggestions;

  /// Fired when the feed is scrolled near its end, so the caller can
  /// fetch and append the next page. The caller is responsible for
  /// guarding against duplicate calls (e.g. while already loading, or
  /// once pagination reports no more pages) — this widget just reports
  /// proximity to the bottom.
  final VoidCallback? onLoadMore;

  /// Fired when the user drags the feed down (collapse the floating
  /// nav bar) or up (expand it). Only reacts to the feed's own
  /// vertical scroll, not nested horizontal scrollers.
  final ValueChanged<bool>? onCollapseNavChanged;

  /// Extra space reserved after the last feed item, e.g. so a floating
  /// nav bar layered over the feed never covers the final post.
  final double bottomPadding;

  const HomeRenderer({
    super.key,
    required this.state,
    this.onRefresh,
    this.onStoryTap,
    this.onCreateStoryTap,
    this.onPostLike,
    this.onPostSave,
    this.onPostAuthorTap,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.onAdTap,
    this.onSuggestedUserTap,
    this.onFollowToggle,
    this.onDismissSuggestions,
    this.onLoadMore,
    this.onCollapseNavChanged,
    this.bottomPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: RefreshIndicator(
          onRefresh: onRefresh ?? () async {},
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildStories()),
              SliverToBoxAdapter(child: _buildFeed()),
              SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // INFINITE SCROLL
  // ================================================================

  bool _handleScrollNotification(ScrollNotification notification) {
    // Only the feed's own vertical scroll counts. The horizontal story
    // row, suggestions shelf and post carousels all bubble their scroll
    // notifications up through here too, and their short extents would
    // otherwise trip both checks below incorrectly.
    if (notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical) {
      return false;
    }

    // Drag direction drives the floating nav bar's collapse/expand,
    // independent of the load-more logic below. UserScrollNotification
    // only fires for the person's own drag, not programmatic scrolls.
    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse) {
        onCollapseNavChanged?.call(true);
      } else if (notification.direction == ScrollDirection.forward) {
        onCollapseNavChanged?.call(false);
      }
    }

    if (onLoadMore == null) return false;

    // Only fetch more once a full feed is actually loaded — this also
    // naturally blocks re-firing while a previous "load more" is still
    // in flight, since status flips away from `loaded` for its
    // duration.
    if (!state.isLoaded) return false;

    const loadMoreThreshold = 400.0;
    final metrics = notification.metrics;

    if (metrics.maxScrollExtent > 0 &&
        metrics.pixels >= metrics.maxScrollExtent - loadMoreThreshold) {
      onLoadMore!.call();
    }

    return false;
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader() {
    final data = state.data;
    final currentUser = data?.header.currentUser ??
        const User(id: '', username: '', displayName: '');

    return HomeHeader(
      currentUser: currentUser,
      appName: 'Asterisk',
      unreadNotifications: data?.header.unreadNotifications ?? 0,
      onMenuPressed: onMenuPressed,
      onNotificationPressed: onNotificationPressed,
    );
  }

  // ================================================================
  // STORIES
  // ================================================================

  Widget _buildStories() {
    // During the first load there is no content to preserve, so show the
    // skeleton. During refresh we deliberately keep the existing stories.
    if (state.status == HomeStatus.initial ||
        state.status == HomeStatus.loading) {
      return const StoryRowSkeleton();
    }

    final data = state.data;
    if (data == null || data.stories.isEmpty) {
      return const SizedBox.shrink();
    }

    return StoryRow(
      currentUser: data.header.currentUser,
      stories: data.stories,
      onStoryTap: onStoryTap,
      onCreateStoryTap: onCreateStoryTap,
    );
  }

  // ================================================================
  // FEED
  // ================================================================

  Widget _buildFeed() {
    if (state.status == HomeStatus.initial ||
        state.status == HomeStatus.loading) {
      return _buildFeedLoading();
    }

    final data = state.data;

    if (state.status == HomeStatus.error && data == null) {
      return _buildFeedError();
    }

    if (data == null || data.feed.isEmpty) {
      return _buildFeedEmpty();
    }

    // loaded, refreshing and loadingMore all keep rendering the current feed.
    return _buildFeedContent(data);
  }

  Widget _buildFeedLoading() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostSkeleton(),
          SizedBox(height: 12),
          PostSkeleton(),
        ],
      ),
    );
  }

  Widget _buildFeedContent(HomeData data) {
    final stories = data.stories;
    final feed = data.feed;
    final suggested = data.suggestedUsers;
    final currentUser = data.header.currentUser;

    final children = <Widget>[];
    var suggestedInserted = false;

    for (var i = 0; i < feed.length; i++) {
      children.add(_buildFeedItem(feed[i], stories, currentUser));

      // Drop the suggestions shelf in after the 3rd item, once, so it
      // reads as a natural break in the feed rather than being pinned
      // to the very top.
      if (!suggestedInserted && suggested.isNotEmpty && i == 2) {
        children.add(_buildSuggestedRow(suggested));
        suggestedInserted = true;
      }
    }

    // Shorter feeds still get the shelf, just at the end instead of
    // dropped entirely.
    if (!suggestedInserted && suggested.isNotEmpty) {
      children.add(_buildSuggestedRow(suggested));
    }

    children.add(_buildFeedFooter(data));

    return Column(children: children);
  }

  Widget _buildFeedItem(FeedItem item, List<Story> stories, User currentUser) {
    switch (item.type) {
      case FeedItemType.post:
        final post = item.post;
        if (post == null) return const SizedBox.shrink();

        final authorActiveStories = stories
            .where((story) =>
                story.user.id == post.author.id && story.isLive)
            .toList();

        return PostCard(
          key: ValueKey(item.id),
          post: post,
          currentUser: currentUser,
          authorHasActiveStory: authorActiveStories.isNotEmpty,
          authorStoriesViewed: authorActiveStories.isNotEmpty &&
              authorActiveStories.every((story) => story.isViewed),
          onAvatarTap: () => onPostAuthorTap?.call(post.author),
          onLike: onPostLike == null ? null : () => onPostLike!(post.id),
          onSave: onPostSave == null ? null : () => onPostSave!(post.id),
        );

      case FeedItemType.advertisement:
        final ad = item.ad;
        if (ad == null) return const SizedBox.shrink();

        return AdPostCard(
          key: ValueKey(item.id),
          ad: ad,
          onTap: onAdTap == null ? null : () => onAdTap!(ad),
        );
    }
  }

  Widget _buildSuggestedRow(List<User> suggested) {
    return SuggestedUserRow(
      users: suggested,
      onUserTap: onSuggestedUserTap,
      onFollowToggle: onFollowToggle,
      onDismiss: onDismissSuggestions,
    );
  }

  Widget _buildFeedFooter(HomeData data) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }

    if (!data.pagination.hasMore && data.hasFeed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            "You're all caught up",
            style: AppTypography.caption(
              fontSize: 12,
              color: const Color(0xFF8A8A8A),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildFeedEmpty() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Center(
        child: Text('There are no posts to show yet.'),
      ),
    );
  }

  Widget _buildFeedError() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Text('Something went wrong while loading your feed.'),
      ),
    );
  }
}
