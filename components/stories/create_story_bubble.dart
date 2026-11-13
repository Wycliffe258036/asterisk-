import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../theme/app_typography.dart';
import '../common/default_avatar.dart';

class CreateStoryBubble extends StatelessWidget {
  final User user;

  final VoidCallback? onTap;

  final double size;

  /// If true, the current user already has an active story.
  ///
  /// In that case the bubble can later be changed to indicate
  /// that the user's existing story can be viewed.
  final bool hasActiveStory;

  const CreateStoryBubble({
    super.key,
    required this.user,
    this.onTap,
    this.size = 60,
    this.hasActiveStory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hasActiveStory
          ? 'View your story'
          : 'Create a story',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: size + 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBubble(),
              const SizedBox(height: 3),
              _buildLabel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubble() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar.
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE5E5E5),
                    Color(0xFFBDBDBD),
                  ],
                ),
              ),
              child: ClipOval(
                child: _buildAvatar(),
              ),
            ),
          ),

          // Add button.
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 5,
                    offset: Offset(0, 2),
                    color: Color(0x25000000),
                  ),
                ],
              ),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF111111),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 17,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildAvatar() {
    final avatarUrl = user.avatarUrl;
    final avatarSlotSize = size - 5; // matches the 2.5px ring padding inset

    if (avatarUrl == null || avatarUrl.isEmpty) {
      return DefaultAvatar(user: user, size: avatarSlotSize);
    }

    return Image.network(
      avatarUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return DefaultAvatar(user: user, size: avatarSlotSize);
      },
    );
  }

  Widget _buildLabel() {
    return SizedBox(
      width: size + 4,
      child: Text(
        'Your story',
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.caption(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF222222),
        ),
      ),
    );
  }
}