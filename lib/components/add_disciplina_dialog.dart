import 'package:app_da_poli/components/weekday_selector.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';

//-------------------------------------------------
// CAIXA DE DIÁLOGO INTERATIVA PARA ADICIONAR DISCIPLINA
//-------------------------------------------------

// Classe para as nossas disciplinas pré-cadastradas
class DisciplinaPreCadastrada {
  final String nome;
  final String codigo;
  final String professor;

  DisciplinaPreCadastrada(this.nome, this.codigo, this.professor);
}

class AddDisciplinaDialog extends StatefulWidget {
  const AddDisciplinaDialog({super.key});

  @override
  State<AddDisciplinaDialog> createState() => _AddDisciplinaDialogState();
}

class _AddDisciplinaDialogState extends State<AddDisciplinaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _codigoController = TextEditingController();
  final _professorController = TextEditingController();
  final _salaController = TextEditingController();

  List<String> _diasSelecionados = [];
  TimeOfDay? _horarioInicio;
  TimeOfDay? _horarioFim;

  final FirestoreService _firestoreService = FirestoreService();

  static final List<DisciplinaPreCadastrada> _disciplinasSugeridas = [
    // ... sua lista de sugestões ...
  ];

  void _salvarDisciplina() async {
    if (_horarioInicio == null || _horarioFim == null) {
      // ... sua validação de horário ...
      return;
    }

    if (_formKey.currentState!.validate()) {
      // --- ALTERAÇÃO PRINCIPAL: Criando um Map em vez de um objeto Disciplina ---
      final Map<String, dynamic> novaDisciplinaData = {
        'nome': _nomeController.text.trim(),
        'codigo': _codigoController.text.trim(),
        'professor': _professorController.text.trim(),
        'sala': _salaController.text.trim(),
        'diasDaSemana': _diasSelecionados,
        'horarioInicio': _horarioInicio!.format(context),
        'horarioFim': _horarioFim!.format(context),
      };

      // Usa o serviço para adicionar o Map de dados ao Firebase
      await _firestoreService.addDisciplina(novaDisciplinaData);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _selecionarHorario(BuildContext context, bool isInicio) async {
    final TimeOfDay? horarioSelecionado = await showTimePicker(
      context: context,
      initialTime: _horarioInicio ?? TimeOfDay.now(),
      helpText: isInicio ? 'SELECIONAR HORÁRIO DE INÍCIO' : 'SELECIONAR HORÁRIO DE FIM',
    );
    if (horarioSelecionado != null) {
      setState(() {
        if (isInicio) {
          _horarioInicio = horarioSelecionado;
        } else {
          _horarioFim = horarioSelecionado;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Nova Disciplina'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Autocomplete para o nome da disciplina
              Autocomplete<DisciplinaPreCadastrada>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<DisciplinaPreCadastrada>.empty();
                  }
                  return _disciplinasSugeridas.where((disciplina) => disciplina
                      .nome
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()));
                },
                displayStringForOption: (DisciplinaPreCadastrada option) => option.nome,
                onSelected: (DisciplinaPreCadastrada selection) {
                  // Preenche os outros campos automaticamente
                  setState(() {
                    _nomeController.text = selection.nome;
                    _codigoController.text = selection.codigo;
                    _professorController.text = selection.professor;
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                   return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(labelText: 'Nome da Disciplina'),
                     validator: (value) {
                       _nomeController.text = value ?? '';
                       if (value == null || value.isEmpty) {
                         return 'Campo obrigatório';
                       }
                       return null;
                     }
                  );
                },
              ),
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(labelText: 'Código (ex: PEA3301)'),
              ),
              TextFormField(
                controller: _professorController,
                decoration: const InputDecoration(labelText: 'Professor'),
              ),
              TextFormField(
                controller: _salaController,
                decoration: const InputDecoration(labelText: 'Sala / Local'),
              ),
              const SizedBox(height: 20),
              const Text('Dias da Semana', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Seletor de dias da semana
              WeekdaySelector(
                onSelectionChanged: (dias) {
                  _diasSelecionados = dias;
                },
              ),
              const SizedBox(height: 20),
              // Seletores de horário
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Início'),
                      ElevatedButton(
                        onPressed: () => _selecionarHorario(context, true),
                        child: Text(_horarioInicio?.format(context) ?? 'Selecionar'),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Fim'),
                      ElevatedButton(
                        onPressed: () => _selecionarHorario(context, false),
                        child: Text(_horarioFim?.format(context) ?? 'Selecionar'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvarDisciplina,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _codigoController.dispose();
    _professorController.dispose();
    _salaController.dispose();
    super.dispose();
  }
}

