import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';

class TaskRepository {
  static const String _tasksKey = 'tasks_list';

  Future<List<TodoTask>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString(_tasksKey);
    if (tasksJson == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      return decoded.map((item) => TodoTask.fromJson(item)).toList();
    } catch (e) {
      print('Error decoding tasks: $e');
      return [];
    }
  }

  Future<void> saveTasks(List<TodoTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, tasksJson);
  }
}
