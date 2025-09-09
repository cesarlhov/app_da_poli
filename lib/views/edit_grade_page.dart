// lib/views/edit_grade_page.dart

import 'package:app_da_poli/components/add_disciplina_dialog.dart';
import 'package:app_da_poli/components/disciplina_card.dart';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditGradePage extends StatefulWidget {
  const EditGradePage({super.key});

  @override
  State<EditGradePage> createState() => _EditGradePageState();
}

class _EditGradePageState extends State<EditGradePage> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final List<String> horarios = ['7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17'];
  final List<String> dias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];
  final List<String> diasAbrev = ['S', 'T', 'Q', 'Q', 'S'];
  late AnimationController _contentFadeController;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _contentFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() { _showContent = true; });
        _contentFadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _contentFadeController.dispose();
    super.dispose();
  }

  void _mostrarAddDisciplinaDialog() {
    showDialog(context: context, builder: (context) => const AddDisciplinaDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned(
            top: 20.0, left: 14.6, right: 14.6, bottom: 320.0,
            child: Hero(
              tag: 'grade-hero',
              child: Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient: const LinearGradient(colors: [Color(0xFF0460E9), Color(0xFF0D41A9)]),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showContent ? 1.0 : 0.0,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return _buildGradeContent(constraints);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: () => context.pop(), child: const Text('Voltar')),
                    ElevatedButton(onPressed: _mostrarAddDisciplinaDialog, child: const Text('Adicionar Disciplina')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeContent(BoxConstraints constraints) {
    final availableHeight = constraints.maxHeight;
    final availableWidth = constraints.maxWidth;
    final double colunaSpacing = 4.0;
    final double horarioHeaderWidth = 35.0;
    final double horaHeight = availableHeight / (horarios.length + 1);
    final double diaWidth = (availableWidth - horarioHeaderWidth - (4 * colunaSpacing)) / dias.length;

    return StreamBuilder<List<Disciplina>>(
        stream: _firestoreService.getDisciplinas(), // <-- Esta chamada agora é válida
        builder: (context, snapshot) {
          final disciplinas = snapshot.data ?? [];
          return Stack(
            children: [
              ..._buildGridLines(availableWidth, horaHeight, horarioHeaderWidth, diaWidth, colunaSpacing),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: horarioHeaderWidth),
                  ...diasAbrev.asMap().entries.map((entry) {
                    int idx = entry.key; String dia = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(left: idx == 0 ? 0 : colunaSpacing),
                      child: SizedBox(
                        width: diaWidth,
                        child: Column(children: [SizedBox(height: horaHeight, child: Center(child: Text(dia, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))))]),
                      ),
                    );
                  })
                ],
              ),
              Row(children: [
                SizedBox(
                  width: horarioHeaderWidth,
                  child: Column(children: [SizedBox(height: horaHeight), ...horarios.map((h) => SizedBox(height: horaHeight, child: Center(child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)))))]),
                ),
              ]),
              ...disciplinas.expand((disciplina) {
                return _posicionarDisciplina(disciplina, diaWidth, horaHeight, horarioHeaderWidth, colunaSpacing);
              }).toList(),
            ],
          );
        });
  }
  
  List<Widget> _buildGridLines(double totalWidth, double horaHeight, double horarioHeaderWidth, double diaWidth, double colunaSpacing) {
    List<Widget> lines = [];
    for (int i = 0; i < horarios.length; i++) {
      lines.add(Positioned(top: (i + 1.5) * horaHeight, left: 0, right: 0, child: Container(height: 1.0, color: Colors.grey.shade300)));
    }
    for (int i = 0; i < dias.length - 1; i++) {
      lines.add(Positioned(top: horaHeight, bottom: 0, left: horarioHeaderWidth + ((i + 1) * diaWidth) + (i * colunaSpacing) + (colunaSpacing / 2), child: Container(width: 1.0, color: Colors.grey.shade300)));
    }
    return lines;
  }

  List<Positioned> _posicionarDisciplina(Disciplina disciplina, double diaWidth, double horaHeight, double horarioHeaderWidth, double colunaSpacing) {
    List<Positioned> widgetsDisciplina = [];
    try {
      final inicioParts = disciplina.horarioInicio.split(':');
      final fimParts = disciplina.horarioFim.split(':');
      final inicioMinutos = int.parse(inicioParts[0]) * 60 + int.parse(inicioParts[1]);
      final fimMinutos = int.parse(fimParts[0]) * 60 + int.parse(fimParts[1]);
      final double top = ((inicioMinutos - 7.5 * 60) / 60) * horaHeight + horaHeight;
      final double height = ((fimMinutos - inicioMinutos) / 60) * horaHeight;
      for (String dia in disciplina.diasDaSemana) {
        final int diaIndex = dias.indexOf(dia);
        if (diaIndex != -1) {
          final double left = horarioHeaderWidth + (diaIndex * diaWidth) + (diaIndex * colunaSpacing);
          widgetsDisciplina.add(
            Positioned(
              top: top, left: left, width: diaWidth, height: height - 2,
              child: DisciplinaCard(disciplina: disciplina, onTap: () => _mostrarDetalhesDisciplina(disciplina)),
            ),
          );
        }
      }
    } catch (e) { print("Erro ao processar horário para a disciplina ${disciplina.nome}: $e"); }
    return widgetsDisciplina;
  }
  
  void _mostrarDetalhesDisciplina(Disciplina disciplina) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(disciplina.nome),
      content: Text('Código: ${disciplina.codigo}\nProfessor: ${disciplina.professor}\nSala: ${disciplina.sala}\nHorário: ${disciplina.horarioInicio} - ${disciplina.horarioFim}'),
      actions: [
        TextButton(child: const Text('Fechar'), onPressed: () => Navigator.of(context).pop()),
        TextButton(
          child: const Text('Apagar', style: TextStyle(color: Colors.red)),
          onPressed: () { _firestoreService.deleteDisciplina(disciplina.id); Navigator.of(context).pop(); },
        ),
      ],
    ));
  }
}