import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:adventure_logger/core/models/public_log_entry.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';
import 'package:adventure_logger/features/social/widgets/user_avatar.dart';

class CommunityLogCard extends StatelessWidget {
  final PublicLogEntry item;
  final bool hasReacted;
  final VoidCallback onTap;
  final VoidCallback onReact;

  const CommunityLogCard({
    super.key,
    required this.item,
    required this.hasReacted,
    required this.onTap,
    required this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d · HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Author row ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  UserAvatar(
                    photoURL: item.authorPhotoURL,
                    name: item.authorName,
                    size: 36,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          df.format(item.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.slate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.isVerified)
                    _VerifiedBadge()
                  else
                    const Icon(
                      Icons.public_rounded,
                      size: 14,
                      color: AppTheme.slate,
                    ),
                ],
              ),
            ),

            if (item.photoURL?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(0),
                ),
                child: CachedNetworkImage(
                  imageUrl: item.photoURL!,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 190,
                    color: AppTheme.forestGreen.withValues(alpha: 0.08),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 190,
                    color: AppTheme.forestGreen.withValues(alpha: 0.08),
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppTheme.slate,
                    ),
                  ),
                ),
              ),
            ],

            // ── Content ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (item.notes.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.notes,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF4A5568),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (item.luxReading != null) ...[
                    const SizedBox(height: 6),
                    _LuxChip(lux: item.luxReading!),
                  ],
                ],
              ),
            ),

            // ── Reaction row ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: onReact,
                    icon: Icon(
                      hasReacted
                          ? Icons.thumb_up_rounded
                          : Icons.thumb_up_outlined,
                      size: 18,
                      color: hasReacted ? AppTheme.forestGreen : AppTheme.slate,
                    ),
                    label: Text(
                      item.reactionCount > 0
                          ? '${item.reactionCount} Helpful'
                          : 'Helpful',
                      style: TextStyle(
                        fontSize: 13,
                        color: hasReacted
                            ? AppTheme.forestGreen
                            : AppTheme.slate,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.forestGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.forestGreen.withValues(alpha: 0.4)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 13, color: AppTheme.forestGreen),
          SizedBox(width: 4),
          Text(
            'Verified',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.forestGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxChip extends StatelessWidget {
  final double lux;
  const _LuxChip({required this.lux});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD966)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.light_mode_outlined,
            size: 12,
            color: Color(0xFFD4A017),
          ),
          const SizedBox(width: 4),
          Text(
            '${lux.toStringAsFixed(0)} lux',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFD4A017),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
