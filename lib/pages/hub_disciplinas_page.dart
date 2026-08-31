// lib/pages/hub_disciplinas_page.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/models/user_model.dart'; 
import 'package:app_da_poli/pages/disciplina_details_page.dart';
import 'package:app_da_poli/providers/user_provider.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_da_poli/pages/criar_disciplina_page.dart';

class HubDisciplinasPage extends StatefulWidget {
  const HubDisciplinasPage({super.key});

  @override
  State<HubDisciplinasPage> createState() => _HubDisciplinasPageState();
}

class _HubDisciplinasPageState extends State<HubDisciplinasPage> {
  final FirestoreService _firestoreService = FirestoreService();

  void _matricularNaDisciplina(BuildContext context, Disciplina disciplina, UserModel currentUser) {
    if (disciplina.turmas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Esta disciplina ainda não tem turmas cadastradas.')));
      return;
    }

    if (disciplina.turmas.length == 1) {
      setState(() => currentUser.turmasIds.add(disciplina.turmas.first.id));
      _firestoreService.matricular(disciplina.id, disciplina.turmas.first.id); 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Matriculado com sucesso!'), backgroundColor: Colors.green));
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Escolha sua Turma', style: TextStyle(fontFamily: 'LeagueSpartan', fontWeight: FontWeight.w900, color: Color(0xFF162038))),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: disciplina.turmas.length,
              itemBuilder: (context, index) {
                final turma = disciplina.turmas[index];
                String resumo = turma.horarios.map((h) => '${h.dia} ${h.inicio}').join(' | ');
                
                return ListTile(
                  title: Text(turma.codigo.isEmpty ? 'Turma ${index + 1}' : 'Turma ${turma.codigo}', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Aristotelica')),
                  subtitle: Text(resumo, style: const TextStyle(fontFamily: 'Lato', fontSize: 13)),
                  trailing: const Icon(Icons.add_circle, color: Color(0xFF0460E9)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    setState(() => currentUser.turmasIds.add(turma.id));
                    await _firestoreService.matricular(disciplina.id, turma.id); 
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Matriculado com sucesso!'), backgroundColor: Colors.green));
                    }
                  },
                );
              }
            )
          )
        )
      );
    }
  }

 @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
              final bool jaInscrito = currentUser.turmasIds.any((idTurma) => disciplina.turmas.any((t) => t.id == idTurma));

              // 🟢 HERO ADICIONADO AQUI: Ele entende de onde a tela tem que pular
              return Hero(
                tag: 'hero_hub_${disciplina.id}',
                flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                  return Material(type: MaterialType.transparency, child: toHeroContext.widget);
                },
                child: Material(
                  type: MaterialType.transparency,
                  child: Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      // 🟢 MUDANÇA NA NAVEGAÇÃO
                      onTap: () => DisciplinaDetailsPage.abrir(context, disciplina, 'hero_hub_${disciplina.id}'),
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
                                  decoration: BoxDecoration(color: disciplina.cor.withAlpha(50), borderRadius: BorderRadius.circular(8)),
                                  child: Text(disciplina.codigo, style: TextStyle(color: disciplina.cor, fontWeight: FontWeight.bold)),
                                ),
                                Row(
                                  children: [
                                    if (disciplina.isVerificada)
                                      const Icon(Icons.verified, color: Colors.blue, size: 22)
                                    else ...[
                                      const Icon(Icons.pending_actions, color: Colors.orange, size: 22),
                                      if (currentUser.isGremio)
                                        IconButton(
                                          icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 26),
                                          tooltip: 'Aprovar Disciplina',
                                          onPressed: () async {
                                            await _firestoreService.aprovarDisciplina(disciplina.id);
                                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disciplina aprovada!'), backgroundColor: Colors.green));
                                          },
                                        ),
                                    ],
                                    if (isAdmin) ...[
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.edit_note, color: Colors.black87),
                                        padding: EdgeInsets.zero, constraints: const BoxConstraints(), tooltip: 'Editar',
                                        onPressed: () {
                                          Navigator.of(context, rootNavigator: true).push(
                                            MaterialPageRoute(
                                              builder: (context) => CriarDisciplinaPage(disciplinaParaEditar: disciplina),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        padding: EdgeInsets.zero, constraints: const BoxConstraints(), tooltip: 'Excluir',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              title: const Text('Tem certeza?', style: TextStyle(fontFamily: 'LeagueSpartan', fontWeight: FontWeight.w900, color: Color(0xFF162038))),
                                              content: Text('Excluir a disciplina ${disciplina.codigo}?', style: const TextStyle(fontFamily: 'Lato', fontSize: 16)),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCELAR', style: TextStyle(fontFamily: 'Aristotelica', color: Colors.grey, fontWeight: FontWeight.w700))),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(ctx).pop(); 
                                                    await _firestoreService.excluirDisciplina(disciplina.id);
                                                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disciplina excluída!'), backgroundColor: Colors.red));
                                                  },
                                                  child: const Text('EXCLUIR', style: TextStyle(fontFamily: 'Aristotelica', color: Colors.red, fontWeight: FontWeight.w700)),
                                                ),
                                              ],
                                            ),
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
                                onPressed: null, 
                                icon: Icon(jaInscrito ? Icons.check_circle : Icons.lock_outline),
                                label: Text(jaInscrito ? 'Matriculado (Altere na Grade)' : 'Adicione na Editar Grade'),
                                style: ElevatedButton.styleFrom(
                                  disabledBackgroundColor: jaInscrito ? Colors.green[100] : Colors.grey[200],
                                  disabledForegroundColor: jaInscrito ? Colors.green[800] : Colors.grey[500],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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