// lib/components/dotted_container.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Um Container com uma borda pontilhada customizável.
class DottedContainer extends StatelessWidget {
  final Widget? child;
  final Color color;
  final Color borderColor;
  final double strokeWidth;
  final BorderRadius borderRadius;
  final List<double> dashPattern;

  const DottedContainer({
    super.key,
    this.child,
    this.color = Colors.transparent,
    this.borderColor = Colors.black,
    this.strokeWidth = 1.0,
    this.borderRadius = BorderRadius.zero,
    this.dashPattern = const <double>[3, 1], // Padrão: 3 pixels desenhados, 1 pixel de espaço
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      // Usamos foregroundPainter para garantir que a borda seja desenhada
      // NA FRENTE do child, evitando que a cor de fundo do child a cubra.
      foregroundPainter: _DottedBorderPainter(
        color: borderColor,
        strokeWidth: strokeWidth,
        borderRadius: borderRadius,
        dashPattern: dashPattern,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}

/// O CustomPainter que efetivamente desenha a borda pontilhada.
class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final BorderRadius borderRadius;
  final List<double> dashPattern;

  _DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Cria um retângulo com as dimensões do widget.
    final Rect fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Reduz o retângulo pela metade da espessura da borda para que a linha
    // seja desenhada dentro dos limites do widget.
    final Rect innerRect = fullRect.deflate(strokeWidth / 2);

    // Converte o retângulo em um RRect (retângulo com cantos arredondados).
    final RRect rrect = borderRadius.toRRect(innerRect);
    final Path path = Path()..addRRect(rrect);

    // Itera sobre o caminho (path) para desenhar os segmentos pontilhados.
    final ui.PathMetrics pathMetrics = path.computeMetrics();
    for (final ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        // Extrai e desenha um pequeno segmento do caminho (o traço).
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashPattern[0]),
          paint,
        );
        // Move a "distância" para o início do próximo traço.
        distance += dashPattern[0] + dashPattern[1];
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedBorderPainter oldDelegate) {
    // Redesenha se qualquer uma das propriedades mudar.
    return oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.borderRadius != borderRadius ||
           oldDelegate.dashPattern != dashPattern;
  }
}