import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeuBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final double borderRadius;
  final double borderWidth;
  final Offset offset;

  const NeuBox({
    super.key,
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

class CategoryBadge extends StatelessWidget {
  final String text;
  final Color color;

  const CategoryBadge({super.key, required this.text, required this.color});

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
