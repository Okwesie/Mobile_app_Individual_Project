import 'package:flutter_test/flutter_test.dart';
import 'package:adventure_logger/core/models/log_entry.dart';

void main() {
  group('LogEntry', () {
    test('fromMap round-trip preserves fields', () {
      final created = DateTime.utc(2025, 6, 1, 14, 30);
      final original = LogEntry(
        id: 42,
        firestoreId: 'fs1',
        userId: 'uid123',
        title: 'Summit',
        notes: 'Windy',
        photoPath: '/tmp/x.jpg',
        latitude: -1.5,
        longitude: 2.25,
        locationName: 'Peak, Region',
        luxReading: 150,
        createdAt: created,
      );

      final map = original.toMap();
      final restored = LogEntry.fromMap(map);

      expect(restored.id, 42);
      expect(restored.firestoreId, 'fs1');
      expect(restored.userId, 'uid123');
      expect(restored.title, 'Summit');
      expect(restored.notes, 'Windy');
      expect(restored.photoPath, '/tmp/x.jpg');
      expect(restored.latitude, -1.5);
      expect(restored.longitude, 2.25);
      expect(restored.locationName, 'Peak, Region');
      expect(restored.luxReading, 150);
      expect(restored.createdAt.toUtc(), created);
    });

    test('fromFirestore parses numeric lat/lon and missing created_at fallback', () {
      final entry = LogEntry.fromFirestore('docA', {
        'user_id': 'u',
        'title': 'T',
        'notes': '',
        'latitude': 5,
        'longitude': 10.5,
        'lux_reading': 3,
      });

      expect(entry.firestoreId, 'docA');
      expect(entry.latitude, 5.0);
      expect(entry.longitude, 10.5);
      expect(entry.luxReading, 3.0);
      expect(entry.createdAt.isBefore(DateTime.now().add(const Duration(seconds: 2))),
          isTrue);
    });

    test('smsText includes maps link with coordinates', () {
      final e = LogEntry(
        title: 'Trail',
        notes: '',
        latitude: 5.5,
        longitude: -0.25,
        locationName: 'Park',
        createdAt: DateTime.utc(2025, 1, 1),
      );
      expect(e.smsText, contains('maps.google.com'));
      expect(e.smsText, contains('5.500000'));
      expect(e.smsText, contains('-0.250000'));
    });

    test('copyWith clearPhoto removes photoPath', () {
      final e = LogEntry(
        title: 'A',
        notes: '',
        photoPath: '/p.jpg',
        createdAt: DateTime.now(),
      );
      final cleared = e.copyWith(clearPhoto: true);
      expect(cleared.photoPath, isNull);
    });
  });
}
