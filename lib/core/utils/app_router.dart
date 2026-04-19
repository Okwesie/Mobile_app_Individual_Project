import 'package:flutter/material.dart';
import 'package:adventure_logger/core/models/log_entry.dart';
import 'package:adventure_logger/features/auth/screens/splash_screen.dart';
import 'package:adventure_logger/features/auth/screens/login_screen.dart';
import 'package:adventure_logger/features/auth/screens/signup_screen.dart';
import 'package:adventure_logger/features/onboarding/screens/onboarding_screen.dart';
import 'package:adventure_logger/features/logs/screens/home_screen.dart';
import 'package:adventure_logger/features/logs/screens/new_log_screen.dart';
import 'package:adventure_logger/features/logs/screens/edit_log_screen.dart';
import 'package:adventure_logger/features/logs/screens/log_detail_screen.dart';
import 'package:adventure_logger/features/settings/screens/settings_screen.dart';
import 'package:adventure_logger/features/shell/main_shell.dart';

abstract final class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String shell = '/shell';
  static const String home = '/home';
  static const String newLog = '/new-log';
  static const String editLog = '/edit-log';
  static const String logDetail = '/log-detail';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case splash:
        return _fade(const SplashScreen());
      case onboarding:
        return _fade(const OnboardingScreen());
      case login:
        return _fade(const LoginScreen());
      case signup:
        return _slide(const SignupScreen());
      case shell:
        return _fade(const MainShell());
      case home:
        return _fade(const HomeScreen());
      case newLog:
        return _slide(const NewLogScreen());
      case editLog:
        final entry = s.arguments as LogEntry;
        return _slide(EditLogScreen(entry: entry));
      case logDetail:
        final entry = s.arguments as LogEntry;
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
        transitionDuration: const Duration(milliseconds: 350),
      );

  static PageRoute<T> _slide<T>(Widget page) => PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      );
}
