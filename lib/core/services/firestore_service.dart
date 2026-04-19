import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adventure_logger/core/models/log_entry.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _logsCol(String uid) =>
      _db.collection('users').doc(uid).collection('logs');

  Future<String> saveLog(String uid, LogEntry entry) async {
    final doc = await _logsCol(uid).add(entry.toFirestore(uid));
    return doc.id;
  }

  Future<void> updateLog(String uid, LogEntry entry) async {
    if (entry.firestoreId == null) return;
    await _logsCol(uid).doc(entry.firestoreId).update(entry.toFirestore(uid));
  }

  Future<void> deleteLog(String uid, String firestoreId) async {
    await _logsCol(uid).doc(firestoreId).delete();
  }

  Future<List<LogEntry>> getLogs(String uid) async {
    final snapshot = await _logsCol(uid)
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs
        .map((d) => LogEntry.fromFirestore(d.id, d.data()))
        .toList();
  }
}
