class LogEntry {
  final int? id;
  final String? firestoreId;
  final String userId;
  final String title;
  final String notes;
  final String? photoPath;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final double? luxReading;
  final DateTime createdAt;

  const LogEntry({
    this.id,
    this.firestoreId,
    this.userId = '',
    required this.title,
    required this.notes,
    this.photoPath,
    this.latitude,
    this.longitude,
    this.locationName,
    this.luxReading,
    required this.createdAt,
  });

  // ── SQLite ────────────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'firestore_id': firestoreId,
        'user_id': userId,
        'title': title,
        'notes': notes,
        'photo_path': photoPath,
        'latitude': latitude,
        'longitude': longitude,
        'location_name': locationName,
        'lux_reading': luxReading,
        'created_at': createdAt.toIso8601String(),
      };

  factory LogEntry.fromMap(Map<String, dynamic> map) => LogEntry(
        id: map['id'] as int?,
        firestoreId: map['firestore_id'] as String?,
        userId: map['user_id'] as String? ?? '',
        title: map['title'] as String,
        notes: map['notes'] as String? ?? '',
        photoPath: map['photo_path'] as String?,
        latitude: map['latitude'] as double?,
        longitude: map['longitude'] as double?,
        locationName: map['location_name'] as String?,
        luxReading: map['lux_reading'] as double?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  // ── Firestore ─────────────────────────────────────────────────────────────

  Map<String, dynamic> toFirestore(String uid) => {
        'user_id': uid,
        'title': title,
        'notes': notes,
        'photo_path': photoPath,
        'latitude': latitude,
        'longitude': longitude,
        'location_name': locationName,
        'lux_reading': luxReading,
        'created_at': createdAt.toIso8601String(),
      };

  factory LogEntry.fromFirestore(
    String docId,
    Map<String, dynamic> data,
  ) =>
      LogEntry(
        firestoreId: docId,
        userId: data['user_id'] as String? ?? '',
        title: data['title'] as String? ?? '',
        notes: data['notes'] as String? ?? '',
        photoPath: data['photo_path'] as String?,
        latitude: (data['latitude'] as num?)?.toDouble(),
        longitude: (data['longitude'] as num?)?.toDouble(),
        locationName: data['location_name'] as String?,
        luxReading: (data['lux_reading'] as num?)?.toDouble(),
        createdAt: data['created_at'] != null
            ? DateTime.parse(data['created_at'] as String)
            : DateTime.now(),
      );

  // ── Helpers ───────────────────────────────────────────────────────────────

  LogEntry copyWith({
    int? id,
    String? firestoreId,
    String? userId,
    String? title,
    String? notes,
    String? photoPath,
    bool clearPhoto = false,
    double? latitude,
    double? longitude,
    String? locationName,
    double? luxReading,
    DateTime? createdAt,
  }) =>
      LogEntry(
        id: id ?? this.id,
        firestoreId: firestoreId ?? this.firestoreId,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        locationName: locationName ?? this.locationName,
        luxReading: luxReading ?? this.luxReading,
        createdAt: createdAt ?? this.createdAt,
      );

  String get ttsText {
    final parts = <String>[
      'Log entry: $title.',
      if (locationName != null && locationName!.isNotEmpty)
        'Location: $locationName.',
      if (luxReading != null && luxReading! >= 0)
        'Ambient light: ${luxReading!.toStringAsFixed(1)} lux.',
      if (notes.isNotEmpty) 'Notes: $notes.',
      'Recorded on ${_formatDate(createdAt)}.',
    ];
    return parts.join(' ');
  }

  String get smsText {
    final latStr = latitude?.toStringAsFixed(6) ?? 'unknown';
    final lonStr = longitude?.toStringAsFixed(6) ?? 'unknown';
    final loc = locationName ?? 'Unknown location';
    return 'ADVENTURE LOGGER — $title\n'
        'Location: $loc\n'
        'GPS: $latStr, $lonStr\n'
        'Time: ${_formatDate(createdAt)}\n'
        'Maps: https://maps.google.com/?q=$latStr,$lonStr';
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}
