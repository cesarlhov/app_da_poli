// lib/main.dart

import 'package:app_da_poli/auth/app_shell.dart';
import 'package:app_da_poli/firebase_options.dart';
import 'package:app_da_poli/pages/login_page.dart';
import 'package:app_da_poli/pages/splash_page.dart';
import 'package:app_da_poli/views/edit_grade_page.dart';
import 'package:app_da_poli/views/jupiter_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFFF0F0F0),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  final router = _createRouter();
  runApp(MyApp(router: router));
}

GoRouter _createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/inicio', pageBuilder: (context, state) => NoTransitionPage(child: const JupiterView())),
          GoRoute(path: '/avisos', pageBuilder: (context, state) => NoTransitionPage(child: const Center(child: Text('Avisos')))),
          GoRoute(path: '/eventos', pageBuilder: (context, state) => NoTransitionPage(child: const Center(child: Text('Eventos')))),
          GoRoute(path: '/config', pageBuilder: (context, state) => NoTransitionPage(child: const Center(child: Text('Config')))),
          GoRoute(path: '/perfil', pageBuilder: (context, state) => NoTransitionPage(child: const Center(child: Text('Perfil')))),
        ],
      ),
      GoRoute(path: '/edit-grade', builder: (context, state) => const EditGradePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    ],
  );
}

class NoTransitionPage<T> extends CustomTransitionPage<T> {
  NoTransitionPage({required super.child, super.key})
      : super(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        );
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F0F0),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFF0F0F0),
        ),
        primarySwatch: Colors.blue,
      ),
    );
  }
}