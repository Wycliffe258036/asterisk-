import 'location.dart';
import 'media.dart';
import 'user.dart';
import 'ad.dart';

enum PostType {
  text,
  image,
  video,
  carousel,
}

enum FeedItemType {
  post,
  advertisement,
}

enum PostVisibility {
  public,
  followers,
  closeFriends,
  private,
}

enum ModerationStatus {
  pending,
  approved,
  flagged,
  removed,
}

class Post {
  final String id;

  final User author;
  final PostType type;

  final String? text;
  final List<Media> media;

  final PostLocation? location;

  final SharedPostInfo? sharedFrom;

  final List<String> mentions;
  final List<String> hashtags;

  final PostVisibility visibility;

  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int saveCount;

  final bool isLiked;
  final bool isSaved;

  final bool commentsDisabled;

  final ModerationStatus moderationStatus;

  final DateTime createdAt;
  final DateTime? editedAt;

  const Post({
    required this.id,
    required this.author,
    required this.type,
    this.text,
    this.media = const [],
    this.location,
    this.sharedFrom,
    this.mentions = const [],
    this.hashtags = const [],
    this.visibility = PostVisibility.public,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.saveCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.commentsDisabled = false,
    this.moderationStatus = ModerationStatus.approved,
    required this.createdAt,
    this.editedAt,
  });

  bool get isEdited => editedAt != null;

  bool get hasMedia => media.isNotEmpty;

  bool get isCarousel => type == PostType.carousel;

  bool get isVideo => type == PostType.video;

  bool get isImage => type == PostType.image;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      author: User.fromJson(
        json['author'] as Map<String, dynamic>,
      ),
      type: PostType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => PostType.text,
      ),
      text: json['text'] as String?,
      media: (json['media'] as List<dynamic>? ?? [])
          .map(
            (item) => Media.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      location: json['location'] != null
          ? PostLocation.fromJson(
              json['location'] as Map<String, dynamic>,
            )
          : null,
      mentions: List<String>.from(
        json['mentions'] as List<dynamic>? ?? [],
      ),
      hashtags: List<String>.from(
        json['hashtags'] as List<dynamic>? ?? [],
      ),
      visibility: PostVisibility.values.firstWhere(
        (value) => value.name == json['visibility'],
        orElse: () => PostVisibility.public,
      ),
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      saveCount: json['saveCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      commentsDisabled:
          json['commentsDisabled'] as bool? ?? false,
      moderationStatus: ModerationStatus.values.firstWhere(
        (value) => value.name == json['moderationStatus'],
        orElse: () => ModerationStatus.approved,
      ),
      createdAt: DateTime.parse(
        json['createdAt'] as String,
      ),
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'type': type.name,
      'text': text,
      'media': media.map((item) => item.toJson()).toList(),
      'location': location?.toJson(),
      'mentions': mentions,
      'hashtags': hashtags,
      'visibility': visibility.name,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'saveCount': saveCount,
      'isLiked': isLiked,
      'isSaved': isSaved,
      'commentsDisabled': commentsDisabled,
      'moderationStatus': moderationStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
    };
  }

  Post copyWith({
    String? text,
    List<Media>? media,
    PostLocation? location,
    List<String>? mentions,
    List<String>? hashtags,
    PostVisibility? visibility,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? saveCount,
    bool? isLiked,
    bool? isSaved,
    bool? commentsDisabled,
    ModerationStatus? moderationStatus,
    DateTime? editedAt,
  }) {
    return Post(
      id: id,
      author: author,
      type: type,
      text: text ?? this.text,
      media: media ?? this.media,
      location: location ?? this.location,
      mentions: mentions ?? this.mentions,
      hashtags: hashtags ?? this.hashtags,
      visibility: visibility ?? this.visibility,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      saveCount: saveCount ?? this.saveCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      commentsDisabled: commentsDisabled ?? this.commentsDisabled,
      moderationStatus:
          moderationStatus ?? this.moderationStatus,
      createdAt: createdAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}

class FeedItem {
  final String id;
  final FeedItemType type;

  final Post? post;
  final Ad? ad;

  const FeedItem({
    required this.id,
    required this.type,
    this.post,
    this.ad,
  });
  
}

class SharedPostInfo {
  final User sharedBy;
  final String originalPostId;
  final DateTime sharedAt;

  /// Optional commentary added by the person sharing.
  final String? shareCaption;

  const SharedPostInfo({
    required this.sharedBy,
    required this.originalPostId,
    required this.sharedAt,
    this.shareCaption,
  });

  factory SharedPostInfo.fromJson(Map<String, dynamic> json) {
    return SharedPostInfo(
      sharedBy: User.fromJson(
        json['sharedBy'] as Map<String, dynamic>,
      ),
      originalPostId: json['originalPostId'] as String,
      sharedAt: DateTime.parse(
        json['sharedAt'] as String,
      ),
      shareCaption: json['shareCaption'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sharedBy': sharedBy.toJson(),
      'originalPostId': originalPostId,
      'sharedAt': sharedAt.toIso8601String(),
      'shareCaption': shareCaption,
    };
  }
}