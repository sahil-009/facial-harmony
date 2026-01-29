import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class FacialResemblanceScreen extends StatefulWidget {
  const FacialResemblanceScreen({super.key});

  @override
  State<FacialResemblanceScreen> createState() =>
      _FacialResemblanceScreenState();
}

class _FacialResemblanceScreenState extends State<FacialResemblanceScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _person1Selected = false;
  bool _person2Selected = false;
  int _resemblanceScore = 0;

  late AnimationController _scanController;
  late AnimationController _pulseController;
  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(_scanController);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startComparison() {
    if (_person1Selected && _person2Selected) {
      setState(() {
        _currentStep = 1; // Scanning
        _resemblanceScore = Random().nextInt(30) + 70; // 70-99%
      });
      
      Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _currentStep = 2; // Result
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both photos to compare!'),
          backgroundColor: Color(0xFF00BFA5),
        ),
      );
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
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Facial Resemblance',
          style: TextStyle(
            color: Color(0xFF00BFA5),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: _currentStep == 2
            ? [
                IconButton(
                  icon: const Icon(Icons.download, color: AppColors.textDark),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: AppColors.textDark),
                  onPressed: () {},
                ),
              ]
            : null,
      ),
      body: _buildStepContent(),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildSelectionScreen();
      case 1:
        return _buildScanningScreen();
      case 2:
        return _buildResultScreen();
      default:
        return _buildSelectionScreen();
    }
  }

  Widget _buildSelectionScreen() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          'Facial\nResemblance',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF00BFA5),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 60),
        
        // Two Photo Slots
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPhotoSlot(
                isSelected: _person1Selected,
                onTap: () => setState(() => _person1Selected = !_person1Selected),
              ),
              const SizedBox(width: 20),
              _buildPhotoSlot(
                isSelected: _person2Selected,
                onTap: () => setState(() => _person2Selected = !_person2Selected),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Compare Button
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _startComparison,
              style: ElevatedButton.styleFrom(
                backgroundColor: _person1Selected && _person2Selected
                    ? const Color(0xFF00BFA5)
                    : Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'COMPARE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _person1Selected && _person2Selected
                      ? Colors.white
                      : Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSlot({required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: isSelected
                  ? Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BFA5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF00BFA5),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_outline,
                            size: 35,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00BFA5) : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSelected ? Icons.check : Icons.add,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningScreen() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Scanning Circle Animation
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Corner Brackets
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF00BFA5).withOpacity(0.3),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            // Top-left corner
                            Positioned(
                              top: -2,
                              left: -2,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: const Color(0xFF00BFA5), width: 4),
                                    left: BorderSide(color: const Color(0xFF00BFA5), width: 4),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            // Top-right corner
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: const Color(0xFF00BFA5), width: 4),
                                    right: BorderSide(color: const Color(0xFF00BFA5), width: 4),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            // Bottom-left corner
                            Positioned(
                              bottom: -2,
                              left: -2,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: const Color(0xFF00BFA5), width: 4),
                                    left: BorderSide(color: const Color(0xFF00BFA5), width: 4),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            // Bottom-right corner
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: const Color(0xFF00BFA5), width: 4),
                                    right: BorderSide(color: const Color(0xFF00BFA5), width: 4),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  // Circular Scanning Animation
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _scanAnimation.value * 2 * pi,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF00BFA5),
                              width: 3,
                            ),
                            gradient: SweepGradient(
                              colors: [
                                const Color(0xFF00BFA5),
                                const Color(0xFF00BFA5).withOpacity(0.1),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.3, 1.0],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Center Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00BFA5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.people,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 60),
            
            const Text(
              'SCANNING...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF00BFA5),
                letterSpacing: 3,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Progress Bar
            Container(
              width: 280,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(4),
              ),
              child: AnimatedBuilder(
                animation: _scanAnimation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _scanAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BFA5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    String message = '';
    if (_resemblanceScore >= 95) {
      message = "Congratulations! You've found the super identical duo!\nThey might be twins or the closest of friends.";
    } else if (_resemblanceScore >= 80) {
      message = "Great resemblance! These faces share many similar features.";
    } else {
      message = "Some similarities detected. Interesting comparison!";
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          const Text(
            'Facial\nResemblance',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF00BFA5),
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Photo Comparison
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildResultPhoto(),
                const SizedBox(width: 20),
                _buildResultPhoto(),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Score Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '$_resemblanceScore%',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Chat Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: const Color(0xFF00BFA5),
              child: const Icon(Icons.chat_bubble, color: Colors.white),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Disclaimer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildResultPhoto() {
    return Container(
      width: 140,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Color(0xFF00BFA5),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
