// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String nome;
  final String email;
  final String curso;
  final String nusp;

  AppUser({
    required this.uid,
    required this.nome,
    required this.email,
    required this.curso,
    required this.nusp,
  });

  // --- MUDANÇA: Renomeado de fromFirestore para fromMap ---
  // Agora ele segue o mesmo padrão do nosso Disciplina model.
  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      uid: id, // Usamos o id do documento como uid
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      curso: data['curso'] ?? 'Não definido',
      nusp: data['nusp'] ?? '',
    );
  }
}