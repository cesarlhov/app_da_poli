// lib/views/profile_view.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/models/user_model.dart';
import 'package:app_da_poli/services/curso_service.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// View que exibe o perfil do usuário, progresso no curso e opções.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final cursoService = CursoService();

    void signOut() async {
      await FirebaseAuth.instance.signOut();
      // Após o logout, redireciona para a tela de login.
      if (context.mounted) context.go('/login');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Perfil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: signOut,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: StreamBuilder<AppUser?>(
        stream: firestoreService.getUserProfile(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text('Não foi possível carregar o perfil.'));
          }
          final user = userSnapshot.data!;

          return StreamBuilder<List<Disciplina>>(
            stream: firestoreService.getDisciplinas(),
            builder: (context, disciplinasSnapshot) {
              final int disciplinasConcluidas = disciplinasSnapshot.data?.length ?? 0;
              final int totalDisciplinasCurso = cursoService.getTotalDisciplinas();
              final double progresso = totalDisciplinasCurso > 0
                  ? disciplinasConcluidas / totalDisciplinasCurso
                  : 0.0;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(user.nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text(user.curso, style: const TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                    _buildProgressBar(
                      'Progresso no Curso',
                      progresso,
                      '$disciplinasConcluidas de $totalDisciplinasCurso disciplinas',
                    ),
                    const SizedBox(height: 40),
                    _buildProfileButton(
                      context,
                      label: 'Minhas Disciplinas',
                      icon: Icons.library_books_outlined,
                      onPressed: () => context.push('/active-disciplinas'), // Rota a ser criada
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Widget auxiliar para a barra de progresso.
  Widget _buildProgressBar(String title, double value, String subtitle) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: value,
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D41A9)),
        ),
        const SizedBox(height: 8),
        Text(subtitle),
      ],
    );
  }

  /// Widget auxiliar para botões de ação do perfil.
  Widget _buildProfileButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}