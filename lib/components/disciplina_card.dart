// lib/components/disciplina_card.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:flutter/material.dart';

class DisciplinaCard extends StatelessWidget {
  final Disciplina disciplina;
  final VoidCallback onTap;

  const DisciplinaCard({
    super.key,
    required this.disciplina,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final characters = disciplina.codigo.split('');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: disciplina.cor,
          borderRadius: BorderRadius.circular(100.0),
        ),
        // --- MUDANÇA: Usando FittedBox para garantir que o texto sempre caiba ---
        child: FittedBox(
          fit: BoxFit.contain, // Encolhe o conteúdo para caber
          child: Padding(
            // Adiciona um pequeno respiro interno
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: characters.map((char) => Text(
                char,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // O tamanho da fonte agora é uma referência
                ),
              )).toList(),
            ),
          ),
        ),
      ),
    );
  }
}