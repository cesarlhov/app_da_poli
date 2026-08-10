// lib/auth/app_shell.dart

import 'package:app_da_poli/components/main_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, 
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
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

  // Mapeamento atualizado para a nova ordem das 5 abas
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/eventos')) return 0;
    if (location.startsWith('/tarefas')) return 1;
    if (location.startsWith('/inicio') || location.startsWith('/jupiter')) return 2;
    if (location.startsWith('/classe')) return 3;
    if (location.startsWith('/perfil')) return 4;
    return 2; // Padrão no Júpiter (/inicio)
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/eventos');
        break;
      case 1:
        context.go('/tarefas');
        break;
      case 2:
        context.go('/inicio');
        break;
      case 3:
        context.go('/classe');
        break;
      case 4:
        context.go('/perfil');
        break;
    }
  }
}