// lib/models/disciplina_model.dart

import 'dart:math';
import 'package:flutter/material.dart';

/// Representa uma disciplina com todas as suas informações.
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

  const Disciplina({
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

  /// Factory constructor para criar uma instância de [Disciplina] a partir de um mapa
  /// (geralmente vindo do Firestore).
  factory Disciplina.fromMap(String id, Map<String, dynamic> data) {
    // Gera uma cor determinística com base no código da disciplina,
    // garantindo que a mesma disciplina tenha sempre a mesma cor.
    final random = Random(data['codigo'].hashCode);
    final color = Color.fromRGBO(
      random.nextInt(156) + 100, // Vermelho entre 100-255 para evitar cores muito escuras
      random.nextInt(156) + 100, // Verde entre 100-255
      random.nextInt(156) + 100, // Azul entre 100-255
      1,
    );

    return Disciplina(
      id: id,
      nome: data['nome'] ?? '',
      codigo: data['codigo'] ?? '',
      professor: data['professor'] ?? '',
      sala: data['sala'] ?? '',
      diasDaSemana: List<String>.from(data['diasDaSemana'] ?? []),
      horarioInicio: data['horarioInicio'] ?? '00:00',
      horarioFim: data['horarioFim'] ?? '00:00',
      // Se uma cor já estiver definida no Firestore, usa ela. Senão, usa a cor gerada.
      cor: data['cor'] != null ? Color(int.parse(data['cor'])) : color,
    );
  }
}