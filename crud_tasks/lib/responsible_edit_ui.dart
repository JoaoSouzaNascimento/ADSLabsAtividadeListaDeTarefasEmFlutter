import 'package:crud_tasks/responsible_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditResponsiblePage extends StatefulWidget {
  final int responsavelId;

  const EditResponsiblePage({super.key, required this.responsavelId});

  @override
  State<EditResponsiblePage> createState() => _EditResponsiblePageState();
}

class _EditResponsiblePageState extends State<EditResponsiblePage> {
  late TextEditingController _nameController;
  late DateTime _birthDateController;
  late Responsible responsible;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final responsibleProvider = Provider.of<ResponsibleProvider>(context, listen: false);
    responsible = responsibleProvider.responsibles.firstWhere(
            (responsible) => responsible.responsavelId == widget.responsavelId);
    _nameController = TextEditingController(text: responsible.nome);
    _birthDateController = responsible.dataDeNascimento;
  }

  @override
  Widget build(BuildContext context) {
    final responsibleProvider = Provider.of<ResponsibleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Responsável'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um nome';
                    }
                    if (value.length < 3) {
                      return 'O nome deve ter pelo menos 3 letras';
                    }
                    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                      return 'O nome deve conter apenas letras';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Data de Nascimento: ',
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        DatePicker.showDatePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime(1900),
                          maxTime: DateTime(2014, 12, 31),
                          onConfirm: (date) {
                            setState(() {
                              _birthDateController = date;
                            });
                          },
                        );
                      },
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(_birthDateController),
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
                        final updatedResponsible = Responsible(
                          responsavelId: responsible.responsavelId,
                          nome: _nameController.text,
                          dataDeNascimento: _birthDateController,
                        );
                        responsibleProvider
                            .editResponsible(responsible.responsavelId, updatedResponsible)
                            .then((_) {
                          Navigator.pop(context);
                          responsibleProvider.fetchResponsibles();
                        }).catchError((error) {
                          _showErrorDialog(context, error.toString());
                        }).whenComplete(() {
                          setState(() {
                            _isLoading = false;
                          });
                        });
                      }
                    },
                    child: const Text('Editar Responsável'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
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