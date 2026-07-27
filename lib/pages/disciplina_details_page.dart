// lib/pages/disciplina_details_page.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/providers/disciplinas_provider.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_da_poli/pages/historico_presenca_page.dart';

class DisciplinaDetailsPage extends StatelessWidget {
  final Disciplina disciplina;

  const DisciplinaDetailsPage({super.key, required this.disciplina});

  bool _isAulaAcontecendo() {
    final now = DateTime.now();
    const mapDias = {1: 'Segunda', 2: 'Terça', 3: 'Quarta', 4: 'Quinta', 5: 'Sexta', 6: 'Sábado', 7: 'Domingo'};
    final hojeStr = mapDias[now.weekday] ?? '';
    if (!disciplina.diasDaSemana.contains(hojeStr)) return false;

    try {
      final minutosAtual = now.hour * 60 + now.minute;
      final inicioStr = disciplina.horarioInicio.split(':');
      final fimStr = disciplina.horarioFim.split(':');
      final minutosInicio = int.parse(inicioStr[0]) * 60 + int.parse(inicioStr[1]);
      final minutosFim = int.parse(fimStr[0]) * 60 + int.parse(fimStr[1]);
      return minutosAtual >= (minutosInicio - 15) && minutosAtual <= minutosFim;
    } catch (e) { return false; }
  }

  String _calcularMediaParcial(String formula, Map<String, double?>? notas) {
    if (notas == null || notas.isEmpty) return '---';
    
    try {
      String expr = formula.toUpperCase();
      notas.forEach((key, value) {
        if (value != null) {
          expr = expr.replaceAll(key, value.toString());
        }
      });

      if (RegExp(r'[A-Z]').hasMatch(expr)) {
        return 'Preencha as notas';
      }

      return 'Em cálculo...';
    } catch (e) {
      return 'Erro na fórmula';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Setup do provedor e data
    final provider = context.watch<DisciplinasProvider>();
    final progresso = provider.progressos.where((p) => p.disciplinaId == disciplina.id).firstOrNull;
    final hoje = DateTime.now();
    final dataHojeStr = "${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}";
    final bool jaRespondeuHoje = progresso?.historicoPresenca.containsKey(dataHojeStr) ?? false;
    final bool mostrarBotoes = _isAulaAcontecendo() && !jaRespondeuHoje;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: disciplina.cor,
        title: Text(disciplina.codigo, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header colorido
            Container(
              color: disciplina.cor.withAlpha(30),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(disciplina.nome, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: disciplina.cor, height: 1.1)),
                  const SizedBox(height: 8),
                  Text("Depto: ${disciplina.departamento}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 16),
                  
                  // Bloco de Presença e Local (UI CONDICIONAL AQUI)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text(disciplina.local, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      
                      // Mostra os botões de Presença ou o Relógio de Histórico
                      if (mostrarBotoes)
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              onPressed: () => FirestoreService().registrarPresenca(disciplina.id, dataHojeStr, true),
                              child: const Text('Presente'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                              onPressed: () => FirestoreService().registrarPresenca(disciplina.id, dataHojeStr, false),
                              child: const Text('Faltei'),
                            ),
                          ],
                        )
                      else if (progresso != null)
                        IconButton(
                          icon: const Icon(Icons.history, size: 30, color: Colors.black87),
                          tooltip: 'Editar Diário de Bordo',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => HistoricoPresencaPage(disciplina: disciplina),
                              ),
                            );
                          },
                        )
                    ],
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Horário das Aulas'),
                  Text("${disciplina.diasDaSemana.join(', ')} • ${disciplina.horarioInicio} às ${disciplina.horarioFim}", style: const TextStyle(fontSize: 16)),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Equipe Acadêmica'),
                  Text("Docentes: ${disciplina.docentes.isNotEmpty ? disciplina.docentes.join(', ') : 'Não informado'}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("Monitores: ${disciplina.monitores.isNotEmpty ? disciplina.monitores.join(', ') : 'Não informado'}", style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Avaliação'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Fórmula de Nota Final:", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(disciplina.formulaAvaliacao, style: const TextStyle(fontSize: 18, fontFamily: 'monospace')),
                      ],
                    ),
                  ),

                  // SEÇÃO DO BOLETIM & NOTAS EM TEMPO REAL
                  const SizedBox(height: 24),
                  _buildSectionTitle('Meu Boletim & Média'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Regra de Avaliação: ${disciplina.formulaAvaliacao}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 12),
                        
                        ...disciplina.variaveisAvaliacao.map((variavel) {
                          final double? notaAtual = progresso?.notasPreenchidas[variavel];
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(variavel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0460E9))),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: TextFormField(
                                      initialValue: notaAtual?.toString() ?? '',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        hintText: 'Digite a nota',
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      onChanged: (valor) {
                                        final double? notaParsed = double.tryParse(valor.replaceAll(',', '.'));
                                        final Map<String, double?> novasNotas = Map.from(progresso?.notasPreenchidas ?? {});
                                        novasNotas[variavel] = notaParsed;

                                        FirestoreService().atualizarNotas(disciplina.id, novasNotas);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        
                        const Divider(height: 24),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Média Parcial Estimada:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(
                              _calcularMediaParcial(disciplina.formulaAvaliacao, progresso?.notasPreenchidas),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0460E9)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Ementa do Curso'),
                  Text(
                    disciplina.ementa.isNotEmpty ? disciplina.ementa : 'Ementa não disponibilizada pelo departamento.',
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }
}