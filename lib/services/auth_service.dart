// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_da_poli/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Devolve quem é o usuário logado
  User? get currentUser => _auth.currentUser;

  // ========================================================
  // 1. FAZER LOGIN
  // ========================================================
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      String erro = 'Erro ao entrar. Tente novamente.';
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        erro = 'Nenhuma conta encontrada com este e-mail.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        erro = 'A senha está incorreta.';
      }
      throw Exception(erro);
    } catch (e) {
      throw Exception('Credenciais incorretas ou erro de rede.');
    }
  }

  // ========================================================
  // 2. CRIAR CONTA E PERFIL NO BANCO
  // ========================================================
  Future<UserCredential> signUp(String email, String password, String nome, String curso, String nusp) async {
    try {
      // 1. Cria a conta no Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      // 2. Cria a pasta do aluno no banco de dados Firestore
      if (cred.user != null) {
        await _firestoreService.createUserProfile(cred.user!, nome, curso, nusp);
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      String erro = 'Ocorreu um erro no cadastro.';
      if (e.code == 'weak-password') {
        erro = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        erro = 'Este e-mail já está em uso por outra conta.';
      }
      throw Exception(erro);
    } catch (e) {
      throw Exception('Não foi possível salvar os dados do perfil. Tente novamente.');
    }
  }

  // ========================================================
  // 3. RECUPERAR SENHA
  // ========================================================
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String erro = 'Erro ao enviar email. Tente novamente.';
      if (e.code == 'user-not-found') {
        erro = 'Nenhum usuário encontrado com este e-mail.';
      } else if (e.code == 'invalid-email') {
        erro = 'O formato do e-mail é inválido.';
      }
      throw Exception(erro);
    }
  }

  // ========================================================
  // 4. DESLOGAR
  // ========================================================
  Future<void> signOut() async {
    await _auth.signOut();
  }
}