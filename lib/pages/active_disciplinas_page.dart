// lib/pages/active_disciplinas_page.dart

import 'package:app_da_poli/providers/disciplinas_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActiveDisciplinasPage extends StatelessWidget {
  const ActiveDisciplinasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final disciplinasProvider = context.watch<DisciplinasProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Disciplinas'),
      ),
      body: _buildBody(disciplinasProvider),
    );
  }

  Widget _buildBody(DisciplinasProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final disciplinas = provider.disciplinas;

    if (disciplinas.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma disciplina adicionada ainda.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: disciplinas.length,
      itemBuilder: (context, index) {
        final disciplina = disciplinas[index];
        // Atualização para docentes
        String nomeProfessor = disciplina.docentes.isNotEmpty ? disciplina.docentes.first : 'Sem professor';

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
            // Atualizado "sala" para "local" e professor
            subtitle: Text('${disciplina.codigo}\nProf. $nomeProfessor - Local: ${disciplina.local}'),
            isThreeLine: true,
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {},
          ),
        );
      },
    );
  }
}