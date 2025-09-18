// lib/models/tarefa_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa uma tarefa a ser feita pelo usuário.
class Tarefa {
  final String id;
  final String titulo;
  final Timestamp dataEntrega;
  final bool concluida;

  const Tarefa({
    required this.id,
    required this.titulo,
    required this.dataEntrega,
    this.concluida = false,
  });

  /// Factory constructor para criar uma instância de [Tarefa] a partir de um mapa.
  factory Tarefa.fromMap(String id, Map<String, dynamic> data) {
    return Tarefa(
      id: id,
      titulo: data['titulo'] ?? 'Tarefa sem título',
      dataEntrega: data['dataEntrega'] as Timestamp? ?? Timestamp.now(),
      concluida: data['concluida'] ?? false,
    );
  }
}