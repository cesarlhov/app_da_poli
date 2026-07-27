// lib/auth/app_shell.dart

import 'package:app_da_poli/components/main_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// O "invólucro" principal do aplicativo para as telas que compartilham
/// a barra de navegação inferior.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Controla a aparência da status bar e da navigation bar do sistema.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Deixa a status bar transparente.
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          top: true,
          bottom: false, // SafeArea inferior será controlado pela NavBar.
          child: child,
        ),
        extendBody: true, // Permite que o body preencha a área da NavBar.
        bottomNavigationBar: MainBottomNavBar(
          currentIndex: _calculateSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
        ),
      ),
    );
  }

  /// Calcula o índice selecionado na BottomNavBar com base na rota atual.
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/avisos')) return 1;
    if (location.startsWith('/tarefas')) return 2;
    if (location.startsWith('/eventos')) return 3;
    if (location.startsWith('/perfil')) return 4;
    return 0; // Padrão é '/inicio'.
  }

  /// Navega para a rota correspondente ao ícone tocado na BottomNavBar.
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/inicio');
        break;
      case 1:
        context.go('/avisos');
        break;
      case 2:
        context.go('/tarefas');
        break;
      case 3:
        context.go('/eventos');
        break;
      case 4:
        context.go('/perfil');
        break;
    }
  }
}