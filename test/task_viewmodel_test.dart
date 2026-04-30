import 'package:flutter_test/flutter_test.dart';
import 'package:todo_application_v1/models.dart';
import 'package:todo_application_v1/repositories/task_repository.dart';
import 'package:todo_application_v1/viewmodels/task_viewmodel.dart';
import 'package:todo_application_v1/services/notification_service.dart';

class FakeTaskRepository extends TaskRepository {
  List<TodoTask> tasks = [];
  int saveCount = 0;
  int getCount = 0;

  @override
  Future<List<TodoTask>> getTasks() async {
    getCount++;
    return tasks;
  }

  @override
  Future<void> saveTasks(List<TodoTask> newTasks) async {
    tasks = List.from(newTasks);
    saveCount++;
  }
}

class FakeNotificationService extends NotificationService {
  int scheduleCount = 0;
  int cancelCount = 0;

  FakeNotificationService() : super();

  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    scheduleCount++;
  }

  @override
  Future<void> cancelNotification({required int id}) async {
    cancelCount++;
  }
}

void main() {
  late TaskViewModel viewModel;
  late FakeTaskRepository fakeRepository;
  late FakeNotificationService fakeNotificationService;

  setUp(() {
    fakeRepository = FakeTaskRepository();
    fakeNotificationService = FakeNotificationService();
    viewModel = TaskViewModel(
      repository: fakeRepository,
      notificationService: fakeNotificationService,
    );
  });

  test('initial tasks should be empty', () {
    expect(viewModel.tasks, isEmpty);
  });

  test('loadTasks should fetch tasks from repository', () async {
    final tasks = [TodoTask(id: '1', title: 'Test Task', subtitle: 'Subtitle')];
    fakeRepository.tasks = tasks;

    await viewModel.loadTasks();

    expect(viewModel.tasks, tasks);
    expect(fakeRepository.getCount, 1);
  });

  test('addTask should add a task and save to repository', () async {
    final task = TodoTask(id: '1', title: 'New Task', subtitle: 'Subtitle');

    await viewModel.addTask(task);

    expect(viewModel.tasks.length, 1);
    expect(viewModel.tasks.first.title, 'New Task');
    expect(fakeRepository.saveCount, 1);
    expect(fakeRepository.tasks.contains(task), true);
  });

  test('deleteTask should remove a task and save to repository', () async {
    final task = TodoTask(id: '1', title: 'Task to Delete', subtitle: 'Subtitle');
    fakeRepository.tasks = [task];
    await viewModel.loadTasks();

    await viewModel.deleteTask(task.id);

    expect(viewModel.tasks, isEmpty);
    expect(fakeRepository.saveCount, 1);
    expect(fakeRepository.tasks, isEmpty);
    expect(fakeNotificationService.cancelCount, 1);
  });

  test('toggleTaskStatus should flip isDone and save', () async {
    final task = TodoTask(id: '1', title: 'Task', subtitle: 'Sub', isDone: false);
    fakeRepository.tasks = [task];
    await viewModel.loadTasks();

    await viewModel.toggleTaskStatus(task.id);

    expect(viewModel.tasks.first.isDone, true);
    expect(fakeRepository.saveCount, 1);
    expect(fakeRepository.tasks.first.isDone, true);
  });

  test('updateTask should update task and save', () async {
    final task = TodoTask(id: '1', title: 'Old Title', subtitle: 'Sub');
    fakeRepository.tasks = [task];
    await viewModel.loadTasks();

    final updatedTask = task.copyWith(title: 'New Title');
    await viewModel.updateTask(updatedTask);

    expect(viewModel.tasks.first.title, 'New Title');
    expect(fakeRepository.saveCount, 1);
    expect(fakeRepository.tasks.first.title, 'New Title');
  });

  test('search should filter tasks by title', () async {
    final task1 = TodoTask(id: '1', title: 'Buy milk', subtitle: 'Sub');
    final task2 = TodoTask(id: '2', title: 'Wash car', subtitle: 'Sub');
    fakeRepository.tasks = [task1, task2];
    await viewModel.loadTasks();

    viewModel.setSearchQuery('milk');
    expect(viewModel.filteredTasks.length, 1);
    expect(viewModel.filteredTasks.first.title, 'Buy milk');
  });

  test('filter should filter tasks by category', () async {
    final task1 = TodoTask(id: '1', title: 'Work task', category: TaskCategory.work, subtitle: 'Sub');
    final task2 = TodoTask(id: '2', title: 'Personal task', category: TaskCategory.personal, subtitle: 'Sub');
    fakeRepository.tasks = [task1, task2];
    await viewModel.loadTasks();

    viewModel.setSelectedCategory(TaskCategory.work);
    expect(viewModel.filteredTasks.length, 1);
    expect(viewModel.filteredTasks.first.title, 'Work task');
  });
}
