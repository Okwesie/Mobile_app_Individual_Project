import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:adventure_logger/core/models/public_log_entry.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';
import 'package:adventure_logger/features/social/social_provider.dart';
import 'package:adventure_logger/features/social/widgets/user_avatar.dart';

class PublicLogDetailScreen extends StatelessWidget {
  final PublicLogEntry entry;
  const PublicLogDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityProvider>();
    final currentEntry = community.feedEntry(entry.id) ?? entry;
    final hasReacted = community.hasReacted(currentEntry.id);
    final df = DateFormat('EEEE, MMMM d yyyy · HH:mm');

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.deepGreen,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.headerGradient,
                ),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentEntry.isVerified)
                      _VerifiedBadgeLarge()
                    else
                      const SizedBox.shrink(),
                    const SizedBox(height: 6),
                    Text(
                      currentEntry.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author row
                  Row(
                    children: [
                      UserAvatar(
                        photoURL: currentEntry.authorPhotoURL,
                        name: currentEntry.authorName,
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentEntry.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            df.format(currentEntry.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.slate,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (currentEntry.photoURL?.isNotEmpty == true) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: currentEntry.photoURL!,
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 240,
                          color: AppTheme.forestGreen.withValues(alpha: 0.08),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 240,
                          color: AppTheme.forestGreen.withValues(alpha: 0.08),
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppTheme.slate,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Lux reading
                  if (currentEntry.luxReading != null) ...[
                    _DetailRow(
                      icon: Icons.light_mode_outlined,
                      label: 'Light Reading',
                      value:
                          '${currentEntry.luxReading!.toStringAsFixed(1)} lux',
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Notes
                  if (currentEntry.notes.isNotEmpty) ...[
                    const Text(
                      'Field Notes',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.deepGreen,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDDDDDD)),
                      ),
                      child: Text(
                        currentEntry.notes,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Reaction button
                  OutlinedButton.icon(
                    onPressed: () => community.toggleReaction(currentEntry.id),
                    icon: Icon(
                      hasReacted
                          ? Icons.thumb_up_rounded
                          : Icons.thumb_up_outlined,
                      size: 20,
                      color: hasReacted ? AppTheme.forestGreen : AppTheme.slate,
                    ),
                    label: Text(
                      hasReacted
                          ? '${currentEntry.reactionCount} Helpful'
                          : currentEntry.reactionCount > 0
                          ? '${currentEntry.reactionCount} Helpful'
                          : 'Mark as Helpful',
                      style: TextStyle(
                        color: hasReacted
                            ? AppTheme.forestGreen
                            : AppTheme.slate,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: hasReacted
                            ? AppTheme.forestGreen
                            : const Color(0xFFCCCCCC),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
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
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerifiedBadgeLarge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 14, color: Colors.white),
          SizedBox(width: 5),
          Text(
            'Verified Log',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
