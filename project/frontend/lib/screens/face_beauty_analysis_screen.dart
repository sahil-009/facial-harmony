import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/ad_service.dart';
import '../services/api_service.dart';
import '../services/device_service.dart';

class FaceBeautyAnalysisScreen extends StatefulWidget {
  const FaceBeautyAnalysisScreen({super.key});

  @override
  State<FaceBeautyAnalysisScreen> createState() =>
      _FaceBeautyAnalysisScreenState();
}

class _FaceBeautyAnalysisScreenState extends State<FaceBeautyAnalysisScreen>
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

  Map<String, dynamic>? _analysisResult;
  bool _isAnalyzing = false;
  String? _capturedImageBase64; // You'll need to set this when photo is taken

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
          'Face Beauty Analysis',
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

  Future<void> _performAnalysis() async {
    if (_isAnalyzing) return;
    
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final deviceId = await DeviceService().getDeviceId();
      final gender = await DeviceService().getGender() ?? 'male';
      
      // Use placeholder if no image captured yet to test flow
      final imageToSend = _capturedImageBase64 ?? "R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7";

      final result = await ApiService().analyzeFace(
        imageBase64: imageToSend,
        gender: gender,
      );

      if (mounted) {
        setState(() {
          _analysisResult = result;
          _isAnalyzing = false;
          _currentStep = 4; // Move to Ads
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e')),
        );
      }
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPermissionScreen();
      case 1:
        return _buildPhotoSelectionScreen();
      case 2:
        return _buildCropScreen();
      case 3:
        return _buildScanningScreen();
      case 4:
        return _buildAdsScreen();
      case 5:
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
          // Face Icon with Premium Design
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.premiumGold,
                  AppColors.premiumPurple,
                  AppColors.premiumBlue,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.premiumGold.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.face,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Camera Permission',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'We need access to your camera to analyze your face beauty. Please grant camera permission to continue.',
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
                'Grant Permission',
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
                      color: AppColors.premiumGold.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Face Guide Overlay
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 250,
                            height: 300,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.premiumGold
                                    .withOpacity(_pulseAnimation.value * 0.6),
                                width: 3,
                              ),
                            ),
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
                  'Position your face in the frame',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Make sure your face is clearly visible',
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

  // Step 2: Crop Screen
  Widget _buildCropScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Crop Area
                Container(
                  width: double.infinity,
                  height: 400,
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.premiumGold,
                      width: 3,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Crop Overlay
                      Center(
                        child: Container(
                          width: 250,
                          height: 300,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.premiumGold,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      // Crop Handles
                      Positioned(
                        top: 50,
                        left: 50,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.premiumGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 50,
                        right: 50,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.premiumGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        left: 50,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.premiumGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        right: 50,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.premiumGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Adjust the crop area',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Drag the corners to adjust the face area',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
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
              ),
              child: const Text(
                'Continue',
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

  // Step 3: Scanning Screen
  Widget _buildScanningScreen() {
    // Trigger analysis
    if (!_isAnalyzing && _analysisResult == null) {
       // Using Future.delayed to avoid calling setState during build
       Future.delayed(Duration.zero, () {
         _performAnalysis();
       });
    }

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
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.premiumGold
                              .withOpacity(_pulseAnimation.value),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.premiumGold
                                .withOpacity(_pulseAnimation.value * 0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Face Icon
                const Icon(
                  Icons.face,
                  size: 120,
                  color: AppColors.premiumPurple,
                ),
                // Scanning Line
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: _scanAnimation.value * 360,
                      left: 0,
                      right: 0,
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
            'Analyzing Your Face...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please wait while we analyze your facial features',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 40),
          // Progress Indicator
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: AppColors.bgLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.premiumPurple,
              ),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  // Step 4: Ads Screen
  Widget _buildAdsScreen() {
    // Show Interstitial Ad (with 3 sec safety timer fallback) 
    // This runs once when widget builds
    if (mounted) {
       Future.delayed(Duration.zero, () async {
         // Wait a brief moment for UI to settle
         await Future.delayed(const Duration(milliseconds: 500));
         
         await AdService().showInterstitialAd(() {
            if (mounted) {
              _nextStep(); // Navigate to Result Screen
            }
         });
       });
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 100,
            color: AppColors.premiumPurple,
          ),
          const SizedBox(height: 32),
          const Text(
            'Preparing Results',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Finalizing your personalized analysis...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 48),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.premiumPurple),
          ),
        ],
      ),
    );
  }


  // Step 5: Result Screen
  Widget _buildResultScreen() {
    if (_analysisResult == null) {
      return const Center(child: Text("No results found"));
    }

    final beautyScore = _analysisResult!['beauty_score'];
    final totalScore = (beautyScore['total_score'] ?? 0.0).toDouble();
    final category = beautyScore['category'] ?? 'Average';
    
    // Safety check for components
    final components = beautyScore['component_scores'] ?? {};
    final symmetryScore = (components['symmetry'] ?? 0.0).toDouble();
    final jawlineScore = (components['jawline'] ?? 0.0).toDouble();
    final structureScore = (components['structure'] ?? 0.0).toDouble();
    
    // Tips
    final tips = (_analysisResult!['tips'] as List?)?.cast<String>() ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Total Score Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8A2387), AppColors.premiumPurple, Color(0xFFE94057)],
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
                const Text(
                  'Beauty Harmony Score',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  totalScore.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Disclaimer (Mandatory)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              'Disclaimer: This analysis is for entertainment & self-improvement purposes only. Results are not medical, psychological, or professional advice. Facial resemblance is approximate, not identity confirmation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Component Scores
          _buildScoreRow("Facial Symmetry", symmetryScore),
          const SizedBox(height: 12),
          _buildScoreRow("Jawline Definition", jawlineScore),
          const SizedBox(height: 12),
          _buildScoreRow("Facial Structure", structureScore),

          const SizedBox(height: 32),
          
          // Tips Section
          if (tips.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personalized Tips',
                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
            ),
            const SizedBox(height: 16),
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.premiumPurple, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(tip, style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4))),
                ],
              ),
            )).toList(),
          ],
          
          const SizedBox(height: 32),
          // Actions
             SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _analysisResult = null;
                  _isAnalyzing = false;
                  _capturedImageBase64 = null;
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
                'Analyze Another Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.premiumPurple,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, dynamic score) {
    final scoreVal = (score is num) ? score.toDouble() : 0.0;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: scoreVal / 100,
            backgroundColor: AppColors.bgLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.premiumPurple),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            scoreVal.toStringAsFixed(0),
             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.premiumPurple),
             textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
