import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    
    return Scaffold(
      backgroundColor: const Color(0xFFE5F1FF), // Light blue background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFF007BFF), width: 4)),
                        ),
                        child: Text(
                          'MY TASKS',
                          style: GoogleFonts.epilogue(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: darkColor,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MONDAY, OCT 24, 2023',
                        style: GoogleFonts.epilogue(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                  _NeuBoxCustom(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: const Color(0xFFFFBA24), // Yellow
                    child: const Icon(Icons.calendar_month, color: darkColor, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // TABS
              Row(
                children: [
                  Expanded(
                    child: _TabItem(title: 'ALL (12)', isActive: true, color: const Color(0xFF007BFF)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TabItem(title: 'WORK', isActive: false),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TabItem(title: 'PERSONAL', isActive: false),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // URGENT SECTION
              _CategoryBadge(text: 'URGENT', color: const Color(0xFFFF649C)), // Pink
              const SizedBox(height: 12),
              const _TaskItem(
                title: 'Design Review\nPresentation',
                subtitle: '9:00 AM - 10:30 AM',
                iconBgColor: Color(0xFFFFBA24), // Yellow
                iconIcon: Icons.priority_high,
              ),
              const SizedBox(height: 12),
              const _TaskItem(
                title: 'Submit Q3 Reports',
                subtitle: 'DUE TODAY',
                iconBgColor: Color(0xFFFFBA24),
                iconIcon: Icons.priority_high,
              ),

              const SizedBox(height: 32),

              // PENDING SECTION
              _CategoryBadge(text: 'PENDING', color: const Color(0xFF00FF7F)), // Green
              const SizedBox(height: 12),
              const _TaskItem(
                title: 'Pick up groceries',
                subtitle: 'PERSONAL',
                iconBgColor: Colors.white,
                isCheckbox: true,
                leftDeco: Color(0xFF007BFF), // Blue border left
              ),
              const SizedBox(height: 12),
              const _TaskItem(
                title: 'Call the plumber',
                subtitle: 'HOME MAINTENANCE',
                iconBgColor: Colors.white,
                isCheckbox: true,
              ),

              const SizedBox(height: 32),

              // DONE SECTION
              _CategoryBadge(text: 'DONE', color: const Color(0xFFD3D8E0)), // Greyish
              const SizedBox(height: 12),
              const _TaskItem(
                title: 'Morning Workout',
                subtitle: 'HEALTH',
                iconBgColor: Color(0xFF69B4FF),
                iconIcon: Icons.check,
                isDone: true,
                isCheckbox: true,
                checked: true,
              ),
              
              const SizedBox(height: 120), // Padding for nav bar
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _CategoryBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: darkColor, width: 2.5),
      ),
      child: Text(
        text,
        style: GoogleFonts.epilogue(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: darkColor,
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final Color? color;

  const _TabItem({required this.title, required this.isActive, this.color});

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    return _NeuBoxCustom(
      padding: const EdgeInsets.symmetric(vertical: 12),
      backgroundColor: isActive ? (color ?? Colors.white) : Colors.white,
      borderRadius: 0,
      borderWidth: 3,
      offset: const Offset(4, 4),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.epilogue(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: isActive && color != null ? Colors.white : darkColor,
          ),
        ),
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color iconBgColor;
  final IconData? iconIcon;
  final bool isCheckbox;
  final bool checked;
  final bool isDone;
  final Color? leftDeco;

  const _TaskItem({
    required this.title,
    required this.subtitle,
    required this.iconBgColor,
    this.iconIcon,
    this.isCheckbox = false,
    this.checked = false,
    this.isDone = false,
    this.leftDeco,
  });

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    return Stack(
      children: [
        _NeuBoxCustom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          borderRadius: 0,
          borderWidth: 3,
          offset: const Offset(5, 5),
          backgroundColor: isDone ? const Color(0xFFF3F4F6) : Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon or Checkbox
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCheckbox ? (checked ? const Color(0xFF69B4FF) : Colors.white) : iconBgColor,
                  border: Border.all(color: darkColor, width: 2),
                ),
                child: isCheckbox
                    ? (checked ? const Icon(Icons.check, size: 16, color: Colors.white) : null)
                    : Icon(iconIcon, size: 16, color: darkColor),
              ),
              const SizedBox(width: 16),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.epilogue(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDone ? const Color(0xFF9CA3AF) : darkColor,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.epilogue(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6C757D),
                      ),
                    ),
                  ],
                ),
              ),
              // Drag indicator
              const Icon(Icons.drag_indicator, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
        if (leftDeco != null)
          Positioned(
            left: 0,
            top: 0,
            bottom: 5, // Account for shadow
            width: 8,
            child: Container(
              decoration: BoxDecoration(
                color: leftDeco,
                border: const Border(
                  top: BorderSide(color: darkColor, width: 3),
                  bottom: BorderSide(color: darkColor, width: 3),
                  left: BorderSide(color: darkColor, width: 3),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Internal reusable neu box component for this page
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
    this.borderRadius = 8.0,
    this.borderWidth = 3.5,
    this.offset = const Offset(4, 4),
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
