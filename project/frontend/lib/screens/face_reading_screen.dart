import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class FaceReadingScreen extends StatefulWidget {
  const FaceReadingScreen({super.key});

  @override
  State<FaceReadingScreen> createState() => _FaceReadingScreenState();
}

class _FaceReadingScreenState extends State<FaceReadingScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0; // 0: Crop, 1: Scanning, 2: Preview, 3: Results
  int _selectedTab = 0;
  
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  final List<String> _tabs = ['Face', 'Lips', 'Eyes', 'Nose', 'Eyebrows'];
  
  final Map<String, Map<String, String>> _analysisData = {
    'Face': {
      'title': 'An Oblong Shaped Face',
      'description': '''People with an oblong face shape, also known as rectangular, often possess elongated features with balanced proportions. They tend to have a longer face length compared to its width, giving them a distinctive and elegant presence. They may exhibit qualities such as intellect, ambition, and determination. With a keen sense of focus, they are often goal-oriented and driven to succeed in their endeavors. While they may appear reserved at times, they can also be quite charismatic and engaging once they feel comfortable in a social setting. Their analytical nature and attention to detail make them well-suited for professions that require strategic thinking and problem-solving skills. Despite their focused demeanor, they also value meaningful connections and cherish relationships with close friends.

• Delicate
• Elegant
• Intellect
• Ambition
• Determination''',
    },
    'Lips': {
      'title': 'Full Lips',
      'description': '''People with full lips are often seen as passionate, expressive, and confident. They tend to be natural communicators who enjoy social interactions and building connections with others. Their warm and friendly demeanor makes them approachable and well-liked in social settings.

• Passionate
• Expressive
• Confident
• Sociable
• Warm''',
    },
    'Eyes': {
      'title': 'Deep-Set Eyes',
      'description': '''People with deep-set eyes are often perceived as mysterious, thoughtful, and introspective. They tend to be observant and analytical, with a natural ability to read people and situations. Their intense gaze can be both captivating and intimidating.

• Mysterious
• Thoughtful
• Observant
• Analytical
• Intense''',
    },
    'Nose': {
      'title': 'Straight Nose',
      'description': '''People with a straight nose are often seen as balanced, practical, and reliable. They tend to have a strong sense of justice and fairness, and are known for their logical thinking and problem-solving abilities. Their straightforward nature makes them trustworthy companions.

• Balanced
• Practical
• Reliable
• Logical
• Trustworthy''',
    },
    'Eyebrows': {
      'title': 'Arched Eyebrows',
      'description': '''People with arched eyebrows are often perceived as expressive, creative, and confident. They tend to be natural leaders who aren\'t afraid to take risks and pursue their goals. Their dynamic personality makes them stand out in any crowd.

• Expressive
• Creative
• Confident
• Bold
• Dynamic''',
    },
  };

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(_scanController);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _startAnalysis() {
    setState(() {
      _currentStep = 1; // Scanning
    });
    
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _currentStep = 2; // Preview
        });
      }
    });
  }

  void _showResults() {
    setState(() {
      _currentStep = 3; // Results
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentStep == 1 ? Colors.black : Colors.white,
      appBar: _currentStep == 1
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF00BFA5),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Face Reading',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: false,
              actions: _currentStep >= 2
                  ? [
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {},
                      ),
                    ]
                  : null,
            ),
      body: _buildStepContent(),
      bottomNavigationBar: _currentStep == 3 ? _buildBottomTabs() : null,
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildCropScreen();
      case 1:
        return _buildScanningScreen();
      case 2:
        return _buildPreviewScreen();
      case 3:
        return _buildResultsScreen();
      default:
        return _buildCropScreen();
    }
  }

  Widget _buildCropScreen() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              width: 280,
              height: 380,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Placeholder image
                  Center(
                    child: Icon(
                      Icons.person,
                      size: 120,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  // Grid overlay
                  CustomPaint(
                    size: const Size(280, 380),
                    painter: GridPainter(),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _startAnalysis,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanningScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Corner brackets
                Container(
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
                      _buildCorner(Alignment.topLeft, true, true),
                      _buildCorner(Alignment.topRight, true, false),
                      _buildCorner(Alignment.bottomLeft, false, true),
                      _buildCorner(Alignment.bottomRight, false, false),
                    ],
                  ),
                ),
                
                // Circular scanning animation
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
                
                // Center icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00BFA5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.face,
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
          
          // Progress bar
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
    );
  }

  Widget _buildCorner(Alignment alignment, bool top, bool left) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: Color(0xFF00BFA5), width: 4) : BorderSide.none,
            bottom: !top ? const BorderSide(color: Color(0xFF00BFA5), width: 4) : BorderSide.none,
            left: left ? const BorderSide(color: Color(0xFF00BFA5), width: 4) : BorderSide.none,
            right: !left ? const BorderSide(color: Color(0xFF00BFA5), width: 4) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: top && left ? const Radius.circular(20) : Radius.zero,
            topRight: top && !left ? const Radius.circular(20) : Radius.zero,
            bottomLeft: !top && left ? const Radius.circular(20) : Radius.zero,
            bottomRight: !top && !left ? const Radius.circular(20) : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewScreen() {
    return Stack(
      children: [
        // Photo with face outline
        Positioned.fill(
          child: Container(
            color: const Color(0xFFE8D5C4),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.person,
                  size: 200,
                  color: Colors.grey.shade400,
                ),
                // Red face outline
                CustomPaint(
                  size: const Size(200, 250),
                  painter: FaceOutlinePainter(),
                ),
              ],
            ),
          ),
        ),
        
        // Show results button
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 240,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFDD835), Color(0xFFFBC02D)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFDD835).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _showResults,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Show results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Chat button
        Positioned(
          bottom: 30,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: const Color(0xFF00BFA5),
            child: const Icon(Icons.chat_bubble, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsScreen() {
    final currentAnalysis = _analysisData[_tabs[_selectedTab]]!;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentAnalysis['title']!,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              currentAnalysis['description']!,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 80), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTabs() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTab = index;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconForTab(_tabs[index]),
                  color: isSelected ? const Color(0xFF00BFA5) : Colors.grey.shade400,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  _tabs[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? const Color(0xFF00BFA5) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  IconData _getIconForTab(String tab) {
    switch (tab) {
      case 'Face':
        return Icons.face;
      case 'Lips':
        return Icons.mood;
      case 'Eyes':
        return Icons.visibility;
      case 'Nose':
        return Icons.air;
      case 'Eyebrows':
        return Icons.remove_red_eye;
      default:
        return Icons.face;
    }
  }
}

// Grid painter for crop screen
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    // Horizontal lines
    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines
    for (int i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Face outline painter for preview screen
class FaceOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Draw an oval face outline
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.7,
      height: size.height * 0.85,
    );
    
    path.addOval(rect);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
