// lib/pages/tarefas_page.dart

import 'package:app_da_poli/components/add_tarefa_dialog.dart';
import 'package:app_da_poli/providers/tarefas_provider.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// View que exibe e gerencia a lista de tarefas do usuário de forma otimizada.
class TarefasPage extends StatelessWidget {
  const TarefasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Escuta o nosso provedor local de tarefas
    final tarefasProvider = context.watch<TarefasProvider>();
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
      body: _buildBody(tarefasProvider, firestoreService),
    );
  }

  Widget _buildBody(TarefasProvider provider, FirestoreService firestoreService) {
    // Se o provedor diz que está carregando, mostramos o indicador
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Pega as tarefas prontas da memória
    final tarefas = provider.tarefas;

    if (tarefas.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma tarefa pendente. Bom trabalho!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

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
                  // O update vai para o Firebase, que avisa o Provider, que atualiza a tela
                  firestoreService.updateTarefa(tarefa.id, value);
                }
              },
            ),
          ),
        );
      },
    );
  }
}