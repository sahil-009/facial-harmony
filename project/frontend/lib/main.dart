import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'screens/splash_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/face_beauty_analysis_screen.dart';
import 'screens/celebrity_look_alike_screen.dart';

import 'screens/facial_symmetry_screen.dart';

import 'screens/beauty_score_showdown_screen.dart';
import 'screens/facial_resemblance_screen.dart';
import 'screens/face_reading_screen.dart';
import 'screens/gender_selection_screen.dart';

import 'services/device_service.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize unique device ID
  await DeviceService().getDeviceId();
  runApp(const FacialHarmonyApp());
}

class FacialHarmonyApp extends StatelessWidget {
  const FacialHarmonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppConstants.splashRoute,
      routes: {
        AppConstants.splashRoute: (context) => const SplashScreen(),
        AppConstants.languageRoute: (context) => const LanguageSelectionScreen(),
        AppConstants.onboardingRoute: (context) => const OnboardingScreen(),
        AppConstants.genderSelectionRoute: (context) => const GenderSelectionScreen(),
        AppConstants.homeRoute: (context) => const HomeScreen(),
        AppConstants.faceBeautyAnalysisRoute: (context) => const FaceBeautyAnalysisScreen(),
        AppConstants.celebrityLookAlikeRoute: (context) =>
            const CelebrityLookAlikeScreen(),
        AppConstants.facialSymmetryRoute: (context) => const FacialSymmetryScreen(),
        AppConstants.beautyScoreShowdownRoute: (context) => const BeautyScoreShowdownScreen(),
        AppConstants.facialResemblanceRoute: (context) => const FacialResemblanceScreen(),
        AppConstants.faceReadingRoute: (context) => const FaceReadingScreen(),
      },
    );
  }
}
