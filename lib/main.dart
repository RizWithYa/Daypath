import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    
    return Scaffold(
      body: SafeArea(
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
                          'Asr in',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6C757D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '02:15:42',
                          style: GoogleFonts.outfit(
                            fontSize: 68,
                            fontWeight: FontWeight.w800,
                            color: darkColor,
                            height: 1.0,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Image.asset('icon/main_icon/Location.png', width: 24, height: 24),
                            const SizedBox(width: 8),
                            Text(
                              'London, United Kingdom',
                              style: GoogleFonts.epilogue(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: darkColor,
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

              ScheduleItem(
                title: 'Fajr',
                time: '05:12 AM',
                iconAsset: 'icon/main_icon/Fajr.png', // Assuming we use these
                iconBgColor: const Color(0xFFFF649C),
                isActive: false,
                isMuted: true,
              ),
              const SizedBox(height: 12),
              ScheduleItem(
                title: 'Dhuhr',
                time: '01:05 PM',
                iconAsset: 'icon/main_icon/Dhuhr.png',
                iconBgColor: Colors.white,
                isActive: true,
                isMuted: false,
              ),
              const SizedBox(height: 12),
              ScheduleItem(
                title: 'Asr',
                time: '04:22 PM',
                iconAsset: 'icon/main_icon/Asr.png',
                iconBgColor: const Color(0xFFCCE4FF),
                isActive: false,
                isMuted: false,
              ),
              const SizedBox(height: 12),
              ScheduleItem(
                title: 'Maghrib',
                time: '07:45 PM',
                iconAsset: 'icon/main_icon/Maghrib.png',
                iconBgColor: darkColor,
                isActive: false,
                isMuted: true,
                iconColor: Colors.white,
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
      ),
      bottomNavigationBar: const CustomBottomNav(),
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
              errorBuilder: (_, __, ___) => const Icon(Icons.wb_sunny_outlined, size: 20),
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
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    return SafeArea(
      child: Container(
        height: 70,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: NeuBox(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem('Home', 'icon/main_icon/Home.png', true),
                    _buildNavItem('Tasks', 'icon/main_icon/Tasks.png', false),
                    const SizedBox(width: 40), // space for center FAB
                    _buildNavItem('Habits', 'icon/main_icon/Habits.png', false),
                    _buildNavItem('Profile', 'icon/main_icon/Profile.png', false),
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

  Widget _buildNavItem(String label, String iconAsset, bool isActive) {
    final color = isActive ? const Color(0xFF007BFF) : Colors.grey[500];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          iconAsset, 
          width: 24, 
          height: 24, 
          color: color,
          errorBuilder: (_, __, ___) => Icon(Icons.circle, size: 24, color: color),
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
    );
  }
}
