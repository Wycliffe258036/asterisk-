import 'package:flutter/material.dart';

import '../../models/story.dart';
import '../../models/story_group.dart';
import '../../models/user.dart';
import 'create_story_bubble.dart';
import 'story_bubble.dart';

class StoryRow extends StatelessWidget {
  final User? currentUser;

  final List<Story> stories;

  /// Fired with the story the viewer should open on — the tapped
  /// user's first unviewed story, or their first story if all of
  /// theirs are already viewed.
  final ValueChanged<Story>? onStoryTap;

  final VoidCallback? onCreateStoryTap;

  final EdgeInsetsGeometry padding;

  const StoryRow({
    super.key,
    this.currentUser,
    required this.stories,
    this.onStoryTap,
    this.onCreateStoryTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 6,
    ),
  });

  @override
  Widget build(BuildContext context) {
    // Only ever show live stories in the tray — an expired one
    // shouldn't leave a stale bubble behind. Stories are then grouped
    // by author so a person with several stories gets exactly one
    // bubble, not one per story.
    final liveStories = stories.where((story) => story.isLive).toList();
    final groups = groupStoriesByUser(liveStories);

    final itemCount = groups.length + (currentUser != null ? 1 : 0);

    if (itemCount == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 94,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: padding,
            itemCount: itemCount,
            separatorBuilder: (
              context,
              index,
            ) {
              return const SizedBox(width: 10);
            },
            itemBuilder: (
              context,
              index,
            ) {
              if (currentUser != null && index == 0) {
                return CreateStoryBubble(
                  user: currentUser!,
                  onTap: onCreateStoryTap,
                  size: 60,
                );
              }

              final groupIndex =
                  currentUser != null ? index - 1 : index;

              final group = groups[groupIndex];

              return StoryBubble(
                user: group.user,
                allViewed: group.allViewed,
                size: 60,
                onTap: () => onStoryTap?.call(group.resumeStory),
              );
            },
          ),
        ),

        const Divider(
          height: 1,
          thickness: 1,
          indent: 14,
          endIndent: 14,
        ),
      ],
    );
  }
}
