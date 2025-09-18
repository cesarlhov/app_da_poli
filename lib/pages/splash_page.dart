// lib/pages/splash_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A primeira tela exibida ao abrir o app.
/// Sua única responsabilidade é verificar o estado de autenticação do usuário
/// e redirecioná-lo para a tela de Login ou para a Home (`/inicio`).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  /// Verifica o usuário atual e redireciona para a rota apropriada.
  Future<void> _redirect() async {
    // Aguarda um frame para garantir que o contexto e o GoRouter estejam prontos.
    await Future.delayed(Duration.zero);

    if (mounted) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        context.go('/login');
      } else {
        context.go('/inicio');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Exibe um indicador de carregamento enquanto a verificação ocorre.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}