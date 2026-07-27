// lib/components/edit_profile_dialog.dart

import 'package:app_da_poli/models/user_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';

class EditProfileDialog extends StatefulWidget {
  final AppUser currentUser;

  const EditProfileDialog({super.key, required this.currentUser});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _cursoController;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.currentUser.nome);
    _cursoController = TextEditingController(text: widget.currentUser.curso);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cursoController.dispose();
    super.dispose();
  }

  Future<void> _salvarPerfil() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final updatedData = {
        'nome': _nomeController.text.trim(),
        'curso': _cursoController.text.trim(),
      };

      await _firestoreService.updateUserProfile(updatedData);

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop(); // Fecha o diálogo
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Perfil'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome Completo'),
              validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cursoController,
              decoration: const InputDecoration(labelText: 'Curso (ex: Engenharia Química)'),
              validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
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
          onPressed: _isLoading ? null : _salvarPerfil,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salvar'),
        ),
      ],
    );
  }
}