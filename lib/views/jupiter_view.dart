// lib/views/jupiter_view.dart

import 'package:app_da_poli/components/aula_card.dart';
import 'package:app_da_poli/components/slidable_grade_preview.dart';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/models/user_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';

class CollapsingGradeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<Disciplina> disciplinas;
  final GlobalKey<SlidableGradePreviewState> slidableGradeKey;
  final VoidCallback onGradeEdited;

  CollapsingGradeHeaderDelegate({
    required this.disciplinas,
    required this.slidableGradeKey,
    required this.onGradeEdited,
  });

  // --- CONTROLE CENTRAL DE ALTURAS E ESPAÇAMENTOS ---
  // Edite apenas aqui para ajustar o layout da grade.

  // 1. Espaçamentos internos ("respiro")
  static const double _topSpacing = 16.0;
  static const double _bottomSpacing = 8.0;
  static const double _headerHeight = 30.0;
  static const double _footerHeight = 20.0;

  // 2. Altura dos blocos de aula
  static const double _alturaBlocoManha = 62.5;
  static const double _alturaBlocoAlmoco = 31.25; // Se TIVER aula
  static const double _alturaBlocoTarde = 62.5;
  static const double _alturaBlocoTardeNoite = 93.75; // Se tiver aula à noite

  // 3. VÃO DO ALMOÇO (QUANDO NÃO HÁ AULA) -- EDITE AQUI
  static const double _alturaVaoAlmoco = 13.88;

  ({bool temAulaAlmoco, bool temAulaNoite}) _analyzeSchedule() {
    bool temAulaAlmoco = disciplinas.any((d) {
      try {
        final i = int.parse(d.horarioInicio.split(':')[0]) * 60 + int.parse(d.horarioInicio.split(':')[1]);
        final f = int.parse(d.horarioFim.split(':')[0]) * 60 + int.parse(d.horarioFim.split(':')[1]);
        return f > 660 && i < 790;
      } catch (e) { return false; }
    });
    bool temAulaNoite = disciplinas.any((d) {
      try {
        final f = int.parse(d.horarioFim.split(':')[0]) * 60 + int.parse(d.horarioFim.split(':')[1]);
        return f > 1010;
      } catch (e) { return false; }
    });
    return (temAulaAlmoco: temAulaAlmoco, temAulaNoite: temAulaNoite);
  }

  @override
  double get maxExtent {
    final config = _analyzeSchedule();
    final alturaMeio = config.temAulaAlmoco ? _alturaBlocoAlmoco : _alturaVaoAlmoco;
    final alturaTarde = config.temAulaNoite ? _alturaBlocoTardeNoite : _alturaBlocoTarde;

    // A altura total é a soma de todas as partes, sem mágicas.
    return _headerHeight + _topSpacing + _alturaBlocoManha + alturaMeio + alturaTarde + _bottomSpacing + _footerHeight;
  }

  @override
  double get minExtent => maxExtent; // Evita o colapso visual

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Passamos as alturas exatas para o filho saber como se desenhar.
    final config = _analyzeSchedule();
    final alturaMeio = config.temAulaAlmoco ? _alturaBlocoAlmoco : _alturaVaoAlmoco;
    final alturaTarde = config.temAulaNoite ? _alturaBlocoTardeNoite : _alturaBlocoTarde;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 14.6),
      child: SlidableGradePreview(
        key: slidableGradeKey,
        disciplinas: disciplinas,
        onGradeEdited: onGradeEdited,
        // Passando as alturas exatas para a MiniGradePreview
        alturaManha: _alturaBlocoManha,
        alturaAlmocoOuVao: alturaMeio,
        alturaTarde: alturaTarde,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant CollapsingGradeHeaderDelegate oldDelegate) {
    return disciplinas != oldDelegate.disciplinas;
  }
}

class JupiterView extends StatefulWidget {
  const JupiterView({super.key});
  @override
  State<JupiterView> createState() => _JupiterViewState();
}

class _JupiterViewState extends State<JupiterView> {
  final FirestoreService _firestoreService = FirestoreService();
  final GlobalKey<SlidableGradePreviewState> _slidableGradeKey = GlobalKey();
  late Future<Map<String, dynamic>> _initialDataFuture;

  @override
  void initState() {
    super.initState();
    _initialDataFuture = _loadInitialData();
  }

  Future<Map<String, dynamic>> _loadInitialData() async {
    final user = await _firestoreService.getUserProfileOnce();
    final disciplinas = await _firestoreService.getDisciplinasOnce();
    return {'user': user, 'disciplinas': disciplinas};
  }

  void _refreshData() {
    setState(() {
      _initialDataFuture = _loadInitialData();
    });
  }

  List<Disciplina> _getAulasDeHoje(List<Disciplina> todasAsDisciplinas) {
    final Map<int, String> weekdayMap = { 1: 'Segunda', 2: 'Terça', 3: 'Quarta', 4: 'Quinta', 5: 'Sexta', 6: 'Sábado', 7: 'Domingo' };
    final String hoje = weekdayMap[DateTime.now().weekday] ?? '';
    if (hoje.isEmpty) return [];
    final aulasHoje = todasAsDisciplinas.where((d) => d.diasDaSemana.contains(hoje)).toList();
    aulasHoje.sort((a, b) {
      try {
        final aInicio = int.parse(a.horarioInicio.split(':')[0]) * 60 + int.parse(a.horarioInicio.split(':')[1]);
        final bInicio = int.parse(b.horarioInicio.split(':')[0]) * 60 + int.parse(b.horarioInicio.split(':')[1]);
        return aInicio.compareTo(bInicio);
      } catch (e) { return 0; }
    });
    return aulasHoje;
  }

  Widget _buildHeader(AppUser user) {
    const double headerFontSize = 21.75;
    const Color poliBlue = Color(0xFF0460E9);
    const Color poliBlack = Color(0xFF101010);
    const Color poliGrey = Color(0xFFBCBEBF);
    const headerTextStyle = TextStyle( fontFamily: 'LeagueSpartan', fontWeight: FontWeight.w900, fontSize: headerFontSize, letterSpacing: -0.6, height: 0.87, );
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 14.6),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('BOM DIA', style: headerTextStyle.copyWith(color: poliBlue)),
              const SizedBox(height: 1),
              Text('CESAR HOV', style: headerTextStyle.copyWith(color: poliBlack)),
              const SizedBox(height: 1),
              Text('ENG. QUÍMICA', style: headerTextStyle.copyWith(color: poliGrey, fontWeight: FontWeight.w900)),
            ],
          ),
          SizedBox(width: 76, height: 76, child: Image.asset('assets/images/gremio_logo.png')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _initialDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!['user'] == null) {
          return const Center(child: Text('Erro ao carregar dados.'));
        }
        final user = snapshot.data!['user'] as AppUser;
        final disciplinas = snapshot.data!['disciplinas'] as List<Disciplina>;
        final aulasDeHoje = _getAulasDeHoje(disciplinas);
        return CustomScrollView(
          slivers: [
            SliverPersistentHeader( pinned: true, delegate: StickyHeaderDelegate(child: _buildHeader(user), height: 114), ),
            SliverPersistentHeader(
              pinned: true,
              delegate: CollapsingGradeHeaderDelegate(
                disciplinas: disciplinas,
                slidableGradeKey: _slidableGradeKey,
                onGradeEdited: _refreshData,
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                GestureDetector(
                  onTap: () => _slidableGradeKey.currentState?.closeMenu(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14.6, 7, 14.6, 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text( 'HOJE', style: TextStyle( fontSize: 25, fontWeight: FontWeight.w900, fontFamily: 'LeagueSpartan',),),
                        const SizedBox(height: 10),
                        if (aulasDeHoje.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(
                              child: Text( 'Nenhuma aula hoje. Aproveite!', style: TextStyle(fontSize: 16, color: Colors.grey),),
                            ),
                          )
                        else
                          ListView.builder(
                            itemCount: aulasDeHoje.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final aula = aulasDeHoje[index];
                              return AulaCard(disciplina: aula);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ]),
            )
          ],
        );
      },
    );
  }
}

class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double? height;
  StickyHeaderDelegate({required this.child, this.height});
  @override
  double get maxExtent => height!;
  @override
  double get minExtent => height!;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;
  @override
  bool shouldRebuild(StickyHeaderDelegate oldDelegate) => true;
}