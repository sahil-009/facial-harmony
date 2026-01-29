import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class BeautyScoreShowdownScreen extends StatefulWidget {
  const BeautyScoreShowdownScreen({super.key});

  @override
  State<BeautyScoreShowdownScreen> createState() =>
      _BeautyScoreShowdownScreenState();
}

class _BeautyScoreShowdownScreenState extends State<BeautyScoreShowdownScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  
  // 6 Players State
  final int _totalPlayers = 6;
  final List<bool> _playersSelected = List.generate(6, (index) => false);
  
  late AnimationController _vsController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  // Mock Data for Results
  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _vsController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _vsController, curve: Curves.easeInOut),
    );
    
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _vsController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _vsController.dispose();
    super.dispose();
  }

  void _startShowdown() {
    // Require at least 2 players to start
    int selectedCount = _playersSelected.where((selected) => selected).length;
    if (selectedCount >= 2) {
      _generateResults(); // Generate mock results before showing
      setState(() {
        _currentStep = 1; // Scanning
      });
      // Simulate scanning duration
      Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _currentStep = 2; // Result
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 2 photos!')),
      );
    }
  }

  void _generateResults() {
    // Create random scores for selected players
    _results = [];
    final random = Random();
    
    for (int i = 0; i < _totalPlayers; i++) {
      if (_playersSelected[i]) {
        double score = 70 + random.nextDouble() * 29; // Score between 70.0 and 99.0
        _results.add({
          'id': i,
          'name': 'Player ${i + 1}',
          'score': double.parse(score.toStringAsFixed(1)),
          'color': Colors.primaries[i % Colors.primaries.length],
        });
      }
    }
    
    // Sort by score descending
    _results.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Beauty Showdown',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
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
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Select up to 6 players',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              itemCount: _totalPlayers,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                return _buildPlayerCard(index);
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
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
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _startShowdown,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
              ),
              child: const Text(
                'START SHOWDOWN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(int index) {
    bool isSelected = _playersSelected[index];
    Color cardColor = Colors.primaries[index % Colors.primaries.length];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _playersSelected[index] = !isSelected;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? cardColor.withOpacity(0.1) : AppColors.bgLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? cardColor : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cardColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected) ...[
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: cardColor,
                    child: const Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_circle, color: cardColor, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Player ${index + 1}',
                style: TextStyle(
                  color: cardColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ] else ...[
              Icon(Icons.add_a_photo, color: Colors.grey.shade400, size: 40),
              const SizedBox(height: 12),
              Text(
                'Add Photo',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Player ${index + 1}',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScanningScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 300,
            width: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Analyzing Central Hub
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0072FF).withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.analytics, color: Colors.white, size: 50),
                  ),
                ),
                // Orbiting Nodes
                AnimatedBuilder(
                  animation: _rotateAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: SizedBox(
                        width: 250,
                        height: 250,
                        child: Stack(
                          children: List.generate(6, (index) {
                            double angle = (2 * pi / 6) * index;
                            return Positioned(
                              left: 125 + 100 * cos(angle) - 15,
                              top: 125 + 100 * sin(angle) - 15,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.primaries[index % Colors.primaries.length],
                                child: const Icon(Icons.face, size: 16, color: Colors.white),
                              ),
                            );
                          }),
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
            'Analyzing All Faces...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Comparing proportions & symmetry',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    if (_results.isEmpty) return const SizedBox();

    final winner = _results[0];

    return Column(
      children: [
        // Winner Section (Top)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF00C6FF).withOpacity(0.1),
                const Color(0xFF0072FF).withOpacity(0.05),
              ],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const Text(
                '🏆 CHAMPION 🏆',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFD700),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD700), width: 4),
                      color: winner['color'],
                      boxShadow: [
                        BoxShadow(
                          color: (winner['color'] as Color).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, size: 80, color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '#1',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                winner['name'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '${winner['score']}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0072FF),
                ),
              ),
            ],
          ),
        ),
        
        // Leaderboard List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _results.length - 1, // Exclude winner
            itemBuilder: (context, index) {
              final item = _results[index + 1];
              final rank = index + 2;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: rank <= 3 ? const Color(0xFFC0C0C0) : AppColors.textMuted, // Silver/Bronze logic simplified
                        ),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: item['color'],
                      radius: 20,
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Text(
                      '${item['score']}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: rank <= 3 ? AppColors.textDark : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        // Actions
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = 0;
                      // Clear selection or keep? Let's keep for easy retry, or clear for new.
                      // Reset selections
                      for(int i=0; i<_totalPlayers; i++) _playersSelected[i] = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('New Showdown'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF0072FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Share Results', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
