// lib/components/slidable_grade_preview.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/views/edit_grade_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SlidableGradePreview extends StatefulWidget {
  final List<Disciplina> disciplinas;
  final VoidCallback onGradeEdited;

  const SlidableGradePreview({
    super.key,
    required this.disciplinas,
    required this.onGradeEdited,
  });

  @override
  State<SlidableGradePreview> createState() => SlidableGradePreviewState();
}

class SlidableGradePreviewState extends State<SlidableGradePreview>
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

  void _navigateToEditPage() async {
    closeMenu();
    await Future.delayed(const Duration(milliseconds: 210));
    
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EditGradePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final screenBackground = Container(
            color: Theme.of(context)
                .scaffoldBackgroundColor
                .withOpacity(animation.value),
          );
          return Stack(children: [screenBackground, child]);
        },
      ),
    );
    widget.onGradeEdited();
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
    final gradient =
        const LinearGradient(colors: [Color(0xFF0460E9), Color(0xFF0D41A9)]);

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
                    onPressed: _navigateToEditPage),
                IconButton(
                    icon: const Icon(Icons.download, color: Colors.black54),
                    onPressed: () {}),
              ],
            ),
          ),
        ),
        GestureDetector(
          onHorizontalDragStart: _handleDragStart,
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          child: Hero(
            tag: 'grade-hero',
            child: Material(
              type: MaterialType.transparency,
              child: Transform.translate(
                offset: Offset(-offset, 0),
                child: Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    gradient: gradient,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MiniGradePreview(
                      disciplinas: widget.disciplinas,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MiniGradePreview extends StatelessWidget {
  final List<Disciplina> disciplinas;
  const MiniGradePreview({super.key, required this.disciplinas});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final config = _analyzeSchedule();
        final totalContentHeight = constraints.maxHeight - (7.3 + 6.7 + 5.0);
        final totalMinutes = (config.temAulaNoite ? 680.0 : 560.0);
        final pixelsPerMinute = totalContentHeight / totalMinutes;

        return Stack(
          children: [
            // --- CORREÇÃO: Adicionado o operador '...' ---
            ..._buildGradeBackground(config, pixelsPerMinute),
            // --- CORREÇÃO: Adicionado o operador '...' ---
            ..._buildPositionedDisciplines(config, pixelsPerMinute, constraints.maxWidth),
            _buildHeadersAndFooters(),
          ],
        );
      },
    );
  }

  ({bool temAulaAlmoco, bool temAulaNoite}) _analyzeSchedule() {
    bool temAulaAlmoco = disciplinas.any((d) => _isDuringLunch(d));
    bool temAulaNoite = disciplinas.any((d) => _isAfterHours(d));
    return (temAulaAlmoco: temAulaAlmoco, temAulaNoite: temAulaNoite);
  }

  List<Widget> _buildGradeBackground(
      ({bool temAulaAlmoco, bool temAulaNoite}) config, double pixelsPerMinute) {
    final double manhaStart = 0;
    final double manhaHeight = 210 * pixelsPerMinute;
    final double almocoStart = manhaHeight + (config.temAulaAlmoco ? 0 : 13.88);
    final double almocoHeight = config.temAulaAlmoco ? (130 * pixelsPerMinute) : 0;
    final double tardeStart = manhaHeight + (config.temAulaAlmoco ? (130 * pixelsPerMinute) : 13.88);
    final double tardeMinutes = config.temAulaNoite ? 340.0 : 220.0;
    final double tardeHeight = tardeMinutes * pixelsPerMinute;

    return [
      Positioned(top: manhaStart, left: 9.72, right: 9.72, height: manhaHeight, child: Container(color: Colors.grey.withOpacity(0.1))),
      if (config.temAulaAlmoco)
        Positioned(top: almocoStart, left: 9.72, right: 9.72, height: almocoHeight, child: Container(color: Colors.grey.withOpacity(0.1))),
      Positioned(top: tardeStart, left: 9.72, right: 9.72, height: tardeHeight, child: Container(color: Colors.grey.withOpacity(0.1))),
    ];
  }

  List<Widget> _buildPositionedDisciplines(
      ({bool temAulaAlmoco, bool temAulaNoite}) config, double pixelsPerMinute, double maxWidth) {
    const double startMinutes = 7.5 * 60;
    final dias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];
    final double availableWidth = maxWidth - (2 * 9.72);
    final double colSpacing = 6.94;
    final double colWidth = (availableWidth - (4 * colSpacing)) / 5;

    List<Widget> positionedDisciplines = [];
    for (var disciplina in disciplinas) {
      try {
        final inicioMinutos = _timeToMinutes(disciplina.horarioInicio);
        final fimMinutos = _timeToMinutes(disciplina.horarioFim);
        
        final double top = (inicioMinutos - startMinutes) * pixelsPerMinute;
        final double height = (fimMinutos - inicioMinutos) * pixelsPerMinute;
        
        for (String dia in disciplina.diasDaSemana) {
          final int diaIndex = dias.indexOf(dia);
          if (diaIndex != -1) {
            final double left = 9.72 + (diaIndex * colWidth) + (diaIndex * colSpacing);
            positionedDisciplines.add(
              Positioned(
                top: top,
                left: left,
                width: colWidth,
                height: height,
                child: Container(
                  margin: const EdgeInsets.all(0.5),
                  decoration: BoxDecoration(color: disciplina.cor, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            );
          }
        }
      } catch(e) { /* ignora */ }
    }
    return positionedDisciplines;
  }

  Widget _buildHeadersAndFooters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(9.72, 7.3, 9.72, 6.7),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('GRADE HORÁRIA', style: TextStyle(fontFamily: 'AristotelicaProDisplay', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0460E9))),
              Text('III Č', style: TextStyle(fontFamily: 'AristotelicaProDisplay', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0460E9))),
            ],
          ),
          const Spacer(),
          const Align(
            alignment: Alignment.centerRight,
            child: Text('< ARRASTE PARA EDITAR', style: TextStyle(fontFamily: 'Lato', fontStyle: FontStyle.italic, color: Color(0xFFBCBEBF), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  bool _isDuringLunch(Disciplina d) {
    try {
      final inicio = _timeToMinutes(d.horarioInicio);
      final fim = _timeToMinutes(d.horarioFim);
      return fim > 660 && inicio < 790;
    } catch (e) { return false; }
  }

  bool _isAfterHours(Disciplina d) {
    try {
      final fim = _timeToMinutes(d.horarioFim);
      return fim > 1010;
    } catch (e) { return false; }
  }
}