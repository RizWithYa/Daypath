import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _colorKey = 'accent_color';
  Color _accentColor = const Color(0xFF007BFF);
  ThemeProvider() {
    _loadColor();
  }

  Color get accentColor => _accentColor;

  Future<void> _loadColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorValue = prefs.getInt(_colorKey);
      if (colorValue != null) {
        _accentColor = Color(colorValue);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load theme color: $e');
    }
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_colorKey, color.value);
    } catch (e) {
      debugPrint('Failed to save theme color: $e');
    }
  }
}
