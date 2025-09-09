// lib/pages/splash_page.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();
    // Garante que o código só rode depois da primeira renderização
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Escuta a primeira mudança de estado de autenticação para decidir para onde ir.
      _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
        // Garante que a navegação só ocorra uma vez
        _authSubscription.cancel();
        if (mounted) {
          if (user == null) {
            // Se não há usuário, vai para a tela de login
            context.go('/login');
          } else {
            // Se há usuário, vai para a tela inicial
            context.go('/inicio');
          }
        }
      });
    });
  }

  @override
  void dispose() {
    // Cancela a inscrição caso a tela seja destruída
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tela de carregamento super simples
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}