import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_application_v1/services/backup_service.dart';

void main() {
  group('BackupService Export/Import', () {
    test('exportData should serialize all SharedPreferences keys', () async {
      SharedPreferences.setMockInitialValues({
        'user_name': 'Test User',
        'tasks_done': 15,
        'streak_days': 5,
        'is_dark_mode': true,
        'unlocked_achievement_ids': ['first_task', 'early_bird'],
      });

      final backupService = BackupService();
      final exportedJson = await backupService.exportData();
      final decoded = jsonDecode(exportedJson) as Map<String, dynamic>;

      expect(decoded['version'], '1.1.0');
      expect(decoded['data']['user_name'], 'Test User');
      expect(decoded['data']['tasks_done'], 15);
      expect(decoded['data']['streak_days'], 5);
      expect(decoded['data']['is_dark_mode'], true);
      expect(decoded['data']['unlocked_achievement_ids'], ['first_task', 'early_bird']);
    });

    test('importData should restore SharedPreferences from JSON', () async {
      SharedPreferences.setMockInitialValues({
        'user_name': 'Old User', // Should be overwritten
      });

      final backupService = BackupService();
      
      final importJson = jsonEncode({
        'version': '1.1.0',
        'data': {
          'user_name': 'New User',
          'tasks_done': 42,
          'unlocked_achievement_ids': ['productivity_master'],
        }
      });

      final success = await backupService.importData(importJson);
      expect(success, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_name'), 'New User');
      expect(prefs.getInt('tasks_done'), 42);
      expect(prefs.getStringList('unlocked_achievement_ids'), ['productivity_master']);
    });
    
    test('importData should fail gracefully on invalid JSON', () async {
      SharedPreferences.setMockInitialValues({});
      final backupService = BackupService();
      
      final success = await backupService.importData('invalid json');
      expect(success, false);
    });
  });
}
