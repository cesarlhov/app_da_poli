// lib/views/avisos_view.dart

import 'package:app_da_poli/models/aviso_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';

//-------------------------------------------------
// TELA PARA EXIBIR O MURAL DE AVISOS
//-------------------------------------------------
class AvisosView extends StatefulWidget {
  const AvisosView({super.key});

  @override
  State<AvisosView> createState() => _AvisosViewState();
}

class _AvisosViewState extends State<AvisosView> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Aviso>>(
        stream: _firestoreService.getAvisos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os avisos.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum aviso publicado.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final avisos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: avisos.length,
            itemBuilder: (context, index) {
              final aviso = avisos[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        aviso.titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        aviso.conteudo,
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          // Formatação simples da data
                          '${aviso.data.toDate().day}/${aviso.data.toDate().month}/${aviso.data.toDate().year}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
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
