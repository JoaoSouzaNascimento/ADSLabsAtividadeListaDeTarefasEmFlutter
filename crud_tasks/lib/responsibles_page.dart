import 'package:crud_tasks/responsible_add_ui.dart';
import 'package:crud_tasks/responsible_api.dart';
import 'package:crud_tasks/responsible_datails_page.dart';
import 'package:crud_tasks/responsible_edit_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ResponsiblesPage extends StatefulWidget {
  const ResponsiblesPage({super.key});

  @override
  State<ResponsiblesPage> createState() => _ResponsiblesPageState();
}

class _ResponsiblesPageState extends State<ResponsiblesPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<ResponsibleProvider>(context, listen: false).fetchResponsibles();
  }

  @override
  Widget build(BuildContext context) {
    final responsibleProvider = Provider.of<ResponsibleProvider>(context);

    return Scaffold(
      body: responsibleProvider.responsibles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: responsibleProvider.responsibles.length,
        itemBuilder: (context, index) {
          final responsible = responsibleProvider.responsibles[index];
          return Card (
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: ListTile(
              title: GestureDetector(
                child: Text(
                  responsible.nome,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onTap: () => navigateToResponsibleDetails(responsible.responsavelId),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 5),
                      Text('Id: ${responsible.responsavelId}'),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 3),
                      Text(
                          'Nascimento: ${DateFormat('yyyy-MM-dd').format(responsible.dataDeNascimento)}'),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => navigateToEditResponsible(responsible.responsavelId),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => responsibleProvider.deleteResponsible(responsible.responsavelId),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => navigateToAddResponsible(),
      ),
    );
  }

  void navigateToAddResponsible() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddResponsiblePage()),
    );
  }

  void navigateToEditResponsible(int responsavelId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  EditResponsiblePage(responsavelId: responsavelId)),
    );
  }

  void navigateToResponsibleDetails(int responsibleId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResponsibleDetailsPage(responsibleId: responsibleId)),
    );
  }
}