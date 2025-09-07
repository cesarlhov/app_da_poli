// lib/components/mini_grade_preview.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:flutter/material.dart';

class MiniGradePreview extends StatelessWidget {
  final List<Disciplina> disciplinas;
  const MiniGradePreview({super.key, required this.disciplinas});

  bool _temAulaNoSlot(String dia, int horaSlot, List<Disciplina> disciplinas) {
    final slotInicioMinutos = horaSlot * 60;
    final slotFimMinutos = (horaSlot + 2) * 60;
    for (var disciplina in disciplinas) {
      if (disciplina.diasDaSemana.contains(dia)) {
        try {
          final inicioParts = disciplina.horarioInicio.split(':');
          final fimParts = disciplina.horarioFim.split(':');
          final disciplinaInicioMinutos =
              int.parse(inicioParts[0]) * 60 + int.parse(inicioParts[1]);
          final disciplinaFimMinutos =
              int.parse(fimParts[0]) * 60 + int.parse(fimParts[1]);
          if (disciplinaInicioMinutos < slotFimMinutos &&
              disciplinaFimMinutos > slotInicioMinutos) {
            return true;
          }
        } catch (e) {
          continue;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final dias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];
    final horas = [8, 10, 12, 14, 16];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GRADE HORÁRIA',
                style: TextStyle(
                    fontFamily: 'Aristotelica',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0460E9))),
            const Text('III Č',
                style: TextStyle(
                    fontFamily: 'Aristotelica',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0460E9))),
          ],
        ),
        const SizedBox(height: 6),
        Table(
          children: List.generate(
            horas.length,
            (rowIndex) => TableRow(
              children: List.generate(
                dias.length,
                (colIndex) {
                  final diaAtual = dias[colIndex];
                  final horaAtual = horas[rowIndex];
                  final temAula =
                      _temAulaNoSlot(diaAtual, horaAtual, disciplinas);
                  return Container(
                    height: 22,
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: temAula
                          ? Colors.blue.withOpacity(1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        const Align(
          alignment: Alignment.centerRight,
          child: Text('< ARRASTE PARA EDITAR',
              style: TextStyle(
                  fontFamily: 'Lato',
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}