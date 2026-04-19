import 'package:adventure_logger/core/models/log_entry.dart';
import 'package:adventure_logger/core/services/sensor_service.dart';

/// Aggregated stats for the Stats screen (pure logic — easy to unit test).
class LogStatistics {
  final int total;
  final int thisWeek;
  final int thisMonth;
  final int withGps;
  final int withPhoto;
  final int withNotes;
  final int withLux;
  final int luxBright;
  final int luxModerate;
  final int luxDim;
  final int luxDark;
  final String? mostFrequentLocation;
  final String? lastLocation;
  final List<LogEntry> recentLogs;

  const LogStatistics({
    required this.total,
    required this.thisWeek,
    required this.thisMonth,
    required this.withGps,
    required this.withPhoto,
    required this.withNotes,
    required this.withLux,
    required this.luxBright,
    required this.luxModerate,
    required this.luxDim,
    required this.luxDark,
    this.mostFrequentLocation,
    this.lastLocation,
    required this.recentLogs,
  });

  /// Computes stats from logs ordered newest-first (matches [DatabaseService] query).
  factory LogStatistics.fromLogs(List<LogEntry> logs) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthStart = DateTime(now.year, now.month, 1);

    var withGps = 0, withPhoto = 0, withNotes = 0, withLux = 0;
    var bright = 0, moderate = 0, dim = 0, dark = 0;
    final locFreq = <String, int>{};

    for (final l in logs) {
      if (l.latitude != null) withGps++;
      if (l.photoPath != null) withPhoto++;
      if (l.notes.isNotEmpty) withNotes++;
      if (l.luxReading != null && l.luxReading! >= 0) {
        withLux++;
        final c = SensorService.classify(l.luxReading!);
        switch (c) {
          case LightCondition.bright:
            bright++;
          case LightCondition.moderate:
            moderate++;
          case LightCondition.dim:
            dim++;
          case LightCondition.dark:
            dark++;
        }
      }
      if (l.locationName != null && l.locationName!.isNotEmpty) {
        final key = l.locationName!.split(',').first.trim();
        locFreq[key] = (locFreq[key] ?? 0) + 1;
      }
    }

    String? topLoc;
    if (locFreq.isNotEmpty) {
      topLoc = locFreq.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    final lastLoc = logs.isNotEmpty ? logs.first.locationName : null;
    final recentLogs = logs.take(5).toList();

    return LogStatistics(
      total: logs.length,
      thisWeek: logs.where((l) => l.createdAt.isAfter(weekAgo)).length,
      thisMonth: logs.where((l) => l.createdAt.isAfter(monthStart)).length,
      withGps: withGps,
      withPhoto: withPhoto,
      withNotes: withNotes,
      withLux: withLux,
      luxBright: bright,
      luxModerate: moderate,
      luxDim: dim,
      luxDark: dark,
      mostFrequentLocation: topLoc,
      lastLocation: lastLoc,
      recentLogs: recentLogs,
    );
  }
}
