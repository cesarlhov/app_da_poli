import 'package:flutter/material.dart';

/// View para exibir um mural de eventos (atualmente em construção).
class EventosPage extends StatelessWidget {
  const EventosPage({super.key});
  
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