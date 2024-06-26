import 'package:crud_tasks/responsible_api.dart';
import 'package:crud_tasks/tasks_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _responsibleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int? _selectedResponsibleId;
  DateTime _deadlineController = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final responsibleProvider = Provider.of<ResponsibleProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Tarefa'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um título';
                    }
                    if (value.length < 3) {
                      return 'O título deve ter pelo menos 3 letras';
                    }
                    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                      return 'O nome deve conter apenas letras';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _responsibleController,
                  decoration: const InputDecoration(
                    labelText: 'Responsável',
                    suffixIcon: Icon(Icons.arrow_drop_down),
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecione um responsável';
                    }
                    return null;
                  },
                  onTap: () async {
                    final selectedResponsible = await showModalBottomSheet<Responsible>(
                      context: context,
                      builder: (context) {
                        return ListView.builder(
                          itemCount: responsibleProvider.responsibles.length,
                          itemBuilder: (context, index) {
                            final responsible = responsibleProvider.responsibles[index];
                            return ListTile(
                              title: Text(responsible.nome),
                              onTap: () {
                                Navigator.pop(context, responsible);
                              },
                            );
                          },
                        );
                      },
                    );
                    if (selectedResponsible != null) {
                      setState(() {
                        _selectedResponsibleId = selectedResponsible.responsavelId;
                        _responsibleController.text = selectedResponsible.nome;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Prazo: ',
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        DatePicker.showDatePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime.now(),
                          onConfirm: (date) {
                            setState(() {
                              _deadlineController = date;
                            });
                          },
                        );
                      },
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(_deadlineController),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        setState(() {
                          _isLoading = true;
                        });
                        final task = Task(
                          idTarefa: 0,
                          titulo: _titleController.text,
                          descricao: _descriptionController.text,
                          responsavelId: _selectedResponsibleId!,
                          status: 'Atribuido',
                          dataLimite: _deadlineController,
                          dataConclusao: null,
                        );
                        taskProvider.addTask(task).then((_) {
                          Navigator.pop(context);
                          taskProvider.fetchTasks();
                        }).catchError((error) {
                          _showErrorDialog(context, error.toString());
                        }).whenComplete(() {
                          setState(() {
                            _isLoading = false;
                          });
                        });
                      }
                    },
                    child: const Text('Adicionar Tarefa'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}