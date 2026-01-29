import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'dart:async';

class CelebrityLookAlikeScreen extends StatefulWidget {
  const CelebrityLookAlikeScreen({super.key});

  @override
  State<CelebrityLookAlikeScreen> createState() =>
      _CelebrityLookAlikeScreenState();
}

class _CelebrityLookAlikeScreenState extends State<CelebrityLookAlikeScreen> {
  // Flow based on numbered references:
  // 1 / 1.1 = permission
  // 2 / 3   = main card + filled
  // 4       = ads
  // 5/5.1/5.2 = final slider
  int _currentStep = 0;
  int _selectedTabIndex = 0; // 0 = Influencers, 1 = Top 100 social
  int _currentResultPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      _currentStep = (_currentStep + 1).clamp(0, 3);
    });
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
          'Celebrity Look Alike',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: AppColors.premiumPurple,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildStepContent(),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPermissionStep();
      case 1:
        return _buildMainCardStep();
      case 2:
        return _buildAdsStep();
      case 3:
      default:
        return _buildResultsStep();
    }
  }

  // Step 0: Camera permission (1.1celibrity_look_cameraPermisson-1)
  Widget _buildPermissionStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF22C55E),
                  Color(0xFF16A34A),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Allow Camera Access',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'To find your celebrity look alike we need access\n'
            'to your camera.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.premiumPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'OK',
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

  // Step 1: Main card / click to open camera (1 & 2 & 3)
  Widget _buildMainCardStep() {
    return Column(
      children: [
        // Ad banner like reference (top)
        Container(
          width: double.infinity,
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF22C55E),
                Color(0xFF16A34A),
              ],
            ),
          ),
          child: const Center(
            child: Text(
              'Ad Banner',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Main upload card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.border.withOpacity(0.8),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFFC3A0),
                                  Color(0xFF6C5CE7),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 56,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tap to add your photo',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 3,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            // Camera / gallery picker could be added here
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.add,
                              size: 20,
                              color: AppColors.premiumPurple,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'with',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _buildSegmentTab(index: 0, label: 'Influencers'),
                      _buildSegmentTab(index: 1, label: 'Top 100 social'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // After search, go to ads (4)
                _nextStep();
                // Then auto-go to results after a short delay
                Timer(const Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      _currentStep = 3;
                    });
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: const Text(
                'SEARCH',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Step 2: Ads screen (4.ads_screen_after captured)
  Widget _buildAdsStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF22C55E),
                    Color(0xFF16A34A),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Advertisement',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Loading your celebrity matches...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Final results with slider (5 / 5.1 / 5.2)
  Widget _buildResultsStep() {
    final results = [
      {
        'name': 'Celebrity Match 1',
        'percent': '89%',
        'tag': 'Top Match',
      },
      {
        'name': 'Celebrity Match 2',
        'percent': '84%',
        'tag': 'Very Similar',
      },
      {
        'name': 'Celebrity Match 3',
        'percent': '80%',
        'tag': 'Good Match',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Your Celebrity Matches',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: results.length,
              onPageChanged: (index) {
                setState(() {
                  _currentResultPage = index;
                });
              },
              itemBuilder: (context, index) {
                final item = results[index];
                return _buildResultCard(
                  name: item['name']!,
                  percent: item['percent']!,
                  tag: item['tag']!,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              results.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentResultPage == index ? 12 : 8,
                height: _currentResultPage == index ? 12 : 8,
                decoration: BoxDecoration(
                  color: _currentResultPage == index
                      ? AppColors.premiumPurple
                      : AppColors.textMuted.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 1; // back to main card
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.premiumPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Try Another Photo',
                style: TextStyle(
                  fontSize: 16,
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

  Widget _buildResultCard({
    required String name,
    required String percent,
    required String tag,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6C5CE7),
                    Color(0xFF5F7FFF),
                  ],
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 70,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              percent,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.premiumPurple,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.premiumPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.premiumPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentTab({required int index, required String label}) {
    final bool isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.premiumPurple
                    : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

