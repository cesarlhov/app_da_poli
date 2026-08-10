// lib/services/supabase_service.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadFotoPerfil(String userId, File imageFile) async {
    try {
      // Nome único para a foto do usuário
      final String path = 'perfil_$userId.jpg';

      // Envia o arquivo para o bucket 'avatars' (substitui se já existir)
      await _supabase.storage.from('avatars').upload(
        path,
        imageFile,
        fileOptions: const FileOptions(upsert: true),
      );

      // Pega a URL pública da imagem recém-enviada
      final String publicUrl = _supabase.storage.from('avatars').getPublicUrl(path);
      
      // Adiciona um timestamp na URL para forçar o Flutter a atualizar o cache visual da imagem
      return '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      throw Exception('Erro ao enviar imagem para o Supabase: $e');
    }
  }
}