import 'package:cloud_firestore/cloud_firestore.dart';

// Este ficheiro define a estrutura de dados para um Aviso.
class Aviso {
  final String id;
  final String titulo;
  final String conteudo;
  final Timestamp data; // Usamos Timestamp para datas do Firebase

  Aviso({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.data,
  });

  // Factory constructor para criar um Aviso a partir de um documento do Firestore
  factory Aviso.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Aviso(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      conteudo: data['conteudo'] ?? '',
      data: data['data'] ?? Timestamp.now(),
    );
  }
}
