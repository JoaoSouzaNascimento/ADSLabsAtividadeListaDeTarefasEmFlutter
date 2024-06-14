import 'package:crud_tasks/responsible_api.dart';
import 'package:crud_tasks/responsible_datails_page.dart';
import 'package:flutter/material.dart';
import 'package:crud_tasks/tasks_api.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TaskDetailsPage extends StatefulWidget {
  final int taskId;

  const TaskDetailsPage({super.key, required this.taskId});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final responsibleProvider = Provider.of<ResponsibleProvider>(context, listen: false);

    late Task task;
    bool taskExists = false;

    for (var t in taskProvider.tasks) {
      if (t.idTarefa == widget.taskId) {
        task = t;
        taskExists = true;
        break;
      }
    }

    if (!taskExists) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes da Tarefa'),
        ),
        body: const Center(
          child: Text('Tarefa não existe mais.'),
        ),
      );
    }

    final responsible = responsibleProvider.responsibles.firstWhere(
              (responsible) => responsible.responsavelId == task.responsavelId);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Tarefa'),
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
                        task.titulo,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const Text(
                        'Descrição',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.descricao ?? 'Nenhuma descrição disponível.',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      GestureDetector(
                        onTap: () {
                          navigateToResponsibleDetails(responsible.responsavelId);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Responsável',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ID: ${task.responsavelId}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const Text(
                        'Status',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.status,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const Text(
                        'Deadline',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('yyyy-MM-dd').format(task.dataLimite),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const Text(
                        'Data de Conclusão',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.dataConclusao != null
                            ? DateFormat('yyyy-MM-dd').format(task.dataConclusao!)
                            : 'Não concluída.',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          final taskUpdated = Task(
            idTarefa: task.idTarefa,
            titulo: task.titulo,
            descricao: task.descricao,
            responsavelId: task.responsavelId,
            status: task.status,
            dataLimite: task.dataLimite,
            dataConclusao: DateTime.now(),
          );
          taskProvider.editTask(task.idTarefa, taskUpdated).then((_) {
            Navigator.pop(context);
            taskProvider.fetchTasks();
          }).catchError((error) {
            //TODO: deal with errors my dear friend
            print(error.toString());
          });
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Concluir Tarefa',
          style: TextStyle(fontSize: 16),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void navigateToResponsibleDetails(int responsibleId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResponsibleDetailsPage(responsibleId: responsibleId)),
    );
  }
}
