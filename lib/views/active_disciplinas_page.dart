// lib/views/active_disciplinas_page.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';

/// Uma página que exibe a lista de disciplinas que o usuário cadastrou.
class ActiveDisciplinasPage extends StatelessWidget {
  const ActiveDisciplinasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Disciplinas'),
      ),
      body: StreamBuilder<List<Disciplina>>(
        stream: firestoreService.getDisciplinas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Ocorreu um erro ao carregar as disciplinas.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma disciplina adicionada ainda.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final disciplinas = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0), // Reduzido o padding para um visual mais compacto
            itemCount: disciplinas.length,
            itemBuilder: (context, index) {
              final disciplina = disciplinas[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: disciplina.cor,
                    child: Text(
                      disciplina.codigo.isNotEmpty ? disciplina.codigo[0] : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(disciplina.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${disciplina.codigo}\nProf. ${disciplina.professor} - Sala: ${disciplina.sala}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    // Futuramente, pode levar a uma tela de detalhes da disciplina.
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}