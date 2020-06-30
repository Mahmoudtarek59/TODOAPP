import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:semicolontodoapp/dummy_data.dart';
import 'package:semicolontodoapp/model/task.dart';
import 'package:http/http.dart' as http;

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  final String token;
  final String userId;
  TaskProvider(this.token, this.userId, this._tasks);

  List<Task> get tasks {
    return [..._tasks];
  }

  Future<void> fetchingTasks() async {
    final url =
        'https://todo-77606.firebaseio.com/tasks/$userId.json?auth=$token';
    try {
      var response = await http.get(url);
      final Map<String, dynamic> data = json.decode(response.body);
      if (data == null) {
        return;
      }
      final List<Task> loadedTasks = [];
      data.forEach((taskId, value) {
        loadedTasks.add(
          Task(
            id: taskId,
            task: value['task'],
            dateTime: DateTime.parse(value['dateTime']),
          ),
        );

      });
      _tasks=loadedTasks.reversed.toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> addTask(Task task) async {
    final url =
        'https://todo-77606.firebaseio.com/tasks/$userId.json?auth=$token';

    try {
      var response = await http.post(
        url,
        body: json.encode({
          'task': task.task,
          'dateTime': task.dateTime.toIso8601String(),
        }),
      );
      print(json.decode(response.body).toString());
      _tasks.insert(
        0,
        Task(
          id: json.decode(response.body)['name'],
          task: task.task,
          dateTime: task.dateTime,
        ),
      );
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateTask(Task task) async {
    final url =
        'https://todo-77606.firebaseio.com/tasks/$userId/${task.id}.json?auth=$token';
    final taskIndex = _tasks.indexWhere((item) => task.id == item.id);
    try {
      await http.patch(url,
          body: json.encode({
            'task': task.task,
            'dateTime': task.dateTime.toIso8601String(),
          }));
      _tasks[taskIndex] = task;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeTask(String taskID) async {
    final url =
        'https://todo-77606.firebaseio.com/tasks/$userId/${taskID}.json?auth=$token';
    final taskIndex = _tasks.indexWhere((item) => taskID == item.id);
    var existingTask = _tasks[taskIndex];
    _tasks.removeAt(taskIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _tasks.insert(taskIndex, existingTask);
      notifyListeners();
      return false;
    }
    existingTask = null;
    return true;
  }
}
