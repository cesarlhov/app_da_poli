// lib/services/firestore_service.dart

import 'package:app_da_poli/models/aviso_model.dart';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/models/tarefa_model.dart';
import 'package:app_da_poli/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Uma classe de serviço para centralizar todas as interações com o Cloud Firestore.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- MÉTODOS DE USUÁRIO ---

  /// Cria um novo documento de perfil para o usuário no Firestore.
  Future<void> createUserProfile(User user, String nome, String curso, String nusp) async {
    return _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'nome': nome,
      'email': user.email,
      'curso': curso,
      'nusp': nusp,
      'criadoEm': FieldValue.serverTimestamp(), // Usa o timestamp do servidor
    });
  }

  /// Retorna um Stream com o perfil do usuário logado, atualizado em tempo real.
  Stream<AppUser?> getUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _db.collection('users').doc(user.uid).snapshots().map(
          (doc) => doc.exists ? AppUser.fromMap(doc.id, doc.data()!) : null,
        );
  }

  /// Retorna uma única instância (Future) do perfil do usuário logado.
  Future<AppUser?> getUserProfileOnce() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final docSnapshot = await _db.collection('users').doc(user.uid).get();
    return docSnapshot.exists ? AppUser.fromMap(docSnapshot.id, docSnapshot.data()!) : null;
  }

  // --- MÉTODOS DE DISCIPLINA ---

  /// Adiciona uma nova disciplina à subcoleção do usuário.
  Future<void> addDisciplina(Map<String, dynamic> disciplinaData) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).collection('disciplinas').add(disciplinaData);
    }
  }
  
  /// Retorna um Stream com a lista de disciplinas do usuário, atualizada em tempo real.
  Stream<List<Disciplina>> getDisciplinas() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('disciplinas')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Disciplina.fromMap(doc.id, doc.data()))
            .toList());
  }
  
  /// Retorna uma única instância (Future) da lista de disciplinas do usuário.
  Future<List<Disciplina>> getDisciplinasOnce() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    final snapshot = await _db.collection('users').doc(user.uid).collection('disciplinas').get();
    return snapshot.docs.map((doc) => Disciplina.fromMap(doc.id, doc.data())).toList();
  }

  /// Deleta uma disciplina específica da subcoleção do usuário.
  Future<void> deleteDisciplina(String disciplinaId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).collection('disciplinas').doc(disciplinaId).delete();
    }
  }

  // --- MÉTODOS DE TAREFAS ---

  /// Adiciona uma nova tarefa à subcoleção do usuário.
  Future<void> addTarefa(String titulo, DateTime dataEntrega) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).collection('tarefas').add({
        'titulo': titulo,
        'dataEntrega': Timestamp.fromDate(dataEntrega),
        'concluida': false,
      });
    }
  }

  /// Retorna um Stream com a lista de tarefas do usuário, ordenada por data.
  Stream<List<Tarefa>> getTarefas() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('tarefas')
        .orderBy('dataEntrega')
        .snapshots()
        .map((s) => s.docs.map((d) => Tarefa.fromMap(d.id, d.data())).toList());
  }
  
  /// Atualiza o estado de 'concluída' de uma tarefa.
  Future<void> updateTarefa(String tarefaId, bool concluida) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).collection('tarefas').doc(tarefaId).update({'concluida': concluida});
    }
  }
  
  // --- MÉTODOS DE AVISOS ---

  /// Retorna um Stream com a lista de avisos globais, ordenada por data.
  Stream<List<Aviso>> getAvisos() {
    return _db
        .collection('avisos')
        .orderBy('data', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Aviso.fromMap(d.id, d.data())).toList());
  }
}