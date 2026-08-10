// lib/main.dart

import 'package:app_da_poli/auth/app_shell.dart';
import 'package:app_da_poli/firebase_options.dart';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/pages/chat_page.dart';
import 'package:app_da_poli/pages/forum_page.dart';
import 'package:app_da_poli/pages/login_page.dart';
import 'package:app_da_poli/pages/splash_page.dart';
import 'package:app_da_poli/pages/active_disciplinas_page.dart';
import 'package:app_da_poli/pages/avisos_page.dart';
import 'package:app_da_poli/pages/edit_grade_page.dart';
import 'package:app_da_poli/pages/eventos_page.dart';
import 'package:app_da_poli/pages/jupiter_page.dart';
import 'package:app_da_poli/pages/profile_page.dart';
import 'package:app_da_poli/pages/tarefas_page.dart';
import 'package:app_da_poli/providers/user_provider.dart';
import 'package:app_da_poli/providers/disciplinas_provider.dart';
import 'package:app_da_poli/providers/tarefas_provider.dart';
import 'package:app_da_poli/providers/avisos_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:app_da_poli/pages/hub_disciplinas_page.dart';
import 'package:app_da_poli/pages/signup_page.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ======= MÁGICA DA TELA INFINITA (Edge-to-Edge) =======
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent, // Deixa a base invisível
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent, // Deixa o topo invisível
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  // ======================================================
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFFF0F0F0),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DisciplinasProvider()),
        ChangeNotifierProvider(create: (_) => TarefasProvider()),
        ChangeNotifierProvider(create: (_) => AvisosProvider()), // NOVO PROVIDER
      ],
      child: const AppInitializer(),
    ),
  );
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
      
      // ======= ROTA DE LOGIN COM FADE PARA A LOGO VOAR =======
      GoRoute(
        path: '/login', 
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const LoginPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Faz a tela anterior sumir suavemente
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1000), // 1 segundo de voo da Logo!
          );
        }
      ),
      // ========================================================
      
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
      
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/inicio', pageBuilder: (context, state) => const NoTransitionPage(child: JupiterPage())),
          GoRoute(path: '/avisos', pageBuilder: (context, state) => const NoTransitionPage(child: AvisosPage())),
          GoRoute(path: '/tarefas', pageBuilder: (context, state) => const NoTransitionPage(child: TarefasPage())),
          GoRoute(path: '/eventos', pageBuilder: (context, state) => const NoTransitionPage(child: EventosPage())),
          GoRoute(path: '/perfil', pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage())),
          GoRoute(path: '/hub-disciplinas', builder: (context, state) => const HubDisciplinasPage()),
        ],
      ),
      
      GoRoute(
        path: '/edit-grade',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final disciplinas = extra['disciplinas'] as List<Disciplina>? ?? [];
          final metrics = extra['metrics'] as Map<String, double>? ?? {};

          return CustomTransitionPage(
            key: state.pageKey,
            child: EditGradePage(
              initialDisciplinas: disciplinas,
              gradeMetrics: metrics,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
      ),
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

class NoTransitionPage<T> extends CustomTransitionPage<T> {
  const NoTransitionPage({required super.child, super.key})
      : super(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: _transitionsBuilder,
        );

  static Widget _transitionsBuilder(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}