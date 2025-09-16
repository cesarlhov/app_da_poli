// lib/pages/home_page.dart

import 'package:app_da_poli/views/avisos_view.dart';
import 'package:app_da_poli/views/eventos_view.dart';
import 'package:app_da_poli/views/jupiter_view.dart';
import 'package:app_da_poli/views/profile_view.dart';
import 'package:app_da_poli/views/tarefas_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//-------------------------------------------------
// TELA PRINCIPAL (HOME) COM NOVO DESIGN
//-------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const JupiterView(),
    const AvisosView(),
    const TarefasView(),
    const EventosView(),
    const ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFF0F0F0); // Nova cor de fundo

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: backgroundColor, // Adapta-se ao fundo
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: backgroundColor, // <<< ALTERAÇÃO AQUI
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
          backgroundColor: backgroundColor, // Passa a cor para a barra
        ),
      ),
    );
  }
}

// --- WIDGET PERSONALIZADO PARA A BARRA DE NAVEGAÇÃO ---

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final Color backgroundColor;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: backgroundColor, // <<< ALTERAÇÃO AQUI
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Início', 0),
          _buildNavItem(Icons.notifications, 'Avisos', 1),
          _buildNavItem(Icons.settings_applications, 'Tarefas', 2),
          _buildNavItem(Icons.school, 'Eventos', 3),
          _buildNavItem(Icons.person, 'Perfil', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;
    const Color poliBlue = Color(0xFF0460E9); // Usando a sua nova cor

    return InkWell(
      onTap: () => onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? poliBlue : Colors.grey,
            size: 28,
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isSelected ? 15 : 0,
            child: Text(
              label,
              style: const TextStyle(
                color: poliBlue,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}


