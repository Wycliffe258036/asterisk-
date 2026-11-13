import 'story.dart';
import 'user.dart';

/// One user's set of currently-live stories, grouped together so the
/// story tray can show a single bubble per person (not per story) and
/// the viewer can play through a user's stories before moving on to
/// the next person — matching how most story trays behave.
class StoryGroup {
  final User user;

  /// This user's stories, in chronological order (oldest first, so
  /// playback matches the order they were posted).
  final List<Story> stories;

  const StoryGroup({
    required this.user,
    required this.stories,
  });

  /// True once every story in this group has been viewed — the tray
  /// bubble switches from the vivid "unviewed" ring to the muted one
  /// only when this is true.
  bool get allViewed => stories.every((story) => story.isViewed);

  /// Where the viewer should resume: the first unviewed story, or the
  /// first story if the user has already seen everything.
  Story get resumeStory {
    return stories.firstWhere(
      (story) => !story.isViewed,
      orElse: () => stories.first,
    );
  }
}

/// Groups a flat list of stories by author, preserving each user's
/// first-appearance order in [stories] (so the tray's left-to-right
/// order doesn't shuffle as new stories are added), and sorts each
/// user's own stories oldest-first.
List<StoryGroup> groupStoriesByUser(List<Story> stories) {
  final groups = <StoryGroup>[];
  final indexByUserId = <String, int>{};

  for (final story in stories) {
    final existingIndex = indexByUserId[story.user.id];

    if (existingIndex == null) {
      indexByUserId[story.user.id] = groups.length;
      groups.add(StoryGroup(user: story.user, stories: [story]));
    } else {
      groups[existingIndex].stories.add(story);
    }
  }

  for (final group in groups) {
    group.stories.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  return groups;
}
