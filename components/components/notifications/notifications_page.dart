import 'package:flutter/material.dart';

import '../../../../models/notification_item.dart';
import '../../../../models/user.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/sky_gradient_background.dart';
import '../../../../components/common/Avatar.dart';

/// Full-page notifications/activity feed. Grouped into "Today" /
/// "This Week" / "Earlier" rather than the reference's algorithmic
/// "Featured" section, since there's no ranking model behind this
/// app's data to earn that label honestly — plain recency grouping is
/// the closest equivalent that isn't fabricated.
///
/// Owns a local, optimistic copy of [notifications] so a follow-toggle
/// updates the row immediately; [onFollowToggle] still fires so the
/// caller can keep its own copy in sync for next time this page opens.
class NotificationsPage extends StatefulWidget {
  final List<NotificationItem> notifications;

  /// Fired once, right after the page's first frame, so the caller can
  /// clear the unread badge in the header.
  final VoidCallback? onOpened;

  final ValueChanged<User>? onFollowToggle;
  final ValueChanged<NotificationItem>? onNotificationTap;

  const NotificationsPage({
    super.key,
    required this.notifications,
    this.onOpened,
    this.onFollowToggle,
    this.onNotificationTap,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();

    _notifications = List<NotificationItem>.from(widget.notifications);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onOpened?.call();
    });
  }

  void _handleFollowToggle(User user) {
    final index = _notifications.indexWhere((n) => n.actor.id == user.id);
    if (index < 0) return;

    final current = _notifications[index];

    final updatedRelationship = UserRelationship(
      isFollowing: !current.actor.relationship.isFollowing,
      isFollowedBy: current.actor.relationship.isFollowedBy,
      hasPendingFollowRequest: current.actor.relationship.hasPendingFollowRequest,
      isBlocked: current.actor.relationship.isBlocked,
      hasBlockedCurrentUser: current.actor.relationship.hasBlockedCurrentUser,
    );

    setState(() {
      _notifications[index] = current.copyWith(
        actor: current.actor.copyWith(relationship: updatedRelationship),
      );
    });

    widget.onFollowToggle?.call(user);
  }

  @override
  Widget build(BuildContext context) {
    final sections = _groupBySection(_notifications);

    return SkyGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: sections.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: sections.length,
                        itemBuilder: (context, index) {
                          return _buildSection(sections[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final palette = SkyGradientBackground.paletteOf(context);
    final isDarkSurface = palette.contentBrightness == Brightness.dark;
    final contentColor = isDarkSurface ? Colors.white : const Color(0xFF151515);

    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: contentColor),
            ),
            Expanded(
              child: Text(
                'Notifications',
                style: AppTypography.title(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: contentColor,
                ),
              ),
            ),
            // Balances the back button so the title stays visually
            // centered, matching the app bar treatment elsewhere.
            const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none_rounded, size: 40, color: Color(0xFFBBBBBB)),
            const SizedBox(height: 12),
            Text(
              'No notifications yet',
              style: AppTypography.body(fontSize: 14, color: const Color(0xFF999999)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(_NotificationSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Text(
            section.title,
            style: AppTypography.title(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        for (final item in section.items)
          _NotificationRow(
            item: item,
            onFollowToggle: _handleFollowToggle,
            onTap: widget.onNotificationTap,
          ),
      ],
    );
  }

  List<_NotificationSection> _groupBySection(List<NotificationItem> items) {
    final now = DateTime.now();
    final today = <NotificationItem>[];
    final thisWeek = <NotificationItem>[];
    final earlier = <NotificationItem>[];

    for (final item in items) {
      final age = now.difference(item.createdAt);

      if (item.createdAt.year == now.year &&
          item.createdAt.month == now.month &&
          item.createdAt.day == now.day) {
        today.add(item);
      } else if (age.inDays < 7) {
        thisWeek.add(item);
      } else {
        earlier.add(item);
      }
    }

    return [
      if (today.isNotEmpty) _NotificationSection('Today', today),
      if (thisWeek.isNotEmpty) _NotificationSection('This Week', thisWeek),
      if (earlier.isNotEmpty) _NotificationSection('Earlier', earlier),
    ];
  }
}

class _NotificationSection {
  final String title;
  final List<NotificationItem> items;

  const _NotificationSection(this.title, this.items);
}

class _NotificationRow extends StatelessWidget {
  final NotificationItem item;
  final ValueChanged<User>? onFollowToggle;
  final ValueChanged<NotificationItem>? onTap;

  const _NotificationRow({required this.item, this.onFollowToggle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? const Color(0xFFF2F2F4) : const Color(0xFF111111);
    final secondaryText = isDark ? const Color(0xFFA6AAB8) : const Color(0xFF777777);
    final unreadTint =
        isDark ? Colors.white.withOpacity(0.05) : const Color(0xFF287BEA).withOpacity(0.05);

    return InkWell(
      onTap: () => onTap?.call(item),
      child: Container(
        color: item.isRead ? Colors.transparent : unreadTint,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Avatar(user: item.actor, size: 46, showVerificationBadge: false),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: AppTypography.body(fontSize: 13.5, color: primaryText),
                  children: [
                    TextSpan(
                      text: item.actor.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (item.additionalActorCount > 0)
                      TextSpan(text: ' and ${item.additionalActorCount} others'),
                    TextSpan(text: ' ${_phraseFor(item.type)}'),
                    if (item.detail != null) TextSpan(text: ' "${item.detail}"'),
                    TextSpan(
                      text: '  ${_relativeTime(item.createdAt)}',
                      style: TextStyle(color: secondaryText, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            _buildTrailing(secondaryText),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing(Color secondaryText) {
    if (item.isFollowSuggestion) {
      final isFollowing = item.actor.relationship.isFollowing;

      return SizedBox(
        height: 32,
        child: OutlinedButton(
          onPressed: () => onFollowToggle?.call(item.actor),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            backgroundColor: isFollowing ? Colors.transparent : const Color(0xFF287BEA),
            side: BorderSide(color: isFollowing ? secondaryText : const Color(0xFF287BEA)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            isFollowing ? 'Following' : 'Follow',
            style: AppTypography.caption(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isFollowing ? secondaryText : Colors.white,
            ),
          ),
        ),
      );
    }

    if (item.thumbnailUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          item.thumbnailUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 44,
            height: 44,
            color: const Color(0xFFECECEC),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _phraseFor(NotificationType type) {
    switch (type) {
      case NotificationType.follow:
        return 'started following you.';
      case NotificationType.followSuggestion:
        return 'is someone you may know on Asterisk.';
      case NotificationType.like:
        return 'liked your post.';
      case NotificationType.comment:
        return 'commented:';
      case NotificationType.repost:
        return 'reposted your post.';
      case NotificationType.mention:
        return 'mentioned you in a comment.';
      case NotificationType.message:
        return 'sent you a message.';
    }
  }

  String _relativeTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';

    final weeks = (difference.inDays / 7).floor();
    return '${weeks}w';
  }
}
