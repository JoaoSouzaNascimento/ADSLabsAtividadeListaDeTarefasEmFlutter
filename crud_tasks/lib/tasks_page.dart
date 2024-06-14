import 'package:crud_tasks/task_add_ui.dart';
import 'package:crud_tasks/task_datails_page.dart';
import 'package:crud_tasks/task_edit_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crud_tasks/tasks_api.dart';
import 'package:intl/intl.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    Provider.of<TaskProvider>(context, listen: false).fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    List<Task> filteredTasks = _selectedStatus == null
        ? taskProvider.tasks
        : taskProvider.tasks
        .where((task) => task.status.toLowerCase() == _selectedStatus!.toLowerCase())
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedStatus == null ? 'All Tasks' : 'Tasks: $_selectedStatus'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list), padding: const EdgeInsets.fromLTRB(0,0,30,0),
            onSelected: (String status) {
              setState(() {
                _selectedStatus = status == 'All' ? null : status;
              });
            },
            itemBuilder: (BuildContext context) {
              return ['All', 'pendente', 'entregue', 'expirado'].map((String status) {
                return PopupMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: filteredTasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return Card (
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: ListTile(
              title: GestureDetector(
                child: Text(
                  task.titulo,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onTap: () => navigateToTaskDetails(task.idTarefa),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 5),
                      Text('Responsible: ${task.responsavelId}'),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 5),
                      Text(
                          'Deadline: ${DateFormat('yyyy-MM-dd').format(task.dataLimite)}'),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.work,
                        color: getStatusColor(task.status),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Status: ${task.status}',
                        style: TextStyle(
                          color: getStatusColor(task.status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => navigateToEditTask(task.idTarefa),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => taskProvider.deleteTask(task.idTarefa),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => navigateToAddTask(),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pendente':
        return Colors.orange;
      case 'entregue':
        return Colors.green;
      case 'expirado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void navigateToAddTask() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskPage()),
    );
  }

  void navigateToEditTask(int taskId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTaskPage(taskId: taskId)),
    );
  }

  void navigateToTaskDetails(int taskId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailsPage(taskId: taskId)),
    );
  }
}