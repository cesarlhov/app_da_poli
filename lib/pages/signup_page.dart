// lib/pages/signup_page.dart

import 'package:app_da_poli/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'package:go_router/go_router.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cursoController = TextEditingController();
  final _nuspController = TextEditingController();
  final _idadeController = TextEditingController();
  final _senhaController = TextEditingController();
  final _repitaSenhaController = TextEditingController();

  bool _concordouTermos = false;
  bool _receberNovidades = false;
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _criarConta() async {
    if (!_concordouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Concorde com os termos para continuar.')));
      return;
    }
    if (_senhaController.text != _repitaSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('As senhas não coincidem.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );
      if (cred.user != null) {
        await _firestoreService.createUserProfile(
          cred.user!,
          _nomeController.text.trim(),
          _cursoController.text.trim(),
          _nuspController.text.trim(),
        );
      }
      if (mounted) context.go('/inicio');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro. Este email já pode estar em uso.')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/images/logochaska_icon.svg', width: 100), 
              const SizedBox(height: 24),

              _buildLabel('NOME COMPLETO'),
              _buildTextField(_nomeController, 'EX: TAYRONE SA'),
              const SizedBox(height: 16),

              _buildLabel('EMAIL'),
              _buildTextField(_emailController, 'EX: OIMEUNOMEETAYRONE@USP.BR'),
              const SizedBox(height: 16),

              _buildLabel('CURSO'),
              _buildTextField(_cursoController, 'EX: ENGENHARIA DE PESCA'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('NUSP'),
                        _buildTextField(_nuspController, 'EX: 31415926'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('IDADE'),
                        _buildTextField(_idadeController, 'EX: 67', keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('SENHA'),
              _buildTextField(_senhaController, 'EX: SENHA', obscureText: true),
              const SizedBox(height: 16),

              _buildLabel('REPITA A SENHA'),
              _buildTextField(_repitaSenhaController, 'EX: SENHA', obscureText: true),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _concordouTermos,
                    activeColor: const Color(0xFF0460E9),
                    onChanged: (val) => setState(() => _concordouTermos = val ?? false),
                  ),
                  Expanded(child: Text('CONCORDO COM OS TERMOS', style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey[700]))),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _receberNovidades,
                    activeColor: const Color(0xFF0460E9),
                    onChanged: (val) => setState(() => _receberNovidades = val ?? false),
                  ),
                  Expanded(child: Text('GOSTARIA DE RECEBER NOVIDADES', style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey[700]))),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 14),
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0460E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Text('VOLTAR', style: TextStyle(fontFamily: 'Aristotelica', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 1.2)),
                          ),
                          Positioned(
                            left: -8,
                            child: SvgPicture.asset(
                              'assets/images/estrela_icon.svg', 
                              height: 38, 
                              colorFilter: const ColorFilter.mode(Color(0xFF0460E9), BlendMode.srcIn), 
                            ), 
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    flex: 6,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _criarConta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9ACD32), 
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('CRIAR CONTA', style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 1.2)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.blue[900])),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'Aristotelica', color: Colors.grey[400], fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}