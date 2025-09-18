// lib/components/weekday_selector.dart

import 'package:flutter/material.dart';

/// Um widget que permite ao usuário selecionar múltiplos dias da semana.
class WeekdaySelector extends StatefulWidget {
  /// Callback que retorna a lista de dias selecionados (ex: ["Segunda", "Quarta"]).
  final Function(List<String>) onSelectionChanged;

  const WeekdaySelector({super.key, required this.onSelectionChanged});

  @override
  State<WeekdaySelector> createState() => _WeekdaySelectorState();
}

class _WeekdaySelectorState extends State<WeekdaySelector> {
  // Mapeamento dos dias da semana para suas abreviações.
  static const Map<String, String> _diasDaSemana = {
    'Segunda': 'S',
    'Terça': 'T',
    'Quarta': 'Q',
    'Quinta': 'Q',
    'Sexta': 'S',
  };

  final List<String> _diasSelecionados = [];

  void _toggleDay(String dia) {
    setState(() {
      if (_diasSelecionados.contains(dia)) {
        _diasSelecionados.remove(dia);
      } else {
        _diasSelecionados.add(dia);
      }
    });
    // Notifica o widget pai sobre a mudança.
    widget.onSelectionChanged(_diasSelecionados);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _diasDaSemana.entries.map((entry) {
        final diaCompleto = entry.key;
        final diaAbreviado = entry.value;
        final isSelected = _diasSelecionados.contains(diaCompleto);

        return GestureDetector(
          onTap: () => _toggleDay(diaCompleto),
          child: CircleAvatar(
            radius: 22, // Um pouco maior para facilitar o toque
            backgroundColor: isSelected ? const Color(0xFF0D41A9) : Colors.grey[300],
            child: Text(
              diaAbreviado,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}