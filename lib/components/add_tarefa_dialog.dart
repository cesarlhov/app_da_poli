import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';

//-------------------------------------------------
// CAIXA DE DIÁLOGO PARA ADICIONAR TAREFA
//-------------------------------------------------
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

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

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
                      : 'Entrega: ${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}',
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selecionarData(context),
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

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }
}
