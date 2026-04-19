import 'package:flutter_test/flutter_test.dart';
import 'package:adventure_logger/core/models/log_entry.dart';
import 'package:adventure_logger/core/models/log_statistics.dart';

void main() {
  group('LogStatistics.fromLogs', () {
    test('empty logs yields zeros', () {
      final s = LogStatistics.fromLogs([]);
      expect(s.total, 0);
      expect(s.thisWeek, 0);
      expect(s.withLux, 0);
      expect(s.recentLogs, isEmpty);
    });

    test('counts GPS, notes, lux buckets', () {
      final now = DateTime.now();
      final logs = [
        LogEntry(
          title: 'A',
          notes: 'n',
          latitude: 1,
          luxReading: 1500,
          createdAt: now,
        ),
        LogEntry(
          title: 'B',
          notes: '',
          luxReading: 50,
          locationName: 'Park, GH',
          createdAt: now.subtract(const Duration(days: 1)),
        ),
      ];
      final s = LogStatistics.fromLogs(logs);
      expect(s.total, 2);
      expect(s.withGps, 1);
      expect(s.withNotes, 1);
      expect(s.withLux, 2);
      expect(s.luxBright, 1);
      expect(s.luxDim, 1);
      expect(s.mostFrequentLocation, 'Park');
      expect(s.recentLogs.length, 2);
    });
  });
}
