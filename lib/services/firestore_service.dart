// lib/services/firestore_service.dart

import 'package:app_da_poli/models/aviso_model.dart';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/models/progresso_model.dart';
import 'package:app_da_poli/models/tarefa_model.dart';
import 'package:app_da_poli/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================================================================
  // --- MÉTODOS DE USUÁRIO ---
  // =========================================================================

  Future<void> createUserProfile(User user, String nome, String curso, String nusp) async {
    return _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'nomeCompleto': nome,
      'nomeUsuario': '', 
      'email': user.email,
      'curso': curso,
      'numeroUSP': nusp,
      'isGremio': false,
      'isRC': false,
      'turmasIds': [],
      'amigosIds': [],
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> uploadFotoPerfil(File imageFile) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // 1. Sobe a foto para o Firebase Storage na pasta 'perfil_fotos'
        final storageRef = FirebaseStorage.instance.ref().child('perfil_fotos/${user.uid}.jpg');
        await storageRef.putFile(imageFile);

        // 2. Pega a URL pública da foto
        final String downloadUrl = await storageRef.getDownloadURL();

        // 3. Atualiza o banco de dados do usuário (Isso vai disparar o Provider para atualizar a tela!)
        await _db.collection('users').doc(user.uid).update({'fotoUrl': downloadUrl});
      } catch (e) {
        throw Exception('Erro ao fazer upload da foto: $e');
      }
    }
  }

  Stream<UserModel?> getUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);
    return _db.collection('users').doc(user.uid).snapshots().map(
          (doc) => doc.exists ? UserModel.fromMap(doc.data()!, doc.id) : null,
    );
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).update(data);
    }
  }

  // =========================================================================
  // --- MÉTODOS DE DISCIPLINAS GLOBAIS ---
  // =========================================================================

  /// Grêmio/Admin cria uma nova disciplina oficial para toda a Poli
  Future<void> createDisciplinaGlobal(Disciplina disciplina) async {
    final docRef = _db.collection('disciplinas').doc(); // Gera ID automático
    await docRef.set(disciplina.toMap());
  }

  /// Atualiza os dados de uma disciplina global existente
  Future<void> updateDisciplinaGlobal(String id, Map<String, dynamic> dadosAtualizados) async {
    await _db.collection('disciplinas').doc(id).update(dadosAtualizados);
  }

  /// Puxa a vitrine de todas as disciplinas verificadas para os alunos procurarem
  Stream<List<Disciplina>> getDisciplinasGlobais() {
    return _db
        .collection('disciplinas')
        .where('isVerificada', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Disciplina.fromMap(doc.id, doc.data()))
        .toList());
  }

  /// Puxa TODAS as disciplinas (Usado pelo Hub / Admins)
  Stream<List<Disciplina>> getTodasAsDisciplinas() {
    return _db
        .collection('disciplinas')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Disciplina.fromMap(doc.id, doc.data()))
        .toList());
  }

  // =========================================================================
  // --- MÉTODOS DE PROGRESSO E MATEMÁTICA DO ALUNO ---
  // =========================================================================

  /// O aluno se inscreve na matéria. Usamos Batch para garantir consistência.
  Future<void> inscreverEmDisciplina(String disciplinaId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _db.batch();

    // 1. Adiciona o ID na lista de turmas do perfil do usuário
    final userRef = _db.collection('users').doc(user.uid);
    batch.update(userRef, {
      'turmasIds': FieldValue.arrayUnion([disciplinaId])
    });

    // 2. Incrementa o número global de inscritos na disciplina
    final disciplinaRef = _db.collection('disciplinas').doc(disciplinaId);
    batch.update(disciplinaRef, {
      'numeroInscritos': FieldValue.increment(1)
    });

    // 3. Cria o espelho de Progresso (Notas e Faltas) zerado
    final progressoRef = userRef.collection('progresso_disciplinas').doc(disciplinaId);
    batch.set(progressoRef, {
      'isFavorita': false,
      'notasPreenchidas': {},
      'formulaPersonalizada': '',
      'tentativasAnteriores': [],
      'faltasRegistradas': 0,
    });

    await batch.commit(); // Executa tudo de uma vez
  }

  /// Ouve em tempo real as notas e faltas de todas as matérias que o aluno cursa
  Stream<List<ProgressoDisciplina>> getMeusProgressos() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('progresso_disciplinas')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ProgressoDisciplina.fromMap(doc.id, doc.data()))
        .toList());
  }

  /// Atualiza as notas ou faltas do aluno. O Provider cuidará de avisar a tela (70% MEC)
  Future<void> updateProgressoDisciplina(String disciplinaId, Map<String, dynamic> dadosAtualizados) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('progresso_disciplinas')
          .doc(disciplinaId)
          .update(dadosAtualizados);
    }
  }

  // =========================================================================
  // --- MÉTODOS DE TAREFAS ---
  // =========================================================================

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

  Future<void> updateTarefa(String tarefaId, bool concluida) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).collection('tarefas').doc(tarefaId).update({'concluida': concluida});
    }
  }

  // =========================================================================
  // --- MÉTODOS DE AVISOS GERAIS ---
  // =========================================================================

  Stream<List<Aviso>> getAvisos() {
    return _db
        .collection('avisos')
        .orderBy('data', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Aviso.fromMap(d.id, d.data())).toList());
  }

  /// Registra presença ou falta em um dia específico no histórico do aluno
  Future<void> registrarPresenca(String disciplinaId, String dataIso, bool presente) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('progresso_disciplinas')
          .doc(disciplinaId)
          .update({
        // Atualiza apenas a data específica dentro do mapa historicoPresenca
        'historicoPresenca.$dataIso': presente,
      });
    }
  }

  /// Atualiza as notas preenchidas pelo aluno em uma disciplina específica
  Future<void> atualizarNotas(String disciplinaId, Map<String, double?> notasPreenchidas) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('progresso_disciplinas')
          .doc(disciplinaId)
          .set({
        'notasPreenchidas': notasPreenchidas,
      }, SetOptions(merge: true)); // Usa merge para garantir que não sobrescreve o resto do progresso
    }
  }
  Future<void> atualizarFotoPerfilUrl(String fotoUrl) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).update({
        'fotoUrl': fotoUrl,
      });
    }
  }
  // =========================================================================
  // --- MÉTODOS DE ADMINISTRAÇÃO E APROVAÇÃO ---
  // =========================================================================

  /// Puxa todos os usuários do aplicativo para o painel de admin
  Stream<List<UserModel>> getTodosUsuarios() {
    return _db.collection('users').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  /// Altera o cargo de qualquer usuário (Admin e Grêmio usam isso)
  Future<void> atualizarCargoUsuario(String uid, String novoCargo) async {
    await _db.collection('users').doc(uid).update({'role': novoCargo});
  }

  /// O Grêmio clica nisso para validar uma disciplina sugerida por um RC
  Future<void> aprovarDisciplina(String disciplinaId) async {
    await _db.collection('disciplinas').doc(disciplinaId).update({'isVerificada': true});
  }

  // 🟢 NOVO: Função para o aluno se desmatricular de uma disciplina
  Future<void> desmatricularDeDisciplina(String disciplinaId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final batch = _db.batch();

    // 1. Remove a ID da lista de turmas
    final userRef = _db.collection('users').doc(user.uid);
    batch.update(userRef, {
      'turmasIds': FieldValue.arrayRemove([disciplinaId])
    });

    // 2. Decrementa o número global de inscritos
    final disciplinaRef = _db.collection('disciplinas').doc(disciplinaId);
    batch.update(disciplinaRef, {
      'numeroInscritos': FieldValue.increment(-1)
    });

    // 3. Deleta o espelho de Progresso (Diário de bordo) do aluno
    final progressoRef = userRef.collection('progresso_disciplinas').doc(disciplinaId);
    batch.delete(progressoRef);

    await batch.commit(); // Executa tudo
  }
}