import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../widgets/feature_card.dart';
import '../widgets/app_drawer.dart';
import '../services/ad_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Gradient _getGradient(String gradientName) {
    switch (gradientName) {
      case 'pink':
        return AppColors.pinkGradient;
      case 'green':
        return AppColors.greenGradient;
      case 'purple':
        return AppColors.purpleGradient;
      case 'cyan':
        return AppColors.cyanGradient;
      case 'teal':
        return AppColors.tealGradient;
      case 'peach':
        return AppColors.peachGradient;
      case 'lavender':
        return AppColors.lavenderGradient;
      default:
        return AppColors.pinkGradient;
    }
  }

  void _showFeatureDialog(BuildContext context, String featureName) {
    // Check if it's Face Beauty Analysis
    if (featureName.contains('Face Beauty')) {
      Navigator.pushNamed(context, AppConstants.faceBeautyAnalysisRoute);
      return;
    }
    // Check if it's Celebrity Look Alike
    if (featureName.contains('Celebrity Look')) {
      Navigator.pushNamed(context, AppConstants.celebrityLookAlikeRoute);
      return;
    }
    // Check if it's Facial Symmetry
    if (featureName.contains('Facial') && featureName.contains('Symmetry')) {
      Navigator.pushNamed(context, AppConstants.facialSymmetryRoute);
      return;
    }
    
    // Check if it's Beauty Score Showdown
    if (featureName.contains('Showdown')) {
      Navigator.pushNamed(context, AppConstants.beautyScoreShowdownRoute);
      return;
    }
    // Check if it's Facial Resemblance
    if (featureName.contains('Resemblance')) {
      Navigator.pushNamed(context, AppConstants.facialResemblanceRoute);
      return;
    }
    // Check if it's Face Reading
    if (featureName.contains('Face') && featureName.contains('Reading')) {
      Navigator.pushNamed(context, AppConstants.faceReadingRoute);
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          featureName.replaceAll('\n', ' '),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'This feature is coming soon! Stay tuned for updates.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it!'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header with White Background
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Ad Banner
                  AdService().getBannerAd(),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      // Premium Menu Button
                      Builder(
                        builder: (context) => Container(
                          decoration: BoxDecoration(
                            color: AppColors.premiumGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.premiumGold.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                            icon: Icon(
                              Icons.menu,
                              color: AppColors.premiumGold,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                  
                  const SizedBox(width: 16),
                  
                  // Premium App Title with Beautiful Typography
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFFF6B9D),
                              Color(0xFF8B5CF6),
                              Color(0xFF5F7FFF),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ).createShader(bounds),
                          child: Text(
                            AppConstants.appName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Premium Beauty Analysis',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Premium Crown Button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.premiumGold,
                          Color(0xFFFFA500),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.premiumGold.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '👑',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Premium Help Button
                  GestureDetector(
                    onTap: () => _showHelpDialog(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.premiumPurple.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.premiumPurple.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '?',
                          style: TextStyle(
                            color: AppColors.premiumPurple,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
            
            // Premium Feature Grid with White Background
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // Banner Section
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF667EEA),
                            Color(0xFF764BA2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667EEA).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                '✨',
                                style: TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enhance Your Facial Features',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Discover your unique beauty',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    
                    // Feature Grid
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                        ),
                        itemCount: AppConstants.features.length,
                        itemBuilder: (context, index) {
                          final feature = AppConstants.features[index];
                          final isLarge = feature['size'] == 'large';
                          
                          return FeatureCard(
                            title: feature['title'],
                            icon: feature['icon'],
                            badge: feature['badge'],
                            gradient: _getGradient(feature['gradient']),
                            isLarge: isLarge,
                            onTap: () => _showFeatureDialog(
                              context,
                              feature['title'],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to use Facial Harmony:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text('1. Select a feature from the home screen'),
              SizedBox(height: 8),
              Text('2. Grant camera permissions when prompted'),
              SizedBox(height: 8),
              Text('3. Take or upload a clear photo of your face'),
              SizedBox(height: 8),
              Text('4. Wait for AI analysis to complete'),
              SizedBox(height: 8),
              Text('5. View your personalized results'),
              SizedBox(height: 16),
              Text(
                'Disclaimer:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'This analysis is for entertainment and self-improvement purposes only. Results are not medical, psychological, or professional advice. Celebrity matches show resemblance, not identity.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 12),
              Text(
                'Privacy:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Images are processed temporarily and not stored by default.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
