import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_application_v1/models.dart';
import 'widgets.dart';

  class ProfilePage extends StatefulWidget {
  final void Function(int)? onNavigateToTab;
  final GlobalKey<ProfilePageState>? profileKey;
  const ProfilePage({super.key, this.onNavigateToTab, this.profileKey});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  void refreshData() {
    _loadProfileData();
  }
  String _userName = 'ALEX RIVERA';
  String? _imagePath;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  int _tasksDone = 0;
  int _streakDays = 0;
  DateTime? _memberSince;
  List<int> _weeklyProgress = [];
  List<String> _unlockedAchievementIds = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'ALEX RIVERA';
      _imagePath = prefs.getString('profile_image_path');
      _tasksDone = prefs.getInt('tasks_done') ?? 0;
      _streakDays = prefs.getInt('streak_days') ?? 0;
      
      String? memberSinceStr = prefs.getString('member_since');
      if (memberSinceStr != null) {
        try {
          _memberSince = DateTime.parse(memberSinceStr);
        } catch (e) {
          _memberSince = DateTime.now();
          prefs.setString('member_since', _memberSince!.toIso8601String());
        }
      } else {
        _memberSince = DateTime.now();
        prefs.setString('member_since', _memberSince!.toIso8601String());
      }

      String? weeklyProgressStr = prefs.getString('weekly_progress');
      if (weeklyProgressStr != null) {
        try {
          _weeklyProgress = List<int>.from(jsonDecode(weeklyProgressStr));
        } catch (e) {
          _weeklyProgress = List.generate(7, (_) => 0);
        }
      } else {
        _weeklyProgress = List.generate(7, (_) => 0);
        prefs.setString('weekly_progress', jsonEncode(_weeklyProgress));
      }
      _unlockedAchievementIds = prefs.getStringList('unlocked_achievement_ids') ?? [];

      _isLoading = false;
    });
  }

  Future<void> _resetProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _loadProfileData();
  }

  void _showSettingsSheet() {
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
              Text(
                'SETTINGS',
                style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, fontSize: 20, color: darkColor),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _showResetConfirmation();
                },
                child: NeuBox(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  backgroundColor: const Color(0xFFFF649C),
                  child: Row(
                    children: [
                      const Icon(Icons.refresh, color: darkColor),
                      const SizedBox(width: 12),
                      Text(
                        'RESET PROFILE',
                        style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, color: darkColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              NeuBox(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFFE8EDFF),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ABOUT',
                      style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, fontSize: 14, color: darkColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'App Name: Todo Neubrutalism',
                      style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, fontSize: 12, color: darkColor),
                    ),
                    Text(
                      'Version: 1.0.0',
                      style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, fontSize: 12, color: darkColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  },
);
  }

  void _showResetConfirmation() {
    const darkColor = Color(0xFF1A1F2B);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: const BorderSide(color: darkColor, width: 3),
        ),
        title: Text('RESET ALL DATA?', style: GoogleFonts.epilogue(fontWeight: FontWeight.w900)),
        content: Text('This will clear all your progress and settings.', style: GoogleFonts.epilogue(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF649C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0), side: const BorderSide(color: darkColor, width: 2)),
            ),
            onPressed: () {
              _resetProfile();
              Navigator.pop(context);
            },
            child: Text('RESET', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, color: darkColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    setState(() {
      _userName = name;
    });
  }

  Future<void> _saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
    setState(() {
      _imagePath = path;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        await _saveImagePath(pickedFile.path);
      }
    } catch (e) {
      debugPrint("Failed to pick image: $e");
    }
  }

  void _showEditNameDialog() {
    final TextEditingController nameController = TextEditingController(text: _userName);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF1A1F2B), width: 3),
          ),
          title: Text(
            'EDIT NAME',
            style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, color: const Color(0xFF1A1F2B)),
          ),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Enter your name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1A1F2B), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1A1F2B), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: GoogleFonts.epilogue(fontWeight: FontWeight.w700, color: Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  _saveUserName(nameController.text.trim().toUpperCase());
                  Navigator.pop(context);
                }
              },
              child: Text('SAVE', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showImagePickerOptions() {
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
              top: BorderSide(color: Color(0xFF1A1F2B), width: 3),
              left: BorderSide(color: Color(0xFF1A1F2B), width: 3),
              right: BorderSide(color: Color(0xFF1A1F2B), width: 3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'UPDATE PROFILE PICTURE',
                style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF1A1F2B)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFFFFBA24), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1A1F2B), width: 3)),
                          child: const Icon(Icons.camera_alt, size: 32, color: Color(0xFF1A1F2B)),
                        ),
                        const SizedBox(height: 8),
                        Text('Camera', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, fontSize: 14)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFF007BFF), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1A1F2B), width: 3)),
                          child: const Icon(Icons.photo_library, size: 32, color: Color(0xFF1A1F2B)),
                        ),
                        const SizedBox(height: 8),
                        Text('Gallery', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  },
);
  }

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFE8EDFF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE8EDFF), // Light periwinkle background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => widget.onNavigateToTab?.call(0),
                    child: NeuBox(
                      padding: const EdgeInsets.all(8),
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.arrow_back, color: darkColor, size: 28),
                    ),
                  ),

                  Text(
                    'PROFILE',
                    style: GoogleFonts.epilogue(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: darkColor,
                      letterSpacing: -1,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showSettingsSheet,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: NeuBox(
                          padding: const EdgeInsets.all(8),
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.settings_outlined, color: darkColor, size: 28),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 32),

              // AVATAR AREA
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECCC), // Light peach background
                        shape: BoxShape.circle,
                        border: Border.all(color: darkColor, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: darkColor,
                            offset: Offset(5, 5),
                          )
                        ],
                        image: _imagePath != null && File(_imagePath!).existsSync()
                            ? DecorationImage(
                                image: FileImage(File(_imagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      // Placeholder avatar
                      child: _imagePath == null || !File(_imagePath!).existsSync()
                          ? const Icon(
                              Icons.person,
                              size: 80,
                              color: Color(0xFFFFCCA8), // Darker peach icon fallback
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF649C), // Pink level badge
                        border: Border.all(color: darkColor, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: darkColor,
                            offset: Offset(3, 3),
                          )
                        ],
                      ),
                      child: Text(
                        'LEVEL ${(_tasksDone ~/ 50) + 1}',
                        style: GoogleFonts.epilogue(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: darkColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _userName,
                    style: GoogleFonts.epilogue(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: darkColor,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showEditNameDialog,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: darkColor, width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.edit, size: 16, color: darkColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6DE89D), // Green badge
                  border: Border.all(color: darkColor, width: 2),
                ),
                child: Text(
                  _unlockedAchievementIds.isEmpty 
                    ? 'Productivity Master' 
                    : Achievement.defaultAchievements.firstWhere((a) => a.id == _unlockedAchievementIds.last).title,
                  style: GoogleFonts.epilogue(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: darkColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Member since ${DateFormat('MMM yyyy').format(_memberSince ?? DateTime.now()).toUpperCase()}',
                style: GoogleFonts.epilogue(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6C757D),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: NeuBox(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TASKS DONE',
                            style: GoogleFonts.epilogue(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF6C757D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            NumberFormat('#,###').format(_tasksDone),
                            style: GoogleFonts.epilogue(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: darkColor,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(
                              color: darkColor,
                            ),
                            child: Text(
                              '+12% UP',
                              style: GoogleFonts.epilogue(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF6DE89D), // Green text
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NeuBox(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: const Color(0xFFF7FF5C), // Yellow bg
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STREAK',
                            style: GoogleFonts.epilogue(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: darkColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_streakDays DAYS',
                            style: GoogleFonts.epilogue(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: darkColor,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: darkColor, width: 2)),
                            ),
                            child: Text(
                              'CURRENT BEST',
                              style: GoogleFonts.epilogue(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: darkColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // WEEKLY PROGRESS
              NeuBox(
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFFF649C), width: 3)), // Pink underline
                      ),
                      child: Text(
                        'WEEKLY PROGRESS',
                        style: GoogleFonts.epilogue(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: darkColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48), // Padding before graph
                    // A simple line graph representation
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        int value = _weeklyProgress.length > index ? _weeklyProgress[index] : 0;
                        return _buildBar(value);
                      }),
                    ),
                    Container(
                      height: 4,
                      width: double.infinity,
                      color: darkColor,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _DayLabel('M'),
                        _DayLabel('T'),
                        _DayLabel('W'),
                        _DayLabel('T'),
                        _DayLabel('F'),
                        _DayLabel('S'),
                        _DayLabel('S'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ACHIEVEMENTS
              _buildAchievementCategory(
                title: 'ACHIEVEMENTS EARNED',
                achievements: Achievement.defaultAchievements.where((a) => _unlockedAchievementIds.contains(a.id)).toList(),
                isUnlocked: true,
              ),
              const SizedBox(height: 16),
              _buildAchievementCategory(
                title: 'YET TO UNLOCK',
                achievements: Achievement.defaultAchievements.where((a) => !_unlockedAchievementIds.contains(a.id)).toList(),
                isUnlocked: false,
              ),
              const SizedBox(height: 120), // Padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBar(int count) {
    const darkColor = Color(0xFF1A1F2B);
    // Calculate height: 4px base + 8px per task, max 100px
    double height = 4.0 + (count * 8.0);
    if (height > 100) height = 100;

    return Container(
      width: 20,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF6DE89D),
        border: Border.all(color: darkColor, width: 2),
        boxShadow: const [
          BoxShadow(color: darkColor, offset: Offset(2, 2)),
        ],
      ),
    );
  }

  Widget _buildAchievementCategory({
    required String title,
    required List<Achievement> achievements,
    required bool isUnlocked,
  }) {
    const darkColor = Color(0xFF1A1F2B);
    return NeuBox(
      padding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      child: ExpansionTile(
        title: Text(
          title,
          style: GoogleFonts.epilogue(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: darkColor,
          ),
        ),
        iconColor: darkColor,
        collapsedIconColor: darkColor,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        children: achievements.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'NO ACHIEVEMENTS YET',
                    style: GoogleFonts.epilogue(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                )
              ]
            : achievements.map((a) => _buildAchievementItem(a, isUnlocked)).toList(),
      ),
    );
  }

  Widget _buildAchievementItem(Achievement achievement, bool isUnlocked) {
    const darkColor = Color(0xFF1A1F2B);
    const ColorFilter greyscale = ColorFilter.matrix(<double>[
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0, 0, 0, 1, 0,
    ]);

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: darkColor, width: 2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ColorFiltered(
          colorFilter: isUnlocked ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply) : greyscale,
          child: Icon(achievement.icon, color: darkColor, size: 32),
        ),
        title: Text(
          achievement.title.toUpperCase(),
          style: GoogleFonts.epilogue(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: darkColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'HOW TO UNLOCK',
              style: GoogleFonts.epilogue(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFF649C), // Pink accent
              ),
            ),
            Text(
              achievement.description,
              style: GoogleFonts.epilogue(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: darkColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String label;

  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.epilogue(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1F2B),
          ),
        ),
      ),
    );
  }
}

