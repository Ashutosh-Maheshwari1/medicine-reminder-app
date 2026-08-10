import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/app_logo_widget.dart';

/// Onboarding data model for each page
class _OnboardPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final List<_FeaturePill> pills;

  const _OnboardPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.pills,
  });
}

class _FeaturePill {
  final String label;
  final IconData icon;
  const _FeaturePill(this.label, this.icon);
}

/// First-time onboarding screen with 3 animated pages
/// Shown only once, then stores a flag in SharedPreferences.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const OnboardingScreen({super.key, required this.onFinished});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _bgAnimController;
  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  static const _pages = [
    _OnboardPage(
      title: 'MediTrack AI',
      subtitle: 'Never Miss a Dose Again',
      description:
          'Your intelligent medicine companion. Set smart reminders, track your doses, '
          'and stay on top of your health — all in one beautiful app.',
      icon: Icons.medication_rounded,
      gradientColors: [Color(0xFF1A5BB8), Color(0xFF2F80ED), Color(0xFF56CCF2)],
      pills: [
        _FeaturePill('Smart Reminders', Icons.alarm_rounded),
        _FeaturePill('Cloud Sync', Icons.cloud_sync_rounded),
        _FeaturePill('AI Powered', Icons.psychology_rounded),
      ],
    ),
    _OnboardPage(
      title: 'Track & Analyze',
      subtitle: 'Know Your Adherence Score',
      description:
          'Interactive charts show your weekly and monthly medication adherence. '
          'Export professional PDF reports for your doctor visits.',
      icon: Icons.insert_chart_rounded,
      gradientColors: [Color(0xFF6B2F9E), Color(0xFF9B51E0), Color(0xFFBB8EF8)],
      pills: [
        _FeaturePill('Adherence Charts', Icons.bar_chart_rounded),
        _FeaturePill('PDF Export', Icons.picture_as_pdf_rounded),
        _FeaturePill('History Log', Icons.history_rounded),
      ],
    ),
    _OnboardPage(
      title: 'Health Tips',
      subtitle: 'AI-Driven Wellness Insights',
      description:
          'Get personalized health tips, medicine info, and wellness advice — '
          'powered by AI to help you live better every day.',
      icon: Icons.health_and_safety_rounded,
      gradientColors: [Color(0xFF0E7A4E), Color(0xFF27AE60), Color(0xFF6FCF97)],
      pills: [
        _FeaturePill('Personalized Tips', Icons.tips_and_updates_rounded),
        _FeaturePill('Medicine Info', Icons.info_rounded),
        _FeaturePill('Multilingual', Icons.translate_rounded),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgAnimController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    widget.onFinished();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgAnimController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  page.gradientColors[0],
                  page.gradientColors[1],
                  page.gradientColors[2],
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Stack(
            children: [
              // ── Decorative background blobs ────────────────────────
              _buildBackgroundBlobs(),

              // ── Main content ───────────────────────────────────────
              Column(
                children: [
                  // Skip button row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Page indicator dots
                        Row(
                          children: List.generate(_pages.length, (i) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 6),
                              width: i == _currentPage ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(i == _currentPage ? 1 : 0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                        // Skip button
                        if (!isLast)
                          TextButton(
                            onPressed: _skip,
                            child: Text(
                              'Skip',
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Page view ─────────────────────────────────────
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return _buildPage(_pages[index]);
                      },
                    ),
                  ),

                  // ── Bottom CTA button ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                    child: _buildCTAButton(isLast),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardPage page) {
    final isFirst = page == _pages[0];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Floating illustration ──────────────────────────────────
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnim.value),
                child: child,
              );
            },
            child: isFirst
                ? const AppLogoWidget(size: 110, interactive: true)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(begin: const Offset(0.7, 0.7))
                : _buildIconIllustration(page)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(begin: const Offset(0.7, 0.7)),
          ),

          const SizedBox(height: 40),

          // ── Title ─────────────────────────────────────────────────
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.8,
              height: 1.1,
            ),
          )
              .animate(key: ValueKey('title_$_currentPage'))
              .fadeIn(delay: 150.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0, delay: 150.ms),

          const SizedBox(height: 8),

          // ── Subtitle ──────────────────────────────────────────────
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.85),
              letterSpacing: 0.2,
            ),
          )
              .animate(key: ValueKey('sub_$_currentPage'))
              .fadeIn(delay: 250.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0, delay: 250.ms),

          const SizedBox(height: 20),

          // ── Description ───────────────────────────────────────────
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.72),
              height: 1.6,
            ),
          )
              .animate(key: ValueKey('desc_$_currentPage'))
              .fadeIn(delay: 350.ms, duration: 400.ms),

          const SizedBox(height: 28),

          // ── Feature pills ─────────────────────────────────────────
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: page.pills
                .asMap()
                .entries
                .map(
                  (e) => _buildFeaturePill(e.value, e.key)
                      .animate(key: ValueKey('pill_${_currentPage}_${e.key}'))
                      .fadeIn(delay: Duration(milliseconds: 450 + e.key * 80))
                      .slideX(
                        begin: 0.3,
                        end: 0,
                        delay: Duration(milliseconds: 450 + e.key * 80),
                      ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIconIllustration(_OnboardPage page) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.12),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Icon(
        page.icon,
        size: 68,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFeaturePill(_FeaturePill pill, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(pill.icon, size: 14, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 6),
          Text(
            pill.label,
            style: GoogleFonts.outfit(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton(bool isLast) {
    return GestureDetector(
      onTap: _nextPage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLast ? 'Get Started' : 'Continue',
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _pages[_currentPage].gradientColors[1],
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
              color: _pages[_currentPage].gradientColors[1],
              size: 20,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 400.ms)
        .slideY(begin: 0.4, end: 0, delay: 600.ms);
  }

  Widget _buildBackgroundBlobs() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: _blob(260, opacity: 0.07),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: _blob(300, opacity: 0.06),
        ),
        Positioned(
          top: 160,
          left: -50,
          child: _blob(140, opacity: 0.05),
        ),
        // Rotating arc decoration
        Positioned(
          top: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: _bgAnimController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _bgAnimController.value * 2 * math.pi * 0.08,
                child: child,
              );
            },
            child: CustomPaint(
              size: const Size(200, 200),
              painter: _ArcPainter(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _blob(double size, {double opacity = 0.08}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}

/// Utility: check if onboarding has been completed before
Future<bool> hasCompletedOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_done') ?? false;
}

// ── Arc decoration painter ─────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 3; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(size.width, 0),
          width: (80 + i * 40).toDouble(),
          height: (80 + i * 40).toDouble(),
        ),
        math.pi / 2,
        math.pi,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => false;
}
