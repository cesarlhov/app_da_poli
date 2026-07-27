// lib/pages/historico_presenca_page.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/providers/disciplinas_provider.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoricoPresencaPage extends StatelessWidget {
  final Disciplina disciplina;

  const HistoricoPresencaPage({super.key, required this.disciplina});

  @override
  Widget build(BuildContext context) {
    // Escutamos o progresso. Qualquer edição no Firebase atualiza a tela na hora!
    final provider = context.watch<DisciplinasProvider>();
    final progresso = provider.progressos.where((p) => p.disciplinaId == disciplina.id).firstOrNull;

    if (progresso == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Diário de Bordo')),
        body: const Center(child: Text('Progresso não encontrado.')),
      );
    }

    final double frequencia = progresso.calcularFrequencia(disciplina.totalAulasEstimadas);
    final bool emRisco = progresso.emRiscoDeReprovacao(disciplina.totalAulasEstimadas);
    final Color corStatus = emRisco ? Colors.red : Colors.green;

    // Pega as datas do mapa, converte para lista e ordena da mais recente para a mais antiga
    final List<String> datasOrdenadas = progresso.historicoPresenca.keys.toList();
    datasOrdenadas.sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário de Bordo', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // CABEÇALHO DO DASHBOARD (O MEDIDOR DE 100%)
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
                        value: frequencia / 100,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(corStatus),
                      ),
                      Center(
                        child: Text(
                          '${frequencia.toStringAsFixed(0)}%',
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
                        'Total de Faltas: ${progresso.faltasTotais}',
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

          // LISTA DO RELÓGIO (CRONOLOGIA)
          Expanded(
            child: datasOrdenadas.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum registro de aula passado.\nAs aulas aparecerão aqui após você respondê-las no card.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: datasOrdenadas.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final dataIso = datasOrdenadas[index];
                      final bool estavaPresente = progresso.historicoPresenca[dataIso] ?? false;
                      
                      // Converte YYYY-MM-DD para DD/MM/YYYY para ficar bonito na tela
                      final partes = dataIso.split('-');
                      final dataFormatada = "${partes[2]}/${partes[1]}/${partes[0]}";

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: estavaPresente ? Colors.green[100] : Colors.red[100],
                            child: Icon(
                              estavaPresente ? Icons.check : Icons.close,
                              color: estavaPresente ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(dataFormatada, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          subtitle: Text(estavaPresente ? 'Marcado como Presente' : 'Marcado como Falta'),
                          trailing: OutlinedButton.icon(
                            onPressed: () {
                              // O INVERSOR DE ESTADO: Se tava presente, vira falta. Se tava falta, vira presente.
                              FirestoreService().registrarPresenca(disciplina.id, dataIso, !estavaPresente);
                            },
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Corrigir'),
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