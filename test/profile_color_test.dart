import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todo_application_v1/profile_page.dart';
import 'package:todo_application_v1/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Accent color picker always contains the default blue option', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    
    final themeProvider = ThemeProvider();
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: Builder(
          builder: (context) {
            return MaterialApp(
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: context.watch<ThemeProvider>().accentColor,
                  primary: context.watch<ThemeProvider>().accentColor,
                ),
              ),
              home: const Scaffold(body: ProfilePage()),
            );
          }
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap the settings icon to open the bottom sheet
    final settingsIcon = find.byIcon(Icons.settings_outlined);
    expect(settingsIcon, findsOneWidget);
    await tester.tap(settingsIcon);
    await tester.pumpAndSettle();

    // Verify APP ACCENT COLOR section exists
    expect(find.text('APP ACCENT COLOR'), findsOneWidget);

    // The blue option should be present
    final blueColor = const Color(0xFF007BFF);
    
    // In our UI, the color option is a Container with a BoxDecoration that has the color.
    // We will look for a Container with that exact color in its decoration.
    Finder blueOptionFinder = find.byWidgetPredicate((widget) {
      if (widget is Container && widget.decoration is BoxDecoration) {
        final boxDeco = widget.decoration as BoxDecoration;
        return boxDeco.color == blueColor && boxDeco.shape == BoxShape.circle;
      }
      return false;
    });

    expect(blueOptionFinder, findsOneWidget, reason: "The default blue color option should be available initially");

    // Tap the orange option
    final orangeColor = const Color(0xFFFFBA24);
    Finder orangeOptionFinder = find.byWidgetPredicate((widget) {
      if (widget is Container && widget.decoration is BoxDecoration) {
        final boxDeco = widget.decoration as BoxDecoration;
        return boxDeco.color == orangeColor && boxDeco.shape == BoxShape.circle;
      }
      return false;
    });
    
    expect(orangeOptionFinder, findsOneWidget);
    await tester.tap(orangeOptionFinder.first);
    await tester.pumpAndSettle();

    // Re-open the settings modal
    await tester.tap(settingsIcon);
    await tester.pumpAndSettle();

    // After theme changed to Orange, the Blue option MUST still exist to allow reverting
    blueOptionFinder = find.byWidgetPredicate((widget) {
      if (widget is Container && widget.decoration is BoxDecoration) {
        final boxDeco = widget.decoration as BoxDecoration;
        return boxDeco.color == blueColor && boxDeco.shape == BoxShape.circle;
      }
      return false;
    });

    expect(blueOptionFinder, findsOneWidget, reason: "The default blue color option should STILL be available after changing to Orange");
  });
}
