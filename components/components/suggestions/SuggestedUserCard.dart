import 'package:flutter/material.dart';

import '../../../../models/user.dart';
import '../../../../theme/app_typography.dart';
import '../../../../components/common/Avatar.dart';

/// A single "suggested for you" card: avatar, name, username, and a
/// follow/following toggle. Sized to sit in a horizontal shelf,
/// similar in spirit to StoryBubble but wider to fit the button.
class SuggestedUserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;
  final VoidCallback? onFollowToggle;

  final double width;

  const SuggestedUserCard({
    super.key,
    required this.user,
    this.onTap,
    this.onFollowToggle,
    this.width = 132,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFollowing = user.relationship.isFollowing;

    final cardColor = isDark ? const Color(0xFF23262F) : Colors.white;
    final primaryText = isDark ? const Color(0xFFF2F2F4) : const Color(0xFF111111);
    final secondaryText = isDark ? const Color(0xFFA6AAB8) : const Color(0xFF888888);

    return SizedBox(
      width: width,
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            child: Column(
              children: [
                Avatar(user: user, size: 56, showVerificationBadge: false),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        user.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: primaryText,
                        ),
                      ),
                    ),
                    if (user.isVerified) ...[
                      const SizedBox(width: 3),
                      const Icon(Icons.verified_rounded, size: 13, color: Color(0xFF2196F3)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '@${user.username}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(fontSize: 11, color: secondaryText),
                ),
                const SizedBox(height: 10),
                _FollowButton(isFollowing: isFollowing, onTap: onFollowToggle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback? onTap;

  const _FollowButton({required this.isFollowing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 32,
      child: Material(
        color: isFollowing ? const Color(0xFFF0F0F0) : const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(
              isFollowing ? 'Following' : 'Follow',
              style: AppTypography.caption(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isFollowing ? const Color(0xFF444444) : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
