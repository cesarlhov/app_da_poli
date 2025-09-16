// lib/pages/login_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Garanta que este import existe

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _signIn() async {
    // Exibe um círculo de carregamento
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Se o login for bem-sucedido, fecha o dialog e navega
      if (mounted) {
        context.pop(); // Fecha o círculo de carregamento
        context.go('/inicio'); // <<< LINHA ADICIONADA: Navega para a tela inicial
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        context.pop(); // Fecha o círculo de carregamento
        // Mostra uma mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Erro desconhecido')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // O resto do seu código da tela de login continua aqui...
    // Apenas a função _signIn() foi modificada.
    return Scaffold(
      // ... seu widget de build
    );
  }
}