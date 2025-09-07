import 'package:cloud_firestore/cloud_firestore.dart';

// Este ficheiro define a estrutura de dados para o perfil de um utilizador.
class AppUser {
  final String uid;
  final String nome;
  final String email;
  final String curso;
  final String nusp; // <-- 1. Adicionado o campo que faltava

  AppUser({
    required this.uid,
    required this.nome,
    required this.email,
    required this.curso,
    required this.nusp, // <-- 2. Adicionado ao construtor
  });

  // Factory constructor para criar um AppUser a partir de um documento do Firestore
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      curso: data['curso'] ?? 'Não definido',
      nusp: data['nusp'] ?? '', // <-- 3. Adicionado o leitor do Firestore
    );
  }
}

