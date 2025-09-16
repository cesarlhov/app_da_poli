// lib/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Acadêmico'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Lógica de pesquisa (desativada por enquanto)
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Página do Chat com IA em construção!'),
      ),
    );
  }
}