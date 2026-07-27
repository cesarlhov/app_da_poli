// lib/components/weekday_selector.dart

import 'package:flutter/material.dart';

class WeekdaySelector extends StatefulWidget {
  final Function(List<String>) onSelectionChanged;
  final List<String> diasIniciais; 

  const WeekdaySelector({
    super.key,
    required this.onSelectionChanged,
    this.diasIniciais = const [],
  });

  @override
  State<WeekdaySelector> createState() => _WeekdaySelectorState();
}

class _WeekdaySelectorState extends State<WeekdaySelector> {
  // Agora com finais de semana!
  final List<String> _diasDaSemana = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
  late List<String> _selecionados;

  @override
  void initState() {
    super.initState();
    _selecionados = List.from(widget.diasIniciais);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _diasDaSemana.map((dia) {
        final isSelected = _selecionados.contains(dia);
        return FilterChip(
          label: Text(dia.substring(0, 3)), // Mostra apenas Seg, Ter, Qua... para economizar espaço
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selecionados.add(dia);
              } else {
                _selecionados.remove(dia);
              }
              widget.onSelectionChanged(_selecionados);
            });
          },
          selectedColor: const Color(0xFF0460E9).withAlpha(50),
          checkmarkColor: const Color(0xFF0460E9),
        );
      }).toList(),
    );
  }
}