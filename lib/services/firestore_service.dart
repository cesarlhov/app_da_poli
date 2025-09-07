import 'package:app_da_poli/models/aviso_model.dart';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/models/tarefa_model.dart';
import 'package:app_da_poli/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- MÉTODOS DE UTILIZADOR ---
  
  // <<< MÉTODO ATUALIZADO ABAIXO >>>
  // Cria o documento de dados do perfil para um novo utilizador
  Future<void> createUserProfile(User user, String nome, String curso, String nusp) async {
    final docRef = _db.collection('users').doc(user.uid);
    final data = {
      'nome': nome,
      'email': user.email,
      'curso': curso,
      'nusp': nusp, // <-- Adicionado o N.º USP
      'uid': user.uid,
      'criadoEm': Timestamp.now(),
    };
    await docRef.set(data);
  }

  // Obtém os dados do perfil do utilizador logado
  Stream<AppUser?> getUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);
    final docRef = _db.collection('users').doc(user.uid);
    return docRef.snapshots().map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);
  }

  // --- MÉTODOS DE DISCIPLINA ---
  Future<void> addDisciplina(Disciplina disciplina) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final collectionRef =
        _db.collection('users').doc(user.uid).collection('disciplinas');
    final data = {
      'nome': disciplina.nome,
      'codigo': disciplina.codigo,
      'professor': disciplina.professor,
      'sala': disciplina.sala,
      'diasDaSemana': disciplina.diasDaSemana,
      'horarioInicio': disciplina.horarioInicio,
      'horarioFim': disciplina.horarioFim,
    };
    await collectionRef.add(data);
  }

  Stream<List<Disciplina>> getDisciplinas() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    final collectionRef =
        _db.collection('users').doc(user.uid).collection('disciplinas');
    return collectionRef
        .snapshots()
        .map((s) => s.docs.map((d) => Disciplina.fromFirestore(d)).toList());
  }

  Future<void> deleteDisciplina(String disciplinaId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('disciplinas')
        .doc(disciplinaId);
    await docRef.delete();
  }

  // --- MÉTODOS DE AVISOS ---
  Stream<List<Aviso>> getAvisos() {
    final collectionRef =
        _db.collection('avisos').orderBy('data', descending: true);
    return collectionRef
        .snapshots()
        .map((s) => s.docs.map((d) => Aviso.fromFirestore(d)).toList());
  }

  // --- MÉTODOS DE TAREFAS ---
  Stream<List<Tarefa>> getTarefas() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    final collectionRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('tarefas')
        .orderBy('dataEntrega');
    return collectionRef
        .snapshots()
        .map((s) => s.docs.map((d) => Tarefa.fromFirestore(d)).toList());
  }

  Future<void> addTarefa(String titulo, DateTime dataEntrega) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final collectionRef =
        _db.collection('users').doc(user.uid).collection('tarefas');
    final data = {
      'titulo': titulo,
      'dataEntrega': Timestamp.fromDate(dataEntrega),
      'concluida': false,
    };
    await collectionRef.add(data);
  }

  Future<void> updateTarefa(String tarefaId, bool concluida) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('tarefas')
        .doc(tarefaId);
    await docRef.update({'concluida': concluida});
  }
}

