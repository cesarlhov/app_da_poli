// lib/models/user_model.dart

/// Representa um usuário do aplicativo com suas informações de perfil.
class AppUser {
  final String uid;
  final String nome;
  final String email;
  final String curso;
  final String nusp;

  const AppUser({
    required this.uid,
    required this.nome,
    required this.email,
    required this.curso,
    required this.nusp,
  });

  /// Factory constructor para criar uma instância de [AppUser] a partir de um mapa.
  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      uid: id,
      nome: data['nome'] ?? 'Usuário sem nome',
      email: data['email'] ?? '',
      curso: data['curso'] ?? 'Não definido',
      nusp: data['nusp'] ?? '',
    );
  }
}