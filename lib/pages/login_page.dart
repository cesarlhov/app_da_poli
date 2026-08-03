// lib/pages/login_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // MÁGICA: Só dispara a cascata quando a logo atinge a metade do caminho (500ms)
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Widget _animado(Widget child, int index) {
    final double delayInicial = (index * 0.08).clamp(0.0, 1.0);
    final double delayFinal = (delayInicial + 0.5).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(delayInicial, delayFinal, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1.2), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }

  Future<void> _login() async {
    if (_identifierController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _identifierController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) context.go('/inicio');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao entrar. Verifique os dados.')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _recuperarSenha() {
    final resetEmailController = TextEditingController(text: _identifierController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('RECUPERAR SENHA', style: TextStyle(fontFamily: 'LeagueSpartan', fontWeight: FontWeight.w800, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Digite o email cadastrado para receber o link de redefinição.', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              style: const TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'EX: OIMEUNOME@USP.BR',
                hintStyle: const TextStyle(fontFamily: 'Aristotelica', color: Color(0xFFBCBEBF), fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.7)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0460E9)),
            onPressed: () async {
              if (resetEmailController.text.isNotEmpty) {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: resetEmailController.text.trim());
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link enviado! Verifique seu email.')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao enviar email.')));
                }
              }
            },
            child: const Text('ENVIAR', style: TextStyle(fontFamily: 'Aristotelica', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent, 
        systemNavigationBarIconBrightness: Brightness.dark, 
        statusBarColor: Colors.transparent, 
        statusBarIconBrightness: Brightness.dark, 
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false, 
        
        body: SizedBox.expand(
          child: Stack(
            children: [
              SafeArea(
                bottom: false, 
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 108),
                      
                      Hero(
                        tag: 'logo_chaska', 
                        child: SvgPicture.asset(
                          'assets/images/logochaska_icon.svg',
                          width: 112.0, 
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      _animado(
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'NOME, EMAIL, NUSP OU NÚMERO',
                            style: const TextStyle(fontFamily: 'LeagueSpartan', fontSize: 18.5, fontWeight: FontWeight.w800, color: Color(0xFF162038), letterSpacing: -0.5),
                          ),
                        ),
                        0,
                      ),
                      
                      const SizedBox(height: 4), 
                      
                      _animado(
                        SizedBox(
                          height: 47, 
                          child: TextField(
                            controller: _identifierController,
                            style: const TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 20.5), 
                            textAlignVertical: TextAlignVertical.center,
                            
                            cursorColor: const Color(0xFF0460E9), 
                            cursorWidth: 2.5, 
                            cursorHeight: 20, 
                            cursorRadius: const Radius.circular(5.0), 

                            decoration: InputDecoration(
                              hintText: 'EX: OIMEUNOMEETAYRONE@USP.BR',
                              hintStyle: const TextStyle(fontFamily: 'Aristotelica', color: Color(0xFFBCBEBF), fontSize: 19, height: 1.0,), 
                              contentPadding: const EdgeInsets.only(
                                left: 11.0,   
                                right: 11.0,  
                                top: 15.0, 
                                bottom: 2.0,  
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.7),
                                borderSide: const BorderSide(color: Color(0xFF848B97), width: 1.7),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.7),
                                borderSide: const BorderSide(color: Color(0xFF0460E9), width: 2.0),
                              ),
                            ),
                          ),
                        ),
                        1,
                      ),
                      
                      const SizedBox(height: 8), 

                      _animado(
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'SENHA',
                            style: const TextStyle(fontFamily: 'LeagueSpartan', fontSize: 18.5, fontWeight: FontWeight.w800, color: Color(0xFF162038), letterSpacing: -0.5),
                          ),
                        ),
                        2,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      _animado(
                        SizedBox(
                          height: 47, 
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 20.5),
                            textAlignVertical: TextAlignVertical.center,
                            
                            cursorColor: const Color(0xFF0460E9),
                            cursorWidth: 2.5,
                            cursorHeight: 20, 
                            cursorRadius: const Radius.circular(5.0), 

                            decoration: InputDecoration(
                              hintText: 'EX: SENHA',
                              hintStyle: const TextStyle(fontFamily: 'Aristotelica', color: Color(0xFFBCBEBF), fontSize: 19, height: 1.0,), 
                              contentPadding: const EdgeInsets.only(
                                left: 11.0,   
                                right: 11.0,  
                                top: 15.0,    
                                bottom: 2.0, 
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.7),
                                borderSide: const BorderSide(color: Color(0xFF848B97), width: 1.7),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.7),
                                borderSide: const BorderSide(color: Color(0xFF0460E9), width: 2.0),
                              ),
                            ),
                          ),
                        ),
                        3,
                      ),
                      
                      const SizedBox(height: 10.0),

                      _animado(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: _recuperarSenha,
                              child: const Text(
                                'ESQUECEU A SENHA?',
                                style: TextStyle(fontFamily: 'Lato', fontStyle: FontStyle.italic, color: Color(0xFFBCBEBF), fontSize: 13, fontWeight: FontWeight.w900), 
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/signup'), 
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFF0460E9), Color(0xFF70C840)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ).createShader(bounds),
                                child: const Text(
                                  'CRIAR CONTA',
                                  style: TextStyle(fontFamily: 'Lato', fontStyle: FontStyle.normal, color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                        4,
                      ),
                      
                      const SizedBox(height: 18),

                      _animado(
                        Container(
                          height: 44.3, 
                          width: double.infinity, 
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C9F19), Color(0xFFAFCB00)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(6.7),
                            border: Border.all(color: const Color(0xFFCEDD26), width: 1.7),
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent, 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.7)),
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text(
                                    'ENTRAR', 
                                    style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 17.25, color: Color(0xFF303B02), letterSpacing: 1.2), 
                                  ),
                          ),
                        ),
                        5,
                      ),
                      
                      const SizedBox(height: 25), 

                      _animado(
                        const Text(
                          'CONECTAR-SE COM', 
                          style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: 18.5, fontWeight: FontWeight.w800, color: Color(0xFF162038), letterSpacing: -0.5),
                        ),
                        6,
                      ),
                      
                      const SizedBox(height: 10.0),
                      
                      _animado(
                        InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(30), 
                          child: Container(
                            width: 46, 
                            height: 46, 
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, 
                              border: Border.all(color: const Color(0xFF848B97), width: 1.7),
                            ),
                            child: SvgPicture.asset(
                              'assets/images/logogoogle_icon.svg', 
                              height: 32, 
                            ), 
                          ),
                        ),
                        7,
                      ),
                      
                      const SizedBox(height: 100), 
                    ],
                  ),
                ),
              ),
              
              Positioned(
                bottom: safeBottom > 0 ? safeBottom + 25.0 : 15.0, 
                left: 0,
                right: 0,
                child: Center(
                  child: _animado(
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'UMA AJUDINHA?', 
                        style: TextStyle(
                          fontFamily: 'LeagueSpartan', 
                          color: Color(0xFFBCBEBF), 
                          fontSize: 13, 
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0, 
                        ) 
                      ),
                    ),
                    8,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}