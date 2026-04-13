class LogEntry {
  final int? id;
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
    required this.title,
    required this.notes,
    this.photoPath,
    this.latitude,
    this.longitude,
    this.locationName,
    this.luxReading,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
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
        title: map['title'] as String,
        notes: map['notes'] as String? ?? '',
        photoPath: map['photo_path'] as String?,
        latitude: map['latitude'] as double?,
        longitude: map['longitude'] as double?,
        locationName: map['location_name'] as String?,
        luxReading: map['lux_reading'] as double?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  LogEntry copyWith({
    int? id,
    String? title,
    String? notes,
    String? photoPath,
    double? latitude,
    double? longitude,
    String? locationName,
    double? luxReading,
    DateTime? createdAt,
  }) =>
      LogEntry(
        id: id ?? this.id,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        photoPath: photoPath ?? this.photoPath,
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
      if (luxReading != null)
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
        'Google Maps: https://maps.google.com/?q=$latStr,$lonStr';
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

}
