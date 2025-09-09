// lib/services/firestore_service.dart

import 'package:app_da_poli/models/aviso_model.dart';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/models/tarefa_model.dart';
import 'package:app_da_poli/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- MÉTODOS DE USUÁRIO ---

  Future<void> createUserProfile(User user, String nome, String curso, String nusp) async {
    final docRef = _db.collection('users').doc(user.uid);
    final data = {
      'nome': nome,
      'email': user.email,
      'curso': curso,
      'nusp': nusp,
      'uid': user.uid,
      'criadoEm': Timestamp.now(),
    };
    await docRef.set(data);
  }

  Stream<AppUser?> getUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);
    final docRef = _db.collection('users').doc(user.uid);
    return docRef.snapshots().map((doc) =>
        doc.exists ? AppUser.fromMap(doc.id, doc.data()!) : null);
  }

  Future<AppUser?> getUserProfileOnce() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final docRef = _db.collection('users').doc(user.uid);
    final docSnapshot = await docRef.get();
    return docSnapshot.exists ? AppUser.fromMap(docSnapshot.id, docSnapshot.data()!) : null;
  }

  // --- MÉTODOS DE DISCIPLINA ---

  Future<void> addDisciplina(Map<String, dynamic> disciplinaData) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final collectionRef = _db.collection('users').doc(user.uid).collection('disciplinas');
    await collectionRef.add(disciplinaData);
  }

  Stream<List<Disciplina>> getDisciplinas() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    final collectionRef = _db.collection('users').doc(user.uid).collection('disciplinas');
    return collectionRef
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => 
            Disciplina.fromMap(doc.id, doc.data())
        ).toList());
  }
  
  Future<List<Disciplina>> getDisciplinasOnce() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    final collectionRef = _db.collection('users').doc(user.uid).collection('disciplinas');
    final snapshot = await collectionRef.get();
    return snapshot.docs.map((doc) => Disciplina.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> deleteDisciplina(String disciplinaId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docRef = _db.collection('users').doc(user.uid).collection('disciplinas').doc(disciplinaId);
    await docRef.delete();
  }

  // --- MÉTODOS DE AVISOS (RESTAURADOS) ---
  Stream<List<Aviso>> getAvisos() {
    final collectionRef =
        _db.collection('avisos').orderBy('data', descending: true);
    // Assumindo que seu Aviso model também tem um construtor fromMap
    return collectionRef
        .snapshots()
        .map((s) => s.docs.map((d) => Aviso.fromMap(d.id, d.data())).toList());
  }

  // --- MÉTODOS DE TAREFAS (RESTAURADOS) ---
  Stream<List<Tarefa>> getTarefas() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    final collectionRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('tarefas')
        .orderBy('dataEntrega');
    // Assumindo que seu Tarefa model também tem um construtor fromMap
    return collectionRef
        .snapshots()
        .map((s) => s.docs.map((d) => Tarefa.fromMap(d.id, d.data())).toList());
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