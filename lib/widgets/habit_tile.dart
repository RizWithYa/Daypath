import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets.dart';

class HabitTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconIcon;
  final Color iconBgColor;
  final bool isChecked;
  final VoidCallback onToggle;

  const HabitTile({
    super.key,
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
