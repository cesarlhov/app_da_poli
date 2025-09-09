// lib/models/tarefa_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Este ficheiro define a estrutura de dados para uma Tarefa.
class Tarefa {
  final String id;
  final String titulo;
  final Timestamp dataEntrega;
  final bool concluida;

  Tarefa({
    required this.id,
    required this.titulo,
    required this.dataEntrega,
    required this.concluida,
  });

  // --- MUDANÇA: Renomeado de fromFirestore para fromMap e parâmetros atualizados ---
  factory Tarefa.fromMap(String id, Map<String, dynamic> data) {
    return Tarefa(
      id: id,
      titulo: data['titulo'] ?? '',
      dataEntrega: data['dataEntrega'] ?? Timestamp.now(),
      concluida: data['concluida'] ?? false,
    );
  }
}