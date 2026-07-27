// lib/pages/profile_page.dart

import 'package:app_da_poli/components/add_disciplina_dialog.dart';
import 'package:app_da_poli/components/edit_profile_dialog.dart';
import 'package:app_da_poli/models/user_model.dart';
import 'package:app_da_poli/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    void signOut() async {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) context.go('/login');
    }

    void _showSettingsMenu() {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Configurações Gerais'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Sair', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    signOut();
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    if (userProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = userProvider.currentUser;
    
    if (user == null) {
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
                onPressed: signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sair e Fazer Login Novamente'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // A MÁGICA DO CONTROLE DE ACESSO ACONTECE AQUI:
    final bool isAdmin = user.role == UserRole.gremio || user.role == UserRole.admin || user.role == UserRole.representante;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Perfil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black54),
            onPressed: _showSettingsMenu,
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
            Text(user.nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            // Mostra o cargo se for liderança
            Text(
              isAdmin ? '${user.curso} • ${user.role.name.toUpperCase()}' : user.curso, 
              style: TextStyle(fontSize: 16, color: isAdmin ? const Color(0xFF0D41A9) : Colors.grey, fontWeight: isAdmin ? FontWeight.bold : FontWeight.normal),
              textAlign: TextAlign.center
            ),
            const SizedBox(height: 32),
            _buildProfileButton(
              context,
              label: 'Editar Perfil',
              icon: Icons.edit_outlined,
              onPressed: () => showDialog(context: context, builder: (context) => EditProfileDialog(currentUser: user)),
            ),
            
            // SEÇÃO EXCLUSIVA PARA ADMINS/GRÊMIO
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
                onPressed: () {
                  showDialog(context: context, builder: (context) => const AddDisciplinaDialog());
                },
              ),
              const SizedBox(height: 12),
              _buildProfileButton(
                context,
                label: 'Hub de Disciplinas',
                icon: Icons.admin_panel_settings_outlined,
                onPressed: () {
                   context.push('/hub-disciplinas'); // <-- MUDOU AQUI
                },
              ),
            ]
          ],
        ),
      ),
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
          backgroundColor: isHighlight ? const Color(0xFF0D41A9) : null, // Cor da Poli se for destaque
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}