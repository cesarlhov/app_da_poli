// lib/pages/profile_page.dart

import 'package:app_da_poli/components/add_disciplina_dialog.dart';
import 'package:app_da_poli/components/edit_profile_dialog.dart';
import 'package:app_da_poli/models/user_model.dart';
import 'package:app_da_poli/providers/user_provider.dart';
import 'package:app_da_poli/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:app_da_poli/services/supabase_service.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    if (userProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = userProvider.currentUser;

    if (user == null) {
      return _buildErrorState(context);
    }

    // ✅ LENDO A HIERARQUIA DO SEU MODELO ORIGINAL!
    final bool isGremio = user.isGremio;
    final bool isRC = user.isRC;
    final bool isAdmin = isGremio || isRC;
    
    String cargo = 'ALUNO';
    if (isGremio) cargo = 'GRÊMIO';
    else if (isRC) cargo = 'REPRESENTANTE';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Perfil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black54),
            onPressed: () => _showSettingsMenu(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            // Puxando o nomeCompleto do seu Modelo!
            Text(user.nomeCompleto, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              isAdmin ? '${user.curso} • $cargo' : user.curso, 
              style: TextStyle(
                fontSize: 16, 
                color: isAdmin ? const Color(0xFF0D41A9) : Colors.grey, 
                fontWeight: isAdmin ? FontWeight.bold : FontWeight.normal, 
              ),
              textAlign: TextAlign.center
            ),
            const SizedBox(height: 32),
            
            _buildProfileButton(
              context,
              label: 'Editar Perfil',
              icon: Icons.edit_outlined,
              onPressed: () => showDialog(context: context, builder: (context) => EditProfileDialog(currentUser: user)),
            ),
            
            if (isAdmin) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text('Painel de Administração', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 16),
              _buildProfileButton(
                context,
                label: 'Criar Turma Oficial',
                icon: Icons.add_business,
                isHighlight: true,
                onPressed: () => showDialog(context: context, builder: (context) => const AddDisciplinaDialog()),
              ),
              const SizedBox(height: 12),
              _buildProfileButton(
                context,
                label: 'Hub de Disciplinas',
                icon: Icons.admin_panel_settings_outlined,
                onPressed: () => context.push('/hub-disciplinas'),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // WIDGETS AUXILIARES EXTRAÍDOS PARA MANTER O BUILD LIMPO
  // =========================================================================

  Widget _buildErrorState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sync_problem, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('Seu perfil precisa ser atualizado.', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await AuthService().signOut();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sair e Fazer Login Novamente'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Alterar Foto de Perfil'),
                onTap: () async {
                  Navigator.pop(context); // Fecha o menu
                  print('🟢 1. Botão de alterar foto clicado!');
                  
                  final currentUser = context.read<UserProvider>().currentUser;
                  print('🟢 2. Usuário atual: ${currentUser?.uid}');
                  
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  
                  if (image != null) {
                    print('🟢 3. Imagem selecionada da galeria: ${image.path}');
                    if (currentUser != null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enviando foto...')));
                      }
                      try {
                        print('🟢 4. Tentando enviar para o Supabase...');
                        String fotoUrl = await SupabaseService().uploadFotoPerfil(currentUser.uid, File(image.path));
                        print('🟢 5. Sucesso no Supabase! URL gerada: $fotoUrl');
                        
                        print('🟢 6. Salvando URL no Firebase...');
                        await FirestoreService().atualizarFotoPerfilUrl(fotoUrl);
                        print('🟢 7. Salvo no Firebase com sucesso!');

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto atualizada com sucesso!'), backgroundColor: Colors.green));
                        }
                      } catch (e) {
                        print('🔴 ERRO CAPTURADO NO CATCH: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
                        }
                      }
                    } else {
                      print('🔴 ERRO: currentUser é nulo!');
                    }
                  } else {
                    print('🟡 AVISO: O usuário cancelou a seleção da imagem na galeria.');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configurações Gerais'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sair', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context); 
                  await AuthService().signOut(); 
                  if (context.mounted) context.go('/login'); 
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onPressed, bool isHighlight = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: isHighlight ? Colors.white : null),
        label: Text(label, style: TextStyle(color: isHighlight ? Colors.white : null)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isHighlight ? const Color(0xFF0D41A9) : null, 
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}