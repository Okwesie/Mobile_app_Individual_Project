import 'dart:math' as math;

import 'package:adventure_logger/core/services/directions_service.dart';
import 'package:adventure_logger/core/services/location_service.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';
import 'package:adventure_logger/features/explore/models/adventure_models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AdventurePlaceDetailScreen extends StatefulWidget {
  final AdventurePlace place;
  final Color accentColor;

  const AdventurePlaceDetailScreen({
    super.key,
    required this.place,
    required this.accentColor,
  });

  @override
  State<AdventurePlaceDetailScreen> createState() =>
      _AdventurePlaceDetailScreenState();
}

class _AdventurePlaceDetailScreenState
    extends State<AdventurePlaceDetailScreen> {
  GoogleMapController? _mapController;
  LocationResult? _currentLocation;
  DirectionsResult? _directions;
  String? _errorMessage;
  String? _routeWarning;
  double? _straightLineDistanceMeters;
  bool _loadingRoute = true;

  LatLng get _destination =>
      LatLng(widget.place.latitude, widget.place.longitude);

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadRoute() async {
    setState(() {
      _loadingRoute = true;
      _errorMessage = null;
      _routeWarning = null;
    });

    try {
      final currentLocation = await LocationService.instance
          .getCurrentLocation();
      final straightLineDistanceMeters = Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        widget.place.latitude,
        widget.place.longitude,
      );

      DirectionsResult? directions;
      String? routeWarning;
      try {
        directions = await DirectionsService.instance.getRoute(
          originLatitude: currentLocation.latitude,
          originLongitude: currentLocation.longitude,
          destinationLatitude: widget.place.latitude,
          destinationLongitude: widget.place.longitude,
        );
      } catch (_) {
        routeWarning =
            'Route preview is unavailable. You can still open Google Maps.';
      }

      if (!mounted) return;
      setState(() {
        _currentLocation = currentLocation;
        _straightLineDistanceMeters = straightLineDistanceMeters;
        _directions = directions;
        _routeWarning = routeWarning;
        _loadingRoute = false;
      });
      _fitRouteToMap();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _loadingRoute = false;
      });
    }
  }

  Future<void> _openGoogleMaps() async {
    final origin = _currentLocation == null
        ? null
        : '${_currentLocation!.latitude},${_currentLocation!.longitude}';
    final params = <String, String>{
      'api': '1',
      'destination': '${widget.place.latitude},${widget.place.longitude}',
      'travelmode': 'driving',
    };
    if (origin != null) params['origin'] = origin;

    final uri = Uri.https('www.google.com', '/maps/dir/', params);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  Set<Marker> _markers() {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('destination'),
        position: _destination,
        infoWindow: InfoWindow(title: widget.place.name),
      ),
    };

    final currentLocation = _currentLocation;
    if (currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('origin'),
          position: LatLng(currentLocation.latitude, currentLocation.longitude),
          infoWindow: const InfoWindow(title: 'Your location'),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _polylines() {
    final points = _directions?.polylinePoints ?? const <LatLng>[];
    if (points.isEmpty) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: widget.accentColor,
        width: 5,
      ),
    };
  }

  void _fitRouteToMap() {
    final controller = _mapController;
    if (controller == null) return;

    final points = [
      if (_currentLocation != null)
        LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
      _destination,
      ...?_directions?.polylinePoints,
    ];
    if (points.length < 2) return;

    final bounds = _boundsFor(points);
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  LatLngBounds _boundsFor(List<LatLng> points) {
    var south = points.first.latitude;
    var north = points.first.latitude;
    var west = points.first.longitude;
    var east = points.first.longitude;

    for (final point in points.skip(1)) {
      south = math.min(south, point.latitude);
      north = math.max(north, point.latitude);
      west = math.min(west, point.longitude);
      east = math.max(east, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final color = widget.accentColor;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: color,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                place.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: place.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: color),
                    errorWidget: (context, url, error) =>
                        Container(color: color),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RegionPill(region: place.region, color: color),
                  const SizedBox(height: 14),
                  Text(
                    place.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A5568),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _RouteSummaryCard(
                    color: color,
                    loading: _loadingRoute,
                    directions: _directions,
                    straightLineDistanceMeters: _straightLineDistanceMeters,
                    errorMessage: _errorMessage,
                    routeWarning: _routeWarning,
                    onRefresh: _loadRoute,
                    onOpenMaps: _openGoogleMaps,
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 260,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _destination,
                          zoom: 10,
                        ),
                        myLocationEnabled: _currentLocation != null,
                        myLocationButtonEnabled: true,
                        markers: _markers(),
                        polylines: _polylines(),
                        onMapCreated: (controller) {
                          _mapController = controller;
                          _fitRouteToMap();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _InfoGrid(place: place, color: color),
                  const SizedBox(height: 20),
                  _HighlightsSection(place: place, color: color),
                  if (place.tip != null) ...[
                    const SizedBox(height: 20),
                    _TipCard(tip: place.tip!, color: color),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteSummaryCard extends StatelessWidget {
  final Color color;
  final bool loading;
  final DirectionsResult? directions;
  final double? straightLineDistanceMeters;
  final String? errorMessage;
  final String? routeWarning;
  final VoidCallback onRefresh;
  final VoidCallback onOpenMaps;

  const _RouteSummaryCard({
    required this.color,
    required this.loading,
    required this.directions,
    required this.straightLineDistanceMeters,
    required this.errorMessage,
    required this.routeWarning,
    required this.onRefresh,
    required this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    final directions = this.directions;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_rounded, color: color),
              const SizedBox(width: 8),
              const Text(
                'Directions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Refresh location',
                onPressed: loading ? null : onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (loading)
            const LinearProgressIndicator(minHeight: 3)
          else if (errorMessage != null)
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Route distance',
                    value: directions?.distanceLabel ?? 'Unavailable',
                    icon: Icons.route_outlined,
                    color: color,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(
                    label: 'Drive time',
                    value: directions?.durationLabel ?? 'Unavailable',
                    icon: Icons.schedule_rounded,
                    color: color,
                  ),
                ),
              ],
            ),
            if (straightLineDistanceMeters != null) ...[
              const SizedBox(height: 10),
              Text(
                'About ${_formatDistance(straightLineDistanceMeters!)} away in a straight line.',
                style: const TextStyle(color: AppTheme.slate, fontSize: 12.5),
              ),
            ],
            if (routeWarning != null) ...[
              const SizedBox(height: 8),
              Text(
                routeWarning!,
                style: const TextStyle(color: Colors.orange, fontSize: 12.5),
              ),
            ],
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOpenMaps,
              icon: const Icon(Icons.navigation_rounded),
              label: const Text('Open in Google Maps'),
              style: FilledButton.styleFrom(backgroundColor: color),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.round()} m';
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.slate,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1B4332),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionPill extends StatelessWidget {
  final String region;
  final Color color;

  const _RegionPill({required this.region, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.place_outlined, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            region,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final AdventurePlace place;
  final Color color;

  const _InfoGrid({required this.place, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: 'Best time',
            value: place.bestTime,
            icon: Icons.wb_sunny_outlined,
            color: color,
          ),
        ),
        if (place.entryFee != null) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _MetricTile(
              label: 'Entry fee',
              value: place.entryFee!,
              icon: Icons.confirmation_number_outlined,
              color: color,
            ),
          ),
        ],
      ],
    );
  }
}

class _HighlightsSection extends StatelessWidget {
  final AdventurePlace place;
  final Color color;

  const _HighlightsSection({required this.place, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HIGHLIGHTS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.slate,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: place.highlights
              .map(
                (highlight) => Chip(
                  label: Text(highlight),
                  labelStyle: TextStyle(color: color),
                  backgroundColor: color.withValues(alpha: 0.08),
                  side: BorderSide(color: color.withValues(alpha: 0.18)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  final String tip;
  final Color color;

  const _TipCard({required this.tip, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: color,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
