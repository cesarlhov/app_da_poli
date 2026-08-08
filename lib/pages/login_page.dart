// lib/pages/login_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:go_router/go_router.dart';

// Máquina de estados para animar o botão!
enum LoginState { idle, loading, success }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Sensores para saber se a pessoa está clicando dentro ou fora das caixas
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  LoginState _loginState = LoginState.idle;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _animController.forward();
      }
    });

    // O sensor que pinta de vermelho e formata o email ao sair da caixa
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        // Ao clicar fora, pega o que foi digitado e converte tudo para minúsculo instantaneamente!
        _identifierController.text = _identifierController.text.toLowerCase();
        setState(() {}); // Atualiza a tela para pintar as bordas
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

  // Função para validar se o email tem formato correto (@ e .com)
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Cor Dinâmica da Borda do Email
  Color _getEmailBorderColor(bool isFocused) {
    final text = _identifierController.text.trim();
    if (text.isEmpty) return isFocused ? const Color(0xFF0460E9) : const Color(0xFF848B97);
    
    if (_isValidEmail(text)) return const Color(0xFFA1BF06); // Verde se for válido
    
    // Vermelho SOMENTE se estiver errado e a pessoa tiver saído da caixa
    if (!_emailFocusNode.hasFocus) return const Color(0xFFD20A0A); 
    
    return isFocused ? const Color(0xFF0460E9) : const Color(0xFF848B97);
  }

  // Cor Dinâmica da Borda da Senha
  Color _getPasswordBorderColor(bool isFocused) {
    // Fica verde instantaneamente após o carregamento ser sucesso!
    if (_loginState == LoginState.success) return const Color(0xFFA1BF06);
    return isFocused ? const Color(0xFF0460E9) : const Color(0xFF848B97);
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
    
    setState(() => _loginState = LoginState.loading);
    FocusScope.of(context).unfocus(); 

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _identifierController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (mounted) {
        setState(() => _loginState = LoginState.success);
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) context.go('/inicio');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _loginState = LoginState.idle); // Para a bolinha!
        String erro = 'Erro ao entrar. Tente novamente.';
        if (e.code == 'user-not-found' || e.code == 'invalid-email') {
          erro = 'Nenhuma conta encontrada com este e-mail.';
        } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          erro = 'A senha está incorreta.';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro), backgroundColor: const Color(0xFFD20A0A)));
      }
    } catch (e) {
      // REDE DE SEGURANÇA: Captura qualquer outro travamento e para a bolinha
      if (mounted) {
        setState(() => _loginState = LoginState.idle);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Credenciais incorretas ou erro de rede.'), backgroundColor: Color(0xFFD20A0A)));
      }
    }
  }

  // Olha como ela ficou limpa! Ela só chama a classe lá do final do arquivo agora.
  void _recuperarSenha() {
    showDialog(
      context: context,
      barrierDismissible: false, // Impede de fechar clicando fora sem querer
      builder: (context) => PasswordRecoveryDialog(initialEmail: _identifierController.text),
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
      // THEME INJETADO AQUI PARA A GOTA INVERTIDA FICAR AZUL!
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: const TextSelectionThemeData(
            selectionHandleColor: Color(0xFF0460E9), // A cor da bolinha/gota de arrastar o texto
            cursorColor: Color(0xFF0460E9),
          ),
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
                          child: Image.asset(
                            'assets/images/logochaska_icon.png',
                            width: 112.0, 
                          ),
                        ),
                        
                        const SizedBox(height: 20),

                        _animado(
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'NOME, EMAIL, NUSP OU NÚMERO',
                              style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: 18.5, fontWeight: FontWeight.w800, color: Color(0xFF162038), letterSpacing: -0.5),
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
                              focusNode: _emailFocusNode,
                              // ISSO CHAMA O TECLADO COM "@"
                              keyboardType: TextInputType.emailAddress, 
                              style: const TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 20.5, color: Color(0xFF5A5F62)), 
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: const Color(0xFF0460E9), 
                              cursorWidth: 2.5, 
                              cursorHeight: 20, 
                              cursorRadius: const Radius.circular(5.0), 
                              onChanged: (text) => setState(() {}), 
                              decoration: InputDecoration(
                                hintText: 'EX: OIMEUNOMEETAYRONE@USP.BR',
                                hintStyle: const TextStyle(fontFamily: 'Aristotelica', color: Color(0xFFBCBEBF), fontSize: 19, height: 1.0,), 
                                contentPadding: const EdgeInsets.only(
                                  left: 11.0, right: 11.0, top: 15.0, bottom: 2.0,  
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.7),
                                  borderSide: BorderSide(color: _getEmailBorderColor(false), width: 1.7),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.7),
                                  borderSide: BorderSide(color: _getEmailBorderColor(true), width: 2.0),
                                ),
                              ),
                            ),
                          ),
                          1,
                        ),
                        
                        const SizedBox(height: 8), 

                        _animado(
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'SENHA',
                              style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: 18.5, fontWeight: FontWeight.w800, color: Color(0xFF162038), letterSpacing: -0.5),
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
                              focusNode: _passwordFocusNode,
                              
                              obscureText: true,
                              
                              style: const TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 20.5, color: Color(0xFF5A5F62)),
                              textAlignVertical: TextAlignVertical.center,
                              
                              cursorColor: const Color(0xFF0460E9),
                              cursorWidth: 2.5,
                              cursorHeight: 20, 
                              cursorRadius: const Radius.circular(5.0), 

                              decoration: InputDecoration(
                                hintText: 'EX: SENHA',
                                hintStyle: const TextStyle(fontFamily: 'Aristotelica', color: Color(0xFFBCBEBF), fontSize: 19, height: 1.0, letterSpacing: 0.0), 
                                contentPadding: const EdgeInsets.only(
                                  left: 11.0, right: 11.0, top: 15.0, bottom: 2.0, 
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.7),
                                  borderSide: BorderSide(color: _getPasswordBorderColor(false), width: 1.7), 
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.7),
                                  borderSide: BorderSide(color: _getPasswordBorderColor(true), width: 2.0), 
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
                                onTap: _recuperarSenha, // << CHAMA A FUNÇÃO LIMPA
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
                          GestureDetector( 
                            onTap: _loginState == LoginState.loading ? null : _login,
                            child: Container(
                              height: 44.3, 
                              width: double.infinity, 
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF7C9F19), Color(0xFFAFCB00)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(6.7),
                                border: Border.all(color: const Color(0xFFCEDD26), width: 1.7),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  if (child.key == const ValueKey('loading') || child.key == const ValueKey('text')) {
                                    return child;
                                  }
                                  return ScaleTransition(scale: animation, child: child);
                                },
                                child: _loginState == LoginState.loading
                                    ? const SizedBox(
                                        key: ValueKey('loading'),
                                        width: 20, 
                                        height: 20, 
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5, 
                                          color: Colors.white, 
                                          strokeCap: StrokeCap.round, 
                                        )
                                      )
                                    : _loginState == LoginState.success
                                        ? const Icon(
                                            Icons.check_rounded, 
                                            key: ValueKey('check'), 
                                            color: Colors.white, 
                                            size: 26
                                          )
                                        : const Text(
                                            'ENTRAR', 
                                            key: ValueKey('text'),
                                            style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 17.25, color: Color(0xFF303B02), letterSpacing: 1.2), 
                                          ),
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
                              child: Image.asset(
                                'assets/images/logogoogle_icon.png', 
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
      ),
    );
  }
}

// ============================================================================
// WIDGET DO POPUP DE RECUPERAÇÃO DE SENHA (UI NOVA + LÓGICA FIREBASE)
// ============================================================================
class PasswordRecoveryDialog extends StatefulWidget {
  final String initialEmail;
  const PasswordRecoveryDialog({super.key, required this.initialEmail});

  @override
  State<PasswordRecoveryDialog> createState() => _PasswordRecoveryDialogState();
}

class _PasswordRecoveryDialogState extends State<PasswordRecoveryDialog> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

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
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link enviado! Verifique sua caixa de entrada e spam.'),
            backgroundColor: Color(0xFFA1BF06), // Verde sucesso!
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String erro = 'Erro ao enviar email. Tente novamente.';
        if (e.code == 'user-not-found') {
          erro = 'Nenhum usuário encontrado com este e-mail.';
        } else if (e.code == 'invalid-email') {
          erro = 'O formato do e-mail é inválido.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro), backgroundColor: const Color(0xFFD20A0A)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFF2B705), width: 3.0), // Borda Amarela!
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'RECUPERAR CONTA', 
              style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: 18.5, fontWeight: FontWeight.w900, color: Color(0xFF162038))
            ),
            const SizedBox(height: 6),
            const Text(
              'DIGITE O E-MAIL CADASTRADO PARA RECEBER O LINK DE REDEFINIÇÃO DE SENHA.', 
              style: TextStyle(fontFamily: 'Aristotelica', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFBCBEBF), height: 1.2)
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 47,
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF5A5F62)),
                cursorColor: const Color(0xFFF2B705),
                decoration: InputDecoration(
                  hintText: 'EX: NOME@USP.BR',
                  hintStyle: const TextStyle(fontFamily: 'Aristotelica', color: Color(0xFFBCBEBF), fontSize: 16, height: 1.0),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.7),
                    borderSide: const BorderSide(color: Color(0xFF848B97), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.7),
                    borderSide: const BorderSide(color: Color(0xFFF2B705), width: 2.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('CANCELAR', style: TextStyle(fontFamily: 'LeagueSpartan', color: Color(0xFFBCBEBF), fontSize: 14, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFC107), Color(0xFFF39C12)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(6.7),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.7)),
                    ),
                    onPressed: _isLoading ? null : _enviarLink,
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('ENVIAR LINK', style: TextStyle(fontFamily: 'LeagueSpartan', color: Color(0xFF162038), fontSize: 15, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}