// lib/pages/hub_disciplinas_page.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/models/user_model.dart'; 
import 'package:app_da_poli/pages/disciplina_details_page.dart';
import 'package:app_da_poli/providers/user_provider.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                            
                            Row(
                              children: [
                                if (disciplina.isVerificada)
                                  const Icon(Icons.verified, color: Colors.blue, size: 22)
                                else ...[
                                  const Icon(Icons.pending_actions, color: Colors.orange, size: 22),
                                  
                                  // 🟢 SE FOR GRÊMIO/ADMIN, MOSTRA O BOTÃO DE APROVAR!
                                  if (currentUser.isGremio)
                                    IconButton(
                                      icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 26),
                                      tooltip: 'Aprovar Disciplina',
                                      onPressed: () async {
                                        await _firestoreService.aprovarDisciplina(disciplina.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disciplina aprovada e visível para todos!'), backgroundColor: Colors.green));
                                        }
                                      },
                                    ),
                                ],
                                
                                // 🟢 BOTAO DE EDITAR (Disponível para Grêmio e RC)
                                if (isAdmin) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.edit_note, color: Colors.black87),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Editar Disciplina',
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('A edição será feita pela nova tela em breve!')),
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
                        
                        // 🟢 BOTÃO DE INSCREVER / DESMATRICULAR
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final mensageiro = ScaffoldMessenger.of(context); 
                              if (jaInscrito) {
                                await _firestoreService.desmatricularDeDisciplina(disciplina.id);
                                mensageiro.showSnackBar(SnackBar(content: Text('Matrícula cancelada em ${disciplina.codigo}'), backgroundColor: Colors.orange));
                              } else {
                                await _firestoreService.inscreverEmDisciplina(disciplina.id);
                                mensageiro.showSnackBar(SnackBar(content: Text('Inscrito em ${disciplina.codigo}'), backgroundColor: Colors.green));
                              }
                            },
                            icon: Icon(jaInscrito ? Icons.remove_circle_outline : Icons.add),
                            label: Text(jaInscrito ? 'Desmatricular' : 'Inscrever-se'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: jaInscrito ? Colors.red : const Color(0xFF0460E9),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        
                        // 🟢 BOTÃO DE APROVAÇÃO DIRETO NO APP (APENAS PARA O GRÊMIO)
                        if (!disciplina.isVerificada && currentUser.isGremio) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await FirebaseFirestore.instance.collection('disciplinas').doc(disciplina.id).update({'isVerificada': true});
                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disciplina Aprovada!'), backgroundColor: Colors.green));
                              },
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Aprovar Oficialmente'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            ),
                          ),
                        ]
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