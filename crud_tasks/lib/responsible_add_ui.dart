import 'package:crud_tasks/responsible_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddResponsiblePage extends StatefulWidget {
  const AddResponsiblePage({super.key});

  @override
  State<AddResponsiblePage> createState() => _AddResponsiblePageState();
}

class _AddResponsiblePageState extends State<AddResponsiblePage> {
  final TextEditingController _nameController = TextEditingController();
  DateTime _birthDateController = DateTime(2014, 12, 31);
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final responsibleProvider = Provider.of<ResponsibleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Responsável'),
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
                        final responsible = Responsible(
                          responsavelId: 0,
                          nome: _nameController.text,
                          dataDeNascimento: _birthDateController,
                        );
                        responsibleProvider
                            .addResponsible(responsible)
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Adicionar Responsável'),
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
