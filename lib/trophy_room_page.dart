import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'widgets.dart';

class TrophyRoomPage extends StatefulWidget {
  const TrophyRoomPage({super.key});

  @override
  State<TrophyRoomPage> createState() => _TrophyRoomPageState();
}

class _TrophyRoomPageState extends State<TrophyRoomPage> {
  bool _isLoading = true;
  List<String> _unlockedIds = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unlockedIds = prefs.getStringList('unlocked_achievement_ids') ?? [];
      _stats = {
        'tasks_done': prefs.getInt('tasks_done') ?? 0,
        'urgent_tasks_done': prefs.getInt('urgent_tasks_done') ?? 0,
        'streak_days': prefs.getInt('streak_days') ?? 0,
      };
      _isLoading = false;
    });
  }

  double _calculateProgress(String id) {
    switch (id) {
      case 'first_task':
        return (_stats['tasks_done'] >= 1) ? 1.0 : 0.0;
      case 'urgent_fighter':
        return (_stats['urgent_tasks_done'] / 5.0).clamp(0.0, 1.0);
      case 'productivity_master':
        return (_stats['tasks_done'] / 10.0).clamp(0.0, 1.0);
      case 'streak_master':
        return (_stats['streak_days'] / 3.0).clamp(0.0, 1.0);
      default:
        return _unlockedIds.contains(id) ? 1.0 : 0.0;
    }
  }

  String _getProgressText(String id) {
    switch (id) {
      case 'urgent_fighter':
        return '${_stats['urgent_tasks_done']}/5';
      case 'productivity_master':
        return '${_stats['tasks_done']}/10';
      case 'streak_master':
        return '${_stats['streak_days']}/3';
      default:
        return _unlockedIds.contains(id) ? 'UNLOCKED' : 'LOCKED';
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    final allAchievements = Achievement.defaultAchievements;

    return Scaffold(
      backgroundColor: const Color(0xFFFFECCC), // Warm Neubrutalist peach
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'TROPHY ROOM',
                        style: GoogleFonts.epilogue(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: darkColor,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: allAchievements.length,
                    itemBuilder: (context, index) {
                      final achievement = allAchievements[index];
                      final isUnlocked = _unlockedIds.contains(achievement.id);
                      final progress = _calculateProgress(achievement.id);
                      
                      return _buildTrophyCard(achievement, isUnlocked, progress);
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildTrophyCard(Achievement achievement, bool isUnlocked, double progress) {
    const darkColor = Color(0xFF1A1F2B);
    const ColorFilter greyscale = ColorFilter.matrix(<double>[
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0, 0, 0, 1, 0,
    ]);

    return GestureDetector(
      onTap: () {
        _showAchievementDetail(context, achievement, isUnlocked, progress);
      },
      child: NeuBox(
        padding: const EdgeInsets.all(16),
        backgroundColor: isUnlocked ? const Color(0xFF86EFAC) : Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColorFiltered(
              colorFilter: isUnlocked ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply) : greyscale,
              child: Icon(achievement.icon, size: 48, color: darkColor),
            ),
            const SizedBox(height: 12),
            Text(
              achievement.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.epilogue(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 8),
            // Progress Bar
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                border: Border.all(color: darkColor, width: 2),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      color: isUnlocked ? Theme.of(context).colorScheme.primary : const Color(0xFFFF649C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getProgressText(achievement.id),
              style: GoogleFonts.epilogue(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: darkColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetail(BuildContext context, Achievement achievement, bool isUnlocked, double progress) {
    const darkColor = Color(0xFF1A1F2B);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                border: Border(
                  top: BorderSide(color: darkColor, width: 3),
                  left: BorderSide(color: darkColor, width: 3),
                  right: BorderSide(color: darkColor, width: 3),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isUnlocked ? const Color(0xFF86EFAC) : const Color(0xFFE8EDFF),
                        shape: BoxShape.circle,
                        border: Border.all(color: darkColor, width: 3),
                      ),
                      child: Icon(achievement.icon, size: 40, color: darkColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      achievement.title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, fontSize: 24, color: darkColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      achievement.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'HOW TO ACHIEVE',
                    style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, fontSize: 14, color: darkColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.howToAchieve,
                    style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, fontSize: 14, color: darkColor),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: NeuBox(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Center(
                          child: Text(
                            'CLOSE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
