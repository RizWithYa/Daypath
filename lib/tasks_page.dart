import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'widgets.dart';

class TasksPage extends StatefulWidget {
  final void Function(int)? onNavigateToTab;
  const TasksPage({super.key, this.onNavigateToTab});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  int _selectedTab = 0; // 0=ALL, 1=WORK, 2=PERSONAL
  DateTime _selectedDate = DateTime.now();
  List<TodoTask> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tasksJson = prefs.getString('tasks_list');
      if (tasksJson != null) {
        final List<dynamic> decoded = jsonDecode(tasksJson);
        setState(() {
          _tasks = decoded.map((item) => TodoTask.fromJson(item)).toList();
        });
      } else {
        _tasks = [
          TodoTask(
            id: '1',
            title: 'Design Review\\nPresentation',
            subtitle: '9:00 AM - 10:30 AM',
            isUrgent: true,
            category: TaskCategory.work,
          ),
          TodoTask(
            id: '2',
            title: 'Submit Q3 Reports',
            subtitle: 'DUE TODAY',
            isUrgent: true,
            category: TaskCategory.work,
          ),
          TodoTask(
            id: '3',
            title: 'Pick up groceries',
            subtitle: 'PERSONAL',
            leftDeco: const Color(0xFF007BFF),
            category: TaskCategory.personal,
          ),
          TodoTask(
            id: '4',
            title: 'Call the plumber',
            subtitle: 'HOME MAINTENANCE',
            category: TaskCategory.personal,
          ),
          TodoTask(
            id: '5',
            title: 'Morning Workout',
            subtitle: 'HEALTH',
            isDone: true,
            category: TaskCategory.personal,
          ),
        ];
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString('tasks_list', tasksJson);
  }

  void _toggleTaskStatus(String id) {
    TodoTask? taskToCheck;
    setState(() {
      final taskIndex = _tasks.indexWhere((t) => t.id == id);
      if (taskIndex != -1) {
        _tasks[taskIndex].isDone = !_tasks[taskIndex].isDone;
        if (_tasks[taskIndex].isDone) {
          taskToCheck = _tasks[taskIndex];
        }
      }
    });
    _saveTasks();

    if (taskToCheck != null) {
      AchievementManager.checkAndUnlock(taskToCheck!, onAchievementUnlocked: (achievementId) {
        if (!mounted) return;
        final achievement = Achievement.defaultAchievements.firstWhere((a) => a.id == achievementId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF00FF7F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              side: const BorderSide(color: Color(0xFF1A1F2B), width: 2),
            ),
            content: Row(
              children: [
                Icon(achievement.icon, color: const Color(0xFF1A1F2B)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ACHIEVEMENT UNLOCKED!', style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, color: const Color(0xFF1A1F2B), fontSize: 10)),
                      Text(achievement.title, style: GoogleFonts.epilogue(fontWeight: FontWeight.w700, color: const Color(0xFF1A1F2B))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A1F2B),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A1F2B),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1A1F2B),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addNewTask() {
    String title = '';
    String subtitle = '';
    String description = '';
    DateTime? dueDate;
    TaskCategory category = TaskCategory.personal;
    bool isUrgent = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            const darkColor = Color(0xFF1A1F2B);
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
                side: const BorderSide(color: darkColor, width: 3.5),
              ),
              title: Text(
                'ADD NEW TASK',
                style: GoogleFonts.epilogue(
                  fontWeight: FontWeight.w900,
                  color: darkColor,
                  letterSpacing: -0.5,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TITLE', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (value) => title = value,
                      style: GoogleFonts.epilogue(fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF3F4F6),
                        border: OutlineInputBorder(borderSide: BorderSide(color: darkColor, width: 2.5)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: darkColor, width: 2.5)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: darkColor, width: 3)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('SUBTITLE', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (value) => subtitle = value,
                      style: GoogleFonts.epilogue(fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF3F4F6),
                        border: OutlineInputBorder(borderSide: BorderSide(color: darkColor, width: 2.5)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: darkColor, width: 2.5)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: darkColor, width: 3)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('DESCRIPTION', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (value) => description = value,
                      maxLines: 3,
                      style: GoogleFonts.epilogue(fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF3F4F6),
                        border: OutlineInputBorder(borderSide: BorderSide(color: darkColor, width: 2.5)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: darkColor, width: 2.5)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: darkColor, width: 3)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('DUE DATE', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, fontSize: 12)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: darkColor,
                                  onPrimary: Colors.white,
                                  onSurface: darkColor,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() => dueDate = picked);
                        }
                      },
                      child: NeuBox(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        backgroundColor: const Color(0xFFF3F4F6),
                        borderRadius: 0,
                        borderWidth: 2.5,
                        offset: const Offset(3, 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dueDate == null ? 'SELECT DATE' : DateFormat('MMM dd, yyyy').format(dueDate!),
                              style: GoogleFonts.epilogue(fontWeight: FontWeight.w700, color: darkColor),
                            ),
                            const Icon(Icons.calendar_today, size: 18, color: darkColor),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('CATEGORY', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('WORK'),
                          selected: category == TaskCategory.work,
                          onSelected: (selected) {
                            if (selected) setDialogState(() => category = TaskCategory.work);
                          },
                          selectedColor: const Color(0xFF007BFF),
                          labelStyle: GoogleFonts.epilogue(
                            fontWeight: FontWeight.bold,
                            color: category == TaskCategory.work ? Colors.white : darkColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                            side: const BorderSide(color: darkColor, width: 2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('PERSONAL'),
                          selected: category == TaskCategory.personal,
                          onSelected: (selected) {
                            if (selected) setDialogState(() => category = TaskCategory.personal);
                          },
                          selectedColor: const Color(0xFF007BFF),
                          labelStyle: GoogleFonts.epilogue(
                            fontWeight: FontWeight.bold,
                            color: category == TaskCategory.personal ? Colors.white : darkColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                            side: const BorderSide(color: darkColor, width: 2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: isUrgent,
                            onChanged: (value) => setDialogState(() => isUrgent = value ?? false),
                            activeColor: const Color(0xFFFF649C),
                            side: const BorderSide(color: darkColor, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('MARK AS URGENT', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('CANCEL', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, color: darkColor)),
                ),
                NeuBox(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: const Color(0xFF00FF7F),
                  borderRadius: 0,
                  borderWidth: 3,
                  offset: const Offset(4, 4),
                  child: InkWell(
                    onTap: () {
                      if (title.isNotEmpty) {
                        setState(() {
                          _tasks.add(TodoTask(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: title,
                            subtitle: subtitle.isNotEmpty 
                                ? subtitle 
                                : (dueDate != null ? DateFormat('MMM dd, yyyy').format(dueDate!) : 'NO DUE DATE'),
                            description: description,
                            dueDate: dueDate,
                            isUrgent: isUrgent,
                            category: category,
                          ));
                        });
                        _saveTasks();
                        Navigator.pop(context);
                      }
                    },
                    child: Text('CONFIRM', style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, color: darkColor)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTaskDetails(TodoTask task) {
    const darkColor = Color(0xFF1A1F2B);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border(
              top: BorderSide(color: darkColor, width: 4),
              left: BorderSide(color: darkColor, width: 4),
              right: BorderSide(color: darkColor, width: 4),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CategoryBadge(
                      text: task.category.name.toUpperCase(),
                      color: task.category == TaskCategory.work ? const Color(0xFF00FF7F) : const Color(0xFFFF649C),
                    ),
                    const SizedBox(width: 8),
                    if (task.isUrgent)
                      const CategoryBadge(text: 'URGENT', color: Color(0xFFFFBA24)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: darkColor, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  task.title.replaceAll('\\n', '\n'),
                  style: GoogleFonts.epilogue(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: darkColor,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  task.subtitle,
                  style: GoogleFonts.epilogue(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6C757D),
                  ),
                ),
                const SizedBox(height: 24),
                if (task.dueDate != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: darkColor),
                      const SizedBox(width: 8),
                      Text(
                        'DUE: ${DateFormat('EEEE, MMM dd, yyyy').format(task.dueDate!)}',
                        style: GoogleFonts.epilogue(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: darkColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'DESCRIPTION',
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: darkColor,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    border: Border.all(color: darkColor, width: 2),
                  ),
                  child: Text(
                    task.description.isEmpty ? 'No description provided.' : task.description,
                    style: GoogleFonts.epilogue(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: darkColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: NeuBox(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: task.isDone ? const Color(0xFFD1D5DB) : const Color(0xFF007BFF),
                    borderRadius: 0,
                    borderWidth: 3,
                    offset: const Offset(4, 4),
                    child: InkWell(
                      onTap: () {
                        _toggleTaskStatus(task.id);
                        Navigator.pop(context);
                      },
                      child: Center(
                        child: Text(
                          task.isDone ? 'MARK AS PENDING' : 'MARK AS COMPLETE',
                          style: GoogleFonts.epilogue(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    
    List<TodoTask> filteredByTab = _tasks;
    if (_selectedTab == 1) {
      filteredByTab = _tasks.where((t) => t.category == TaskCategory.work).toList();
    } else if (_selectedTab == 2) {
      filteredByTab = _tasks.where((t) => t.category == TaskCategory.personal).toList();
    }

    final urgentTasks = filteredByTab.where((t) => t.isUrgent && !t.isDone).toList();
    final pendingTasks = filteredByTab.where((t) => !t.isUrgent && !t.isDone).toList();
    final doneTasks = filteredByTab.where((t) => t.isDone).toList();

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFE5F1FF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    int workCount = _tasks.where((t) => t.category == TaskCategory.work).length;
    int personalCount = _tasks.where((t) => t.category == TaskCategory.personal).length;

    return Scaffold(
      backgroundColor: const Color(0xFFE5F1FF), // Light blue background
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        backgroundColor: const Color(0xFFFFBA24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: const BorderSide(color: darkColor, width: 3),
        ),
        child: const Icon(Icons.add, color: darkColor, size: 32),
      ),
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
                        DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate).toUpperCase(),
                        style: GoogleFonts.epilogue(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _selectDate,
                    child: NeuBox(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: const Color(0xFFFFBA24), // Yellow
                      child: const Icon(Icons.calendar_month, color: darkColor, size: 28),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // TABS
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: _TabItem(
                        title: 'ALL (${_tasks.length})',
                        isActive: _selectedTab == 0,
                        color: const Color(0xFF007BFF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: _TabItem(
                        title: 'WORK ($workCount)',
                        isActive: _selectedTab == 1,
                        color: const Color(0xFF00FF7F),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 2),
                      child: _TabItem(
                        title: 'PERSONAL ($personalCount)',
                        isActive: _selectedTab == 2,
                        color: const Color(0xFFFF649C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // URGENT SECTION
              _buildTaskSection('URGENT', urgentTasks, const Color(0xFFFF649C)),
              const SizedBox(height: 20),

              // PENDING SECTION
              _buildTaskSection('PENDING', pendingTasks, const Color(0xFF00FF7F)),
              const SizedBox(height: 32),

              // DONE SECTION
              _buildTaskSection('DONE', doneTasks, const Color(0xFFD3D8E0), isDoneSection: true),
              
              const SizedBox(height: 120), // Padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskSection(String title, List<TodoTask> tasks, Color badgeColor, {bool isDoneSection = false}) {
    return DragTarget<TodoTask>(
      onAccept: (task) {
        setState(() {
          final index = _tasks.indexWhere((t) => t.id == task.id);
          if (index != -1) {
            if (isDoneSection) {
              _tasks[index] = _tasks[index].copyWith(isDone: true);
            } else if (title == 'URGENT') {
              _tasks[index] = _tasks[index].copyWith(isUrgent: true, isDone: false);
            } else {
              _tasks[index] = _tasks[index].copyWith(isUrgent: false, isDone: false);
            }
          }
        });
        _saveTasks();
      },
      builder: (context, candidateData, rejectedData) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryBadge(text: title, color: badgeColor),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 100),
                alignment: Alignment.centerLeft,
                child: Text(
                  'No tasks here',
                  style: GoogleFonts.epilogue(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              )
            else
              ...tasks.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LongPressDraggable<TodoTask>(
                  data: task,
                  feedback: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: _TaskItem(
                        title: task.title,
                        subtitle: task.subtitle,
                        iconBgColor: task.isUrgent ? const Color(0xFFFFBA24) : Colors.white,
                        onToggle: () {},
                        onTap: () {},
                        isCheckbox: true,
                        checked: task.isDone,
                        isDone: task.isDone,
                        leftDeco: task.leftDeco,
                        iconIcon: task.isUrgent ? Icons.priority_high : null,
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: _TaskItem(
                      title: task.title,
                      subtitle: task.subtitle,
                      iconBgColor: task.isUrgent ? const Color(0xFFFFBA24) : Colors.white,
                      onToggle: () {},
                      onTap: () {},
                      isCheckbox: true,
                      checked: task.isDone,
                      isDone: task.isDone,
                      leftDeco: task.leftDeco,
                      iconIcon: task.isUrgent ? Icons.priority_high : null,
                    ),
                  ),
                  child: DragTarget<TodoTask>(
                    onAccept: (droppedTask) {
                      if (droppedTask.id != task.id) {
                        setState(() {
                          final oldIndex = _tasks.indexWhere((t) => t.id == droppedTask.id);
                          
                          TodoTask updatedTask = droppedTask;
                          if (isDoneSection) {
                            updatedTask = updatedTask.copyWith(isDone: true);
                          } else if (title == 'URGENT') {
                            updatedTask = updatedTask.copyWith(isUrgent: true, isDone: false);
                          } else {
                            updatedTask = updatedTask.copyWith(isUrgent: false, isDone: false);
                          }
                          
                          _tasks.removeAt(oldIndex);
                          // Re-calculate new index after removal
                          final adjustedNewIndex = _tasks.indexWhere((t) => t.id == task.id);
                          _tasks.insert(adjustedNewIndex, updatedTask);
                        });
                        _saveTasks();
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return _TaskItem(
                        title: task.title,
                        subtitle: task.subtitle,
                        iconBgColor: task.isUrgent ? const Color(0xFFFFBA24) : (isDoneSection ? const Color(0xFF69B4FF) : Colors.white),
                        onToggle: () => _toggleTaskStatus(task.id),
                        onTap: () => _showTaskDetails(task),
                        isCheckbox: true,
                        checked: task.isDone,
                        isDone: task.isDone,
                        leftDeco: task.leftDeco,
                        iconIcon: task.isUrgent ? Icons.priority_high : (isDoneSection ? Icons.check : null),
                      );
                    },
                  ),
                ),
              )),
          ],
        );
      },
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
    return NeuBox(
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
            fontSize: 11, // Slightly smaller to fit counts
            color: isActive ? (color == const Color(0xFF00FF7F) ? darkColor : Colors.white) : darkColor,
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
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _TaskItem({
    required this.title,
    required this.subtitle,
    required this.iconBgColor,
    required this.onToggle,
    required this.onTap,
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
                            title.replaceAll('\\n', '\n'),
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
                  ),
                ),
                // Drag indicator
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.drag_indicator, color: Color(0xFF9CA3AF)),
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
