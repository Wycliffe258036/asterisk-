import 'user.dart';

enum NotificationType {
  follow,
  followSuggestion,
  like,
  comment,
  repost,
  mention,
  message,
}

class NotificationItem {
  final String id;
  final NotificationType type;

  /// Who the notification is about/from.
  final User actor;

  /// Additional actors folded into the same line, e.g.
  /// "Kwame and 12 others liked your post."
  final int additionalActorCount;

  final DateTime createdAt;

  /// Free-form trailing text specific to this notification, e.g. the
  /// comment's own text. Null when the type's default phrasing is
  /// enough on its own.
  final String? detail;

  /// A thumbnail for the trailing edge (the post/story this
  /// notification is about). Not shown for follow-suggestion
  /// notifications, which show a Follow button instead.
  final String? thumbnailUrl;

  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.actor,
    this.additionalActorCount = 0,
    required this.createdAt,
    this.detail,
    this.thumbnailUrl,
    this.isRead = false,
  });

  bool get isFollowSuggestion => type == NotificationType.followSuggestion;

  NotificationItem copyWith({
    User? actor,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id,
      type: type,
      actor: actor ?? this.actor,
      additionalActorCount: additionalActorCount,
      createdAt: createdAt,
      detail: detail,
      thumbnailUrl: thumbnailUrl,
      isRead: isRead ?? this.isRead,
    );
  }
}
