import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tasks_page.dart';

void main() {
  runApp(const MuslimDailyApp());
}

class MuslimDailyApp extends StatelessWidget {
  const MuslimDailyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Muslim Daily',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFDCF6E3), // Light green tint
        textTheme: GoogleFonts.epilogueTextTheme(),
        primaryColor: const Color(0xFF1A1F2B),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  void _onNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const _HomeView(),
          const TasksPage(),
          const Center(child: Text('Habits')),
          const Center(child: Text('Profile')),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  Map<String, String>? _prayerTimes;
  String _nextPrayerName = 'Loading...';
  String _countdown = '00:00:00';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
    _timer = Timer.periodic(const Duration(seconds: 1), _updateCountdown);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.aladhan.com/v1/timingsByCity?city=Jakarta&country=Indonesia&method=11'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];
        setState(() {
          _prayerTimes = {
            'Fajr': timings['Fajr'],
            'Dhuhr': timings['Dhuhr'],
            'Asr': timings['Asr'],
            'Maghrib': timings['Maghrib'],
            'Isha': timings['Isha'],
          };
        });
        _updateCountdown(null);
      }
    } catch (e) {
      debugPrint('Failed to load prayer times: $e');
    }
  }

  void _updateCountdown(Timer? timer) {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    DateTime? nextTime;
    String nextName = '';

    for (var entry in _prayerTimes!.entries) {
      final parts = entry.value.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final prayerTime = DateTime(now.year, now.month, now.day, hour, minute);
      
      if (prayerTime.isAfter(now)) {
        nextTime = prayerTime;
        nextName = entry.key;
        break;
      }
    }

    if (nextTime == null) {
       final fajrParts = _prayerTimes!['Fajr']!.split(':');
       nextTime = DateTime(now.year, now.month, now.day + 1, int.parse(fajrParts[0]), int.parse(fajrParts[1]));
       nextName = 'Fajr';
    }

    final diff = nextTime.difference(now);
    
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(diff.inHours);
    final minutes = twoDigits(diff.inMinutes.remainder(60));
    final seconds = twoDigits(diff.inSeconds.remainder(60));

    setState(() {
      _nextPrayerName = nextName;
      _countdown = '$hours:$minutes:$seconds';
    });
  }

  String _getTime12Hour(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final ampm = hour >= 12 ? 'PM' : 'AM';
    int hour12 = hour % 12;
    if (hour12 == 0) hour12 = 12;
    final minStr = minute.toString().padLeft(2, '0');
    return '$hour12:$minStr $ampm';
  }

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- APP BAR ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NeuButton(
                  onTap: () {},
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('icon/main_icon/3_Menubar.png', width: 24, height: 24),
                ),
                Text(
                  'MUSLIM DAILY',
                  style: GoogleFonts.epilogue(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: darkColor,
                    letterSpacing: -0.5,
                  ),
                ),
                NeuButton(
                  onTap: () {},
                  color: const Color(0xFFFFBA24), // Yellow
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('icon/main_icon/User.png', width: 24, height: 24),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- NEXT PRAYER CARD ---
            Stack(
              children: [
                NeuBox(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  borderRadius: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_nextPrayerName in',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _countdown,
                          style: GoogleFonts.outfit(
                            fontSize: 68,
                            fontWeight: FontWeight.w800,
                            color: darkColor,
                            height: 1.0,
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Image.asset(
                            'icon/main_icon/Location.png', 
                            width: 24, 
                            height: 24,
                            errorBuilder: (_, _, _) => const Icon(Icons.location_on_outlined, color: Color(0xFF007BFF), size: 24),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Jakarta, Indonesia',
                              style: GoogleFonts.epilogue(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: darkColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: NeuButton(
                          onTap: () {},
                          color: const Color(0xFF007BFF),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          borderRadius: 12,
                          child: const Center(
                            child: Text(
                              'SET REMINDER',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF007BFF),
                      border: Border(
                        bottom: BorderSide(color: darkColor, width: 3.5),
                        left: BorderSide(color: darkColor, width: 3.5),
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'NEXT PRAYER',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- TODAY'S SCHEDULE ---
            Text(
              'TODAY\'S SCHEDULE',
              style: GoogleFonts.epilogue(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 16),

            if (_prayerTimes == null)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Column(
                children: [
                  ScheduleItem(
                    title: 'Fajr',
                    time: _getTime12Hour(_prayerTimes!['Fajr']!),
                    iconAsset: 'icon/main_icon/Fajr.png',
                    iconBgColor: const Color(0xFFFF649C),
                    isActive: _nextPrayerName == 'Fajr',
                    isMuted: true,
                  ),
                  const SizedBox(height: 12),
                  ScheduleItem(
                    title: 'Dhuhr',
                    time: _getTime12Hour(_prayerTimes!['Dhuhr']!),
                    iconAsset: 'icon/main_icon/Dhuhr.png',
                    iconBgColor: Colors.white,
                    isActive: _nextPrayerName == 'Dhuhr',
                    isMuted: false,
                  ),
                  const SizedBox(height: 12),
                  ScheduleItem(
                    title: 'Asr',
                    time: _getTime12Hour(_prayerTimes!['Asr']!),
                    iconAsset: 'icon/main_icon/Asr.png',
                    iconBgColor: const Color(0xFFCCE4FF),
                    isActive: _nextPrayerName == 'Asr',
                    isMuted: false,
                  ),
                  const SizedBox(height: 12),
                  ScheduleItem(
                    title: 'Maghrib',
                    time: _getTime12Hour(_prayerTimes!['Maghrib']!),
                    iconAsset: 'icon/main_icon/Maghrib.png',
                    iconBgColor: darkColor,
                    isActive: _nextPrayerName == 'Maghrib',
                    isMuted: true,
                    iconColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  ScheduleItem(
                    title: 'Isha',
                    time: _getTime12Hour(_prayerTimes!['Isha']!),
                    iconAsset: 'icon/main_icon/Maghrib.png', // Fallback icon since Isha.png was not provided
                    iconBgColor: const Color(0xFF1A1F2B),
                    isActive: _nextPrayerName == 'Isha',
                    isMuted: false,
                    iconColor: Colors.white,
                  ),
                ],
              ),

            const SizedBox(height: 30),

            // --- YOUR LOCATION ---
            Text(
              'YOUR LOCATION',
              style: GoogleFonts.epilogue(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 16),
            NeuBox(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.5),
                child: Image.asset(
                  'icon/main_icon/Overlay+Border+Shadow.png', // Assuming map snippet
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[300],
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: Colors.white,
                      child: const Text(
                        'LONDON, UK',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 100), // padding for bottom nav
          ],
        ),
      ),
    );
  }
}

// --- REUSABLE COMPONENTS ---

class NeuBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final double borderRadius;

  const NeuBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = Colors.white,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFF1A1F2B), width: 3.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1F2B),
            offset: Offset(borderRadius > 8 ? 6 : 4, borderRadius > 8 ? 6 : 4),
            blurRadius: 0,
          )
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

class NeuButton extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback onTap;
  final double borderRadius;

  const NeuButton({
    super.key,
    required this.child,
    required this.onTap,
    this.padding = const EdgeInsets.all(12),
    this.color = Colors.white,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeuBox(
        padding: padding,
        backgroundColor: color,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}

class ScheduleItem extends StatelessWidget {
  final String title;
  final String time;
  final String iconAsset;
  final Color iconBgColor;
  final bool isActive;
  final bool isMuted;
  final Color? iconColor;

  const ScheduleItem({
    super.key,
    required this.title,
    required this.time,
    required this.iconAsset,
    required this.iconBgColor,
    required this.isActive,
    required this.isMuted,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    return NeuBox(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: isActive ? const Color(0xFFFFBA24) : Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: darkColor, width: 2),
            ),
            child: Image.asset(
              iconAsset,
              width: 20,
              height: 20,
              color: iconColor,
              errorBuilder: (_, _, _) => const Icon(Icons.wb_sunny_outlined, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: darkColor,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isActive ? darkColor : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isMuted ? Icons.notifications_off_outlined : Icons.notifications_active_outlined,
            color: isMuted ? Colors.grey[400] : darkColor,
            size: 28,
          ),
        ],
      ),
    );
  }
}

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 80,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: NeuBox(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildNavItem(0, 'Home', 'icon/main_icon/Home_navbar.png')),
                    Expanded(child: _buildNavItem(1, 'Tasks', 'icon/main_icon/Task_navbar.png')),
                    const SizedBox(width: 48), // space for center FAB
                    Expanded(child: _buildNavItem(2, 'Habits', 'icon/main_icon/Habits_navbar.png')),
                    Expanded(child: _buildNavItem(3, 'Profile', 'icon/main_icon/Profile_navbar.png')),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -20,
              left: 0,
              right: 0,
              child: Center(
                child: NeuButton(
                  onTap: () {},
                  color: const Color(0xFF007BFF),
                  padding: const EdgeInsets.all(12),
                  borderRadius: 4, // Square sharp look
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String iconAsset) {
    final isActive = currentIndex == index;
    final color = isActive ? const Color(0xFF007BFF) : Colors.grey[500];
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(0, isActive ? -6.0 : 0.0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconAsset, 
              width: 24, 
              height: 24, 
              color: color,
              errorBuilder: (_, _, _) => Icon(Icons.circle, size: 24, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
