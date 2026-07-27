// lib/components/aula_card.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/pages/disciplina_details_page.dart';
import 'package:app_da_poli/providers/disciplinas_provider.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AulaCard extends StatelessWidget {
  final Disciplina disciplina;
  const AulaCard({super.key, required this.disciplina});

  // Função mágica que descobre se a aula está acontecendo AGORA (com 15 min de tolerância)
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

      // Mostra o botão de 15 minutos antes da aula até o minuto que ela acaba
      return minutosAtual >= (minutosInicio - 15) && minutosAtual <= minutosFim;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Busca o progresso do aluno nesta disciplina
    final provider = context.watch<DisciplinasProvider>();
    final progresso = provider.progressos.where((p) => p.disciplinaId == disciplina.id).firstOrNull;

    // Gera a data de hoje no formato do banco (YYYY-MM-DD)
    final hoje = DateTime.now();
    final dataHojeStr = "${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}";

    // Verifica se ele já respondeu hoje
    final bool jaRespondeuHoje = progresso?.historicoPresenca.containsKey(dataHojeStr) ?? false;
    final bool mostrarBotoes = _isAulaAcontecendo() && !jaRespondeuHoje;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DisciplinaDetailsPage(disciplina: disciplina)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: disciplina.cor.withAlpha((255 * 0.15).round()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: disciplina.cor, width: 1.5),
        ),
        child: Row(
          children: [
            _buildHorarioColumn(),
            const SizedBox(width: 16),
            Expanded(child: _buildInfoColumn()),
            
            // A MÁGICA VISUAL: Botões ou Seta
            if (mostrarBotoes)
              _buildBotoesPresenca(context, dataHojeStr)
            else
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildBotoesPresenca(BuildContext context, String dataHojeStr) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 32),
          tooltip: 'Presente',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => FirestoreService().registrarPresenca(disciplina.id, dataHojeStr, true),
        ),
        const SizedBox(height: 8),
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red, size: 32),
          tooltip: 'Faltei',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => FirestoreService().registrarPresenca(disciplina.id, dataHojeStr, false),
        ),
      ],
    );
  }

  Widget _buildHorarioColumn() {
    return Column(
      children: [
        Text(disciplina.horarioInicio, style: const TextStyle(fontFamily: 'LeagueSpartan', fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 8),
        Container(height: 40, width: 2, color: disciplina.cor.withAlpha((255 * 0.5).round())),
        const SizedBox(height: 8),
        Text(disciplina.horarioFim, style: const TextStyle(fontFamily: 'LeagueSpartan', fontWeight: FontWeight.w700, fontSize: 16)),
      ],
    );
  }

  Widget _buildInfoColumn() {
    String nomeProfessor = disciplina.docentes.isNotEmpty ? disciplina.docentes.first : 'Sem professor';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(disciplina.codigo, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: disciplina.cor, fontFamily: 'LeagueSpartan', height: 1.1)),
        Text(disciplina.nome, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Text("Local: ${disciplina.local}", style: TextStyle(fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.w500)),
        Text("Prof. $nomeProfessor", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }
}