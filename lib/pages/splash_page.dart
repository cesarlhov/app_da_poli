// lib/pages/splash_page.dart

import 'package:app_da_poli/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE DE MEDIDAS (TELA DE ABERTURA)
  // =========================================================================
  final double _tamanhoLogo = 170.0; 
  final double _deslocamentoVerticalCentro = 0.0; 
  final double _distanciaBaixoAssinatura = -25.0; 
  final double _distanciaDireitaAssinatura = 23.0; 
  final double _tamanhoLogosRodape = 225.0;
  final double _distanciaRodapeAteBaseSegura = 30.0; 
  // =========================================================================

  bool _hideFooter = false;
  final AuthService _authService = AuthService(); // Nosso carteiro de Auth

  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      setState(() {
        _hideFooter = true; 
      });
      await Future.delayed(const Duration(milliseconds: 400));
    }
    if (mounted) {
      // ✅ A tela pergunta ao Service quem está logado
      final user = _authService.currentUser;
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
      body: SafeArea( 
        child: Column(
          children: [
            Expanded(
              child: Center( 
                child: Transform.translate(
                  offset: Offset(0, _deslocamentoVerticalCentro),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Hero(
                        tag: 'logo_chaska', 
                        child: Image.asset(
                          'assets/images/logochaska_icon.png',
                          width: _tamanhoLogo, 
                        ),
                      ),
                      Positioned(
                        right: _distanciaDireitaAssinatura,  
                        bottom: _distanciaBaixoAssinatura, 
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
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: _distanciaRodapeAteBaseSegura),
              child: AnimatedOpacity(
                opacity: _hideFooter ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 700),
                child: Image.asset(
                  'assets/images/logostelainicial_icon.png',
                  width: _tamanhoLogosRodape, 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}