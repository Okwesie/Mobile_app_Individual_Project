import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:adventure_logger/core/models/log_entry.dart';
import 'package:adventure_logger/core/utils/app_router.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';
import 'package:adventure_logger/features/auth/auth_provider.dart';
import 'package:adventure_logger/features/logs/log_provider.dart';
import 'package:adventure_logger/features/logs/widgets/lux_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final logProv = context.watch<LogProvider>();

    final filtered = _search.isEmpty
        ? logProv.logs
        : logProv.logs.where((l) {
            final q = _search.toLowerCase();
            return l.title.toLowerCase().contains(q) ||
                (l.locationName?.toLowerCase().contains(q) ?? false);
          }).toList();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          _AppHeader(user: auth.user, logCount: logProv.logs.length),
        ],
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Search logs...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _search = ''),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  isDense: true,
                ),
              ),
            ),

            // Log list
            Expanded(
              child: logProv.loading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                  ? _EmptyState(hasSearch: _search.isNotEmpty)
                  : RefreshIndicator(
                      onRefresh: () {
                        final provider = context.read<LogProvider>();
                        return provider.loadLogs();
                      },
                      color: AppTheme.forestGreen,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 100),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) =>
                            _LogCard(entry: filtered[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final provider = context.read<LogProvider>();
          await Navigator.pushNamed(context, AppRouter.newLog);
          if (!mounted) return;
          provider.loadLogs();
        },
        icon: const Icon(Icons.add),
        label: const Text('New Log'),
      ),
    );
  }
}

// ── App header ───────────────────────────────────────────────────────────────

class _AppHeader extends StatelessWidget {
  final dynamic user;
  final int logCount;
  const _AppHeader({required this.user, required this.logCount});

  @override
  Widget build(BuildContext context) {
    final name = (user?.displayName as String?)?.split(' ').first ?? 'Explorer';
    final photoUrl = user?.photoURL as String?;

    return SliverAppBar(
      expandedHeight: 148,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.deepGreen,
      // Title only shown when AppBar is collapsed
      title: Text(
        'My Logs',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        // No title here — prevents the double-render overlap
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Avatar(photoUrl: photoUrl, name: name),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $name 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$logCount log${logCount == 1 ? '' : 's'} recorded',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  const _Avatar({this.photoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          placeholder: (context, url) => _Initials(name: name),
          errorWidget: (context, url, error) => _Initials(name: name),
        ),
      );
    }
    return _Initials(name: name);
  }
}

class _Initials extends StatelessWidget {
  final String name;
  const _Initials({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppTheme.amber,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppTheme.deepGreen,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

// ── Log card ─────────────────────────────────────────────────────────────────

class _LogCard extends StatelessWidget {
  final LogEntry entry;
  const _LogCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d, yyyy · HH:mm');

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.delete_outline, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Log?'),
          content: Text('Delete "${entry.title}"? This cannot be undone.'),
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
      ),
      onDismissed: (_) {
        context.read<LogProvider>().deleteLog(entry);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('"${entry.title}" deleted.')));
      },
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(
            context,
            AppRouter.logDetail,
            arguments: entry,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(path: entry.photoPath),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (entry.locationName?.isNotEmpty == true)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: AppTheme.slate,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                entry.locationName!,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            df.format(entry.createdAt),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                          const Spacer(),
                          if (entry.luxReading != null)
                            LuxBadge(lux: entry.luxReading!),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.slate,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Thumbnail ────────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  final String? path;
  const _Thumbnail({this.path});

  @override
  Widget build(BuildContext context) {
    if (path != null && File(path!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(path!),
          width: 68,
          height: 68,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0E0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.terrain_rounded, color: AppTheme.slate, size: 30),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  const _EmptyState({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F0E0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch ? Icons.search_off : Icons.terrain_rounded,
                size: 52,
                color: AppTheme.slate,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasSearch ? 'No results found' : 'No logs yet',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppTheme.slate),
            ),
            const SizedBox(height: 10),
            Text(
              hasSearch
                  ? 'Try a different search term.'
                  : 'Tap + New Log to create your first Verified Log.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
