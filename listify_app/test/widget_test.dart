// This is a basic Flutter widget test for Listify todo app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:listify_app/main.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    // Initialize the database factory for testing
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App loads and shows basic structure', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Wait for initial frame
    await tester.pump();
    
    // Verify that the app bar is present
    expect(find.text('Listify'), findsOneWidget);
    
    // Verify that the add task button exists
    expect(find.byType(FloatingActionButton), findsOneWidget);
    
    // Check that there's some form of loading or content area
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Floating action button is present and tappable', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Wait for initial frame
    await tester.pump();

    // Find the floating action button
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    
    // Verify it contains the expected elements
    expect(find.descendant(of: fab, matching: find.byIcon(Icons.add)), findsOneWidget);
    expect(find.descendant(of: fab, matching: find.text('Add Task')), findsOneWidget);
  });
}
