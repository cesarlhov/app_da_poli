// lib/views/active_disciplinas_page.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';

//-------------------------------------------------
// PÁGINA PARA EXIBIR AS DISCIPLINAS ATIVAS DO UTILIZADOR
//-------------------------------------------------
class ActiveDisciplinasPage extends StatefulWidget {
  const ActiveDisciplinasPage({super.key});

  @override
  State<ActiveDisciplinasPage> createState() => _ActiveDisciplinasPageState();
}

class _ActiveDisciplinasPageState extends State<ActiveDisciplinasPage> {
  // Instância do nosso serviço de Firestore
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Disciplinas Ativas'),
      ),
      body: StreamBuilder<List<Disciplina>>(
        // Ouve o stream de disciplinas do nosso serviço
        stream: _firestoreService.getDisciplinas(),
        builder: (context, snapshot) {
          // Se estiver a carregar os dados, mostra um círculo de progresso
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Se ocorrer um erro
          if (snapshot.hasError) {
            return const Center(
                child: Text('Ocorreu um erro ao carregar as disciplinas.'));
          }
          // Se não houver dados ou a lista estiver vazia
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma disciplina adicionada ainda.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Se tivermos dados, construímos a lista
          final disciplinas = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: disciplinas.length,
            itemBuilder: (context, index) {
              final disciplina = disciplinas[index];
              // Usamos um Card para um visual mais apelativo
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(disciplina.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${disciplina.codigo}\nProf. ${disciplina.professor} - Sala: ${disciplina.sala}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    // Futuramente, pode levar a uma tela de detalhes da disciplina
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
