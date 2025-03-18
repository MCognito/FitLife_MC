// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitlife/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        child: const MyApp(themeMode: ThemeMode.light),
      ),
    );

    // Verify that the app initializes without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App has correct theme', (WidgetTester tester) async {
    // Build our app with light theme
    await tester.pumpWidget(
      ProviderScope(
        child: const MyApp(themeMode: ThemeMode.light),
      ),
    );

    // Get the MaterialApp widget
    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    // Verify that the theme is set correctly
    expect(app.theme, isNotNull);
    expect(app.darkTheme, isNotNull);
  });

  testWidgets('App has a title', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(
      ProviderScope(
        child: const MyApp(themeMode: ThemeMode.light),
      ),
    );

    // Get the MaterialApp widget
    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    // Verify that the app title is set
    expect(app.title, isNotNull);
  });
}
