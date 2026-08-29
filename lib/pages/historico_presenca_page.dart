// lib/pages/historico_presenca_page.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/providers/disciplinas_provider.dart';
import 'package:app_da_poli/providers/user_provider.dart'; // 🟢 NOVO IMPORT
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoricoPresencaPage extends StatelessWidget {
  final Disciplina disciplina;

  const HistoricoPresencaPage({super.key, required this.disciplina});

  // 🟢 O Motor de Calendário importado para a página de Histórico
  List<DateTime> _obterDatasDeAula(Turma turma) {
    List<DateTime> datas = [];
    DateTime inicio = disciplina.dataInicio.toDate();
    DateTime fim = disciplina.dataFim.toDate();
    
    const mapDias = {'SEGUNDA': 1, 'TERÇA': 2, 'QUARTA': 3, 'QUINTA': 4, 'SEXTA': 5, 'SÁBADO': 6, 'DOMINGO': 7};
    Set<int> diasValidos = {};
    for (var h in turma.horarios) {
      if (mapDias.containsKey(h.dia.toUpperCase())) {
        diasValidos.add(mapDias[h.dia.toUpperCase()]!);
      }
    }

    if (diasValidos.isEmpty) return datas;

    DateTime atual = DateTime(inicio.year, inicio.month, inicio.day);
    DateTime limite = DateTime(fim.year, fim.month, fim.day, 23, 59, 59);

    while (atual.isBefore(limite) || atual.isAtSameMomentAs(limite)) {
      if (diasValidos.contains(atual.weekday)) {
        datas.add(atual);
      }
      atual = atual.add(const Duration(days: 1));
    }
    return datas;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DisciplinasProvider>();
    final userProvider = context.watch<UserProvider>();
    final progresso = provider.progressos.where((p) => p.disciplinaId == disciplina.id).firstOrNull;
    final user = userProvider.currentUser;

    // 1. Descobrir qual é a turma do aluno
    List<Turma> turmasDoAluno = disciplina.turmas.where((t) => user?.turmasIds.contains(t.id) ?? false).toList();
    Turma? turmaAtual = turmasDoAluno.isNotEmpty ? turmasDoAluno.first : (disciplina.turmas.isNotEmpty ? disciplina.turmas.first : null);

    // 2. Levantar todas as aulas que JÁ ACONTECERAM até a data de hoje
    List<DateTime> aulasPassadas = [];
    int totalAulasEstimadas = disciplina.totalAulasEstimadas;

    if (turmaAtual != null) {
      List<DateTime> todasAsAulas = _obterDatasDeAula(turmaAtual);
      if (todasAsAulas.isNotEmpty) totalAulasEstimadas = todasAsAulas.length;

      DateTime hoje = DateTime.now();
      DateTime limite = DateTime(hoje.year, hoje.month, hoje.day, 23, 59, 59);
      
      aulasPassadas = todasAsAulas.where((d) => d.isBefore(limite) || d.isAtSameMomentAs(limite)).toList();
      aulasPassadas.sort((a, b) => b.compareTo(a)); // Ordena para mostrar as mais recentes no topo
    }

    // 3. Cálculos de Risco
    final freqCalculada = progresso?.calcularFrequencia(totalAulasEstimadas) ?? 100.0;
    final bool emRisco = progresso?.emRiscoDeReprovacao(totalAulasEstimadas) ?? false;
    final Color corStatus = emRisco ? Colors.red : Colors.green;
    final int faltas = progresso?.faltasTotais ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário de Bordo', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: freqCalculada / 100,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(corStatus),
                      ),
                      Center(
                        child: Text(
                          '${freqCalculada.toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: corStatus),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total de Faltas: $faltas',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        emRisco 
                            ? 'Atenção: Você está abaixo do limite de 70% do MEC!'
                            : 'Frequência segura. Continue assim!',
                        style: TextStyle(color: corStatus, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: aulasPassadas.isEmpty
                ? const Center(
                    child: Text(
                      'A disciplina ainda não começou.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: aulasPassadas.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final data = aulasPassadas[index];
                      final dataIso = "${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}";
                      
                      // 🟢 Agora pega bool? (true, false ou null)
                      final bool? estavaPresente = progresso?.historicoPresenca[dataIso];
                      final dataFormatada = "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}";

                      Color corAvatar = estavaPresente == true ? Colors.green[100]! : (estavaPresente == false ? Colors.red[100]! : Colors.grey[200]!);
                      IconData iconAvatar = estavaPresente == true ? Icons.check : (estavaPresente == false ? Icons.close : Icons.remove);
                      Color corIcone = estavaPresente == true ? Colors.green : (estavaPresente == false ? Colors.red : Colors.grey[600]!);
                      String txtSubtitle = estavaPresente == true ? 'Presente' : (estavaPresente == false ? 'Faltou' : 'Sem Registro');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: corAvatar,
                            child: Icon(iconAvatar, color: corIcone),
                          ),
                          title: Text(dataFormatada, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          subtitle: Text(txtSubtitle),
                          
                          // 🟢 O Dropdown super elegante que aceita os 3 estados
                          trailing: PopupMenuButton<bool?>(
                            initialValue: estavaPresente,
                            onSelected: (novoValor) {
                              FirestoreService().registrarPresenca(disciplina.id, dataIso, novoValor);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: true, child: Text('Presente', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                              const PopupMenuItem(value: false, child: Text('Faltou', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                              const PopupMenuItem(value: null, child: Text('Sem Registro', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                            ],
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: corAvatar,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(txtSubtitle, style: TextStyle(fontWeight: FontWeight.bold, color: corIcone)),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_drop_down, size: 20, color: corIcone),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}