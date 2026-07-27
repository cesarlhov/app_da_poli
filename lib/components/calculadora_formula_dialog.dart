// lib/components/calculadora_formula_dialog.dart

import 'package:flutter/material.dart';

class CalculadoraFormulaDialog extends StatefulWidget {
  final String formulaInicial;
  const CalculadoraFormulaDialog({super.key, this.formulaInicial = ''});

  @override
  State<CalculadoraFormulaDialog> createState() => _CalculadoraFormulaDialogState();
}

class _CalculadoraFormulaDialogState extends State<CalculadoraFormulaDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.formulaInicial);
  }

  void _addTexto(String texto) {
    setState(() {
      _controller.text += texto;
    });
  }

  void _apagar() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _controller.text = _controller.text.substring(0, _controller.text.length - 1);
      });
    }
  }

  void _limparTudo() {
    setState(() {
      _controller.text = '';
    });
  }

  Widget _buildBotao(String texto, {Color? corFundo, Color? corTexto, VoidCallback? onTap, double flex = 1}) {
    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: corFundo ?? Colors.grey[200],
            foregroundColor: corTexto ?? Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          onPressed: onTap ?? () => _addTexto(texto),
          child: Text(texto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editor de Fórmula Avançado', style: TextStyle(fontWeight: FontWeight.bold)),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // VISOR
            TextField(
              controller: _controller,
              readOnly: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, letterSpacing: 1.5, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 12),
            
            // VARIÁVEIS DA DISCIPLINA
            const Text('Variáveis Disponíveis', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: ['P1', 'P2', 'P3', 'SUB', 'TRAB', 'P1 + P2'].map((v) => ActionChip(
                label: Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                backgroundColor: const Color(0xFF0460E9).withAlpha(30),
                side: const BorderSide(color: Color(0xFF0460E9)),
                onPressed: () => _addTexto(v == 'P1 + P2' ? '(P1 + P2)' : v),
              )).toList(),
            ),
            const Divider(height: 20),
            
            // TECLADO MATEMÁTICO AVANÇADO
            Row(children: [
              _buildBotao('sqrt(', corFundo: Colors.purple[50], corTexto: Colors.purple[900], onTap: () => _addTexto('sqrt(')),
              _buildBotao('^', corFundo: Colors.purple[50], corTexto: Colors.purple[900]),
              _buildBotao('(', corFundo: Colors.blue[50], corTexto: Colors.blue[900]), 
              _buildBotao(')', corFundo: Colors.blue[50], corTexto: Colors.blue[900]), 
            ]),
            Row(children: [
              _buildBotao('AC', corFundo: Colors.red[100], corTexto: Colors.red[900], onTap: _limparTudo), 
              _buildBotao('⌫', corFundo: Colors.orange[100], corTexto: Colors.orange[900], onTap: _apagar),
              _buildBotao('/', corFundo: Colors.grey[300]),
              _buildBotao('*', corFundo: Colors.grey[300]),
            ]),
            Row(children: [_buildBotao('7'), _buildBotao('8'), _buildBotao('9'), _buildBotao('-', corFundo: Colors.grey[300])]),
            Row(children: [_buildBotao('4'), _buildBotao('5'), _buildBotao('6'), _buildBotao('+', corFundo: Colors.grey[300])]),
            Row(children: [_buildBotao('1'), _buildBotao('2'), _buildBotao('3'), _buildBotao('0', flex: 2)]),
            Row(children: [_buildBotao('.'), _buildBotao('0.5', onTap: () => _addTexto('0.5'))]),
            const SizedBox(height: 12),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0460E9), foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Salvar Fórmula'),
        ),
      ],
    );
  }
}