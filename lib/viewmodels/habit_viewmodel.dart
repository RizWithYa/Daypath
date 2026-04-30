import 'package:flutter/material.dart';
import '../models.dart';
import '../repositories/habit_repository.dart';

class HabitViewModel extends ChangeNotifier {
  final HabitRepository repository;
  List<Habit> _habits = [];
  bool _isLoading = false;

  HabitViewModel({required this.repository});

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;

  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();
    try {
      _habits = await repository.getHabits();
    } catch (e) {
      debugPrint('Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await repository.saveHabits(_habits);
    notifyListeners();
  }

  Future<void> toggleHabitCompletion(String id, DateTime date) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index].toggleCompletionOn(date);
      await repository.saveHabits(_habits);
      notifyListeners();
    }
  }
}
