// lib/main.dart

import 'package:app_da_poli/auth/app_shell.dart';
import 'package:app_da_poli/firebase_options.dart';
import 'package:app_da_poli/pages/chat_page.dart';
import 'package:app_da_poli/pages/forum_page.dart';
import 'package:app_da_poli/pages/login_page.dart';
import 'package:app_da_poli/pages/splash_page.dart';
import 'package:app_da_poli/views/active_disciplinas_page.dart';
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFFF0F0F0),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const AppInitializer());
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
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
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: Text('Erro ao inicializar o Firebase.'))),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp(router: _createRouter());
        }
        return const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}

GoRouter _createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/inicio', pageBuilder: (context, state) => const NoTransitionPage(child: JupiterView())),
          GoRoute(path: '/avisos', pageBuilder: (context, state) => const NoTransitionPage(child: AvisosView())),
          GoRoute(path: '/tarefas', pageBuilder: (context, state) => const NoTransitionPage(child: TarefasView())),
          GoRoute(path: '/eventos', pageBuilder: (context, state) => const NoTransitionPage(child: EventosView())),
          GoRoute(path: '/perfil', pageBuilder: (context, state) => const NoTransitionPage(child: ProfileView())),
        ],
      ),

      GoRoute(path: '/edit-grade', builder: (context, state) => const EditGradePage()),
      GoRoute(path: '/forum', builder: (context, state) => const ForumPage()),
      GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
      GoRoute(path: '/active-disciplinas', builder: (context, state) => const ActiveDisciplinasPage()),
    ],
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
        primarySwatch: Colors.blue,
      ),
    );
  }
}

/// Uma página customizada que remove a animação de transição.
class NoTransitionPage<T> extends CustomTransitionPage<T> {
  const NoTransitionPage({required super.child, super.key})
      : super(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: _transitionsBuilder, // Referência à função estática
        );

  // A função builder agora é um método estático separado.
  static Widget _transitionsBuilder(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}