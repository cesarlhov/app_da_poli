// lib/main.dart

import 'package:app_da_poli/auth/app_shell.dart';
import 'package:app_da_poli/firebase_options.dart';
import 'package:app_da_poli/pages/chat_page.dart';
import 'package:app_da_poli/pages/forum_page.dart';
import 'package:app_da_poli/pages/login_page.dart';
import 'package:app_da_poli/pages/splash_page.dart';
import 'package:app_da_poli/views/avisos_view.dart';
import 'package:app_da_poli/views/edit_grade_page.dart';
import 'package:app_da_poli/views/eventos_view.dart';
import 'package:app_da_poli/views/jupiter_view.dart';
import 'package:app_da_poli/views/profile_view.dart';
import 'package:app_da_poli/views/tarefas_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// --- MODIFICAÇÃO PRINCIPAL COMEÇA AQUI ---

void main() {
  // Garante que o Flutter está pronto
  WidgetsFlutterBinding.ensureInitialized();
  
  // Define a orientação do sistema
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFFF0F0F0),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Inicia o App, que agora vai gerenciar a inicialização do Firebase
  runApp(const AppInitializer());
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  // Guarda o resultado da inicialização do Firebase
  late final Future<FirebaseApp> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    // FutureBuilder espera a inicialização terminar
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // Se der erro na inicialização, mostra uma tela de erro
        if (snapshot.hasError) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'Erro ao inicializar o Firebase.',
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          );
        }

        // Se terminar a inicialização com sucesso, mostra o app principal
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp(router: _createRouter());
        }

        // Enquanto estiver inicializando, mostra uma tela de carregamento
        return const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}

// --- O RESTO DO SEU CÓDIGO PERMANECE O MESMO ---

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
          GoRoute(path: '/avisos', pageBuilder: (context, state) => NoTransitionPage(child: const AvisosView())),
          GoRoute(path: '/tarefas', pageBuilder: (context, state) => NoTransitionPage(child: const TarefasView())),
          GoRoute(path: '/eventos', pageBuilder: (context, state) => NoTransitionPage(child: const EventosView())),
          GoRoute(path: '/perfil', pageBuilder: (context, state) => NoTransitionPage(child: const ProfileView())),
        ],
      ),
      GoRoute(path: '/edit-grade', builder: (context, state) => const EditGradePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/forum', builder: (context, state) => const ForumPage()),
      GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
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