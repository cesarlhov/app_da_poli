import 'dart:math';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/models/user_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:app_da_poli/views/edit_grade_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//-------------------------------------------------
// TELA DE INÍCIO COM LAYOUT E FÍSICA AVANÇADOS
//-------------------------------------------------
class GradeView extends StatefulWidget {
  const GradeView({super.key});

  @override
  State<GradeView> createState() => _GradeViewState();
}

class _GradeViewState extends State<GradeView> {
  final FirestoreService _firestoreService = FirestoreService();
  final GlobalKey<_SlidableGradePreviewState> _slidableGradeKey = GlobalKey();

  Widget _buildHeader(AppUser user) {
    const double headerFontSize = 21.75;
    const Color poliBlue = Color(0xFF0460E9);
    const Color poliBlack = Color(0xFF101010);
    const Color poliGrey = Color(0xFFBCBEBF);

    const headerTextStyle = TextStyle(
      fontFamily: 'LeagueSpartan',
      fontWeight: FontWeight.w900,
      fontSize: headerFontSize,
      letterSpacing: -0.6,
      height: 0.87,
    );

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 14.6, vertical: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start, // ou center
        children: [
          // Texto à esquerda
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('BOM DIA', style: headerTextStyle.copyWith(color: poliBlue)),
              const SizedBox(height: 1),
              Text('CESAR HOV',
                  style: headerTextStyle.copyWith(color: poliBlack)),
              const SizedBox(height: 1),
              Text(
                'ENG. QUÍMICA',
                style: headerTextStyle.copyWith(
                    color: poliGrey, fontWeight: FontWeight.w900),
              ),
            ],
          ),

          // Logos/ícones à direita
          Row(
            children: [
              Icon(Icons.cloud_outlined, color: Colors.grey[300], size: 40),
              const SizedBox(width: 20),
              SizedBox(
                width: 80,
                height: 80,
                child: Image.asset('assets/images/gremio_logo.png'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<AppUser?>(
        stream: _firestoreService.getUserProfile(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text('A carregar perfil...'));
          }

          final user = userSnapshot.data!;

          return GestureDetector(
            onTap: () => _slidableGradeKey.currentState?.closeMenu(),
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(child: _buildHeader(user), height: 120),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 14.6, vertical: 8.0),
                    child: StreamBuilder<List<Disciplina>>(
                      stream: _firestoreService.getDisciplinas(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final disciplinas = snapshot.data ?? [];
                        return SlidableGradePreview(
                          key: _slidableGradeKey,
                          disciplinas: disciplinas,
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 7),
                        const Text(
                          'HOJE',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w900),
                        ),
                        Container(
                            height: 200, color: Colors.red.withOpacity(0.1)),
                        Container(
                            height: 200,
                            color: Colors.green.withOpacity(0.1)),
                        Container(
                            height: 200,
                            color: Colors.yellow.withOpacity(0.1)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double? height;
  final bool isVariable;

  _StickyHeaderDelegate({required this.child, this.height, this.isVariable = false});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child; // <-- Retorne o child diretamente
  }

  @override
  double get maxExtent => isVariable ? 250 : height!;
  @override
  double get minExtent => isVariable ? 220 : height!;

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) => true;
}

// O widget da Grade Deslizante continua igual
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

class MiniGradePreview extends StatelessWidget {
  final List<Disciplina> disciplinas;
  const MiniGradePreview({super.key, required this.disciplinas});
  bool _temAulaNoSlot(String dia, int horaSlot, List<Disciplina> disciplinas) {
    final slotInicioMinutos = horaSlot * 60;
    final slotFimMinutos = (horaSlot + 2) * 60;
    for (var disciplina in disciplinas) {
      if (disciplina.diasDaSemana.contains(dia)) {
        try {
          final inicioParts = disciplina.horarioInicio.split(':');
          final fimParts = disciplina.horarioFim.split(':');
          final disciplinaInicioMinutos =
              int.parse(inicioParts[0]) * 60 + int.parse(inicioParts[1]);
          final disciplinaFimMinutos =
              int.parse(fimParts[0]) * 60 + int.parse(fimParts[1]);
          if (disciplinaInicioMinutos < slotFimMinutos &&
              disciplinaFimMinutos > slotInicioMinutos) {
            return true;
          }
        } catch (e) {
          continue;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final dias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];
    final horas = [8, 10, 12, 14, 16];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GRADE HORÁRIA',
                style: TextStyle(
                    fontFamily: 'Aristotelica',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0460E9))),
            const Text('III Č',
                style: TextStyle(
                    fontFamily: 'Aristotelica',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0460E9))),
          ],
        ),
        const SizedBox(height: 6),
        Table(
          children: List.generate(
            horas.length,
                (rowIndex) => TableRow(
              children: List.generate(
                dias.length,
                    (colIndex) {
                  final diaAtual = dias[colIndex];
                  final horaAtual = horas[rowIndex];
                  final temAula =
                  _temAulaNoSlot(diaAtual, horaAtual, disciplinas);
                  return Container(
                    height: 22,
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: temAula
                          ? Colors.blue.withOpacity(1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        const Align(
          alignment: Alignment.centerRight,
          child: Text('< ARRASTE PARA EDITAR',
              style: TextStyle(
                  fontFamily: 'Lato',
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}


