import 'package:flutter/material.dart';
import '../models.dart';
import '../repositories/task_repository.dart';
import '../services/notification_service.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository repository;
  final NotificationService notificationService;
  List<TodoTask> _tasks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  TaskCategory? _selectedCategory;

  TaskViewModel({
    required this.repository,
    required this.notificationService,
  });

  List<TodoTask> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  TaskCategory? get selectedCategory => _selectedCategory;

  List<TodoTask> get filteredTasks {
    return _tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || task.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await repository.getTasks();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(TaskCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> addTask(TodoTask task) async {
    _tasks.add(task);
    await repository.saveTasks(_tasks);
    
    if (task.reminderDate != null) {
      await _scheduleTaskReminder(task);
    }
    
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks.removeAt(index);
      await repository.saveTasks(_tasks);
      
      // Cancel reminder
      await notificationService.cancelNotification(id: task.id.hashCode);
      
      notifyListeners();
    }
  }

  Future<void> toggleTaskStatus(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isDone = !_tasks[index].isDone;
      final task = _tasks[index];
      await repository.saveTasks(_tasks);
      
      if (task.isDone) {
        // Cancel reminder if done
        await notificationService.cancelNotification(id: task.id.hashCode);
      } else if (task.reminderDate != null) {
        // Reschedule if un-done
        await _scheduleTaskReminder(task);
      }
      
      notifyListeners();
    }
  }

  Future<void> updateTask(TodoTask task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await repository.saveTasks(_tasks);
      
      // Update reminder
      await notificationService.cancelNotification(id: task.id.hashCode);
      if (task.reminderDate != null && !task.isDone) {
        await _scheduleTaskReminder(task);
      }
      
      notifyListeners();
    }
  }

  Future<void> _scheduleTaskReminder(TodoTask task) async {
    if (task.reminderDate == null) return;
    
    await notificationService.scheduleNotification(
      id: task.id.hashCode,
      title: 'Reminder: ${task.title}',
      body: task.subtitle,
      scheduledDate: task.reminderDate!,
      payload: task.id,
    );
  }
}
