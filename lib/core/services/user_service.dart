import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:adventure_logger/core/models/log_entry.dart';
import 'package:adventure_logger/core/models/public_log_entry.dart';
import 'package:adventure_logger/core/models/user_profile.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  // ── User Profile ─────────────────────────────────────────────────────────

  Future<void> createOrUpdateProfile({
    required String uid,
    required String displayName,
    String? photoURL,
  }) async {
    final doc = await _userDoc(uid).get();
    final data = <String, dynamic>{
      'displayName': displayName,
      if (!doc.exists) 'createdAt': FieldValue.serverTimestamp(),
    };
    if (photoURL != null) data['photoURL'] = photoURL;
    await _userDoc(uid).set(data, SetOptions(merge: true));
  }

  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfile.fromMap(uid, doc.data()!);
  }

  Future<void> updateBio(String uid, String bio) async {
    await _userDoc(uid).set({'bio': bio}, SetOptions(merge: true));
  }

  // ── Public Logs ──────────────────────────────────────────────────────────

  String _publicDocId(String uid, LogEntry log) {
    final firestoreId = log.firestoreId;
    if (firestoreId != null && firestoreId.isNotEmpty) {
      return '${uid}_$firestoreId';
    }
    return '${uid}_local_${log.id}';
  }

  String _localPublicDocId(String uid, int localId) => '${uid}_local_$localId';

  Future<void> syncPublicLog({
    required LogEntry log,
    required String uid,
    required String authorName,
    String? authorPhotoURL,
    required bool isNew,
  }) async {
    if (log.id == null) return;
    final docId = _publicDocId(uid, log);
    final isVerified =
        log.photoPath != null && log.latitude != null && log.luxReading != null;
    final data = <String, dynamic>{
      'title': log.title,
      'notes': log.notes,
      'locationName': FieldValue.delete(),
      'latitude': FieldValue.delete(),
      'longitude': FieldValue.delete(),
      if (log.luxReading != null) 'luxReading': log.luxReading,
      'createdAt': Timestamp.fromDate(log.createdAt),
      'authorUid': uid,
      'authorName': authorName,
      'isVerified': isVerified,
      if (isNew) 'reactionCount': 0,
    };
    if (authorPhotoURL != null) data['authorPhotoURL'] = authorPhotoURL;
    await _attachPublicPhoto(data: data, uid: uid, docId: docId, log: log);
    await _db
        .collection('public_logs')
        .doc(docId)
        .set(data, SetOptions(merge: true));

    final localDocId = _localPublicDocId(uid, log.id!);
    if (localDocId != docId) {
      await _deletePublicPhoto(uid, localDocId);
      await _deletePublicLog(localDocId);
    }
  }

  Future<void> removePublicLog(String uid, LogEntry log) async {
    final docId = _publicDocId(uid, log);
    await _deletePublicPhoto(uid, docId);
    await _deletePublicLog(docId);
    if (log.id != null) {
      final localDocId = _localPublicDocId(uid, log.id!);
      await _deletePublicPhoto(uid, localDocId);
      await _deletePublicLog(localDocId);
    }
  }

  Future<void> _deletePublicLog(String docId) async {
    try {
      await _db.collection('public_logs').doc(docId).delete();
    } catch (_) {}
  }

  Future<void> _attachPublicPhoto({
    required Map<String, dynamic> data,
    required String uid,
    required String docId,
    required LogEntry log,
  }) async {
    final photoPath = log.photoPath;
    if (photoPath == null || photoPath.isEmpty) {
      data['photoURL'] = FieldValue.delete();
      data['storagePath'] = FieldValue.delete();
      await _deletePublicPhoto(uid, docId);
      return;
    }

    final file = File(photoPath);
    if (!await file.exists()) {
      data['photoURL'] = FieldValue.delete();
      data['storagePath'] = FieldValue.delete();
      await _deletePublicPhoto(uid, docId);
      return;
    }

    final ref = _publicPhotoRef(uid, docId);
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    data['photoURL'] = await ref.getDownloadURL();
    data['storagePath'] = ref.fullPath;
  }

  Reference _publicPhotoRef(String uid, String docId) =>
      _storage.ref('public_log_photos/$uid/$docId.jpg');

  Future<void> _deletePublicPhoto(String uid, String docId) async {
    try {
      await _publicPhotoRef(uid, docId).delete();
    } catch (_) {}
  }

  Future<List<PublicLogEntry>> getCommunityFeed() async {
    final snap = await _db
        .collection('public_logs')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snap.docs
        .map((d) => PublicLogEntry.fromFirestore(d.id, d.data()))
        .toList();
  }

  Future<bool> getMyReaction(String logDocId, String uid) async {
    final doc = await _db
        .collection('public_logs')
        .doc(logDocId)
        .collection('reactions')
        .doc(uid)
        .get();
    return doc.exists;
  }

  Future<int> countPublicLogsForUser(String uid) async {
    final snap = await _db
        .collection('public_logs')
        .where('authorUid', isEqualTo: uid)
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<void> toggleReaction({
    required String logDocId,
    required String uid,
    required bool currentlyReacted,
  }) async {
    final reactionRef = _db
        .collection('public_logs')
        .doc(logDocId)
        .collection('reactions')
        .doc(uid);
    final logRef = _db.collection('public_logs').doc(logDocId);
    final batch = _db.batch();
    if (currentlyReacted) {
      batch.delete(reactionRef);
      batch.update(logRef, {'reactionCount': FieldValue.increment(-1)});
    } else {
      batch.set(reactionRef, {'reactedAt': FieldValue.serverTimestamp()});
      batch.update(logRef, {'reactionCount': FieldValue.increment(1)});
    }
    await batch.commit();
  }
}
