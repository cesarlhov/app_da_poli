// lib/pages/avisos_page.dart

import 'package:app_da_poli/providers/avisos_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AvisosPage extends StatelessWidget {
  const AvisosPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Escuta o nosso provedor local de avisos
    final avisosProvider = context.watch<AvisosProvider>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Interações', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInteractionButton(context, icon: Icons.forum_outlined, label: 'Fórum da Comunidade', onPressed: () => context.push('/forum')),
            const SizedBox(height: 12),
            _buildInteractionButton(context, icon: Icons.chat_bubble_outline, label: 'Chat Acadêmico com IA', onPressed: () => context.push('/chat')),
            const Divider(height: 40),
            const Text('Mural de Avisos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Passamos o provider para extrair a lista
            Expanded(
              child: _buildAvisosList(avisosProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvisosList(AvisosProvider provider) {
    // Se o provedor diz que está carregando, mostramos o indicador
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final avisos = provider.avisos;

    if (avisos.isEmpty) {
      return const Center(
        child: Text('Nenhum aviso no momento.', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }
    
    return ListView.builder(
      itemCount: avisos.length,
      itemBuilder: (context, index) {
        final aviso = avisos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            title: Text(aviso.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(aviso.conteudo),
            trailing: Text(DateFormat('dd/MM').format(aviso.data.toDate()), style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        );
      },
    );
  }

  Widget _buildInteractionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}