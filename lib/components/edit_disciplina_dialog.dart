// lib/components/edit_disciplina_dialog.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:app_da_poli/components/calculadora_formula_dialog.dart';

class EditDisciplinaDialog extends StatefulWidget {
  final Disciplina disciplina;
  const EditDisciplinaDialog({super.key, required this.disciplina});

  @override
  State<EditDisciplinaDialog> createState() => _EditDisciplinaDialogState();
}

class _EditDisciplinaDialogState extends State<EditDisciplinaDialog> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _nomeController;
  late TextEditingController _codigoController;
  late TextEditingController _deptoController;
  late TextEditingController _localController;
  late TextEditingController _docentesController;
  late TextEditingController _formulaController;
  late TextEditingController _ementaController;
  late bool _isVerificada;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.disciplina.nome);
    _codigoController = TextEditingController(text: widget.disciplina.codigo);
    _deptoController = TextEditingController(text: widget.disciplina.departamento);
    _localController = TextEditingController(text: widget.disciplina.local);
    _docentesController = TextEditingController(text: widget.disciplina.docentes.join(', '));
    _formulaController = TextEditingController(text: widget.disciplina.formulaAvaliacao);
    _ementaController = TextEditingController(text: widget.disciplina.ementa);
    _isVerificada = widget.disciplina.isVerificada;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _codigoController.dispose();
    _deptoController.dispose();
    _localController.dispose();
    _docentesController.dispose();
    _formulaController.dispose();
    _ementaController.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      // Converte a string separada por vírgulas de volta para uma lista
      List<String> listaDocentes = _docentesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final dadosAtualizados = {
        'nome': _nomeController.text.trim(),
        'codigo': _codigoController.text.trim(),
        'departamento': _deptoController.text.trim(),
        'local': _localController.text.trim(),
        'docentes': listaDocentes,
        'formulaAvaliacao': _formulaController.text.trim(),
        'ementa': _ementaController.text.trim(),
        'isVerificada': _isVerificada,
      };

      await _firestoreService.updateDisciplinaGlobal(widget.disciplina.id, dadosAtualizados);

      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar ${widget.disciplina.codigo}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Disciplina Oficial (Verificada)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Torna o ícone azul e oficializa a turma.'),
                value: _isVerificada,
                activeColor: Colors.blue,
                onChanged: (val) => setState(() => _isVerificada = val),
              ),
              const Divider(),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome da Disciplina'),
                validator: (val) => val!.isEmpty ? 'Obrigatório' : null,
              ),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _codigoController, decoration: const InputDecoration(labelText: 'Código'))),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: _deptoController, decoration: const InputDecoration(labelText: 'Depto (Ex: PME)'))),
                ],
              ),
              TextFormField(
                controller: _localController,
                decoration: const InputDecoration(labelText: 'Local / Sala'),
              ),
              TextFormField(
                controller: _docentesController,
                decoration: const InputDecoration(labelText: 'Docentes (Separados por vírgula)'),
              ),
              // CAMPO DA FÓRMULA COM BOTÃO DE CALCULADORA
              TextFormField(
                controller: _formulaController,
                readOnly: true, // O Admin não digita pelo teclado do celular
                decoration: InputDecoration(
                  labelText: 'Fórmula de Avaliação',
                  filled: true,
                  fillColor: Colors.blue[50],
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calculate, color: Color(0xFF0460E9)),
                    onPressed: () async {
                      // Abre a nossa calculadora e espera o resultado
                      final novaFormula = await showDialog<String>(
                        context: context,
                        builder: (context) => CalculadoraFormulaDialog(
                          formulaInicial: _formulaController.text,
                        ),
                      );
                      
                      // Se ele clicou em salvar e trouxe um texto, atualiza o campo
                      if (novaFormula != null) {
                        setState(() {
                          _formulaController.text = novaFormula;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ementaController,
                decoration: const InputDecoration(labelText: 'Ementa do Curso', alignLabelWithHint: true),
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _salvarAlteracoes, child: const Text('Salvar')),
      ],
    );
  }
}