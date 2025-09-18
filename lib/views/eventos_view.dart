// lib/views/eventos_view.dart

import 'package:flutter/material.dart';

/// View para exibir um mural de eventos (atualmente em construção).
class EventosView extends StatelessWidget {
  const EventosView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Mural de Eventos',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}