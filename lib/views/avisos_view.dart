// lib/views/avisos_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AvisosView extends StatelessWidget {
  const AvisosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos e Interações'),
        automaticallyImplyLeading: false, // Remove a seta de voltar padrão
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.forum_outlined),
              label: const Text('Fórum da Comunidade'),
              onPressed: () {
                context.go('/forum');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Chat Acadêmico com IA'),
              onPressed: () {
                context.go('/chat');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const Divider(height: 40),
            // Aqui você pode adicionar a lista de avisos normalmente
            const Center(child: Text('Nenhum aviso no momento.')),
          ],
        ),
      ),
    );
  }
}