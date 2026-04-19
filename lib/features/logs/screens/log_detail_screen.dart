import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:adventure_logger/core/models/log_entry.dart';
import 'package:adventure_logger/core/services/tts_service.dart';
import 'package:adventure_logger/core/services/sms_service.dart';
import 'package:adventure_logger/core/services/sensor_service.dart';
import 'package:adventure_logger/core/utils/app_router.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';
import 'package:adventure_logger/features/logs/log_provider.dart';
import 'package:adventure_logger/features/logs/widgets/lux_badge.dart';
import 'package:adventure_logger/features/settings/settings_provider.dart';

class LogDetailScreen extends StatefulWidget {
  final LogEntry entry;
  const LogDetailScreen({super.key, required this.entry});

  @override
  State<LogDetailScreen> createState() => _LogDetailScreenState();
}

class _LogDetailScreenState extends State<LogDetailScreen> {
  late LogEntry _entry;
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  Future<void> _toggleTts() async {
    final tts = TtsService.instance;
    if (_speaking) {
      await tts.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }
    setState(() => _speaking = true);
    final rate = context.read<SettingsProvider>().ttsRate;
    await tts.speak(_entry.ttsText, rate: rate);
    if (mounted) setState(() => _speaking = false);
  }

  Future<void> _dispatchSms() async {
    final contact = context.read<SettingsProvider>().emergencyContact;
    final launched =
        await SmsService.instance.sendSms(number: contact, body: _entry.smsText);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open SMS app.')),
      );
    }
  }

  Future<void> _edit() async {
    final result = await Navigator.pushNamed(
      context,
      AppRouter.editLog,
      arguments: _entry,
    );
    if (result is LogEntry && mounted) {
      setState(() => _entry = result);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Log?'),
        content:
            Text('Delete "${_entry.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade700),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<LogProvider>().deleteLog(_entry);
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
    final condition = _entry.luxReading != null
        ? SensorService.classify(_entry.luxReading!)
        : null;
    final hasPhoto = _entry.photoPath != null &&
        File(_entry.photoPath!).existsSync();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: hasPhoto ? 280 : 160,
            pinned: true,
            backgroundColor: AppTheme.deepGreen,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                tooltip: 'Edit',
                onPressed: _edit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                tooltip: 'Delete',
                onPressed: _delete,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: hasPhoto
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(_entry.photoPath!),
                          fit: BoxFit.cover,
                        ),
                        // Gradient overlay so title is readable
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppTheme.deepGreen.withValues(alpha: 0.85),
                              ],
                              stops: const [0.4, 1.0],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      decoration: const BoxDecoration(
                          gradient: AppTheme.headerGradient),
                      child: const Center(
                        child: Icon(Icons.terrain_rounded,
                            size: 72, color: Colors.white24),
                      ),
                    ),
              title: Text(
                _entry.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              titlePadding: const EdgeInsetsDirectional.only(
                  start: 56, bottom: 16, end: 56),
            ),
          ),

          // ── Content ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date chip
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: AppTheme.slate),
                      const SizedBox(width: 6),
                      Text(
                        df.format(_entry.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Action chips ─────────────────────────────────
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _ActionChip(
                        icon: _speaking
                            ? Icons.stop_circle_outlined
                            : Icons.volume_up_outlined,
                        label: _speaking ? 'Stop' : 'Read Aloud',
                        color: AppTheme.forestGreen,
                        onTap: _toggleTts,
                      ),
                      _ActionChip(
                        icon: Icons.sms_outlined,
                        label: 'Send via SMS',
                        color: const Color(0xFF1565C0),
                        onTap: _dispatchSms,
                      ),
                      _ActionChip(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        color: AppTheme.amber,
                        onTap: _edit,
                        dark: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 20),

                  // ── Location ──────────────────────────────────────
                  _InfoCard(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    children: [
                      Text(
                        _entry.locationName ?? 'Not recorded',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (_entry.latitude != null &&
                          _entry.longitude != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${_entry.latitude!.toStringAsFixed(6)}, '
                          '${_entry.longitude!.toStringAsFixed(6)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Light Sensor ──────────────────────────────────
                  _InfoCard(
                    icon: Icons.light_mode_outlined,
                    title: 'Ambient Light',
                    trailing: _entry.luxReading != null && _entry.luxReading! >= 0
                        ? LuxBadge(lux: _entry.luxReading!)
                        : null,
                    children: [
                      Text(
                        _entry.luxReading == null
                            ? 'Not recorded'
                            : _entry.luxReading! < 0
                                ? 'Sensor unavailable on this device'
                                : '${_entry.luxReading!.toStringAsFixed(1)} lux'
                                    ' — ${SensorService.conditionLabel(condition!)}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (condition != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          SensorService.safetyAdvice(condition),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ),

                  // ── Notes ─────────────────────────────────────────
                  if (_entry.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.notes_outlined,
                      title: 'Field Notes',
                      children: [
                        Text(
                          _entry.notes,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool dark;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: dark ? AppTheme.deepGreen : color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: dark ? AppTheme.deepGreen : color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2EDE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.forestGreen),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.forestGreen,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}
