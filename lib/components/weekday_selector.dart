import 'package:flutter/material.dart';

//-------------------------------------------------
// COMPONENTE PARA SELECIONAR OS DIAS DA SEMANA
//-------------------------------------------------
class WeekdaySelector extends StatefulWidget {
  final Function(List<String>) onSelectionChanged;

  const WeekdaySelector({super.key, required this.onSelectionChanged});

  @override
  State<WeekdaySelector> createState() => _WeekdaySelectorState();
}

class _WeekdaySelectorState extends State<WeekdaySelector> {
  final List<String> _dias = ['S', 'T', 'Q', 'Q', 'S'];
  final List<String> _diasCompletos = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];
  final List<String> _diasSelecionados = [];

  void _toggleDay(int index) {
    final dia = _diasCompletos[index];
    setState(() {
      if (_diasSelecionados.contains(dia)) {
        _diasSelecionados.remove(dia);
      } else {
        _diasSelecionados.add(dia);
      }
    });
    widget.onSelectionChanged(_diasSelecionados);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_dias.length, (index) {
        final diaCompleto = _diasCompletos[index];
        final isSelected = _diasSelecionados.contains(diaCompleto);
        return GestureDetector(
          onTap: () => _toggleDay(index),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: isSelected ? const Color(0xFF003366) : Colors.grey[300],
            child: Text(
              _dias[index],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
}
