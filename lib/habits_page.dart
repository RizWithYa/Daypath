import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'widgets.dart';

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
  final void Function(int)? onNavigateToTab;
  const HabitsPage({super.key, this.onNavigateToTab});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDate = DateTime.now();

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
  void _showAddHabitDialog() {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    IconData selectedIcon = Icons.star;
    Color selectedColor = const Color(0xFFE4C1F9);

    final List<IconData> presetIcons = [
      Icons.menu_book,
      Icons.wb_sunny_outlined,
      Icons.mosque_outlined,
      Icons.favorite_border,
      Icons.water_drop_outlined,
      Icons.self_improvement,
      Icons.fitness_center,
      Icons.edit_note,
    ];

    final List<Color> presetColors = [
      const Color(0xFFE4C1F9),
      const Color(0xFFFFD19A),
      const Color(0xFFB5D8FF),
      const Color(0xFFFFB5D8),
      const Color(0xFF86EFAC),
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFFFF1E4),
          insetPadding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + 24,
          ),
          shape: const RoundedRectangleBorder(side: BorderSide(color: Color(0xFF1A1F2B), width: 3)),
          title: Text(
            'ADD NEW HABIT',
            style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, color: const Color(0xFF1A1F2B)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('TITLE', titleController),
                const SizedBox(height: 16),
                _buildTextField('SUBTITLE', subtitleController),
                const SizedBox(height: 16),
                Text('SELECT ICON', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: presetIcons.map((icon) => GestureDetector(
                      onTap: () => setDialogState(() => selectedIcon = icon),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedIcon == icon ? const Color(0xFF007BFF) : Colors.white,
                          border: Border.all(color: const Color(0xFF1A1F2B), width: 2),
                        ),
                        child: Icon(icon, color: selectedIcon == icon ? Colors.white : const Color(0xFF1A1F2B)),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Text('SELECT COLOR', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: presetColors.map((color) => GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = color),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1A1F2B),
                          width: selectedColor == color ? 3 : 1.5,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, color: Colors.grey)),
            ),
            GestureDetector(
              onTap: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _habits.add(Habit(
                      title: titleController.text.toUpperCase(),
                      subtitle: subtitleController.text,
                      icon: selectedIcon,
                      color: selectedColor,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: NeuBox(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: const Color(0xFF86EFAC),
                borderWidth: 2,
                offset: const Offset(3, 3),
                child: Text('ADD', style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, color: const Color(0xFF1A1F2B))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: GoogleFonts.epilogue(fontWeight: FontWeight.w600),
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF1A1F2B), width: 2), borderRadius: BorderRadius.zero),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF007BFF), width: 2), borderRadius: BorderRadius.zero),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    final monthName = DateFormat('MMMM yyyy').format(_selectedMonth).toUpperCase();

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
                  GestureDetector(
                    onTap: () => widget.onNavigateToTab?.call(1),
                    child: NeuBox(
                      padding: const EdgeInsets.all(8),
                      backgroundColor: const Color(0xFF007BFF),
                      child: const Icon(Icons.calendar_month, color: Colors.white, size: 28),
                    ),
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
                  GestureDetector(
                    onTap: () => widget.onNavigateToTab?.call(3),
                    child: NeuBox(
                      padding: const EdgeInsets.all(8),
                      backgroundColor: const Color(0xFFFFBA24),
                      child: const Icon(Icons.person_outline, color: darkColor, size: 28),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // CALENDAR
              NeuBox(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                            });
                          },
                          child: NeuBox(
                            padding: const EdgeInsets.all(4),
                            backgroundColor: const Color(0xFFFF649C),
                            borderWidth: 2,
                            offset: const Offset(3, 3),
                            child: const Icon(Icons.chevron_left, color: darkColor, size: 20),
                          ),
                        ),
                        Text(
                          monthName,
                          style: GoogleFonts.epilogue(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: darkColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                            });
                          },
                          child: NeuBox(
                            padding: const EdgeInsets.all(4),
                            backgroundColor: const Color(0xFFFF649C),
                            borderWidth: 2,
                            offset: const Offset(3, 3),
                            child: const Icon(Icons.chevron_right, color: darkColor, size: 20),
                          ),
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
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: 42,
                      itemBuilder: (context, index) {
                        final daysInMonth = _getDaysInMonth(_selectedMonth);
                        final date = daysInMonth[index];
                        final isToday = date.day == DateTime.now().day && 
                                          date.month == DateTime.now().month && 
                                          date.year == DateTime.now().year;
                        final isSelected = _selectedDate != null && 
                                             date.day == _selectedDate!.day && 
                                             date.month == _selectedDate!.month && 
                                             date.year == _selectedDate!.year;
                        final isOtherMonth = date.month != _selectedMonth.month;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                          child: _buildDateItem(
                            date.day.toString(),
                            isMuted: isOtherMonth,
                            isSelected: isSelected,
                            isToday: isToday,
                          ),
                        );
                      },
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
              NeuBox(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFF86EFAC),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TODAY\'S PROGRESS',
                              style: GoogleFonts.epilogue(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: darkColor.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              _completionPercentage >= 100 ? 'EXCELLENT!' : 'KEEP IT UP!',
                              style: GoogleFonts.epilogue(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: darkColor,
                              ),
                            ),
                          ],
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: Color(0xFF1A1F2B)),
                        const SizedBox(width: 4),
                        Text(
                          'Habits reset daily at midnight',
                          style: GoogleFonts.epilogue(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: darkColor.withOpacity(0.6),
                          ),
                        ),
                      ],
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
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _showAddHabitDialog,
                child: NeuBox(
                  backgroundColor: const Color(0xFFB5D8FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle_outline, color: darkColor),
                      const SizedBox(width: 8),
                      Text(
                        'ADD NEW HABIT',
                        style: GoogleFonts.epilogue(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: darkColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstDayOfCalendar = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));
    return List.generate(42, (index) => firstDayOfCalendar.add(Duration(days: index)));
  }

  Widget _buildDayHeader(String text) {
    return SizedBox(
      width: 36, // Keep consistent with date item size if needed, but GridView handles it now
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

  Widget _buildDateItem(String day, {bool isMuted = false, bool isSelected = false, bool isToday = false}) {
    const darkColor = Color(0xFF1A1F2B);
    if (isMuted) {
      return Center(
        child: Text(
          day,
          style: GoogleFonts.epilogue(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF007BFF) : (isToday ? const Color(0xFF86EFAC).withOpacity(0.3) : Colors.white),
        border: Border.all(color: isSelected ? darkColor : (isToday ? const Color(0xFF16A34A) : darkColor), width: 2),
      ),
      child: Center(
        child: Text(
          day,
          style: GoogleFonts.epilogue(
            fontSize: 14,
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
      child: NeuBox(
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

