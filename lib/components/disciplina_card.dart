import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:flutter/material.dart';

//-------------------------------------------------
// COMPONENTE PARA EXIBIR UMA DISCIPLINA NA GRADE
//-------------------------------------------------
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: const Color(0xFF003366).withOpacity(0.8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              disciplina.nome,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 2),
            Text(
              disciplina.codigo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
