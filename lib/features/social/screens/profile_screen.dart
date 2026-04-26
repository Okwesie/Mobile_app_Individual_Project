import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';
import 'package:adventure_logger/features/social/social_provider.dart';
import 'package:adventure_logger/features/social/widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editingBio = false;
  late TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    _bioCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveBio(CommunityProvider community) async {
    final bio = _bioCtrl.text.trim();
    await community.updateBio(bio);
    if (mounted) setState(() => _editingBio = false);
  }

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityProvider>();
    final profile = community.myProfile;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.deepGreen,
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.headerGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      UserAvatar(
                        photoURL: profile?.photoURL ?? user?.photoURL,
                        name:
                            profile?.displayName ??
                            user?.displayName ??
                            'Explorer',
                        size: 72,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        profile?.displayName ?? user?.displayName ?? 'Explorer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (user?.email != null)
                        Text(
                          user!.email!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            // Bio section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Bio',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.deepGreen,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      if (!_editingBio)
                        TextButton.icon(
                          onPressed: () {
                            _bioCtrl.text = profile?.bio ?? '';
                            setState(() => _editingBio = true);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.forestGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_editingBio) ...[
                    TextField(
                      controller: _bioCtrl,
                      maxLines: 3,
                      maxLength: 160,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Tell the community about yourself…',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _editingBio = false),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => _saveBio(community),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.forestGreen,
                          ),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ] else
                    Text(
                      profile?.bio.isNotEmpty == true
                          ? profile!.bio
                          : 'No bio yet. Tap Edit to add one.',
                      style: TextStyle(
                        color: profile?.bio.isNotEmpty == true
                            ? null
                            : Colors.grey.shade500,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Community stats
            if (profile != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: const Text(
                  'Stats',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.deepGreen,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              _StatTile(
                icon: Icons.public_rounded,
                label: 'Public logs shared',
                value: _countPublicLogs(profile.uid, community),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _countPublicLogs(String uid, CommunityProvider community) {
    return FutureBuilder<int>(
      future: community.countPublicLogsForUser(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        return Text(
          '${snapshot.data ?? 0}',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppTheme.deepGreen,
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget value;
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.forestGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.forestGreen, size: 20),
      ),
      title: Text(label),
      trailing: value,
    );
  }
}
