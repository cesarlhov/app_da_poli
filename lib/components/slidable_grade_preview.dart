// lib/components/slidable_grade_preview.dart

import 'package:app_da_poli/components/mini_grade_preview.dart';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/views/edit_grade_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SlidableGradePreview extends StatefulWidget {
  final List<Disciplina> disciplinas;
  const SlidableGradePreview({super.key, required this.disciplinas});

  @override
  State<SlidableGradePreview> createState() => _SlidableGradePreviewState();
}

class _SlidableGradePreviewState extends State<SlidableGradePreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final double _revealWidth = 80.0;
  bool _hapticTriggered = false;
  double _dragDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _animationController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void closeMenu() {
    if (_animationController.value != 0) _animationController.reverse();
  }

  void _handleDragStart(DragStartDetails details) {
    _dragDistance = 0.0;
    _hapticTriggered = false;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _dragDistance += details.delta.dx.abs();
    
    final resistedDelta = (details.delta.dx / _revealWidth) * 0.5;
    final newPosition = _animationController.value - resistedDelta;
    _animationController.value = newPosition.clamp(0.0, 1.0);

    if (_animationController.value > 0.5 && !_hapticTriggered) {
      HapticFeedback.heavyImpact();
      _hapticTriggered = true;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    final threshold = 0.5;

    if (_dragDistance < 30) {
      _animationController.reverse();
      return;
    }

    if (_animationController.value > threshold) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final offset = _animationController.value * _revealWidth;

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(11),
          ),
          child: SizedBox(
            width: _revealWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black54),
                  onPressed: () {
                    closeMenu();
                    Future.delayed(const Duration(milliseconds: 200), () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EditGradePage()));
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.black54),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onHorizontalDragStart: _handleDragStart,
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          child: Transform.translate(
            offset: Offset(-offset, 0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 7.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: const Color(0xFF0460E9), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(2 - (offset / 10), 5),
                  )
                ],
              ),
              child: MiniGradePreview(disciplinas: widget.disciplinas),
            ),
          ),
        ),
      ],
    );
  }
}