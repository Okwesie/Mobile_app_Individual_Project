import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:adventure_logger/core/models/log_entry.dart';
import 'package:adventure_logger/core/services/tts_service.dart';
import 'package:adventure_logger/core/services/sms_service.dart';
import 'package:adventure_logger/core/services/sensor_service.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';
import 'package:adventure_logger/features/logs/widgets/lux_badge.dart';
import 'package:adventure_logger/features/logs/log_provider.dart';
import 'package:adventure_logger/features/settings/settings_provider.dart';

class LogDetailScreen extends StatefulWidget {
  final LogEntry entry;
  const LogDetailScreen({super.key, required this.entry});

  @override
  State<LogDetailScreen> createState() => _LogDetailScreenState();
}

class _LogDetailScreenState extends State<LogDetailScreen> {
  bool _speaking = false;

  Future<void> _toggleTts() async {
    final tts = TtsService.instance;
    if (_speaking) {
      await tts.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }
    setState(() => _speaking = true);
    final rate =
        context.read<SettingsProvider>().ttsRate;
    await tts.speak(widget.entry.ttsText, rate: rate);
    if (mounted) setState(() => _speaking = false);
  }

  Future<void> _dispatchSms() async {
    final contact =
        context.read<SettingsProvider>().emergencyContact;
    final body = widget.entry.smsText;
    final launched =
        await SmsService.instance.sendSms(number: contact, body: body);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open SMS app.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Log?'),
        content: Text('Delete "${widget.entry.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<LogProvider>().deleteLog(widget.entry);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEEE, MMMM d yyyy · HH:mm');
    final entry = widget.entry;
    final condition =
        entry.luxReading != null ? SensorService.classify(entry.luxReading!) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete log',
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero photo
            if (entry.photoPath != null && File(entry.photoPath!).existsSync())
              SizedBox(
                width: double.infinity,
                height: 260,
                child: Image.file(
                  File(entry.photoPath!),
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 160,
                color: const Color(0xFFE8F0E0),
                child: const Center(
                  child: Icon(Icons.terrain_rounded,
                      size: 72, color: AppTheme.slate),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    entry.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    df.format(entry.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Location
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: entry.locationName ?? 'Not recorded',
                  ),
                  if (entry.latitude != null && entry.longitude != null) ...[
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: Icons.gps_fixed,
                      label: 'Coordinates',
                      value:
                          '${entry.latitude!.toStringAsFixed(6)}, '
                          '${entry.longitude!.toStringAsFixed(6)}',
                      monospace: true,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Light sensor
                  _InfoRow(
                    icon: Icons.light_mode_outlined,
                    label: 'Light Reading',
                    value: entry.luxReading == null
                        ? 'Not recorded'
                        : entry.luxReading! < 0
                            ? 'Sensor unavailable'
                            : '${entry.luxReading!.toStringAsFixed(1)} lux'
                                ' — ${SensorService.conditionLabel(condition!)}',
                    trailing: entry.luxReading != null && entry.luxReading! >= 0
                        ? LuxBadge(lux: entry.luxReading!)
                        : null,
                  ),
                  if (condition != null) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 28),
                      child: Text(
                        SensorService.safetyAdvice(condition),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],

                  // Notes
                  if (entry.notes.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Field Notes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.notes,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Action buttons
                  _ActionButton(
                    icon: _speaking ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
                    label: _speaking ? 'Stop Reading' : 'Read Aloud (TTS)',
                    color: AppTheme.forestGreen,
                    onTap: _toggleTts,
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    icon: Icons.sms_outlined,
                    label: 'Send Location via SMS',
                    color: const Color(0xFF1565C0),
                    onTap: _dispatchSms,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool monospace;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.monospace = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.slate),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.slate,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: monospace ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
