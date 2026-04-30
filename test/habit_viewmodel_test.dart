import 'package:flutter_test/flutter_test.dart';
import 'package:todo_application_v1/models.dart';
import 'package:todo_application_v1/repositories/habit_repository.dart';
import 'package:todo_application_v1/viewmodels/habit_viewmodel.dart';
import 'package:flutter/material.dart';

class FakeHabitRepository extends HabitRepository {
  List<Habit> habits = [];
  int saveCount = 0;
  int getCount = 0;

  @override
  Future<List<Habit>> getHabits() async {
    getCount++;
    return habits;
  }

  @override
  Future<void> saveHabits(List<Habit> newHabits) async {
    habits = List.from(newHabits);
    saveCount++;
  }
}

void main() {
  late HabitViewModel viewModel;
  late FakeHabitRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeHabitRepository();
    viewModel = HabitViewModel(repository: fakeRepository);
  });

  test('initial habits should be empty', () {
    expect(viewModel.habits, isEmpty);
  });

  test('loadHabits should fetch habits from repository', () async {
    final habits = [Habit(id: '1', title: 'Test Habit', subtitle: 'Sub', icon: Icons.star, color: Colors.blue)];
    fakeRepository.habits = habits;

    await viewModel.loadHabits();

    expect(viewModel.habits, habits);
    expect(fakeRepository.getCount, 1);
  });

  test('addHabit should add a habit and save to repository', () async {
    final habit = Habit(id: '1', title: 'New Habit', subtitle: 'Sub', icon: Icons.star, color: Colors.blue);

    await viewModel.addHabit(habit);

    expect(viewModel.habits.length, 1);
    expect(viewModel.habits.first.title, 'New Habit');
    expect(fakeRepository.saveCount, 1);
  });

  test('toggleHabitCompletion should toggle and save', () async {
    final date = DateTime.now();
    final habit = Habit(id: '1', title: 'Habit', subtitle: 'Sub', icon: Icons.star, color: Colors.blue);
    fakeRepository.habits = [habit];
    await viewModel.loadHabits();

    await viewModel.toggleHabitCompletion(habit.id, date);

    expect(viewModel.habits.first.isCompletedOn(date), true);
    expect(fakeRepository.saveCount, 1);
    
    await viewModel.toggleHabitCompletion(habit.id, date);
    expect(viewModel.habits.first.isCompletedOn(date), false);
  });
}
