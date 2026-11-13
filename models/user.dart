class User {
  final String id;
  final String username;
  final String displayName;

  final String? avatarUrl;
  final String? avatarPath;
  final String? bio;

  final bool isVerified;
  final bool isPrivate;

  /// Relationship between the current user and this user.
  final UserRelationship relationship;

  final int followerCount;
  final int followingCount;
  final int postCount;

  const User({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.avatarPath,
    this.bio,
    this.isVerified = false,
    this.isPrivate = false,
    this.relationship = const UserRelationship(),
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      avatarPath: json['avatarPath'] as String?,
      bio: json['bio'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      isPrivate: json['isPrivate'] as bool? ?? false,
      relationship: json['relationship'] != null
          ? UserRelationship.fromJson(
              json['relationship'] as Map<String, dynamic>,
            )
          : const UserRelationship(),
      followerCount: json['followerCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      postCount: json['postCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'avatarPath': avatarPath,
      'bio': bio,
      'isVerified': isVerified,
      'isPrivate': isPrivate,
      'relationship': relationship.toJson(),
      'followerCount': followerCount,
      'followingCount': followingCount,
      'postCount': postCount,
    };
  }

  User copyWith({
    String? username,
    String? displayName,
    String? avatarUrl,
    String? avatarPath,
    String? bio,
    bool? isVerified,
    bool? isPrivate,
    UserRelationship? relationship,
    int? followerCount,
    int? followingCount,
    int? postCount,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarPath: avatarPath ?? this.avatarPath,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      isPrivate: isPrivate ?? this.isPrivate,
      relationship: relationship ?? this.relationship,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      postCount: postCount ?? this.postCount,
    );
  }
}

class UserRelationship {
  final bool isFollowing;
  final bool isFollowedBy;
  final bool hasPendingFollowRequest;
  final bool isBlocked;
  final bool hasBlockedCurrentUser;

  const UserRelationship({
    this.isFollowing = false,
    this.isFollowedBy = false,
    this.hasPendingFollowRequest = false,
    this.isBlocked = false,
    this.hasBlockedCurrentUser = false,
  });

  factory UserRelationship.fromJson(Map<String, dynamic> json) {
    return UserRelationship(
      isFollowing: json['isFollowing'] as bool? ?? false,
      isFollowedBy: json['isFollowedBy'] as bool? ?? false,
      hasPendingFollowRequest:
          json['hasPendingFollowRequest'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
      hasBlockedCurrentUser:
          json['hasBlockedCurrentUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isFollowing': isFollowing,
      'isFollowedBy': isFollowedBy,
      'hasPendingFollowRequest': hasPendingFollowRequest,
      'isBlocked': isBlocked,
      'hasBlockedCurrentUser': hasBlockedCurrentUser,
    };
  }
}