// lib/views/jupiter_view.dart

import 'package:app_da_poli/components/slidable_grade_preview.dart';
import 'package:app_da_poli/components/sticky_header_delegate.dart';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/models/user_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';

class JupiterView extends StatefulWidget {
  const JupiterView({super.key});

  @override
  State<JupiterView> createState() => _JupiterViewState();
}

class _JupiterViewState extends State<JupiterView> {
  final FirestoreService _firestoreService = FirestoreService();
  final GlobalKey<SlidableGradePreviewState> _slidableGradeKey = GlobalKey();

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 80.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('BOM DIA', style: headerTextStyle.copyWith(color: poliBlue)),
                const SizedBox(height: 1),
                Text('CESAR HOV', style: headerTextStyle.copyWith(color: poliBlack)),
                const SizedBox(height: 1),
                Text(
                  'ENG. QUÍMICA',
                  style: headerTextStyle.copyWith(color: poliGrey, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
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
                  delegate: StickyHeaderDelegate(child: _buildHeader(user), height: 120),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: StickyHeaderDelegate(
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.symmetric(horizontal: 14.6, vertical: 8.0),
                      child: StreamBuilder<List<Disciplina>>(
                        stream: _firestoreService.getDisciplinas(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(height: 230);
                          }
                          final disciplinas = snapshot.data ?? [];
                          return SlidableGradePreview(
                            key: _slidableGradeKey,
                            disciplinas: disciplinas,
                          );
                        },
                      ),
                    ),
                    height: 250.0,
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 7),
                          const Text(
                            'HOJE',
                            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                          ),
                          Container(height: 200, color: Colors.red.withOpacity(0.1)),
                          Container(height: 200, color: Colors.green.withOpacity(0.1)),
                          Container(height: 200, color: Colors.yellow.withOpacity(0.1)),
                        ],
                      ),
                    ),
                  ]),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}