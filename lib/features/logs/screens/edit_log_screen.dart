import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adventure_logger/core/models/log_entry.dart';
import 'package:adventure_logger/core/services/camera_service.dart';
import 'package:adventure_logger/core/services/location_service.dart';
import 'package:adventure_logger/core/services/sensor_service.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';
import 'package:adventure_logger/features/logs/log_provider.dart';
import 'package:adventure_logger/features/logs/widgets/lux_badge.dart';
import 'package:adventure_logger/features/logs/widgets/log_speech_mic_button.dart';

class EditLogScreen extends StatefulWidget {
  final LogEntry entry;
  const EditLogScreen({super.key, required this.entry});

  @override
  State<EditLogScreen> createState() => _EditLogScreenState();
}

class _EditLogScreenState extends State<EditLogScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _notesCtrl;

  String? _photoPath;
  bool _photoRemoved = false;

  LocationResult? _location;
  bool _loadingLocation = false;
  String? _locationError;

  double? _luxReading;
  bool _loadingLux = false;

  bool _saving = false;
  late String _visibility;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _titleCtrl = TextEditingController(text: e.title);
    _notesCtrl = TextEditingController(text: e.notes);
    _photoPath = e.photoPath;
    _visibility = e.visibility;

    // Pre-populate location from existing entry
    if (e.latitude != null && e.longitude != null) {
      _location = LocationResult(
        latitude: e.latitude!,
        longitude: e.longitude!,
        locationName: e.locationName ?? '',
      );
    }
    _luxReading = e.luxReading;
  }

  void _setVisibility(String v) {
    if (v == 'public' && _visibility != 'public') {
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Make this log public?'),
          content: const Text(
            'Your exact GPS coordinates and location name will not be shown in Community. Your photo, title, notes, light reading, and profile name will be visible to signed-in users. Avoid sharing phone numbers, home addresses, live location details, or anything sensitive in your notes/photo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _visibility = 'public');
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2D6A4F),
              ),
              child: const Text('Make Public'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _visibility = v);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      final path = await CameraService.instance.capturePhoto();
      if (path != null && mounted) {
        setState(() {
          _photoPath = path;
          _photoRemoved = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Camera error: $e')));
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final path = await CameraService.instance.pickFromGallery();
      if (path != null && mounted) {
        setState(() {
          _photoPath = path;
          _photoRemoved = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gallery error: $e')));
      }
    }
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationError = null;
    });
    try {
      final result = await LocationService.instance.getCurrentLocation();
      if (mounted) setState(() => _location = result);
    } catch (e) {
      if (mounted) setState(() => _locationError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _readLux() async {
    setState(() => _loadingLux = true);
    final lux = await SensorService.instance.readOnce();
    if (mounted) {
      setState(() {
        _luxReading = lux;
        _loadingLux = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final updated = widget.entry.copyWith(
      title: _titleCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      photoPath: _photoRemoved ? null : _photoPath,
      clearPhoto: _photoRemoved,
      latitude: _location?.latitude,
      longitude: _location?.longitude,
      locationName: _location?.locationName,
      luxReading: _luxReading,
      visibility: _visibility,
    );

    final ok = await context.read<LogProvider>().updateLog(updated);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log updated successfully.')),
      );
      Navigator.pop(context, updated);
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update log. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final condition = _luxReading != null
        ? SensorService.classify(_luxReading!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Log'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Title ────────────────────────────────────────────────
            _SectionLabel('Log Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'e.g. Summit attempt — Mt. Afadjato',
                prefixIcon: const Icon(Icons.title),
                suffixIcon: LogSpeechMicButton(
                  controller: _titleCtrl,
                  longForm: false,
                  combineWithExistingText: false,
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Title is required.';
                }
                if (v.trim().length < 3) return 'Title is too short.';
                return null;
              },
            ),

            const SizedBox(height: 24),

            // ── Photo ─────────────────────────────────────────────────
            _SectionLabel('Photo'),
            const SizedBox(height: 8),
            _photoPath != null &&
                    !_photoRemoved &&
                    File(_photoPath!).existsSync()
                ? Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_photoPath!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _capturePhoto,
                              icon: const Icon(Icons.camera_alt, size: 18),
                              label: const Text('Replace'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.forestGreen,
                                side: const BorderSide(
                                  color: AppTheme.forestGreen,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  setState(() => _photoRemoved = true),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('Remove'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
                                side: BorderSide(color: Colors.red.shade300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _capturePhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.forestGreen,
                            side: const BorderSide(color: AppTheme.forestGreen),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Gallery'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.forestGreen,
                            side: const BorderSide(color: AppTheme.forestGreen),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),

            const SizedBox(height: 24),

            // ── Location ──────────────────────────────────────────────
            _SectionLabel('Location'),
            const SizedBox(height: 8),
            if (_location != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF388E3C),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _location!.locationName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_location!.latitude.toStringAsFixed(6)}, '
                      '${_location!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF388E3C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ] else if (_locationError != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _locationError!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
              const SizedBox(height: 8),
            ],
            ElevatedButton.icon(
              onPressed: _loadingLocation ? null : _fetchLocation,
              icon: _loadingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.my_location),
              label: Text(
                _location == null ? 'Get Current Location' : 'Refresh Location',
              ),
            ),

            const SizedBox(height: 24),

            // ── Light Sensor ──────────────────────────────────────────
            _SectionLabel('Light Sensor'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDDDDD)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.light_mode_outlined,
                        color: AppTheme.forestGreen,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Ambient light reading',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      if (_luxReading != null && _luxReading! >= 0)
                        LuxBadge(lux: _luxReading!),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_loadingLux)
                    const Center(child: CircularProgressIndicator())
                  else if (_luxReading != null)
                    Text(
                      _luxReading! < 0
                          ? 'Sensor not available.'
                          : '${_luxReading!.toStringAsFixed(1)} lux — '
                                '${SensorService.conditionLabel(condition!)}. '
                                '${SensorService.safetyAdvice(condition)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.slate,
                      ),
                    )
                  else
                    const Text(
                      'No sensor reading recorded.',
                      style: TextStyle(color: AppTheme.slate),
                    ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _loadingLux ? null : _readLux,
                    icon: const Icon(Icons.sensors, size: 18),
                    label: Text(
                      _luxReading == null
                          ? 'Read Light Sensor'
                          : 'Re-read Sensor',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.forestGreen,
                      side: const BorderSide(color: AppTheme.forestGreen),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Notes ─────────────────────────────────────────────────
            _SectionLabel('Field Notes'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Trail conditions, hazards, observations...',
                alignLabelWithHint: true,
                suffixIcon: LogSpeechMicButton(
                  controller: _notesCtrl,
                  longForm: true,
                  combineWithExistingText: true,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Visibility ────────────────────────────────────────────
            _SectionLabel('Visibility'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'private',
                  label: Text('Private'),
                  icon: Icon(Icons.lock_outline, size: 16),
                ),
                ButtonSegment(
                  value: 'public',
                  label: Text('Public'),
                  icon: Icon(Icons.public_rounded, size: 16),
                ),
              ],
              selected: {_visibility},
              onSelectionChanged: (s) => _setVisibility(s.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppTheme.forestGreen,
                selectedForegroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Public posts hide GPS/location names, but your photo and notes are shared. Keep sensitive details out.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.slate,
                height: 1.35,
              ),
            ),

            const SizedBox(height: 32),

            // ── Save button ───────────────────────────────────────────
            ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving...' : 'Save Changes'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppTheme.deepGreen,
        letterSpacing: 0.3,
      ),
    );
  }
}
