// lib/pages/hub_disciplinas_page.dart

import 'package:app_da_poli/components/edit_disciplina_dialog.dart'; // NOVO IMPORT
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/models/user_model.dart'; // IMPORT PARA USER ROLE
import 'package:app_da_poli/pages/disciplina_details_page.dart';
import 'package:app_da_poli/providers/user_provider.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HubDisciplinasPage extends StatefulWidget {
  const HubDisciplinasPage({super.key});

  @override
  State<HubDisciplinasPage> createState() => _HubDisciplinasPageState();
}

class _HubDisciplinasPageState extends State<HubDisciplinasPage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Verifica se o usuário tem cargo de edição
    final bool isAdmin = currentUser.isGremio || currentUser.isRC;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hub de Disciplinas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<List<Disciplina>>(
        stream: _firestoreService.getTodasAsDisciplinas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text('Erro ao carregar as disciplinas.'));
          
          final disciplinas = snapshot.data ?? [];
          if (disciplinas.isEmpty) return const Center(child: Text('Nenhuma disciplina criada ainda.', style: TextStyle(fontSize: 16, color: Colors.grey)));

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: disciplinas.length,
            itemBuilder: (context, index) {
              final disciplina = disciplinas[index];
              final bool jaInscrito = currentUser.turmasIds.contains(disciplina.id);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => DisciplinaDetailsPage(disciplina: disciplina)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: disciplina.cor.withAlpha(50),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(disciplina.codigo, style: TextStyle(color: disciplina.cor, fontWeight: FontWeight.bold)),
                            ),
                            
                            // CANTO SUPERIOR DIREITO: Ícones e Botão de Edição
                            Row(
                              children: [
                                if (disciplina.isVerificada)
                                  const Icon(Icons.verified, color: Colors.blue, size: 22)
                                else
                                  const Icon(Icons.pending_actions, color: Colors.orange, size: 22),
                                
                                if (isAdmin) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.edit_note, color: Colors.black87),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Editar Disciplina',
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => EditDisciplinaDialog(disciplina: disciplina),
                                      );
                                    },
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(disciplina.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Depto: ${disciplina.departamento} • ${disciplina.numeroInscritos} alunos', style: TextStyle(color: Colors.grey[700])),
                        const SizedBox(height: 16),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: jaInscrito
                                ? null
                                : () async {
                                    await _firestoreService.inscreverEmDisciplina(disciplina.id);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Inscrito em ${disciplina.codigo} com sucesso!')));
                                  },
                            icon: Icon(jaInscrito ? Icons.check : Icons.add),
                            label: Text(jaInscrito ? 'Já Inscrito' : 'Inscrever-se'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: jaInscrito ? Colors.green : const Color(0xFF0460E9),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.green.withAlpha(150),
                              disabledForegroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}