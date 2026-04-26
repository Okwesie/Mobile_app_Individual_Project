import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:adventure_logger/core/models/log_entry.dart';
import 'package:adventure_logger/core/services/database_service.dart';
import 'package:adventure_logger/core/services/firestore_service.dart';
import 'package:adventure_logger/core/services/notification_service.dart';
import 'package:adventure_logger/core/services/camera_service.dart';
import 'package:adventure_logger/core/services/user_service.dart';

class LogProvider extends ChangeNotifier {
  final DatabaseService _local = DatabaseService.instance;

  /// Lazy: [FirestoreService] touches Firebase; avoid eager init for tests / simple widgets.
  FirestoreService get _cloud => FirestoreService.instance;
  final NotificationService _notifs = NotificationService.instance;

  List<LogEntry> _logs = [];
  bool _loading = false;
  String? _error;
  String? _uid;

  List<LogEntry> get logs => List.unmodifiable(_logs);
  bool get loading => _loading;
  String? get error => _error;

  LogProvider() {
    if (Firebase.apps.isEmpty) return;

    // Seed from persisted auth immediately (synchronous — never null on restart
    // if the user was previously signed in).
    final current = FirebaseAuth.instance.currentUser;
    if (current != null) setUser(current.uid);

    // Stay in sync with sign-in / sign-out events.
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setUser(user?.uid);
    });
  }

  void setUser(String? uid) {
    if (_uid != uid) {
      _uid = uid;
      _logs = [];
      if (uid != null) loadLogs();
    }
  }

  Future<void> loadLogs() async {
    if (_uid == null) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Load from local SQLite first (instant, offline-capable)
      _logs = await _local.getLogsForUser(_uid!);
      notifyListeners();

      // Then sync from Firestore in background
      _syncFromFirestore();
    } catch (e) {
      _error = 'Failed to load logs: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Pull remote logs (remote wins per [firestoreId]), then push locals missing a cloud id.
  Future<void> _syncFromFirestore() async {
    if (_uid == null) return;
    try {
      final remote = await _cloud.getLogs(_uid!);

      // 1) Upsert each remote doc: same firestoreId → update local row (multi-device / edits).
      for (final r in remote) {
        final fsId = r.firestoreId;
        if (fsId == null) continue;

        final merged = r.copyWith(userId: _uid!);
        final idx = _logs.indexWhere((l) => l.firestoreId == fsId);

        if (idx >= 0) {
          final existing = _logs[idx];
          await _local.updateLog(merged.copyWith(id: existing.id));
        } else {
          await _local.insertLog(merged);
        }
      }

      _logs = await _local.getLogsForUser(_uid!);
      notifyListeners();

      // 2) Upload locals created offline so other devices can see them.
      for (final l in List<LogEntry>.from(_logs)) {
        if (l.firestoreId != null || l.id == null) continue;
        try {
          final fsId = await _cloud.saveLog(_uid!, l.copyWith(userId: _uid!));
          await _local.setFirestoreId(l.id!, fsId);
        } catch (_) {}
      }

      _logs = await _local.getLogsForUser(_uid!);
      notifyListeners();
    } catch (_) {
      // Silent — offline is fine
    }
  }

  Future<bool> saveLog(LogEntry entry, {bool notify = true}) async {
    if (_uid == null) return false;
    try {
      final withUid = entry.copyWith(userId: _uid);
      // 1. Save locally
      final localId = await _local.insertLog(withUid);
      var savedEntry = withUid.copyWith(id: localId);
      // 2. Save to Firestore (best-effort)
      try {
        final fsId = await _cloud.saveLog(_uid!, withUid);
        await _local.setFirestoreId(localId, fsId);
        savedEntry = savedEntry.copyWith(firestoreId: fsId);
      } catch (_) {}
      // 3. Sync to public_logs if public
      if (savedEntry.visibility == 'public') {
        await _syncPublicLog(savedEntry, isNew: true);
      }

      _logs = await _local.getLogsForUser(_uid!);
      notifyListeners();
      if (notify) await _notifs.showLogSaved(entry.title);
      return true;
    } catch (e) {
      _error = 'Failed to save log: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLog(LogEntry entry) async {
    if (_uid == null || entry.id == null) return false;
    try {
      final old = _logs.firstWhere(
        (l) => l.id == entry.id,
        orElse: () => entry,
      );
      await _local.updateLog(entry);
      try {
        if (entry.firestoreId != null) {
          await _cloud.updateLog(_uid!, entry);
        }
      } catch (_) {}
      // Sync public_logs
      if (entry.visibility == 'public') {
        await _syncPublicLog(entry, isNew: old.visibility != 'public');
      } else if (old.visibility == 'public') {
        await _removePublicLog(entry);
      }

      final idx = _logs.indexWhere((l) => l.id == entry.id);
      if (idx != -1) {
        _logs[idx] = entry;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update log: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLog(LogEntry entry) async {
    if (entry.id == null) return false;
    try {
      await _local.deleteLog(entry.id!);
      try {
        if (entry.firestoreId != null && _uid != null) {
          await _cloud.deleteLog(_uid!, entry.firestoreId!);
        }
      } catch (_) {}
      // Remove from public_logs if it was public
      if (entry.visibility == 'public') {
        await _removePublicLog(entry);
      }

      if (entry.photoPath != null) {
        await CameraService.instance.deletePhoto(entry.photoPath!);
      }
      _logs.removeWhere((e) => e.id == entry.id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete log: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> _syncPublicLog(LogEntry entry, {required bool isNew}) async {
    if (_uid == null || entry.id == null) return;
    final user = FirebaseAuth.instance.currentUser;
    await UserService.instance.syncPublicLog(
      log: entry,
      uid: _uid!,
      authorName: user?.displayName ?? 'Explorer',
      authorPhotoURL: user?.photoURL,
      isNew: isNew,
    );
  }

  Future<void> _removePublicLog(LogEntry entry) async {
    if (_uid == null || entry.id == null) return;
    await UserService.instance.removePublicLog(_uid!, entry);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
