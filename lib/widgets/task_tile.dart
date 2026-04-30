import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets.dart';

class TaskTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime? dueDate;
  final Color iconBgColor;
  final IconData? iconIcon;
  final bool isCheckbox;
  final bool checked;
  final bool isDone;
  final Color? leftDeco;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.dueDate,
    required this.iconBgColor,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
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
        NeuBox(
          padding: EdgeInsets.zero,
          borderRadius: 0,
          borderWidth: 3,
          offset: const Offset(5, 5),
          backgroundColor: isDone ? const Color(0xFFF3F4F6) : Colors.white,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon or Checkbox Area
                GestureDetector(
                  onTap: onToggle,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    child: Container(
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
                  ),
                ),
                // Text Content Area
                Expanded(
                  child: GestureDetector(
                    onTap: onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.replaceAll('\n', '\n'),
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
                          if (dueDate != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Deadline: ${DateFormat('MMM dd, yyyy').format(dueDate!)}',
                              style: GoogleFonts.epilogue(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDone ? const Color(0xFF9CA3AF) : const Color(0xFFFF649C),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // Delete Button
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: darkColor, size: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  constraints: const BoxConstraints(),
                ),
                // Drag indicator
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.drag_indicator, color: Color(0xFF9CA3AF), size: 18),
                ),
              ],
            ),
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
