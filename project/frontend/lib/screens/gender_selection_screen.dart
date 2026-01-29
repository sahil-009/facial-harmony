import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../services/ad_service.dart';
import '../services/api_service.dart';
import '../services/device_service.dart';
import 'facial_symmetry_screen.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedGender;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  void _continue() {
    if (_selectedGender != null) {
      DeviceService().saveGender(_selectedGender!);
      Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender to continue'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Title
              FadeTransition(
                opacity: _animationController,
                child: const Text(
                  'Select Your Gender',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 12),
              
              FadeTransition(
                opacity: _animationController,
                child: Text(
                  'Help us personalize your experience',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Gender Cards
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildGenderCard(
                        gender: 'Male',
                        icon: '👨',
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildGenderCard(
                        gender: 'Female',
                        icon: '👩',
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedGender != null
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: _selectedGender != null ? 5 : 0,
                  ),
                  child: Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _selectedGender != null
                          ? Colors.white
                          : Colors.grey.shade500,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard({
    required String gender,
    required String icon,
    required Gradient gradient,
  }) {
    final isSelected = _selectedGender == gender;
    
    return GestureDetector(
      onTap: () => _selectGender(gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: isSelected ? 1.1 : 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Label
            Text(
              gender,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Check icon
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: gradient.colors.first,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
