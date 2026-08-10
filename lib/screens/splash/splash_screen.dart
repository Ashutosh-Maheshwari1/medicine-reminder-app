import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/app_router.dart';
import '../../widgets/app_logo_widget.dart';
import '../onboarding/onboarding_screen.dart';

/// Animated splash screen with gradient and logo
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    // After splash, check if first-time user → show onboarding, else login
    Future.delayed(const Duration(milliseconds: 3000), () async {
      if (!mounted) return;
      final done = await hasCompletedOnboarding();
      if (!mounted) return;
      context.go(done ? Routes.login : Routes.onboarding);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Stack(
            children: [
              // Background decorative circles
              Positioned(
                top: -80,
                right: -60,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                top: 200,
                left: -40,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated interactive logo
                    const AppLogoWidget(
                      size: 120,
                      interactive: true,
                      autoAnimate: true,
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .scale(begin: const Offset(0.5, 0.5), delay: 200.ms),

                    const SizedBox(height: 36),

                    // App name
                    Text(
                      'MediTrack AI',
                      style: GoogleFonts.outfit(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0, delay: 500.ms),

                    const SizedBox(height: 10),

                    // Tagline
                    Text(
                      'Never miss a dose.',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 0.3,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0, delay: 700.ms),
                  ],
                ),
              ),

              // Bottom loading indicator
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Powered by AI',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
