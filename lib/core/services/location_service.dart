import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String locationName;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });
}

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Requests permission if needed, then returns current position + name.
  /// Throws a [String] error message on failure.
  Future<LocationResult> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled. Please enable GPS.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission denied.';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permission permanently denied. Enable it in Settings.';
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    final name = await _reversGeocode(position.latitude, position.longitude);

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      locationName: name,
    );
  }

  Future<String> _reversGeocode(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon)
          .timeout(const Duration(seconds: 8));
      if (placemarks.isEmpty) return _coordsString(lat, lon);
      final p = placemarks.first;
      final parts = [
        p.name,
        p.locality,
        p.administrativeArea,
        p.country,
      ].where((e) => e != null && e.isNotEmpty).toList();
      return parts.isNotEmpty ? parts.join(', ') : _coordsString(lat, lon);
    } catch (_) {
      return _coordsString(lat, lon);
    }
  }

  String _coordsString(double lat, double lon) =>
      '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
}
