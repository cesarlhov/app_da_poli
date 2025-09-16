// lib/components/aula_card.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:flutter/material.dart';

class AulaCard extends StatelessWidget {
  final Disciplina disciplina;
  const AulaCard({super.key, required this.disciplina});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: disciplina.cor.withOpacity(0.15), // Usa a cor da disciplina com opacidade
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: disciplina.cor, // Borda com a cor da disciplina
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Coluna da Esquerda com Horários
          Column(
            children: [
              Text(
                disciplina.horarioInicio,
                style: const TextStyle(
                  fontFamily: 'LeagueSpartan',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 40,
                width: 2,
                color: disciplina.cor.withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              Text(
                disciplina.horarioFim,
                style: const TextStyle(
                  fontFamily: 'LeagueSpartan',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Coluna da Direita com Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  disciplina.codigo,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: disciplina.cor,
                    fontFamily: 'LeagueSpartan',
                    height: 1.1
                  ),
                ),
                Text(
                  disciplina.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    height: 1.2
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  "Sala ${disciplina.sala}", // Simplifiquei um pouco
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                     fontWeight: FontWeight.w500,
                  ),
                ),
                 Text(
                  disciplina.professor,
                   style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}