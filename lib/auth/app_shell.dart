// lib/auth/app_shell.dart
import 'package:app_da_poli/components/main_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import necessário
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // --- MUDANÇA: Usando AnnotatedRegion para controlar as barras do sistema ---
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // Deixa a barra de status transparente, mostrando nossa cor de fundo
        statusBarColor: Colors.transparent, 
        // Ícones da barra de status (hora, bateria) ficam escuros
        statusBarIconBrightness: Brightness.dark, 
        // Cor da barra de navegação de gestos (embaixo)
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor, 
        // Ícones da barra de gestos (a "pílula") ficam escuros
        systemNavigationBarIconBrightness: Brightness.dark, 
      ),
      child: Scaffold(
        body: SafeArea(
          top: true,
          bottom: false,
          child: child,
        ),
        extendBody: true,
        bottomNavigationBar: MainBottomNavBar(
          currentIndex: _calculateSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/avisos')) return 1;
    if (location.startsWith('/eventos')) return 2; // Novo índice
    if (location.startsWith('/config')) return 3;
    if (location.startsWith('/perfil')) return 4;
    return 0; // '/inicio'
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/inicio');
        break;
      case 1:
        context.go('/avisos');
        break;
      case 2:
        context.go('/eventos'); // Nova rota
        break;
      case 3:
        context.go('/config');
        break;
      case 4:
        context.go('/perfil');
        break;
    }
  }
}