// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:balance_calculator/main.dart';
import 'package:balance_calculator/providers/balance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => BalanceProvider(),
        child: const BalanceApp(),
      ),
    );

    // Verify that our app starts.
    expect(find.text('Balance Manager'), findsOneWidget);
  });

  testWidgets('App configures the default theme correctly', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => BalanceProvider(),
        child: const BalanceApp(),
      ),
    );

    // Find the MaterialApp widget.
    final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));

    // Verify theme configuration.
    expect(materialApp.themeMode, ThemeMode.system);
    expect(materialApp.theme, isNotNull);
    expect(materialApp.darkTheme, isNull);
    expect(materialApp.theme!.colorScheme.brightness, Brightness.light);
    expect(materialApp.theme!.useMaterial3, isTrue);
    expect(materialApp.theme!.appBarTheme.backgroundColor, Colors.deepPurple);
    expect(materialApp.theme!.appBarTheme.foregroundColor, Colors.white);
  });
}
