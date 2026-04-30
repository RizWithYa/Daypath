import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_application_v1/models.dart';

void main() {
  group('Achievement Model', () {
    test('should initialize with howToAchieve field', () {
      final achievement = Achievement(
        id: 'test_id',
        title: 'Test Title',
        description: 'Test Description',
        howToAchieve: 'Complete a specific test task',
        icon: Icons.star,
      );

      expect(achievement.id, 'test_id');
      expect(achievement.title, 'Test Title');
      expect(achievement.description, 'Test Description');
      expect(achievement.howToAchieve, 'Complete a specific test task');
      expect(achievement.icon, Icons.star);
      expect(achievement.isUnlocked, false);
    });

    test('default achievements should have howToAchieve property populated', () {
      final defaults = Achievement.defaultAchievements;
      
      expect(defaults, isNotEmpty);
      for (var achievement in defaults) {
        expect(achievement.howToAchieve, isNotEmpty);
      }
    });
  });
}
