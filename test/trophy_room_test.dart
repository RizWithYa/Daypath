import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_application_v1/trophy_room_page.dart';
import 'package:todo_application_v1/models.dart';
import 'package:todo_application_v1/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Tapping achievement shows detail modal', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    // Build the TrophyRoomPage wrapped in necessary providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(),
          ),
        ],
        child: const MaterialApp(
          home: TrophyRoomPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initial load, grid items should be present
    expect(find.byType(GridView), findsOneWidget);
    
    // Find the 'First Task' achievement
    final firstTaskFinder = find.text('FIRST TASK');
    expect(firstTaskFinder, findsOneWidget);

    // Tap it
    await tester.tap(firstTaskFinder);
    await tester.pumpAndSettle();

    // Verify the modal appears with the details
    expect(find.text('HOW TO ACHIEVE'), findsOneWidget);
    expect(find.text('Simply complete any single task from your task list to unlock this achievement.'), findsOneWidget);
  });
}
