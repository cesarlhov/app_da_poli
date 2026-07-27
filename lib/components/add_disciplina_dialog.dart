// lib/components/add_disciplina_dialog.dart

import 'package:app_da_poli/components/weekday_selector.dart';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  final _localController = TextEditingController(); // Atualizado para local

  List<String> _diasSelecionados = [];
  TimeOfDay? _horarioInicio;
  TimeOfDay? _horarioFim;

  final FirestoreService _firestoreService = FirestoreService();

  static final List<DisciplinaPreCadastrada> _disciplinasSugeridas = [
     DisciplinaPreCadastrada('Cálculo Numérico', 'PME3380', 'Professor A'),
     DisciplinaPreCadastrada('Circuitos Elétricos', 'PEA3301', 'Professor B'),
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _codigoController.dispose();
    _professorController.dispose();
    _localController.dispose();
    super.dispose();
  }

  Future<void> _salvarDisciplina() async {
    if (_horarioInicio == null || _horarioFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione os horários de início e fim.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Cria a disciplina usando o novo Molde Global
      final novaDisciplina = Disciplina(
        id: '', // O Firestore gera o ID
        nome: _nomeController.text.trim(),
        codigo: _codigoController.text.trim(),
        departamento: 'Geral', // Temporário, até termos um seletor de departamento
        local: _localController.text.trim(),
        diasDaSemana: _diasSelecionados,
        horarioInicio: _horarioInicio!.format(context),
        horarioFim: _horarioFim!.format(context),
        cor: Colors.blue, // A cor é recalculada depois
        docentes: [_professorController.text.trim()], // Adiciona como lista
        dataInicio: Timestamp.now(), // Temporário
        dataFim: Timestamp.now(), // Temporário
        totalAulasEstimadas: 30, // Temporário
        isVerificada: false, // Entra como não oficial
      );

      // Usamos o novo método do Service
      await _firestoreService.createDisciplinaGlobal(novaDisciplina);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

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
                  setState(() {
                    _nomeController.text = selection.nome;
                    _codigoController.text = selection.codigo;
                    _professorController.text = selection.professor;
                  });
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  _nomeController.value = textEditingController.value;
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(labelText: 'Nome da Disciplina'),
                    validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
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
                controller: _localController,
                decoration: const InputDecoration(labelText: 'Local / Sala'),
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

class DisciplinaPreCadastrada {
  final String nome;
  final String codigo;
  final String professor;
  DisciplinaPreCadastrada(this.nome, this.codigo, this.professor);
}