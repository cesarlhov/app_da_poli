// lib/pages/login_page.dart

import 'package:app_da_poli/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:go_router/go_router.dart';

enum LoginState { idle, loading, success }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  
  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE DE MEDIDAS E FONTES (TELA DE LOGIN)
  // =========================================================================
  final double _tamanhoLogo = 112.0;
  final double _espacoCimaLogo = 108.0; 
  final double _espacoBaixoLogo = 24.0; 
  final double _tamanhoFonteTitulo = 18.0; 
  final double _espacoTituloCaixa = 3.0; 
  final double _tamanhoFonteDigitada = 19.0; 
  final double _tamanhoFonteDica = 19.0; 
  final double _espacoAbaixoDaCaixa = 6.0; 
  final double _alturaBotaoEntrar = 40.0; 
  final double _espacoAteBotoesAcao = 10.0; 
  final double _espacoAteBotaoEntrar = 18.0; 
  final double _espacoAteConectarCom = 25.0; 
  final double _espacoAteIconeGoogle = 8.0; 
  // =========================================================================

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final AuthService _authService = AuthService(); // Nosso carteiro!
  
  LoginState _loginState = LoginState.idle;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _animController.forward();
    });

    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        _identifierController.text = _identifierController.text.toLowerCase();
        setState(() {}); 
      }
    });
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Color _getEmailBorderColor(bool isFocused) {
    final text = _identifierController.text.trim();
    if (text.isEmpty) return isFocused ? const Color(0xFF0460E9) : const Color(0xFF848B97);
    if (_isValidEmail(text)) return const Color(0xFFA1BF06); 
    if (!_emailFocusNode.hasFocus) return const Color(0xFFD20A0A); 
    return isFocused ? const Color(0xFF0460E9) : const Color(0xFF848B97);
  }

  Color _getPasswordBorderColor(bool isFocused) {
    if (_loginState == LoginState.success) return const Color(0xFFA1BF06);
    return isFocused ? const Color(0xFF0460E9) : const Color(0xFF848B97);
  }

  Widget _animado(Widget child, int index) {
    final double delayInicial = (index * 0.08).clamp(0.0, 1.0);
    final double delayFinal = (delayInicial + 0.5).clamp(0.0, 1.0);
    final animation = CurvedAnimation(parent: _animController, curve: Interval(delayInicial, delayFinal, curve: Curves.easeOutCubic));
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
    
    setState(() => _loginState = LoginState.loading);
    FocusScope.of(context).unfocus(); 

    try {
      // ✅ Tela burra: Apenas entrega os textos pro AuthService
      await _authService.signIn(_identifierController.text.trim(), _passwordController.text.trim());
      
      if (mounted) {
        setState(() => _loginState = LoginState.success);
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) context.go('/inicio');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loginState = LoginState.idle);
        // Limpa a palavra "Exception:" que o Dart adiciona
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: const Color(0xFFD20A0A)));
      }
    }
  }

  void _recuperarSenha() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PasswordRecoveryDialog(initialEmail: _identifierController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent, 
        systemNavigationBarIconBrightness: Brightness.dark, 
        statusBarColor: Colors.transparent, 
        statusBarIconBrightness: Brightness.dark, 
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: const TextSelectionThemeData(
            selectionHandleColor: Color(0xFF0460E9), 
            cursorColor: Color(0xFF0460E9),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true, 
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
                        SizedBox(height: _espacoCimaLogo),
                        Hero(tag: 'logo_chaska', child: Image.asset('assets/images/logochaska_icon.png', width: _tamanhoLogo)),
                        SizedBox(height: _espacoBaixoLogo),
                        _animado(Align(alignment: Alignment.centerLeft, child: Text('NOME, EMAIL, NUSP OU NÚMERO', style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: _tamanhoFonteTitulo, fontWeight: FontWeight.w800, color: const Color(0xFF162038), letterSpacing: -0.5))), 0),
                        SizedBox(height: _espacoTituloCaixa), 
                        _animado(
                          SizedBox(
                            height: 47, 
                            child: TextField(
                              controller: _identifierController,
                              focusNode: _emailFocusNode,
                              keyboardType: TextInputType.emailAddress, 
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                              style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoFonteDigitada, color: const Color(0xFF5A5F62)), 
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: const Color(0xFF0460E9), 
                              cursorWidth: 2.5, 
                              cursorHeight: 20, 
                              cursorRadius: const Radius.circular(5.0), 
                              onChanged: (text) => setState(() {}), 
                              decoration: InputDecoration(
                                hintText: 'EX: OIMEUNOMEETAYRONE@USP.BR',
                                hintStyle: TextStyle(fontFamily: 'Aristotelica', color: const Color(0xFFBCBEBF), fontSize: _tamanhoFonteDica, height: 1.0,), 
                                contentPadding: const EdgeInsets.only(left: 11.0, right: 11.0, top: 15.0, bottom: 2.0),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.7), borderSide: BorderSide(color: _getEmailBorderColor(false), width: 1.7)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.7), borderSide: BorderSide(color: _getEmailBorderColor(true), width: 2.0)),
                              ),
                            ),
                          ),
                          1,
                        ),
                        SizedBox(height: _espacoAbaixoDaCaixa), 
                        _animado(Align(alignment: Alignment.centerLeft, child: Text('SENHA', style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: _tamanhoFonteTitulo, fontWeight: FontWeight.w800, color: const Color(0xFF162038), letterSpacing: -0.5))), 2),
                        SizedBox(height: _espacoTituloCaixa),
                        _animado(
                          SizedBox(
                            height: 47, 
                            child: TextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => FocusScope.of(context).unfocus(),
                              style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoFonteDigitada, color: const Color(0xFF5A5F62)),
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: const Color(0xFF0460E9),
                              cursorWidth: 2.5,
                              cursorHeight: 20, 
                              cursorRadius: const Radius.circular(5.0), 
                              decoration: InputDecoration(
                                hintText: 'EX: SENHA',
                                hintStyle: TextStyle(fontFamily: 'Aristotelica', color: const Color(0xFFBCBEBF), fontSize: _tamanhoFonteDica, height: 1.0, letterSpacing: 0.0), 
                                contentPadding: const EdgeInsets.only(left: 11.0, right: 11.0, top: 15.0, bottom: 2.0),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.7), borderSide: BorderSide(color: _getPasswordBorderColor(false), width: 1.7)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.7), borderSide: BorderSide(color: _getPasswordBorderColor(true), width: 2.0)),
                              ),
                            ),
                          ),
                          3,
                        ),
                        SizedBox(height: _espacoAteBotoesAcao),
                        _animado(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: _recuperarSenha, 
                                child: const Text('ESQUECEU A SENHA?', style: TextStyle(fontFamily: 'Lato', fontStyle: FontStyle.italic, color: Color(0xFFBCBEBF), fontSize: 13, fontWeight: FontWeight.w900)),
                              ),
                              GestureDetector(
                                onTap: () => context.push('/signup'), 
                                child: ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF0460E9), Color(0xFF70C840)], begin: Alignment.centerLeft, end: Alignment.centerRight).createShader(bounds),
                                  child: const Text('CRIAR CONTA', style: TextStyle(fontFamily: 'Lato', fontStyle: FontStyle.normal, color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                                ),
                              ),
                            ],
                          ),
                          4,
                        ),
                        SizedBox(height: _espacoAteBotaoEntrar),
                        _animado(
                          GestureDetector( 
                            onTap: _loginState == LoginState.loading ? null : _login,
                            child: Container(
                              height: _alturaBotaoEntrar, 
                              width: double.infinity, 
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF7C9F19), Color(0xFFAFCB00)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                                borderRadius: BorderRadius.circular(6.7),
                                border: Border.all(color: const Color(0xFFCEDD26), width: 1.7),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  if (child.key == const ValueKey('loading') || child.key == const ValueKey('text')) return child;
                                  return ScaleTransition(scale: animation, child: child);
                                },
                                child: _loginState == LoginState.loading
                                    ? const SizedBox(key: ValueKey('loading'), width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white, strokeCap: StrokeCap.round))
                                    : _loginState == LoginState.success
                                        ? const Icon(Icons.check_rounded, key: ValueKey('check'), color: Colors.white, size: 26)
                                        : const Padding(key: ValueKey('text'), padding: EdgeInsets.only(top: 3.0), child: Text('ENTRAR', style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 17.25, color: Color(0xFF303B02), letterSpacing: 1.2))),
                              ),
                            ),
                          ),
                          5,
                        ),
                        SizedBox(height: _espacoAteConectarCom), 
                        _animado(Text('CONECTAR-SE COM', style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: _tamanhoFonteTitulo, fontWeight: FontWeight.w800, color: const Color(0xFF162038), letterSpacing: -0.5)), 6),
                        SizedBox(height: _espacoAteIconeGoogle),
                        _animado(
                          InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(30), 
                            child: Container(
                              width: 46, height: 46, alignment: Alignment.center,
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF848B97), width: 1.7)),
                              child: Image.asset('assets/images/logogoogle_icon.png', height: 32), 
                            ),
                          ),
                          7,
                        ),
                        const SizedBox(height: 100), 
                      ],
                    ),
                  ),
                ),
                if (!isKeyboardOpen)
                  Positioned(
                    bottom: safeBottom > 0 ? safeBottom + 25.0 : 15.0, 
                    left: 0, right: 0,
                    child: Center(
                      child: _animado(
                        GestureDetector(
                          onTap: () {},
                          child: const Text('UMA AJUDINHA?', style: TextStyle(fontFamily: 'LeagueSpartan', color: Color(0xFFBCBEBF), fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.0))
                        ),
                        8,
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET DO POPUP DE RECUPERAÇÃO DE SENHA (PADRONIZADO E BLINDADO)
// ============================================================================
class PasswordRecoveryDialog extends StatefulWidget {
  final String initialEmail;
  const PasswordRecoveryDialog({super.key, required this.initialEmail});

  @override
  State<PasswordRecoveryDialog> createState() => _PasswordRecoveryDialogState();
}

class _PasswordRecoveryDialogState extends State<PasswordRecoveryDialog> {
  final double _espessuraBordaPopup = 1.7; 
  final double _raioBordaPopup = 6.7; 
  final double _paddingInternoTopo = 18.0; 
  final double _paddingInternoBaixo = 18.0; 
  final double _paddingInternoLaterais = 19.0; 
  final double _espacoCimaTitulo = 0.0; 
  final double _espacoTituloSubtitulo = 4.0; 
  final double _espacoSubtituloCaixa = 16.0; 
  final double _espacoCaixaBotoes = 12.0; 
  final double _espacoBaixoBotoes = 0.0; 
  final double _alturaBotoes = 40.0; 
  final double _espacoEntreBotoes = 20.0; 

  final _emailController = TextEditingController();
  final AuthService _authService = AuthService(); // Nosso carteiro!
  bool _isLoading = false;
  bool _hasError = false; 

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviarLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _hasError = true);
      return;
    }
    setState(() { _isLoading = true; _hasError = false; });

    try {
      // ✅ Chamada limpa
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link enviado! Verifique sua caixa de entrada e spam.'), backgroundColor: Color(0xFFA1BF06)));
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; _hasError = true; });
        final msg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFFD20A0A)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_raioBordaPopup), side: BorderSide(color: const Color(0xFFFFBF00), width: _espessuraBordaPopup)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: EdgeInsets.only(top: _paddingInternoTopo, bottom: _paddingInternoBaixo, left: _paddingInternoLaterais, right: _paddingInternoLaterais),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: _espacoCimaTitulo),
            const Text('RECUPERAR SENHA', style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: 18.5, fontWeight: FontWeight.w900, color: Color(0xFF162038), letterSpacing: -0.5)),
            SizedBox(height: _espacoTituloSubtitulo),
            const Text('DIGITE O E-MAIL CADASTRADO PARA RECEBER O LINK DE REDEFINIÇÃO DE SENHA.', style: TextStyle(fontFamily: 'Lato', fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFBCBEBF), height: 1.2)),
            SizedBox(height: _espacoSubtituloCaixa),
            SizedBox(
              height: 47,
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) { if (_hasError) setState(() => _hasError = false); },
                style: const TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 19.0, color: Color(0xFF5A5F62)),
                textAlignVertical: TextAlignVertical.center,
                cursorColor: const Color(0xFF0460E9), cursorWidth: 2.5, cursorHeight: 20, cursorRadius: const Radius.circular(5.0),
                decoration: InputDecoration(
                  hintText: 'EX: NOME@USP.BR',
                  hintStyle: const TextStyle(fontFamily: 'Aristotelica', color: Color(0xFFBCBEBF), fontSize: 19.0, height: 1.0),
                  contentPadding: const EdgeInsets.only(left: 11.0, right: 11.0, top: 15.0, bottom: 2.0),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.7), borderSide: BorderSide(color: _hasError ? const Color(0xFFD20A0A) : const Color(0xFF848B97), width: 1.7)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.7), borderSide: BorderSide(color: _hasError ? const Color(0xFFD20A0A) : const Color(0xFF848B97), width: 2.0)),
                ),
              ),
            ),
            SizedBox(height: _espacoCaixaBotoes),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: _isLoading ? null : () => Navigator.pop(context),
                  child: Container(
                    height: _alturaBotoes, color: Colors.transparent, alignment: Alignment.center,
                    child: const Padding(padding: EdgeInsets.only(top: 3.0), child: Text('CANCELAR', style: TextStyle(fontFamily: 'Aristotelica', color: Color(0xFFBCBEBF), fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.2))),
                  ),
                ),
                SizedBox(width: _espacoEntreBotoes),
                GestureDetector(
                  onTap: _isLoading ? null : _enviarLink,
                  child: Container(
                    height: _alturaBotoes, padding: const EdgeInsets.symmetric(horizontal: 20.0), alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFEBC12B), Color(0xFFD38F0D)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                      borderRadius: BorderRadius.circular(6.7), border: Border.all(color: const Color(0xFFFFBF00), width: 1.7), 
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF3B2602), strokeWidth: 2.5, strokeCap: StrokeCap.round))
                      : const Padding(padding: EdgeInsets.only(top: 3.0), child: Text('RECEBER LINK', style: TextStyle(fontFamily: 'Aristotelica', color: Color(0xFF321C06), fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.2))),
                  ),
                ),
              ],
            ),
            SizedBox(height: _espacoBaixoBotoes),
          ],
        ),
      ),
    );
  }
}