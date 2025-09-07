import 'package:app_da_poli/components/add_disciplina_dialog.dart';
import 'package:app_da_poli/components/disciplina_card.dart';
import 'package:app_da_poli/components/grade_cell.dart';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/services/firestore_service.dart'; // <-- A CORREÇÃO ESTÁ AQUI
import 'package:flutter/material.dart';

//-------------------------------------------------
// PÁGINA PARA EDITAR A GRADE (COM DADOS DO FIREBASE)
//-------------------------------------------------
class EditGradePage extends StatefulWidget {
  const EditGradePage({super.key});

  @override
  State<EditGradePage> createState() => _EditGradePageState();
}

class _EditGradePageState extends State<EditGradePage> {
  final FirestoreService _firestoreService = FirestoreService();

  final List<String> horarios = [
    '08:00', '09:00', '10:00', '11:00', '12:00', 
    '13:00', '14:00', '15:00', '16:00', '17:00'
  ];
  final List<String> dias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];
  final List<String> diasAbrev = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];
  
  final double horaHeight = 60.0;
  final double diaWidth = 100.0;
  final double horarioHeaderWidth = 60.0;

  void _mostrarAddDisciplinaDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const AddDisciplinaDialog();
      },
    );
  }

  // Função para mostrar os detalhes da disciplina e a opção de apagar
  void _mostrarDetalhesDisciplina(Disciplina disciplina) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(disciplina.nome),
        content: Text(
            'Código: ${disciplina.codigo}\nProfessor: ${disciplina.professor}\nSala: ${disciplina.sala}\nHorário: ${disciplina.horarioInicio} - ${disciplina.horarioFim}'),
        actions: [
          TextButton(
            child: const Text('Fechar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Apagar', style: TextStyle(color: Colors.red)),
            onPressed: () {
              // Usa o serviço para apagar a disciplina
              _firestoreService.deleteDisciplina(disciplina.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Minha Grade'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarAddDisciplinaDialog,
        backgroundColor: const Color(0xFF003660),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Disciplina>>(
        stream: _firestoreService.getDisciplinas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar disciplinas.'));
          }

          final disciplinas = snapshot.data ?? [];
          return _construirGradeComDisciplinas(disciplinas);
        },
      ),
    );
  }

  Widget _construirGradeComDisciplinas(List<Disciplina> disciplinas) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          margin: const EdgeInsets.all(8.0),
          // Stack permite sobrepor widgets (disciplinas sobre a grade vazia)
          child: Stack(
            children: [
              // 1. Fundo da Grade (Células e Cabeçalhos)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coluna de Horários
                  SizedBox(
                    width: horarioHeaderWidth,
                    child: Column(
                      children: [
                        GradeCell(text: 'Hora', isHeader: true, height: horaHeight),
                        ...horarios.map((h) => GradeCell(text: h, isHeader: true, height: horaHeight))
                      ],
                    ),
                  ),
                  // Colunas dos Dias
                  ...diasAbrev.map((d) => SizedBox(
                    width: diaWidth,
                    child: Column(
                      children: [
                        GradeCell(text: d, isHeader: true, height: horaHeight),
                        ...horarios.map((_) => GradeCell(text: '', height: horaHeight))
                      ],
                    ),
                  ))
                ],
              ),
              // 2. Disciplinas Sobrepostas
              ...disciplinas.expand((disciplina) {
                return _posicionarDisciplina(disciplina);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // Lógica para posicionar cada disciplina na grade
  List<Positioned> _posicionarDisciplina(Disciplina disciplina) {
    List<Positioned> widgetsDisciplina = [];

    try {
      final inicioParts = disciplina.horarioInicio.split(':');
      final fimParts = disciplina.horarioFim.split(':');
      final inicioMinutos = int.parse(inicioParts[0]) * 60 + int.parse(inicioParts[1]);
      final fimMinutos = int.parse(fimParts[0]) * 60 + int.parse(fimParts[1]);

      // Calcula a posição vertical e a altura baseada nos horários
      final double top = ((inicioMinutos - 8 * 60) / 60) * horaHeight + horaHeight;
      final double height = ((fimMinutos - inicioMinutos) / 60) * horaHeight;

      for (String dia in disciplina.diasDaSemana) {
        final int diaIndex = dias.indexOf(dia); // Procura o dia na lista completa
        if (diaIndex != -1) {
          final double left = horarioHeaderWidth + (diaIndex * diaWidth);
          widgetsDisciplina.add(
            Positioned(
              top: top,
              left: left + 2, // Pequeno espaçamento
              width: diaWidth - 4,
              height: height - 2,
              child: DisciplinaCard(
                disciplina: disciplina,
                onTap: () => _mostrarDetalhesDisciplina(disciplina),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print("Erro ao processar horário para a disciplina ${disciplina.nome}: $e");
    }

    return widgetsDisciplina;
  }
}

