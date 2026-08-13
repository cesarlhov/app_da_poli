// lib/pages/signup_page.dart

import 'package:app_da_poli/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

enum SignupState { idle, loading, success }

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  
  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE DE MEDIDAS E FONTES
  // =========================================================================
  final double _tamanhoLogo = 112.0;
  final double _espacoCimaLogo = 13.0; 
  final double _espacoBaixoLogo = 20.0; 
  final double _tamanhoFonteTitulo = 18.0; 
  final double _espacoTituloCaixa = 3.0; 
  final double _tamanhoFonteDigitada = 19.0; 
  final double _tamanhoFonteDica = 19.0; 
  final double _espacoAbaixoDaCaixa = 6.0; 
  final double _espacoNuspIdade = 15.0; 
  final double _espacoDaUltimaCaixaAteTermos = 16.0; 
  final double _tamanhoFonteCheckbox = 12.0; 
  final double _espacoCaixinhaTexto = 5.0; 
  final double _espacoEntreCheckboxes = 3.0; 
  final double _alturaBotoes = 40.0; 
  final double _espacoAteBotoesFinais = 16.0; 
  final double _larguraTotalVoltar = 95.0; 
  final double _espacoEntreBotoesFinais = 10.0; 
  final double _tamanhoEstrela = 32.0; 
  final double _avancoBotaoVoltar = 15.0; 
  // =========================================================================

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cursoController = TextEditingController();
  final _nuspController = TextEditingController();
  final _idadeController = TextEditingController();
  final _senhaController = TextEditingController();
  final _repitaSenhaController = TextEditingController();

  final _nomeFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _cursoFocus = FocusNode();
  final _nuspFocus = FocusNode();
  final _idadeFocus = FocusNode();
  final _senhaFocus = FocusNode();
  final _repitaSenhaFocus = FocusNode();

  bool _concordouTermos = false;
  bool _receberNovidades = false;
  SignupState _signupState = SignupState.idle;
  
  final AuthService _authService = AuthService(); // Nosso novo carteiro!
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _animController.forward();
    });

    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        _emailController.text = _emailController.text.toLowerCase();
        setState(() {}); 
      }
    });

    for (var focus in [_nomeFocus, _cursoFocus, _nuspFocus, _idadeFocus, _senhaFocus, _repitaSenhaFocus]) {
      focus.addListener(() { setState(() {}); });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose(); _emailController.dispose(); _cursoController.dispose();
    _nuspController.dispose(); _idadeController.dispose(); _senhaController.dispose();
    _repitaSenhaController.dispose();
    _nomeFocus.dispose(); _emailFocus.dispose(); _cursoFocus.dispose();
    _nuspFocus.dispose(); _idadeFocus.dispose(); _senhaFocus.dispose();
    _repitaSenhaFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  Widget _animado(Widget child, int index) {
    final double delayInicial = (index * 0.05).clamp(0.0, 1.0);
    final double delayFinal = (delayInicial + 0.4).clamp(0.0, 1.0);
    final animation = CurvedAnimation(parent: _animController, curve: Interval(delayInicial, delayFinal, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }

  Color _getGenericBorderColor(bool isFocused, TextEditingController ctrl) {
    if (isFocused) return const Color(0xFF0460E9);
    if (ctrl.text.isNotEmpty) return const Color(0xFFA1BF06); 
    return const Color(0xFF848B97); 
  }

  Color _getEmailBorderColor(bool isFocused) {
    final text = _emailController.text.trim();
    if (text.isEmpty) return isFocused ? const Color(0xFF0460E9) : const Color(0xFF848B97);
    if (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text)) return const Color(0xFFA1BF06);
    if (!isFocused) return const Color(0xFFD20A0A); 
    return const Color(0xFF0460E9);
  }

  Color _getRepitaSenhaBorderColor(bool isFocused) {
    if (_repitaSenhaController.text.isEmpty) return isFocused ? const Color(0xFF0460E9) : const Color(0xFF848B97);
    if (_senhaController.text == _repitaSenhaController.text) return const Color(0xFFA1BF06); 
    if (!isFocused) return const Color(0xFFD20A0A); 
    return const Color(0xFF0460E9);
  }

  Future<void> _criarConta() async {
    if (!_concordouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Concorde com os termos para continuar.'), backgroundColor: Color(0xFFD20A0A)));
      return;
    }
    if (_senhaController.text != _repitaSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('As senhas não coincidem.'), backgroundColor: Color(0xFFD20A0A)));
      return;
    }
    
    setState(() => _signupState = SignupState.loading);
    FocusScope.of(context).unfocus();

    try {
      // ✅ Tela burra: Repassa tudo pro AuthService e ele cria o Auth + Firestore juntos!
      await _authService.signUp(
        _emailController.text.trim(),
        _senhaController.text.trim(),
        _nomeController.text.trim(),
        _cursoController.text.trim(),
        _nuspController.text.trim(),
      );
      
      if (mounted) {
        setState(() => _signupState = SignupState.success);
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) context.go('/inicio');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _signupState = SignupState.idle);
        final msg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFFD20A0A)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent, systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: const TextSelectionThemeData(selectionHandleColor: Color(0xFF0460E9), cursorColor: Color(0xFF0460E9)),
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true, 
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: _espacoCimaLogo),
                  Hero(tag: 'logo_chaska', child: Image.asset('assets/images/logochaska_icon.png', width: _tamanhoLogo)),
                  SizedBox(height: _espacoBaixoLogo),
                  _animado(_buildFieldBlock('NOME COMPLETO', _nomeController, _nomeFocus, 'EX: TAYRONE SA', (f) => _getGenericBorderColor(f, _nomeController), nextFocus: _emailFocus), 1),
                  _animado(_buildFieldBlock('EMAIL', _emailController, _emailFocus, 'EX: OIMEUNOMEETAYRONE@USP.BR', _getEmailBorderColor, keyboardType: TextInputType.emailAddress, nextFocus: _cursoFocus), 2),
                  _animado(_buildFieldBlock('CURSO', _cursoController, _cursoFocus, 'EX: ENGENHARIA DE PESCA', (f) => _getGenericBorderColor(f, _cursoController), nextFocus: _nuspFocus), 3),
                  _animado(
                    Padding(
                      padding: EdgeInsets.only(bottom: _espacoAbaixoDaCaixa),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: _buildInnerFieldBlock('NUSP', _nuspController, _nuspFocus, 'EX: 31415926', (f) => _getGenericBorderColor(f, _nuspController), keyboardType: TextInputType.number, nextFocus: _idadeFocus)),
                          SizedBox(width: _espacoNuspIdade), 
                          Expanded(flex: 1, child: _buildInnerFieldBlock('IDADE', _idadeController, _idadeFocus, 'EX: 67', (f) => _getGenericBorderColor(f, _idadeController), keyboardType: TextInputType.number, nextFocus: _senhaFocus)),
                        ],
                      ),
                    ),
                    4
                  ),
                  _animado(_buildFieldBlock('SENHA', _senhaController, _senhaFocus, 'EX: SENHA', (f) => _getGenericBorderColor(f, _senhaController), obscureText: true, nextFocus: _repitaSenhaFocus), 5),
                  _animado(_buildInnerFieldBlock('REPITA A SENHA', _repitaSenhaController, _repitaSenhaFocus, 'EX: SENHA', _getRepitaSenhaBorderColor, obscureText: true), 6),
                  SizedBox(height: _espacoDaUltimaCaixaAteTermos),
                  _animado(
                    Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 24, height: 24, child: Checkbox(value: _concordouTermos, activeColor: const Color(0xFF0460E9), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)), side: const BorderSide(color: Color(0xFF848B97), width: 1.5), onChanged: (val) => setState(() => _concordouTermos = val ?? false))),
                            SizedBox(width: _espacoCaixinhaTexto), 
                            Expanded(child: Text('CONCORDO COM OS TERMOS', style: TextStyle(fontFamily: 'Lato', fontSize: _tamanhoFonteCheckbox, fontWeight: FontWeight.w800, color: const Color(0xFF848B97)))),
                          ],
                        ),
                        SizedBox(height: _espacoEntreCheckboxes), 
                        Row(
                          children: [
                            SizedBox(width: 24, height: 24, child: Checkbox(value: _receberNovidades, activeColor: const Color(0xFF0460E9), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)), side: const BorderSide(color: Color(0xFF848B97), width: 1.5), onChanged: (val) => setState(() => _receberNovidades = val ?? false))),
                            SizedBox(width: _espacoCaixinhaTexto),
                            Expanded(child: Text('GOSTARIA DE RECEBER NOVIDADES', style: TextStyle(fontFamily: 'Lato', fontSize: _tamanhoFonteCheckbox, fontWeight: FontWeight.w800, color: const Color(0xFF848B97)))),
                          ],
                        ),
                      ],
                    ),
                    7
                  ),
                  SizedBox(height: _espacoAteBotoesFinais),
                  _animado(
                    Row(
                      children: [
                        SizedBox(
                          width: _larguraTotalVoltar, height: _alturaBotoes,
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: Stack(
                              clipBehavior: Clip.none, alignment: Alignment.centerLeft, 
                              children: [
                                Positioned(left: 0, child: Image.asset('assets/images/estrela_icon.png', height: _tamanhoEstrela, width: _tamanhoEstrela, color: const Color(0xFF0085FF))),
                                Positioned(
                                  left: _avancoBotaoVoltar, right: 0, top: 0, bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0460E9), Color(0xFF0D41A9)], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(6.7), border: Border.all(color: const Color(0xFF0085FF), width: 1.7)),
                                    alignment: Alignment.center,
                                    child: const Padding(padding: EdgeInsets.only(top: 3.0), child: Text('VOLTAR', style: TextStyle(fontFamily: 'Aristotelica', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 1.2))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: _espacoEntreBotoesFinais),
                        Expanded( 
                          child: GestureDetector( 
                            onTap: _signupState == SignupState.loading ? null : _criarConta,
                            child: Container(
                              height: _alturaBotoes, alignment: Alignment.center,
                              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7C9F19), Color(0xFFAFCB00)], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(6.7), border: Border.all(color: const Color(0xFFCEDD26), width: 1.7)),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  if (child.key == const ValueKey('loading') || child.key == const ValueKey('text')) return child;
                                  return ScaleTransition(scale: animation, child: child);
                                },
                                child: _signupState == SignupState.loading
                                    ? const SizedBox(key: ValueKey('loading'), width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white, strokeCap: StrokeCap.round))
                                    : _signupState == SignupState.success
                                        ? const Icon(Icons.check_rounded, key: ValueKey('check'), color: Colors.white, size: 26)
                                        : const Padding(key: ValueKey('text'), padding: EdgeInsets.only(top: 3.0), child: Text('CRIAR CONTA', style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF303B02), letterSpacing: 1.2))),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    8
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldBlock(String label, TextEditingController controller, FocusNode focusNode, String hint, Color Function(bool) getBorderColor, {bool obscureText = false, TextInputType keyboardType = TextInputType.text, FocusNode? nextFocus}) {
    return Padding(
      padding: EdgeInsets.only(bottom: _espacoAbaixoDaCaixa),
      child: _buildInnerFieldBlock(label, controller, focusNode, hint, getBorderColor, obscureText: obscureText, keyboardType: keyboardType, nextFocus: nextFocus),
    );
  }

  Widget _buildInnerFieldBlock(String label, TextEditingController controller, FocusNode focusNode, String hint, Color Function(bool) getBorderColor, {bool obscureText = false, TextInputType keyboardType = TextInputType.text, FocusNode? nextFocus}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: _tamanhoFonteTitulo, fontWeight: FontWeight.w800, color: const Color(0xFF162038), letterSpacing: -0.5)),
        SizedBox(height: _espacoTituloCaixa),
        SizedBox(
          height: 47,
          child: TextField(
            controller: controller, focusNode: focusNode, obscureText: obscureText, keyboardType: keyboardType,
            textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
            onSubmitted: (_) { if (nextFocus != null) { FocusScope.of(context).requestFocus(nextFocus); } else { FocusScope.of(context).unfocus(); } },
            style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoFonteDigitada, color: const Color(0xFF5A5F62)), 
            textAlignVertical: TextAlignVertical.center, cursorColor: const Color(0xFF0460E9), cursorWidth: 2.5, cursorHeight: 20, cursorRadius: const Radius.circular(5.0), 
            onChanged: (_) => setState(() {}), 
            decoration: InputDecoration(
              hintText: hint, hintStyle: TextStyle(fontFamily: 'Aristotelica', color: const Color(0xFFBCBEBF), fontSize: _tamanhoFonteDica, height: 1.0), 
              contentPadding: const EdgeInsets.only(left: 11.0, right: 11.0, top: 15.0, bottom: 2.0),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.7), borderSide: BorderSide(color: getBorderColor(false), width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.7), borderSide: BorderSide(color: getBorderColor(true), width: 2.0)),
            ),
          ),
        ),
      ],
    );
  }
}