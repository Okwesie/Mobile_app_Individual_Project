import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';
import 'package:adventure_logger/features/logs/log_provider.dart';
import 'package:adventure_logger/features/onboarding/screens/onboarding_screen.dart';
import 'package:adventure_logger/features/stats/screens/stats_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OnboardingScreen shows first slide content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: OnboardingScreen()),
    );
    await tester.pump();
    expect(find.textContaining('Document'), findsOneWidget);
  });

  testWidgets('StatsScreen shows header (LogProvider does not init Firestore until sync)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => LogProvider(),
          child: const StatsScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Your Stats'), findsOneWidget);
  });

  testWidgets('MaterialApp uses AppTheme (shell smoke)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Builder(
          builder: (context) {
            expect(
              Theme.of(context).colorScheme.primary,
              AppTheme.forestGreen,
            );
            return const Scaffold(body: SizedBox.shrink());
          },
        ),
      ),
    );
    await tester.pump();
  });
}
