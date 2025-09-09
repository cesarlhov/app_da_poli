// lib/views/jupiter_view.dart

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

  static const double _manhaHeight = 62.5;
  static const double _tardeHeightPadrao = 62.5;
  static const double _tardeHeightEstendida = 93.75;
  static const double _almocoGapPadrao = 13.88;
  static const double _almocoBlocoHeight = 31.25;
  static const double _verticalPaddings = 7.3 + 6.7;
  static const double _internalSpacers = 5.0;

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
    final almocoHeight = config.temAulaAlmoco ? _almocoBlocoHeight : _almocoGapPadrao;
    final tardeHeight = config.temAulaNoite ? _tardeHeightEstendida : _tardeHeightPadrao;
    return _manhaHeight + almocoHeight + tardeHeight + _verticalPaddings + _internalSpacers;
  }

  @override
  double get minExtent => maxExtent / 2;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.6),
      child: SlidableGradePreview(
        key: slidableGradeKey,
        disciplinas: disciplinas,
        onGradeEdited: onGradeEdited,
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
          Row(
            children: [
              Icon(Icons.cloud_outlined, color: Colors.grey[300], size: 40),
              const SizedBox(width: 20),
              SizedBox(width: 76, height: 76, child: Image.asset('assets/images/gremio_logo.png')),
            ],
          ),
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

        return CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeaderDelegate(child: _buildHeader(user), height: 114),
            ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14.6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 7),
                        const Text('HOJE', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                        Container(height: 800, color: Colors.red.withOpacity(0.1)),
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

// O StickyHeaderDelegate genérico
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