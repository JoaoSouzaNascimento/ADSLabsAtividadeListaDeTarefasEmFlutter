import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:crud_tasks/consts.dart';

class Task {
  int idTarefa;
  final String titulo;
  final String? descricao;
  final DateTime dataLimite;
  final DateTime? dataConclusao;
  final String status;
  int? responsavelId;

  Task({
    required this.idTarefa,
    required this.titulo,
    required this.descricao,
    required this.dataLimite,
    required this.dataConclusao,
    required this.status,
    required this.responsavelId,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    idTarefa: json['id_tarefa'],
    titulo: json['titulo'],
    descricao: json['descricao'],
    dataLimite: DateTime.parse(json['data_limite']),
    dataConclusao: DateTime.parse(json['data_conclusao']),
    status: json['status'],
    responsavelId: json['responsavelId'],
  );


  Map<String, dynamic> toJson() => {
    'id_tarefa': idTarefa,
    'titulo': titulo,
    'descricao': descricao,
    'status': status,
    'data_limite': dataLimite.toIso8601String(),
    'data_conclusao': dataConclusao!.toIso8601String(),
    'responsavelId': responsavelId,
  };

  Map<String, dynamic> toJsonForAdd() => {
    'titulo': titulo,
    'descricao': descricao,
    'status': status,
    'data_limite': dataLimite.toIso8601String(),
    'data_conclusao': dataConclusao!.toIso8601String(),
    'responsavelId': responsavelId
  };
}

class TaskProvider extends ChangeNotifier {
  List<Task> tasks = [];

  Future<void> fetchTasks() async {
    const url = 'http://$localhost:3000/tarefas';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> taskData = data['dados'];
      tasks = taskData.map((item) => Task.fromJson(item)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> addTask(Task task) async {
    const url = 'http://$localhost:3000/tarefas';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(task.toJsonForAdd()),
    );
    if (response.statusCode != 200) {
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to add task');
    } else {
      tasks.add(task);
      notifyListeners();
    }
  }

  Future<void> deleteTask(int taskId) async {
    final url = 'http://$localhost:3000/tarefas/$taskId';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    } else {
      tasks.removeWhere((task) => task.idTarefa == taskId);
      notifyListeners();
    }
  }

  Future<void> editTask(int taskId, Task updatedTask) async {
    final url = 'http://$localhost:3000/tarefas/$taskId';
    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(updatedTask.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to edit task');
    } else {
      final index = tasks.indexWhere((task) => task.idTarefa == taskId);
      tasks[index] = updatedTask;
      notifyListeners();
    }
  }
}
