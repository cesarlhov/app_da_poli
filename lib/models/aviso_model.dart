// lib/models/aviso_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Este ficheiro define a estrutura de dados para um Aviso.
class Aviso {
  final String id;
  final String titulo;
  final String conteudo;
  final Timestamp data;

  Aviso({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.data,
  });

  // --- MUDANÇA: Renomeado de fromFirestore para fromMap e parâmetros atualizados ---
  factory Aviso.fromMap(String id, Map<String, dynamic> data) {
    return Aviso(
      id: id,
      titulo: data['titulo'] ?? '',
      conteudo: data['conteudo'] ?? '',
      data: data['data'] ?? Timestamp.now(),
    );
  }
}