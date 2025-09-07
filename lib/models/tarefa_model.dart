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

  // Factory constructor para criar uma Tarefa a partir de um documento do Firestore
  factory Tarefa.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Tarefa(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      dataEntrega: data['dataEntrega'] ?? Timestamp.now(),
      concluida: data['concluida'] ?? false,
    );
  }
}
