// lib/pages/admin_usuarios_page.dart

import 'package:app_da_poli/models/user_model.dart';
import 'package:app_da_poli/providers/user_provider.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminUsuariosPage extends StatelessWidget {
  const AdminUsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().currentUser;
    final FirestoreService firestoreService = FirestoreService();

    if (currentUser == null || (!currentUser.isGremio)) {
      return const Scaffold(body: Center(child: Text('Acesso Negado.')));
    }

    // O "Admin" supremo pode dar o cargo de admin. O Gremio normal não pode criar outros admins.
    // 🟢 Agora verificamos o poder supremo do Chov
    final bool amISupreme = currentUser.isChov;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Permissões', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: firestoreService.getTodosUsuarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text('Erro ao carregar usuários.'));

          final usuarios = snapshot.data ?? [];

          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              final bool isMe = usuario.uid == currentUser.uid;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF0460E9),
                    backgroundImage: usuario.fotoUrl != null ? NetworkImage(usuario.fotoUrl!) : null,
                    child: usuario.fotoUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                  ),
                  title: Text(usuario.nomeCompleto, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${usuario.curso}\nNUSP: ${usuario.numeroUSP}'),
                  isThreeLine: true,
                  trailing: isMe 
                    ? const Text('VOCÊ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))
                    : DropdownButton<String>(
                        value: usuario.role.name,
                        style: const TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, color: Color(0xFF0460E9)),
                        items: ['aluno', 'representante', 'gremio', if (amISupreme) 'chov'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (novoCargo) async {
                          if (novoCargo != null) {
                            // 1. Mostra um aviso de que está processando
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Atualizando permissões...'), duration: Duration(seconds: 1)),
                            );
                            
                            try {
                              // 2. AGORA ELE ESPERA (AWAIT) A CONFIRMAÇÃO DA NUVEM
                              await firestoreService.atualizarCargoUsuario(usuario.uid, novoCargo);
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${usuario.nomeCompleto} foi promovido para $novoCargo!'), backgroundColor: Colors.green),
                                );
                              }
                            } catch (e) {
                              // 3. SE DER ERRO (COMO FALTA DE INTERNET), AVISA NA TELA!
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro ao atualizar: $e'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          }
                        },
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}