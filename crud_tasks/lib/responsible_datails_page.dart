import 'package:crud_tasks/responsible_api.dart';
import 'package:crud_tasks/task_add_ui.dart';
import 'package:crud_tasks/task_datails_page.dart';
import 'package:crud_tasks/task_edit_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crud_tasks/tasks_api.dart';
import 'package:intl/intl.dart';

class ResponsibleDetailsPage extends StatefulWidget {
  final int responsibleId;

  const ResponsibleDetailsPage({super.key, required this.responsibleId});

  @override
  State<ResponsibleDetailsPage> createState() => _ResponsibleDetailsPageState();
}

class _ResponsibleDetailsPageState extends State<ResponsibleDetailsPage> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final responsibleProvider = Provider.of<ResponsibleProvider>(context);
    final responsible = responsibleProvider.responsibles.firstWhere(
            (responsible) => responsible.responsavelId == widget.responsibleId
    );
    final tasks = _selectedStatus == null
        ? taskProvider.tasks
          .where(
            (task) => task.responsavelId == responsible.responsavelId).toList()
        : taskProvider.tasks
        .where(
            (task) => task.status.toLowerCase() == _selectedStatus!.toLowerCase()
                && task.responsavelId == responsible.responsavelId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Responsável'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        responsible.nome,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const Text(
                        'Responsável',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ID: ${responsible.responsavelId}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const Text(
                        'Data de Nascimento',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('yyyy-MM-dd').format(responsible.dataDeNascimento),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tarefas Atribuídas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
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
              Text(_selectedStatus == null ? 'All Tasks' : 'Tasks: $_selectedStatus'),
              const SizedBox(height: 16),
              tasks.isEmpty
                  ? const Text(
                  'Nenhuma tarefa atribuída.',
                  style: TextStyle(fontSize: 16))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: ListTile(
                      title: GestureDetector(
                        child: Text(
                          task.titulo,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        onTap: () => navigateToTaskDetails(context, task.idTarefa),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person),
                              const SizedBox(width: 5),
                              Text('Responsável: ${task.responsavelId}'),
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
                            onPressed: () => navigateToEditTask(context, task.idTarefa),
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => navigateToAddTask(context),
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

  void navigateToAddTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskPage()),
    );
  }

  void navigateToEditTask(BuildContext context, int taskId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTaskPage(taskId: taskId)),
    );
  }

  void navigateToTaskDetails(BuildContext context, int taskId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailsPage(taskId: taskId)),
    );
  }
}