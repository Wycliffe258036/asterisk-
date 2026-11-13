import 'media.dart';
import 'user.dart';

enum StoryMediaType {
  image,
  video,
}

class Story {
  final String id;

  final User user;

  final Media media;

  /// Optional text displayed over the story.
  final String? caption;

  final DateTime createdAt;

  final DateTime expiresAt;

  final bool viewed;

  final int likeCount;

  final int reshareCount;

  final bool isLiked;

  const Story({
    required this.id,
    required this.user,
    required this.media,
    this.caption,
    required this.createdAt,
    required this.expiresAt,
    this.viewed = false,
    this.likeCount = 0,
    this.reshareCount = 0,
    this.isLiked = false,
  });

  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  bool get isLive => !isExpired;

  bool get isViewed => viewed;

  StoryMediaType get mediaType {
    return media.type == MediaType.video
        ? StoryMediaType.video
        : StoryMediaType.image;
  }

  String get mediaUrl {
    return media.optimizedUrl ?? media.url;
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      user: User.fromJson(
        json['user'] as Map<String, dynamic>,
      ),
      media: Media.fromJson(
        json['media'] as Map<String, dynamic>,
      ),
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(
        json['createdAt'] as String,
      ),
      expiresAt: DateTime.parse(
        json['expiresAt'] as String,
      ),
      viewed: json['viewed'] as bool? ?? false,
      likeCount: json['likeCount'] as int? ?? 0,
      reshareCount: json['reshareCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'media': media.toJson(),
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'viewed': viewed,
      'likeCount': likeCount,
      'reshareCount': reshareCount,
      'isLiked': isLiked,
    };
  }

  Story copyWith({
    String? caption,
    User? user,
    Media? media,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? viewed,
    int? likeCount,
    int? reshareCount,
    bool? isLiked,
  }) {
    return Story(
      id: id,
      user: user ?? this.user,
      media: media ?? this.media,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewed: viewed ?? this.viewed,
      likeCount: likeCount ?? this.likeCount,
      reshareCount: reshareCount ?? this.reshareCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}