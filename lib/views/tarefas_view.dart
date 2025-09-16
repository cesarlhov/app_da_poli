// lib/views/tarefas_view.dart

import 'package:app_da_poli/components/add_tarefa_dialog.dart';
import 'package:app_da_poli/models/tarefa_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';

//-------------------------------------------------
// TELA PARA EXIBIR E GERIR TAREFAS
//-------------------------------------------------
class TarefasView extends StatefulWidget {
  const TarefasView({super.key});

  @override
  State<TarefasView> createState() => _TarefasViewState();
}

class _TarefasViewState extends State<TarefasView> {
  final FirestoreService _firestoreService = FirestoreService();

  void _mostrarAddTarefaDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddTarefaDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarAddTarefaDialog,
        backgroundColor: const Color(0xFF003366),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Tarefa>>(
        stream: _firestoreService.getTarefas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar as tarefas.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nenhuma tarefa pendente. Bom trabalho!',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          final tarefas = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: tarefas.length,
            itemBuilder: (context, index) {
              final tarefa = tarefas[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    tarefa.titulo,
                    style: TextStyle(
                      decoration: tarefa.concluida
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(
                      'Entrega: ${tarefa.dataEntrega.toDate().day}/${tarefa.dataEntrega.toDate().month}'),
                  trailing: Checkbox(
                    value: tarefa.concluida,
                    onChanged: (bool? value) {
                      if (value != null) {
                        _firestoreService.updateTarefa(tarefa.id, value);
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
