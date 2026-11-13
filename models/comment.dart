import 'user.dart';

class Comment {
  final String id;
  final String postId;

  final User author;
  final String text;

  final int likeCount;
  final int replyCount;

  final bool isLiked;

  final String? parentCommentId;

  final DateTime createdAt;
  final DateTime? editedAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.text,
    this.likeCount = 0,
    this.replyCount = 0,
    this.isLiked = false,
    this.parentCommentId,
    required this.createdAt,
    this.editedAt,
  });

  bool get isReply => parentCommentId != null;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['postId'] as String,
      author: User.fromJson(
        json['author'] as Map<String, dynamic>,
      ),
      text: json['text'] as String,
      likeCount: json['likeCount'] as int? ?? 0,
      replyCount: json['replyCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      parentCommentId: json['parentCommentId'] as String?,
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
      'postId': postId,
      'author': author.toJson(),
      'text': text,
      'likeCount': likeCount,
      'replyCount': replyCount,
      'isLiked': isLiked,
      'parentCommentId': parentCommentId,
      'createdAt': createdAt.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
    };
  }
}