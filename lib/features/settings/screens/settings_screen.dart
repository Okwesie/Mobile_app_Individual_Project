import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:adventure_logger/core/utils/app_router.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';
import 'package:adventure_logger/features/auth/auth_provider.dart';
import 'package:adventure_logger/features/settings/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _contactCtrl;
  bool _editingContact = false;
  bool _contactTextSeeded = false;

  @override
  void initState() {
    super.initState();
    _contactCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_contactTextSeeded) {
      _contactCtrl.text = context.read<SettingsProvider>().emergencyContact;
      _contactTextSeeded = true;
    }
  }

  @override
  void dispose() {
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text(
            'You will need to sign in again to access your logs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade700),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // ── Profile card ────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.headerGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _ProfileAvatar(
                  photoUrl: user?.photoURL,
                  name: user?.displayName ?? 'Explorer',
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Explorer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Emergency Contact ────────────────────────────────────────
          _SectionHeader('Emergency Contact'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _editingContact
                  ? Row(
                      key: const ValueKey('editing'),
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _contactCtrl,
                            keyboardType: TextInputType.phone,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: '+233 XX XXX XXXX',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.check_circle,
                              color: AppTheme.forestGreen, size: 30),
                          onPressed: () {
                            final number = _contactCtrl.text.trim();
                            // Basic phone validation
                            if (number.isNotEmpty &&
                                !RegExp(r'^\+?[\d\s\-()]{7,15}$')
                                    .hasMatch(number)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Enter a valid phone number.')),
                              );
                              return;
                            }
                            settings.setEmergencyContact(number);
                            setState(() => _editingContact = false);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.cancel_outlined,
                              color: Colors.grey.shade400, size: 28),
                          onPressed: () {
                            _contactCtrl.text =
                                settings.emergencyContact;
                            setState(() => _editingContact = false);
                          },
                        ),
                      ],
                    )
                  : Container(
                      key: const ValueKey('display'),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2EDE8)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              color: AppTheme.slate, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  settings.emergencyContact.isEmpty
                                      ? 'Not set'
                                      : settings.emergencyContact,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: settings.emergencyContact.isEmpty
                                        ? Colors.grey
                                        : AppTheme.deepGreen,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Used for GPS coordinates SMS dispatch',
                                  style: TextStyle(
                                      fontSize: 12, color: AppTheme.slate),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => _editingContact = true),
                            child: const Text('Edit'),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 8),

          // ── TTS ─────────────────────────────────────────────────────
          _SectionHeader('Text-to-Speech'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed_outlined,
                        color: AppTheme.slate, size: 18),
                    const SizedBox(width: 8),
                    Text('Reading speed: ${_rateLabel(settings.ttsRate)}',
                        style: const TextStyle(fontSize: 14)),
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

          // ── Notifications ────────────────────────────────────────────
          _SectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined,
                color: AppTheme.slate),
            title: const Text('Save confirmations'),
            subtitle: const Text('Notify when a log is saved'),
            value: settings.notificationsEnabled,
            activeThumbColor: AppTheme.forestGreen,
            activeTrackColor:
                AppTheme.forestGreen.withValues(alpha: 0.4),
            onChanged: (v) => settings.setNotificationsEnabled(v),
          ),

          const SizedBox(height: 8),

          // ── About ────────────────────────────────────────────────────
          _SectionHeader('About'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'Adventure Logger',
            subtitle: 'v1.0.0 · CS441 Final Project · Ashesi University',
          ),

          const SizedBox(height: 24),

          // ── Sign out ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
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

class _ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  const _ProfileAvatar({this.photoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          placeholder: (context, url) => _InitialsCircle(name: name),
          errorWidget: (context, url, error) => _InitialsCircle(name: name),
        ),
      );
    }
    return _InitialsCircle(name: name);
  }
}

class _InitialsCircle extends StatelessWidget {
  final String name;
  const _InitialsCircle({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.amber,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppTheme.deepGreen,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.slate),
      title: Text(title,
          style: TextStyle(
            color: title == 'Not set' ? Colors.grey : null,
          )),
      subtitle: subtitle != null ? Text(subtitle!) : null,
    );
  }
}
