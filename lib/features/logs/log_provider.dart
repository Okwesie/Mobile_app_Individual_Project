import 'package:flutter/foundation.dart';
import 'package:adventure_logger/core/models/log_entry.dart';
import 'package:adventure_logger/core/services/database_service.dart';
import 'package:adventure_logger/core/services/firestore_service.dart';
import 'package:adventure_logger/core/services/notification_service.dart';
import 'package:adventure_logger/core/services/camera_service.dart';

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

  Future<bool> saveLog(LogEntry entry) async {
    if (_uid == null) return false;
    try {
      final withUid = entry.copyWith(userId: _uid);
      // 1. Save locally
      final localId = await _local.insertLog(withUid);
      // 2. Save to Firestore (best-effort)
      try {
        final fsId = await _cloud.saveLog(_uid!, withUid);
        await _local.setFirestoreId(localId, fsId);
      } catch (_) {}

      _logs = await _local.getLogsForUser(_uid!);
      notifyListeners();
      await _notifs.showLogSaved(entry.title);
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
      await _local.updateLog(entry);
      try {
        if (entry.firestoreId != null) {
          await _cloud.updateLog(_uid!, entry);
        }
      } catch (_) {}

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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
