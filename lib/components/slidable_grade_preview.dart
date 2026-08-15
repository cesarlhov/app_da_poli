// lib/components/slidable_grade_preview.dart

import 'dart:math';
import 'package:app_da_poli/components/dotted_container.dart';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/providers/user_provider.dart'; // 🟢 NOVO IMPORT
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // 🟢 NOVO IMPORT

class SlidableGradePreview extends StatefulWidget {
  final List<Disciplina> disciplinas;
  final VoidCallback onGradeEdited;
  final VoidCallback? onShrink;
  
  final double scrollProgress;
  final double shrinkValue;
  final double espacoGradeAteArraste;
  final double espacoArrasteAteBase;
  final double espacoBaseSemFooter; 

  const SlidableGradePreview({
    super.key,
    required this.disciplinas,
    required this.onGradeEdited,
    this.onShrink,
    this.scrollProgress = 0.0,
    this.shrinkValue = 0.0,
    this.espacoGradeAteArraste = 6.0,
    this.espacoArrasteAteBase = 15.0,
    this.espacoBaseSemFooter = 16.0,
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
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && widget.onShrink != null) {
        widget.onShrink!();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void closeMenu() {
    if (_animationController.value != 0.0) _animationController.reverse();
  }

  void _navigateToEditPage() async {
    closeMenu();
    await Future.delayed(const Duration(milliseconds: 210));
    if (mounted) {
      context.push('/edit-grade', extra: {'disciplinas': widget.disciplinas}).then((_) => widget.onGradeEdited());
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final newPosition = _animationController.value - (details.primaryDelta! / _revealWidth);
    _animationController.value = newPosition.clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_animationController.value > 0.5) _animationController.forward();
    else _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Positioned(
          top: 0, bottom: 0, right: 0,
          child: _buildRevealOptions(),
        ),
        GestureDetector(
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final offset = _animationController.value * _revealWidth;
              return Transform.translate(offset: Offset(-offset, 0), child: child);
            },
            // 🟢 O HERO VOLTOU AQUI PARA FAZER A ANIMAÇÃO DE VOO!
            child: Hero(
              tag: 'grade-hero',
              child: Material(
                type: MaterialType.transparency,
                child: _MiniGradePreview(
                  disciplinas: widget.disciplinas,
                  scrollProgress: widget.scrollProgress,
                  shrinkValue: widget.shrinkValue,
                  espacoGradeAteArraste: widget.espacoGradeAteArraste,
                  espacoArrasteAteBase: widget.espacoArrasteAteBase,
                  espacoBaseSemFooter: widget.espacoBaseSemFooter, 
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevealOptions() {
    return Container(
      width: _revealWidth + 20,
      decoration: BoxDecoration(color: const Color(0xFF5E6982), borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(icon: SvgPicture.asset('assets/images/editar_icon.svg', colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn), width: 28), onPressed: _navigateToEditPage),
            IconButton(icon: SvgPicture.asset('assets/images/baixar_icon.svg', colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn), width: 28), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class _MiniGradePreview extends StatelessWidget {
  final List<Disciplina> disciplinas;
  final double scrollProgress;
  final double shrinkValue; 
  final double espacoGradeAteArraste;
  final double espacoArrasteAteBase;
  final double espacoBaseSemFooter;
  
  const _MiniGradePreview({
    required this.disciplinas, 
    this.scrollProgress = 0.0, 
    this.shrinkValue = 0.0, 
    this.espacoGradeAteArraste = 6.0,
    this.espacoArrasteAteBase = 15.0,
    this.espacoBaseSemFooter = 16.0
  });

  double get _escalaAlturaGrade => (1.0 - scrollProgress * 0.5).clamp(0.5, 1.0); 

  double get alturaManhaPadrao => 64.0 * _escalaAlturaGrade; 
  double get minutosManhaPadrao => 210.0; 
  double get pixelsPorMinuto => alturaManhaPadrao / minutosManhaPadrao; 

  final double espacoTopoAteTitulo = 12.0;
  final double espacoTituloAteGrade = 4.0;
  final double espacoAcimaLinha = 6.0;
  final double espacoAbaixoLinha = 6.0;

  final double tamanhoTitulo = 19.0;
  final double tamanhoCreditos = 19.0;

  final bool _usarLarguraFixaColuna = false; 
  final double _larguraFixaColunaPadrao = 45.0; 

  final double _espessuraBorda = 1.5; 
  final double _raioBorda = 8.0;
  final Color _corBordaInicio = const Color(0xFF0460E9);
  final Color _corBordaFim = const Color(0xFF0D41A9);
  final Color _corFundoInterno = const Color(0xFFF0F0F0);

  final double _paddingLateralGrade = 12.0; 
  final double _espacoEntreColunas = 7.0;

  final Color _corTitulo = const Color(0xFF0460E9);
  final Color _corArraste = const Color(0xFFBCBEBF);
  final double _linhaAlmocoEspessura = 4.0;
  final double _pontilhadoEspessura = 1.5;
  final double _pontilhadoRaio = 6.0;
  final double _pontilhadoTraco = 2.0;
  final double _pontilhadoEspaco = 2.0;
  final Color _corGradeLinha = const Color(0xFFBFC5D1);
  final Color _corFundoCard = const Color(0xFFDEE2EC);

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - BLOQUINHOS DAS DISCIPLINAS
  // =========================================================================
  final double _tamanhoTextoBloco = 15.0; 
  final FontWeight _pesoFonteBloco = FontWeight.w700; 
  final double _opacidadeTextoBloco = 0.5; 
  final Color _corTextoBloco = const Color(0xFFF0F0F0); 
  final double _paddingTopTextoBloco = 8.0; 
  
  final Color _corEspecialPQI = const Color(0xFF284ACE); 
  // =========================================================================

  int _timeToMin(String time) {
    if (time.isEmpty || !time.contains(':')) return 0;
    try {
      final parts = time.split(':');
      return int.parse(parts[0].trim()) * 60 + int.parse(parts[1].trim());
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double alturaTextoArraste = 14.0; 
    final double openHeight = espacoGradeAteArraste + alturaTextoArraste + espacoArrasteAteBase;
    final double closedHeight = espacoBaseSemFooter;
    final double currentFooterHeight = (openHeight * (1 - shrinkValue)) + (closedHeight * shrinkValue);

    return CustomPaint(
      foregroundPainter: _GradientBorderPainter(
        strokeWidth: _espessuraBorda,
        radius: _raioBorda,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_corBordaInicio, _corBordaFim]),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_raioBorda - (_espessuraBorda / 2)),
        child: Container(
          color: _corFundoInterno,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                _buildHeader(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _paddingLateralGrade),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return _buildGridEngine(context, constraints); // 🟢 CONTEXT ENVIADO
                    },
                  ),
                ),
                SizedBox(
                  height: currentFooterHeight, 
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Opacity(
                      opacity: (1 - (shrinkValue * 1.5)).clamp(0.0, 1.0), 
                      child: Padding(
                        padding: EdgeInsets.only(top: espacoGradeAteArraste, right: _paddingLateralGrade),
                        child: Text('< ARRASTE PARA EDITAR', style: TextStyle(fontFamily: 'Lato', fontStyle: FontStyle.italic, color: _corArraste, fontSize: 12.0, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(top: espacoTopoAteTitulo, bottom: espacoTituloAteGrade, left: _paddingLateralGrade, right: _paddingLateralGrade),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('GRADE HORÁRIA', style: TextStyle(fontFamily: 'Aristotelica', fontSize: tamanhoTitulo, fontWeight: FontWeight.w700, color: _corTitulo)),
          Text('24 Č', style: TextStyle(fontFamily: 'Aristotelica', fontSize: tamanhoCreditos, fontWeight: FontWeight.w700, color: _corTitulo)),
        ],
      ),
    );
  }

  // 🟢 A MÁGICA FOI FEITA AQUI (NO MOTOR DA GRADE)
  Widget _buildGridEngine(BuildContext context, BoxConstraints constraints) {
    // Busca as turmas que o aluno está inscrito
    final user = context.read<UserProvider>().currentUser;
    final turmasIds = user?.turmasIds ?? [];

    int minMins = 450; 
    int maxMins = 1000; 
    List<bool> dayHasLunch = List.filled(5, false);

    // 1. Fase de Descoberta: Ajusta o tamanho da grade e o almoço
    for (var d in disciplinas) {
      var turmasValidas = d.turmas.where((t) => turmasIds.contains(t.id)).toList();
      if (turmasValidas.isEmpty) turmasValidas = d.turmas; // Fallback se o banco não tiver turmasIds salvas ainda

      for (var t in turmasValidas) {
        for (var hor in t.horarios) {
          int start = _timeToMin(hor.inicio);
          int end = _timeToMin(hor.fim);
          if (start == 0 || end == 0) continue;

          if (start < minMins) minMins = start;
          if (end > maxMins) maxMins = end;

          if (start < 790 && end > 660) {
            // 🟢 Correção do bug: .toUpperCase() para achar os dias perfeitamente
            int index = ['SEGUNDA','TERÇA','QUARTA','QUINTA','SEXTA'].indexOf(hor.dia.toUpperCase());
            if (index != -1) dayHasLunch[index] = true;
          }
        }
      }
    }

    double extraTop = (450 - minMins) > 0 ? (450 - minMins) * pixelsPorMinuto : 0.0;
    double extraBottom = (maxMins > 1000) ? (maxMins - 1000) * pixelsPorMinuto : 0.0;
    
    double alturaManha = 210 * pixelsPorMinuto;
    double alturaTarde = 210 * pixelsPorMinuto;
    double alturaAlmoco = espacoAcimaLinha + _linhaAlmocoEspessura + espacoAbaixoLinha; 
    
    double totalGridHeight = extraTop + alturaManha + alturaAlmoco + alturaTarde + extraBottom;

    double timeToY(int t) {
      if (t <= 660) {
        return extraTop + (t - 450) * pixelsPorMinuto;
      } else if (t >= 790) {
        return extraTop + alturaManha + alturaAlmoco + (t - 790) * pixelsPorMinuto;
      } else {
        return extraTop + alturaManha + ((t - 660) / 130.0) * alturaAlmoco;
      }
    }

    double availableWidth = max(0.0, constraints.maxWidth);
    double autoColWidth = max(0.0, (availableWidth - (4 * _espacoEntreColunas)) / 5);
    double colWidth = _usarLarguraFixaColuna ? _larguraFixaColunaPadrao : autoColWidth;
    double totalGridWidth = (colWidth * 5) + (4 * _espacoEntreColunas);

    Widget buildDottedBox(double h) {
      return SizedBox(
        height: max(0.0, h),
        child: DottedContainer(
          borderColor: _corGradeLinha,
          strokeWidth: _pontilhadoEspessura,
          borderRadius: BorderRadius.circular(_pontilhadoRaio),
          color: _corFundoCard.withOpacity(0.5),
          dashPattern: [_pontilhadoTraco, _pontilhadoEspaco],
          child: Container(),
        ),
      );
    }

    List<Widget> classBlocks = [];
    double fadeOutTexto = (1.0 - (scrollProgress / 0.70)).clamp(0.0, 1.0);

    // 2. Fase de Construção: Cria os Bloquinhos Coloridos
    for (var d in disciplinas) {
      String siglaPura = d.codigo.replaceAll(RegExp(r'[^A-Za-z]'), '').toUpperCase();
      Color corBloco = siglaPura == 'PQI' ? _corEspecialPQI : d.cor;

      var turmasValidas = d.turmas.where((t) => turmasIds.contains(t.id)).toList();
      if (turmasValidas.isEmpty) turmasValidas = d.turmas;

      for (var t in turmasValidas) {
        for (var hor in t.horarios) {
          int start = _timeToMin(hor.inicio);
          int end = _timeToMin(hor.fim);
          if (start == 0 || end == 0) continue; 

          double top = max(0.0, timeToY(start)); 
          double height = max(0.0, timeToY(end) - top); 
          
          int diaIndex = ['SEGUNDA','TERÇA','QUARTA','QUINTA','SEXTA'].indexOf(hor.dia.toUpperCase());
          if (diaIndex != -1) {
            classBlocks.add(
              Positioned(
                top: top, left: diaIndex * (colWidth + _espacoEntreColunas), width: colWidth, height: height,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0.5, vertical: 0.5),
                  decoration: BoxDecoration(color: corBloco, borderRadius: BorderRadius.circular(_pontilhadoRaio)),
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(top: _paddingTopTextoBloco * _escalaAlturaGrade), 
                  child: Opacity(
                    opacity: (fadeOutTexto * _opacidadeTextoBloco).clamp(0.0, 1.0), 
                    child: Text(
                      siglaPura, 
                      style: TextStyle(
                        fontFamily: 'Aristotelica', 
                        fontWeight: _pesoFonteBloco, 
                        fontSize: _tamanhoTextoBloco * _escalaAlturaGrade, 
                        color: _corTextoBloco,
                        height: 1.0, 
                      )
                    ),
                  ),
                )
              )
            );
          }
        }
      }
    }

    // 3. Fase do Almoço: Desenha a linha sólida
    List<Widget> lineSegments = [];
    int startIdx = -1;
    for (int i = 0; i <= 5; i++) {
      if (i < 5 && !dayHasLunch[i]) {
        if (startIdx == -1) startIdx = i; 
      } else {
        if (startIdx != -1) {
          double leftPos = startIdx * (colWidth + _espacoEntreColunas);
          int count = i - startIdx;
          double lineWidth = max(0.0, (count * colWidth) + ((count - 1) * _espacoEntreColunas));
          
          lineSegments.add(
            Positioned(
              left: leftPos,
              width: lineWidth,
              top: extraTop + alturaManha + espacoAcimaLinha, 
              height: _linhaAlmocoEspessura,
              child: Container(
                decoration: BoxDecoration(
                  color: _corGradeLinha,
                  borderRadius: BorderRadius.circular(_linhaAlmocoEspessura / 2),
                ),
              ),
            )
          );
          startIdx = -1;
        }
      }
    }

    return SizedBox(
      height: max(0.0, totalGridHeight), 
      child: Align(
        alignment: Alignment.center, 
        child: SizedBox(
          width: totalGridWidth,
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (i) {
                  return SizedBox(
                    width: colWidth,
                    child: Column(
                      children: [
                        if (extraTop > 0) SizedBox(height: extraTop),
                        dayHasLunch[i] ? buildDottedBox(alturaManha + alturaAlmoco + alturaTarde) : buildDottedBox(alturaManha),
                        if (!dayHasLunch[i]) SizedBox(height: alturaAlmoco),
                        if (!dayHasLunch[i]) buildDottedBox(alturaTarde),
                        if (extraBottom > 0) SizedBox(height: extraBottom),
                      ],
                    )
                  );
                }),
              ),
              ...lineSegments, 
              ...classBlocks,
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double strokeWidth;
  final double radius;
  final Gradient gradient;

  _GradientBorderPainter({required this.strokeWidth, required this.radius, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth);
    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius - (strokeWidth / 2)));
    final Paint paint = Paint()..shader = gradient.createShader(rect)..strokeWidth = strokeWidth..style = PaintingStyle.stroke;
    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter old) => old.strokeWidth != strokeWidth || old.radius != radius || old.gradient != gradient;
}