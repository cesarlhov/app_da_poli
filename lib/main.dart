import 'package:app_da_poli/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PoliApp());
}

class PoliApp extends StatelessWidget {
  const PoliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App da Poli',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'LeagueSpartan',
        // <<< ALTERAÇÃO AQUI >>>
        scaffoldBackgroundColor: const Color(0xFFF0F0F0), // Nova cor de fundo
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFF003366),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

