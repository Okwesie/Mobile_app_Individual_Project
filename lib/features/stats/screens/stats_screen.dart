import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:adventure_logger/core/models/log_entry.dart';
import 'package:adventure_logger/core/models/log_statistics.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';
import 'package:adventure_logger/features/logs/log_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<LogProvider>().logs;
    final topInset = MediaQuery.paddingOf(context).top;

    final stats = LogStatistics.fromLogs(logs);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          // Single header block (no FlexibleSpaceBar title — it overlapped "Your Stats")
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppTheme.headerGradient,
              ),
              padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 22),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Stats',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'A summary of all your logged adventures.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: logs.isEmpty
                ? _EmptyStats()
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Overview row ────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.library_books_outlined,
                                value: '${stats.total}',
                                label: 'Total Logs',
                                color: AppTheme.forestGreen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.today_outlined,
                                value: '${stats.thisWeek}',
                                label: 'This Week',
                                color: AppTheme.amber,
                                dark: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.calendar_month_outlined,
                                value: '${stats.thisMonth}',
                                label: 'This Month',
                                color: AppTheme.midGreen,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Location coverage ───────────────────────
                        _SectionLabel('Location Coverage'),
                        const SizedBox(height: 10),
                        _InfoCard(
                          child: Column(
                            children: [
                              _DataRow(
                                icon: Icons.location_on_outlined,
                                label: 'Logs with GPS',
                                value:
                                    '${stats.withGps} / ${stats.total}',
                                color: AppTheme.forestGreen,
                              ),
                              if (stats.mostFrequentLocation != null) ...[
                                const _Divider(),
                                _DataRow(
                                  icon: Icons.star_outline,
                                  label: 'Most logged area',
                                  value: stats.mostFrequentLocation!,
                                  color: AppTheme.amber,
                                ),
                              ],
                              if (stats.lastLocation != null) ...[
                                const _Divider(),
                                _DataRow(
                                  icon: Icons.history_outlined,
                                  label: 'Last location',
                                  value: stats.lastLocation!,
                                  color: AppTheme.slate,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Light conditions ────────────────────────
                        _SectionLabel('Light Conditions Recorded'),
                        const SizedBox(height: 10),
                        _InfoCard(
                          child: Column(
                            children: [
                              _LightBar(
                                label: 'Bright',
                                count: stats.luxBright,
                                total: stats.withLux,
                                color: Colors.amber.shade600,
                                icon: Icons.wb_sunny,
                              ),
                              const SizedBox(height: 10),
                              _LightBar(
                                label: 'Moderate',
                                count: stats.luxModerate,
                                total: stats.withLux,
                                color: Colors.orange.shade500,
                                icon: Icons.wb_cloudy_outlined,
                              ),
                              const SizedBox(height: 10),
                              _LightBar(
                                label: 'Dim',
                                count: stats.luxDim,
                                total: stats.withLux,
                                color: Colors.blueGrey.shade500,
                                icon: Icons.nights_stay_outlined,
                              ),
                              const SizedBox(height: 10),
                              _LightBar(
                                label: 'Dark',
                                count: stats.luxDark,
                                total: stats.withLux,
                                color: Colors.indigo.shade600,
                                icon: Icons.dark_mode,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Activity timeline ───────────────────────
                        _SectionLabel('Recent Activity'),
                        const SizedBox(height: 10),
                        _InfoCard(
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i < stats.recentLogs.length;
                                  i++) ...[
                                if (i > 0) const _Divider(),
                                _TimelineRow(
                                    entry: stats.recentLogs[i],
                                    isFirst: i == 0),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Photo coverage ──────────────────────────
                        _SectionLabel('Documentation Quality'),
                        const SizedBox(height: 10),
                        _InfoCard(
                          child: Column(
                            children: [
                              _DataRow(
                                icon: Icons.photo_camera_outlined,
                                label: 'Logs with photo',
                                value:
                                    '${stats.withPhoto} / ${stats.total}',
                                color: AppTheme.forestGreen,
                              ),
                              const _Divider(),
                              _DataRow(
                                icon: Icons.notes_outlined,
                                label: 'Logs with field notes',
                                value:
                                    '${stats.withNotes} / ${stats.total}',
                                color: AppTheme.midGreen,
                              ),
                              const _Divider(),
                              _DataRow(
                                icon: Icons.sensors,
                                label: 'Logs with sensor data',
                                value:
                                    '${stats.withLux} / ${stats.total}',
                                color: AppTheme.amber,
                              ),
                            ],
                          ),
                        ),

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

// ── Widgets ───────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool dark;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: dark ? AppTheme.deepGreen : color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: dark ? AppTheme.deepGreen : color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DataRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.slate),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.deepGreen,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _LightBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final IconData icon;

  const _LightBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.slate),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: count > 0 ? color : Colors.grey.shade400,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final LogEntry entry;
  final bool isFirst;

  const _TimelineRow({required this.entry, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d · HH:mm');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isFirst ? AppTheme.forestGreen : AppTheme.slate,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepGreen,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                [
                  df.format(entry.createdAt),
                  if (entry.locationName?.isNotEmpty == true)
                    entry.locationName!.split(',').first,
                ].join(' · '),
                style: const TextStyle(fontSize: 11, color: AppTheme.slate),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, color: Color(0xFFEEF2EE)),
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
        letterSpacing: 0.2,
      ),
    );
  }
}

class _EmptyStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F0E0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bar_chart_rounded,
                size: 52, color: AppTheme.slate),
          ),
          const SizedBox(height: 24),
          const Text(
            'No data yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.slate,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first log to see stats here.',
            style: TextStyle(color: AppTheme.slate, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
