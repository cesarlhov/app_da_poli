// lib/components/add_tarefa_dialog.dart

import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Um diálogo para adicionar uma nova tarefa.
class AddTarefaDialog extends StatefulWidget {
  const AddTarefaDialog({super.key});

  @override
  State<AddTarefaDialog> createState() => _AddTarefaDialogState();
}

class _AddTarefaDialogState extends State<AddTarefaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  DateTime? _dataSelecionada;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  /// Exibe o seletor de data e atualiza o estado.
  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)), // Permite datas passadas
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // Permite datas futuras
    );
    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

  /// Valida e salva a nova tarefa no Firestore.
  void _salvarTarefa() {
    if (_formKey.currentState!.validate()) {
      if (_dataSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione uma data de entrega.')),
        );
        return;
      }
      _firestoreService.addTarefa(_tituloController.text.trim(), _dataSelecionada!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Nova Tarefa'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título (ex: Prova de Cálculo)'),
              validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dataSelecionada == null
                      ? 'Nenhuma data selecionada'
                      // Usando o intl para um formato mais legível.
                      : 'Entrega: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada!)}',
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selecionarData(context),
                  tooltip: 'Selecionar Data',
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvarTarefa,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}