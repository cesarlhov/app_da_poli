// lib/pages/forum_page.dart

import 'package:flutter/material.dart';

/// Página para o fórum da comunidade (atualmente em construção).
class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fórum da Comunidade'),
        // O GoRouter adiciona o botão de voltar automaticamente quando a página
        // não faz parte do Shell principal.
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Fórum em construção!',
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}