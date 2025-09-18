// lib/components/add_disciplina_dialog.dart

import 'package:app_da_poli/components/weekday_selector.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';

/// Um diálogo para adicionar ou editar uma disciplina.
/// Utiliza o serviço do Firestore para salvar os dados.
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

  // Exemplo de como as sugestões podem ser estruturadas.
  // O ideal seria carregar esta lista de um serviço ou banco de dados.
  static final List<DisciplinaPreCadastrada> _disciplinasSugeridas = [
     DisciplinaPreCadastrada('Cálculo Numérico', 'PME3380', 'Professor A'),
     DisciplinaPreCadastrada('Circuitos Elétricos', 'PEA3301', 'Professor B'),
  ];

  @override
  void dispose() {
    // Limpeza dos controllers para evitar memory leaks.
    _nomeController.dispose();
    _codigoController.dispose();
    _professorController.dispose();
    _salaController.dispose();
    super.dispose();
  }

  /// Valida o formulário e salva a nova disciplina no Firestore.
  Future<void> _salvarDisciplina() async {
    // Valida se os horários foram selecionados.
    if (_horarioInicio == null || _horarioFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione os horários de início e fim.')),
      );
      return;
    }

    // Valida o resto do formulário.
    if (_formKey.currentState!.validate()) {
      final novaDisciplinaData = {
        'nome': _nomeController.text.trim(),
        'codigo': _codigoController.text.trim(),
        'professor': _professorController.text.trim(),
        'sala': _salaController.text.trim(),
        'diasDaSemana': _diasSelecionados,
        'horarioInicio': _horarioInicio!.format(context),
        'horarioFim': _horarioFim!.format(context),
      };

      await _firestoreService.addDisciplina(novaDisciplinaData);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  /// Exibe o seletor de tempo e atualiza o estado.
  Future<void> _selecionarHorario(BuildContext context, {required bool isInicio}) async {
    final TimeOfDay? horarioSelecionado = await showTimePicker(
      context: context,
      initialTime: isInicio ? _horarioInicio ?? TimeOfDay.now() : _horarioFim ?? TimeOfDay.now(),
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
              Autocomplete<DisciplinaPreCadastrada>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<DisciplinaPreCadastrada>.empty();
                  }
                  return _disciplinasSugeridas.where((d) =>
                      d.nome.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                displayStringForOption: (DisciplinaPreCadastrada option) => option.nome,
                onSelected: (DisciplinaPreCadastrada selection) {
                  // Preenche os campos automaticamente ao selecionar uma sugestão.
                  setState(() {
                    _nomeController.text = selection.nome;
                    _codigoController.text = selection.codigo;
                    _professorController.text = selection.professor;
                  });
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  // Sincroniza o controller do Autocomplete com o nosso controller principal.
                  _nomeController.value = textEditingController.value;
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(labelText: 'Nome da Disciplina'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
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
              WeekdaySelector(
                onSelectionChanged: (dias) {
                  _diasSelecionados = dias;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTimePicker('Início', _horarioInicio, () => _selecionarHorario(context, isInicio: true)),
                  _buildTimePicker('Fim', _horarioFim, () => _selecionarHorario(context, isInicio: false)),
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

  /// Widget auxiliar para criar os botões de seleção de horário.
  Widget _buildTimePicker(String label, TimeOfDay? time, VoidCallback onPressed) {
    return Column(
      children: [
        Text(label),
        ElevatedButton(
          onPressed: onPressed,
          child: Text(time?.format(context) ?? 'Selecionar'),
        ),
      ],
    );
  }
}

/// Classe auxiliar para o Autocomplete.
class DisciplinaPreCadastrada {
  final String nome;
  final String codigo;
  final String professor;

  DisciplinaPreCadastrada(this.nome, this.codigo, this.professor);
}