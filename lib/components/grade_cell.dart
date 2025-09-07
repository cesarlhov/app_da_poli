import 'package:flutter/material.dart';

//-------------------------------------------------
// COMPONENTE PARA UMA CÉLULA DA GRADE
//-------------------------------------------------
class GradeCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final Color color;
  final double height; // <-- Parâmetro de altura adicionado

  const GradeCell({
    super.key,
    required this.text,
    this.isHeader = false,
    this.color = Colors.transparent,
    required this.height, // <-- Altura é agora necessária
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height, // <-- Altura é agora usada aqui
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

