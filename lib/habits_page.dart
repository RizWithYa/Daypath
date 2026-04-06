import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Habit {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  bool isCompleted;

  Habit({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isCompleted = false,
  });
}

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  final List<Habit> _habits = [
    Habit(
      title: 'TILAWAH QURAN',
      subtitle: 'Read at least 1 Juz/Page',
      icon: Icons.menu_book,
      color: const Color(0xFFE4C1F9),
    ),
    Habit(
      title: 'MORNING DHIKR',
      subtitle: 'Start the day with remembrance',
      icon: Icons.wb_sunny_outlined,
      color: const Color(0xFFFFD19A),
    ),
    Habit(
      title: 'SUNNAH PRAYER',
      subtitle: 'Duha, Tahajjud, or Rawatib',
      icon: Icons.mosque_outlined,
      color: const Color(0xFFB5D8FF),
    ),
    Habit(
      title: 'GIVE CHARITY',
      subtitle: 'Small act of kindness counts',
      icon: Icons.favorite_border,
      color: const Color(0xFFFFB5D8),
    ),
  ];

  double get _completionPercentage {
    if (_habits.isEmpty) return 0;
    int completedCount = _habits.where((h) => h.isCompleted).length;
    return (completedCount / _habits.length) * 100;
  }

  void _toggleHabit(int index) {
    setState(() {
      _habits[index].isCompleted = !_habits[index].isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now).toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF1E4),
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
                    backgroundColor: const Color(0xFF007BFF),
                    child: const Icon(Icons.calendar_month, color: Colors.white, size: 28),
                  ),
                  Text(
                    'DAILY.IBADAH',
                    style: GoogleFonts.epilogue(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: darkColor,
                      letterSpacing: -1,
                    ),
                  ),
                  _NeuBoxCustom(
                    padding: const EdgeInsets.all(8),
                    backgroundColor: const Color(0xFFFFBA24),
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
                          backgroundColor: const Color(0xFFFF649C),
                          borderWidth: 2,
                          offset: const Offset(3, 3),
                          child: const Icon(Icons.chevron_left, color: darkColor, size: 20),
                        ),
                        Text(
                          monthName,
                          style: GoogleFonts.epilogue(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: darkColor,
                          ),
                        ),
                        _NeuBoxCustom(
                          padding: const EdgeInsets.all(4),
                          backgroundColor: const Color(0xFFFF649C),
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
                      children: List.generate(7, (index) {
                        final date = now.subtract(Duration(days: now.weekday % 7 - index));
                        final isToday = date.day == now.day && date.month == now.month;
                        final isOtherMonth = date.month != now.month;
                        return _buildDateItem(date.day.toString(), isMuted: isOtherMonth, isSelected: isToday);
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // DAILY FOCUS
              Text(
                'IBADAH GOALS',
                style: GoogleFonts.epilogue(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: darkColor,
                ),
              ),
              const SizedBox(height: 12),
              _NeuBoxCustom(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFF86EFAC),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _completionPercentage >= 100 ? 'EXCELLENT!' : 'KEEP IT UP!',
                          style: GoogleFonts.epilogue(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: darkColor,
                          ),
                        ),
                        Text(
                          '${_completionPercentage.toInt()}%',
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
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: _completionPercentage / 100,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF007BFF),
                              ),
                            ),
                          ),
                          Row(
                            children: List.generate(4, (index) => Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(right: BorderSide(color: darkColor.withOpacity(0.5), width: 1.5)),
                                ),
                              ),
                            )),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _completionPercentage >= 100 
                        ? '"MashaAllah, you completed all goals today!"'
                        : '"Every small step brings you closer to Allah."',
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

              // HABIT LIST
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _habits.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final habit = _habits[index];
                  return _HabitItem(
                    title: habit.title,
                    subtitle: habit.subtitle,
                    iconIcon: habit.icon,
                    iconBgColor: habit.color,
                    isChecked: habit.isCompleted,
                    onToggle: () => _toggleHabit(index),
                  );
                },
              ),

              const SizedBox(height: 120),
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
  final bool isChecked;
  final VoidCallback onToggle;

  const _HabitItem({
    required this.title,
    required this.subtitle,
    required this.iconIcon,
    required this.iconBgColor,
    required this.isChecked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    return GestureDetector(
      onTap: onToggle,
      child: _NeuBoxCustom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        borderRadius: 0,
        borderWidth: 3,
        offset: const Offset(4, 4),
        backgroundColor: isChecked ? Colors.white.withOpacity(0.9) : Colors.white,
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
                      color: isChecked ? darkColor.withOpacity(0.5) : darkColor,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
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
            // Checkbox
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFF22C55E) : Colors.white,
                border: Border.all(color: darkColor, width: 2.5),
              ),
              child: isChecked
                  ? const Icon(Icons.check, color: Colors.white, size: 30)
                  : const Icon(Icons.check, color: Color(0xFFD3D8E0), size: 30),
            ),
          ],
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
