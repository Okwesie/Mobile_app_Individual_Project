import 'package:flutter/material.dart';

class AdventurePlace {
  final String name;
  final String region;
  final String description;
  final String imageUrl;
  final List<String> highlights;
  final String bestTime;
  final String? difficulty;
  final String? entryFee;
  final String? tip;

  const AdventurePlace({
    required this.name,
    required this.region,
    required this.description,
    required this.imageUrl,
    required this.highlights,
    required this.bestTime,
    this.difficulty,
    this.entryFee,
    this.tip,
  });
}

class AdventureCategory {
  final String id;
  final String name;
  final String tagline;
  final IconData icon;
  final Color color;
  final String imageUrl;
  final List<AdventurePlace> places;

  const AdventureCategory({
    required this.id,
    required this.name,
    required this.tagline,
    required this.icon,
    required this.color,
    required this.imageUrl,
    required this.places,
  });
}
