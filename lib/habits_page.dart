import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1E4), // Light cream background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NeuBoxCustom(
                    padding: const EdgeInsets.all(8),
                    backgroundColor: const Color(0xFF007BFF), // Blue icon bg
                    child: const Icon(Icons.calendar_month, color: Colors.white, size: 28),
                  ),
                  Text(
                    'HABIT.TRACK',
                    style: GoogleFonts.epilogue(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: darkColor,
                      letterSpacing: -1,
                    ),
                  ),
                  _NeuBoxCustom(
                    padding: const EdgeInsets.all(8),
                    backgroundColor: const Color(0xFFFFBA24), // Yellow
                    child: const Icon(Icons.person_outline, color: darkColor, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // CALENDAR
              _NeuBoxCustom(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _NeuBoxCustom(
                          padding: const EdgeInsets.all(4),
                          backgroundColor: const Color(0xFFFF649C), // Pink
                          borderWidth: 2,
                          offset: const Offset(3, 3),
                          child: const Icon(Icons.chevron_left, color: darkColor, size: 20),
                        ),
                        Text(
                          'OCTOBER 2023',
                          style: GoogleFonts.epilogue(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: darkColor,
                          ),
                        ),
                        _NeuBoxCustom(
                          padding: const EdgeInsets.all(4),
                          backgroundColor: const Color(0xFFFF649C), // Pink
                          borderWidth: 2,
                          offset: const Offset(3, 3),
                          child: const Icon(Icons.chevron_right, color: darkColor, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDayHeader('SUN'),
                        _buildDayHeader('MON'),
                        _buildDayHeader('TUE'),
                        _buildDayHeader('WED'),
                        _buildDayHeader('THU'),
                        _buildDayHeader('FRI'),
                        _buildDayHeader('SAT'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDateItem('28', isMuted: true),
                        _buildDateItem('29', isMuted: true),
                        _buildDateItem('30', isMuted: true),
                        _buildDateItem('1', isSelected: false),
                        _buildDateItem('2', isSelected: false),
                        _buildDateItem('3', isSelected: false),
                        _buildDateItem('4', isSelected: false),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDateItem('5', isSelected: true),
                        _buildDateItem('6', isSelected: false),
                        _buildDateItem('7', isSelected: false),
                        _buildDateItem('8', isSelected: false),
                        _buildDateItem('9', isSelected: false),
                        _buildDateItem('10', isSelected: false),
                        _buildDateItem('11', isSelected: false),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // DAILY FOCUS
              Text(
                'DAILY FOCUS',
                style: GoogleFonts.epilogue(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: darkColor,
                ),
              ),
              const SizedBox(height: 12),
              _NeuBoxCustom(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFF86EFAC), // Light green
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LEVEL UP!',
                          style: GoogleFonts.epilogue(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: darkColor,
                          ),
                        ),
                        Text(
                          '65%',
                          style: GoogleFonts.epilogue(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: darkColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress Bar
                    Container(
                      height: 24,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: darkColor, width: 3),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 65,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF007BFF),
                                border: const Border(right: BorderSide(color: darkColor, width: 3)),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 35,
                            child: Container(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"Almost there, keep crushing it!"',
                      style: GoogleFonts.epilogue(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: darkColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // HABIT LIST items
              _HabitItem(
                title: 'DRINK WATER',
                subtitle: '2L / 3L Daily',
                iconIcon: Icons.water_drop_outlined,
                iconBgColor: const Color(0xFFB5D8FF), // Light blue
                checkedColor: const Color(0xFF007BFF),
                isChecked: true,
              ),
              const SizedBox(height: 16),
              _HabitItem(
                title: 'READ BOOK',
                subtitle: '20 / 20 Pages',
                iconIcon: Icons.menu_book,
                iconBgColor: const Color(0xFFE4C1F9), // Light purple
                checkedColor: const Color(0xFF22C55E), // Green
                isChecked: true,
                isCheckMarkDouble: true,
              ),
              const SizedBox(height: 16),
              _HabitItem(
                title: 'WORKOUT',
                subtitle: '0 / 45 Mins',
                iconIcon: Icons.fitness_center,
                iconBgColor: const Color(0xFFFFD19A), // Orange
                checkedColor: Colors.white,
                isChecked: false,
              ),

              const SizedBox(height: 120), // Padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayHeader(String text) {
    return SizedBox(
      width: 36,
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.epilogue(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1F2B),
          ),
        ),
      ),
    );
  }

  Widget _buildDateItem(String day, {bool isMuted = false, bool isSelected = false}) {
    const darkColor = Color(0xFF1A1F2B);
    if (isMuted) {
      return SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Text(
            day,
            style: GoogleFonts.epilogue(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
        ),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF007BFF) : Colors.white,
        border: Border.all(color: darkColor, width: 2),
      ),
      child: Center(
        child: Text(
          day,
          style: GoogleFonts.epilogue(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : darkColor,
          ),
        ),
      ),
    );
  }
}

class _HabitItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconIcon;
  final Color iconBgColor;
  final Color checkedColor;
  final bool isChecked;
  final bool isCheckMarkDouble;

  const _HabitItem({
    required this.title,
    required this.subtitle,
    required this.iconIcon,
    required this.iconBgColor,
    required this.checkedColor,
    required this.isChecked,
    this.isCheckMarkDouble = false,
  });

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    return _NeuBoxCustom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      borderRadius: 0,
      borderWidth: 3,
      offset: const Offset(4, 4),
      backgroundColor: Colors.white,
      child: Row(
        children: [
          // Left Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              border: Border.all(color: darkColor, width: 2.5),
            ),
            child: Icon(iconIcon, color: darkColor, size: 24),
          ),
          const SizedBox(width: 16),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.epilogue(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: darkColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6C757D),
                  ),
                ),
              ],
            ),
          ),
          // Checkbox Idea
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isChecked ? checkedColor : Colors.white,
              border: Border.all(color: darkColor, width: 2.5),
            ),
            child: isChecked
                ? Icon(isCheckMarkDouble ? Icons.done_all : Icons.check, color: isCheckMarkDouble ? darkColor : Colors.white, size: 30) // from img, the checkmarks are black/darkColor. Wait, first checkmark is white in pic. Let's look closely at image. Drink Water has a white checkmark. Read book has a double black checkmark. Workout has a grey checkmark.
                : const Icon(Icons.check, color: Color(0xFFD3D8E0), size: 30),
          ),
        ],
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
