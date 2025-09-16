// lib/components/slidable_grade_preview.dart

import 'package:app_da_poli/components/dotted_container.dart';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/views/edit_grade_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SlidableGradePreview extends StatefulWidget {
  final List<Disciplina> disciplinas;
  final VoidCallback onGradeEdited;
  final double alturaManha;
  final double alturaAlmocoOuVao;
  final double alturaTarde;

  const SlidableGradePreview({
    super.key,
    required this.disciplinas,
    required this.onGradeEdited,
    required this.alturaManha,
    required this.alturaAlmocoOuVao,
    required this.alturaTarde,
  });

  @override
  State<SlidableGradePreview> createState() => SlidableGradePreviewState();
}

class SlidableGradePreviewState extends State<SlidableGradePreview> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final double _revealWidth = 80.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _animationController.addListener(() => setState(() {}));
  }
  @override
  void dispose() { _animationController.dispose(); super.dispose(); }
  void closeMenu() { if (_animationController.value != 0) _animationController.reverse(); }
  void _navigateToEditPage() async {
    closeMenu();
    await Future.delayed(const Duration(milliseconds: 210));
    await Navigator.of(context).push( PageRouteBuilder( opaque: false, transitionDuration: const Duration(milliseconds: 450), pageBuilder: (context, animation, secondaryAnimation) => const EditGradePage(), transitionsBuilder: (context, animation, secondaryAnimation, child) { final screenBackground = Container( color: Theme.of(context).scaffoldBackgroundColor.withOpacity(animation.value), ); return Stack(children: [screenBackground, child]); },),);
    widget.onGradeEdited();
  }
  void _handleDragStart(DragStartDetails details) { }
  void _handleDragUpdate(DragUpdateDetails details) {
    final resistedDelta = (details.delta.dx / _revealWidth) * 0.5;
    final newPosition = _animationController.value - resistedDelta;
    _animationController.value = newPosition.clamp(0.0, 1.0);
  }
  void _handleDragEnd(DragEndDetails details) {
    if (_animationController.value > 0.5) { _animationController.forward(); } else { _animationController.reverse(); }
  }

  @override
  Widget build(BuildContext context) {
    final offset = _animationController.value * _revealWidth;
    final gradient = const LinearGradient(colors: [Color(0xFF0460E9), Color(0xFF0D41A9)]);
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Container( decoration: BoxDecoration( color: Colors.grey[200], borderRadius: BorderRadius.circular(11), ), child: SizedBox( width: _revealWidth, child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ IconButton(icon: const Icon(Icons.edit, color: Colors.black54), onPressed: _navigateToEditPage), IconButton(icon: const Icon(Icons.download, color: Colors.black54), onPressed: () {}), ], ), ), ),
        GestureDetector(
          onHorizontalDragStart: _handleDragStart, onHorizontalDragUpdate: _handleDragUpdate, onHorizontalDragEnd: _handleDragEnd,
          child: Hero(
            tag: 'grade-hero',
            child: Material(
              type: MaterialType.transparency,
              child: Transform.translate(
                offset: Offset(-offset, 0),
                child: Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration( borderRadius: BorderRadius.circular(11), gradient: gradient, ),
                  child: Container(
                    decoration: BoxDecoration( color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(8),),
                    child: MiniGradePreview(
                      disciplinas: widget.disciplinas,
                      alturaManha: widget.alturaManha,
                      alturaAlmocoOuVao: widget.alturaAlmocoOuVao,
                      alturaTarde: widget.alturaTarde,
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
  final double alturaManha;
  final double alturaAlmocoOuVao;
  final double alturaTarde;

  const MiniGradePreview({
    super.key,
    required this.disciplinas,
    required this.alturaManha,
    required this.alturaAlmocoOuVao,
    required this.alturaTarde,
  });

  static const double _duracaoManhaMin = 210;
  static const double _duracaoAlmocoMin = 130;
  static const double _duracaoTardeMin = 220;
  static const double _duracaoTardeNoiteMin = 340;

  Widget _buildBackgroundColumns(BuildContext context) {
    final dias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];
    const corFundo = Color(0xFFdee2ec);
    const corBorda = Color(0xFFbfc5d1);
    const espessuraBorda = 2.0;
    final borderRadius = BorderRadius.circular(4);

    bool temAulaNoAlmoco(String dia) {
      for (var disciplina in disciplinas) {
        if (disciplina.diasDaSemana.contains(dia)) {
          if (_isDuringLunch(disciplina)) return true;
        }
      }
      return false;
    }

    Widget buildStyledBlock(double height, {bool isVisible = true}) {
      if (!isVisible) {
        return SizedBox(height: height);
      }
      return SizedBox(
        height: height,
        child: DottedContainer(
          borderColor: corBorda,
          strokeWidth: espessuraBorda,
          borderRadius: borderRadius,
          color: corFundo,
          dashPattern: const [3, 2],
          child: Container( // O Container interno agora preenche a largura
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: borderRadius),
          ),
        ),
      );
    }

    final double availableWidth = MediaQuery.of(context).size.width - 2 * 14.6 - (2 * 9.72) - 6;
    final double colSpacing = 6.94;
    final double colWidth = (availableWidth - (4 * colSpacing)) / 5;

    // Calculamos a altura total dos blocos para determinar o espaçamento entre eles
    final totalBlockHeight = alturaManha + alturaAlmocoOuVao + alturaTarde;
    final totalAvailableHeight = alturaManha + alturaAlmocoOuVao + alturaTarde; // Exemplo, pode ser ajustado se necessário
    final verticalSpacing = (totalAvailableHeight - totalBlockHeight) / 2;


    List<Widget> rowChildren = [];
    for (int i = 0; i < dias.length; i++) {
      final dia = dias[i];
      final bool mostrarFundoAlmoco = temAulaNoAlmoco(dia);

      rowChildren.add(
        SizedBox(
          width: colWidth,
          child: Column(
            children: [
              buildStyledBlock(alturaManha),
              SizedBox(height: verticalSpacing),
              buildStyledBlock(alturaAlmocoOuVao, isVisible: mostrarFundoAlmoco),
              SizedBox(height: verticalSpacing),
              buildStyledBlock(alturaTarde),
            ],
          ),
        ),
      );

      if (i < dias.length - 1) {
        rowChildren.add(SizedBox(width: colSpacing));
      }
    }

    return Row(children: rowChildren);
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 30.0;
    const double topSpacing = 10.0;
    const double footerHeight = 20.0;
    const double bottomSpacing = 8.0;

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: headerHeight + topSpacing,
            left: 9.72,
            right: 9.72,
            bottom: footerHeight + bottomSpacing,
          ),
          child: _buildBackgroundColumns(context),
        ),
        Positioned.fill(
          child: _buildPositionedDisciplines(context),
        ),
        _buildHeadersAndFooters(),
      ],
    );
  }

  Widget _buildPositionedDisciplines(BuildContext context) {
    final temAulaNoite = disciplinas.any(_isAfterHours);
    final double duracaoTardeAtual = temAulaNoite ? _duracaoTardeNoiteMin : _duracaoTardeMin;
    final double pxPerMinManha = alturaManha / _duracaoManhaMin;
    final double pxPerMinAlmoco = alturaAlmocoOuVao / _duracaoAlmocoMin;
    final double pxPerMinTarde = alturaTarde / duracaoTardeAtual;
    const double inicioManhaMin = 450;
    const double inicioAlmocoMin = 660;
    const double inicioTardeMin = 790;
    final dias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];
    final double availableWidth = MediaQuery.of(context).size.width - 2 * 14.6 - (2 * 9.72) - 6;
    final double colSpacing = 6.94;
    final double colWidth = (availableWidth - (4 * colSpacing)) / 5;
    List<Widget> positionedDisciplines = [];
    for (var disciplina in disciplinas) {
      try {
        final inicioMinutosTotal = _timeToMinutes(disciplina.horarioInicio);
        final fimMinutosTotal = _timeToMinutes(disciplina.horarioFim);
        double top = 0;
        double pixelsPerMinute;
        if (inicioMinutosTotal < inicioAlmocoMin) {
          pixelsPerMinute = pxPerMinManha;
          top = (inicioMinutosTotal - inicioManhaMin) * pixelsPerMinute;
        } else if (inicioMinutosTotal < inicioTardeMin) {
          pixelsPerMinute = pxPerMinAlmoco;
          top = alturaManha + (inicioMinutosTotal - inicioAlmocoMin) * pixelsPerMinute;
        } else {
          pixelsPerMinute = pxPerMinTarde;
          top = alturaManha + alturaAlmocoOuVao + (inicioMinutosTotal - inicioTardeMin) * pixelsPerMinute;
        }
        final double height = (fimMinutosTotal - inicioMinutosTotal) * pixelsPerMinute;
        for (String dia in disciplina.diasDaSemana) {
          final int diaIndex = dias.indexOf(dia);
          if (diaIndex != -1) {
            final double left = 9.72 + (diaIndex * colWidth) + (diaIndex * colSpacing);
            positionedDisciplines.add(
              Positioned(
                top: top + 30.0 + 10.0,
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
      } catch (e) { /* ignora */ }
    }
    return Stack(children: positionedDisciplines);
   }

  Widget _buildHeadersAndFooters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(9.7, 5, 9.7, 6),
      child: Column(
        children: [
          Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [ Text('GRADE HORÁRIA', style: TextStyle(fontFamily: 'AristotelicaProDisplay', fontSize: 23, fontWeight: FontWeight.bold, color: Color(0xFF0460E9))), Text('III Č', style: TextStyle(fontFamily: 'AristotelicaProDisplay', fontSize: 23, fontWeight: FontWeight.bold, color: Color(0xFF0460E9))), ], ),
          const Spacer(),
          const Align( alignment: Alignment.centerRight, child: Text('< ARRASTE PARA EDITAR', style: TextStyle(fontFamily: 'Lato', fontStyle: FontStyle.italic, color: Color(0xFFBCBEBF), fontSize: 12, fontWeight: FontWeight.bold)),),
        ],
      ),
    );
  }
  int _timeToMinutes(String time) { final parts = time.split(':'); return int.parse(parts[0]) * 60 + int.parse(parts[1]); }
  bool _isDuringLunch(Disciplina d) { try { final inicio = _timeToMinutes(d.horarioInicio); final fim = _timeToMinutes(d.horarioFim); return fim > 660 && inicio < 790; } catch (e) { return false; } }
  bool _isAfterHours(Disciplina d) { try { final fim = _timeToMinutes(d.horarioFim); return fim > 1010; } catch (e) { return false; } }
}