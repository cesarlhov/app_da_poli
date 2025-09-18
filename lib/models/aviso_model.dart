// lib/models/aviso_model.dart

import 'package:cloud_firestore/cloud_firestore.dart'; // <-- ESTA LINHA CORRIGE OS ERROS

/// Representa um aviso ou comunicado geral no aplicativo.
class Aviso {
  final String id;
  final String titulo;
  final String conteudo;
  final Timestamp data;

  const Aviso({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.data,
  });

  /// Factory constructor para criar uma instância de [Aviso] a partir de um mapa.
  factory Aviso.fromMap(String id, Map<String, dynamic> data) {
    return Aviso(
      id: id,
      titulo: data['titulo'] ?? 'Aviso sem título',
      conteudo: data['conteudo'] ?? '',
      data: data['data'] as Timestamp? ?? Timestamp.now(),
    );
  }
}