import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adventure_logger/core/utils/app_router.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.camera_alt_rounded,
      iconBg: Color(0xFF1B4332),
      accentColor: AppTheme.lightGreen,
      title: 'Document Every Moment',
      subtitle:
          'Capture photos, record field notes, and build a visual archive of every trail you conquer.',
      tag: 'Camera · Gallery',
    ),
    _OnboardingPage(
      icon: Icons.gps_fixed_rounded,
      iconBg: Color(0xFF2D6A4F),
      accentColor: AppTheme.amber,
      title: 'Always Know Where You Are',
      subtitle:
          'Every log is pinned to your exact GPS coordinates with a human-readable location name and ambient light reading for safety context.',
      tag: 'GPS · Light Sensor',
    ),
    _OnboardingPage(
      icon: Icons.shield_outlined,
      iconBg: Color(0xFF40916C),
      accentColor: AppTheme.lightGreen,
      title: 'Safe, Even Offline',
      subtitle:
          'All data is stored locally — no signal required. Backed up to the cloud the moment you reconnect. Share your location via SMS in an emergency.',
      tag: 'Offline · Secure · SMS',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _pages[i],
              ),
            ),

            // Dots + button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppTheme.amber
                              : Colors.white30,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                          );
                        } else {
                          _finish();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.amber,
                        foregroundColor: AppTheme.deepGreen,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Next'
                            : 'Get Started',
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

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color accentColor;
  final String title;
  final String subtitle;
  final String tag;

  const _OnboardingPage({
    required this.icon,
    required this.iconBg,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Icon(icon, size: 72, color: accentColor),
          ),
          const SizedBox(height: 48),
          // Tag chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: accentColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
