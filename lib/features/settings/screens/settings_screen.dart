import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';
import 'package:adventure_logger/features/settings/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _contactController;
  bool _contactEditing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _contactController = TextEditingController(
      text: context.read<SettingsProvider>().emergencyContact,
    );
  }

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _SectionHeader('Emergency Contact'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _contactEditing
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _contactController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: '+233 XX XXX XXXX',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          autofocus: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.check_circle,
                            color: AppTheme.forestGreen, size: 30),
                        onPressed: () {
                          settings.setEmergencyContact(
                              _contactController.text.trim());
                          setState(() => _contactEditing = false);
                        },
                      ),
                    ],
                  )
                : ListTile(
                    leading: const Icon(Icons.phone_outlined,
                        color: AppTheme.slate),
                    title: Text(
                      settings.emergencyContact.isEmpty
                          ? 'Not set'
                          : settings.emergencyContact,
                      style: TextStyle(
                        color: settings.emergencyContact.isEmpty
                            ? Colors.grey
                            : null,
                      ),
                    ),
                    subtitle:
                        const Text('Used for SMS coordinate dispatch'),
                    trailing: TextButton(
                      onPressed: () => setState(() => _contactEditing = true),
                      child: const Text('Edit'),
                    ),
                  ),
          ),

          const SizedBox(height: 16),
          _SectionHeader('Text-to-Speech'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed, color: AppTheme.slate, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Speed: ${_rateLabel(settings.ttsRate)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Slider(
                  value: settings.ttsRate,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  label: _rateLabel(settings.ttsRate),
                  activeColor: AppTheme.forestGreen,
                  onChanged: (v) => settings.setTtsRate(v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          _SectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined,
                color: AppTheme.slate),
            title: const Text('Save confirmations'),
            subtitle: const Text(
                'Show a notification when a log is saved'),
            value: settings.notificationsEnabled,
            activeThumbColor: AppTheme.forestGreen,
            activeTrackColor: AppTheme.forestGreen.withValues(alpha: 0.5),
            onChanged: (v) => settings.setNotificationsEnabled(v),
          ),

          const SizedBox(height: 24),
          _SectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppTheme.slate),
            title: const Text('Adventure Logger'),
            subtitle: const Text('v1.0.0 · CS441 Final Project · 2026'),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: AppTheme.slate),
            title: const Text('Caleb Okwesie Arthur'),
            subtitle: const Text('Ashesi University'),
          ),
        ],
      ),
    );
  }

  String _rateLabel(double rate) {
    if (rate <= 0.25) return 'Slow';
    if (rate <= 0.5) return 'Normal';
    if (rate <= 0.75) return 'Fast';
    return 'Very Fast';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.forestGreen,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
