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

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/avisos')) return 1;
    if (location.startsWith('/tarefas')) return 2;
    if (location.startsWith('/eventos')) return 3; // Corrigido
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
        context.go('/tarefas');
        break;
      case 3:
        context.go('/eventos'); // Corrigido
        break;
      case 4:
        context.go('/perfil');
        break;
    }
  }
}