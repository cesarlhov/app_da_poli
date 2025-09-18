// lib/views/edit_grade_page.dart

import 'package:app_da_poli/components/add_disciplina_dialog.dart';
import 'package:app_da_poli/components/disciplina_card.dart';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer; // Para logging em vez de print

/// Página de edição da grade horária, mostrada sobre a tela principal.
class EditGradePage extends StatefulWidget {
  const EditGradePage({super.key});

  @override
  State<EditGradePage> createState() => _EditGradePageState();
}

class _EditGradePageState extends State<EditGradePage> {
  final FirestoreService _firestoreService = FirestoreService();

  // Constantes para a construção da grade.
  static const List<String> _horarios = ['07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18'];
  static const List<String> _dias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];
  static const List<String> _diasAbrev = ['S', 'T', 'Q', 'Q', 'S'];

  /// Exibe o diálogo para adicionar uma nova disciplina.
  void _mostrarAddDisciplinaDialog() {
    showDialog(context: context, builder: (context) => const AddDisciplinaDialog());
  }

  /// Exibe os detalhes de uma disciplina e oferece a opção de apagar.
  void _mostrarDetalhesDisciplina(Disciplina disciplina) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(disciplina.nome),
        content: Text('Código: ${disciplina.codigo}\nProfessor: ${disciplina.professor}\nSala: ${disciplina.sala}\nHorário: ${disciplina.horarioInicio} - ${disciplina.horarioFim}'),
        actions: [
          TextButton(
            child: const Text('Apagar', style: TextStyle(color: Colors.red)),
            onPressed: () {
              _firestoreService.deleteDisciplina(disciplina.id);
              Navigator.of(context).pop(); // Fecha o diálogo
            },
          ),
          TextButton(
            child: const Text('Fechar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // O fundo é controlado pela PageRouteBuilder
      body: Column(
        children: [
          Expanded(
            child: Hero(
              tag: 'grade-hero', // Animação a partir da minigrade
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  margin: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 20),
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
                    child: _buildGradeContent(),
                  ),
                ),
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// Constrói a área principal da grade com os horários e disciplinas.
  Widget _buildGradeContent() {
    return StreamBuilder<List<Disciplina>>(
      stream: _firestoreService.getDisciplinas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final disciplinas = snapshot.data ?? [];
        
        return LayoutBuilder(
          builder: (context, constraints) {
            final double horaHeight = constraints.maxHeight / (_horarios.length + 1);
            final double horarioHeaderWidth = 35.0;
            final double diaWidth = (constraints.maxWidth - horarioHeaderWidth) / _dias.length;

            return Stack(
              children: [
                _buildGridLines(constraints, horaHeight, horarioHeaderWidth),
                _buildTimeHeaders(horaHeight, horarioHeaderWidth),
                _buildDayHeaders(horaHeight, horarioHeaderWidth, diaWidth),
                ...disciplinas.expand((disciplina) {
                  return _posicionarDisciplina(disciplina, horaHeight, horarioHeaderWidth, diaWidth);
                }),
              ],
            );
          },
        );
      },
    );
  }

  /// Constrói os botões de ação na parte inferior da tela.
  Widget _buildActionButtons() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(icon: const Icon(Icons.close), label: const Text('Fechar'), onPressed: () => context.pop()),
            ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Adicionar'), onPressed: _mostrarAddDisciplinaDialog),
          ],
        ),
      ),
    );
  }

  /// Desenha as linhas horizontais da grade.
  Widget _buildGridLines(BoxConstraints constraints, double horaHeight, double horarioHeaderWidth) {
    return Stack(
      children: List.generate(_horarios.length + 1, (i) {
        return Positioned(
          top: (i + 1) * horaHeight,
          left: horarioHeaderWidth,
          right: 0,
          child: Container(
            height: 1.0,
            color: Colors.grey.shade300,
          ),
        );
      }),
    );
  }
  
  /// Desenha os cabeçalhos de horário (coluna da esquerda).
  Widget _buildTimeHeaders(double horaHeight, double horarioHeaderWidth) {
    return Positioned(
      top: horaHeight,
      left: 0,
      bottom: 0,
      width: horarioHeaderWidth,
      child: Column(
        children: _horarios.map((h) => Expanded(
          child: Center(
            child: Text(
              h,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        )).toList(),
      ),
    );
  }

  /// Desenha os cabeçalhos de dias da semana (linha do topo).
  Widget _buildDayHeaders(double horaHeight, double horarioHeaderWidth, double diaWidth) {
    return Positioned(
      top: 0,
      left: horarioHeaderWidth,
      right: 0,
      height: horaHeight,
      child: Row(
        children: _diasAbrev.map((dia) => SizedBox(
          width: diaWidth,
          child: Center(
            child: Text(
              dia,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        )).toList(),
      ),
    );
  }
  
  /// Calcula a posição e o tamanho de um card de disciplina.
  List<Widget> _posicionarDisciplina(Disciplina disciplina, double horaHeight, double horarioHeaderWidth, double diaWidth) {
    try {
      final inicioParts = disciplina.horarioInicio.split(':');
      final fimParts = disciplina.horarioFim.split(':');
      final inicioMinutos = int.parse(inicioParts[0]) * 60 + int.parse(inicioParts[1]);
      final fimMinutos = int.parse(fimParts[0]) * 60 + int.parse(fimParts[1]);

      final double topOffset = ((inicioMinutos - (7 * 60)) / 60) * horaHeight;
      final double top = horaHeight + topOffset;
      final double height = ((fimMinutos - inicioMinutos) / 60) * horaHeight;
      
      return disciplina.diasDaSemana.map((dia) {
        final int diaIndex = _dias.indexOf(dia);
        if (diaIndex == -1) return const SizedBox.shrink();

        final double left = horarioHeaderWidth + (diaIndex * diaWidth);

        return Positioned(
          top: top,
          left: left,
          width: diaWidth,
          height: height - 2,
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: DisciplinaCard(
              disciplina: disciplina,
              onTap: () => _mostrarDetalhesDisciplina(disciplina),
            ),
          ),
        );
      }).toList();
    } catch (e) {
      developer.log(
        "Erro ao processar horário para a disciplina ${disciplina.nome}",
        name: 'EditGradePage',
        error: e,
      );
      return [const SizedBox.shrink()];
    }
  }
}