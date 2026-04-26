import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsResult {
  final int distanceMeters;
  final int durationSeconds;
  final String travelMode;
  final List<LatLng> polylinePoints;

  const DirectionsResult({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.travelMode,
    required this.polylinePoints,
  });

  String get distanceLabel {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '$distanceMeters m';
  }

  String get durationLabel {
    final minutes = (durationSeconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '$hours hr';
    return '$hours hr $remainingMinutes min';
  }
}

class DirectionsService {
  DirectionsService._();
  static final DirectionsService instance = DirectionsService._();

  final HttpsCallable _getRoute = FirebaseFunctions.instanceFor(
    region: 'us-central1',
  ).httpsCallable('getRoute');

  Future<DirectionsResult> getRoute({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    final response = await _getRoute.call<Map<String, dynamic>>({
      'origin': {'latitude': originLatitude, 'longitude': originLongitude},
      'destination': {
        'latitude': destinationLatitude,
        'longitude': destinationLongitude,
      },
      'travelMode': 'DRIVE',
    });

    final data = Map<String, dynamic>.from(response.data);
    final encodedPolyline = data['encodedPolyline'] as String? ?? '';

    return DirectionsResult(
      distanceMeters: (data['distanceMeters'] as num?)?.round() ?? 0,
      durationSeconds: (data['durationSeconds'] as num?)?.round() ?? 0,
      travelMode: data['travelMode'] as String? ?? 'DRIVE',
      polylinePoints: _decodePolyline(encodedPolyline),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var latitude = 0;
    var longitude = 0;

    while (index < encoded.length) {
      final latitudeChange = _decodeNextValue(encoded, index);
      index = latitudeChange.nextIndex;
      latitude += latitudeChange.value;

      final longitudeChange = _decodeNextValue(encoded, index);
      index = longitudeChange.nextIndex;
      longitude += longitudeChange.value;

      points.add(LatLng(latitude / 1e5, longitude / 1e5));
    }

    return points;
  }

  _PolylineValue _decodeNextValue(String encoded, int startIndex) {
    var result = 0;
    var shift = 0;
    var index = startIndex;
    int byte;

    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);

    final value = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
    return _PolylineValue(value: value, nextIndex: index);
  }
}

class _PolylineValue {
  final int value;
  final int nextIndex;

  const _PolylineValue({required this.value, required this.nextIndex});
}
