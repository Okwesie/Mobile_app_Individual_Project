import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';
import 'package:adventure_logger/features/social/social_provider.dart';
import 'package:adventure_logger/features/social/screens/public_log_detail_screen.dart';
import 'package:adventure_logger/features/social/widgets/feed_log_card.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.deepGreen,
            title: const Text(
              'Community',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppTheme.headerGradient),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shared Logs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Public verified logs from adventurers',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: community.feedLoading
            ? const Center(child: CircularProgressIndicator())
            : community.feed.isEmpty
                ? _EmptyFeed(onRefresh: community.loadFeed)
                : RefreshIndicator(
                    onRefresh: community.loadFeed,
                    color: AppTheme.forestGreen,
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.only(top: 8, bottom: 100),
                      itemCount: community.feed.length,
                      itemBuilder: (context, i) {
                        final item = community.feed[i];
                        return CommunityLogCard(
                          item: item,
                          hasReacted: community.hasReacted(item.id),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PublicLogDetailScreen(entry: item),
                            ),
                          ),
                          onReact: () =>
                              community.toggleReaction(item.id),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _EmptyFeed({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.forestGreen,
      child: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F0E0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.public_rounded,
                          size: 48, color: AppTheme.slate),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No public logs yet',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: AppTheme.slate),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Be the first to share a verified log with the community.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
