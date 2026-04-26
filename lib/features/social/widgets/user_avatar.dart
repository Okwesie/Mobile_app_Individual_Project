import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String? photoURL;
  final String name;
  final double size;

  const UserAvatar({
    super.key,
    this.photoURL,
    required this.name,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (photoURL != null && photoURL!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoURL!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _Initials(name: name, size: size),
          errorWidget: (context, url, error) => _Initials(name: name, size: size),
        ),
      );
    }
    return _Initials(name: name, size: size);
  }
}

class _Initials extends StatelessWidget {
  final String name;
  final double size;
  const _Initials({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppTheme.amber,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: AppTheme.deepGreen,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}
