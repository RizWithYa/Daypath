import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'ALEX RIVERA';
  String? _imagePath;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

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
      _isLoading = false;
    });
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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
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
                  _NeuBoxCustom(
                    padding: const EdgeInsets.all(8),
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.arrow_back, color: darkColor, size: 28),
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
                  _NeuBoxCustom(
                    padding: const EdgeInsets.all(8),
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.settings_outlined, color: darkColor, size: 28),
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
                        'LEVEL 24',
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
                  'Productivity Master',
                  style: GoogleFonts.epilogue(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: darkColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Member since JAN 2023',
                style: GoogleFonts.epilogue(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6C757D),
                ),
              ),
              const SizedBox(height: 32),

              // STATS ROW
              Row(
                children: [
                  Expanded(
                    child: _NeuBoxCustom(
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
                            '1,284',
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
                    child: _NeuBoxCustom(
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
                            '15 DAYS',
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
              _NeuBoxCustom(
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
                      children: [
                        _buildGraphPoint(),
                        _buildGraphPoint(),
                        _buildGraphPoint(),
                        _buildGraphPoint(),
                        _buildGraphPoint(),
                        _buildGraphPoint(),
                        _buildGraphPoint(),
                      ],
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ACHIEVEMENTS',
                  style: GoogleFonts.epilogue(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: darkColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    _buildAchievementBadge(Icons.workspace_premium_outlined, 'EARLY BIRD'),
                    const SizedBox(width: 16),
                    _buildAchievementBadge(Icons.bolt, 'FAST MOVER'),
                    const SizedBox(width: 16),
                    _buildAchievementBadge(Icons.star_border, 'PERFECT WEEK'),
                    const SizedBox(width: 16),
                    // Just an empty partial box to hint it's scrollable
                    Container(
                      width: 30,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: const Border(
                          top: BorderSide(color: darkColor, width: 3),
                          bottom: BorderSide(color: darkColor, width: 3),
                          left: BorderSide(color: darkColor, width: 3),
                        ),
                        boxShadow: const [
                          BoxShadow(color: darkColor, offset: Offset(4, 4))
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 120), // Padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraphPoint() {
    // We would use an actual height for the graph point if we had data
    return Container(
      width: 4,
      height: 4,
      color: const Color(0xFF1A1F2B),
    );
  }

  Widget _buildAchievementBadge(IconData icon, String label) {
    const darkColor = Color(0xFF1A1F2B);
    return _NeuBoxCustom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Icon(icon, color: darkColor, size: 32),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.epilogue(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: darkColor,
            ),
          ),
        ],
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

class _NeuBoxCustom extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final double borderRadius;
  final double borderWidth;
  final Offset offset;

  const _NeuBoxCustom({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = Colors.white,
    this.borderRadius = 0.0,
    this.borderWidth = 3.0,
    this.offset = const Offset(5, 5),
  });

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: darkColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: darkColor,
            offset: offset,
            blurRadius: 0,
          )
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
