import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupService {
  BackupService();

  Future<String> exportData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    final Map<String, dynamic> data = {};
    for (String key in keys) {
      data[key] = prefs.get(key);
    }

    final backup = {
      'version': '1.1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'data': data,
    };

    return jsonEncode(backup);
  }

  Future<bool> importData(String jsonString) async {
    try {
      final backup = jsonDecode(jsonString);
      if (backup is! Map<String, dynamic> || backup['data'] == null) {
        return false;
      }

      final data = backup['data'] as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();

      await prefs.clear();

      for (var entry in data.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is String) {
          await prefs.setString(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is List) {
          await prefs.setStringList(key, value.map((e) => e.toString()).toList());
        }
      }
      return true;
    } catch (e) {
      debugPrint('Import data error: $e');
      return false;
    }
  }

  Future<void> exportBackup() async {
    try {
      final jsonString = await exportData();
      
      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/daypath_backup_$timestamp.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)], 
        text: 'Daypath Data Backup - $timestamp',
        subject: 'Daypath Backup',
      );
    } catch (e) {
      debugPrint('Export failed: $e');
      rethrow;
    }
  }

  Future<bool> importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        
        return await importData(content);
      }
      return false;
    } catch (e) {
      debugPrint('Import failed: $e');
      return false;
    }
  }
}
