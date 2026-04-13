import 'package:flutter/foundation.dart';
import 'package:adventure_logger/core/models/log_entry.dart';
import 'package:adventure_logger/core/services/database_service.dart';
import 'package:adventure_logger/core/services/notification_service.dart';
import 'package:adventure_logger/core/services/camera_service.dart';

class LogProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final NotificationService _notifs = NotificationService.instance;

  List<LogEntry> _logs = [];
  bool _loading = false;
  String? _error;

  List<LogEntry> get logs => List.unmodifiable(_logs);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadLogs() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _logs = await _db.getAllLogs();
    } catch (e) {
      _error = 'Failed to load logs: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> saveLog(LogEntry entry) async {
    try {
      final id = await _db.insertLog(entry);
      final saved = entry.copyWith(id: id);
      _logs.insert(0, saved);
      notifyListeners();
      await _notifs.showLogSaved(entry.title);
      return true;
    } catch (e) {
      _error = 'Failed to save log: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLog(LogEntry entry) async {
    if (entry.id == null) return false;
    try {
      await _db.deleteLog(entry.id!);
      // Delete associated photo file
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
