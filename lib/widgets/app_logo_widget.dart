import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/app_colors.dart';

/// Interactive MediTrack AI Logo Widget
/// Features: pulse animation, rotating ring, particle burst on tap, shimmer glow
class AppLogoWidget extends StatefulWidget {
  final double size;
  final bool interactive;
  final bool autoAnimate;

  const AppLogoWidget({
    super.key,
    this.size = 120,
    this.interactive = true,
    this.autoAnimate = true,
  });

  @override
  State<AppLogoWidget> createState() => _AppLogoWidgetState();
}

class _AppLogoWidgetState extends State<AppLogoWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _tapController;
  late AnimationController _particleController;

  late Animation<double> _pulseAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _tapScaleAnim;
  late Animation<double> _particleAnim;

  final List<_Particle> _particles = [];
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotation animation
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    // Tap bounce animation
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _tapScaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.88),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.88, end: 1.08),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0),
        weight: 20,
      ),
    ]).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeOut));

    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _particleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );

    _particleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _particles.clear());
      }
    });

    if (widget.autoAnimate) {
      _pulseController.repeat(reverse: true);
      _rotateController.repeat();
    }
  }

  void _generateParticles() {
    final rand = math.Random();
    _particles.clear();
    for (int i = 0; i < 10; i++) {
      final angle = rand.nextDouble() * 2 * math.pi;
      final speed = rand.nextDouble() * 0.6 + 0.4;
      _particles.add(_Particle(
        angle: angle,
        speed: speed,
        color: i % 3 == 0
            ? AppColors.primaryLight
            : i % 3 == 1
                ? Colors.white
                : AppColors.accent,
        size: rand.nextDouble() * 5 + 3,
      ));
    }
  }

  void _onTap() {
    if (!widget.interactive) return;
    _generateParticles();
    _tapController.forward(from: 0);
    _particleController.forward(from: 0);
    setState(() => _isPressed = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _tapController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return GestureDetector(
      onTap: _onTap,
      child: SizedBox(
        width: s * 1.4,
        height: s * 1.4,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _pulseController,
            _rotateController,
            _tapController,
            _particleController,
          ]),
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Opacity(
                  opacity: _glowAnim.value * 0.3,
                  child: Container(
                    width: s * 1.35,
                    height: s * 1.35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.5),
                          AppColors.primaryLight.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Rotating dashed ring
                Transform.rotate(
                  angle: _rotateController.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(s * 1.18, s * 1.18),
                    painter: _DashedRingPainter(
                      color: AppColors.primaryLight.withOpacity(0.6),
                      strokeWidth: 1.5,
                      dashCount: 16,
                    ),
                  ),
                ),

                // Particle burst
                if (_particles.isNotEmpty)
                  ...List.generate(_particles.length, (i) {
                    final p = _particles[i];
                    final distance = _particleAnim.value * s * 0.8;
                    final opacity = (1.0 - _particleAnim.value).clamp(0.0, 1.0);
                    return Positioned(
                      left: s * 0.7 +
                          math.cos(p.angle) * distance -
                          p.size / 2,
                      top: s * 0.7 +
                          math.sin(p.angle) * distance * p.speed -
                          p.size / 2,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: p.size,
                          height: p.size,
                          decoration: BoxDecoration(
                            color: p.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),

                // Main logo body
                Transform.scale(
                  scale: _pulseAnim.value * _tapScaleAnim.value,
                  child: Container(
                    width: s,
                    height: s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1A5BB8),
                          Color(0xFF2F80ED),
                          Color(0xFF56CCF2),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary
                              .withOpacity(0.4 * _glowAnim.value),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: AppColors.primaryLight
                              .withOpacity(0.2 * _glowAnim.value),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glassmorphism inner shine
                        Positioned(
                          top: s * 0.1,
                          left: s * 0.15,
                          child: Container(
                            width: s * 0.5,
                            height: s * 0.22,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.25),
                                  Colors.white.withOpacity(0.0),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),

                        // Medical cross icon + AI circuit
                        CustomPaint(
                          size: Size(s * 0.55, s * 0.55),
                          painter: _MedCrossPainter(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter for the medical cross with circuit lines
class _MedCrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final t = w * 0.28; // thickness of cross arm

    // Draw plus/cross shape
    final crossPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w / 2, h / 2), width: w, height: t),
        Radius.circular(t / 2),
      ))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w / 2, h / 2), width: t, height: h),
        Radius.circular(t / 2),
      ));

    canvas.drawPath(crossPath, paint);

    // AI circuit dots at cross tips
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final dotRadius = t * 0.18;
    final dots = [
      Offset(w / 2, t * 0.15), // top
      Offset(w / 2, h - t * 0.15), // bottom
      Offset(t * 0.15, h / 2), // left
      Offset(w - t * 0.15, h / 2), // right
    ];
    for (final dot in dots) {
      canvas.drawCircle(dot, dotRadius, dotPaint);
    }

    // Center AI node
    final centerPaint = Paint()
      ..color = const Color(0xFF2F80ED)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2), t * 0.25, centerPaint);

    // Mini pill below center
    final pillPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.fill;
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.78),
        width: t * 1.1,
        height: t * 0.42,
      ),
      Radius.circular(t * 0.25),
    );
    canvas.drawRRect(pillRect, pillPaint);
  }

  @override
  bool shouldRepaint(_MedCrossPainter oldDelegate) => false;
}

/// Custom painter for dashed rotating ring
class _DashedRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  _DashedRingPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final dashAngle = 2 * math.pi / dashCount;
    final gapFraction = 0.4;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

/// Particle data model
class _Particle {
  final double angle;
  final double speed;
  final Color color;
  final double size;

  _Particle({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
  });
}
