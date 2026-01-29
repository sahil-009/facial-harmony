class AppConstants {
  // App Info
  static const String appName = 'Facial Harmony';
  static const String appTagline = 'AI-Powered Beauty Analysis';
  
  // Routes
  static const String splashRoute = '/';
  static const String languageRoute = '/language';
  static const String onboardingRoute = '/onboarding';
  static const String homeRoute = '/home';
  static const String faceBeautyAnalysisRoute = '/face-beauty-analysis';
  static const String celebrityLookAlikeRoute = '/celebrity-look-alike';
  static const String facialSymmetryRoute = '/facial-symmetry';
  static const String beautyScoreShowdownRoute = '/beauty-score-showdown';
  static const String facialResemblanceRoute = '/facial-resemblance';
  static const String faceReadingRoute = '/face-reading';
  static const String genderSelectionRoute = '/gender-selection';
  
  // Languages
  static const List<Map<String, String>> languages = [
    {'flag': '🇬🇧', 'name': 'English', 'code': 'en'},
    {'flag': '🇿🇦', 'name': 'Afrikaans', 'code': 'af'},
    {'flag': '🇪🇹', 'name': 'አማርኛ', 'code': 'am'},
    {'flag': '🇸🇦', 'name': 'العربية', 'code': 'ar'},
    {'flag': '🇦🇿', 'name': 'Azərbaycan', 'code': 'az'},
    {'flag': '🇧🇬', 'name': 'Български', 'code': 'bg'},
    {'flag': '🇧🇩', 'name': 'বাংলা', 'code': 'bn'},
    {'flag': '🇪🇸', 'name': 'Català', 'code': 'ca'},
  ];
  
  // Onboarding Content
  static const List<Map<String, String>> onboardingSlides = [
    {
      'title': 'Golden Ratio Face Score',
      'description': 'Welcome to Facial Harmony! Accurate face scoring with AI-Powered Facial Analysis',
    },
    {
      'title': 'Facial Symmetry Analysis',
      'description': 'Discover your facial balance and symmetry with advanced AI technology',
    },
    {
      'title': 'Personalized Beauty Tips',
      'description': 'Get customized recommendations to enhance your natural beauty',
    },
  ];
  
  // Feature Cards
  static const List<Map<String, dynamic>> features = [
    {
      'title': 'Face Beauty\nAnalysis',
      'icon': '✨',
      'badge': 'HOT',
      'gradient': 'pink',
      'size': 'large',
    },
    {
      'title': 'Celebrity Look\nAlike',
      'icon': '🌟',
      'badge': 'HOT',
      'gradient': 'green',
      'size': 'medium',
    },
    {
      'title': 'Facial\nSymmetry',
      'icon': '🪞',
      'badge': 'NEW',
      'gradient': 'purple',
      'size': 'medium',
    },
    {
      'title': 'Beauty Score\nShowdown',
      'icon': '💯',
      'badge': 'HOT',
      'gradient': 'cyan',
      'size': 'medium',
    },
    {
      'title': 'Facial\nResemblance',
      'icon': '👯',
      'badge': null,
      'gradient': 'teal',
      'size': 'medium',
    },
    {
      'title': 'Face\nReading',
      'icon': '🔍',
      'badge': null,
      'gradient': 'peach',
      'size': 'medium',
    },
    {
      'title': 'Beauty\nTips',
      'icon': '💄',
      'badge': null,
      'gradient': 'lavender',
      'size': 'medium',
    },
  ];
}
