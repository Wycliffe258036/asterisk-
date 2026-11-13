import 'package:flutter/material.dart';

import '../../models/user.dart';
import 'default_avatar.dart';

class Avatar extends StatelessWidget {
  final User user;
  final double size;
  final bool showVerificationBadge;
  final bool showOnlineIndicator;

  /// Whether this user currently has one or more active (unexpired)
  /// stories. When true, a colored ring is drawn around the avatar,
  /// matching the story tray treatment.
  final bool hasActiveStory;

  /// Only meaningful when [hasActiveStory] is true. Switches the ring
  /// from the vivid "unviewed" gradient to the muted grey "viewed"
  /// gradient, same as the story tray bubbles.
  final bool storiesViewed;

  final VoidCallback? onPressed;

  const Avatar({
    super.key,
    required this.user,
    this.size = 44,
    this.showVerificationBadge = true,
    this.showOnlineIndicator = false,
    this.hasActiveStory = false,
    this.storiesViewed = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          hasActiveStory ? _buildStoryRing() : _buildAvatar(),
          if (showVerificationBadge && user.isVerified)
            _buildVerificationBadge(),
          if (showOnlineIndicator) _buildOnlineIndicator(),
        ],
      ),
    );

    if (onPressed != null) {
      avatar = GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE8E8E8),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildAvatarImage(),
    );
  }

  Widget _buildStoryRing() {
    final borderWidth = (size * 0.05).clamp(2.0, 4.0).toDouble();
    final gapWidth = (size * 0.025).clamp(1.0, 2.5).toDouble();

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: storiesViewed
            ? const LinearGradient(
                colors: [Color(0xFFD5D5D5), Color(0xFFBDBDBD)],
              )
            : const SweepGradient(
                colors: [
                  Color(0xFFFF3D81),
                  Color(0xFFFF8A3D),
                  Color(0xFFFFD23F),
                  Color(0xFFCB4CFF),
                  Color(0xFFFF3D81),
                ],
              ),
      ),
      child: Container(
        padding: EdgeInsets.all(gapWidth),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: ClipOval(child: _buildAvatarImage()),
      ),
    );
  }

  Widget _buildAvatarImage() {
    final localPath = user.avatarPath;
    final imageUrl = user.avatarUrl;

    if (localPath != null && localPath.isNotEmpty) {
      return Image.asset(
        localPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildNetworkOrFallback(imageUrl);
        },
      );
    }

    return _buildNetworkOrFallback(imageUrl);
  }

  Widget _buildNetworkOrFallback(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildFallback();
        },
      );
    }

    return _buildFallback();
  }

 Widget _buildFallback() {
    return DefaultAvatar(user: user, size: size);
  }

  Widget _buildVerificationBadge() {
    final badgeSize = size * 0.28;

    return Positioned(
      right: -1,
      bottom: -1,
      child: Container(
        width: badgeSize,
        height: badgeSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2196F3),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: badgeSize * 0.65,
        ),
      ),
    );
  }

  Widget _buildOnlineIndicator() {
    final indicatorSize = size * 0.22;

    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: indicatorSize,
        height: indicatorSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF32CD72),
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}