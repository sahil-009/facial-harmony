import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;
  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(_mainController);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.linear),
    );

    // Navigate to language selection after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppConstants.languageRoute);
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F1E),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium Face Scanning Frame
              SizedBox(
                width: 320,
                height: 360,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Glow Ring
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.premiumGold.withOpacity(_glowAnimation.value * 0.3),
                                AppColors.premiumPurple.withOpacity(_glowAnimation.value * 0.2),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.premiumGold.withOpacity(_glowAnimation.value * 0.5),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: AppColors.premiumPurple.withOpacity(_glowAnimation.value * 0.3),
                                blurRadius: 60,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    // Premium Corner Frames with Gold
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Stack(
                          children: [
                            _buildPremiumCorner(Alignment.topLeft, true, true, _pulseAnimation.value),
                            _buildPremiumCorner(Alignment.topRight, true, false, _pulseAnimation.value),
                            _buildPremiumCorner(Alignment.bottomLeft, false, true, _pulseAnimation.value),
                            _buildPremiumCorner(Alignment.bottomRight, false, false, _pulseAnimation.value),
                          ],
                        );
                      },
                    ),
                    
                    // Rotating Face Mesh Circle
                    AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 2 * 3.14159,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.premiumGold.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Central Face Mesh
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 200,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.premiumGold.withOpacity(_pulseAnimation.value * 0.2),
                                AppColors.premiumPurple.withOpacity(_pulseAnimation.value * 0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: CustomPaint(
                            painter: PremiumFaceMeshPainter(
                              goldColor: AppColors.premiumGold.withOpacity(_pulseAnimation.value),
                              purpleColor: AppColors.premiumPurple.withOpacity(_pulseAnimation.value * 0.7),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Premium Scan Line
                    AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: _scanAnimation.value * 360,
                          left: 40,
                          right: 40,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.premiumGold,
                                  AppColors.premiumPurple,
                                  AppColors.premiumGold,
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.premiumGold,
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                ),
                                BoxShadow(
                                  color: AppColors.premiumPurple,
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Premium App Title with Gradient
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.premiumGold, AppColors.premiumPurple, AppColors.premiumBlue],
                ).createShader(bounds),
                child: const Text(
                  'Facial Harmony',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Tagline
              Text(
                'Premium AI Beauty Analysis',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Premium Loading Bar
              SizedBox(
                width: 240,
                child: Column(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: Stack(
                        children: [
                          AnimatedBuilder(
                            animation: _mainController,
                            builder: (context, child) {
                              return FractionallySizedBox(
                                widthFactor: _mainController.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.premiumGold,
                                        AppColors.premiumPurple,
                                        AppColors.premiumBlue,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.premiumGold.withOpacity(0.6),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This process may contain ads',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCorner(Alignment alignment, bool isTop, bool isLeft, double opacity) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? BorderSide(
                    color: AppColors.premiumGold.withOpacity(opacity),
                    width: 4,
                  )
                : BorderSide.none,
            bottom: !isTop
                ? BorderSide(
                    color: AppColors.premiumGold.withOpacity(opacity),
                    width: 4,
                  )
                : BorderSide.none,
            left: isLeft
                ? BorderSide(
                    color: AppColors.premiumGold.withOpacity(opacity),
                    width: 4,
                  )
                : BorderSide.none,
            right: !isLeft
                ? BorderSide(
                    color: AppColors.premiumGold.withOpacity(opacity),
                    width: 4,
                  )
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft ? const Radius.circular(12) : Radius.zero,
            topRight: isTop && !isLeft ? const Radius.circular(12) : Radius.zero,
            bottomLeft: !isTop && isLeft ? const Radius.circular(12) : Radius.zero,
            bottomRight: !isTop && !isLeft ? const Radius.circular(12) : Radius.zero,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.premiumGold.withOpacity(opacity * 0.5),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumFaceMeshPainter extends CustomPainter {
  final Color goldColor;
  final Color purpleColor;

  PremiumFaceMeshPainter({
    required this.goldColor,
    required this.purpleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Premium Gold Paint
    final goldPaint = Paint()
      ..color = goldColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Premium Purple Paint
    final purplePaint = Paint()
      ..color = purpleColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw enhanced facial features
    // Eyes with premium glow
    final eyePaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.38), 10, eyePaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.38), 10, eyePaint);
    
    // Eye pupils
    final pupilPaint = Paint()
      ..color = purpleColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.38), 4, pupilPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.38), 4, pupilPaint);

    // Enhanced Nose with gradient effect
    final nosePath = Path();
    nosePath.moveTo(center.dx, size.height * 0.28);
    nosePath.lineTo(center.dx - 8, size.height * 0.45);
    nosePath.lineTo(center.dx, size.height * 0.52);
    nosePath.lineTo(center.dx + 8, size.height * 0.45);
    nosePath.close();
    canvas.drawPath(nosePath, goldPaint);

    // Premium Mouth
    final mouthPath = Path();
    mouthPath.moveTo(size.width * 0.28, size.height * 0.62);
    mouthPath.quadraticBezierTo(
      center.dx,
      size.height * 0.72,
      size.width * 0.72,
      size.height * 0.62,
    );
    canvas.drawPath(mouthPath, goldPaint);

    // Premium Mesh Grid with gradient
    purplePaint.strokeWidth = 0.8;
    purplePaint.color = purpleColor.withOpacity(0.4);

    // Horizontal mesh lines
    for (double y = 0.18; y <= 0.82; y += 0.16) {
      canvas.drawLine(
        Offset(size.width * 0.15, size.height * y),
        Offset(size.width * 0.85, size.height * y),
        purplePaint,
      );
    }

    // Vertical mesh lines
    for (double x = 0.25; x <= 0.75; x += 0.15) {
      canvas.drawLine(
        Offset(size.width * x, size.height * 0.12),
        Offset(size.width * x, size.height * 0.88),
        purplePaint,
      );
    }

    // Facial contour lines
    final contourPath = Path();
    contourPath.moveTo(size.width * 0.2, size.height * 0.25);
    contourPath.quadraticBezierTo(
      size.width * 0.1, size.height * 0.5,
      size.width * 0.2, size.height * 0.75,
    );
    contourPath.moveTo(size.width * 0.8, size.height * 0.25);
    contourPath.quadraticBezierTo(
      size.width * 0.9, size.height * 0.5,
      size.width * 0.8, size.height * 0.75,
    );
    canvas.drawPath(contourPath, purplePaint);
  }

  @override
  bool shouldRepaint(PremiumFaceMeshPainter oldDelegate) =>
      oldDelegate.goldColor != goldColor || oldDelegate.purpleColor != purpleColor;
}
