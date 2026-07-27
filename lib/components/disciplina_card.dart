// lib/components/disciplina_card.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:flutter/material.dart';

/// Um card vertical e compacto que representa uma disciplina na grade horária.
/// Exibe o código da disciplina verticalmente.
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
    // Divide o código da disciplina em caracteres individuais para exibição vertical.
    final characters = disciplina.codigo.split('');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: disciplina.cor,
          borderRadius: BorderRadius.circular(10.0), // Raio de borda um pouco menor para um visual mais limpo
        ),
        // FittedBox garante que o conteúdo (a coluna de texto) se ajuste
        // ao espaço disponível, encolhendo se necessário.
        child: FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: characters.map((char) => Text(
                char,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // O tamanho da fonte é a base, mas pode ser ajustado pelo FittedBox
                ),
              )).toList(),
            ),
          ),
        ),
      ),
    );
  }
}