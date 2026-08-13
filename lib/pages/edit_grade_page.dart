import 'dart:async';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class EditGradePage extends StatefulWidget {
  final List<Disciplina> initialDisciplinas;
  final Map<String, double> gradeMetrics;

  const EditGradePage({
    super.key,
    required this.initialDisciplinas,
    required this.gradeMetrics,
  });

  @override
  State<EditGradePage> createState() => _EditGradePageState();
}

class _EditGradePageState extends State<EditGradePage> with SingleTickerProviderStateMixin {
  late List<Disciplina> _disciplinas;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _disciplinas = List.from(widget.initialDisciplinas);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'grade-hero',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 14.6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          gradient: const LinearGradient(colors: [Color(0xFF0460E9), Color(0xFF0D41A9)]),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildGradeContent(),
                  ),
                ],
              ),
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildBottomControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14.6, 10, 14.6, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'GRADE HORÁRIA',
            style: TextStyle(
              fontFamily: 'LeagueSpartan',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0460E9),
            ),
          ),
          const Text(
            '24 Č',
            style: TextStyle(
              fontFamily: 'LeagueSpartan',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0460E9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeContent() {
    return const Center(child: Text("Conteúdo da Grade Aqui", style: TextStyle(color: Colors.black)));
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.6, vertical: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFdee2ec),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBCBEBF)),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: const Text(
                    'SELECIONE UMA DISCIPLINA',
                    style: TextStyle(color: Color(0xFFBCBEBF), fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF0460E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/upload_icon.svg',
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildControlChip('TURMA'),
              _buildControlChip('DEPARTAMENTO'),
              _buildControlChip('EDIT'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0460E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      'SALVAR',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCC00),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.star, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFdee2ec),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBCBEBF)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFBCBEBF),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}