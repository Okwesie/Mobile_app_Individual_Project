import 'package:cloud_firestore/cloud_firestore.dart';

class PublicLogEntry {
  final String id;
  final String title;
  final String notes;
  final String? photoURL;
  final double? luxReading;
  final DateTime createdAt;
  final String authorUid;
  final String authorName;
  final String? authorPhotoURL;
  final bool isVerified;
  final int reactionCount;

  const PublicLogEntry({
    required this.id,
    required this.title,
    required this.notes,
    this.photoURL,
    this.luxReading,
    required this.createdAt,
    required this.authorUid,
    required this.authorName,
    this.authorPhotoURL,
    required this.isVerified,
    required this.reactionCount,
  });

  static PublicLogEntry fromFirestore(String id, Map<String, dynamic> d) {
    return PublicLogEntry(
      id: id,
      title: d['title'] as String? ?? '',
      notes: d['notes'] as String? ?? '',
      photoURL: d['photoURL'] as String?,
      luxReading: (d['luxReading'] as num?)?.toDouble(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      authorUid: d['authorUid'] as String? ?? '',
      authorName: d['authorName'] as String? ?? 'Explorer',
      authorPhotoURL: d['authorPhotoURL'] as String?,
      isVerified: d['isVerified'] as bool? ?? false,
      reactionCount: (d['reactionCount'] as num?)?.toInt() ?? 0,
    );
  }

  PublicLogEntry copyWith({int? reactionCount}) {
    return PublicLogEntry(
      id: id,
      title: title,
      notes: notes,
      photoURL: photoURL,
      luxReading: luxReading,
      createdAt: createdAt,
      authorUid: authorUid,
      authorName: authorName,
      authorPhotoURL: authorPhotoURL,
      isVerified: isVerified,
      reactionCount: reactionCount ?? this.reactionCount,
    );
  }
}
