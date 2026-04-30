import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';

class HabitRepository {
  static const String _habitsKey = 'habits_list';

  Future<List<Habit>> getHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsJson = prefs.getString(_habitsKey);
    if (habitsJson == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(habitsJson);
      return decoded.map((item) => Habit.fromJson(item)).toList();
    } catch (e) {
      print('Error decoding habits: $e');
      return [];
    }
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final String habitsJson = jsonEncode(habits.map((h) => h.toJson()).toList());
    await prefs.setString(_habitsKey, habitsJson);
  }
}
