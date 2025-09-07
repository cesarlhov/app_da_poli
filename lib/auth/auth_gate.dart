import 'package:app_da_poli/pages/home_page.dart';
import 'package:app_da_poli/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//-------------------------------------------------
// WIDGET "PORTEIRO"
//-------------------------------------------------
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // Ouve em tempo real as mudanças no estado de autenticação
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Se o snapshot tem dados, significa que o usuário está logado
          if (snapshot.hasData) {
            return const HomePage();
          }
          // Se não tem dados, o usuário não está logado
          else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
