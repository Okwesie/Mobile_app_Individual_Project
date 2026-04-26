import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';
import 'package:adventure_logger/features/explore/models/adventure_models.dart';
import 'package:adventure_logger/features/explore/screens/adventure_place_detail_screen.dart';

class AdventurePlacesScreen extends StatelessWidget {
  final AdventureCategory category;
  const AdventurePlacesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: category.color,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: category.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: category.color),
                    errorWidget: (context, url, error) =>
                        Container(color: category.color),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          category.color.withValues(alpha: 0.95),
                        ],
                        stops: const [0.35, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                category.icon,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              category.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category.tagline,
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
            ),
          ),

          // ── Count bar ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                '${category.places.length} DESTINATIONS IN GHANA'.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: category.color,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // ── Place cards ──────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _PlaceCard(
                place: category.places[i],
                accentColor: category.color,
              ),
              childCount: category.places.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatefulWidget {
  final AdventurePlace place;
  final Color accentColor;
  const _PlaceCard({required this.place, required this.accentColor});

  @override
  State<_PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<_PlaceCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final color = widget.accentColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo ────────────────────────────────────────────────
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: place.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: color.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.image_outlined,
                        color: color.withValues(alpha: 0.4),
                        size: 48,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: color.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.terrain_rounded,
                        color: color.withValues(alpha: 0.4),
                        size: 48,
                      ),
                    ),
                  ),
                  // Region badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.region,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Difficulty badge
                  if (place.difficulty != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _difficultyColor(place.difficulty!),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          place.difficulty!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Content ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    _expanded
                        ? place.description
                        : _truncate(place.description, 120),
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF4A5568),
                      height: 1.5,
                    ),
                  ),
                  if (place.description.length > 120)
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _expanded ? 'Show less' : 'Read more',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // ── Info row ─────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _InfoItem(
                          icon: Icons.wb_sunny_outlined,
                          label: 'Best Time',
                          value: place.bestTime,
                          color: color,
                        ),
                      ),
                      if (place.entryFee != null)
                        Expanded(
                          child: _InfoItem(
                            icon: Icons.confirmation_number_outlined,
                            label: 'Entry Fee',
                            value: place.entryFee!,
                            color: color,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Highlights ───────────────────────────────────
                  const Text(
                    'HIGHLIGHTS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.slate,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: place.highlights
                        .map((h) => _HighlightChip(text: h, color: color))
                        .toList(),
                  ),

                  // ── Tip ──────────────────────────────────────────
                  if (place.tip != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              place.tip!,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: color,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdventurePlaceDetailScreen(
                            place: place,
                            accentColor: color,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('View details & directions'),
                      style: FilledButton.styleFrom(backgroundColor: color),
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

  String _truncate(String text, int max) =>
      text.length <= max ? text : '${text.substring(0, max).trimRight()}…';

  Color _difficultyColor(String difficulty) {
    final d = difficulty.toLowerCase();
    if (d.contains('easy')) return Colors.green.shade600;
    if (d.contains('moderate')) return Colors.orange.shade700;
    if (d.contains('challeng')) return Colors.red.shade700;
    return AppTheme.slate;
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.slate,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _HighlightChip extends StatelessWidget {
  final String text;
  final Color color;
  const _HighlightChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
