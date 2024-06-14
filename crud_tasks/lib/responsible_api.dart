import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:crud_tasks/consts.dart';

class Responsible {
  int responsavelId;
  final String nome;
  final DateTime dataDeNascimento;

  Responsible({
    required this.responsavelId,
    required this.nome,
    required this.dataDeNascimento,
  });

  factory Responsible.fromJson(Map<String, dynamic> json) => Responsible(
    responsavelId: json['id_responsavel'],
    nome: json['nome'],
    dataDeNascimento: DateTime.parse(json['data_nascimento'])
  );


  Map<String, dynamic> toJson() => {
    'id_responsavel': responsavelId,
    'nome': nome,
    'data_nascimento': dataDeNascimento.toIso8601String(),
  };

  Map<String, dynamic> toJsonForAdd() => {
    'nome': nome,
    'data_nascimento': dataDeNascimento.toIso8601String(),
  };
}

class ResponsibleProvider extends ChangeNotifier {
  List<Responsible> responsibles = [];

  Future<void> fetchResponsibles() async {
    const url = 'http://$localhost:3000/responsaveis';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> responsibleData = data['dados'];
      responsibles = responsibleData.map((item) => Responsible.fromJson(item)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load responsibles');
    }
  }

  Future<void> addResponsible(Responsible responsible) async {
    const url = 'http://$localhost:3000/responsaveis';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(responsible.toJsonForAdd()),
    );
    if (response.statusCode != 201) {
      final data = json.decode(response.body);
      throw data['message'];
    } else {
      responsibles.add(responsible);
      notifyListeners();
    }
  }

  Future<void> deleteResponsible(int responsibleId) async {
    final url = 'http://$localhost:3000/responsaveis/$responsibleId';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete responsible');
    } else {
      responsibles.removeWhere((responsible) => responsible.responsavelId == responsibleId);
      notifyListeners();
    }
  }

  Future<void> editResponsible(int responsibleId, Responsible updatedResponsible) async {
    final url = 'http://$localhost:3000/responsaveis/$responsibleId';
    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(updatedResponsible.toJson()),
    );
    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw data['message'];
    } else {
      final index = responsibles.indexWhere((responsible) => responsible.responsavelId == responsibleId);
      responsibles[index] = updatedResponsible;
      notifyListeners();
    }
  }
}
