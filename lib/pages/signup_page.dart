// lib/pages/signup_page.dart

import 'package:app_da_poli/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//-------------------------------------------------
// TELA DE CRIAR CONTA (COM CRIAÇÃO DE PERFIL)
//-------------------------------------------------
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cursoController = TextEditingController();
  final _nuspController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As senhas não coincidem.')),
        );
        return;
      }

      setState(() { _isLoading = true; });

      try {
        // 1. Cria o utilizador na Autenticação do Firebase
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // 2. Se for bem-sucedido, cria o perfil no Firestore
        if (userCredential.user != null) {
          // <<< ADICIONADO TRATAMENTO DE ERROS DETALHADO >>>
          try {
            print("--- DEBUG: A tentar criar perfil para o utilizador: ${userCredential.user!.uid}");
            await _firestoreService.createUserProfile(
              userCredential.user!,
              _nomeController.text.trim(),
              _cursoController.text.trim(),
              _nuspController.text.trim(),
            );
            print("--- DEBUG: Perfil criado com sucesso no Firestore!");
            if (mounted) Navigator.of(context).pop();
          } catch (e) {
            // Se falhar, mostra o erro exato na consola e na tela
            print("--- DEBUG: ERRO AO CRIAR PERFIL NO FIRESTORE: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("ERRO AO GUARDAR DADOS: $e"),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 10), // Dura mais tempo para poder ler
              ),
            );
          }
        }

      } on FirebaseAuthException catch (e) {
        String message = 'Ocorreu um erro no registo.';
        if (e.code == 'weak-password') {
          message = 'A senha é muito fraca.';
        } else if (e.code == 'email-already-in-use') {
          message = 'Este e-mail já está a ser utilizado.';
        }
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      } finally {
        if (mounted) setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Nova Conta'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(labelText: 'Nome Completo'),
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                   TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cursoController,
                    decoration: const InputDecoration(labelText: 'Curso'),
                     validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nuspController,
                    decoration: const InputDecoration(labelText: 'Número USP'),
                    keyboardType: TextInputType.number,
                     validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                     validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(labelText: 'Confirmar Senha'),
                    obscureText: true,
                     validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,))
                      : const Text('Cadastrar', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

