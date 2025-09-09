// lib/models/disciplina_model.dart

import 'dart:math';
import 'package:flutter/material.dart';

class Disciplina {
  final String id;
  final String nome;
  final String codigo;
  final String professor;
  final String sala;
  final List<String> diasDaSemana;
  final String horarioInicio;
  final String horarioFim;
  final Color cor;

  Disciplina({
    required this.id,
    required this.nome,
    required this.codigo,
    required this.professor,
    required this.sala,
    required this.diasDaSemana,
    required this.horarioInicio,
    required this.horarioFim,
    required this.cor,
  });

  // Construtor que cria um objeto Disciplina a partir de dados do Firestore
  factory Disciplina.fromMap(String id, Map<String, dynamic> data) {
    // Lógica para gerar uma cor com base no código da disciplina,
    // garantindo que a mesma disciplina tenha sempre a mesma cor.
    final random = Random(data['codigo'].hashCode);
    final color = Color.fromRGBO(
      random.nextInt(156) + 100, // R entre 100-255
      random.nextInt(156) + 100, // G entre 100-255
      random.nextInt(156) + 100, // B entre 100-255
      1,
    );

    return Disciplina(
      id: id,
      nome: data['nome'] ?? '',
      codigo: data['codigo'] ?? '',
      professor: data['professor'] ?? '',
      sala: data['sala'] ?? '',
      diasDaSemana: List<String>.from(data['diasDaSemana'] ?? []),
      horarioInicio: data['horarioInicio'] ?? '',
      horarioFim: data['horarioFim'] ?? '',
      cor: data['cor'] != null ? Color(int.parse(data['cor'])) : color,
    );
  }
}