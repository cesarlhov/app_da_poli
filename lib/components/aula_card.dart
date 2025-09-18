// lib/components/aula_card.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:flutter/material.dart';

/// Card para exibir as informações de uma aula agendada para o dia.
class AulaCard extends StatelessWidget {
  final Disciplina disciplina;
  const AulaCard({super.key, required this.disciplina});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: disciplina.cor.withAlpha((255 * 0.15).round()), // Correção da opacidade
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: disciplina.cor,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          _buildHorarioColumn(),
          const SizedBox(width: 16),
          Expanded(child: _buildInfoColumn()),
        ],
      ),
    );
  }

  Widget _buildHorarioColumn() {
    return Column(
      children: [
        Text(disciplina.horarioInicio, style: const TextStyle(fontFamily: 'LeagueSpartan', fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          height: 40,
          width: 2,
          color: disciplina.cor.withAlpha((255 * 0.5).round()), // Correção da opacidade
        ),
        const SizedBox(height: 8),
        Text(disciplina.horarioFim, style: const TextStyle(fontFamily: 'LeagueSpartan', fontWeight: FontWeight.w700, fontSize: 16)),
      ],
    );
  }

  Widget _buildInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(disciplina.codigo, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: disciplina.cor, fontFamily: 'LeagueSpartan', height: 1.1)),
        Text(disciplina.nome, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Text("Sala ${disciplina.sala}", style: TextStyle(fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.w500)),
        Text(disciplina.professor, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }
}