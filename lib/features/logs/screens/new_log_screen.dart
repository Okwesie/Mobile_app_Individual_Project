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

class NewLogScreen extends StatefulWidget {
  const NewLogScreen({super.key});

  @override
  State<NewLogScreen> createState() => _NewLogScreenState();
}

class _NewLogScreenState extends State<NewLogScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 4;

  // Step 1 — Title
  final _titleController = TextEditingController();
  final _titleKey = GlobalKey<FormState>();

  // Step 2 — Camera
  String? _photoPath;

  // Step 3 — GPS
  LocationResult? _location;
  bool _loadingLocation = false;
  String? _locationError;

  // Step 4 — Sensor + Notes
  double? _luxReading;
  bool _loadingLux = false;
  final _notesController = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final path = await CameraService.instance.capturePhoto();
      if (path != null && mounted) setState(() => _photoPath = path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e'),
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final path = await CameraService.instance.pickFromGallery();
      if (path != null && mounted) setState(() => _photoPath = path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery error: $e'),
              behavior: SnackBarBehavior.floating),
        );
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
    setState(() => _saving = true);

    final entry = LogEntry(
      title: _titleController.text.trim(),
      notes: _notesController.text.trim(),
      photoPath: _photoPath,
      latitude: _location?.latitude,
      longitude: _location?.longitude,
      locationName: _location?.locationName,
      luxReading: _luxReading,
      createdAt: DateTime.now(),
    );

    final ok = await context.read<LogProvider>().saveLog(entry);
    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save log. Try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _goBack),
        title: const Text('New Verified Log'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _StepProgressBar(
            current: _currentStep,
            total: _totalSteps,
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _currentStep = i),
        children: [
          _Step1Title(
            controller: _titleController,
            formKey: _titleKey,
            onNext: () {
              if (_titleKey.currentState!.validate()) _goNext();
            },
          ),
          _Step2Camera(
            photoPath: _photoPath,
            onCapture: _capturePhoto,
            onGallery: _pickFromGallery,
            onRemove: () => setState(() => _photoPath = null),
            onNext: _goNext,
          ),
          _Step3Gps(
            location: _location,
            loading: _loadingLocation,
            error: _locationError,
            onFetch: _fetchLocation,
            onNext: _goNext,
          ),
          _Step4SensorNotes(
            luxReading: _luxReading,
            loadingLux: _loadingLux,
            notesController: _notesController,
            onReadLux: _readLux,
            onSave: _save,
            saving: _saving,
          ),
        ],
      ),
    );
  }
}

// ─── Progress bar ───────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _StepProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: (current + 1) / total,
      backgroundColor: AppTheme.forestGreen.withValues(alpha: 0.3),
      valueColor: const AlwaysStoppedAnimation(Colors.white),
      minHeight: 4,
    );
  }
}

// ─── Step 1: Title ──────────────────────────────────────────────────────────

class _Step1Title extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final VoidCallback onNext;

  const _Step1Title({
    required this.controller,
    required this.formKey,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      step: 1,
      title: 'Name your log',
      subtitle: 'Give this entry a descriptive title.',
      icon: Icons.edit_note,
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Log Title',
                hintText: 'e.g. Summit attempt — Mt. Afadjato',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Title is required.';
                }
                if (v.trim().length < 3) return 'Title is too short.';
                return null;
              },
              onFieldSubmitted: (_) => onNext(),
            ),
            const SizedBox(height: 32),
            _NextButton(onTap: onNext, label: 'Next: Photo'),
          ],
        ),
      ),
    );
  }
}

// ─── Step 2: Camera ─────────────────────────────────────────────────────────

class _Step2Camera extends StatelessWidget {
  final String? photoPath;
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final VoidCallback onRemove;
  final VoidCallback onNext;

  const _Step2Camera({
    required this.photoPath,
    required this.onCapture,
    required this.onGallery,
    required this.onRemove,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      step: 2,
      title: 'Capture evidence',
      subtitle: 'Take a photo or pick one from your gallery.',
      icon: Icons.camera_alt_outlined,
      child: Column(
        children: [
          if (photoPath != null && File(photoPath!).existsSync()) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                File(photoPath!),
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Remove photo'),
              style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade700),
            ),
          ] else ...[
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0E0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.forestGreen.withValues(alpha: 0.3)),
              ),
              child: const Center(
                child: Icon(Icons.image_outlined,
                    size: 56, color: AppTheme.slate),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCapture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.forestGreen,
                      side: const BorderSide(color: AppTheme.forestGreen),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onGallery,
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
          ],
          const SizedBox(height: 32),
          _NextButton(
            onTap: onNext,
            label: 'Next: GPS',
            secondary: photoPath == null ? 'Skip — no photo' : null,
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: GPS ────────────────────────────────────────────────────────────

class _Step3Gps extends StatelessWidget {
  final LocationResult? location;
  final bool loading;
  final String? error;
  final VoidCallback onFetch;
  final VoidCallback onNext;

  const _Step3Gps({
    required this.location,
    required this.loading,
    required this.error,
    required this.onFetch,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      step: 3,
      title: 'Confirm location',
      subtitle: 'Tag this entry with your current GPS coordinates.',
      icon: Icons.gps_fixed,
      child: Column(
        children: [
          if (loading)
            const _PendingCard(
              icon: Icons.gps_not_fixed,
              message: 'Getting GPS fix...',
            )
          else if (location != null)
            _LocationCard(location: location!)
          else
            _PendingCard(
              icon: Icons.gps_off,
              message: error ?? 'No location yet.',
              isError: error != null,
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: loading ? null : onFetch,
            icon: loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.my_location),
            label:
                Text(location == null ? 'Get Current Location' : 'Refresh'),
          ),
          const SizedBox(height: 32),
          _NextButton(
            onTap: onNext,
            label: 'Next: Sensor & Notes',
            secondary: location == null ? 'Skip location' : null,
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final LocationResult location;
  const _LocationCard({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.check_circle,
                  color: Color(0xFF388E3C), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location.locationName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${location.latitude.toStringAsFixed(6)}, '
            '${location.longitude.toStringAsFixed(6)}',
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF388E3C)),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isError;
  const _PendingCard(
      {required this.icon, required this.message, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red.shade700 : AppTheme.slate;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isError
            ? Colors.red.shade50
            : const Color(0xFFF4F6F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isError
                ? Colors.red.shade200
                : const Color(0xFFCCCCCC)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 4: Sensor + Notes ─────────────────────────────────────────────────

class _Step4SensorNotes extends StatelessWidget {
  final double? luxReading;
  final bool loadingLux;
  final TextEditingController notesController;
  final VoidCallback onReadLux;
  final Future<void> Function() onSave;
  final bool saving;

  const _Step4SensorNotes({
    required this.luxReading,
    required this.loadingLux,
    required this.notesController,
    required this.onReadLux,
    required this.onSave,
    required this.saving,
  });

  @override
  Widget build(BuildContext context) {
    final condition =
        luxReading != null ? SensorService.classify(luxReading!) : null;

    return _StepWrapper(
      step: 4,
      title: 'Sensor & Notes',
      subtitle: 'Read ambient light and add any field notes.',
      icon: Icons.lightbulb_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lux reading card
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
                    const Icon(Icons.light_mode_outlined,
                        color: AppTheme.forestGreen),
                    const SizedBox(width: 8),
                    const Text(
                      'Light Sensor',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (luxReading != null) LuxBadge(lux: luxReading!),
                  ],
                ),
                const SizedBox(height: 12),
                if (loadingLux)
                  const Center(child: CircularProgressIndicator())
                else if (luxReading != null) ...[
                  Text(
                    luxReading! < 0
                        ? 'Sensor not available on this device.'
                        : '${luxReading!.toStringAsFixed(1)} lux  —  '
                            '${SensorService.conditionLabel(condition!)}',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    condition != null
                        ? SensorService.safetyAdvice(condition)
                        : '',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.slate),
                  ),
                ] else
                  const Text(
                    'Tap the button to read ambient light.',
                    style: TextStyle(color: AppTheme.slate),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: loadingLux ? null : onReadLux,
                    icon: const Icon(Icons.sensors),
                    label: Text(luxReading == null
                        ? 'Read Light Sensor'
                        : 'Re-read Sensor'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.forestGreen,
                      side:
                          const BorderSide(color: AppTheme.forestGreen),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Notes
          TextField(
            controller: notesController,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Field Notes (optional)',
              hintText: 'Trail conditions, hazards, observations...',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: Icon(Icons.notes),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.verified_outlined),
              label: Text(saving ? 'Saving...' : 'Save Verified Log'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared step wrapper ─────────────────────────────────────────────────────

class _StepWrapper extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _StepWrapper({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.forestGreen, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step $step of 4',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.slate,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final String? secondary;

  const _NextButton({
    required this.onTap,
    required this.label,
    this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        if (secondary != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onTap,
            child: Text(
              secondary!,
              style: const TextStyle(color: AppTheme.slate),
            ),
          ),
        ],
      ],
    );
  }
}
