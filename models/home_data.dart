import 'post.dart';
import 'story.dart';
import 'user.dart';
import 'pagination.dart';

class HomeHeaderData {
  final User currentUser;
  final int unreadNotifications;

  const HomeHeaderData({
    required this.currentUser,
    this.unreadNotifications = 0,
  });

  factory HomeHeaderData.fromJson(Map<String, dynamic> json) {
    return HomeHeaderData(
      currentUser: User.fromJson(
        json['currentUser'] as Map<String, dynamic>,
      ),
      unreadNotifications:
          json['unreadNotifications'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentUser': currentUser.toJson(),
      'unreadNotifications': unreadNotifications,
    };
  }
}

class HomeData {
  final HomeHeaderData header;

  final List<Story> stories;
  final List<User> suggestedUsers;
  final List<FeedItem> feed;

  final Pagination pagination;

  const HomeData({
    required this.header,
    this.stories = const [],
    this.suggestedUsers = const [],
    this.feed = const [],
    this.pagination = const Pagination(),
  });

  bool get hasStories => stories.isNotEmpty;

  bool get hasSuggestions => suggestedUsers.isNotEmpty;

  bool get hasFeed => feed.isNotEmpty;

  bool get hasPosts => hasFeed;
}

 