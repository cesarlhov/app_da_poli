// lib/pages/signup_page.dart

import 'package:app_da_poli/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Página para o usuário criar uma nova conta e perfil.
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

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cursoController.dispose();
    _nuspController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Valida o formulário e tenta criar uma nova conta e perfil de usuário.
  Future<void> _signUp() async {
    // Valida o formulário antes de continuar.
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('As senhas não coincidem.');
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // 1. Cria o usuário no Firebase Authentication.
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Se a criação for bem-sucedida, cria o perfil no Firestore.
      if (userCredential.user != null) {
        await _firestoreService.createUserProfile(
          userCredential.user!,
          _nomeController.text.trim(),
          _cursoController.text.trim(),
          _nuspController.text.trim(),
        );
        
        // Retorna para a página anterior (Login) se a operação for bem-sucedida.
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta criada com sucesso! Você já pode fazer login.'), backgroundColor: Colors.green),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Trata erros específicos do Firebase Auth.
      String message = 'Ocorreu um erro no cadastro.';
      if (e.code == 'weak-password') {
        message = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Este e-mail já está em uso por outra conta.';
      }
      _showErrorSnackBar(message);
    } catch (e) {
      // Trata outros erros (ex: falha ao salvar no Firestore).
      _showErrorSnackBar('Não foi possível salvar os dados do perfil. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }
  
  /// Exibe uma SnackBar de erro.
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
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
                  _buildTextField(controller: _nomeController, label: 'Nome Completo', icon: Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _emailController, label: 'E-mail', icon: Icons.email, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _cursoController, label: 'Curso', icon: Icons.school),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _nuspController, label: 'Número USP', icon: Icons.badge, keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _passwordController, label: 'Senha', icon: Icons.lock, obscureText: true),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _confirmPasswordController, label: 'Confirmar Senha', icon: Icons.lock_outline, obscureText: true),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
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

  /// Widget auxiliar para criar os campos de texto.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
    );
  }
}