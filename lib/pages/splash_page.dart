// lib/pages/splash_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hideFooter = false;

  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // Aguarda o tempo inicial da splash (ex: 1800ms)
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      setState(() {
        _hideFooter = true; // Inicia o esmaecimento dos ícones do rodapé e assinatura
      });
      // Aguarda 400ms para os ícones sumirem completamente antes de trocar de tela
      await Future.delayed(const Duration(milliseconds: 400));
    }
    if (mounted) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        context.go('/login');
      } else {
        context.go('/inicio');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // CENTRO: Logo Ch'aska + Assinatura atrelada
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Hero(
                  tag: 'logo_chaska', 
                  child: SvgPicture.asset(
                    'assets/images/logochaska_icon.svg',
                    width: 164, 
                  ),
                ),
                // Assinatura some junto com o rodapé
                Positioned(
                  right: 23,  
                  bottom: -15, 
                  child: AnimatedOpacity(
                    opacity: _hideFooter ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 350),
                    child: const Text(
                      "POR\nCESAR HOV",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'MonumentExtended',
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF444E75), 
                        height: 0.87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // RODAPÉ: Logos Institucionais que somem antes da logo voar
          Positioned(
            bottom: 34, 
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: _hideFooter ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 700),
                child: SvgPicture.asset(
                  'assets/images/logostelainicial_icon.svg',
                  width: 221, 
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}