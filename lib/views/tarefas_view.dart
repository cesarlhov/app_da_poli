// lib/views/tarefas_view.dart

import 'package:app_da_poli/components/add_tarefa_dialog.dart';
import 'package:app_da_poli/models/tarefa_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// View que exibe e gerencia la lista de tarefas do usuário.
class TarefasView extends StatelessWidget {
  const TarefasView({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    void mostrarAddTarefaDialog() {
      showDialog(context: context, builder: (context) => const AddTarefaDialog());
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: mostrarAddTarefaDialog,
        backgroundColor: const Color(0xFF0D41A9),
        tooltip: 'Adicionar Tarefa',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Tarefa>>(
        stream: firestoreService.getTarefas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar as tarefas.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma tarefa pendente. Bom trabalho!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final tarefas = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: tarefas.length,
            itemBuilder: (context, index) {
              final tarefa = tarefas[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                child: ListTile(
                  title: Text(
                    tarefa.titulo,
                    style: TextStyle(
                      decoration: tarefa.concluida ? TextDecoration.lineThrough : TextDecoration.none,
                      color: tarefa.concluida ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Text('Entrega: ${DateFormat('dd/MM/yyyy').format(tarefa.dataEntrega.toDate())}'),
                  trailing: Checkbox(
                    value: tarefa.concluida,
                    onChanged: (bool? value) {
                      if (value != null) {
                        firestoreService.updateTarefa(tarefa.id, value);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}