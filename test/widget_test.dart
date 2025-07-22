// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:hypothesis_helper/main.dart';
import 'package:hypothesis_helper/providers/test_provider.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('App starts correctly', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const HypothesisHelperApp());

      // Verify that the app starts with the calculator screen
      expect(find.text('假设检验计算器'), findsOneWidget);
      expect(find.text('计算器'), findsOneWidget);
      expect(find.text('学习模块'), findsOneWidget);
    });

    testWidgets('Navigation between screens works', (WidgetTester tester) async {
      await tester.pumpWidget(const HypothesisHelperApp());

      // Tap on learning module
      await tester.tap(find.text('学习模块'));
      await tester.pumpAndSettle();

      // Verify we're on the learning screen
      expect(find.text('交互式学习模块'), findsOneWidget);

      // Go back to calculator
      await tester.tap(find.text('计算器'));
      await tester.pumpAndSettle();

      // Verify we're back on calculator screen
      expect(find.text('假设检验计算器'), findsOneWidget);
    });

    testWidgets('Calculator navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(const HypothesisHelperApp());

      // Tap on start calculation button
      await tester.tap(find.text('开始计算'));
      await tester.pumpAndSettle();

      // Verify we're on the test selection screen
      expect(find.text('选择检验类型'), findsOneWidget);
      expect(find.text('单样本t检验'), findsOneWidget);
    });

    testWidgets('Learning modules navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(const HypothesisHelperApp());

      // Navigate to learning screen
      await tester.tap(find.text('学习模块'));
      await tester.pumpAndSettle();

      // Tap on P值可视化
      await tester.tap(find.text('P值可视化'));
      await tester.pumpAndSettle();

      // Verify we're on the P value visualization screen
      expect(find.text('P值可视化'), findsOneWidget);
    });
  });

  group('Provider Tests', () {
    testWidgets('TestProvider state management', (WidgetTester tester) async {
      late TestProvider testProvider;

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TestProvider(),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                testProvider = Provider.of<TestProvider>(context, listen: false);
                return const Scaffold(
                  body: Text('Test'),
                );
              },
            ),
          ),
        ),
      );

      // Test initial state
      expect(testProvider.currentInput, isNull);
      expect(testProvider.currentResult, isNull);
      expect(testProvider.isCalculating, isFalse);
      expect(testProvider.errorMessage, isNull);
    });
  });
}
