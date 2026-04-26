class UserProfile {
  final String uid;
  final String displayName;
  final String? photoURL;
  final String bio;
  final int followersCount;
  final int followingCount;

  const UserProfile({
    required this.uid,
    required this.displayName,
    this.photoURL,
    this.bio = '',
    this.followersCount = 0,
    this.followingCount = 0,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) =>
      UserProfile(
        uid: uid,
        displayName: data['displayName'] as String? ?? 'Explorer',
        photoURL: data['photoURL'] as String?,
        bio: data['bio'] as String? ?? '',
        followersCount: (data['followersCount'] as num?)?.toInt() ?? 0,
        followingCount: (data['followingCount'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
        'bio': bio,
        'followersCount': followersCount,
        'followingCount': followingCount,
      };

  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    String? bio,
    int? followersCount,
    int? followingCount,
  }) =>
      UserProfile(
        uid: uid,
        displayName: displayName ?? this.displayName,
        photoURL: photoURL ?? this.photoURL,
        bio: bio ?? this.bio,
        followersCount: followersCount ?? this.followersCount,
        followingCount: followingCount ?? this.followingCount,
      );
}
