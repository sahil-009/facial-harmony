import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class FacialSymmetryScreen extends StatefulWidget {
  const FacialSymmetryScreen({super.key});

  @override
  State<FacialSymmetryScreen> createState() => _FacialSymmetryScreenState();
}

class _FacialSymmetryScreenState extends State<FacialSymmetryScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(_scanController);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Facial Symmetry',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildStepContent(),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPermissionScreen();
      case 1:
        return _buildPhotoSelectionScreen();
      case 2:
        return _buildScanningScreen();
      case 3:
        return _buildResultScreen();
      default:
        return _buildPermissionScreen();
    }
  }

  // Step 0: Permission Screen
  Widget _buildPermissionScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Symmetry Icon with Premium Design
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.premiumPurple,
                  Color(0xFF8A2387),
                  Color(0xFFE94057),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.premiumPurple.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.compare_arrows, // Symmetry icon
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Analyze Symmetry',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'We will analyze the balance between the left and right sides of your face to determine your symmetry score.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 60),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.premiumPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Start Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step 1: Photo Selection Screen
  Widget _buildPhotoSelectionScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Camera Preview Area
                Container(
                  width: double.infinity,
                  height: 400,
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.premiumPurple.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Face Guide Overlay with Symmetry Line
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 250,
                                height: 320,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(125),
                                  border: Border.all(
                                    color: AppColors.premiumPurple
                                        .withOpacity(_pulseAnimation.value * 0.6),
                                    width: 3,
                                  ),
                                ),
                              ),
                              // Vertical Center Line for Symmetry
                              Container(
                                height: 320,
                                width: 2,
                                color: AppColors.premiumGold.withOpacity(0.5),
                              ),
                            ],
                          );
                        },
                      ),
                      const Icon(
                        Icons.camera_alt,
                        size: 80,
                        color: AppColors.premiumPurple,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Align your face',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ensure your nose is aligned with the center line',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Open gallery
                    _nextStep();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.premiumPurple,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library, color: AppColors.premiumPurple),
                      const SizedBox(width: 8),
                      Text(
                        'Gallery',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.premiumPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.premiumPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Capture',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Step 2: Scanning Screen
  Widget _buildScanningScreen() {
    // Auto navigate to result after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _nextStep();
      }
    });

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Scanning Animation
          SizedBox(
            width: 300,
            height: 360,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Face Frame
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 250,
                      height: 320,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(125),
                        border: Border.all(
                          color: AppColors.premiumPurple
                              .withOpacity(_pulseAnimation.value),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.premiumPurple
                                .withOpacity(_pulseAnimation.value * 0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Face Icon Split
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(
                      Icons.face_retouching_natural,
                      size: 100,
                      color: AppColors.premiumPurple.withOpacity(0.8),
                    ),
                  ],
                ),
                // Vertical Scanning Line for Symmetry
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    // Scanning from left to right to check symmetry
                    return Positioned(
                      left: _scanAnimation.value * 300, // Approximate width
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
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
          const SizedBox(height: 40),
          const Text(
            'Analyzing Symmetry...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Comparing left and right facial features',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Step 3: Result Screen
  Widget _buildResultScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Result Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8A2387),
                  AppColors.premiumPurple,
                  Color(0xFFE94057),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.premiumPurple.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.compare_arrows,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Symmetry Score',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '96.2%',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Perfect! Highly symmetrical features.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Comparison Cards
          Row(
            children: [
              Expanded(
                child: _buildComparisonCard('Left Face', 'Original', Icons.face),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComparisonCard('Right Face', 'Mirrored', Icons.flip),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Analysis Details
          _buildAnalysisDetail('Eye Alignment', '98%', Icons.remove_red_eye),
          const SizedBox(height: 12),
          _buildAnalysisDetail('Nose Center', '95%', Icons.circle),
          const SizedBox(height: 12),
          _buildAnalysisDetail('Jawline Balance', '94%', Icons.favorite_border), // Using heart/generic for jaw
          
          const SizedBox(height: 32),
          
          // Action Buttons
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Share result
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.premiumPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Share Result',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 1; // Go back to photo selection
                });
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppColors.premiumPurple,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Retake Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.premiumPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.premiumPurple.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.premiumPurple, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisDetail(String label, String score, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.premiumPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.premiumPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Text(
            score,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.premiumPurple,
            ),
          ),
        ],
      ),
    );
  }
}
