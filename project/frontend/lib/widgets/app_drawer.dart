import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      child: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // Premium Header with Face Profile
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.premiumGold,
                      AppColors.premiumPurple,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premiumGold.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Premium Face Profile Icon
                    Container(
                      width: 120,
                      height: 120,
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
                            color: AppColors.premiumGold.withOpacity(0.5),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: AppColors.premiumPurple.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Face outline
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                          // Face icon
                          const Icon(
                            Icons.face,
                            size: 60,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Facial Harmony',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Premium Beauty Analysis',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: [
                    _buildPremiumNavItem(
                      icon: Icons.workspace_premium,
                      title: 'Get Pro',
                      gradient: const LinearGradient(
                        colors: [AppColors.premiumGold, AppColors.premiumPurple],
                      ),
                      isHighlighted: true,
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _buildPremiumNavItem(
                      icon: Icons.language,
                      title: 'Languages',
                      onTap: () {},
                    ),
                    _buildPremiumNavItem(
                      icon: Icons.camera_alt,
                      title: 'Take the right photo',
                      onTap: () {},
                    ),
                    _buildPremiumNavItem(
                      icon: Icons.star,
                      title: 'Rate App',
                      onTap: () {},
                    ),
                    _buildPremiumNavItem(
                      icon: Icons.share,
                      title: 'Share App',
                      onTap: () {},
                    ),
                    _buildPremiumNavItem(
                      icon: Icons.feedback,
                      title: 'Feedback',
                      onTap: () {},
                    ),
                    _buildPremiumNavItem(
                      icon: Icons.privacy_tip,
                      title: 'Privacy Policy',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              
              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.premiumGold.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified,
                        color: AppColors.premiumGold,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Premium Edition',
                        style: TextStyle(
                          color: AppColors.premiumGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumNavItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Gradient? gradient,
    bool isHighlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: AppColors.premiumGold.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? Colors.white.withOpacity(0.2)
                        : AppColors.premiumGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isHighlighted
                        ? Colors.white
                        : AppColors.premiumGold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                      color: isHighlighted ? Colors.white : AppColors.textLight,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isHighlighted
                      ? Colors.white.withOpacity(0.7)
                      : AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
