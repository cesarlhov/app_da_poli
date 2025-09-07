import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/models/user_model.dart';
import 'package:app_da_poli/services/curso_service.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:app_da_poli/views/active_disciplinas_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//-------------------------------------------------
// TELA DE PERFIL DO UTILIZADOR (COM DADOS REAIS)
//-------------------------------------------------
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final FirestoreService _firestoreService = FirestoreService();
  final CursoService _cursoService = CursoService(); // O nosso novo serviço de dados do curso

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black54),
            onPressed: _signOut,
            tooltip: 'Configurações e Sair',
          ),
        ],
      ),
      // StreamBuilder principal para os dados do perfil
      body: StreamBuilder<AppUser?>(
        stream: _firestoreService.getUserProfile(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text('Não foi possível carregar o perfil.'));
          }

          final user = userSnapshot.data!;

          // StreamBuilder secundário para as disciplinas (para calcular o progresso)
          return StreamBuilder<List<Disciplina>>(
            stream: _firestoreService.getDisciplinas(),
            builder: (context, disciplinasSnapshot) {
              
              final int disciplinasConcluidas = disciplinasSnapshot.data?.length ?? 0;
              final int totalDisciplinasCurso = _cursoService.getTotalDisciplinas();
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
                    Text(
                      user.nome,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.curso,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Progresso no Curso',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progresso,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF003366)),
                    ),
                    const SizedBox(height: 8),
                    // Exibe os dados de progresso reais
                    Text(
                      '${(progresso * 100).toStringAsFixed(1)}% concluído ($disciplinasConcluidas de $totalDisciplinasCurso)',
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ActiveDisciplinasPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.library_books_outlined),
                        label: const Text('Disciplinas Ativas'),
                      ),
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
}

