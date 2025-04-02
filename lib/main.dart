import 'dart:convert'; // Для кодирования/декодирования JSON
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Для сохранения данных

void main() {
  runApp(const TaskManagerApp());
}

class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});

  // Метод для преобразования Task в Map (для JSON)
  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
      };

  // Фабричный конструктор для создания Task из Map (из JSON)
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        isDone: json['isDone'],
      );
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TaskListScreen(),
      debugShowCheckedModeBanner: false, // Убираем баннер Debug
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _editController = TextEditingController();

  // Ключ для сохранения данных в SharedPreferences
  static const String _tasksKey = 'tasks';

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Загружаем задачи при инициализации
  }

  // Загрузка задач из SharedPreferences
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? tasksJson = prefs.getStringList(_tasksKey);
    if (tasksJson != null) {
      setState(() {
        _tasks.clear(); // Очищаем текущий список перед загрузкой
        _tasks.addAll(tasksJson
            .map((taskJson) => Task.fromJson(jsonDecode(taskJson)))
            .toList());
      });
    }
  }

  // Сохранение задач в SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> tasksJson =
        _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList(_tasksKey, tasksJson);
  }

  void _addTask() {
    final String taskTitle = _taskController.text.trim();
    if (taskTitle.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: taskTitle));
      });
      _saveTasks(); // Сохраняем задачи
      _taskController.clear(); // Очищаем поле ввода
      FocusScope.of(context).unfocus(); // Скрываем клавиатуру
    } else {
      // Показываем сообщение, если поле пустое
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите название задачи.')),
      );
    }
  }

  void _toggleTaskStatus(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
    _saveTasks(); // Сохраняем задачи
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks(); // Сохраняем задачи
  }

  // 1. Делаем функцию асинхронной
  void _editTask(int index) async {
    final Task task = _tasks[index];
    _editController.text = task.title;
    // Убираем сохранение scaffoldMessenger здесь

    // 2. Ожидаем результат showDialog
    final String? newTitle = await showDialog<String?>(
      context: context,
      // Важно: Не передаем context асинхронно, используем dialogContext внутри builder
      builder: (BuildContext dialogContext) {
        // Используем контроллер, объявленный выше
        return AlertDialog(
          title: const Text('Редактировать задачу'),
          content: TextField(
            controller: _editController, // 2. Передаем контроллер
            autofocus: true, // Сразу фокусируемся на поле
            decoration: const InputDecoration(
              hintText: 'Новое название задачи',
            ),
            onSubmitted: (_) {
              // Сохраняем по Enter
              final String newTitle = _editController.text.trim();
              if (newTitle.isNotEmpty) {
                // Возвращаем новое название при закрытии
                Navigator.of(dialogContext).pop(newTitle);
              } else {
                // Возвращаем пустую строку, чтобы сигнализировать об ошибке ввода
                Navigator.of(dialogContext).pop("");
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                // Закрываем диалог, не возвращая значения (или возвращая null)
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Сохранить'),
              onPressed: () {
                final String newTitle = _editController.text.trim();
                if (newTitle.isNotEmpty) {
                  // Возвращаем новое название при закрытии
                  Navigator.of(dialogContext).pop(newTitle);
                } else {
                  // Возвращаем пустую строку, чтобы сигнализировать об ошибке ввода
                  Navigator.of(dialogContext).pop("");
                }
              },
            ),
          ],
        );
      },
    ); // Завершение await showDialog

    // Важно: Проверяем mounted *сразу после* await и *перед* любыми действиями
    if (!mounted) {
      return;
    }

    // 4. Обрабатываем результат
    if (newTitle != null) {
      // Результат есть (не отмена)
      if (newTitle.isNotEmpty) {
        // Результат - валидное название
        setState(() {
          _tasks[index].title = newTitle;
        });
        _saveTasks(); // Сохраняем задачи
      } else {
        // Результат - пустая строка (ошибка ввода)
        // Показываем SnackBar на основном экране ПОСЛЕ закрытия диалога
        // Получаем ScaffoldMessenger здесь, т.к. context гарантированно валиден после проверки mounted
        if (context.mounted) {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Название задачи не может быть пустым.'),
            ),
          );
        }
      }
    }
    // Если newTitle == null (отмена), ничего не делаем
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Менеджер Задач')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Введите новую задачу...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTask(), // Добавляем задачу по Enter
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                    ), // Делаем кнопку повыше
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  tileColor: Colors.grey[200], // Добавляем цвет фона
                  leading: Checkbox(
                    value: task.isDone,
                    onChanged: (bool? value) {
                      _toggleTaskStatus(index);
                    },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration:
                          task.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                      color: task.isDone ? Colors.grey : Colors.black,
                    ),
                  ),
                  trailing: Row(
                    // Используем Row для размещения нескольких иконок
                    mainAxisSize:
                        MainAxisSize.min, // Занимаем минимальное место
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editTask(index),
                        tooltip: 'Редактировать', // Подсказка при наведении
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeTask(index),
                        tooltip: 'Удалить', // Подсказка при наведении
                      ),
                    ],
                  ),
                  onTap:
                      () => _toggleTaskStatus(
                        index,
                      ), // Меняем статус по тапу на элемент
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose(); // Освобождаем ресурсы контроллера
    _editController.dispose();
    super.dispose();
  }
}
