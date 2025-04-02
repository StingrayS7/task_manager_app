// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_manager_app/main.dart';

void main() {
  testWidgets('Adds a task smoke test', (WidgetTester tester) async { // Изменим описание теста
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TaskManagerApp()); // Используем TaskManagerApp

    // Verify that initially there are no tasks.
    expect(find.byType(ListTile), findsNothing); // Проверяем, что список задач пуст
    // expect(find.text('1'), findsNothing); // Удалим старые проверки счетчика

    // Enter text into the TextField.
    await tester.enterText(find.byType(TextField), 'Новая задача');
    await tester.pump();

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that the new task appears in the list.
    expect(find.text('Новая задача'), findsOneWidget); // Проверяем наличие новой задачи
    expect(find.byType(ListTile), findsOneWidget); // Проверяем, что в списке есть один элемент
    // expect(find.text('0'), findsNothing); // Удалим старые проверки счетчика
    // expect(find.text('1'), findsOneWidget); // Удалим старые проверки счетчика
  });
}
