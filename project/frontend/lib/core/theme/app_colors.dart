import 'package:flutter/material.dart';

class AppColors {
  // Premium Primary Colors
  static const Color primary = Color(0xFFD4AF37); // Gold
  static const Color primaryDark = Color(0xFFB8941F);
  static const Color secondary = Color(0xFF8B5CF6); // Purple
  static const Color accent = Color(0xFFFF6B9D); // Pink
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color premiumPurple = Color(0xFF6C5CE7);
  static const Color premiumBlue = Color(0xFF5F7FFF);
  
  // Background Colors
  static const Color bgDark = Color(0xFF0F0F1E);
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color bgCard = Color(0xFF1A1A2E);
  
  // Text Colors
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9CA3AF);
  
  // Border & Divider
  static const Color border = Color(0xFF2D2D44);
  
  // Premium Feature Card Gradients
  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B9D), Color(0xFFC44569)],
  );
  
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D9A3), Color(0xFF00A67E)],
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF6C5CE7)],
  );
  
  static const LinearGradient cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5F7FFF), Color(0xFF4C63D2)],
  );
  
  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6)],
  );
  
  static const LinearGradient peachGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9A8B), Color(0xFFFF6B6B)],
  );
  
  static const LinearGradient lavenderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA78BFA), Color(0xFF8B5CF6)],
  );
  
  // Premium Gold Gradient
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
  );
  
  // Premium Purple-Blue Gradient
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C5CE7), Color(0xFF5F7FFF), Color(0xFF4ECDC4)],
  );
}
