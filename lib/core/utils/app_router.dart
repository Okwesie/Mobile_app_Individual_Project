import 'package:flutter/material.dart';
import 'package:adventure_logger/core/models/log_entry.dart';
import 'package:adventure_logger/features/auth/screens/splash_screen.dart';
import 'package:adventure_logger/features/logs/screens/home_screen.dart';
import 'package:adventure_logger/features/logs/screens/new_log_screen.dart';
import 'package:adventure_logger/features/logs/screens/log_detail_screen.dart';
import 'package:adventure_logger/features/settings/screens/settings_screen.dart';

abstract final class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String newLog = '/new-log';
  static const String logDetail = '/log-detail';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings_) {
    switch (settings_.name) {
      case splash:
        return _fade(const SplashScreen());
      case home:
        return _fade(const HomeScreen());
      case newLog:
        return _slide(const NewLogScreen());
      case logDetail:
        final entry = settings_.arguments as LogEntry;
        return _slide(LogDetailScreen(entry: entry));
      case settings:
        return _slide(const SettingsScreen());
      default:
        return _fade(const SplashScreen());
    }
  }

  static PageRoute<T> _fade<T>(Widget page) => PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      );

  static PageRoute<T> _slide<T>(Widget page) => PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      );
}
