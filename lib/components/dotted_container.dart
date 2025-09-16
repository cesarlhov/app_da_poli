// lib/components/dotted_container.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

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
    this.dashPattern = const <double>[3, 1],
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      // --- CORREÇÃO AQUI: Trocamos 'painter' por 'foregroundPainter' ---
      // 'painter' desenha ATRÁS do 'child'.
      // 'foregroundPainter' desenha DEPOIS e NA FRENTE do 'child'.
      foregroundPainter: _DottedBorderPainter(
        color: borderColor,
        strokeWidth: strokeWidth,
        borderRadius: borderRadius,
        dashPattern: dashPattern,
      ),
      // O Container (fundo cinza) é desenhado PRIMEIRO.
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

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final BorderRadius borderRadius;
  final List<double> dashPattern;

  _DottedBorderPainter({
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.borderRadius = BorderRadius.zero,
    this.dashPattern = const <double>[3, 1],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Rect fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // A borda interna é desenhada encolhendo o caminho do desenho
    final Rect innerRect = fullRect.deflate(strokeWidth / 2);

    final RRect rrect = borderRadius.toRRect(innerRect);
    final Path path = Path()..addRRect(rrect);

    final ui.PathMetrics pathMetrics = path.computeMetrics();
    for (final ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashPattern[0]),
          paint,
        );
        distance += dashPattern[0] + dashPattern[1];
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}