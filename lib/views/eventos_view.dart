import 'package:flutter/material.dart';

//-------------------------------------------------
// TELA PARA EXIBIR OS EVENTOS
//-------------------------------------------------
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
