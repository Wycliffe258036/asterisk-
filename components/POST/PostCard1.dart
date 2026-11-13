import 'package:flutter/material.dart';

import '../../models/media.dart';
import '../../models/post.dart';
import '../../models/user.dart';
import '../common/Avatar.dart';
import '../../theme/app_typography.dart';
import 'post_options_sheet.dart';
import 'post_comments_sheet.dart';
import 'post_share_sheet.dart';

class PostCard extends StatelessWidget {
  final Post post;

  /// Whether the post's author currently has an active (unexpired) story.
  /// Draws the colored ring around the header avatar when true.
  final bool authorHasActiveStory;

  /// Only relevant when [authorHasActiveStory] is true — switches the
  /// ring to the muted "already viewed" treatment.
  final bool authorStoriesViewed;

  /// Fired when the header avatar is tapped. The caller decides whether
  /// that opens the story viewer or a profile-page placeholder.
  final VoidCallback? onAvatarTap;

  /// The person currently using the app — shown next to the comment
  /// composer if the built-in comments sheet is opened. Optional.
  final User? currentUser;

  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  /// Outer spacing around the card. With the sky background now visible
  /// behind the feed, this margin *is* the visible gap between cards
  /// and the screen edges — tune it here to change how much "floats".
  final EdgeInsetsGeometry margin;

  const PostCard({
    super.key,
    required this.post,
    this.authorHasActiveStory = false,
    this.authorStoriesViewed = false,
    this.onAvatarTap,
    this.currentUser,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 18),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _PostCardColors.of(isDark);

    return Container(
      margin: margin,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            // A plain BoxShadow, not a BackdropFilter — it only blurs the
            // shadow's own silhouette, not everything behind the card, so
            // it doesn't carry the hit-test/semantics risk BackdropFilter
            // caused on the media overlay earlier.
            color: Colors.black.withOpacity(isDark ? 0.40 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: post.hasMedia
            ? _buildMediaPostChildren(colors)
            : _buildTextPostChildren(colors),
      ),
    );
  }

  // ================================================================
  // LAYOUT VARIANTS
  // ================================================================

  List<Widget> _buildMediaPostChildren(_PostCardColors colors) {
    final hasCaption = post.text != null && post.text!.trim().isNotEmpty;

    return [
      if (post.sharedFrom != null) ...[
        _buildSharedFrom(colors),
        const SizedBox(height: 8),
      ],

      // Header is overlaid directly on the media itself here — nothing
      // else (buttons, caption) sits on the photo.
      _buildMediaCard(),

      const SizedBox(height: 10),

      if (hasCaption) ...[
        _buildCaption(colors),
        const SizedBox(height: 10),
      ],

      _buildActions(colors),

      const SizedBox(height: 4),

      _buildEngagementSummary(colors),
    ];
  }

  List<Widget> _buildTextPostChildren(_PostCardColors colors) {
    final hasCaption = post.text != null && post.text!.trim().isNotEmpty;

    return [
      _buildHeader(colors: colors),

      if (post.sharedFrom != null) ...[
        const SizedBox(height: 8),
        _buildSharedFrom(colors),
      ],

      const SizedBox(height: 12),

      if (hasCaption) ...[
        _buildCaption(colors),
        const SizedBox(height: 10),
      ],

      _buildActions(colors),

      const SizedBox(height: 4),

      _buildEngagementSummary(colors),
    ];
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader({_PostCardColors? colors, bool overlay = false}) {
    final user = post.author;

    final nameColor = overlay ? Colors.white : colors!.primaryText;
    final timeColor = overlay ? const Color(0xE6FFFFFF) : colors!.secondaryText;
    final moreColor = overlay ? Colors.white : colors!.mutedIcon;
    final shadows = overlay
        ? const [Shadow(blurRadius: 6, color: Colors.black54)]
        : null;

    return Row(
      children: [
        _buildAvatar(user, size: 38),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: nameColor,
                      ).copyWith(shadows: shadows),
                    ),
                  ),

                  if (user.isVerified) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.verified_rounded,
                      size: 15,
                      color: const Color(0xFF287BEA),
                      shadows: shadows,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 2),

              Text(
                _formatRelativeTime(post.createdAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption(
                  fontSize: 12,
                  color: timeColor,
                ).copyWith(shadows: shadows),
              ),
            ],
          ),
        ),

        Builder(
          builder: (context) {
            return IconButton(
              onPressed: () => showPostOptionsSheet(context, post: post),
              icon: Icon(Icons.more_horiz_rounded, size: 22, shadows: shadows),
              splashRadius: 20,
              color: moreColor,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSharedFrom(_PostCardColors colors) {
    final shared = post.sharedFrom!;
    final hasShareCaption =
        shared.shareCaption != null && shared.shareCaption!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Avatar(
              user: shared.sharedBy,
              size: 26,
              showVerificationBadge: false,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Shared from ${shared.sharedBy.displayName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.secondaryText,
                ),
              ),
            ),
          ],
        ),

        if (hasShareCaption) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Text(
              shared.shareCaption!,
              style: AppTypography.caption(
                fontSize: 12,
                color: colors.secondaryText,
              ).copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ],
    );
  }

  // ================================================================
  // MEDIA CARD
  //
  // Only the header sits on the photo, behind a small fixed-height
  // gradient band for legibility. Buttons and caption live below the
  // image, on the card's own surface.
  // ================================================================

  Widget _buildMediaCard() {
    final aspectRatio = post.isCarousel
        ? 4 / 5
        : (post.media.first.aspectRatio ?? 4 / 5);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildMediaContent(),

            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 74,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x8A000000), Color(0x00000000)],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 10,
              right: 4,
              top: 8,
              child: _buildHeader(overlay: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    if (post.isCarousel) {
      return _CarouselMedia(items: post.media);
    }

    if (post.isVideo) {
      return _VideoThumbnail(media: post.media.first);
    }

    return _buildImage(post.media.first);
  }

  Widget _buildImage(Media media) {
    return Image.network(
      media.optimizedUrl ?? media.url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const _MediaErrorPlaceholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: const Color(0xFFEFEFEF),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  // ================================================================
  // CAPTION
  // ================================================================

  Widget _buildCaption(_PostCardColors colors) {
    final text = post.text;

    if (text == null || text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      text,
      style: AppTypography.body(
        fontSize: 14,
        color: colors.primaryText,
      ),
    );
  }

  // ================================================================
  // ACTIONS
  // ================================================================

  Widget _buildActions(_PostCardColors colors) {
    return Row(
      children: [
        _ActionButton(
          icon: post.isLiked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          label: _formatCount(post.likeCount),
          active: post.isLiked,
          onTap: onLike,
          iconColor: colors.primaryText,
          labelColor: colors.secondaryText,
        ),

        const SizedBox(width: 18),

        Builder(
          builder: (context) {
            return _ActionButton(
              icon: Icons.chat_bubble_outline_rounded,
              label: _formatCount(post.commentCount),
              iconColor: colors.primaryText,
              labelColor: colors.secondaryText,
              onTap: () {
                if (onComment != null) {
                  onComment!.call();
                } else {
                  showPostCommentsSheet(
                    context,
                    post: post,
                    currentUser: currentUser,
                  );
                }
              },
            );
          },
        ),

        const SizedBox(width: 18),

        Builder(
          builder: (context) {
            return _ActionButton(
              icon: Icons.send_outlined,
              label: _formatCount(post.shareCount),
              iconColor: colors.primaryText,
              labelColor: colors.secondaryText,
              onTap: () {
                if (onShare != null) {
                  onShare!.call();
                } else {
                  showPostShareSheet(context, post: post);
                }
              },
            );
          },
        ),

        const Spacer(),

        IconButton(
          onPressed: onSave,
          icon: Icon(
            post.isSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            size: 22,
          ),
          color: colors.primaryText,
          splashRadius: 20,
          tooltip: 'Save',
        ),
      ],
    );
  }

  // ================================================================
  // ENGAGEMENT
  // ================================================================

  Widget _buildEngagementSummary(_PostCardColors colors) {
    final likes = post.likeCount;
    final comments = post.commentCount;

    if (likes == 0 && comments == 0) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (likes > 0)
          Text(
            '$likes ${likes == 1 ? 'like' : 'likes'}',
            style: AppTypography.caption(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.secondaryText,
            ),
          ),

        if (likes > 0 && comments > 0) const SizedBox(width: 12),

        if (comments > 0)
          Text(
            '$comments ${comments == 1 ? 'comment' : 'comments'}',
            style: AppTypography.caption(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.secondaryText,
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar(User user, {required double size}) {
    return Avatar(
      user: user,
      size: size,
      showVerificationBadge: false,
      hasActiveStory: authorHasActiveStory,
      storiesViewed: authorStoriesViewed,
      onPressed: onAvatarTap,
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }

    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }

    return count.toString();
  }

  String _formatRelativeTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }

    if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }

    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    }

    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    }

    final years = (difference.inDays / 365).floor();
    return '${years}y ago';
  }
}

// ================================================================
// CARD COLOR TOKENS
//
// A small, deliberately minimal palette for the card's own chrome —
// separate from the sky gradient behind it. Both a light and dark
// variant, so cards read as "a bit darker" in dark mode, matching how
// the sky itself adapts, rather than switching to an unrelated scheme.
// ================================================================

// Easy to retune: how much of the sky behind shows through the card.
const double _lightCardOpacity = 0.90;
const double _darkCardOpacity = 0.82;

class _PostCardColors {
  final Color card;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedIcon;

  const _PostCardColors({
    required this.card,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedIcon,
  });

  static _PostCardColors of(bool isDark) {
    if (isDark) {
      return _PostCardColors(
        card: const Color(0xFF212121).withOpacity(_darkCardOpacity),
        primaryText: const Color(0xFFF2F2F4),
        secondaryText: const Color(0xFFA6AAB8),
        mutedIcon: const Color(0xFFC7CAD6),
      );
    }

    return _PostCardColors(
      card: const Color(0xFFC9C9C9).withOpacity(_lightCardOpacity),
      primaryText: const Color(0xFF111111),
      secondaryText: const Color(0xFF777777),
      mutedIcon: const Color(0xFF555555),
    );
  }
}

// ================================================================
// ACTION BUTTON
// ================================================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color labelColor;
  final Color activeColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
    this.iconColor = const Color(0xFF222222),
    this.labelColor = const Color(0xFF555555),
    // ignore: unused_element_parameter
    this.activeColor = const Color(0xFFE83D68),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? activeColor : iconColor,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.caption(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// CAROUSEL MEDIA (mixed images + videos, with page dots)
// ================================================================

class _CarouselMedia extends StatefulWidget {
  final List<Media> items;

  const _CarouselMedia({required this.items});

  @override
  State<_CarouselMedia> createState() => _CarouselMediaState();
}

class _CarouselMediaState extends State<_CarouselMedia> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: widget.items.length,
          onPageChanged: (index) {
            setState(() => _currentPage = index);
          },
          itemBuilder: (context, index) {
            final media = widget.items[index];

            if (media.type == MediaType.video) {
              return _VideoThumbnail(media: media);
            }

            return Image.network(
              media.optimizedUrl ?? media.url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const _MediaErrorPlaceholder();
              },
            );
          },
        ),

        if (widget.items.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: _PageDots(
              count: widget.items.length,
              currentIndex: _currentPage,
            ),
          ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _PageDots({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          width: isActive ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(3),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
            ],
          ),
        );
      }),
    );
  }
}

// ================================================================
// VIDEO THUMBNAIL (static preview + play affordance)
// ================================================================

class _VideoThumbnail extends StatelessWidget {
  final Media media;

  const _VideoThumbnail({required this.media});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (media.thumbnailUrl != null)
          Image.network(
            media.thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildBackground();
            },
          )
        else
          _buildBackground(),

        Container(color: Colors.black.withOpacity(0.12)),

        Center(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xAA111111),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ),

        if (media.durationMs != null)
          Positioned(
            top: 10,
            right: 10,
            child: _DurationBadge(durationMs: media.durationMs!),
          ),
      ],
    );
  }

  Widget _buildBackground() {
    return Container(
      color: const Color(0xFF222222),
      child: const Center(
        child: Icon(Icons.videocam_rounded, color: Colors.white54, size: 48),
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  final int durationMs;

  const _DurationBadge({required this.durationMs});

  @override
  Widget build(BuildContext context) {
    final totalSeconds = (durationMs / 1000).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final label = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ================================================================
// MEDIA ERROR PLACEHOLDER
// ================================================================

class _MediaErrorPlaceholder extends StatelessWidget {
  const _MediaErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFECECEC),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xFF999999),
          size: 42,
        ),
      ),
    );
  }
}
